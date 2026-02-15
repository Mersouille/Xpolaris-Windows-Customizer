#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Script maître de personnalisation Windows
.DESCRIPTION
    Menu interactif pour personnaliser, optimiser et créer une image Windowssans bloatware
.NOTES
    Auteur: Personnalisation Windows
    Date: 21 décembre 2025
    Version: 4.3.0
#>

# Configuration console pour ps2exe - CRITIQUE pour l'affichage
try {
    # Forcer la taille de buffer pour ps2exe
    if ($Host.UI.RawUI) {
        $Host.UI.RawUI.WindowTitle = "Xpolaris Windows Customizer v4.3.0"
        $Host.UI.RawUI.BackgroundColor = "Black"
        $Host.UI.RawUI.ForegroundColor = "White"
        
        # Forcer la taille du buffer (évite l'écran noir)
        $bufferSize = $Host.UI.RawUI.BufferSize
        $bufferSize.Width = 120
        $bufferSize.Height = 3000
        $Host.UI.RawUI.BufferSize = $bufferSize
        
        # Forcer la taille de la fenêtre
        $windowSize = $Host.UI.RawUI.WindowSize
        $windowSize.Width = 120
        $windowSize.Height = 40
        $Host.UI.RawUI.WindowSize = $windowSize
    }
    Clear-Host
} catch {
    # Si erreur, continuer quand même
}

# Configuration de l'encodage UTF-8 pour afficher correctement les émojis
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

# DIAGNOSTIC ps2exe - Afficher un message de démarrage
Write-Output "Initialisation de Xpolaris Windows Customizer..."

# Configuration globale - Détection automatique du dossier
$Global:ISOPath = Split-Path -Parent $MyInvocation.MyCommand.Path
if ([string]::IsNullOrEmpty($Global:ISOPath)) {
    $Global:ISOPath = $PSScriptRoot
}
if ([string]::IsNullOrEmpty($Global:ISOPath)) {
    $Global:ISOPath = Get-Location
}
$Global:WorkDir = "$Global:ISOPath\CustomizeWork"
$Global:MountDir = "$Global:WorkDir\Mount"
$Global:InstallWim = "$Global:ISOPath\sources\install.wim"
$Global:BootWim = "$Global:ISOPath\sources\boot.wim"
$Global:CustomISODir = "$Global:WorkDir\CustomISO"
$Global:OutputISO = "$Global:ISOPath\Windows_Custom_Xpolaris.iso"

# Variables pour les applications à installer
$Global:Install7Zip = $false
$Global:InstallNotepadPP = $false
$Global:InstallChrome = $false
$Global:InstallCCleaner = $false
$Global:InstallVLC = $false
$Global:InstallTeamViewer = $false

# Fonction d'affichage couleur
function Write-ColorOutput {
    param([string]$Color, [string]$Message)
    $fc = $host.UI.RawUI.ForegroundColor
    $host.UI.RawUI.ForegroundColor = $Color
    Write-Output $Message
    $host.UI.RawUI.ForegroundColor = $fc
}

# Fonction d'affichage du logo ASCII Xpolaris
function Show-XpolarisLogo {
    Write-Host ""
    Write-Host "        ██╗  ██╗██████╗  ██████╗ ██╗      █████╗ ██████╗ ██╗███████╗" -ForegroundColor Cyan
    Write-Host "        ╚██╗██╔╝██╔══██╗██╔═══██╗██║     ██╔══██╗██╔══██╗██║██╔════╝" -ForegroundColor Cyan
    Write-Host "         ╚███╔╝ ██████╔╝██║   ██║██║     ███████║██████╔╝██║███████╗" -ForegroundColor Cyan
    Write-Host "         ██╔██╗ ██╔═══╝ ██║   ██║██║     ██╔══██║██╔══██╗██║╚════██║" -ForegroundColor Cyan
    Write-Host "        ██╔╝ ██╗██║     ╚██████╔╝███████╗██║  ██║██║  ██║██║███████║" -ForegroundColor Cyan
    Write-Host "        ╚═╝  ╚═╝╚═╝      ╚═════╝ ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝╚══════╝" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "                      ⭐ WINDOWS CUSTOMIZER v4.3.0 ⭐" -ForegroundColor Yellow
    Write-Host "                  Edition Personnalisée Sans Bloatware" -ForegroundColor Gray
    Write-Host ""
}

# Fonction de barre de progression
function Show-ProgressBar {
    param(
        [string]$Activity,
        [int]$PercentComplete,
        [string]$Status = ""
    )
    
    $BarLength = 50
    $FilledLength = [math]::Floor($BarLength * $PercentComplete / 100)
    $EmptyLength = $BarLength - $FilledLength
    
    $Bar = ("[" + ("=" * $FilledLength) + ">" + (" " * $EmptyLength) + "]")
    
    Write-Host -NoNewline "`r$Activity $Bar $PercentComplete% $Status" -ForegroundColor Cyan
}

# Fonction de montage avec progression
function Mount-ImageWithProgress {
    param(
        [string]$ImagePath,
        [int]$Index,
        [string]$MountPath
    )
    
    Write-Host ""
    Show-ProgressBar -Activity "Montage de l'image" -PercentComplete 0 -Status "(Initialisation...)"
    Start-Sleep -Milliseconds 500
    
    # Lancement du montage en arrière-plan
    $Job = Start-Job -ScriptBlock {
        param($img, $idx, $mnt)
        Mount-WindowsImage -ImagePath $img -Index $idx -Path $mnt -ErrorAction Stop
    } -ArgumentList $ImagePath, $Index, $MountPath
    
    # Simulation de progression pendant le montage
    $Progress = 0
    while ($Job.State -eq "Running" -and $Progress -lt 95) {
        Start-Sleep -Seconds 3
        $Progress += 5
        Show-ProgressBar -Activity "Montage de l'image" -PercentComplete $Progress -Status "(Copie des fichiers...)"
    }
    
    # Attendre la fin (peut prendre quelques minutes)
    if ($Job.State -eq "Running") {
        Show-ProgressBar -Activity "Montage de l'image" -PercentComplete 95 -Status "(Finalisation en cours, veuillez patienter...)"
    }
    $Result = Wait-Job $Job | Receive-Job
    Remove-Job $Job
    
    Show-ProgressBar -Activity "Montage de l'image" -PercentComplete 100 -Status "(Termine!)"
    Write-Host ""
    
    return $Result
}

# Fonction de démontage avec progression
function Dismount-ImageWithProgress {
    param(
        [string]$MountPath,
        [switch]$Save,
        [switch]$Discard
    )
    
    Write-Host ""
    Show-ProgressBar -Activity "Demontage de l'image" -PercentComplete 0 -Status "(Initialisation...)"
    Start-Sleep -Milliseconds 500
    
    # Lancement du démontage en arrière-plan
    $Job = Start-Job -ScriptBlock {
        param($mnt, $sv, $dis)
        if ($sv) {
            Dismount-WindowsImage -Path $mnt -Save -ErrorAction Stop
        } elseif ($dis) {
            Dismount-WindowsImage -Path $mnt -Discard -ErrorAction Stop
        }
    } -ArgumentList $MountPath, $Save, $Discard
    
    # Simulation de progression pendant le démontage
    $Progress = 0
    $StatusMessages = @(
        "(Sauvegarde des modifications...)",
        "(Compression WIM...)",
        "(Verification integrite...)",
        "(Finalisation...)"
    )
    $MessageIndex = 0
    
    while ($Job.State -eq "Running" -and $Progress -lt 95) {
        Start-Sleep -Seconds 4
        $Progress += 3
        if ($Progress -gt 95) { $Progress = 95 }
        
        $Status = $StatusMessages[$MessageIndex % $StatusMessages.Count]
        if ($Progress % 25 -eq 0) { $MessageIndex++ }
        
        Show-ProgressBar -Activity "Demontage de l'image" -PercentComplete $Progress -Status $Status
    }
    
    # Attendre la fin (peut prendre quelques minutes)
    if ($Job.State -eq "Running") {
        Show-ProgressBar -Activity "Demontage de l'image" -PercentComplete 95 -Status "(Finalisation en cours, veuillez patienter...)"
    }
    $Result = Wait-Job $Job | Receive-Job
    Remove-Job $Job
    
    Show-ProgressBar -Activity "Demontage de l'image" -PercentComplete 100 -Status "(Termine!)"
    Write-Host ""
    
    return $Result
}

# Fonction de progression pour processus externe
function Start-ProcessWithProgress {
    param(
        [string]$Activity,
        [string]$FilePath,
        [array]$ArgumentList,
        [int]$EstimatedSeconds = 60
    )
    
    Write-Host ""
    Show-ProgressBar -Activity $Activity -PercentComplete 0 -Status "(Demarrage...)"
    Start-Sleep -Milliseconds 500
    
    # Lancement du processus en arrière-plan
    $Job = Start-Job -ScriptBlock {
        param($filePath, $argList)
        
        # Convertir l'array en arguments valides
        $arguments = @()
        foreach ($arg in $argList) {
            if (-not [string]::IsNullOrWhiteSpace($arg)) {
                $arguments += $arg
            }
        }
        
        try {
            $proc = Start-Process -FilePath $filePath -ArgumentList $arguments -Wait -PassThru -NoNewWindow -ErrorAction Stop
            return $proc.ExitCode
        } catch {
            Write-Error $_.Exception.Message
            return 1
        }
    } -ArgumentList $FilePath, $ArgumentList
    
    # Simulation de progression
    $Progress = 0
    $Increment = [math]::Max(1, [math]::Floor(100 / ($EstimatedSeconds / 2)))
    
    while ($Job.State -eq "Running" -and $Progress -lt 95) {
        Start-Sleep -Seconds 2
        $Progress += $Increment
        if ($Progress -gt 95) { $Progress = 95 }
        
        Show-ProgressBar -Activity $Activity -PercentComplete $Progress -Status "(Traitement en cours...)"
    }
    
    # Attendre la fin
    $JobResult = Wait-Job $Job
    $ExitCode = Receive-Job $JobResult
    
    # Afficher les erreurs s'il y en a
    if ($JobResult.State -eq "Failed" -or $JobResult.ChildJobs[0].Error.Count -gt 0) {
        foreach ($err in $JobResult.ChildJobs[0].Error) {
            Write-Host "  Erreur: $err" -ForegroundColor Red
        }
    }
    
    Remove-Job $Job
    
    Show-ProgressBar -Activity $Activity -PercentComplete 100 -Status "(Termine!)"
    Write-Host ""
    
    return $ExitCode
}

# Fonction de menu de sélection des applications
function Show-AppsMenu {
    Clear-Host
    Show-XpolarisLogo
    
    Write-Host "╔══════════════════════════════════════════════════════════════════════════╗" -ForegroundColor DarkCyan
    Write-Host "║              SÉLECTION DES APPLICATIONS À INSTALLER                      ║" -ForegroundColor DarkCyan
    Write-Host "╚══════════════════════════════════════════════════════════════════════════╝" -ForegroundColor DarkCyan
    Write-Host ""
    Write-Host "Ces applications seront installées automatiquement après l'installation" -ForegroundColor Gray
    Write-Host "de Windows via le gestionnaire winget." -ForegroundColor Gray
    Write-Host ""
    
    # Afficher l'état actuel
    Write-Host "État actuel de la sélection :" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  [1] 7-Zip (Compression)           " -NoNewline
    if ($Global:Install7Zip) { Write-Host "[✓ Sélectionné]" -ForegroundColor Green } else { Write-Host "[ Non sélectionné]" -ForegroundColor Gray }
    
    Write-Host "  [2] Notepad++ (Éditeur de texte)  " -NoNewline
    if ($Global:InstallNotepadPP) { Write-Host "[✓ Sélectionné]" -ForegroundColor Green } else { Write-Host "[ Non sélectionné]" -ForegroundColor Gray }
    
    Write-Host "  [3] Google Chrome (Navigateur)    " -NoNewline
    if ($Global:InstallChrome) { Write-Host "[✓ Sélectionné]" -ForegroundColor Green } else { Write-Host "[ Non sélectionné]" -ForegroundColor Gray }
    
    Write-Host "  [4] CCleaner (Nettoyage système)  " -NoNewline
    if ($Global:InstallCCleaner) { Write-Host "[✓ Sélectionné]" -ForegroundColor Green } else { Write-Host "[ Non sélectionné]" -ForegroundColor Gray }
    
    Write-Host "  [5] VLC Media Player (Lecteur)    " -NoNewline
    if ($Global:InstallVLC) { Write-Host "[✓ Sélectionné]" -ForegroundColor Green } else { Write-Host "[ Non sélectionné]" -ForegroundColor Gray }
    
    Write-Host "  [6] TeamViewer (Bureau à distance) " -NoNewline
    if ($Global:InstallTeamViewer) { Write-Host "[✓ Sélectionné]" -ForegroundColor Green } else { Write-Host "[ Non sélectionné]" -ForegroundColor Gray }
    
    Write-Host ""
    Write-Host "  [A] Tout sélectionner" -ForegroundColor Yellow
    Write-Host "  [D] Tout désélectionner" -ForegroundColor Yellow
    Write-Host "  [R] Sélection recommandée (7-Zip, Notepad++, Chrome, VLC)" -ForegroundColor Yellow
    Write-Host "  [0] Terminer et continuer" -ForegroundColor Green
    Write-Host ""
    Write-Host "Votre choix: " -NoNewline -ForegroundColor Cyan
    
    $Choice = Read-Host
    
    switch ($Choice) {
        "1" { $Global:Install7Zip = -not $Global:Install7Zip; Show-AppsMenu }
        "2" { $Global:InstallNotepadPP = -not $Global:InstallNotepadPP; Show-AppsMenu }
        "3" { $Global:InstallChrome = -not $Global:InstallChrome; Show-AppsMenu }
        "4" { $Global:InstallCCleaner = -not $Global:InstallCCleaner; Show-AppsMenu }
        "5" { $Global:InstallVLC = -not $Global:InstallVLC; Show-AppsMenu }
        "6" { $Global:InstallTeamViewer = -not $Global:InstallTeamViewer; Show-AppsMenu }
        "A" { 
            $Global:Install7Zip = $true
            $Global:InstallNotepadPP = $true
            $Global:InstallChrome = $true
            $Global:InstallCCleaner = $true
            $Global:InstallVLC = $true
            $Global:InstallTeamViewer = $true
            Show-AppsMenu
        }
        "D" {
            $Global:Install7Zip = $false
            $Global:InstallNotepadPP = $false
            $Global:InstallChrome = $false
            $Global:InstallCCleaner = $false
            $Global:InstallVLC = $false
            $Global:InstallTeamViewer = $false
            Show-AppsMenu
        }
        "R" {
            $Global:Install7Zip = $true
            $Global:InstallNotepadPP = $true
            $Global:InstallChrome = $true
            $Global:InstallCCleaner = $false
            $Global:InstallVLC = $true
            $Global:InstallTeamViewer = $false
            Show-AppsMenu
        }
        "0" { return }
        default { Show-AppsMenu }
    }
}

