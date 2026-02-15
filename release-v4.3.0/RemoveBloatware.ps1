# ===================================================================
# Script de suppression complète du bloatware Windows 11
# Xpolaris OS - Edition Personnalisée
# ===================================================================

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  SUPPRESSION BLOATWARE WINDOWS 11" -ForegroundColor White
Write-Host "  Xpolaris OS - Post-Installation" -ForegroundColor Gray
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Liste complète des applications à supprimer (plus aggressive)
$BloatwareApps = @(
    # Xbox et Gaming (PRIORITAIRE)
    "*Xbox*",
    "*Microsoft.GamingApp*",
    "*Microsoft.XboxGameOverlay*",
    "*Microsoft.XboxGamingOverlay*",
    "*Microsoft.XboxIdentityProvider*",
    "*Microsoft.XboxSpeechToTextOverlay*",
    "*Microsoft.GamingServices*",
    
    # Microsoft Teams (PRIORITAIRE)
    "*Teams*",
    "*MicrosoftTeams*",
    
    # OneDrive (PRIORITAIRE)
    "*OneDrive*",
    "*Microsoft.OneDrive*",
    
    # Microsoft Store Apps
    "*BingNews*",
    "*BingWeather*",
    "*BingFinance*",
    "*BingSports*",
    "*Clipchamp*",
    "*Todos*",
    "*PowerAutomate*",
    "*LinkedIn*",
    
    # Communication et Social
    "*YourPhone*",
    "*WindowsPhone*",
    "*People*",
    "*SkypeApp*",
    
    # Divertissement
    "*ZuneMusic*",
    "*ZuneVideo*",
    "*WindowsAlarms*",
    "*WindowsSoundRecorder*",
    "*MicrosoftSolitaire*",
    
    # Productivité inutile
    "*GetHelp*",
    "*Getstarted*",
    "*MicrosoftOfficeHub*",
    "*WindowsFeedbackHub*",
    "*WindowsMaps*",
    "*WindowsCommunicationsApps*",
    
    # 3D et Mixed Reality
    "*3DViewer*",
    "*MixedReality*",
    "*Paint3D*",
    
    # Autres
    "*Wallet*",
    "*Messaging*"
)

Write-Host "[1/3] Suppression des AppxPackage (tous utilisateurs)..." -ForegroundColor Yellow
$RemovedCount = 0

foreach ($App in $BloatwareApps) {
    $Packages = Get-AppxPackage -AllUsers -Name $App -ErrorAction SilentlyContinue
    
    foreach ($Package in $Packages) {
        try {
            Write-Host "  - Suppression: $($Package.Name)" -ForegroundColor Gray
            Remove-AppxPackage -Package $Package.PackageFullName -AllUsers -ErrorAction Stop
            $RemovedCount++
        } catch {
            Write-Host "    ERREUR: $_" -ForegroundColor Red
        }
    }
}

Write-Host "  [OK] $RemovedCount package(s) supprime(s)" -ForegroundColor Green
Write-Host ""

Write-Host "[2/3] Suppression des AppxProvisionedPackage..." -ForegroundColor Yellow
$ProvisionedCount = 0

foreach ($App in $BloatwareApps) {
    $ProvisionedPackages = Get-AppxProvisionedPackage -Online | Where-Object { $_.DisplayName -like $App }
    
    foreach ($Package in $ProvisionedPackages) {
        try {
            Write-Host "  - Suppression: $($Package.DisplayName)" -ForegroundColor Gray
            Remove-AppxProvisionedPackage -Online -PackageName $Package.PackageName -ErrorAction Stop | Out-Null
            $ProvisionedCount++
        } catch {
            Write-Host "    ERREUR: $_" -ForegroundColor Red
        }
    }
}

Write-Host "  [OK] $ProvisionedCount package(s) provisionne(s) supprime(s)" -ForegroundColor Green
Write-Host ""

Write-Host "[3/5] Désactivation services Xbox et OneDrive..." -ForegroundColor Yellow

# Désactiver services Xbox
$XboxServices = @(
    "XblAuthManager",
    "XblGameSave",
    "XboxGipSvc",
    "XboxNetApiSvc"
)

foreach ($Service in $XboxServices) {
    try {
        $ServiceObj = Get-Service -Name $Service -ErrorAction SilentlyContinue
        if ($ServiceObj) {
            Write-Host "  - Désactivation: $Service" -ForegroundColor Gray
            Stop-Service -Name $Service -Force -ErrorAction SilentlyContinue
            Set-Service -Name $Service -StartupType Disabled -ErrorAction SilentlyContinue
        }
    } catch {
        # Service n'existe pas ou déjà désactivé
    }
}

Write-Host "  [OK] Services Xbox desactives" -ForegroundColor Green
Write-Host ""

Write-Host "[4/5] Désinstallation complète OneDrive..." -ForegroundColor Yellow

# Arrêter processus OneDrive
Stop-Process -Name "OneDrive" -Force -ErrorAction SilentlyContinue
Stop-Process -Name "OneDriveSetup" -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2

# Désinstaller OneDrive (32-bit et 64-bit)
$OneDriveUninstall = @(
    "$env:SystemRoot\System32\OneDriveSetup.exe",
    "$env:SystemRoot\SysWOW64\OneDriveSetup.exe"
)

