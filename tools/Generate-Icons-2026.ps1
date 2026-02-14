#requires -Version 5.1
<#
Generate-Icons-2026.ps1

- Generates two icon concepts (Premium + Glass) as PNG and ICO using System.Drawing
- Also exports quick previews at multiple sizes

Notes:
- This project is Windows-only.
- ICO generation here uses the built-in Icon.FromHandle approach for 256px.
    (Windows will downscale; for true multi-size ICO, see TODO in script.)
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Add-Type -AssemblyName System.Drawing

# Used by Save-Ico256 to avoid re-defining the Win32 P/Invoke type.
$script:Win32IconTypeLoaded = $false

function New-DirIfMissing {
    param([Parameter(Mandatory)] [string] $Path)
    if (-not (Test-Path -LiteralPath $Path)) {
        New-Item -ItemType Directory -Path $Path | Out-Null
    }
}

function New-LinearGradientBrush {
    param(
        [Parameter(Mandatory)] [System.Drawing.RectangleF] $Rect,
        [Parameter(Mandatory)] [System.Drawing.Color] $Start,
        [Parameter(Mandatory)] [System.Drawing.Color] $End,
        [float] $Angle = 45
    )

    $brush = New-Object System.Drawing.Drawing2D.LinearGradientBrush($Rect, $Start, $End, $Angle)
    # Slightly punchy blend
    $blend = New-Object System.Drawing.Drawing2D.Blend
    $blend.Positions = [float[]](0.0, 0.5, 1.0)
    $blend.Factors   = [float[]](1.0, 0.9, 1.0)
    $brush.Blend = $blend
    return $brush
}

function New-RoundedRectPath {
    param(
        [Parameter(Mandatory)] [System.Drawing.RectangleF] $Rect,
        [Parameter(Mandatory)] [float] $Radius
    )

    $path = New-Object System.Drawing.Drawing2D.GraphicsPath

    $d = [math]::Min($Radius * 2, [math]::Min($Rect.Width, $Rect.Height))
    $arc = New-Object System.Drawing.RectangleF($Rect.X, $Rect.Y, $d, $d)

    # Top-left
    $path.AddArc($arc, 180, 90)
    # Top-right
    $arc.X = $Rect.Right - $d
    $path.AddArc($arc, 270, 90)
    # Bottom-right
    $arc.Y = $Rect.Bottom - $d
    $path.AddArc($arc, 0, 90)
    # Bottom-left
    $arc.X = $Rect.X
    $path.AddArc($arc, 90, 90)

    $path.CloseFigure()
    return $path
}

function Save-Png {
    param(
        [Parameter(Mandatory)] [System.Drawing.Bitmap] $Bitmap,
        [Parameter(Mandatory)] [string] $Path
    )
    $Bitmap.Save($Path, [System.Drawing.Imaging.ImageFormat]::Png)
}

