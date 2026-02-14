# ===================================================================
# XPOLARIS APPS MANAGER - Gestionnaire d'applications universel
# Xpolaris OS - Installation et dépannage automatique
# ===================================================================
# Modes d'utilisation :
#   1. AUTO : Tâche planifiée au 1er démarrage (installation complète)
#   2. INTERACTIF : Double-clic pour dépannage manuel
# ===================================================================

param(
    [switch]$AutoMode,              # Mode automatique (tâche planifiée)
    [switch]$RemoveTasksOnly,       # Mode interactif : Supprimer tâches
    [switch]$InstallAppsOnly,       # Mode interactif : Installer apps
    [switch]$FixBloatwareOnly,      # Mode interactif : Supprimer bloatware
    [switch]$FullFix                # Mode interactif : Tout corriger
)

# Attraper toutes les erreurs pour ne pas fermer la fenêtre
$ErrorActionPreference = "Continue"

# Détecter le mode d'exécution
$IsScheduledTask = $AutoMode -or ($MyInvocation.InvocationName -match "XpolarisInstallApps")

# ===================================================================
# MODE AUTOMATIQUE (Tâche planifiée au 1er démarrage)
# ===================================================================
if ($IsScheduledTask) {
    # Créer un fichier de log
    $LogFile = "C:\InstallApps.log"
    $StartTime = Get-Date

    function Write-Log {
        param([string]$Message)
        $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        "$Timestamp - $Message" | Out-File -FilePath $LogFile -Append -Encoding UTF8
        Write-Host $Message
    }

    Write-Log "============================================"
    Write-Log "INSTALLATION AUTOMATIQUE DES APPLICATIONS"
    Write-Log "Xpolaris OS - Edition Personnalisee"
    Write-Log "============================================"
    Write-Log ""
    Write-Log "[DEBUG] Script demarre depuis: $PSCommandPath"
    Write-Log "[DEBUG] Utilisateur: $env:USERNAME"
    Write-Log ""

    # SUPPRIMER LA TÂCHE PLANIFIÉE IMMÉDIATEMENT (éviter boucle infinie)
    Write-Log "[INIT] Suppression de la tache planifiee pour eviter relancement..."
    try {
        $Task = Get-ScheduledTask -TaskName "XpolarisInstallApps" -ErrorAction SilentlyContinue
        if ($Task) {
            Unregister-ScheduledTask -TaskName "XpolarisInstallApps" -Confirm:$false -ErrorAction Stop
            Write-Log "[OK] Tache planifiee supprimee - Ne se relancera plus"
        }
    } catch {
        Write-Log "[AVERTISSEMENT] Impossible de supprimer la tache : $_"
    }
    Write-Log ""

    # Attendre que Windows soit complètement démarré
    Write-Log "[ATTENTE] Attente initiale de 60 secondes pour demarrage complet..."
    Start-Sleep -Seconds 60

    # Vérifier si winget existe
    $WingetPath = Get-Command winget -ErrorAction SilentlyContinue
    if ($WingetPath) {
        Write-Log "[DEBUG] Winget trouve: $($WingetPath.Source)"
    }

    # Attendre que winget soit disponible
    Write-Log "[ATTENTE] Attente de la disponibilite de winget..."
    Write-Log "[INFO] Cette etape peut prendre 5-10 minutes apres le premier demarrage"

    $MaxWaitMinutes = 15
    $WaitSeconds = 0
    $WingetReady = $false

    while (-not $WingetReady -and $WaitSeconds -lt ($MaxWaitMinutes * 60)) {
        try {
            # Tester si winget est disponible
            $TestResult = winget --version 2>&1
            Write-Log "[DEBUG] Test winget: $TestResult (ExitCode: $LASTEXITCODE)"
            
            if ($LASTEXITCODE -eq 0 -and $TestResult -match "v[\d\.]+") {
                $WingetReady = $true
                Write-Log "[OK] winget est disponible : $TestResult"
            } else {
                Start-Sleep -Seconds 20
                $WaitSeconds += 20
                
                if ($WaitSeconds % 60 -eq 0) {
                    Write-Log "[ATTENTE] Toujours en attente... ($($WaitSeconds / 60) minutes ecoulees)"
                }
            }
        } catch {
            Write-Log "[DEBUG] Exception lors du test winget: $_"
            Start-Sleep -Seconds 20
            $WaitSeconds += 20
            
            if ($WaitSeconds % 60 -eq 0) {
                Write-Log "[ATTENTE] Toujours en attente... ($($WaitSeconds / 60) minutes ecoulees)"
            }
        }
    }

    $SuccessCount = 0
    $FailedCount = 0

    if (-not $WingetReady) {
        Write-Log "[ERREUR] winget n'est pas disponible apres $MaxWaitMinutes minutes d'attente"
        Write-Log "[INFO] Basculement vers installation FALLBACK (telechargement direct)..."
        Write-Log ""
        
        # Installation FALLBACK intégrée
        $FallbackApps = @(
            @{ Name = "Google Chrome"; Url = "https://dl.google.com/chrome/install/latest/chrome_installer.exe"; FileName = "ChromeSetup.exe"; Args = "/silent /install" },
            @{ Name = "7-Zip"; Url = "https://www.7-zip.org/a/7z2408-x64.exe"; FileName = "7z-Setup.exe"; Args = "/S" },
            @{ Name = "VLC Media Player"; Url = "https://get.videolan.org/vlc/3.0.20/win64/vlc-3.0.20-win64.exe"; FileName = "VLC-Setup.exe"; Args = "/L=1036 /S" },
            @{ Name = "Notepad++"; Url = "https://github.com/notepad-plus-plus/notepad-plus-plus/releases/download/v8.6.9/npp.8.6.9.Installer.x64.exe"; FileName = "NotepadPP-Setup.exe"; Args = "/S" },
            @{ Name = "TeamViewer"; Url = "https://download.teamviewer.com/download/TeamViewer_Setup_x64.exe"; FileName = "TeamViewer-Setup.exe"; Args = "/S" }
        )
        
        $DownloadPath = "$env:TEMP\XpolarisApps"
        if (-not (Test-Path $DownloadPath)) { New-Item -ItemType Directory -Path $DownloadPath -Force | Out-Null }
        
        Write-Log "[INFO] Telechargement et installation directe..."
        foreach ($App in $FallbackApps) {
            Write-Log "[FALLBACK] $($App.Name)..."
            try {
                $OutputFile = Join-Path $DownloadPath $App.FileName
                $ProgressPreference = 'SilentlyContinue'
                Invoke-WebRequest -Uri $App.Url -OutFile $OutputFile -UseBasicParsing -TimeoutSec 300 -ErrorAction Stop
                $Process = Start-Process -FilePath $OutputFile -ArgumentList $App.Args -Wait -PassThru -NoNewWindow -ErrorAction Stop
                if ($Process.ExitCode -eq 0 -or $Process.ExitCode -eq 3010) {
                    Write-Log "  [OK] $($App.Name) installe"
                    $SuccessCount++
                } else {
                    Write-Log "  [ERREUR] Code: $($Process.ExitCode)"
                    $FailedCount++
                }
                Remove-Item $OutputFile -Force -ErrorAction SilentlyContinue
            } catch {
                Write-Log "  [ERREUR] $_"
                $FailedCount++
            }
            Start-Sleep -Seconds 3
        }
        
        Write-Log ""
        Write-Log "[INFO] FALLBACK termine - Succes: $SuccessCount | Echecs: $FailedCount"
        Write-Log ""
    } else {
        # winget est disponible, installation normale
        Write-Log "[INFO] Attente supplementaire de 30 secondes pour stabilisation..."
        Start-Sleep -Seconds 30
        
        # Liste des applications à installer
        $Apps = @(
            @{ Name = "Google Chrome"; Id = "Google.Chrome"; Icon = "[WEB]" },
            @{ Name = "7-Zip"; Id = "7zip.7zip"; Icon = "[7Z]" },
            @{ Name = "VLC Media Player"; Id = "VideoLAN.VLC"; Icon = "[VLC]" },
            @{ Name = "Notepad++"; Id = "Notepad++.Notepad++"; Icon = "[NPP]" },
            @{ Name = "TeamViewer"; Id = "TeamViewer.TeamViewer"; Icon = "[TV]" },
            @{ Name = "Virtual CloneDrive"; Id = "ElaborateBytes.VirtualCloneDrive"; Icon = "[VCD]" }
        )
        
        Write-Log ""
        Write-Log "[INFO] Installation de $($Apps.Count) applications..."
        Write-Log ""
        
        foreach ($App in $Apps) {
            Write-Log "[$($App.Icon)] Installation de $($App.Name)..."
            
            try {
                $Result = winget install --id $App.Id --silent --accept-package-agreements --accept-source-agreements 2>&1
                
                if ($LASTEXITCODE -eq 0) {
                    Write-Log "    [OK] $($App.Name) installe avec succes"
                    $SuccessCount++
                } else {
                    Write-Log "    [ERREUR] Echec installation $($App.Name) - Code: $LASTEXITCODE"
                    Write-Log "    Details: $Result"
                    $FailedCount++
                }
            } catch {
                Write-Log "    [ERREUR] Exception lors de l'installation de $($App.Name) : $_"
                $FailedCount++
            }
            
            Start-Sleep -Seconds 5
        }
    }

    $EndTime = Get-Date
    $Duration = ($EndTime - $StartTime).TotalMinutes

    Write-Log ""
    Write-Log "============================================"
    Write-Log "INSTALLATION TERMINEE"
    Write-Log "============================================"
    Write-Log "Applications installees : $SuccessCount"
    Write-Log "Echecs : $FailedCount"
    Write-Log "Duree totale : $([math]::Round($Duration, 2)) minutes"
    Write-Log ""

    # VERIFICATION RAPIDE DES BLOATWARES
    Write-Log "--------------------------------------------"
    Write-Log "VERIFICATION BLOATWARE"
    Write-Log "--------------------------------------------"

    $BloatwareCheck = @(
        @{ Name = "Xbox"; Pattern = "*Xbox*" },
        @{ Name = "Teams"; Pattern = "*Teams*" },
        @{ Name = "OneDrive"; Pattern = "*OneDrive*" }
    )

    $BloatwareFound = 0
    foreach ($Bloat in $BloatwareCheck) {
        $Found = Get-AppxPackage -AllUsers -Name $Bloat.Pattern -ErrorAction SilentlyContinue
        if ($Found) {
            Write-Log "[AVERTISSEMENT] $($Bloat.Name) encore present - Verifiez RemoveBloatware.log"
            $BloatwareFound++
        } else {
            Write-Log "[OK] $($Bloat.Name) supprime"
        }
    }

    if ($BloatwareFound -eq 0) {
        Write-Log "[OK] Tous les bloatwares ont ete supprimes"
    }

    Write-Log ""
    Write-Log "[INFO] Log complet disponible : $LogFile"
    Write-Log ""

    # Créer une notification (si possible)
    try {
        $Notification = "Installation terminee : $SuccessCount apps installees"
        if ($FailedCount -gt 0) {
            $Notification += " ($FailedCount echecs)"
        }
        if ($BloatwareFound -gt 0) {
            $Notification += "`n$BloatwareFound bloatware(s) encore present(s)"
        }
        
        Add-Type -AssemblyName System.Windows.Forms
        $IconType = if ($FailedCount -gt 0 -or $BloatwareFound -gt 0) { [System.Windows.Forms.MessageBoxIcon]::Warning } else { [System.Windows.Forms.MessageBoxIcon]::Information }
        $null = [System.Windows.Forms.MessageBox]::Show($Notification, "Xpolaris - Installation Apps", [System.Windows.Forms.MessageBoxButtons]::OK, $IconType)
    } catch {
        Write-Log "[INFO] Impossible d'afficher la notification : $_"
    }

    Write-Log ""
    Write-Log "[INFO] Script termine - Mode AUTO"
    Write-Log ""

    exit 0
}

