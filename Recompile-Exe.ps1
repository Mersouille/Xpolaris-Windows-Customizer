#Requires -RunAsAdministrator
# Script simplifié de recompilation de Xpolaris-Windows-Customizer.exe

$ErrorActionPreference = "Stop"
$ScriptPath = "$PSScriptRoot\Windows-CustomizeMaster.ps1"
$ExePath = "$PSScriptRoot\Xpolaris-Windows-Customizer.exe"

Clear-Host
Write-Host ""
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  RECOMPILATION DE XPOLARIS-WINDOWS-CUSTOMIZER.EXE" -ForegroundColor Yellow
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

# Validation rapide
Write-Host "Validation du script..." -NoNewline
if (-not (Test-Path $ScriptPath)) {
    Write-Host " ❌" -ForegroundColor Red
    Write-Host "Erreur: Script source non trouvé" -ForegroundColor Red
    pause
    exit 1
}
Write-Host " ✅" -ForegroundColor Green

Write-Host " ✅" -ForegroundColor Green

# Vérification de ps2exe
Write-Host "Verification de ps2exe..." -NoNewline
$PS2EXE = Get-Command ps2exe -ErrorAction SilentlyContinue
if (-not $PS2EXE) {
    Write-Host " ❌" -ForegroundColor Red
    Write-Host ""
    Write-Host "Installation de ps2exe..." -ForegroundColor Yellow
    try {
        Install-Module -Name ps2exe -Scope CurrentUser -Force
        Write-Host "✅ ps2exe installe" -ForegroundColor Green
    } catch {
        Write-Host "❌ Échec: $_" -ForegroundColor Red
        Write-Host ""
        Write-Host "Installez manuellement: Install-Module -Name ps2exe" -ForegroundColor Yellow
        pause
        exit 1
    }
} else {
    Write-Host " ✅" -ForegroundColor Green
}

# Suppression de l'ancien exe
Write-Host "Suppression de l'ancien exe..." -NoNewline
if (Test-Path $ExePath) {
    try {
        Remove-Item $ExePath -Force
        Write-Host " ✅" -ForegroundColor Green
    } catch {
        Write-Host " ❌" -ForegroundColor Yellow
        Write-Host "L'exe est peut-être en cours d'exécution. Fermez-le et réessayez." -ForegroundColor Yellow
        pause
        exit 1
    }
} else {
    Write-Host " ⏭️" -ForegroundColor Gray
}

# Compilation
Write-Host ""
Write-Host "Compilation en cours..." -ForegroundColor Cyan
Write-Host "(Cela peut prendre 1-2 minutes)" -ForegroundColor Gray
Write-Host ""

try {
    Invoke-ps2exe `
        -InputFile $ScriptPath `
        -OutputFile $ExePath `
        -noConsole:$false `
        -requireAdmin `
        -title "Xpolaris Windows Customizer" `
        -description "Windows 11 Customizer - Edition Sans Bloatware" `
        -company "Xpolaris" `
        -product "Xpolaris Windows Customizer" `
        -version "2.2.0.0" `
        -ErrorAction Stop
    
    Write-Host ""
    Write-Host "✅ Compilation terminee" -ForegroundColor Green
    
} catch {
    Write-Host ""
    Write-Host "❌ Erreur: $_" -ForegroundColor Red
    pause
    exit 1
}

# Validation
if (-not (Test-Path $ExePath)) {
    Write-Host "❌ L'exe n'a pas été créé" -ForegroundColor Red
    pause
    exit 1
}

$ExeSizeMB = [math]::Round((Get-Item $ExePath).Length / 1MB, 2)

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host "           ✅ SUCCES !" -ForegroundColor Green
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host ""
Write-Host "Fichier: $ExePath" -ForegroundColor White
Write-Host "Taille: $ExeSizeMB MB" -ForegroundColor Cyan
Write-Host ""
Write-Host "⚠️  Note: Votre antivirus peut signaler un faux positif" -ForegroundColor Yellow
Write-Host ""

$Test = Read-Host "Lancer l'exe maintenant ? (O/N)"
if ($Test -match "^[Oo]") {
    Start-Process -FilePath $ExePath
}

Write-Host ""
Write-Host "✨ Terminé !" -ForegroundColor Green
Write-Host ""
pause