function Save-Ico256 {
    param(
        [Parameter(Mandatory)] [System.Drawing.Bitmap] $Bitmap,
        [Parameter(Mandatory)] [string] $Path
    )

    # ICO generated from a 256x256 bitmap. This creates a single-size ICO.
    # For perfect results across all Explorer sizes, we can build a multi-image ICO later.
    $hIcon = $Bitmap.GetHicon()
    try {
        $icon = [System.Drawing.Icon]::FromHandle($hIcon)
        $fs = [System.IO.File]::Open($Path, [System.IO.FileMode]::Create)
        try {
            $icon.Save($fs)
        } finally {
            $fs.Dispose()
        }
    } finally {
        # DestroyIcon to avoid handle leak (idempotent type load)
        if (-not $script:Win32IconTypeLoaded) {
            Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;
public static class XpolarisWin32Icon {
    [DllImport("user32.dll", SetLastError=true)]
    public static extern bool DestroyIcon(IntPtr hIcon);
}
'@ -Language CSharp
            $script:Win32IconTypeLoaded = $true
        }

        [XpolarisWin32Icon]::DestroyIcon($hIcon) | Out-Null
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

function New-PremiumIcon {
    param([int] $Size = 1024)

    $bmp = New-Object System.Drawing.Bitmap($Size, $Size, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    try {
        $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
        $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
        $g.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
        $g.Clear([System.Drawing.Color]::Transparent)

        $pad = [int]([math]::Round($Size * 0.06))
    $rect = [System.Drawing.RectangleF]::new([single]$pad, [single]$pad, [single]($Size - (2 * $pad)), [single]($Size - (2 * $pad)))

        # Very rounded corners (iOS-ish)
        $radius = [float]($rect.Width * 0.28)
        $path = New-RoundedRectPath -Rect $rect -Radius $radius

        # Background gradient: #6A00FF -> #0066FF
        $c1 = [System.Drawing.ColorTranslator]::FromHtml('#6A00FF')
        $c2 = [System.Drawing.ColorTranslator]::FromHtml('#0066FF')
        $bgBrush = New-LinearGradientBrush -Rect $rect -Start $c1 -End $c2 -Angle 45

        $g.FillPath($bgBrush, $path)

        # Inner shadow (soft internal relief)
        # Technique: draw a slightly smaller rounded rect with a semi-transparent dark stroke and blur-like multiple strokes
        $innerLevels = 10
        for ($i = 0; $i -lt $innerLevels; $i++) {
            $alpha = [int](28 - ($i * 2))
            if ($alpha -lt 2) { $alpha = 2 }
            $pen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb($alpha, 0, 0, 0), [float]($Size * 0.006 + $i * ($Size * 0.0008)))
            $pen.Alignment = [System.Drawing.Drawing2D.PenAlignment]::Inset
            $g.DrawPath($pen, $path)
            $pen.Dispose()
        }

        # Subtle highlight rim
        $rimPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(26, 255, 255, 255), [float]($Size * 0.004))
        $rimPen.Alignment = [System.Drawing.Drawing2D.PenAlignment]::Inset
        $g.DrawPath($rimPen, $path)
        $rimPen.Dispose()

        # The X: white, slightly rounded (thick strokes with round caps)
        $xPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(245, 255, 255, 255), [float]($Size * 0.10))
        $xPen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
        $xPen.EndCap   = [System.Drawing.Drawing2D.LineCap]::Round
        $xPen.LineJoin = [System.Drawing.Drawing2D.LineJoin]::Round

        $xPad = [float]($Size * 0.26)
        $x1 = $xPad
        $y1 = $xPad
        $x2 = $Size - $xPad
        $y2 = $Size - $xPad

        # Tiny drop shadow under X (helps small sizes)
        $shadowPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(35, 0, 0, 0), [float]($Size * 0.10))
        $shadowPen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
        $shadowPen.EndCap   = [System.Drawing.Drawing2D.LineCap]::Round
        $shadowPen.LineJoin = [System.Drawing.Drawing2D.LineJoin]::Round
        $offset = [float]($Size * 0.012)
        $g.DrawLine($shadowPen, $x1 + $offset, $y1 + $offset, $x2 + $offset, $y2 + $offset)
        $g.DrawLine($shadowPen, $x2 + $offset, $y1 + $offset, $x1 + $offset, $y2 + $offset)
        $shadowPen.Dispose()

        $g.DrawLine($xPen, $x1, $y1, $x2, $y2)
        $g.DrawLine($xPen, $x2, $y1, $x1, $y2)
        $xPen.Dispose()

        # Diagonal gloss is intentionally minimal for premium
        $glossPath = New-Object System.Drawing.Drawing2D.GraphicsPath
        $glossPath.AddPolygon([System.Drawing.PointF[]]@(
            [System.Drawing.PointF]::new([single]$rect.X, [single]($rect.Y + $rect.Height * 0.15)),
            [System.Drawing.PointF]::new([single]($rect.X + $rect.Width * 0.85), [single]$rect.Y),
            [System.Drawing.PointF]::new([single]($rect.X + $rect.Width), [single]$rect.Y),
            [System.Drawing.PointF]::new([single]$rect.X, [single]($rect.Y + $rect.Height * 0.45))
        ))
        $glossBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(18, 255, 255, 255))
        $g.SetClip($path)
        $g.FillPath($glossBrush, $glossPath)
        $g.ResetClip()
        $glossBrush.Dispose()
        $glossPath.Dispose()

        $bgBrush.Dispose()
        $path.Dispose()

        return $bmp
    } finally {
        $g.Dispose()
    }
}

