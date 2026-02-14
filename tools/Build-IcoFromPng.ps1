<#
Build-IcoFromPng.ps1

Creates a multi-size ICO file with BMP-format entries (not PNG).
This is compatible with ps2exe / csc.exe Win32 resource embedding.

Each size gets its own pre-rendered bitmap from the source PNG (high-quality bicubic).
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string] $InputPng,

    [Parameter(Mandatory)]
    [string] $OutputIco,

    [int[]] $Sizes = @(16, 24, 32, 48, 64, 128, 256)
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Add-Type -AssemblyName System.Drawing

function Resize-Bitmap {
    param(
        [System.Drawing.Bitmap] $Source,
        [int] $Size
    )
    $dst = New-Object System.Drawing.Bitmap($Size, $Size, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $g = [System.Drawing.Graphics]::FromImage($dst)
    try {
        $g.SmoothingMode      = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
        $g.InterpolationMode  = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
        $g.PixelOffsetMode    = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
        $g.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
        $g.Clear([System.Drawing.Color]::Transparent)
        $g.DrawImage($Source, 0, 0, $Size, $Size)
    }
    finally { $g.Dispose() }
    return $dst
}

function Get-BmpDibBytes {
    <#
    Returns raw DIB bytes (BITMAPINFOHEADER + pixel data bottom-up + AND mask)
    for embedding inside an ICO file. Uses LockBits for speed.
    #>
    param([System.Drawing.Bitmap] $Bitmap)

    $w = $Bitmap.Width
    $h = $Bitmap.Height

    # Lock bitmap and copy pixel data (top-down, BGRA)
    $rect = [System.Drawing.Rectangle]::new(0, 0, $w, $h)
    $bmpData = $Bitmap.LockBits($rect, [System.Drawing.Imaging.ImageLockMode]::ReadOnly, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    try {
        $stride = [math]::Abs($bmpData.Stride)
        $totalPixelBytes = $stride * $h
        $pixelsTopDown = New-Object byte[] $totalPixelBytes
        [System.Runtime.InteropServices.Marshal]::Copy($bmpData.Scan0, $pixelsTopDown, 0, $totalPixelBytes)
    }
    finally {
        $Bitmap.UnlockBits($bmpData)
    }

    # Build bottom-up pixel array (ICO BMP format is bottom-up)
    $rowBytes = $w * 4
    $pixelsBottomUp = New-Object byte[] ($rowBytes * $h)
    for ($y = 0; $y -lt $h; $y++) {
        $srcOffset = $y * $stride
        $dstOffset = ($h - 1 - $y) * $rowBytes
        [Array]::Copy($pixelsTopDown, $srcOffset, $pixelsBottomUp, $dstOffset, $rowBytes)
    }

    # AND mask (all zeros = opaque; alpha already in pixels)
    $andMaskRowBytes = [int]([math]::Ceiling($w / 32.0)) * 4
    $andMaskSize = $andMaskRowBytes * $h
    $andMask = New-Object byte[] $andMaskSize

    # Assemble: BITMAPINFOHEADER (40) + pixels + AND mask
    $ms = New-Object System.IO.MemoryStream
    $bw2 = New-Object System.IO.BinaryWriter($ms)

    # BITMAPINFOHEADER
    $bw2.Write([int32]40)                  # biSize
    $bw2.Write([int32]$w)                  # biWidth
    $bw2.Write([int32]($h * 2))            # biHeight (doubled for ICO)
    $bw2.Write([int16]1)                   # biPlanes
    $bw2.Write([int16]32)                  # biBitCount
    $bw2.Write([int32]0)                   # biCompression (BI_RGB)
    $bw2.Write([int32]($pixelsBottomUp.Length + $andMaskSize))  # biSizeImage
    $bw2.Write([int32]0)                   # biXPelsPerMeter
    $bw2.Write([int32]0)                   # biYPelsPerMeter
    $bw2.Write([int32]0)                   # biClrUsed
    $bw2.Write([int32]0)                   # biClrImportant

    $bw2.Write($pixelsBottomUp)
    $bw2.Write($andMask)
    $bw2.Flush()

    $result = $ms.ToArray()
    $bw2.Dispose()
    $ms.Dispose()
    return ,$result
}

# --- Main ---

if (-not (Test-Path -LiteralPath $InputPng)) {
    throw "Input PNG not found: $InputPng"
}

$dir = Split-Path -Parent $OutputIco
if ($dir -and -not (Test-Path -LiteralPath $dir)) {
    New-Item -ItemType Directory -Path $dir | Out-Null
}

Write-Host "Loading source: $InputPng" -ForegroundColor Cyan
$source = [System.Drawing.Bitmap]::FromFile((Resolve-Path $InputPng).Path)

try {
    # Pre-render each size
    $entries = [System.Collections.Generic.List[object]]::new()
    foreach ($s in $Sizes) {
        Write-Host "  Rendering ${s}x${s}..." -NoNewline
        $bmp = Resize-Bitmap -Source $source -Size $s
        try {
            $dibBytes = Get-BmpDibBytes -Bitmap $bmp
            $entries.Add([pscustomobject]@{ Size = [int]$s; DibBytes = [byte[]]$dibBytes })
            Write-Host " OK ($($dibBytes.Length) bytes)" -ForegroundColor Green
        }
        finally { $bmp.Dispose() }
    }

    Write-Host "  Total entries: $($entries.Count)" -ForegroundColor Yellow

    # Build ICO file
    $icoPath = if ([System.IO.Path]::IsPathRooted($OutputIco)) { $OutputIco } else { Join-Path (Get-Location).Path $OutputIco }
    $fs = [System.IO.File]::Open($icoPath, [System.IO.FileMode]::Create)
    $bw = New-Object System.IO.BinaryWriter($fs)
    try {
        [int]$numImages = $entries.Count

        # ICONDIR header (6 bytes)
        $bw.Write([UInt16]0)            # reserved
        $bw.Write([UInt16]1)            # type = ICO
        $bw.Write([UInt16]$numImages)   # count

        # Calculate offsets: header(6) + entries(16 each) + image data
        [int]$dataOffset = 6 + ($numImages * 16)

        # Write ICONDIRENTRY for each image
        for ($i = 0; $i -lt $numImages; $i++) {
            $e = $entries[$i]
            [byte]$sizeByte = if ($e.Size -ge 256) { 0 } else { $e.Size }
            $bw.Write($sizeByte)            # bWidth
            $bw.Write($sizeByte)            # bHeight
            $bw.Write([byte]0)              # bColorCount
            $bw.Write([byte]0)              # bReserved
            $bw.Write([UInt16]1)            # wPlanes
            $bw.Write([UInt16]32)           # wBitCount
            $bw.Write([UInt32]$e.DibBytes.Length)   # dwBytesInRes
            $bw.Write([UInt32]$dataOffset)          # dwImageOffset
            $dataOffset += $e.DibBytes.Length
        }

        # Write image data
        for ($i = 0; $i -lt $numImages; $i++) {
            $e = $entries[$i]
            $bw.Write([byte[]]$e.DibBytes)
        }

    }
    finally {
        $bw.Dispose()
        $fs.Dispose()
    }
}
finally {
    $source.Dispose()
}

$info = Get-Item $OutputIco
Write-Host "`nWrote: $($info.FullName)" -ForegroundColor Green
Write-Host "Size: $([math]::Round($info.Length / 1KB, 1)) KB, $($Sizes.Count) images ($($Sizes -join ', ')px)" -ForegroundColor Green
