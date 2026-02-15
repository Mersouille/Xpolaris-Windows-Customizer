#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Suppression du branding OEM Xpolaris
.DESCRIPTION
    Retire toutes les modifications OEM pour un système complètement neutre
    Utilisé pour les déploiements professionnels
#>

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  SUPPRESSION BRANDING OEM XPOLARIS" -ForegroundColor White
Write-Host "  Configuration professionnelle neutre" -ForegroundColor Gray
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Supprimer les clés Registry OEM
Write-Host "[1/2] Suppression des informations OEM..." -ForegroundColor Yellow

$OEMRegPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation"

if (Test-Path $OEMRegPath) {
    try {
        # Supprimer toutes les propriétés OEM
        $OEMProperties = @(
            "Manufacturer",
            "Model",
            "SupportHours",
            "SupportPhone",
            "SupportURL",
            "Logo"
        )
        
        foreach ($Property in $OEMProperties) {
            if (Get-ItemProperty -Path $OEMRegPath -Name $Property -ErrorAction SilentlyContinue) {
                Write-Host "  - Suppression: $Property" -ForegroundColor Gray
                Remove-ItemProperty -Path $OEMRegPath -Name $Property -Force -ErrorAction SilentlyContinue
            }
        }
        
        Write-Host "  [OK] Informations OEM supprimees" -ForegroundColor Green
    } catch {
        Write-Host "  [ERREUR] Impossible de supprimer les cles OEM: $_" -ForegroundColor Red
    }
} else {
    Write-Host "  [INFO] Aucune information OEM trouvee" -ForegroundColor Gray
}

Write-Host ""

# Renommer l'ordinateur si nécessaire (optionnel)
Write-Host "[2/2] Verification nom d'ordinateur..." -ForegroundColor Yellow

$CurrentName = $env:COMPUTERNAME
if ($CurrentName -match "XPOLARIS") {
    Write-Host "  [INFO] Nom actuel: $CurrentName" -ForegroundColor Cyan
    Write-Host "  [INFO] Utiliser 'Rename-Computer' pour changer le nom si necessaire" -ForegroundColor Gray
} else {
    Write-Host "  [OK] Nom d'ordinateur deja neutre: $CurrentName" -ForegroundColor Green
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  [OK] BRANDING OEM SUPPRIME" -ForegroundColor White
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Les informations systeme afficheront maintenant des valeurs neutres." -ForegroundColor Cyan
Write-Host "Redemarrez l'ordinateur pour appliquer tous les changements." -ForegroundColor Yellow
Write-Host ""