# Fonction de génération du fichier Apps-Manager.ps1
function New-AppsManagerScript {
    param([string]$OutputPath)
    
    # Compter les applications sélectionnées
    $selectedApps = @()
    if ($Global:Install7Zip) { $selectedApps += @{Name="7-Zip"; Id="7zip.7zip"; Icon="📦"} }
    if ($Global:InstallNotepadPP) { $selectedApps += @{Name="Notepad++"; Id="Notepad++.Notepad++"; Icon="📝"} }
    if ($Global:InstallChrome) { $selectedApps += @{Name="Google Chrome"; Id="Google.Chrome"; Icon="🌐"} }
    if ($Global:InstallCCleaner) { $selectedApps += @{Name="CCleaner"; Id="Piriform.CCleaner"; Icon="🧹"} }
    if ($Global:InstallVLC) { $selectedApps += @{Name="VLC Media Player"; Id="VideoLAN.VLC"; Icon="🎬"} }
    if ($Global:InstallTeamViewer) { $selectedApps += @{Name="TeamViewer"; Id="TeamViewer.TeamViewer"; Icon="🖥️"} }
    
    if ($selectedApps.Count -eq 0) {
        Write-Host "    ! Aucune application sélectionnée" -ForegroundColor Yellow
        return $false
    }
    
    # Construire le script ligne par ligne
    $scriptLines = @()
    $scriptLines += "#Requires -RunAsAdministrator"
    $scriptLines += "<#"
    $scriptLines += ".SYNOPSIS"
    $scriptLines += "    Xpolaris Apps Manager - Gestionnaire d'applications"
    $scriptLines += ".DESCRIPTION"
    $scriptLines += "    Installation automatique d'applications via winget avec fallback"
    $scriptLines += "    Généré automatiquement par Xpolaris Windows Customizer"
    $scriptLines += "#>"
    $scriptLines += ""
    $scriptLines += "`$ErrorActionPreference = 'Continue'"
    $scriptLines += "`$LogFile = 'C:\Xpolaris-Apps-Manager.log'"
    $scriptLines += ""
    $scriptLines += "function Write-Log {"
    $scriptLines += "    param([string]`$Message)"
    $scriptLines += "    `$Timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'"
    $scriptLines += "    `$LogMessage = `"[`$Timestamp] `$Message`""
    $scriptLines += "    Add-Content -Path `$LogFile -Value `$LogMessage"
    $scriptLines += "    Write-Host `$Message"
    $scriptLines += "}"
    $scriptLines += ""
    $scriptLines += "Write-Log '═══════════════════════════════════════════════════════════════'"
    $scriptLines += "Write-Log 'Xpolaris Apps Manager - Démarrage'"
    $scriptLines += "Write-Log '═══════════════════════════════════════════════════════════════'"
    $scriptLines += ""
    $scriptLines += "try {"
    $scriptLines += "    if (`$PSVersionTable.PSVersion.Major -lt 5) {"
    $scriptLines += "        Write-Log '[ERREUR] PowerShell 5.0+ requis'"
    $scriptLines += "        exit 1"
    $scriptLines += "    }"
    $scriptLines += ""
    $scriptLines += "    # Liste des applications à installer via winget"
    $scriptLines += "    `$WingetApps = @("
    
    foreach ($app in $selectedApps) {
        $scriptLines += "        @{Name='$($app.Name)'; Id='$($app.Id)'; Icon='$($app.Icon)'}"
    }
    
    $scriptLines += "    )"
    $scriptLines += ""
    $scriptLines += "    `$SuccessCount = 0"
    $scriptLines += "    `$FailedApps = @()"
    $scriptLines += ""
    $scriptLines += "    # Installation via winget"
    $scriptLines += "    if (`$WingetApps.Count -gt 0) {"
    $scriptLines += "        Write-Log `"[INFO] Installation via winget - `$(`$WingetApps.Count) apps`""
    $scriptLines += "        foreach (`$AppItem in `$WingetApps) {"
    $scriptLines += "            Write-Log `"[`$(`$AppItem.Icon)] `$(`$AppItem.Name)...`""
    $scriptLines += "            try {"
    $scriptLines += "                `$Output = winget install --id `$AppItem.Id --source winget --silent --accept-package-agreements --accept-source-agreements 2>&1 | Out-String"
    $scriptLines += "                if (`$LASTEXITCODE -eq 0) {"
    $scriptLines += "                    Write-Log `"    [OK] `$(`$AppItem.Name) installé`""
    $scriptLines += "                    `$SuccessCount++"
    $scriptLines += "                } else {"
    $scriptLines += "                    Write-Log `"    [ERREUR] Code: `$LASTEXITCODE`""
    $scriptLines += "                    Write-Log `"    Output: `$Output`""
    $scriptLines += "                    `$FailedApps += `$AppItem.Name"
    $scriptLines += "                }"
    $scriptLines += "            } catch {"
    $scriptLines += "                Write-Log `"    [ERREUR] Exception: `$_`""
    $scriptLines += "                `$FailedApps += `$AppItem.Name"
    $scriptLines += "            }"
    $scriptLines += "        }"
    $scriptLines += "    }"
    $scriptLines += ""
    $scriptLines += "    Write-Log '═══════════════════════════════════════════════════════════════'"
    $scriptLines += "    Write-Log `"[RÉSUMÉ] `$SuccessCount/`$(`$WingetApps.Count) succès`""
    $scriptLines += "    if (`$FailedApps.Count -gt 0) {"
    $scriptLines += "        Write-Log `"[ÉCHECS] `$(`$FailedApps -join ', ')`""
    $scriptLines += "    }"
    $scriptLines += "    Write-Log '═══════════════════════════════════════════════════════════════'"
    $scriptLines += ""
    $scriptLines += "} catch {"
    $scriptLines += "    Write-Log `"[ERREUR CRITIQUE] `$_`""
    $scriptLines += "    exit 1"
    $scriptLines += "}"
    
    # Écrire le fichier
    $scriptLines -join "`r`n" | Out-File -FilePath $OutputPath -Encoding UTF8 -Force
    
    Write-Host "    ✓ Apps-Manager.ps1 généré ($($selectedApps.Count) apps)" -ForegroundColor Green
    return $true
}

# Fonction de titre
# Fonction de titre avec logo ASCII
function Show-Title {
    Clear-Host
    Show-XpolarisLogo
    
    Write-Host "╔══════════════════════════════════════════════════════════════════════════╗" -ForegroundColor DarkCyan
    Write-Host "║                         MENU PRINCIPAL                                   ║" -ForegroundColor DarkCyan
    Write-Host "╚══════════════════════════════════════════════════════════════════════════╝" -ForegroundColor DarkCyan
}

