# Script pour générer une icône moderne pour Xpolaris GUI
# Utilise System.Drawing pour créer une icône .ico

Add-Type -AssemblyName System.Drawing

# Créer un bitmap 256x256 pour haute résolution
$size = 256
$bitmap = New-Object System.Drawing.Bitmap($size, $size)
$graphics = [System.Drawing.Graphics]::FromImage($bitmap)
$graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic

# Fond dégradé bleu moderne
$rect = New-Object System.Drawing.Rectangle(0, 0, $size, $size)
$brush = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
    $rect,
    [System.Drawing.Color]::FromArgb(255, 0, 120, 212),  # #0078D4
    [System.Drawing.Color]::FromArgb(255, 0, 217, 255),  # #00D9FF
    45
)
$graphics.FillEllipse($brush, 10, 10, $size-20, $size-20)

# Bordure blanche pour effet glassmorphism
$penWhite = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(100, 255, 255, 255), 8)
$graphics.DrawEllipse($penWhite, 15, 15, $size-30, $size-30)

# Dessiner un "X" stylisé au centre (pour Xpolaris)
$penX = New-Object System.Drawing.Pen([System.Drawing.Color]::White, 24)
$penX.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
$penX.EndCap = [System.Drawing.Drawing2D.LineCap]::Round

$margin = 70
$graphics.DrawLine($penX, $margin, $margin, $size-$margin, $size-$margin)
$graphics.DrawLine($penX, $size-$margin, $margin, $margin, $size-$margin)

# Ajouter un point lumineux (effet de brillance)
$highlight = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
    (New-Object System.Drawing.Point(60, 60)),
    (New-Object System.Drawing.Point(120, 120)),
    [System.Drawing.Color]::FromArgb(180, 255, 255, 255),
    [System.Drawing.Color]::FromArgb(0, 255, 255, 255)
)
$graphics.FillEllipse($highlight, 50, 50, 80, 80)

# Nettoyage
$graphics.Dispose()

# Sauvegarder en tant qu'icône
$iconPath = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) "Xpolaris-Icon.ico"

# Convertir en .ico avec plusieurs tailles
$icon = [System.Drawing.Icon]::FromHandle($bitmap.GetHicon())

# Sauvegarder
$fileStream = New-Object System.IO.FileStream($iconPath, [System.IO.FileMode]::Create)
$icon.Save($fileStream)
$fileStream.Close()

# Libérer les ressources
$bitmap.Dispose()

Write-Host "`n✅ Icône créée avec succès !" -ForegroundColor Green
Write-Host "📁 Emplacement : $iconPath" -ForegroundColor Cyan
Write-Host "🎨 Style : Moderne, dégradé bleu, X stylisé" -ForegroundColor Yellow
Write-Host "`n💡 Recompilez avec Compile-GUI.ps1 pour appliquer l'icône`n" -ForegroundColor Magenta
