#requires -Version 5.1
<#
PngToIco-MultiSize.ps1

Creates a true multi-size .ico containing 16/24/32/48/64/128/256 PNG-compressed entries.

Why: Windows Explorer picks the closest size; multi-size ICO looks crisp everywhere.

Usage:
    pwsh -NoProfile -ExecutionPolicy Bypass -File tools\PngToIco-MultiSize.ps1 -InputPng "assets\icons-2026\Xpolaris-Glass-1024.png" -OutputIco "assets\icons-2026\Xpolaris-Glass-Multi.ico"
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string] $InputPng,

    [Parameter(Mandatory)]
    [string] $OutputIco,

    [int[]] $Sizes = @(16,24,32,48,64,128,256)
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Add-Type -AssemblyName System.Drawing

function Get-PngBytesFromBitmap {
    param([Parameter(Mandatory)][System.Drawing.Bitmap] $Bitmap)
    $ms = New-Object System.IO.MemoryStream
    try {
        $Bitmap.Save($ms, [System.Drawing.Imaging.ImageFormat]::Png)
        return $ms.ToArray()
    } finally {
        $ms.Dispose()
    }
}

function Resize-Bitmap {
    param(
        [Parameter(Mandatory)] [System.Drawing.Bitmap] $Bitmap,
        [Parameter(Mandatory)] [int] $Size
    )
    $dst = New-Object System.Drawing.Bitmap($Size, $Size, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $g = [System.Drawing.Graphics]::FromImage($dst)
    try {
        $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
        $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
        $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
        $g.Clear([System.Drawing.Color]::Transparent)
        $g.DrawImage($Bitmap, 0, 0, $Size, $Size)
    } finally {
        $g.Dispose()
    }
    return $dst
}

if (-not (Test-Path -LiteralPath $InputPng)) {
    throw "Input PNG not found: $InputPng"
}

$dir = Split-Path -Parent $OutputIco
if ($dir -and -not (Test-Path -LiteralPath $dir)) {
    New-Item -ItemType Directory -Path $dir | Out-Null
}

$base = [System.Drawing.Bitmap]::FromFile($InputPng)
try {
    # Prepare images bytes for each size
    $entries = @()
    foreach ($s in $Sizes) {
        $b = Resize-Bitmap -Bitmap $base -Size $s
        try {
            $pngBytes = Get-PngBytesFromBitmap -Bitmap $b
            $entries += [pscustomobject]@{ Size = $s; Bytes = $pngBytes }
        } finally {
            $b.Dispose()
        }
    }

    # Build ICO
    $fs = [System.IO.File]::Open($OutputIco, [System.IO.FileMode]::Create)
    $bw = New-Object System.IO.BinaryWriter($fs)
    try {
        # ICONDIR
        $bw.Write([UInt16]0) # reserved
        $bw.Write([UInt16]1) # type 1 = icon
        $bw.Write([UInt16]$entries.Count)

        $dirEntryStart = $fs.Position
        # Write placeholder ICONDIRENTRY structs (16 bytes each)
        for ($i=0; $i -lt $entries.Count; $i++) {
            0..15 | ForEach-Object { $bw.Write([byte]0) }
        }

        $imageDataOffsets = @()
        foreach ($e in $entries) {
            $imageDataOffsets += [int]$fs.Position
            $bw.Write($e.Bytes)
        }

        # Go back and fill directory entries
        $fs.Position = $dirEntryStart
        for ($i=0; $i -lt $entries.Count; $i++) {
            $e = $entries[$i]
            $sizeByte = if ($e.Size -ge 256) { 0 } else { [byte]$e.Size }

            $bw.Write($sizeByte)         # bWidth
            $bw.Write($sizeByte)         # bHeight
            $bw.Write([byte]0)           # bColorCount
            $bw.Write([byte]0)           # bReserved
            $bw.Write([UInt16]1)         # wPlanes
            $bw.Write([UInt16]32)        # wBitCount
            $bw.Write([UInt32]$e.Bytes.Length)      # dwBytesInRes
            $bw.Write([UInt32]$imageDataOffsets[$i]) # dwImageOffset
        }

    } finally {
        $bw.Dispose()
        $fs.Dispose()
    }

} finally {
    $base.Dispose()
}

Write-Host "Wrote multi-size ICO: $OutputIco" -ForegroundColor Green
