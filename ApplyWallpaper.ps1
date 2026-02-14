# Script de configuration du fond d'écran Xpolaris# ===================================================================

# S'exécute au premier login via tâche planifiée# Script de force application du fond d'ecran Xpolaris

# S'execute au premier demarrage pour garantir l'affichage du logo

$ErrorActionPreference = 'SilentlyContinue'# ===================================================================

$WallpaperPath = "C:\Windows\Web\Wallpaper\XpolarisWallpaper.bmp"

$LogFile = "C:\ApplyWallpaper.log"

if (Test-Path $WallpaperPath) {

    # Appliquer via stratégie systèmefunction Write-Log {

    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "Wallpaper" -Value $WallpaperPath -Type String    param([string]$Message)

    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "WallpaperStyle" -Value "10" -Type String    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

        "$Timestamp - $Message" | Out-File -FilePath $LogFile -Append -Encoding UTF8

    # Appliquer pour l'utilisateur actuel}

    Add-Type @"

    using System;Write-Log "============================================"

    using System.Runtime.InteropServices;Write-Log "APPLICATION FOND D'ECRAN XPOLARIS"

    public class Wallpaper {Write-Log "============================================"

        [DllImport("user32.dll", CharSet=CharSet.Auto)]Write-Log ""

        public static extern int SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);

    }$WallpaperPath = "C:\Windows\Web\Wallpaper\XpolarisWallpaper.bmp"

"@

    [Wallpaper]::SystemParametersInfo(0x0014, 0, $WallpaperPath, 0x0003)# Verifier si le fond d'ecran existe

    if (-not (Test-Path $WallpaperPath)) {

    Write-Host "Fond d'écran Xpolaris appliqué avec succès"    Write-Log "[ERREUR] Fond d'ecran introuvable: $WallpaperPath"

        exit 1

    # Supprimer la tâche après exécution}

    Unregister-ScheduledTask -TaskName "XpolarisApplyWallpaper" -Confirm:$false -ErrorAction SilentlyContinue

} else {Write-Log "[OK] Fond d'ecran trouve: $WallpaperPath"

    Write-Host "Fond d'écran Xpolaris introuvable : $WallpaperPath"Write-Log "[INFO] Taille: $([math]::Round((Get-Item $WallpaperPath).Length / 1MB, 2)) MB"

}

# Methode 1: Registry HKLM (pour tous les utilisateurs)

exit 0Write-Log ""

Write-Log "[1/3] Configuration Registry HKLM..."
try {
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "Wallpaper" -Value $WallpaperPath -Force
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "WallpaperStyle" -Value "10" -Force
    Write-Log "[OK] Registry HKLM configuree"
} catch {
    Write-Log "[ERREUR] Echec Registry HKLM: $_"
}

# Methode 2: Registry HKCU (utilisateur actuel) - Windows 11 specifique
Write-Log ""
Write-Log "[2/4] Configuration Registry HKCU..."
try {
    # Registry Desktop classique
    Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "Wallpaper" -Value $WallpaperPath -Force
    Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "WallpaperStyle" -Value "10" -Force  # Remplir
    Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "TileWallpaper" -Value "0" -Force
    
    # Registry TranscodedImageCache (Windows 11 specifique)
    $TranscodedPath = "HKCU:\Control Panel\Desktop"
    if (Get-ItemProperty -Path $TranscodedPath -Name "TranscodedImageCache" -ErrorAction SilentlyContinue) {
        Remove-ItemProperty -Path $TranscodedPath -Name "TranscodedImageCache" -Force -ErrorAction SilentlyContinue
        Write-Log "[OK] Cache TranscodedImageCache supprime (force MAJ)"
    }
    
    Write-Log "[OK] Registry HKCU configuree"
} catch {
    Write-Log "[ERREUR] Echec Registry HKCU: $_"
}

# Methode 3: Copier dans dossier utilisateur (Windows 11)
Write-Log ""
Write-Log "[3/4] Copie dans AppData utilisateur..."
try {
    $UserWallpaperDir = "$env:APPDATA\Microsoft\Windows\Themes"
    if (-not (Test-Path $UserWallpaperDir)) {
        New-Item -Path $UserWallpaperDir -ItemType Directory -Force | Out-Null
    }
    
    $UserWallpaperPath = "$UserWallpaperDir\TranscodedWallpaper"
    Copy-Item -Path $WallpaperPath -Destination $UserWallpaperPath -Force
    Write-Log "[OK] Fond d'ecran copie dans: $UserWallpaperPath"
} catch {
    Write-Log "[ERREUR] Echec copie utilisateur: $_"
}

# Methode 4: API Windows (force le rafraichissement)
Write-Log ""
Write-Log "[4/4] Application via API Windows..."
try {
    Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;

public class Wallpaper {
    [DllImport("user32.dll", CharSet = CharSet.Auto)]
    public static extern int SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);
}
"@
    
    # SPI_SETDESKWALLPAPER = 0x0014
    # SPIF_UPDATEINIFILE = 0x01
    # SPIF_SENDCHANGE = 0x02
    $result = [Wallpaper]::SystemParametersInfo(0x0014, 0, $WallpaperPath, 0x01 -bor 0x02)
    
    if ($result -eq 1) {
        Write-Log "[OK] Fond d'ecran applique via API Windows"
    } else {
        Write-Log "[AVERTISSEMENT] API Windows code: $result (peut etre normal)"
    }
} catch {
    Write-Log "[ERREUR] Exception API Windows: $_"
}

# Rafraichir le bureau (methode multiple pour Windows 11)
Write-Log ""
Write-Log "[INFO] Rafraichissement du bureau..."
try {
    # Methode 1: UpdatePerUserSystemParameters
    rundll32.exe user32.dll, UpdatePerUserSystemParameters, 1, True
    
    # Methode 2: Tuer et relancer Explorer
    Start-Sleep -Seconds 2
    Stop-Process -Name "explorer" -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 2
    Start-Process "explorer.exe"
    
    Write-Log "[OK] Bureau rafraichi (Explorer relance)"
} catch {
    Write-Log "[ERREUR] Echec rafraichissement: $_"
}

# Supprimer la tâche planifiée
Write-Log ""
Write-Log "[NETTOYAGE] Suppression de la tache planifiee..."
try {
    $TaskExists = schtasks /Query /TN "XpolarisApplyWallpaper" 2>&1
    if ($LASTEXITCODE -eq 0) {
        schtasks /Delete /TN "XpolarisApplyWallpaper" /F >$null 2>&1
        Write-Log "[OK] Tache planifiee supprimee"
    }
} catch {
    Write-Log "[INFO] Tache planifiee deja supprimee"
}

Write-Log ""
Write-Log "============================================"
Write-Log "APPLICATION TERMINEE"
Write-Log "============================================"
Write-Log ""
Write-Log "[INFO] Si le fond d'ecran n'apparait pas:"
Write-Log "  1. Verifiez C:\SetupComplete.log"
Write-Log "  2. Redemarrez Windows"
Write-Log "  3. Clic droit Bureau > Personnaliser > Arriere-plan"
Write-Log ""