function New-GlassIcon {
    param([int] $Size = 1024)

    $bmp = New-Object System.Drawing.Bitmap($Size, $Size, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    try {
        $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
        $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
        $g.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
        $g.Clear([System.Drawing.Color]::Transparent)

        $pad = [int]([math]::Round($Size * 0.06))
    $rect = [System.Drawing.RectangleF]::new([single]$pad, [single]$pad, [single]($Size - (2 * $pad)), [single]($Size - (2 * $pad)))
        $radius = [float]($rect.Width * 0.26)
        $path = New-RoundedRectPath -Rect $rect -Radius $radius

        # Base gradient
        $c1 = [System.Drawing.ColorTranslator]::FromHtml('#6A00FF')
        $c2 = [System.Drawing.ColorTranslator]::FromHtml('#0066FF')
        $bgBrush = New-LinearGradientBrush -Rect $rect -Start $c1 -End $c2 -Angle 35
        $g.FillPath($bgBrush, $path)

        # Blurry background shapes (simulated by layered translucent circles)
        # Keep them subtle so the icon stays readable at 16/32px.
        $g.SetClip($path)
        $circles = @(
            @{ X = 0.20; Y = 0.28; R = 0.36; A = 26; C = '#FF4FD8' },
            @{ X = 0.78; Y = 0.30; R = 0.40; A = 22; C = '#00E5FF' },
            @{ X = 0.55; Y = 0.82; R = 0.48; A = 18; C = '#7CFF6B' }
        )

        foreach ($c in $circles) {
            $cx = [float]($rect.X + $rect.Width * $c.X)
            $cy = [float]($rect.Y + $rect.Height * $c.Y)
            $r  = [float]($rect.Width * $c.R)
            $col = [System.Drawing.ColorTranslator]::FromHtml($c.C)

            for ($i = 0; $i -lt 10; $i++) {
                $a = [int]($c.A - $i*2)
                if ($a -lt 2) { $a = 2 }
                $brush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb($a, $col))
                $grow = [float]($i * $rect.Width * 0.009)
                $g.FillEllipse($brush, $cx - $r/2 - $grow, $cy - $r/2 - $grow, $r + 2*$grow, $r + 2*$grow)
                $brush.Dispose()
            }
        }

    # Glass plate overlay (slightly stronger so the X pops at small sizes)
    $glassBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(46, 255, 255, 255))
        $g.FillPath($glassBrush, $path)
        $glassBrush.Dispose()

    # Diagonal subtle reflection
        $refPath = New-Object System.Drawing.Drawing2D.GraphicsPath
        $refPath.AddPolygon([System.Drawing.PointF[]]@(
            [System.Drawing.PointF]::new([single]($rect.X - $rect.Width * 0.10), [single]($rect.Y + $rect.Height * 0.15)),
            [System.Drawing.PointF]::new([single]($rect.X + $rect.Width * 0.85), [single]($rect.Y - $rect.Height * 0.10)),
            [System.Drawing.PointF]::new([single]($rect.X + $rect.Width * 1.10), [single]($rect.Y + $rect.Height * 0.10)),
            [System.Drawing.PointF]::new([single]($rect.X + $rect.Width * 0.15), [single]($rect.Y + $rect.Height * 0.35))
        ))
    $refBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(28, 255, 255, 255))
        $g.FillPath($refBrush, $refPath)
        $refBrush.Dispose()
        $refPath.Dispose()

    # The X: semi-transparent glass + luminous white outline
    # Make it thicker / brighter to stay legible at 16/32px.
        $xPad = [float]($Size * 0.27)
        $x1 = $xPad
        $y1 = $xPad
        $x2 = $Size - $xPad
        $y2 = $Size - $xPad

    $glowPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(190, 255, 255, 255), [float]($Size * 0.135))
        $glowPen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
        $glowPen.EndCap   = [System.Drawing.Drawing2D.LineCap]::Round
        $glowPen.LineJoin = [System.Drawing.Drawing2D.LineJoin]::Round

    $xFillPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(110, 255, 255, 255), [float]($Size * 0.108))
        $xFillPen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
        $xFillPen.EndCap   = [System.Drawing.Drawing2D.LineCap]::Round
        $xFillPen.LineJoin = [System.Drawing.Drawing2D.LineJoin]::Round

        $g.DrawLine($glowPen, $x1, $y1, $x2, $y2)
        $g.DrawLine($glowPen, $x2, $y1, $x1, $y2)

        $g.DrawLine($xFillPen, $x1, $y1, $x2, $y2)
        $g.DrawLine($xFillPen, $x2, $y1, $x1, $y2)

        $glowPen.Dispose()
        $xFillPen.Dispose()

        # Outer luminous rim
        $rimPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(40, 255, 255, 255), [float]($Size * 0.006))
        $rimPen.Alignment = [System.Drawing.Drawing2D.PenAlignment]::Inset
        $g.DrawPath($rimPen, $path)
        $rimPen.Dispose()

        $g.ResetClip()

        $bgBrush.Dispose()
        $path.Dispose()

        return $bmp
    } finally {
        $g.Dispose()
    }
}