foreach ($UninstallPath in $OneDriveUninstall) {
    if (Test-Path $UninstallPath) {
        Write-Host "  - Désinstallation: $UninstallPath" -ForegroundColor Gray
        Start-Process -FilePath $UninstallPath -ArgumentList "/uninstall" -Wait -NoNewWindow -ErrorAction SilentlyContinue
    }
}

# Supprimer dossiers OneDrive
$OneDriveFolders = @(
    "$env:UserProfile\OneDrive",
    "$env:LocalAppData\Microsoft\OneDrive",
    "$env:ProgramData\Microsoft OneDrive",
    "$env:SystemDrive\OneDriveTemp"
)

foreach ($Folder in $OneDriveFolders) {
    if (Test-Path $Folder) {
        Write-Host "  - Suppression: $Folder" -ForegroundColor Gray
        Remove-Item -Path $Folder -Recurse -Force -ErrorAction SilentlyContinue
    }
}

# Bloquer OneDrive via Registry
try {
    $OneDriveRegPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive"
    if (-not (Test-Path $OneDriveRegPath)) {
        New-Item -Path $OneDriveRegPath -Force | Out-Null
    }
    Set-ItemProperty -Path $OneDriveRegPath -Name "DisableFileSyncNGSC" -Value 1 -Force
    Write-Host "  - Registry: OneDrive bloqué définitivement" -ForegroundColor Gray
} catch {
    Write-Host "    ERREUR Registry OneDrive: $_" -ForegroundColor Red
}

Write-Host "  [OK] OneDrive completement desinstalle" -ForegroundColor Green
Write-Host ""

Write-Host "[5/6] Suppression des raccourcis stub du menu Demarrer..." -ForegroundColor Yellow

# Chemins des raccourcis du menu Démarrer
$StartMenuPaths = @(
    "$env:ProgramData\Microsoft\Windows\Start Menu\Programs",
    "$env:AppData\Microsoft\Windows\Start Menu\Programs",
    "$env:ALLUSERSPROFILE\Microsoft\Windows\Start Menu\Programs"
)

# Noms de raccourcis à supprimer (stubs vers Store)
$StubShortcuts = @(
    "*OneDrive*",
    "*Outlook*",
    "*Solitaire*",
    "*Xbox*",
    "*Teams*",
    "*LinkedIn*",
    "*TikTok*",
    "*Instagram*",
    "*Facebook*",
    "*Clipchamp*",
    "*Spotify*"
)

$ShortcutsRemoved = 0
foreach ($Path in $StartMenuPaths) {
    if (Test-Path $Path) {
        foreach ($Stub in $StubShortcuts) {
            # Supprimer les .lnk classiques
            $Shortcuts = Get-ChildItem -Path $Path -Filter "$Stub.lnk" -Recurse -ErrorAction SilentlyContinue
            foreach ($Shortcut in $Shortcuts) {
                try {
                    Write-Host "  - Suppression raccourci .lnk: $($Shortcut.Name)" -ForegroundColor Gray
                    Remove-Item -Path $Shortcut.FullName -Force -ErrorAction Stop
                    $ShortcutsRemoved++
                } catch {
                    # Ignore les erreurs d'accès
                }
            }
            
            # NOUVEAU: Supprimer aussi les stubs SANS extension (Windows 11)
            $StubFiles = Get-ChildItem -Path $Path -Filter $Stub -Recurse -ErrorAction SilentlyContinue | Where-Object { $_.Extension -eq "" }
            foreach ($StubFile in $StubFiles) {
                try {
                    Write-Host "  - Suppression stub sans extension: $($StubFile.Name)" -ForegroundColor Gray
                    Remove-Item -Path $StubFile.FullName -Force -ErrorAction Stop
                    $ShortcutsRemoved++
                } catch {
                    # Ignore les erreurs d'accès
                }
            }
        }
    }
}

Write-Host "  [OK] $ShortcutsRemoved raccourci(s) supprime(s)" -ForegroundColor Green
Write-Host ""

Write-Host "[6/6] Nettoyage Registry bloatware..." -ForegroundColor Yellow

# Supprimer clés Registry Xbox
$XboxRegKeys = @(
    "HKCU:\Software\Microsoft\GameBar",
    "HKLM:\SOFTWARE\Microsoft\WindowsRuntime\ActivatableClassId\Windows.Gaming.GameBar.PresenceServer.Internal.PresenceWriter"
)

foreach ($RegKey in $XboxRegKeys) {
    if (Test-Path $RegKey) {
        Write-Host "  - Suppression: $RegKey" -ForegroundColor Gray
        Remove-Item -Path $RegKey -Recurse -Force -ErrorAction SilentlyContinue
    }
}

Write-Host "  [OK] Registry nettoye" -ForegroundColor Green
Write-Host ""

Write-Host "========================================" -ForegroundColor Green
Write-Host "  [OK] NETTOYAGE TERMINE AVEC SUCCES" -ForegroundColor White
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Total supprimé: $($RemovedCount + $ProvisionedCount) packages" -ForegroundColor Cyan
Write-Host ""

# Auto-suppression du script après exécution
Start-Sleep -Seconds 3
Remove-Item -Path $MyInvocation.MyCommand.Path -Force -ErrorAction SilentlyContinue