# Fonction d'analyse de l'état (optimisée)
function Get-SystemState {
    param([switch]$Quick)
    
    $State = @{
        InstallWimExists = Test-Path $Global:InstallWim
        InstallWimSize = 0
        EditionCount = 0
        IsCustomized = Test-Path "$Global:WorkDir\install_customized.txt"
        CustomDate = ""
        HasBackup = Test-Path "$Global:WorkDir\install_backup.wim"
        WorkDirSize = 0
        ISOComplete = $false
    }
    
    # Vérification de la structure ISO complète (boot et efi requis)
    $State.ISOComplete = (Test-Path "$Global:ISOPath\boot") -and (Test-Path "$Global:ISOPath\efi")
    
    if ($State.InstallWimExists) {
        $State.InstallWimSize = [math]::Round((Get-Item $Global:InstallWim).Length / 1GB, 2)
        
        # Mode rapide : skip Get-WindowsImage (lent)
        if (-not $Quick) {
            try {
                $ImageInfo = Get-WindowsImage -ImagePath $Global:InstallWim -ErrorAction SilentlyContinue
                $State.EditionCount = $ImageInfo.Count
                # Sauvegarder le compte en cache pour le mode rapide
                Set-Content "$Global:WorkDir\edition_count.txt" -Value $State.EditionCount -Force -ErrorAction SilentlyContinue
            } catch {
                $State.EditionCount = 0
            }
        } else {
            # Vérifier si le cache existe et si install.wim n'a pas changé
            $CacheFile = "$Global:WorkDir\edition_count.txt"
            $CacheValid = $false
            
            if (Test-Path $CacheFile) {
                $CacheDate = (Get-Item $CacheFile).LastWriteTime
                $WimDate = (Get-Item $Global:InstallWim).LastWriteTime
                
                # Cache valide seulement si plus récent que install.wim
                if ($CacheDate -gt $WimDate) {
                    $CacheValid = $true
                    $State.EditionCount = [int](Get-Content $CacheFile -ErrorAction SilentlyContinue)
                }
            }
            
            # Si cache invalide, recompter et sauvegarder
            if (-not $CacheValid) {
                try {
                    $ImageInfo = Get-WindowsImage -ImagePath $Global:InstallWim -ErrorAction SilentlyContinue
                    $State.EditionCount = $ImageInfo.Count
                    Set-Content $CacheFile -Value $State.EditionCount -Force -ErrorAction SilentlyContinue
                } catch {
                    $State.EditionCount = 1
                }
            }
        }
    }
    
    if ($State.IsCustomized) {
        $State.CustomDate = Get-Content "$Global:WorkDir\install_customized.txt" -ErrorAction SilentlyContinue
    }
    
    if (Test-Path $Global:WorkDir) {
        # Optimisé : compte uniquement les fichiers sans récursion profonde
        $State.WorkDirSize = [math]::Round((Get-ChildItem -Path $Global:WorkDir -File -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum / 1GB, 2)
    }
    
    return $State
}

# Fonction d'affichage de l'état (mode rapide avec style amélioré)
function Show-Status {
    $State = Get-SystemState -Quick
    
    Write-Host ""
    Write-Host "┌────────────────────────────────────────────────────────────────────────┐" -ForegroundColor DarkGray
    Write-Host "│ " -NoNewline -ForegroundColor DarkGray
    Write-Host "📊 ÉTAT DU SYSTÈME" -NoNewline -ForegroundColor Cyan
    Write-Host "                                                     │" -ForegroundColor DarkGray
    Write-Host "└────────────────────────────────────────────────────────────────────────┘" -ForegroundColor DarkGray
    Write-Host ""
    
    # Install.wim
    Write-Host "  💿 Image install.wim" -ForegroundColor White
    if ($State.InstallWimExists) {
        Write-Host "     → Taille : " -NoNewline -ForegroundColor Gray
        Write-Host "$($State.InstallWimSize) GB" -ForegroundColor Green -NoNewline
        Write-Host " | Éditions : " -NoNewline -ForegroundColor Gray
        Write-Host "$($State.EditionCount)" -ForegroundColor Yellow
    } else {
        Write-Host "     → " -NoNewline -ForegroundColor Gray
        Write-Host "❌ Non trouvée" -ForegroundColor Red
    }
    Write-Host ""
    
    # Personnalisée
    Write-Host "  ⚙️  Personnalisation" -ForegroundColor White
    if ($State.IsCustomized) {
        Write-Host "     → " -NoNewline -ForegroundColor Gray
        Write-Host "✅ Oui" -ForegroundColor Green -NoNewline
        Write-Host " (le $($State.CustomDate))" -ForegroundColor DarkGray
    } else {
        Write-Host "     → " -NoNewline -ForegroundColor Gray
        Write-Host "⏳ Non effectuée" -ForegroundColor Yellow
    }
    Write-Host ""
    
    # Sauvegarde
    Write-Host "  💾 Sauvegarde" -ForegroundColor White
    if ($State.HasBackup) {
        Write-Host "     → " -NoNewline -ForegroundColor Gray
        Write-Host "✅ Disponible" -ForegroundColor Green
    } else {
        Write-Host "     → " -NoNewline -ForegroundColor Gray
        Write-Host "⚠️  Aucune sauvegarde" -ForegroundColor Yellow
    }
    Write-Host ""
    
    # Espace temporaire
    Write-Host "  🗂️  Espace temporaire" -ForegroundColor White
    if ($State.WorkDirSize -gt 0) {
        Write-Host "     → " -NoNewline -ForegroundColor Gray
        Write-Host "$($State.WorkDirSize) GB" -ForegroundColor Yellow -NoNewline
        Write-Host " (nettoyable)" -ForegroundColor DarkGray
    } else {
        Write-Host "     → " -NoNewline -ForegroundColor Gray
        Write-Host "0 GB" -ForegroundColor Green -NoNewline
        Write-Host " (propre)" -ForegroundColor DarkGray
    }
    
    # Avertissement structure ISO incomplète
    if (-not $State.ISOComplete) {
        Write-Host ""
        Write-Host "  ⚠️  " -NoNewline -ForegroundColor Yellow
        Write-Host "STRUCTURE ISO INCOMPLÈTE" -ForegroundColor Red
        Write-Host "     → Dossiers boot/ ou efi/ manquants" -ForegroundColor DarkGray
        Write-Host "     → Montez votre ISO Windows et copiez TOUT son contenu" -ForegroundColor Gray
    }
    Write-Host ""
}

# Menu principal
# Menu principal avec style amélioré
function Show-Menu {
    Show-Title
    Show-Status
    Write-Host ""
    
    Write-Host "┌────────────────────────────────────────────────────────────────────────┐" -ForegroundColor DarkGray
    Write-Host "│ " -NoNewline -ForegroundColor DarkGray
    Write-Host "🎯 ACTIONS DISPONIBLES" -NoNewline -ForegroundColor Cyan
    Write-Host "                                                 │" -ForegroundColor DarkGray
    Write-Host "└────────────────────────────────────────────────────────────────────────┘" -ForegroundColor DarkGray
    Write-Host ""
    
    Write-Host "  ╔═══════════════════════════════════════════════════════════════════╗" -ForegroundColor DarkCyan
    Write-Host "  ║ " -NoNewline -ForegroundColor DarkCyan
    Write-Host "[1]" -NoNewline -ForegroundColor Yellow
    Write-Host " 🎯 Processus Complet" -NoNewline -ForegroundColor White
    Write-Host " (Recommandé)" -NoNewline -ForegroundColor Green
    Write-Host "                             ║" -ForegroundColor DarkCyan
    Write-Host "  ║                                                                   ║" -ForegroundColor DarkCyan
    Write-Host "  ║     " -NoNewline -ForegroundColor DarkCyan
    Write-Host "→ Extraction de l'édition Windows choisie" -NoNewline -ForegroundColor Gray
    Write-Host "                     ║" -ForegroundColor DarkCyan
    Write-Host "  ║     " -NoNewline -ForegroundColor DarkCyan
    Write-Host "→ Suppression des composants inutiles" -NoNewline -ForegroundColor Gray
    Write-Host "                         ║" -ForegroundColor DarkCyan
    Write-Host "  ║     " -NoNewline -ForegroundColor DarkCyan
    Write-Host "→ Personnalisation et optimisations" -NoNewline -ForegroundColor Gray
    Write-Host "                           ║" -ForegroundColor DarkCyan
    Write-Host "  ║     " -NoNewline -ForegroundColor DarkCyan
    Write-Host "→ Création de l'ISO bootable" -NoNewline -ForegroundColor Gray
    Write-Host "                                  ║" -ForegroundColor DarkCyan
    Write-Host "  ║     " -NoNewline -ForegroundColor DarkCyan
    Write-Host "→ Nettoyage automatique" -NoNewline -ForegroundColor Gray
    Write-Host "                                       ║" -ForegroundColor DarkCyan
    Write-Host "  ╚═══════════════════════════════════════════════════════════════════╝" -ForegroundColor DarkCyan
    Write-Host ""
    
    Write-Host "  [2] ✂️  Extraire une seule édition Windows" -ForegroundColor White
    Write-Host "      → Réduit la taille de ~60%" -ForegroundColor Gray
    Write-Host ""
    
    Write-Host "  [3] 🔧 Personnaliser et optimiser l'image" -ForegroundColor White
    Write-Host "      → Bloatware + Optimisations + Xpolaris" -ForegroundColor Gray
    Write-Host ""
    
    Write-Host "  [4] 📦 Supprimer des composants Windows " -NoNewline -ForegroundColor White
    Write-Host "(Avancé)" -ForegroundColor Red
    Write-Host "      → Réduire encore plus la taille de l'image" -ForegroundColor Gray
    Write-Host ""
    
    Write-Host "  [5] 🗑️  Nettoyer les anciennes versions" -ForegroundColor White
    Write-Host "      → Libérer de l'espace disque temporaire" -ForegroundColor Gray
    Write-Host ""
    
    Write-Host "  [6] 💿 Créer support bootable " -NoNewline -ForegroundColor White
    Write-Host "(Rufus/oscdimg)" -ForegroundColor Cyan
    Write-Host "      → Clé USB bootable ou fichier .ISO" -ForegroundColor Gray
    Write-Host ""
    
    Write-Host "  [7] 🔄 Restaurer l'image originale" -ForegroundColor White
    Write-Host "      → Depuis la sauvegarde automatique" -ForegroundColor Gray
    Write-Host ""
    
    Write-Host "  [8] 📊 Afficher les informations détaillées" -ForegroundColor White
    Write-Host "      → Éditions, taille, état complet" -ForegroundColor Gray
    Write-Host ""
    
    Write-Host "  ╔═══════════════════════════════════════════════════════════════════╗" -ForegroundColor Red
    Write-Host "  ║ " -NoNewline -ForegroundColor Red
    Write-Host "[0]" -NoNewline -ForegroundColor Yellow
    Write-Host " ❌ Quitter" -NoNewline -ForegroundColor White
    Write-Host "                                                    ║" -ForegroundColor Red
    Write-Host "  ╚═══════════════════════════════════════════════════════════════════╝" -ForegroundColor Red
    Write-Host ""
    Write-Host "┌────────────────────────────────────────────────────────────────────────┐" -ForegroundColor DarkGray
    Write-Host "│ " -NoNewline -ForegroundColor DarkGray
    Write-Host "Votre choix" -NoNewline -ForegroundColor Cyan
    Write-Host " : " -NoNewline -ForegroundColor DarkGray
}

# Fonction 1: Processus complet
function Start-CompleteProcess {
    Show-Title
    Write-ColorOutput Green "🎯 PROCESSUS COMPLET DE PERSONNALISATION"
    Write-Host ""
    Write-Host "Ce processus va:"
    Write-Host "  1. Extraire l'édition Windows choisie uniquement"
    Write-Host "  2. Supprimer les composants Windows inutiles (IE, Media Player, etc.)"
    Write-Host "  3. Personnaliser et optimiser l'image"
    Write-Host "  4. Créer l'ISO finale bootable"
    Write-Host "  5. Nettoyer les fichiers temporaires (sans supprimer l'ISO)"
    Write-Host ""
    Write-Host "⚠️  Durée estimée: 20-40 minutes (selon la puissance du PC)" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Voulez-vous lancer le processus complet ? " -NoNewline -ForegroundColor Cyan
    Write-Host "(O/N)" -ForegroundColor Yellow -NoNewline
    Write-Host ": " -NoNewline
    $Confirm = Read-Host
    
    if ($Confirm -ne "O" -and $Confirm -ne "o") {
        Write-Host ""
        Write-ColorOutput Yellow "✓ Processus annulé - Retour au menu principal"
        Start-Sleep -Seconds 2
        return
    }
    
    Write-Host ""
    Write-ColorOutput Green "✓ Mode automatique activé - Processus complet sans interruption"
    Write-Host ""
    
    # Étape 1: Extraction
    Write-Host ""
    Write-Host ("═"*60) -ForegroundColor Cyan
    Write-ColorOutput Cyan "ÉTAPE 1/5: Extraction de l'édition Windows choisie"
    Write-Host ("═"*60) -ForegroundColor Cyan
    Start-ExtractSingleEdition -AutoMode
    
    # Étape 2: Suppression composants
    Write-Host ""
    Write-Host ("═"*60) -ForegroundColor Cyan
    Write-ColorOutput Cyan "ÉTAPE 2/5: Suppression composants Windows inutiles"
    Write-Host ("═"*60) -ForegroundColor Cyan
    Start-RemoveComponents -AutoMode
    
    # Étape 3: Personnalisation
    Write-Host ""
    Write-Host ("═"*60) -ForegroundColor Cyan
    Write-ColorOutput Cyan "ÉTAPE 3/5: Personnalisation et optimisation"
    Write-Host ("═"*60) -ForegroundColor Cyan
    Start-CustomizeImage -AutoMode
    
    # Étape 4: Création ISO
    Write-Host ""
    Write-Host ("═"*60) -ForegroundColor Cyan
    Write-ColorOutput Cyan "ÉTAPE 4/5: Création de l'ISO"
    Write-Host ("═"*60) -ForegroundColor Cyan
    Start-CreateISO -AutoMode
    
    # Étape 5: Nettoyage
    Write-Host ""
    Write-Host ("═"*60) -ForegroundColor Cyan
    Write-ColorOutput Cyan "ÉTAPE 5/5: Nettoyage"
    Write-Host ("═"*60) -ForegroundColor Cyan
    Start-Cleanup -Silent -KeepISO
    
    Write-Host ""
    Write-ColorOutput Green "╔═══════════════════════════════════════════════════════════╗"
    Write-ColorOutput Green "║         PROCESSUS COMPLET TERMINÉ AVEC SUCCÈS !           ║"
    Write-ColorOutput Green "╚═══════════════════════════════════════════════════════════╝"
    Write-Host ""
    pause
}

# Fonction 2: Extraire édition unique
function Start-ExtractSingleEdition {
    param([switch]$AutoMode)
    
    $State = Get-SystemState
    
    if ($State.EditionCount -eq 1) {
        Write-ColorOutput Yellow "⚠ L'image contient déjà une seule édition."
        if (-not $AutoMode) { pause }
        return
    }
    
    # En mode auto, sélectionner automatiquement la première édition (Pro généralement)
    if ($AutoMode) {
        $ImageInfo = Get-WindowsImage -ImagePath $Global:InstallWim
        $EditionIndex = 1  # Par défaut: première édition
        
        # Chercher "Pro" si disponible
        $ProEdition = $ImageInfo | Where-Object { $_.ImageName -like "*Pro*" -and $_.ImageName -notlike "*Education*" }
        if ($ProEdition) {
            $EditionIndex = $ProEdition[0].ImageIndex
        }
        
        $SelectedEdition = $ImageInfo | Where-Object { $_.ImageIndex -eq $EditionIndex }
        Write-ColorOutput Green "✓ Mode auto: Édition sélectionnée: $($SelectedEdition.ImageName)"
    } else {
        # Afficher les éditions disponibles
        Write-ColorOutput Cyan "`nÉditions Windows disponibles:"
        Write-Host ""
        
        $ImageInfo = Get-WindowsImage -ImagePath $Global:InstallWim
        foreach ($Image in $ImageInfo) {
            Write-Host "  [$($Image.ImageIndex)] " -NoNewline -ForegroundColor Yellow
            Write-Host "$($Image.ImageName)" -ForegroundColor White
            Write-Host "      Taille: $([math]::Round($Image.ImageSize / 1GB, 2)) GB" -ForegroundColor Gray
        }
        
        Write-Host ""
        Write-Host "  [0] " -NoNewline -ForegroundColor Magenta
        Write-Host "Retour au menu principal" -ForegroundColor White
        Write-Host ""
        Write-Host "Quelle édition souhaitez-vous extraire ? " -NoNewline -ForegroundColor Cyan
        $EditionInput = Read-Host
        
        # Option retour
        if ($EditionInput -eq "0") {
            return
        }
        
        # Conversion et validation de l'index
        try {
            $EditionIndex = [int]$EditionInput
        } catch {
            Write-ColorOutput Red "✗ Veuillez entrer un nombre valide"
            pause
            return
        }
        
        if ($EditionIndex -lt 1 -or $EditionIndex -gt $ImageInfo.Count) {
            Write-ColorOutput Red "✗ Index invalide (choisissez entre 1 et $($ImageInfo.Count))"
            pause
            return
        }
        
        $SelectedEdition = $ImageInfo | Where-Object { $_.ImageIndex -eq $EditionIndex }
        Write-Host ""
        Write-ColorOutput Green "✓ Édition sélectionnée: $($SelectedEdition.ImageName)"
        Write-Host ""
    }
    
    $SingleEditionWim = "$Global:WorkDir\install_single.wim"
    
    # Création du répertoire
    if (-not (Test-Path $Global:WorkDir)) {
        New-Item -ItemType Directory -Path $Global:WorkDir -Force | Out-Null
    }
    
    # Sauvegarde
    if (-not (Test-Path "$Global:WorkDir\install_multiéditions.wim")) {
        Write-Host "  Sauvegarde multi-éditions..." -NoNewline
        Copy-Item $Global:InstallWim "$Global:WorkDir\install_multiéditions.wim" -Force
        Write-Host " ✓" -ForegroundColor Green
    }
    
    # Extraction
    Write-Host "  Extraction en cours (10-15 min)..." -NoNewline
    if (Test-Path $SingleEditionWim) {
        Remove-Item $SingleEditionWim -Force
    }
    
    dism /Export-Image /SourceImageFile:"$Global:InstallWim" /SourceIndex:$EditionIndex /DestinationImageFile:"$SingleEditionWim" /Compress:max /CheckIntegrity 2>&1 | Out-Null
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host " ✓" -ForegroundColor Green
        
        # Remplacement
        Copy-Item $SingleEditionWim $Global:InstallWim -Force
        
        # Cache du nombre d'éditions pour performances
        "1" | Out-File "$Global:WorkDir\edition_count.txt" -Force
        
        Write-ColorOutput Green "`n✓ Extraction terminée - Image réduite à 1 édition"
    } else {
        Write-Host " ✗" -ForegroundColor Red
        Write-ColorOutput Red "Erreur lors de l'extraction"
    }
}