# ===================================================================
# MODE INTERACTIF (Double-clic pour dépannage)
# ===================================================================

# Si lancé avec double-clic, forcer l'élévation admin
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    try {
        Write-Host "Demande d'elevation administrateur..." -ForegroundColor Yellow
        Start-Process powershell.exe "-ExecutionPolicy Bypass -NoProfile -File `"$PSCommandPath`"" -Verb RunAs
        exit 0
    } catch {
        Write-Host "`n[ERREUR] Impossible d'obtenir les droits administrateur !" -ForegroundColor Red
        Write-Host "Faites clic-droit > 'Executer en tant qu'administrateur'`n" -ForegroundColor Yellow
        Read-Host "Appuyez sur Entree pour quitter"
        exit 1
    }
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  XPOLARIS APPS MANAGER" -ForegroundColor White
Write-Host "  Gestionnaire et depannage" -ForegroundColor Gray
Write-Host "========================================`n" -ForegroundColor Cyan

Write-Host "[OK] Droits administrateur obtenus`n" -ForegroundColor Green

# Si aucun paramètre, mode interactif
if (-not ($RemoveTasksOnly -or $InstallAppsOnly -or $FixBloatwareOnly -or $FullFix)) {
    Write-Host "Que voulez-vous faire ?`n" -ForegroundColor Yellow
    Write-Host "  [1] Supprimer taches planifiees (arreter boucle au demarrage)" -ForegroundColor White
    Write-Host "  [2] Installer applications manquantes" -ForegroundColor White
    Write-Host "  [3] Supprimer bloatware restant (Xbox, Teams, OneDrive)" -ForegroundColor White
    Write-Host "  [4] TOUT CORRIGER (recommande)" -ForegroundColor Green
    Write-Host "  [5] Quitter`n" -ForegroundColor Gray
    
    $Choice = Read-Host "Votre choix (1-5)"
    
    switch ($Choice) {
        "1" { $RemoveTasksOnly = $true }
        "2" { $InstallAppsOnly = $true }
        "3" { $FixBloatwareOnly = $true }
        "4" { $FullFix = $true }
        "5" { exit 0 }
        default { 
            Write-Host "`n[ERREUR] Choix invalide !`n" -ForegroundColor Red
            Read-Host "Appuyez sur Entree pour quitter"
            exit 1
        }
    }
    Write-Host ""
}

