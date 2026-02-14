# Xpolaris Windows Customizer Pro

![Version](https://img.shields.io/badge/version-4.3.0-blue)
![Platform](https://img.shields.io/badge/platform-Windows%2011-0078D6)
![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-5391FE)
![License](https://img.shields.io/badge/license-MIT-green)

**Interface graphique moderne pour creer des ISO Windows 11 personnalises sans bloatware.**

![Screenshot](docs/screenshot.png)

## Fonctionnalites

- **Extraction d'edition** : Selectionnez et extrayez une edition specifique (Pro, Home, etc.)
- **Suppression du bloatware** : 17 applications Microsoft indesirables (Cortana, Xbox, Teams, OneDrive, Clipchamp...)
- **Suppression de composants Windows** : IE11, WMP, Paint 3D, Fax, Hello Face, WordPad, Phone Link...
- **Optimisations systeme** : Telemetrie, Cortana, widgets, Copilot, Recall, ContentDeliveryManager (11 cles)
- **Post-installation Xpolaris** : Branding OEM, activation Admin, fond d'ecran, scripts automatises
- **Modifications du registre** : Tweaks explorateur, performance visuelle, notifications
- **Creation d'ISO bootable** : Generez un ISO BIOS/UEFI compatible avec oscdimg
- **Boutons de selection rapide** : Tout cocher / Tout decocher / Config recommandee

## Prerequis

- **Windows 10/11** (64-bit)
- **PowerShell 5.1** ou superieur
- **Droits administrateur**
- **Windows ADK** (pour oscdimg.exe) - [Telecharger](https://docs.microsoft.com/windows-hardware/get-started/adk-install)
- **~20 Go d'espace disque** pour le traitement

## Installation

### Option 1 : Cloner le depot
```bash
git clone https://github.com/Mersouille/Xpolaris-Windows-Customizer.git
cd Xpolaris-Windows-Customizer
```

### Option 2 : Telecharger le ZIP
Telechargez la derniere release depuis [Releases](https://github.com/Mersouille/Xpolaris-Windows-Customizer/releases)

## Utilisation

### Methode recommandee (Script PowerShell)
```powershell
# Clic droit sur Lancer-Xpolaris.bat -> Executer en tant qu'administrateur
```

### Methode alternative (PowerShell direct)
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
.\Xpolaris-GUI.ps1
```

## Guide rapide

1. **Selectionnez un ISO** : Cliquez sur "Parcourir" et choisissez votre ISO Windows 11
2. **Chargez les editions** : Cliquez sur "Charger les editions disponibles"
3. **Selectionnez une edition** : Choisissez l'edition a extraire (ex: Windows 11 Pro)
4. **Configurez les options** : Dans l'onglet "Personnalisation", cochez les options souhaitees
5. **Lancez le processus** : Cliquez sur "DEMARRER LE PROCESSUS COMPLET"
6. **Attendez** : Le processus prend environ 15-30 minutes selon votre PC

## Applications supprimees par defaut

| Application | Description |
|-------------|-------------|
| Cortana | Assistant vocal Microsoft |
| Xbox Apps | Applications gaming Xbox (5 composants) |
| OneDrive | Stockage cloud Microsoft |
| Teams | Application de communication |
| Skype | Application de communication |
| News & Weather | Actualites et meteo |
| Feedback Hub | Hub de commentaires |
| Solitaire | Jeux Microsoft |
| Maps | Cartes Windows |
| Tips / Get Started | Astuces Windows |
| Clipchamp | Editeur video |
| Microsoft To Do | Gestionnaire de taches |
| Power Automate | Automatisation desktop |
| People | Contacts |
| Office Hub | Hub Microsoft Office |
| Groove Music | Lecteur musique (Zune) |
| Movies & TV | Films et TV (Zune Video) |

## Composants Windows supprimables

| Composant | Description |
|-----------|-------------|
| Internet Explorer 11 | Navigateur legacy |
| Windows Media Player | Lecteur multimedia legacy |
| Paint 3D / 3D Viewer | Applications 3D |
| Fax & Scan | Telecopie et numerisation |
| Hello Face | Reconnaissance faciale (sans camera IR) |
| WordPad | Editeur de texte |
| Xbox Services | Composants Xbox systeme |
| Phone Link | Liaison telephone |
| Mixed Reality Portal | Realite mixte |
| Microsoft Wallet | Portefeuille Microsoft |

## Optimisations appliquees

- Desactivation de la telemetrie Windows
- Desactivation de Cortana
- Blocage des applications suggerees (11 cles ContentDeliveryManager)
- Desactivation des widgets
- Desactivation de Copilot
- Desactivation de Recall (Windows AI)
- Affichage des extensions de fichiers
- Affichage des fichiers caches
- Masquer les notifications OneDrive dans l'explorateur
- Optimisation des effets visuels (performance)

## Post-Installation Xpolaris

- **Branding OEM** : Xpolaris affiche dans Systeme > Informations
- **Compte Administrateur** : Active automatiquement
- **Fond d'ecran** : Wallpaper Xpolaris applique + tache planifiee
- **RemoveBloatware** : Script de nettoyage supplementaire au 1er demarrage
- **Apps Manager** : Tache planifiee d'installation d'apps au login
- **SetupComplete.cmd** : Script maitre avec log de debug complet
- **autounattend.xml** : Installation Windows entierement automatisee

## Structure du projet

```
Xpolaris-Windows-Customizer/
├── Xpolaris-GUI.ps1          # Application principale
├── Lancer-Xpolaris.bat       # Lanceur avec droits admin
├── Windows-CustomizeMaster.ps1 # Script CLI original
├── autounattend.xml          # Fichier de reponse automatique
├── RemoveBloatware.ps1       # Script de suppression bloatware
├── Xpolaris-Apps-Manager.ps1 # Gestionnaire d'applications
├── docs/                     # Documentation
└── README.md                 # Ce fichier
```

## Depannage

### L'application ne se lance pas
- Verifiez que vous avez les droits administrateur
- Executez `Set-ExecutionPolicy Bypass -Scope Process -Force` dans PowerShell

### Erreur "oscdimg.exe non trouve"
- Installez Windows ADK depuis le site Microsoft
- Verifiez que le chemin est correct dans les variables d'environnement

### Le dossier Mount ne peut pas etre supprime
1. Cliquez sur le bouton "Nettoyer" dans l'onglet "Creation ISO"
2. Si le probleme persiste, redemarrez votre ordinateur
3. Supprimez manuellement le dossier `CustomizeWork`

### Antivirus bloque l'application
Les fichiers .exe compiles avec ps2exe peuvent etre detectes comme faux positifs.
**Solution** : Utilisez `Lancer-Xpolaris.bat` au lieu du fichier .exe

## Compilation (optionnel)

Pour compiler en executable :

```powershell
# Installer ps2exe
Install-Module -Name ps2exe -Force

# Compiler
ps2exe -InputFile "Xpolaris-GUI.ps1" -OutputFile "Xpolaris-GUI.exe" -NoConsole -requireAdmin -Title "Windows Customizer by Xpolaris" -Version "4.3.0"
```

**Note** : Les executables compiles peuvent declencher des faux positifs antivirus.

## Changelog

### v4.3.0 (14 fevrier 2026)
- **+17 apps Appx** supprimables (Clipchamp, To Do, Power Automate, People, Office Hub, Zune...)
- **+11 composants Windows** supprimables via DISM (IE11, WMP, Paint 3D, Fax, WordPad, Xbox services...)
- **Post-Installation Xpolaris** : Branding OEM, activation Admin, wallpaper, SetupComplete.cmd dynamique
- **ContentDeliveryManager** : 11 cles registre au lieu de 3
- **Nouvelles optimisations** : ShowSyncProviderNotifications, VisualFXSetting, Copilot/Recall avec vraies cles
- **Boutons de selection rapide** : Tout cocher / Tout decocher / Config recommandee
- **Layout 3 colonnes** dans l'onglet Personnalisation (51 options au total)
- **Correction PSScriptAnalyzer** : 0 warning (catch vides, verbes approuves)
- Renommage fonctions : Import-Editions, Export-SelectedEdition, Switch-Theme

### v4.1.0 (14 fevrier 2026)
- Interface utilisateur modernisee
- Correction des problemes d'encodage
- Amelioration de la gestion des erreurs
- Ajout du bouton de nettoyage manuel
- Suppression des caracteres speciaux pour compatibilite

### v3.0.0
- Premiere version avec interface graphique WPF
- Theme sombre/clair
- Barre de progression

### v2.2.0
- Version CLI originale
- Scripts de personnalisation

## Contribution

Les contributions sont les bienvenues ! N'hesitez pas a :

1. Fork le projet
2. Creer une branche (`git checkout -b feature/amelioration`)
3. Commit vos changements (`git commit -am 'Ajout d'une fonctionnalite'`)
4. Push sur la branche (`git push origin feature/amelioration`)
5. Ouvrir une Pull Request

## Licence

Ce projet est sous licence MIT. Voir le fichier [LICENSE](LICENSE) pour plus de details.

## Auteur

**Xpolaris** - *Developpeur principal*

## Remerciements

- Microsoft pour Windows ADK et les outils DISM
- La communaute PowerShell
- Tous les contributeurs

---

**Avertissement** : Cet outil modifie des images Windows. Utilisez-le a vos propres risques. Testez toujours l'ISO genere dans une machine virtuelle avant de l'utiliser en production.
