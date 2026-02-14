#Requires -Version 5.1
<#
.SYNOPSIS
    Compile l'interface graphique WPF en exécutable
.DESCRIPTION
    Transforme Xpolaris-GUI.ps1 en Xpolaris-GUI.exe avec ps2exe
.NOTES
    Version: 3.0.0
    Date: 1 février 2026
#>

# Chemins
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$sourceScript = Join-Path $scriptPath "Xpolaris-GUI.ps1"
$outputExe = Join-Path $scriptPath "Xpolaris-GUI.exe"
$oldExe = Join-Path $scriptPath "Xpolaris-GUI-OLD.exe"
$iconPath = Join-Path $scriptPath "Xpolaris-Icon.ico" # Icône moderne

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  Compilation GUI Xpolaris v3.0.0" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# Étape 1 : Vérifier que le script source existe
if (-not (Test-Path $sourceScript)) {
    Write-Host "[ERREUR] Le fichier source n'existe pas : $sourceScript" -ForegroundColor Red
    exit 1
}

Write-Host "[1/5] ✓ Script source trouvé : Xpolaris-GUI.ps1" -ForegroundColor Green

# Étape 2 : Vérifier que ps2exe est installé
Write-Host "[2/5] Vérification de ps2exe..." -ForegroundColor Yellow

try {
    $ps2exeModule = Get-Module -ListAvailable -Name ps2exe
    if (-not $ps2exeModule) {
        Write-Host "      Module ps2exe non trouvé. Installation..." -ForegroundColor Yellow
        Install-Module -Name ps2exe -Force -Scope CurrentUser -AllowClobber
        Import-Module ps2exe
        Write-Host "      ✓ ps2exe installé avec succès" -ForegroundColor Green
    } else {
        Import-Module ps2exe -Force
        Write-Host "      ✓ ps2exe déjà installé" -ForegroundColor Green
    }
} catch {
    Write-Host "[ERREUR] Impossible d'installer/charger ps2exe : $_" -ForegroundColor Red
    exit 1
}

# Étape 3 : Supprimer l'ancien exécutable s'il existe
if (Test-Path $outputExe) {
    Write-Host "[3/5] Ancien EXE détecté..." -ForegroundColor Yellow
    
    try {
        # Renommer l'ancien EXE en backup
        if (Test-Path $oldExe) {
            Remove-Item $oldExe -Force
        }
        Rename-Item $outputExe $oldExe -Force
        Write-Host "      ✓ Ancien EXE sauvegardé : Xpolaris-GUI-OLD.exe" -ForegroundColor Green
    } catch {
        Write-Host "      ⚠ Impossible de renommer l'ancien EXE (fichier en cours d'utilisation ?)" -ForegroundColor Yellow
        Write-Host "      Tentative de suppression forcée..." -ForegroundColor Yellow
        
        try {
            Remove-Item $outputExe -Force
            Write-Host "      ✓ Ancien EXE supprimé" -ForegroundColor Green
        } catch {
            Write-Host "[ERREUR] Impossible de supprimer l'ancien EXE. Fermez-le et réessayez." -ForegroundColor Red
            exit 1
        }
    }
} else {
    Write-Host "[3/5] ✓ Aucun ancien EXE à supprimer" -ForegroundColor Green
}

# Étape 4 : Compilation avec ps2exe
Write-Host "[4/5] Compilation en cours..." -ForegroundColor Yellow
Write-Host "      Source : Xpolaris-GUI.ps1" -ForegroundColor Gray
Write-Host "      Sortie : Xpolaris-GUI.exe" -ForegroundColor Gray
Write-Host "      Mode   : GUI (fenêtre uniquement, pas de console)" -ForegroundColor Gray

try {
    # Paramètres de compilation
    $compileParams = @{
        inputFile      = $sourceScript
        outputFile     = $outputExe
        noConsole      = $true          # GUI sans console
        requireAdmin   = $true          # Nécessite les droits admin
        title          = "Xpolaris Windows Customizer Pro"
        description    = "Interface graphique moderne pour personnaliser Windows"
        company        = "Xpolaris"
        product        = "Windows Customizer"
        copyright      = "© 2026 Xpolaris"
        version        = "3.0.0.0"
        noError        = $false
        noOutput       = $false
    }
    
    # Ajouter l'icône si elle existe
    if ($iconPath -and (Test-Path $iconPath)) {
        $compileParams.iconFile = $iconPath
        Write-Host "      Icône  : $iconPath" -ForegroundColor Gray
    }
    
    # Lancer la compilation
    Invoke-ps2exe @compileParams
    
    Write-Host "`n      ✓ Compilation terminée avec succès !" -ForegroundColor Green
    
} catch {
    Write-Host "`n[ERREUR] Échec de la compilation : $_" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
}

# Étape 5 : Vérifier la sortie
Write-Host "[5/5] Vérification de l'exécutable..." -ForegroundColor Yellow

if (Test-Path $outputExe) {
    $exeInfo = Get-Item $outputExe
    $sizeMB = [math]::Round($exeInfo.Length / 1MB, 2)
    
    Write-Host "      ✓ Fichier créé : Xpolaris-GUI.exe" -ForegroundColor Green
    Write-Host "      Taille        : $sizeMB MB" -ForegroundColor Gray
    Write-Host "      Date          : $($exeInfo.LastWriteTime)" -ForegroundColor Gray
    Write-Host "      Emplacement   : $outputExe" -ForegroundColor Gray
    
    Write-Host "`n========================================" -ForegroundColor Cyan
    Write-Host "  ✓ COMPILATION RÉUSSIE !" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Cyan
    
    Write-Host "`n📌 Instructions :" -ForegroundColor Yellow
    Write-Host "   1. Double-cliquez sur Xpolaris-GUI.exe" -ForegroundColor White
    Write-Host "   2. Acceptez l'élévation UAC (droits admin)" -ForegroundColor White
    Write-Host "   3. L'interface graphique se lancera automatiquement" -ForegroundColor White
    
    Write-Host "`n📦 Fichiers générés :" -ForegroundColor Yellow
    Write-Host "   - Xpolaris-GUI.exe          (Nouvelle version GUI)" -ForegroundColor Cyan
    Write-Host "   - Xpolaris-GUI-OLD.exe      (Backup de l'ancienne version)" -ForegroundColor Gray
    Write-Host "   - Xpolaris-Windows-Customizer.exe  (Version console originale)" -ForegroundColor Gray
    
    Write-Host "`n💡 Conseil : Gardez les deux versions (console + GUI)" -ForegroundColor Magenta
    Write-Host "   pour plus de flexibilité !`n" -ForegroundColor Magenta
    
} else {
    Write-Host "`n[ERREUR] Le fichier EXE n'a pas été créé" -ForegroundColor Red
    exit 1
}

# Demander si on veut lancer l'EXE
Write-Host "Voulez-vous lancer Xpolaris-GUI.exe maintenant ? (O/N) : " -ForegroundColor Yellow -NoNewline
$response = Read-Host

if ($response -eq 'O' -or $response -eq 'o') {
    Write-Host "`nLancement de l'interface graphique..." -ForegroundColor Green
    Start-Process $outputExe
} else {
    Write-Host "`nCompilation terminée. Vous pouvez lancer Xpolaris-GUI.exe manuellement.`n" -ForegroundColor Cyan
}