$StepNumber = 1

# ============================================
# ÉTAPE 1 : Supprimer tâches planifiées
# ============================================
if ($RemoveTasksOnly -or $FullFix) {
    Write-Host "[$StepNumber] Suppression taches planifiees...`n" -ForegroundColor Yellow
    
    $Tasks = @("XpolarisInstallApps", "XpolarisApplyWallpaper")
    
    foreach ($TaskName in $Tasks) {
        try {
            $Task = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
            if ($Task) {
                Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false -ErrorAction Stop
                Write-Host "  [OK] $TaskName supprimee" -ForegroundColor Green
            } else {
                Write-Host "  [INFO] $TaskName deja supprimee" -ForegroundColor Gray
            }
        } catch {
            Write-Host "  [ERREUR] $TaskName : $_" -ForegroundColor Red
        }
    }
    
    Write-Host "`n[OK] Taches planifiees desactivees`n" -ForegroundColor Green
    $StepNumber++
}

# ============================================
# ÉTAPE 2 : Installer applications manquantes
# ============================================
if ($InstallAppsOnly -or $FullFix) {
    Write-Host "[$StepNumber] Installation applications manquantes...`n" -ForegroundColor Yellow
    
    # Liste complète des applications
    $AllApps = @(
        @{ Name = "Google Chrome"; Id = "Google.Chrome"; Pattern = "*Chrome*"; Url = "https://dl.google.com/chrome/install/latest/chrome_installer.exe"; Args = "/silent /install" },
        @{ Name = "7-Zip"; Id = "7zip.7zip"; Pattern = "*7-Zip*"; Url = "https://www.7-zip.org/a/7z2408-x64.exe"; Args = "/S" },
        @{ Name = "VLC Media Player"; Id = "VideoLAN.VLC"; Pattern = "*VLC*"; Url = "https://get.videolan.org/vlc/3.0.20/win64/vlc-3.0.20-win64.exe"; Args = "/L=1036 /S" },
        @{ Name = "Notepad++"; Id = "Notepad++.Notepad++"; Pattern = "*Notepad++*"; Url = "https://github.com/notepad-plus-plus/notepad-plus-plus/releases/download/v8.6.9/npp.8.6.9.Installer.x64.exe"; Args = "/S" },
        @{ Name = "TeamViewer"; Id = "TeamViewer.TeamViewer"; Pattern = "*TeamViewer*"; Url = "https://download.teamviewer.com/download/TeamViewer_Setup_x64.exe"; Args = "/S" },
        @{ Name = "Virtual CloneDrive"; Id = "ElaborateBytes.VirtualCloneDrive"; Pattern = "*Virtual*CloneDrive*"; Url = $null; Args = $null }
    )
    
    $InstalledCount = 0
    $SkippedCount = 0
    
    foreach ($App in $AllApps) {
        # Vérifier si déjà installé
        $Installed = Get-ItemProperty "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*", 
                                        "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*" -ErrorAction SilentlyContinue |
                     Where-Object { $_.DisplayName -like $App.Pattern }
        
        if ($Installed) {
            Write-Host "  [OK] $($App.Name) deja installe" -ForegroundColor Green
            $SkippedCount++
            continue
        }
        
        Write-Host "  Installation de $($App.Name)..." -ForegroundColor Cyan
        
        # Essayer d'abord avec winget
        $WingetAvailable = Get-Command winget -ErrorAction SilentlyContinue
        $InstallSuccess = $false
        
        if ($WingetAvailable) {
            try {
                Write-Host "    - Tentative via winget..." -ForegroundColor Gray
                $Result = winget install --id $App.Id --silent --accept-package-agreements --accept-source-agreements 2>&1
                
                if ($LASTEXITCODE -eq 0) {
                    Write-Host "  [OK] $($App.Name) installe avec succes (winget)`n" -ForegroundColor Green
                    $InstallSuccess = $true
                    $InstalledCount++
                } else {
                    throw "Winget echec, tentative telechargement direct..."
                }
            } catch {
                Write-Host "    - Winget echec, telechargement direct..." -ForegroundColor Yellow
                $WingetAvailable = $false
            }
        }
        
        # Si winget échoue ou indisponible ET que l'URL existe, téléchargement direct
        if (-not $InstallSuccess -and $App.Url) {
            try {
                $DownloadPath = "$env:TEMP\XpolarisApps"
                if (-not (Test-Path $DownloadPath)) {
                    New-Item -ItemType Directory -Path $DownloadPath -Force | Out-Null
                }
                
                $FileName = "$($App.Name -replace ' ', '')-Setup.exe"
                $Installer = Join-Path $DownloadPath $FileName
                
                Write-Host "    - Telechargement..." -ForegroundColor Gray
                $ProgressPreference = 'SilentlyContinue'
                Invoke-WebRequest -Uri $App.Url -OutFile $Installer -UseBasicParsing -TimeoutSec 300 -ErrorAction Stop
                
                Write-Host "    - Installation..." -ForegroundColor Gray
                $Process = Start-Process -FilePath $Installer -ArgumentList $App.Args -Wait -PassThru -NoNewWindow -ErrorAction Stop
                
                if ($Process.ExitCode -eq 0 -or $Process.ExitCode -eq 3010) {
                    Write-Host "  [OK] $($App.Name) installe avec succes`n" -ForegroundColor Green
                    $InstalledCount++
                } else {
                    Write-Host "  [AVERTISSEMENT] $($App.Name) Code retour: $($Process.ExitCode)`n" -ForegroundColor Yellow
                }
                
                Remove-Item $Installer -Force -ErrorAction SilentlyContinue
                
            } catch {
                Write-Host "  [ERREUR] Impossible d'installer $($App.Name): $_`n" -ForegroundColor Red
            }
        } elseif (-not $InstallSuccess) {
            Write-Host "  [INFO] Aucune source de telechargement disponible pour $($App.Name)`n" -ForegroundColor Gray
        }
        
        Start-Sleep -Seconds 2
    }
    
    Write-Host "Resultat : $InstalledCount nouvelles installations | $SkippedCount deja presentes`n" -ForegroundColor Cyan
    $StepNumber++
}