# Fonction 3: Personnaliser l'image
function Start-CustomizeImage {
    param([switch]$AutoMode)
    
    if (-not $AutoMode) {
        Show-Title
        Write-ColorOutput Cyan "🔧 PERSONNALISATION ET OPTIMISATION DE L'IMAGE"
        Write-Host ""
        Write-Host "Ce processus va:" -ForegroundColor White
        Write-Host "  • Monter l'image Windows (install.wim)"
        Write-Host "  • Supprimer les applications préinstallées (bloatware)"
        Write-Host "  • Ajouter les scripts Xpolaris (fond d'écran, apps, etc.)"
        Write-Host "  • Copier autounattend.xml pour installation automatique"
        Write-Host "  • Démonter et sauvegarder les modifications"
        Write-Host ""
        Write-Host "⏱️  Durée estimée: 10-15 minutes" -ForegroundColor Yellow
        Write-Host ""
        
        # Menu de sélection des applications
        Write-Host "Voulez-vous sélectionner des applications à installer automatiquement ? " -NoNewline -ForegroundColor Cyan
        Write-Host "(O/N)" -ForegroundColor Yellow -NoNewline
        Write-Host ": " -NoNewline
        $AppsChoice = Read-Host
        
        if ($AppsChoice -eq "O" -or $AppsChoice -eq "o") {
            Show-AppsMenu
        }
        
        Write-Host ""
        Write-Host "Voulez-vous lancer la personnalisation ? " -NoNewline -ForegroundColor Cyan
        Write-Host "(O/N)" -ForegroundColor Yellow -NoNewline
        Write-Host ": " -NoNewline
        $Confirm = Read-Host
        
        if ($Confirm -ne "O" -and $Confirm -ne "o") {
            Write-Host ""
            Write-ColorOutput Yellow "✓ Personnalisation annulée - Retour au menu principal"
            Start-Sleep -Seconds 2
            return
        }
        
        Write-Host ""
    }
    
    # Vérification préalable de la structure ISO source
    if (-not (Test-Path "$Global:ISOPath\boot") -or -not (Test-Path "$Global:ISOPath\efi")) {
        Write-ColorOutput Red "✗ STRUCTURE ISO SOURCE INCOMPLÈTE"
        Write-Host ""
        Write-ColorOutput Yellow "  Le dossier source ne contient pas boot\ et/ou efi\"
        Write-Host ""
        Write-ColorOutput Cyan "  SOLUTION :"
        Write-Host "  1. Montez votre ISO Windows original (clic droit → Monter)" -ForegroundColor White
        Write-Host "  2. Copiez TOUT le contenu (boot, efi, sources, etc.)" -ForegroundColor White
        Write-Host "  3. Collez dans : $Global:ISOPath" -ForegroundColor White
        Write-Host ""
        if (-not $AutoMode) { pause }
        return
    }
    
    # Création de la structure
    Write-Host "  Préparation..." -NoNewline
    if (Test-Path $Global:WorkDir) {
        Remove-Item "$Global:WorkDir\Mount" -Recurse -Force -ErrorAction SilentlyContinue
        Remove-Item "$Global:WorkDir\CustomISO" -Recurse -Force -ErrorAction SilentlyContinue
    }
    New-Item -ItemType Directory -Path $Global:WorkDir -Force | Out-Null
    New-Item -ItemType Directory -Path $Global:MountDir -Force | Out-Null
    New-Item -ItemType Directory -Path $Global:CustomISODir -Force | Out-Null
    Write-Host " ✓" -ForegroundColor Green
    
    # Copie des fichiers ISO
    Write-Host "  Copie des fichiers ISO..." -NoNewline
    try {
        $ItemsToCopy = Get-ChildItem -Path $Global:ISOPath -Exclude "CustomizeWork","*.ps1","*.md"
        foreach ($Item in $ItemsToCopy) {
            Copy-Item -Path $Item.FullName -Destination $Global:CustomISODir -Recurse -Force -ErrorAction Stop
        }
        Write-Host " ✓" -ForegroundColor Green
    } catch {
        Write-Host " ✗" -ForegroundColor Red
        Write-ColorOutput Red "Erreur lors de la copie des fichiers ISO : $_"
        if (-not $AutoMode) { pause }
        return
    }
    
    # Vérification des fichiers de boot critiques
    $BootFile1 = "$Global:CustomISODir\boot\etfsboot.com"
    $BootFile2 = "$Global:CustomISODir\efi\microsoft\boot\efisys.bin"
    if (-not (Test-Path $BootFile1) -or -not (Test-Path $BootFile2)) {
        Write-ColorOutput Red "✗ Fichiers de boot manquants après copie"
        Write-ColorOutput Yellow "  Assurez-vous que votre ISO source contient boot\ et efi\"
        if (-not $AutoMode) { pause }
        return
    }
    
    # Sauvegarde
    if (-not (Test-Path "$Global:WorkDir\install_backup.wim")) {
        Write-Host "  Sauvegarde de l'image..." -NoNewline
        Copy-Item $Global:InstallWim "$Global:WorkDir\install_backup.wim" -Force
        Write-Host " ✓" -ForegroundColor Green
    }
    
    # Montage avec barre de progression
    Write-Host ""
    $ImageInfo = Get-WindowsImage -ImagePath $Global:InstallWim
    $ImageIndex = if ($ImageInfo.Count -eq 1) { 1 } else { 6 }
    
    try {
        Mount-ImageWithProgress -ImagePath $Global:InstallWim -Index $ImageIndex -MountPath $Global:MountDir
        Write-Host "✓ Image montée avec succès" -ForegroundColor Green
    } catch {
        Write-Host "✗ Erreur lors du montage" -ForegroundColor Red
        Write-ColorOutput Red "Erreur: $_"
        pause
        return
    }
    
    # Optimisations registre
    Write-Host "  Application des optimisations..." -NoNewline
    
    $RegPath = "$Global:MountDir\Windows\System32\config\SOFTWARE"
    $RegPath2 = "$Global:MountDir\Users\Default\NTUSER.DAT"
    
    reg load "HKLM\WIM_SOFTWARE" $RegPath 2>&1 | Out-Null
    reg load "HKLM\WIM_NTUSER" $RegPath2 2>&1 | Out-Null
    
    # Télémétrie
    reg add "HKLM\WIM_SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v AllowTelemetry /t REG_DWORD /d 0 /f 2>&1 | Out-Null
    
    # Cortana
    reg add "HKLM\WIM_SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v AllowCortana /t REG_DWORD /d 0 /f 2>&1 | Out-Null
    
    # Bloquer installation automatique apps
    reg add "HKLM\WIM_NTUSER\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v SubscribedContent-338388Enabled /t REG_DWORD /d 0 /f 2>&1 | Out-Null
    reg add "HKLM\WIM_NTUSER\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v SilentInstalledAppsEnabled /t REG_DWORD /d 0 /f 2>&1 | Out-Null
    reg add "HKLM\WIM_NTUSER\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v ContentDeliveryAllowed /t REG_DWORD /d 0 /f 2>&1 | Out-Null
    reg add "HKLM\WIM_NTUSER\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v OemPreInstalledAppsEnabled /t REG_DWORD /d 0 /f 2>&1 | Out-Null
    reg add "HKLM\WIM_NTUSER\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v PreInstalledAppsEnabled /t REG_DWORD /d 0 /f 2>&1 | Out-Null
    reg add "HKLM\WIM_NTUSER\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v PreInstalledAppsEverEnabled /t REG_DWORD /d 0 /f 2>&1 | Out-Null
    reg add "HKLM\WIM_NTUSER\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v SystemPaneSuggestionsEnabled /t REG_DWORD /d 0 /f 2>&1 | Out-Null
    reg add "HKLM\WIM_NTUSER\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v SubscribedContent-310093Enabled /t REG_DWORD /d 0 /f 2>&1 | Out-Null
    reg add "HKLM\WIM_NTUSER\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v SubscribedContent-338389Enabled /t REG_DWORD /d 0 /f 2>&1 | Out-Null
    reg add "HKLM\WIM_NTUSER\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v SubscribedContent-353694Enabled /t REG_DWORD /d 0 /f 2>&1 | Out-Null
    reg add "HKLM\WIM_NTUSER\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v SubscribedContent-353696Enabled /t REG_DWORD /d 0 /f 2>&1 | Out-Null
    
    # Explorateur
    reg add "HKLM\WIM_NTUSER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v ShowSyncProviderNotifications /t REG_DWORD /d 0 /f 2>&1 | Out-Null
    reg add "HKLM\WIM_NTUSER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v HideFileExt /t REG_DWORD /d 0 /f 2>&1 | Out-Null
    reg add "HKLM\WIM_NTUSER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v Hidden /t REG_DWORD /d 1 /f 2>&1 | Out-Null
    
    # Widgets
    reg add "HKLM\WIM_SOFTWARE\Policies\Microsoft\Dsh" /v AllowNewsAndInterests /t REG_DWORD /d 0 /f 2>&1 | Out-Null
    
    # Performance
    reg add "HKLM\WIM_NTUSER\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" /v VisualFXSetting /t REG_DWORD /d 2 /f 2>&1 | Out-Null
    
    reg unload "HKLM\WIM_SOFTWARE" 2>&1 | Out-Null
    reg unload "HKLM\WIM_NTUSER" 2>&1 | Out-Null
    
    Write-Host " ✓" -ForegroundColor Green
    
    # Nettoyage
    Write-Host "  Nettoyage de l'image..." -NoNewline
    dism /Image:"$Global:MountDir" /Cleanup-Image /StartComponentCleanup /ResetBase 2>&1 | Out-Null
    Write-Host " ✓" -ForegroundColor Green
    
    # Démontage avec barre de progression
    try {
        Dismount-ImageWithProgress -MountPath $Global:MountDir -Save
        Write-Host "✓ Image démontée et sauvegardée avec succès" -ForegroundColor Green
    } catch {
        Write-Host "✗ Erreur lors du démontage" -ForegroundColor Red
        pause
        return
    }
    
    # Copie de l'image modifiée
    Copy-Item $Global:InstallWim "$Global:CustomISODir\sources\install.wim" -Force
    
    # Copie des fichiers de personnalisation Xpolaris
    Write-Host "`n  Copie des fichiers de personnalisation..." -ForegroundColor Yellow
    
    # Générer Apps-Manager.ps1 si des applications sont sélectionnées
    $AppManagerGenerated = New-AppsManagerScript -OutputPath "$Global:ISOPath\Xpolaris-Apps-Manager.ps1"
    
    # Copier autounattend.xml à la racine de l'ISO
    if (Test-Path "$Global:ISOPath\autounattend.xml") {
        Copy-Item "$Global:ISOPath\autounattend.xml" "$Global:CustomISODir\autounattend.xml" -Force
        Write-Host "    ✓ autounattend.xml copié (installation automatique)" -ForegroundColor Green
    } else {
        Write-Host "    ! autounattend.xml non trouvé (installation manuelle)" -ForegroundColor Yellow
    }
    
    # Copier le fond d'écran Xpolaris Full HD
    if (Test-Path "$Global:ISOPath\XpolarisWallpaper.bmp") {
        Copy-Item "$Global:ISOPath\XpolarisWallpaper.bmp" "$Global:CustomISODir\sources\XpolarisWallpaper.bmp" -Force
        Write-Host "    ✓ XpolarisWallpaper.bmp copié (fond d'écran Full HD)" -ForegroundColor Green
        
        # Copier RemoveBloatware.ps1 dans sources (nettoyage post-installation)
        if (Test-Path "$Global:ISOPath\RemoveBloatware.ps1") {
            Copy-Item "$Global:ISOPath\RemoveBloatware.ps1" "$Global:CustomISODir\sources\RemoveBloatware.ps1" -Force
            Write-Host "    ✓ RemoveBloatware.ps1 copié (nettoyage bloatware)" -ForegroundColor Green
        }
        
        # Copier Xpolaris-Apps-Manager.ps1 dans sources (installation apps + dépannage)
        if (Test-Path "$Global:ISOPath\Xpolaris-Apps-Manager.ps1") {
            Copy-Item "$Global:ISOPath\Xpolaris-Apps-Manager.ps1" "$Global:CustomISODir\sources\Xpolaris-Apps-Manager.ps1" -Force
            Write-Host "    ✓ Xpolaris-Apps-Manager.ps1 copié (installation + dépannage)" -ForegroundColor Green
        }
        
        # Copier ApplyWallpaper.ps1 dans sources (force application fond d'écran)
        if (Test-Path "$Global:ISOPath\ApplyWallpaper.ps1") {
            Copy-Item "$Global:ISOPath\ApplyWallpaper.ps1" "$Global:CustomISODir\sources\ApplyWallpaper.ps1" -Force
            Write-Host "    ✓ ApplyWallpaper.ps1 copié (force fond d'écran)" -ForegroundColor Green
        }
        
        # Créer aussi une copie dans C:\ pour autounattend.xml
        if (-not (Test-Path "$Global:CustomISODir\sources\`$OEM$\`$`$\Setup\Scripts")) {
            New-Item -ItemType Directory -Path "$Global:CustomISODir\sources\`$OEM$\`$`$\Setup\Scripts" -Force | Out-Null
        }
        Copy-Item "$Global:ISOPath\XpolarisWallpaper.bmp" "$Global:CustomISODir\sources\`$OEM$\`$`$\Setup\Scripts\XpolarisWallpaper.bmp" -Force
        
        # Copier RemoveBloatware.ps1 dans le dossier Scripts
        if (Test-Path "$Global:ISOPath\RemoveBloatware.ps1") {
            Copy-Item "$Global:ISOPath\RemoveBloatware.ps1" "$Global:CustomISODir\sources\`$OEM$\`$`$\Setup\Scripts\RemoveBloatware.ps1" -Force
        }
        
        # Copier Xpolaris-Apps-Manager.ps1 dans le dossier Scripts
        if (Test-Path "$Global:ISOPath\Xpolaris-Apps-Manager.ps1") {
            Copy-Item "$Global:ISOPath\Xpolaris-Apps-Manager.ps1" "$Global:CustomISODir\sources\`$OEM$\`$`$\Setup\Scripts\Xpolaris-Apps-Manager.ps1" -Force
        }
        
        # Copier ApplyWallpaper.ps1 dans le dossier Scripts
        if (Test-Path "$Global:ISOPath\ApplyWallpaper.ps1") {
            Copy-Item "$Global:ISOPath\ApplyWallpaper.ps1" "$Global:CustomISODir\sources\`$OEM$\`$`$\Setup\Scripts\ApplyWallpaper.ps1" -Force
        }
        
        # Copier les scripts de dépannage (NOUVEAU - disponibles sur le Bureau après installation)
        if (Test-Path "$Global:ISOPath\Xpolaris-Apps-Manager.ps1") {
            # Copier dans le dossier Scripts pour disponibilité immédiate
            Copy-Item "$Global:ISOPath\Xpolaris-Apps-Manager.ps1" "$Global:CustomISODir\sources\`$OEM$\`$`$\Setup\Scripts\Xpolaris-Apps-Manager.ps1" -Force
            # Copier aussi sur le Bureau de l'Administrateur
            if (-not (Test-Path "$Global:CustomISODir\sources\`$OEM$\`$`$\Users\Administrateur\Desktop")) {
                New-Item -ItemType Directory -Path "$Global:CustomISODir\sources\`$OEM$\`$`$\Users\Administrateur\Desktop" -Force | Out-Null
            }
            Copy-Item "$Global:ISOPath\Xpolaris-Apps-Manager.ps1" "$Global:CustomISODir\sources\`$OEM$\`$`$\Users\Administrateur\Desktop\Xpolaris-Apps-Manager.ps1" -Force
            Write-Host "    ✓ Xpolaris-Apps-Manager.ps1 copié (dépannage universel)" -ForegroundColor Green
        }
        
        # Copier le lanceur .CMD également
        if (Test-Path "$Global:ISOPath\Xpolaris-Apps-Manager.cmd") {
            Copy-Item "$Global:ISOPath\Xpolaris-Apps-Manager.cmd" "$Global:CustomISODir\sources\`$OEM$\`$`$\Setup\Scripts\Xpolaris-Apps-Manager.cmd" -Force
            Copy-Item "$Global:ISOPath\Xpolaris-Apps-Manager.cmd" "$Global:CustomISODir\sources\`$OEM$\`$`$\Users\Administrateur\Desktop\Xpolaris-Apps-Manager.cmd" -Force
            Write-Host "    ✓ Xpolaris-Apps-Manager.cmd copié (lanceur)" -ForegroundColor Green
        }
        
        # Créer un script SetupComplete.cmd COMPLET qui exécute tout
        $CopyScript = @'
@echo off
REM ============================================================
REM Xpolaris OS - Configuration Post-Installation avec DEBUG
REM Log complet: C:\SetupComplete.log
REM ============================================================

set LOGFILE=C:\SetupComplete.log
echo ============================================ > %LOGFILE%
echo Xpolaris OS - Configuration Post-Installation >> %LOGFILE%
echo Date: %date% %time% >> %LOGFILE%
echo ============================================ >> %LOGFILE%
echo. >> %LOGFILE%

echo [DEBUG] Dossier d'execution: %~dp0 >> %LOGFILE%
echo [DEBUG] Fichiers disponibles: >> %LOGFILE%
dir /b "%~dp0" >> %LOGFILE%
echo. >> %LOGFILE%

REM Copier les fichiers vers C:\
echo [1/5] Copie des fichiers... >> %LOGFILE%

REM Fond d'ecran
if exist "%~dp0XpolarisWallpaper.bmp" (
    echo [OK] XpolarisWallpaper.bmp trouve >> %LOGFILE%
    copy /Y "%~dp0XpolarisWallpaper.bmp" "C:\Windows\Web\Wallpaper\XpolarisWallpaper.bmp" >> %LOGFILE% 2>&1
    if exist "C:\Windows\Web\Wallpaper\XpolarisWallpaper.bmp" (
        echo [OK] Fond d'ecran copie avec succes >> %LOGFILE%
    ) else (
        echo [ERREUR] Echec copie fond d'ecran >> %LOGFILE%
    )
) else (
    echo [ERREUR] XpolarisWallpaper.bmp introuvable dans %~dp0 >> %LOGFILE%
)

REM RemoveBloatware.ps1 - GARDER dans Scripts, pas de copie vers C:\
if exist "%~dp0RemoveBloatware.ps1" (
    echo [OK] RemoveBloatware.ps1 trouve dans %~dp0 >> %LOGFILE%
) else (
    echo [ERREUR] RemoveBloatware.ps1 introuvable >> %LOGFILE%
)

REM Xpolaris-Apps-Manager.ps1 - GARDER dans Scripts, pas de copie vers C:\
if exist "%~dp0Xpolaris-Apps-Manager.ps1" (
    echo [OK] Xpolaris-Apps-Manager.ps1 trouve dans %~dp0 >> %LOGFILE%
) else (
    echo [ERREUR] Xpolaris-Apps-Manager.ps1 introuvable >> %LOGFILE%
)

REM ApplyWallpaper.ps1 - GARDER dans Scripts, pas de copie vers C:\
if exist "%~dp0ApplyWallpaper.ps1" (
    echo [OK] ApplyWallpaper.ps1 trouve dans %~dp0 >> %LOGFILE%
) else (
    echo [ERREUR] ApplyWallpaper.ps1 introuvable >> %LOGFILE%
)

echo. >> %LOGFILE%

REM Configuration fond d'ecran
echo [2/5] Configuration fond d'ecran Xpolaris... >> %LOGFILE%
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v Wallpaper /t REG_SZ /d "C:\Windows\Web\Wallpaper\XpolarisWallpaper.bmp" /f >> %LOGFILE% 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v WallpaperStyle /t REG_SZ /d "10" /f >> %LOGFILE% 2>&1
echo [OK] Registry fond d'ecran configure >> %LOGFILE%
echo. >> %LOGFILE%

REM Configurer les informations OEM
echo [3/5] Configuration OEM Registry... >> %LOGFILE%
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation" /v Manufacturer /t REG_SZ /d "Xpolaris" /f >> %LOGFILE% 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation" /v Model /t REG_SZ /d "Xpolaris OS - Edition Personnalisee" /f >> %LOGFILE% 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation" /v SupportHours /t REG_SZ /d "24/7 - Xpolaris Support" /f >> %LOGFILE% 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation" /v SupportPhone /t REG_SZ /d "+33 X-POLARIS" /f >> %LOGFILE% 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation" /v SupportURL /t REG_SZ /d "https://xpolaris.local" /f >> %LOGFILE% 2>&1
echo [OK] OEM Info configuree >> %LOGFILE%
echo. >> %LOGFILE%

REM Activer le compte Administrateur
echo [4/6] Activation compte Administrateur... >> %LOGFILE%
net user Administrateur /active:yes >> %LOGFILE% 2>&1
echo [OK] Compte Administrateur active >> %LOGFILE%
echo. >> %LOGFILE%

REM Executer RemoveBloatware.ps1 IMMEDIATEMENT (avant premier login)
echo [5/6] Suppression bloatware (Xbox, Teams, OneDrive)... >> %LOGFILE%
set "BLOATWARE_SCRIPT=%~dp0RemoveBloatware.ps1"
if exist "%BLOATWARE_SCRIPT%" (
    echo [OK] Script trouve: %BLOATWARE_SCRIPT% >> %LOGFILE%
    echo [INFO] Execution en cours... >> %LOGFILE%
    powershell.exe -ExecutionPolicy Bypass -NoProfile -File "%BLOATWARE_SCRIPT%" >> C:\RemoveBloatware.log 2>&1
    if errorlevel 1 (
        echo [ERREUR] Echec suppression bloatware - code: %ERRORLEVEL% >> %LOGFILE%
    ) else (
        echo [OK] Bloatware supprime avec succes >> %LOGFILE%
        echo [INFO] Details dans C:\RemoveBloatware.log >> %LOGFILE%
    )
) else (
    echo [ERREUR] Script RemoveBloatware.ps1 introuvable dans %~dp0 >> %LOGFILE%
)
echo. >> %LOGFILE%

REM Créer tâche planifiée pour Xpolaris-Apps-Manager.ps1 (mode AUTO)
echo [6/7] Creation tache planifiee XpolarisInstallApps... >> %LOGFILE%
set "SCRIPT_PATH=%~dp0Xpolaris-Apps-Manager.ps1"
echo [DEBUG] Chemin complet: %SCRIPT_PATH% >> %LOGFILE%
if exist "%SCRIPT_PATH%" (
    echo [OK] Script trouve: %SCRIPT_PATH% >> %LOGFILE%
    schtasks /Create /TN "XpolarisInstallApps" /TR "powershell.exe -ExecutionPolicy Bypass -NoProfile -File \"%SCRIPT_PATH%\" -AutoMode" /SC ONLOGON /DELAY 0001:00 /RL HIGHEST /RU "Administrateur" /F >> %LOGFILE% 2>&1
    if errorlevel 1 (
        echo [ERREUR] Echec creation tache XpolarisInstallApps - code: %ERRORLEVEL% >> %LOGFILE%
    ) else (
        echo [OK] Tache XpolarisInstallApps creee avec succes >> %LOGFILE%
    )
) else (
    echo [ERREUR] Script Xpolaris-Apps-Manager.ps1 introuvable dans %~dp0 >> %LOGFILE%
)

REM Créer tâche planifiée pour ApplyWallpaper.ps1 (force fond d'écran)
echo. >> %LOGFILE%
echo [7/7] Creation tache planifiee ApplyWallpaper... >> %LOGFILE%
set "WALLPAPER_SCRIPT=%~dp0ApplyWallpaper.ps1"
echo [DEBUG] Chemin complet: %WALLPAPER_SCRIPT% >> %LOGFILE%
if exist "%WALLPAPER_SCRIPT%" (
    echo [OK] Script trouve: %WALLPAPER_SCRIPT% >> %LOGFILE%
    schtasks /Create /TN "XpolarisApplyWallpaper" /TR "powershell.exe -ExecutionPolicy Bypass -NoProfile -File \"%WALLPAPER_SCRIPT%\"" /SC ONLOGON /DELAY 0000:30 /RL HIGHEST /RU "Administrateur" /F >> %LOGFILE% 2>&1
    if errorlevel 1 (
        echo [ERREUR] Echec creation tache ApplyWallpaper - code: %ERRORLEVEL% >> %LOGFILE%
    ) else (
        echo [OK] Tache XpolarisApplyWallpaper creee avec succes >> %LOGFILE%
    )
) else (
    echo [ERREUR] Script ApplyWallpaper.ps1 introuvable dans %~dp0 >> %LOGFILE%
)

echo. >> %LOGFILE%
echo ============================================ >> %LOGFILE%
echo Configuration terminee >> %LOGFILE%
echo Verifiez ce log: %LOGFILE% >> %LOGFILE%
echo ============================================ >> %LOGFILE%

REM Afficher le log à l'écran
type %LOGFILE%
timeout /t 5
'@
        Set-Content "$Global:CustomISODir\sources\`$OEM$\`$`$\Setup\Scripts\SetupComplete.cmd" -Value $CopyScript -Force
        Write-Host "    ✓ SetupComplete.cmd créé (avec logs de débogage)" -ForegroundColor Green
    } else {
        Write-Host "    ! XpolarisWallpaper.bmp non trouvé" -ForegroundColor Yellow
    }
    
    # Marqueur
    Get-Date -Format "yyyy-MM-dd HH:mm:ss" | Out-File "$Global:WorkDir\install_customized.txt" -Force
    
    Write-ColorOutput Green "✓ Personnalisation terminée"
}

# Fonction 4: Supprimer des composants Windows
function Start-RemoveComponents {
    param([switch]$AutoMode)
    
    if (-not $AutoMode) {
        Show-Title
        Write-ColorOutput Red "📦 SUPPRESSION DE COMPOSANTS WINDOWS (AVANCÉ)"
        Write-Host ""
        Write-Host "Cette fonction supprime des composants Windows pour réduire la taille." -ForegroundColor Yellow
        Write-Host ""
    }
    
    # Vérification de l'image
    if (-not (Test-Path $Global:InstallWim)) {
        Write-ColorOutput Red "✗ install.wim non trouvé"
        if (-not $AutoMode) { pause }
        return
    }
    
    if (-not $AutoMode) {
        # Affichage des composants disponibles à la suppression
        Write-Host "Composants pouvant être supprimés:" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "  [1] 🌐 Internet Explorer 11" -ForegroundColor White
        Write-Host "  [2] 🎵 Windows Media Player Legacy" -ForegroundColor White
        Write-Host "  [3] 🖼️  Paint 3D et 3D Viewer" -ForegroundColor White
        Write-Host "  [4] 📠 Télécopie et numérisation Windows" -ForegroundColor White
        Write-Host "  [5] 💼 Windows Hello Face (si pas de caméra IR)" -ForegroundColor White
        Write-Host "  [6] 📝 WordPad" -ForegroundColor White
        Write-Host "  [7] 🎮 Composants Xbox (services)" -ForegroundColor White
        Write-Host "  [8] 📱 Your Phone / Phone Link" -ForegroundColor White
        Write-Host "  [9] 🌍 Packs de langues additionnels (garder fr-FR)" -ForegroundColor White
        Write-Host "  [A] ⚡ TOUT supprimer (recommandé)" -ForegroundColor Green
        Write-Host "  [0] ❌ Annuler" -ForegroundColor Red
        Write-Host ""
        
        $Choice = Read-Host "Votre choix"
        
        if ($Choice -eq "0") {
            return
        }
    } else {
        # Mode automatique: supprimer tout
        $Choice = "A"
        Write-Host "  Mode automatique: suppression de tous les composants inutiles..." -ForegroundColor Cyan
    }
    
    # Sélection des composants à supprimer
    $ComponentsToRemove = @()
    
    switch ($Choice) {
        "1" { $ComponentsToRemove = @("Internet-Explorer-Optional-amd64") }
        "2" { $ComponentsToRemove = @("WindowsMediaPlayer") }
        "3" { $ComponentsToRemove = @("Microsoft.Windows.MSPaint", "Microsoft.Microsoft3DViewer") }
        "4" { $ComponentsToRemove = @("FaxServicesClientPackage") }
        "5" { $ComponentsToRemove = @("Hello-Face") }
        "6" { $ComponentsToRemove = @("Microsoft-Windows-WordPad") }
        "7" { $ComponentsToRemove = @("Microsoft-Xbox-Game-CallableUI", "Microsoft-Xbox-GameBar") }
        "8" { $ComponentsToRemove = @("Microsoft.YourPhone") }
        "9" { 
            Write-Host "Suppression des langues (garder fr-FR) nécessite un traitement spécial..." -ForegroundColor Yellow
            pause
            return
        }
        "A" { 
            $ComponentsToRemove = @(
                # Navigateur et médias legacy
                "Internet-Explorer-Optional-amd64",
                "WindowsMediaPlayer",
                
                # Télécopie et outils obsolètes
                "FaxServicesClientPackage",
                "Microsoft-Windows-WordPad",
                
                # Paint et 3D
                "Microsoft.Windows.MSPaint",
                "Microsoft.Microsoft3DViewer",
                
                # Xbox et Gaming
                "Microsoft-Xbox-Game-CallableUI",
                "Microsoft-Xbox-GameBar",
                "Microsoft.Xbox.TCUI",
                "Microsoft.XboxApp",
                "Microsoft.XboxGameOverlay",
                "Microsoft.XboxGamingOverlay",
                "Microsoft.XboxIdentityProvider",
                "Microsoft.XboxSpeechToTextOverlay",
                
                # Téléphone et Communication
                "Microsoft.YourPhone",
                "Microsoft.WindowsPhone",
                
                # Microsoft Store Apps (bloatware)
                "Microsoft.BingNews",
                "Microsoft.BingWeather",
                "Microsoft.BingFinance",
                "Microsoft.BingSports",
                "Clipchamp.Clipchamp",
                "Microsoft.Clipchamp",
                "Microsoft.OneDrive",
                "Microsoft.Teams",
                "Microsoft.Todos",
                "Microsoft.PowerAutomateDesktop",
                "Microsoft.LinkedIn",
                
                # Autres apps Microsoft inutiles
                "Microsoft.GetHelp",
                "Microsoft.Getstarted",
                "Microsoft.MicrosoftOfficeHub",
                "Microsoft.MicrosoftSolitaireCollection",
                "Microsoft.People",
                "Microsoft.WindowsAlarms",
                "Microsoft.WindowsCommunicationsApps",
                "Microsoft.WindowsFeedbackHub",
                "Microsoft.WindowsMaps",
                "Microsoft.WindowsSoundRecorder",
                "Microsoft.ZuneMusic",
                "Microsoft.ZuneVideo",
                "Microsoft.SkypeApp",
                "Microsoft.Wallet",
                "Microsoft.MixedReality.Portal"
            )
        }
        default {
            Write-ColorOutput Red "Choix invalide"
            pause
            return
        }
    }
    
    if ($ComponentsToRemove.Count -eq 0) {
        Write-ColorOutput Yellow "Aucun composant sélectionné"
        pause
        return
    }
    
    # Création du point de montage
    if (-not (Test-Path $Global:MountDir)) {
        New-Item -ItemType Directory -Path $Global:MountDir -Force | Out-Null
    }
    
    # Montage de l'image avec barre de progression
    try {
        $ImageInfo = Get-WindowsImage -ImagePath $Global:InstallWim
        $ImageIndex = if ($ImageInfo.Count -eq 1) { 1 } else { 6 }
        Mount-ImageWithProgress -ImagePath $Global:InstallWim -Index $ImageIndex -MountPath $Global:MountDir
        Write-Host "✓ Image montée avec succès" -ForegroundColor Green
    } catch {
        Write-Host "✗ Erreur lors du montage" -ForegroundColor Red
        Write-ColorOutput Red "Erreur: $_"
        if (-not $AutoMode) { pause }
        return
    }
    
    # Suppression des composants
    Write-Host "`nSuppression des composants..." -ForegroundColor Cyan
    $RemovedCount = 0
    $FailedCount = 0
    
    foreach ($Component in $ComponentsToRemove) {
        Write-Host "  Suppression: $Component..." -NoNewline
        
        try {
            $Removed = $false
            
            # 1. Tentative avec Disable-WindowsOptionalFeature (pour IE, Media Player, etc.)
            $Feature = Get-WindowsOptionalFeature -Path $Global:MountDir -FeatureName $Component -ErrorAction SilentlyContinue
            
            if ($Feature -and $Feature.State -eq "Enabled") {
                Disable-WindowsOptionalFeature -Path $Global:MountDir -FeatureName $Component -Remove -NoRestart -ErrorAction Stop | Out-Null
                Write-Host " ✓" -ForegroundColor Green
                $RemovedCount++
                $Removed = $true
            }
            
            # 2. Si pas trouvé, tentative avec AppX Provisioned Packages (pour Paint 3D, Xbox, YourPhone, etc.)
            if (-not $Removed) {
                $AppxPackages = Get-AppxProvisionedPackage -Path $Global:MountDir -ErrorAction SilentlyContinue | Where-Object { $_.DisplayName -like "*$Component*" }
                
                if ($AppxPackages) {
                    foreach ($Appx in $AppxPackages) {
                        Remove-AppxProvisionedPackage -Path $Global:MountDir -PackageName $Appx.PackageName -ErrorAction Stop | Out-Null
                    }
                    Write-Host " ✓" -ForegroundColor Green
                    $RemovedCount++
                    $Removed = $true
                }
            }
            
            # 3. Si toujours pas trouvé, tentative avec Get-WindowsPackage (packages Windows)
            if (-not $Removed) {
                $Packages = Get-WindowsPackage -Path $Global:MountDir -ErrorAction SilentlyContinue | Where-Object { $_.PackageName -like "*$Component*" }
                
                if ($Packages) {
                    foreach ($Package in $Packages) {
                        Remove-WindowsPackage -Path $Global:MountDir -PackageName $Package.PackageName -NoRestart -ErrorAction Stop | Out-Null
                    }
                    Write-Host " ✓" -ForegroundColor Green
                    $RemovedCount++
                    $Removed = $true
                }
            }
            
            # Si rien n'a été trouvé
            if (-not $Removed) {
                Write-Host " -" -ForegroundColor DarkGray
                Write-Host "      (Non trouvé ou déjà supprimé)" -ForegroundColor DarkGray
            }
            
        } catch {
            Write-Host " ✗" -ForegroundColor Red
            Write-Host "      Erreur: $_" -ForegroundColor Red
            $FailedCount++
        }
    }
    
    Write-Host ""
    Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Green
    Write-Host "Composants supprimés: $RemovedCount | Échecs: $FailedCount" -ForegroundColor Green
    Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Green
    
    # Nettoyage approfondi
    Write-Host "`nNettoyage approfondi de l'image..." -NoNewline
    dism /Image:"$Global:MountDir" /Cleanup-Image /StartComponentCleanup /ResetBase 2>&1 | Out-Null
    Write-Host " ✓" -ForegroundColor Green
    
    # Taille avant démontage
    $SizeBefore = (Get-Item $Global:InstallWim).Length
    
    # Démontage avec barre de progression
    try {
        Dismount-ImageWithProgress -MountPath $Global:MountDir -Save
        Write-Host "✓ Image démontée et sauvegardée avec succès" -ForegroundColor Green
    } catch {
        Write-Host "✗ Erreur lors du démontage" -ForegroundColor Red
        Write-ColorOutput Red "Erreur lors du démontage: $_"
        if (-not $AutoMode) { pause }
        return
    }
    
    # Taille après démontage (attendre que le fichier soit libéré)
    Start-Sleep -Seconds 2
    $SizeAfter = (Get-Item $Global:InstallWim).Length
    $SavedBytes = $SizeBefore - $SizeAfter
    $Saved = [math]::Round($SavedBytes / 1MB, 2)
    
    Write-Host ""
    if ($RemovedCount -gt 0) {
        Write-ColorOutput Green "✓ Suppression terminée"
        Write-Host "Taille avant: $([math]::Round($SizeBefore / 1GB, 2)) GB" -ForegroundColor White
        Write-Host "Taille après: $([math]::Round($SizeAfter / 1GB, 2)) GB" -ForegroundColor Green
        
        if ($SavedBytes -gt 0) {
            Write-Host "Économisé: $Saved MB" -ForegroundColor Cyan
        } else {
            Write-Host "Note: Gain visible après re-compression de l'image" -ForegroundColor Yellow
        }
    } else {
        Write-ColorOutput Yellow "⚠ Aucun composant n'a été supprimé"
    }
    Write-Host ""
    
    if (-not $AutoMode) {
        pause
    }
}

# Fonction 5: Nettoyage
function Start-Cleanup {
    param(
        [switch]$Silent,
        [switch]$KeepISO
    )
    
    # Vérification et démontage des images montées
    Write-Host "`nVérification des images montées..." -NoNewline
    $MountedImages = Get-WindowsImage -Mounted -ErrorAction SilentlyContinue
    if ($MountedImages) {
        Write-Host " Trouvée!" -ForegroundColor Yellow
        Write-Host "Une image est montée dans $Global:MountDir" -ForegroundColor Yellow
        
        if (-not $Silent) {
            Write-Host "Démonter l'image ? (O=Sauvegarder / N=Annuler / D=Discard)" -ForegroundColor Cyan
            $DismountChoice = Read-Host
            
            if ($DismountChoice -eq "O" -or $DismountChoice -eq "o") {
                Write-Host "Démontage avec sauvegarde..." -NoNewline
                Dismount-WindowsImage -Path $Global:MountDir -Save -ErrorAction SilentlyContinue | Out-Null
                Write-Host " ✓" -ForegroundColor Green
            } elseif ($DismountChoice -eq "D" -or $DismountChoice -eq "d") {
                Write-Host "Démontage sans sauvegarde..." -NoNewline
                Dismount-WindowsImage -Path $Global:MountDir -Discard -ErrorAction SilentlyContinue | Out-Null
                Write-Host " ✓" -ForegroundColor Green
            } else {
                Write-ColorOutput Yellow "Nettoyage annulé (image toujours montée)"
                pause
                return
            }
        } else {
            # Mode silent : démonter sans sauvegarder
            Dismount-WindowsImage -Path $Global:MountDir -Discard -ErrorAction SilentlyContinue | Out-Null
        }
    } else {
        Write-Host " OK" -ForegroundColor Green
    }
    
    $FilesToClean = @(
        "$Global:WorkDir\install_backup.wim",
        "$Global:WorkDir\install_multiéditions.wim",
        "$Global:WorkDir\install_single.wim",
        "$Global:WorkDir\Mount"
    )
    
    # Si on ne garde pas l'ISO, ajouter CustomISO et l'ISO créé à la liste
    if (-not $KeepISO) {
        $FilesToClean += "$Global:WorkDir\CustomISO"
        if (Test-Path $Global:OutputISO) {
            $FilesToClean += $Global:OutputISO
        }
    }
    
    # Calcul de la taille AVANT suppression
    $TotalSize = 0
    $FilesFound = @()
    
    foreach ($Item in $FilesToClean) {
        if (Test-Path $Item) {
            $FilesFound += $Item
            if (Test-Path $Item -PathType Container) {
                $Size = (Get-ChildItem -Path $Item -Recurse -File -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
            } else {
                $Size = (Get-Item $Item -ErrorAction SilentlyContinue).Length
            }
            $TotalSize += $Size
        }
    }
    
    $TotalSizeGB = [math]::Round($TotalSize / 1GB, 2)
    
    if ($TotalSize -eq 0) {
        if (-not $Silent) {
            Write-ColorOutput Green "✓ Aucun fichier temporaire à nettoyer"
            pause
        }
        return
    }
    
    if (-not $Silent) {
        Write-Host "`nFichiers trouvés:" -ForegroundColor Cyan
        foreach ($File in $FilesFound) {
            $FileName = Split-Path $File -Leaf
            Write-Host "  - $FileName" -ForegroundColor Gray
        }
        Write-Host "`nEspace récupérable: $TotalSizeGB GB" -ForegroundColor Yellow
        $Confirm = Read-Host "Supprimer ? (O/N)"
        if ($Confirm -ne "O" -and $Confirm -ne "o") {
            return
        }
    }
    
    Write-Host "`n  Nettoyage en cours..." -NoNewline
    $DeletedCount = 0
    foreach ($Item in $FilesToClean) {
        if (Test-Path $Item) {
            try {
                Remove-Item -Path $Item -Recurse -Force -ErrorAction Stop
                $DeletedCount++
            } catch {
                Write-Host "`n  Erreur lors de la suppression de $Item : $_" -ForegroundColor Red
            }
        }
    }
    
    # Vérification réelle après suppression
    $RemainingSize = 0
    foreach ($Item in $FilesToClean) {
        if (Test-Path $Item) {
            if (Test-Path $Item -PathType Container) {
                $Size = (Get-ChildItem -Path $Item -Recurse -File -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
            } else {
                $Size = (Get-Item $Item -ErrorAction SilentlyContinue).Length
            }
            $RemainingSize += $Size
        }
    }
    
    $ActualFreed = [math]::Round(($TotalSize - $RemainingSize) / 1GB, 2)
    
    Write-Host " ✓" -ForegroundColor Green
    
    if ($ActualFreed -gt 0) {
        Write-ColorOutput Green "✓ $ActualFreed GB libérés ($DeletedCount élément(s) supprimé(s))"
    } else {
        Write-ColorOutput Yellow "⚠ Aucun espace libéré (fichiers déjà supprimés ou inaccessibles)"
    }
    
    if (-not $Silent) {
        pause
    }
}

# Fonction 5: Créer ISO
function Start-CreateISO {
    param([switch]$AutoMode)
    
    if (-not (Test-Path $Global:CustomISODir)) {
        Write-ColorOutput Red "✗ Dossier CustomISO non trouvé. Exécutez d'abord la personnalisation."
        if (-not $AutoMode) { pause }
        return
    }
    
    if (-not $AutoMode) {
        Show-Title
        Write-ColorOutput Cyan "💿 CRÉATION DE L'ISO BOOTABLE XPOLARIS"
        Write-Host ""
        Write-Host "Ce processus va:" -ForegroundColor White
        Write-Host "  • Vérifier la présence de oscdimg.exe (Windows ADK)"
        Write-Host "  • Créer une image ISO bootable (BIOS + UEFI)"
        Write-Host "  • Générer: Windows_Custom_Xpolaris.iso"
        Write-Host ""
        $CustomISOSize = Get-ChildItem $Global:CustomISODir -Recurse -File | Measure-Object -Property Length -Sum
        $SizeGB = [math]::Round($CustomISOSize.Sum / 1GB, 2)
        Write-Host "📦 Taille estimée de l'ISO: $SizeGB GB" -ForegroundColor Cyan
        Write-Host "⏱️  Durée estimée: 3-5 minutes" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "Voulez-vous créer l'ISO bootable ? " -NoNewline -ForegroundColor Cyan
        Write-Host "(O/N)" -ForegroundColor Yellow -NoNewline
        Write-Host ": " -NoNewline
        $Confirm = Read-Host
        
        if ($Confirm -ne "O" -and $Confirm -ne "o") {
            Write-Host ""
            Write-ColorOutput Yellow "✓ Création ISO annulée - Retour au menu principal"
            Start-Sleep -Seconds 2
            return
        }
        
        Write-Host ""
    }
    
    # 🗑️ NETTOYAGE PRÉVENTIF : Supprimer TOUS les fichiers .iso existants
    Write-Host "╔═══════════════════════════════════════════════════════════╗" -ForegroundColor Yellow
    Write-Host "║ " -NoNewline -ForegroundColor Yellow
    Write-Host "🗑️  NETTOYAGE PRÉVENTIF DES FICHIERS .ISO" -NoNewline -ForegroundColor White
    Write-Host "                     ║" -ForegroundColor Yellow
    Write-Host "╚═══════════════════════════════════════════════════════════╝" -ForegroundColor Yellow
    Write-Host ""
    
    # Supprimer l'ancienne ISO finale si elle existe
    if (Test-Path $Global:OutputISO) {
        $OldSize = [math]::Round((Get-Item $Global:OutputISO).Length / 1GB, 2)
        Write-Host "  🗑️  Suppression : Windows_Custom_Xpolaris.iso ($OldSize GB)" -ForegroundColor Yellow
        Remove-Item $Global:OutputISO -Force -ErrorAction SilentlyContinue
        Write-Host "      ✓ Supprimé" -ForegroundColor Green
    }
    
    # Supprimer TOUS les fichiers .iso dans CustomISODir (évite le doublement de taille)
    Write-Host ""
    Write-Host "  🔍 Recherche de fichiers .iso dans CustomISODir..." -ForegroundColor Cyan
    $ISOFilesInCustomDir = Get-ChildItem -Path $Global:CustomISODir -Filter "*.iso" -Recurse -Force -ErrorAction SilentlyContinue
    if ($ISOFilesInCustomDir -and $ISOFilesInCustomDir.Count -gt 0) {
        Write-Host "      ⚠️  ATTENTION : $($ISOFilesInCustomDir.Count) fichier(s) .iso trouvé(s) !" -ForegroundColor Red
        Write-Host ""
        foreach ($ISOFile in $ISOFilesInCustomDir) {
            $ISOSize = [math]::Round($ISOFile.Length / 1GB, 2)
            Write-Host "      🗑️  Suppression : $($ISOFile.Name) ($ISOSize GB)" -ForegroundColor Yellow
            Write-Host "          Chemin : $($ISOFile.FullName)" -ForegroundColor Gray
            Remove-Item $ISOFile.FullName -Force -ErrorAction SilentlyContinue
            if (-not (Test-Path $ISOFile.FullName)) {
                Write-Host "          ✓ Supprimé avec succès" -ForegroundColor Green
            } else {
                Write-Host "          ✗ Échec de la suppression" -ForegroundColor Red
            }
        }
        Write-Host ""
        Write-Host "  ✓ Nettoyage terminé - Prêt pour la création de l'ISO" -ForegroundColor Green
    } else {
        Write-Host "      ✓ Aucun fichier .iso trouvé (OK)" -ForegroundColor Green
    }
    Write-Host ""
    Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Gray
    Write-Host ""
    
    # PRIORITÉ 1: Recherche de oscdimg.exe (Windows ADK) pour créer l'ISO
    Write-Host "╔═══════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║ " -NoNewline -ForegroundColor Cyan
    Write-Host "Méthode recommandée : Créer un fichier .ISO bootable" -NoNewline -ForegroundColor White
    Write-Host "      ║" -ForegroundColor Cyan
    Write-Host "╚═══════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  Recherche de oscdimg.exe (Windows ADK)..." -NoNewline
    
    $OscdimgPaths = @(
        "C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Deployment Tools\amd64\Oscdimg\oscdimg.exe",
        "C:\Program Files (x86)\Windows Kits\11\Assessment and Deployment Kit\Deployment Tools\amd64\Oscdimg\oscdimg.exe"
    )
    
    $OscdimgPath = $null
    foreach ($Path in $OscdimgPaths) {
        if (Test-Path $Path) {
            $OscdimgPath = $Path
            break
        }
    }
    
    if ($OscdimgPath) {
        Write-Host " ✓" -ForegroundColor Green
        Write-Host ""
        
        # Création de l'ISO avec oscdimg
        Write-ColorOutput Green "✓ oscdimg.exe trouvé - Création de l'ISO en cours..."
        Write-Host ""
        
        # Création ISO avec barre de progression
        # Note : BootData contient des chemins qui peuvent avoir des espaces
        # On doit construire la commande très soigneusement
        $BootFile1 = "$Global:CustomISODir\boot\etfsboot.com"
        $BootFile2 = "$Global:CustomISODir\efi\microsoft\boot\efisys.bin"
        
        # Vérification des fichiers de boot
        if (-not (Test-Path $BootFile1)) {
            Write-ColorOutput Red "✗ Fichier de boot BIOS manquant : boot\etfsboot.com"
            if (-not $AutoMode) { pause }
            return
        }
        if (-not (Test-Path $BootFile2)) {
            Write-ColorOutput Red "✗ Fichier de boot UEFI manquant : efi\microsoft\boot\efisys.bin"
            if (-not $AutoMode) { pause }
            return
        }
        
        # Format correct pour VMware/VirtualBox : utiliser les chemins relatifs depuis CustomISODir
        $BootData = "2#p0,e,b`"boot\etfsboot.com`"#pEF,e,b`"efi\microsoft\boot\efisys.bin`""
        
        Write-Host "  Préparation de la création de l'ISO..." -ForegroundColor Cyan
        Write-Host "  Source : $Global:CustomISODir" -ForegroundColor Gray
        Write-Host "  Destination : $Global:OutputISO" -ForegroundColor Gray
        Write-Host ""
        
        try {
            # Méthode la plus fiable : créer un fichier batch temporaire
            # Cela évite tous les problèmes d'échappement de guillemets
            $TempBatchFile = "$env:TEMP\oscdimg_temp_$(Get-Random).cmd"
            $BatchContent = "@echo off`r`n"
            $BatchContent += "cd /d `"$Global:CustomISODir`"`r`n"
            # Paramètres optimisés pour VMware/VirtualBox :
            # -m = ignore 31 char limit
            # -o = optimize storage
            # -u2 = UDF file system
            # -udfver102 = UDF version 1.02
            # -l = volume label
            # -bootdata = dual boot (BIOS + UEFI)
            $BatchContent += "`"$OscdimgPath`" -m -o -u2 -udfver102 -l`"CCSA_X64FRE_FR-FR_DV9`" -bootdata:$BootData `"$Global:CustomISODir`" `"$Global:OutputISO`"`r`n"
            $BatchContent += "exit %ERRORLEVEL%"
            
            [System.IO.File]::WriteAllText($TempBatchFile, $BatchContent)
            
            Write-Host "  📝 Commande qui sera exécutée :" -ForegroundColor Cyan
            Write-Host "  $BatchContent" -ForegroundColor DarkGray
            Write-Host ""
            
            # Exécution du fichier batch SANS redirection pour voir la sortie en temps réel
            Write-Host "╔══════════════════════════════════════════════════════════════════╗" -ForegroundColor Yellow
            Write-Host "║ " -NoNewline -ForegroundColor Yellow
            Write-Host "🚀 Création de l'ISO en cours..." -NoNewline -ForegroundColor White
            Write-Host "                                     ║" -ForegroundColor Yellow
            Write-Host "╚══════════════════════════════════════════════════════════════════╝" -ForegroundColor Yellow
            Write-Host ""
            Write-Host "  ⏱️  Durée estimée : 5-10 minutes" -ForegroundColor Cyan
            Write-Host "  📊 La progression sera affichée dans une fenêtre séparée" -ForegroundColor Cyan
            Write-Host ""
            Write-Host "  Veuillez patienter..." -ForegroundColor Gray
            Write-Host ""
            
            $pinfo = New-Object System.Diagnostics.ProcessStartInfo
            $pinfo.FileName = "cmd.exe"
            $pinfo.Arguments = "/c `"$TempBatchFile`""
            $pinfo.RedirectStandardError = $false
            $pinfo.RedirectStandardOutput = $false
            $pinfo.UseShellExecute = $false
            $pinfo.CreateNoWindow = $false  # Afficher la fenêtre pour voir la progression
            
            $p = New-Object System.Diagnostics.Process
            $p.StartInfo = $pinfo
            $p.Start() | Out-Null
            $p.WaitForExit()
            
            $ExitCode = $p.ExitCode
            
            Write-Host ""
            Write-Host "  ✅ oscdimg terminé avec le code : $ExitCode" -ForegroundColor $(if ($ExitCode -eq 0) { "Green" } else { "Red" })
            Write-Host ""
            
            # Nettoyage du fichier temporaire
            if (Test-Path $TempBatchFile) {
                Remove-Item $TempBatchFile -Force -ErrorAction SilentlyContinue
            }
            
        } catch {
            Write-Host ""
            Write-ColorOutput Red "✗ Erreur lors du lancement de oscdimg : $_"
            Write-Host "  Détails : $($_.Exception.Message)" -ForegroundColor Yellow
            Write-Host "  Ligne : $($_.InvocationInfo.ScriptLineNumber)" -ForegroundColor Gray
            $ExitCode = 1
        }
        
        if ($ExitCode -eq 0 -and (Test-Path $Global:OutputISO)) {
            $ISOSize = [math]::Round((Get-Item $Global:OutputISO).Length / 1GB, 2)
            Write-Host ""
            Write-Host "╔═══════════════════════════════════════════════════════════╗" -ForegroundColor Green
            Write-Host "║ " -NoNewline -ForegroundColor Green
            Write-Host "✓ ISO CRÉÉE AVEC SUCCÈS !" -NoNewline -ForegroundColor White
            Write-Host "                                  ║" -ForegroundColor Green
            Write-Host "╚═══════════════════════════════════════════════════════════╝" -ForegroundColor Green
            Write-Host ""
            Write-Host "  Fichier : Windows_Custom_Xpolaris.iso" -ForegroundColor White
            Write-Host "  Taille  : $ISOSize GB" -ForegroundColor Cyan
            Write-Host "  Chemin  : $Global:OutputISO" -ForegroundColor Gray
            Write-Host ""
            Write-Host "💡 Vous pouvez maintenant:" -ForegroundColor Yellow
            Write-Host "   • Graver l'ISO sur un DVD" -ForegroundColor Gray
            Write-Host "   • Créer une clé USB bootable avec Rufus" -ForegroundColor Gray
            Write-Host "   • Utiliser l'ISO en machine virtuelle (VirtualBox, VMware, etc.)" -ForegroundColor Gray
        } else {
            Write-Host ""
            Write-ColorOutput Red "✗ Erreur lors de la création de l'ISO"
            Write-Host ""
            Write-ColorOutput Yellow "→ Essayons avec une méthode alternative (Rufus)..."
            Write-Host ""
            # Ne pas faire return, continuer vers Rufus
            $OscdimgPath = $null
        }
    } else {
        Write-Host " ✗" -ForegroundColor Red
        Write-Host ""
        Write-ColorOutput Yellow "⚠ oscdimg.exe non trouvé (nécessite Windows ADK)"
        Write-Host ""
        
        # Proposition de téléchargement et installation d'ADK
        Write-Host "╔═══════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
        Write-Host "║ " -NoNewline -ForegroundColor Cyan
        Write-Host "INSTALLER WINDOWS ADK (RECOMMANDÉ)" -NoNewline -ForegroundColor White
        Write-Host "                       ║" -ForegroundColor Cyan
        Write-Host "╚═══════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "Windows ADK contient oscdimg.exe pour créer des fichiers .ISO" -ForegroundColor White
        Write-Host ""
        Write-Host "📊 Informations :" -ForegroundColor Yellow
        Write-Host "  • Taille du téléchargement : ~2 MB (installateur)" -ForegroundColor Gray
        Write-Host "  • Installation (Deployment Tools uniquement) : ~200 MB" -ForegroundColor Gray
        Write-Host "  • Temps d'installation : ~5 minutes" -ForegroundColor Gray
        Write-Host "  • Source : Microsoft (officiel et gratuit)" -ForegroundColor Gray
        Write-Host ""
        
        $InstallADK = Read-Host "Voulez-vous télécharger et installer Windows ADK maintenant ? (O/N)"
        
        if ($InstallADK -eq "O" -or $InstallADK -eq "o") {
            Write-Host ""
            Write-Host "╔═══════════════════════════════════════════════════════════╗" -ForegroundColor Green
            Write-Host "║ " -NoNewline -ForegroundColor Green
            Write-Host "TÉLÉCHARGEMENT ET INSTALLATION DE WINDOWS ADK" -NoNewline -ForegroundColor White
            Write-Host "            ║" -ForegroundColor Green
            Write-Host "╚═══════════════════════════════════════════════════════════╝" -ForegroundColor Green
            Write-Host ""
            
            # Téléchargement de l'installateur ADK
            $ADKSetupURL = "https://go.microsoft.com/fwlink/?linkid=2243390"
            $ADKSetupPath = "$env:TEMP\adksetup.exe"
            
            Write-Host "  Étape 1/2 : Téléchargement de adksetup.exe..." -ForegroundColor Cyan
            Write-Host "              (Cela peut prendre 1-2 minutes)" -ForegroundColor Gray
            Write-Host ""
            
            try {
                # Téléchargement avec progression
                $ProgressPreference = 'SilentlyContinue'
                Invoke-WebRequest -Uri $ADKSetupURL -OutFile $ADKSetupPath -UseBasicParsing
                $ProgressPreference = 'Continue'
                
                Write-Host "  ✓ Téléchargement terminé" -ForegroundColor Green
                Write-Host ""
                Write-Host "  Étape 2/2 : Lancement de l'installation..." -ForegroundColor Cyan
                Write-Host ""
                Write-Host "╔═══════════════════════════════════════════════════════════╗" -ForegroundColor Yellow
                Write-Host "║ " -NoNewline -ForegroundColor Yellow
                Write-Host "⚠️  INSTRUCTIONS IMPORTANTES" -NoNewline -ForegroundColor White
                Write-Host "                              ║" -ForegroundColor Yellow
                Write-Host "╚═══════════════════════════════════════════════════════════╝" -ForegroundColor Yellow
                Write-Host ""
                Write-Host "  Dans la fenêtre d'installation qui va s'ouvrir :" -ForegroundColor White
                Write-Host ""
                Write-Host "  1️⃣  Cliquez sur 'Next' à l'écran de bienvenue" -ForegroundColor Cyan
                Write-Host ""
                Write-Host "  2️⃣  Acceptez la licence (Accept)" -ForegroundColor Cyan
                Write-Host ""
                Write-Host "  3️⃣  IMPORTANT - Sélection des composants :" -ForegroundColor Cyan
                Write-Host "     🔲 DÉCOCHEZ TOUT" -ForegroundColor Red
                Write-Host "     ☑️  Cochez UNIQUEMENT : " -NoNewline -ForegroundColor Green
                Write-Host "'Deployment Tools'" -ForegroundColor Yellow
                Write-Host ""
                Write-Host "  4️⃣  Cliquez sur 'Install' et attendez (~5 min)" -ForegroundColor Cyan
                Write-Host ""
                Write-Host "  5️⃣  Fermez l'installateur une fois terminé" -ForegroundColor Cyan
                Write-Host ""
                Write-Host "  6️⃣  Revenez ici et relancez la création de l'ISO" -ForegroundColor Cyan
                Write-Host ""
                Write-Host "════════════════════════════════════════════════════════════" -ForegroundColor Gray
                Write-Host ""
                
                $LaunchSetup = Read-Host "Lancer l'installateur maintenant ? (O/N)"
                
                if ($LaunchSetup -eq "O" -or $LaunchSetup -eq "o") {
                    Write-Host ""
                    Write-Host "  Lancement de l'installateur ADK..." -ForegroundColor Cyan
                    Write-Host "  (Une fenêtre va s'ouvrir)" -ForegroundColor Gray
                    Write-Host ""
                    
                    Start-Process -FilePath $ADKSetupPath -Wait
                    
                    Write-Host ""
                    Write-ColorOutput Green "✓ Installation terminée"
                    Write-Host ""
                    Write-Host "  Vérification de l'installation..." -NoNewline
                    
                    # Re-vérifier si oscdimg est maintenant disponible
                    $OscdimgPath = $null
                    foreach ($Path in $OscdimgPaths) {
                        if (Test-Path $Path) {
                            $OscdimgPath = $Path
                            break
                        }
                    }
                    
                    if ($OscdimgPath) {
                        Write-Host " ✓" -ForegroundColor Green
                        Write-Host ""
                        Write-ColorOutput Green "🎉 oscdimg.exe est maintenant installé !"
                        Write-Host ""
                        Write-Host "  Relançons la création de l'ISO..." -ForegroundColor Cyan
                        Start-Sleep -Seconds 2
                        Start-CreateISO
                        return
                    } else {
                        Write-Host " ⚠" -ForegroundColor Yellow
                        Write-Host ""
                        Write-ColorOutput Yellow "⚠ oscdimg.exe n'a pas été trouvé après l'installation"
                        Write-Host ""
                        Write-Host "Vérifiez que vous avez bien coché 'Deployment Tools'" -ForegroundColor Yellow
                        Write-Host "Vous pouvez relancer l'installateur : $ADKSetupPath" -ForegroundColor Gray
                    }
                } else {
                    Write-Host ""
                    Write-ColorOutput Yellow "→ Installation annulée"
                    Write-Host ""
                    Write-Host "  L'installateur est téléchargé ici : $ADKSetupPath" -ForegroundColor Gray
                    Write-Host "  Vous pouvez l'exécuter plus tard." -ForegroundColor Gray
                }
                
            } catch {
                Write-Host ""
                Write-ColorOutput Red "✗ Erreur lors du téléchargement : $_"
                Write-Host ""
                Write-Host "Téléchargez manuellement depuis :" -ForegroundColor Yellow
                Write-Host "  → https://go.microsoft.com/fwlink/?linkid=2243390" -ForegroundColor Cyan
            }
            
            Write-Host ""
        }
    }
    
    # Si oscdimg a réussi, proposer d'ouvrir le dossier et terminer
    if ($OscdimgPath -and (Test-Path $Global:OutputISO)) {
        $OpenFolder = Read-Host "Ouvrir le dossier contenant l'ISO ? (O/N)"
        if ($OpenFolder -eq "O" -or $OpenFolder -eq "o") {
            Start-Process explorer.exe -ArgumentList "/select,`"$Global:OutputISO`""
        }
        Write-Host ""
        pause
        return
    }
    
    # PRIORITÉ 2: Si oscdimg échoue ou n'est pas disponible, proposer Rufus pour créer une clé USB
    Write-Host "╔═══════════════════════════════════════════════════════════╗" -ForegroundColor Yellow
    Write-Host "║ " -NoNewline -ForegroundColor Yellow
    Write-Host "Méthode alternative : Créer une clé USB bootable" -NoNewline -ForegroundColor White
    Write-Host "           ║" -ForegroundColor Yellow
    Write-Host "╚═══════════════════════════════════════════════════════════╝" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  Recherche de Rufus..." -NoNewline
    
    # Chercher d'abord dans le dossier du projet (n'importe quelle version)
    $RufusPath = $null
    $RufusFiles = Get-ChildItem -Path $Global:ISOPath -Filter "rufus*.exe" -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($RufusFiles) {
        $RufusPath = $RufusFiles.FullName
    }
    
    # Si pas trouvé, chercher dans les emplacements standards
    if (-not $RufusPath) {
        $RufusPaths = @(
            "$env:USERPROFILE\Downloads",
            "$env:USERPROFILE\Desktop",
            "C:\Tools",
            "C:\"
        )
        
        foreach ($SearchPath in $RufusPaths) {
            if (Test-Path $SearchPath) {
                $Found = Get-ChildItem -Path $SearchPath -Filter "rufus*.exe" -ErrorAction SilentlyContinue | Select-Object -First 1
                if ($Found) {
                    $RufusPath = $Found.FullName
                    break
                }
            }
        }
    }
    
    # Si toujours pas trouvé, recherche globale sur tous les lecteurs (peut être long)
    if (-not $RufusPath) {
        Write-Host "" # Nouvelle ligne
        Write-Host "  Recherche approfondie sur tous les lecteurs..." -ForegroundColor Yellow
        
        $Drives = Get-PSDrive -PSProvider FileSystem | Where-Object { $_.Used -ne $null }
        foreach ($Drive in $Drives) {
            try {
                $Found = Get-ChildItem -Path "$($Drive.Root)" -Filter "rufus*.exe" -Recurse -ErrorAction SilentlyContinue -Depth 3 | Select-Object -First 1
                if ($Found) {
                    $RufusPath = $Found.FullName
                    break
                }
            } catch {
                # Ignorer les erreurs d'accès
                continue
            }
        }
        
        if ($RufusPath) {
            Write-Host "  Trouvé dans: $(Split-Path $RufusPath)" -ForegroundColor Gray
        }
    }
    
    if ($RufusPath) {
        if (-not (Get-Host).UI.RawUI.CursorPosition.X -eq 0) {
            Write-Host " ✓" -ForegroundColor Green
        } else {
            Write-Host "  ✓ Rufus trouvé" -ForegroundColor Green
        }
        Write-Host "  Fichier: $(Split-Path $RufusPath -Leaf)" -ForegroundColor Gray
        Write-Host "  Chemin: $RufusPath" -ForegroundColor Gray
        Write-Host ""
        
        # Utilisation de Rufus pour créer une clé USB
        Write-ColorOutput Cyan "Rufus peut créer une clé USB bootable directement"
        Write-Host ""
        Write-Host "Instructions :" -ForegroundColor White
        Write-Host "  1. Insérez votre clé USB (8 GB minimum)" -ForegroundColor Cyan
        Write-Host "  2. Dans Rufus, cliquez sur 'SÉLECTION'" -ForegroundColor Cyan
        Write-Host "  3. Sélectionnez le fichier:" -ForegroundColor Cyan
        Write-Host "     📁 $Global:CustomISODir\sources\install.wim" -ForegroundColor Yellow
        Write-Host "  4. Choisissez GPT+UEFI (PC récents) ou MBR+BIOS (anciens PC)" -ForegroundColor Cyan
        Write-Host "  5. Cliquez sur 'DÉMARRER'" -ForegroundColor Cyan
        Write-Host ""
        
        $Confirm = Read-Host "Lancer Rufus pour créer une clé USB bootable ? (O/N)"
        if ($Confirm -eq "O" -or $Confirm -eq "o") {
            Write-Host ""
            Write-Host "  Lancement de Rufus..." -ForegroundColor Cyan
            Start-Process -FilePath $RufusPath
            Write-Host ""
            Write-ColorOutput Green "✓ Rufus lancé"
            Write-Host ""
            Write-Host "  Sélectionnez install.wim dans: $Global:CustomISODir\sources\" -ForegroundColor Gray
        }
        Write-Host ""
        pause
        return
    }
    
    Write-Host " ✗" -ForegroundColor Red
    Write-Host ""
    
    # Aucune solution trouvée
    Write-ColorOutput Red "✗ Aucun outil de création d'ISO/USB disponible"
    Write-Host ""
    Write-Host "╔═══════════════════════════════════════════════════════════╗" -ForegroundColor Yellow
    Write-Host "║ " -NoNewline -ForegroundColor Yellow
    Write-Host "SOLUTIONS POSSIBLES" -NoNewline -ForegroundColor White
    Write-Host "                                         ║" -ForegroundColor Yellow
    Write-Host "╚═══════════════════════════════════════════════════════════╝" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Option 1 : Installer Windows ADK (pour créer un fichier .ISO)" -ForegroundColor Cyan
    Write-Host "  • Téléchargez Windows ADK :" -ForegroundColor White
    Write-Host "    → https://go.microsoft.com/fwlink/?linkid=2243390" -ForegroundColor Gray
    Write-Host "  • Lors de l'installation, sélectionnez uniquement:" -ForegroundColor White
    Write-Host "    → 'Deployment Tools' (environ 200 MB)" -ForegroundColor Gray
    Write-Host "  • Relancez ce script après l'installation" -ForegroundColor White
    Write-Host ""
    Write-Host "Option 2 : Télécharger Rufus (pour créer une clé USB)" -ForegroundColor Cyan
    Write-Host "  • Téléchargez Rufus :" -ForegroundColor White
    Write-Host "    → https://rufus.ie" -ForegroundColor Gray
    Write-Host "  • Placez rufus.exe dans: $Global:ISOPath" -ForegroundColor White
    Write-Host "  • Relancez ce script" -ForegroundColor White
    Write-Host ""
    Write-Host "Option 3 : Utiliser un logiciel tiers (AnyBurn, ImgBurn, etc.)" -ForegroundColor Cyan
    Write-Host "  • Le dossier contenant tous les fichiers est ici :" -ForegroundColor White
    Write-Host "    📁 $Global:CustomISODir" -ForegroundColor Yellow
    Write-Host ""
    
    $OpenFolder = Read-Host "Ouvrir le dossier CustomISO ? (O/N)"
    if ($OpenFolder -eq "O" -or $OpenFolder -eq "o") {
        Start-Process explorer.exe -ArgumentList "`"$Global:CustomISODir`""
    }
    
    Write-Host ""
    pause
}

# Fonction 6: Restaurer
function Start-Restore {
    $BackupWim = "$Global:WorkDir\install_backup.wim"
    
    if (-not (Test-Path $BackupWim)) {
        Write-ColorOutput Red "✗ Aucune sauvegarde trouvée"
        pause
        return
    }
    
    Write-Host "Sauvegarde trouvée: $BackupWim" -ForegroundColor Green
    $Confirm = Read-Host "Restaurer l'image originale ? (O/N)"
    
    if ($Confirm -eq "O" -or $Confirm -eq "o") {
        Write-Host "  Restauration..." -NoNewline
        Copy-Item $BackupWim $Global:InstallWim -Force
        Write-Host " ✓" -ForegroundColor Green
        Write-ColorOutput Green "✓ Image restaurée"
    }
    
    pause
}

# Fonction 7: Informations
function Show-DetailedInfo {
    Show-Title
    Write-ColorOutput Cyan "📊 INFORMATIONS DÉTAILLÉES"
    Write-Host ""
    
    if (Test-Path $Global:InstallWim) {
        Write-ColorOutput Yellow "Image install.wim:"
        DISM /Get-WimInfo /WimFile:"$Global:InstallWim"
    } else {
        Write-ColorOutput Red "✗ install.wim non trouvé"
    }
    
    Write-Host ""
    pause
}

# Vérification admin
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-ColorOutput Red "ERREUR: Ce script nécessite des droits administrateur!"
    pause
    exit
}

# Boucle principale
while ($true) {
    Show-Menu
    $Choice = Read-Host
    Write-Host "└────────────────────────────────────────────────────────────────────────┘" -ForegroundColor DarkGray
    Write-Host ""
    
    switch ($Choice) {
        "1" { Start-CompleteProcess }
        "2" { Start-ExtractSingleEdition; pause }
        "3" { Start-CustomizeImage; pause }
        "4" { Start-RemoveComponents }
        "5" { Start-Cleanup -KeepISO }
        "6" { Start-CreateISO }
        "7" { Start-Restore }
        "8" { Show-DetailedInfo }
        "0" { 
            Clear-Host
            Show-XpolarisLogo
            Write-Host "╔══════════════════════════════════════════════════════════════════════════╗" -ForegroundColor Green
            Write-Host "║                                                                          ║" -ForegroundColor Green
            Write-Host "║                   ✨ Merci d'avoir utilisé Xpolaris ! ✨                 ║" -ForegroundColor Green
            Write-Host "║                                                                          ║" -ForegroundColor Green
            Write-Host "║                   Edition Personnalisée - Sans Bloatware                 ║" -ForegroundColor Green
            Write-Host "║                                                                          ║" -ForegroundColor Green
            Write-Host "╚══════════════════════════════════════════════════════════════════════════╝" -ForegroundColor Green
            Write-Host ""
            Start-Sleep -Seconds 2
            exit 
        }
        default { 
            Write-Host "  ❌ " -NoNewline -ForegroundColor Red
            Write-Host "Choix invalide - Veuillez entrer un nombre entre 0 et 8" -ForegroundColor Yellow
            Start-Sleep -Seconds 2
        }
    }
}