function Export-IconSet {
    param(
        [Parameter(Mandatory)] [System.Drawing.Bitmap] $Bitmap1024,
        [Parameter(Mandatory)] [string] $BaseName,
        [Parameter(Mandatory)] [string] $OutDir
    )

    New-DirIfMissing -Path $OutDir

    $png1024 = Join-Path $OutDir "$BaseName-1024.png"
    Save-Png -Bitmap $Bitmap1024 -Path $png1024

    $bmp256 = Resize-Bitmap -Bitmap $Bitmap1024 -Size 256
    try {
        $png256 = Join-Path $OutDir "$BaseName-256.png"
        Save-Png -Bitmap $bmp256 -Path $png256

        $ico = Join-Path $OutDir "$BaseName.ico"
        Save-Ico256 -Bitmap $bmp256 -Path $ico

        # Quick previews
        foreach ($s in 64, 48, 32, 24, 16) {
            $b = Resize-Bitmap -Bitmap $Bitmap1024 -Size $s
            try {
                Save-Png -Bitmap $b -Path (Join-Path $OutDir "$BaseName-$s.png")
            } finally {
                $b.Dispose()
            }
        }

    } finally {
        $bmp256.Dispose()
    }
}

# --- Main
$root = Split-Path -Parent $PSScriptRoot
$out = Join-Path $root 'assets\icons-2026'
New-DirIfMissing -Path $out

Write-Host "Generating Premium icon..." -ForegroundColor Cyan
$prem = New-PremiumIcon -Size 1024
try {
    Export-IconSet -Bitmap1024 $prem -BaseName 'Xpolaris-Premium' -OutDir $out
} finally {
    $prem.Dispose()
}

Write-Host "Generating Glass icon..." -ForegroundColor Cyan
$glass = New-GlassIcon -Size 1024
try {
    Export-IconSet -Bitmap1024 $glass -BaseName 'Xpolaris-Glass' -OutDir $out
} finally {
    $glass.Dispose()
}

Write-Host "Done. Output: $out" -ForegroundColor Green