# ============================================
# ÉTAPE 3 : Supprimer bloatware restant
# ============================================
if ($FixBloatwareOnly -or $FullFix) {
    Write-Host "[$StepNumber] Suppression bloatware restant...`n" -ForegroundColor Yellow
    
    # Arrêter les services Xbox avant suppression (évite erreur 0x80070032)
    Write-Host "  - Arret services Xbox..." -ForegroundColor Gray
    $XboxServices = @("XblAuthManager", "XblGameSave", "XboxGipSvc", "XboxNetApiSvc")
    foreach ($Service in $XboxServices) {
        try {
            Stop-Service -Name $Service -Force -ErrorAction SilentlyContinue
            Set-Service -Name $Service -StartupType Disabled -ErrorAction SilentlyContinue
        } catch { }
    }
    
    $BloatwarePatterns = @("*Xbox*", "*Teams*", "*OneDrive*")
    $RemovedCount = 0
    
    foreach ($Pattern in $BloatwarePatterns) {
        $Apps = Get-AppxPackage -AllUsers -Name $Pattern -ErrorAction SilentlyContinue
        
        if ($Apps) {
            foreach ($App in $Apps) {
                try {
                    Write-Host "  - Suppression: $($App.Name)" -ForegroundColor Gray
                    
                    Remove-AppxPackage -Package $App.PackageFullName -AllUsers -ErrorAction Stop
                    Write-Host "    [OK] Supprime" -ForegroundColor Green
                    $RemovedCount++
                } catch {
                    if ($_.Exception.Message -match "0x80070032") {
                        Write-Host "    [AVERTISSEMENT] Package en cours d'utilisation" -ForegroundColor Yellow
                        Write-Host "    [INFO] Sera supprime au prochain redemarrage" -ForegroundColor Gray
                    } else {
                        Write-Host "    [ERREUR] $_" -ForegroundColor Red
                    }
                }
            }
        }
    }
    
    if ($RemovedCount -eq 0) {
        Write-Host "  [OK] Aucun bloatware trouve`n" -ForegroundColor Green
    } else {
        Write-Host "`n  [OK] $RemovedCount bloatware(s) supprime(s)`n" -ForegroundColor Green
    }
    
    $StepNumber++
}

# ============================================
# RÉSUMÉ FINAL
# ============================================
Write-Host "========================================" -ForegroundColor Green
Write-Host "  CORRECTIONS TERMINEES" -ForegroundColor White
Write-Host "========================================`n" -ForegroundColor Green

Write-Host "Verification finale...`n" -ForegroundColor Cyan

# Applications installées
Write-Host "APPLICATIONS INSTALLEES :" -ForegroundColor White
$AppsCheck = @(
    @{ Name = "Google Chrome"; Pattern = "*Chrome*" },
    @{ Name = "7-Zip"; Pattern = "*7-Zip*" },
    @{ Name = "VLC Media Player"; Pattern = "*VLC*" },
    @{ Name = "Notepad++"; Pattern = "*Notepad++*" },
    @{ Name = "TeamViewer"; Pattern = "*TeamViewer*" },
    @{ Name = "Virtual CloneDrive"; Pattern = "*Virtual*CloneDrive*" }
)

foreach ($App in $AppsCheck) {
    $Installed = Get-ItemProperty "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*", 
                                    "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*" -ErrorAction SilentlyContinue |
                 Where-Object { $_.DisplayName -like $App.Pattern }
    
    if ($Installed) {
        Write-Host "  [OK] $($App.Name)" -ForegroundColor Green
    } else {
        Write-Host "  [X]  $($App.Name) - NON INSTALLE" -ForegroundColor Red
    }
}

# Bloatware
Write-Host "`nBLOATWARE SUPPRIME :" -ForegroundColor White
$BloatwareCheck = @(
    @{ Name = "Xbox"; Pattern = "*Xbox*" },
    @{ Name = "Teams"; Pattern = "*Teams*" },
    @{ Name = "OneDrive"; Pattern = "*OneDrive*" }
)

foreach ($Bloat in $BloatwareCheck) {
    $Found = Get-AppxPackage -AllUsers -Name $Bloat.Pattern -ErrorAction SilentlyContinue
    
    if ($Found) {
        Write-Host "  [!] $($Bloat.Name) - ENCORE PRESENT" -ForegroundColor Yellow
    } else {
        Write-Host "  [OK] $($Bloat.Name)" -ForegroundColor Green
    }
}

# Tâches planifiées
Write-Host "`nTACHES PLANIFIEES :" -ForegroundColor White
$TasksCheck = @("XpolarisInstallApps", "XpolarisApplyWallpaper")
foreach ($TaskName in $TasksCheck) {
    $Task = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
    if ($Task) {
        Write-Host "  [!] $TaskName - ENCORE ACTIVE" -ForegroundColor Yellow
    } else {
        Write-Host "  [OK] $TaskName - Supprimee" -ForegroundColor Green
    }
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Prochaines etapes :" -ForegroundColor White
Write-Host "  1. Redemarrez Windows" -ForegroundColor Gray
Write-Host "  2. Plus de fenetre DOS au demarrage !" -ForegroundColor Gray
Write-Host "  3. Profitez de votre Windows personnalise" -ForegroundColor Gray
Write-Host "========================================`n" -ForegroundColor Cyan

Write-Host "Script termine avec succes !`n" -ForegroundColor Green
Read-Host "Appuyez sur Entree pour fermer"
exit 0
