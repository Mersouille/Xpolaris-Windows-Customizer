# ⭐ XPOLARIS WINDOWS CUSTOMIZER v3.0.0

**Outil universel de personnalisation Windows** avec **interface console OU graphique**

> Compatible avec **Windows 10, 11, Server** et toutes futures versions
> 
> **🆕 Mise à jour du 1er février 2026** : **Interface graphique WPF moderne** (GUI) + version console préservée

---

## 📋 TABLE DES MATIÈRES

1. [Présentation](#-présentation)
2. [Versions disponibles](#-versions-disponibles-console--gui)
3. [Prérequis](#-prérequis)
4. [Installation rapide](#-installation-rapide)
5. [Structure des fichiers](#-structure-des-fichiers-consolidée)
6. [Utilisation](#-utilisation)
7. [Options du menu](#-options-du-menu)
8. [Scripts de post-installation](#-scripts-de-post-installation)
9. [Dépannage automatique](#-dépannage-automatique)
10. [Personnalisation autounattend.xml](#-personnalisation-autounattendxml)
11. [Création de l'ISO bootable](#-création-de-liso-bootable)
12. [Guide de Débogage](#-guide-de-débogage)
13. [Problème : Compte Administrateur désactivé](#-problème--compte-administrateur-désactivé)
14. [FAQ](#-faq)
15. [Changelog](#-changelog)

---

## 🎯 PRÉSENTATION

**Xpolaris Windows Customizer** est un outil PowerShell tout-en-un disponible en **DEUX versions** :

### 🖥️ Version Console (v2.2.0)
- Interface texte ASCII professionnelle avec logo Xpolaris en couleur
- Menu numérique [1] à [5]
- Idéal pour automatisation et scripts
- Léger et rapide

### 🎨 Version GUI (v3.0.0) - **NOUVEAU**
- Interface graphique WPF moderne style Windows 11
- Onglets organisés (Sélection ISO / Personnalisation / Création / Logs)
- Drag & Drop pour fichiers ISO
- Thème sombre/clair commutable
- Progress bars animées et logs en temps réel
- Checkboxes pour sélection multiple d'options
- Expérience utilisateur intuitive et visuelle

### ✨ Fonctionnalités communes

✅ **Extraire une seule édition** Windows (réduction de ~60% de la taille)  
✅ **Personnaliser l'image** avec optimisations et branding Xpolaris  
✅ **Créer une ISO bootable** avec Rufus (détection automatique)  
✅ **Installer automatiquement** avec autounattend.xml (bypass réseau inclus)  
✅ **Fond d'écran Xpolaris Full HD** (1920x1080, logo centré)  
✅ **Installation automatique de 6 applications** via winget (avec fallback intégré)  
✅ **Scripts de dépannage** automatiquement sur le Bureau après installation

### 🌟 Caractéristiques

- 🔍 **Détection automatique Rufus** (recherche 3 phases sur tous les disques)
- 🚫 **Bypass réseau** - Option "Je n'ai pas internet" activée (BypassNRO)
- 🔧 **15+ optimisations système** (télémétrie, performances, confidentialité)
- 🖼️ **Branding Xpolaris** complet (fond d'écran Full HD, infos OEM)
- 📦 **6 applications installées automatiquement** (Chrome, 7-Zip, VLC, Notepad++, TeamViewer, Virtual CloneDrive)
- 🛠️ **Scripts de dépannage intégrés** (sur le Bureau dès l'installation)
- 🌐 **Universel** - Fonctionne avec n'importe quelle version Windows
- 📊 **Logs de débogage automatiques** (4 fichiers .log dans C:\)
- ⚙️ **Tâches planifiées intelligentes** avec auto-suppression
- 🔄 **Fallback automatique** si winget indisponible (téléchargement direct .exe)

---

## 🎭 VERSIONS DISPONIBLES : CONSOLE & GUI

Xpolaris Windows Customizer est disponible en **DEUX versions complètes** :

### 📊 Comparaison rapide

| Critère | 🖥️ Console (v2.2.0) | 🎨 GUI (v3.0.0) |
|---------|---------------------|-----------------|
| **Interface** | Texte ASCII | Graphique WPF |
| **Facilité** | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| **Vitesse** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ |
| **Mémoire** | ~50 MB | ~120 MB |
| **Automatisation** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ |
| **Visuel** | ⭐⭐ | ⭐⭐⭐⭐⭐ |
| **Drag & Drop** | ❌ | ✅ |
| **Thème perso** | ❌ | ✅ |
| **Logs temps réel** | ⭐⭐ | ⭐⭐⭐⭐⭐ |
| **Fichier** | `Xpolaris-Windows-Customizer.exe` | `Xpolaris-GUI.exe` |

### 🖥️ Version Console - Pour les puristes

**Avantages :**
- ✅ Léger et rapide
- ✅ Compatible scripts automatisés
- ✅ Fonctionne en SSH/RDP
- ✅ Interface ASCII stylisée
- ✅ Idéal pour serveurs

**Utilisation :**
```cmd
Xpolaris-Windows-Customizer.exe
```

### 🎨 Version GUI - Pour l'expérience moderne

**Avantages :**
- ✅ Interface graphique Windows 11
- ✅ **4 onglets organisés** :
  - 📁 **Sélection ISO** : Parcourir ou glisser-déposer
  - 🎨 **Personnalisation** : Checkboxes pour tout configurer
  - 💿 **Création ISO** : Processus complet automatisé
  - 📋 **Logs** : Console en temps réel avec export
- ✅ Thème sombre/clair commutable 🌙☀️
- ✅ Drag & Drop pour fichiers ISO
- ✅ Progress bars animées
- ✅ Sélection multiple via checkboxes
- ✅ Logs exportables

**Utilisation :**
```cmd
Xpolaris-GUI.exe
```

**Captures d'écran GUI :**
```
┌──────────────────────────────────────────────────┐
│ ⚡ XPOLARIS WINDOWS CUSTOMIZER PRO  🌙 Thème  ℹ️ │
│ Version 3.0.0 - Interface Graphique Moderne      │
├──────────────────────────────────────────────────┤
│ 📁 Sélection ISO │ 🎨 Personnalisation │ 💿 ... │
├──────────────────────────────────────────────────┤
│                                                  │
│  ╔═════════════════════════════════════════╗    │
│  ║ Fichier ISO Source                      ║    │
│  ║ [C:\Win11.iso      ] [📂 Parcourir...] ║    │
│  ║ 💡 Glissez-déposez votre ISO ici        ║    │
│  ╚═════════════════════════════════════════╝    │
│                                                  │
│  🚀 DÉMARRER LE PROCESSUS COMPLET                │
│  ━━━━━━━━━━━━━━━━━━━━━━━━ 45%                   │
│  Extraction de l'édition Windows...              │
│                                                  │
├──────────────────────────────────────────────────┤
│ ✓ Prêt              v3.0.0 | Xpolaris © 2026   │
└──────────────────────────────────────────────────┘
```

### 💡 Quelle version choisir ?

**Choisissez CONSOLE si :**
- Vous préférez les interfaces textuelles
- Vous voulez automatiser via scripts
- Vous travaillez en SSH/RDP distant
- Vous avez des ressources limitées
- Vous êtes un utilisateur avancé

**Choisissez GUI si :**
- C'est votre **première utilisation** 🎯
- Vous préférez les interfaces graphiques
- Vous voulez voir la progression visuellement
- Vous aimez le design moderne Windows 11
- Vous voulez utiliser Drag & Drop

**💡 Astuce :** Les deux versions sont conservées ! Testez les deux et choisissez votre préférée.

---

## 💾 PRÉREQUIS

### Système requis

- ✅ **Windows 10/11** avec PowerShell 5.1 ou supérieur
- ✅ **Droits administrateur** (requis pour DISM et modifications système)
- ✅ **15 GB d'espace disque** libre minimum
- ✅ **Image ISO Windows** montée ou dossier contenant `install.wim`

### Outils recommandés

- 🔸 **Rufus 4.6+** (téléchargement automatique si absent)
- 🔸 **Windows ADK** (optionnel, fallback si Rufus absent)

### Fichiers nécessaires

⚠️ **IMPORTANT : Vous devez copier TOUTE la structure de l'ISO Windows**, pas seulement `sources\install.wim` !

#### Étapes de préparation :

1. **Montez votre ISO Windows** (clic droit → Monter, ou utilisez un outil comme 7-Zip)
2. **Copiez TOUT le contenu** (Ctrl+A puis Ctrl+C)
3. **Collez dans le dossier du script** où se trouve `Windows-CustomizeMaster.ps1`

#### Structure requise (complète) :

```
📁 Dossier du script/
├── 📄 Windows-CustomizeMaster.ps1    (Script principal)
├── 📄 Windows-CustomizeMaster.exe    (Exécutable - Recommandé)
├── 📄 autounattend.xml                 (Configuration installation automatique)
├── 📄 XpolarisLogo.ps1                 (Générateur logo OEM - installation)
├── 🖼️ Xpolaris.jpg                     (Image logo 1544x980)
│
├── 📄 XpolarisLogo_Preview.ps1         (Optionnel - Prévisualisation du logo)
├── 🖼️ XpolarisLogo_Preview.bmp         (Généré - Aperçu du logo)
│
├── 📁 boot/                            ⚠️ REQUIS pour ISO bootable
│   ├── bcd
│   ├── boot.sdi
│   ├── etfsboot.com                   ← Fichier critique BIOS
│   └── ...
│
├── 📁 efi/                             ⚠️ REQUIS pour boot UEFI
│   └── microsoft/boot/
│       └── efisys.bin                 ← Fichier critique UEFI
│
├── 📁 sources/                         ⚠️ REQUIS
│   ├── install.wim                    ← Image Windows principale
│   ├── boot.wim
│   └── ...
│
├── 📁 support/                         (Facultatif)
├── 📄 autorun.inf
├── 📄 bootmgr                          ⚠️ REQUIS
├── 📄 bootmgr.efi                      ⚠️ REQUIS
├── 📄 setup.exe
├── 🖼️ XpolarisWallpaper.bmp            ⚠️ Fond d'écran Full HD (1920x1080)
├── 📄 RemoveBloatware.ps1              ⚠️ Script nettoyage bloatware
├── 📄 Xpolaris-Apps-Manager.ps1        🆕 Script TOUT-EN-UN (installation + dépannage)
├── 📄 Xpolaris-Apps-Manager.cmd        🆕 Lanceur automatique
└── 📄 ApplyWallpaper.ps1               ⚠️ Script force fond d'écran
```

> 💡 **Fichiers essentiels pour personnalisation Xpolaris** :
> - `XpolarisWallpaper.bmp` (1 MB) → Fond d'écran avec logo centré 600x600 sur fond noir
> - `RemoveBloatware.ps1` (7 KB) → Supprime Xbox, Teams, OneDrive au 1er démarrage
> - `Xpolaris-Apps-Manager.ps1` (25 KB) 🆕 → **TOUT-EN-UN** : Installation auto + dépannage manuel
> - `Xpolaris-Apps-Manager.cmd` (1 KB) 🆕 → Lanceur avec élévation auto
> - `ApplyWallpaper.ps1` (3 KB) → Force l'application du fond d'écran (3 méthodes)
> 
> 💡 **Le script détectera automatiquement si la structure est incomplète** et affichera un avertissement au démarrage.

---

## 📁 STRUCTURE DES FICHIERS CONSOLIDÉE

### 🎯 Scripts PowerShell (7 fichiers)

#### **Scripts principaux** (4)
- `Windows-CustomizeMaster.ps1` (98 KB) → Script principal console avec menu interactif
- `Xpolaris-GUI.ps1` (50 KB) → **🆕 Interface graphique WPF moderne**
- `Recompile-Exe.ps1` (2 KB) → Génération du fichier `.exe` console
- `Compile-GUI.ps1` (3 KB) → **🆕 Compilation de l'interface graphique**

#### **Scripts ISO** (2 - copiés automatiquement)
- `RemoveBloatware.ps1` (7 KB) → Suppression Xbox, Teams, OneDrive
- `ApplyWallpaper.ps1` (3 KB) → Application fond d'écran

#### **Script universel** (1)
- `Xpolaris-Apps-Manager.ps1` (25 KB) → **Installation AUTO + Dépannage INTERACTIF**
- `Xpolaris-Apps-Manager.cmd` (1 KB) → Lanceur automatique

### 💻 Exécutables compilés (2 versions)

| Fichier | Version | Interface | Taille | Date |
|---------|---------|-----------|--------|------|
| `Xpolaris-Windows-Customizer.exe` | v2.2.0 | Console (ASCII) | ~2-3 MB | 28/12/2025 |
| `Xpolaris-GUI.exe` | **v3.0.0** | **Graphique (WPF)** | **~60 KB** | **01/02/2026** 🆕 |

### ✨ Évolution du projet

| Version | Date | Fichiers | Changement |
|---------|------|----------|------------|
| v2.1 | Décembre 2025 | 9 fichiers | Version initiale |
| v2.2.0 | 28/12/2025 | **5 fichiers** | Fusion Apps-Manager (-44%) |
| **v3.0.0** | **01/02/2026** | **7 fichiers** | **+ Interface GUI** 🆕 |

**Bénéfices :**
- ✅ **Architecture simplifiée** : Code unifié
- ✅ **Deux interfaces** : Console ET Graphique
- ✅ **Maintenance facilitée** : Moins de duplication
- ✅ **Expérience utilisateur** : Choix selon préférence

---

## 🚀 INSTALLATION RAPIDE

### Méthode 1 : Interface Graphique (GUI) - **RECOMMANDÉ**

**Double-cliquez sur :**
```
Xpolaris-GUI.exe
```

- ✅ Interface graphique moderne Windows 11
- ✅ Drag & Drop pour ISO
- ✅ Thème sombre/clair
- ✅ Progress bars animées
- ✅ Logs en temps réel

### Méthode 2 : Interface Console

**Double-cliquez sur :**
```
Xpolaris-Windows-Customizer.exe
```

- ✅ Lance automatiquement en **mode administrateur**
- ✅ Gère l'élévation UAC
- ✅ Interface ASCII professionnelle
- ✅ Léger et rapide

### Méthode 3 : Via PowerShell (Développeurs)

```powershell
# 1. Ouvrir PowerShell en tant qu'administrateur
# Clic droit sur PowerShell → Exécuter en tant qu'administrateur

# 2. Naviguer vers le dossier
cd "E:\Projets Visual Studio\Windows Customizer v2.2.0"

# 3. Autoriser l'exécution
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

# 4. Lancer le script
.\Windows-CustomizeMaster.ps1
```

---

## 🎮 UTILISATION

### 🎯 Démarrage rapide

Deux méthodes selon votre préférence :

#### Méthode 1 : Interface Graphique (GUI) - **RECOMMANDÉ pour débutants**

```cmd
# Double-cliquer sur :
Xpolaris-GUI.exe

# Ou via PowerShell :
.\Xpolaris-GUI.exe
```

#### Méthode 2 : Interface Console

```cmd
# Double-cliquer sur :
Xpolaris-Windows-Customizer.exe

# Ou via PowerShell :
.\Xpolaris-Windows-Customizer.exe
```

---

### 🎨 INTERFACE GRAPHIQUE (GUI v3.0.0)

#### 📁 Onglet 1 : Sélection ISO

**Étape 1 : Charger votre ISO**
```
╔═══════════════════════════════════════════╗
║  Fichier ISO Source                       ║
╠═══════════════════════════════════════════╣
║  [                         ] [📂 Parcourir]║
║  💡 Glissez-déposez votre fichier ISO ici ║
╚═══════════════════════════════════════════╝
```

**Actions possibles :**
- 📂 **Parcourir** : Ouvrir le sélecteur de fichier classique
- 🖱️ **Drag & Drop** : Glisser votre ISO directement dans la zone

**Étape 2 : Charger les éditions**
```
[🔍 Charger les éditions disponibles]

Résultat :
1 - Windows 11 Pro
2 - Windows 11 Home
3 - Windows 11 Education
```

**Étape 3 : Extraire (optionnel)**
```
[📦 Extraire l'édition sélectionnée]
```

---

#### 🎨 Onglet 2 : Personnalisation

**Suppression des composants Windows :**
```
☑ Internet Explorer
☑ Windows Media Player Legacy
☑ WordPad
☐ Paint (ancien)
☐ Notepad (ancien)
```

**Bloatware à supprimer :**
```
Colonne 1:                  Colonne 2:
☑ Xbox                      ☑ Get Help
☑ Microsoft Teams           ☑ Feedback Hub
☑ OneDrive                  ☑ Maps
☑ Cortana                   ☑ Solitaire Collection
☑ 3D Viewer                 ☑ People
☑ Office Hub                ☑ Groove Music
```

**Applications à installer :**
```
☑ 🌐 Google Chrome          ☑ 📝 Notepad++
☑ 📦 7-Zip                  ☑ 🖥️ TeamViewer
☑ 🎬 VLC Media Player       ☑ 💿 Virtual CloneDrive
```

**Options avancées :**
```
☑ Désactiver la télémétrie
☑ Activer le thème sombre
☑ Désactiver Cortana complètement
☑ Afficher les extensions de fichiers
☐ Désactiver l'hibernation
```

---

#### 💿 Onglet 3 : Création ISO

**Fichier de sortie :**
```
╔═══════════════════════════════════════════╗
║  Nom du fichier ISO à créer :             ║
║  [Windows_Custom_Xpolaris.iso] [📂 Choisir]║
╚═══════════════════════════════════════════╝
```

**Processus complet automatisé :**
```
Le processus complet effectuera automatiquement :
✓ Extraction de l'édition Windows sélectionnée
✓ Suppression des composants non désirés
✓ Application des personnalisations
✓ Intégration des scripts de post-installation
✓ Création de l'ISO final
✓ Nettoyage des fichiers temporaires

[🚀 DÉMARRER LE PROCESSUS COMPLET]

━━━━━━━━━━━━━━━━━━━━━━━━━━ 45%
Extraction de l'édition Windows...

[⏹️ Arrêter le processus]
```

---

#### 📋 Onglet 4 : Logs

**Console en temps réel :**
```
╔═══════════════════════════════════════════╗
║ [18:15:32] Bienvenue dans Xpolaris...     ║
║ [18:15:33] ISO sélectionné : Win11.iso    ║
║ [18:15:45] Chargement des éditions...     ║
║ [18:15:47] ✓ 3 édition(s) trouvée(s)     ║
║ [18:16:10] Extraction en cours...         ║
║ [18:16:55] ✓ Extraction terminée          ║
║ [18:17:20] Suppression des composants...  ║
╚═══════════════════════════════════════════╝

[🗑️ Effacer]  [💾 Exporter]
```

**Fonctionnalités :**
- ✅ Logs horodatés automatiquement
- ✅ Défilement automatique
- ✅ Export vers fichier texte
- ✅ Style terminal (fond noir, texte vert)

---

#### 🎨 Fonctionnalités supplémentaires GUI

**Barre d'outils supérieure :**
```
⚡ XPOLARIS WINDOWS CUSTOMIZER PRO
Version 3.0.0 - Interface Graphique Moderne

                     [🌙 Thème]  [ℹ️ À propos]
```

**Barre de statut inférieure :**
```
✓ Prêt                    v3.0.0 | Xpolaris © 2026
```

**Basculer le thème :**
- 🌙 **Thème sombre** (par défaut) : Fond #1E1E1E
- ☀️ **Thème clair** : Fond #F0F0F0

---

### 🖥️ INTERFACE CONSOLE (v2.2.0)

#### Interface principale

Au lancement, vous verrez :

```
██╗  ██╗██████╗  ██████╗ ██╗      █████╗ ██████╗ ██╗███████╗
╚██╗██╔╝██╔══██╗██╔═══██╗██║     ██╔══██╗██╔══██╗██║██╔════╝
 ╚███╔╝ ██████╔╝██║   ██║██║     ███████║██████╔╝██║███████╗
 ██╔██╗ ██╔═══╝ ██║   ██║██║     ██╔══██║██╔══██╗██║╚════██║
██╔╝ ██╗██║     ╚██████╔╝███████╗██║  ██║██║  ██║██║███████║
╚═╝  ╚═╝╚═╝      ╚═════╝ ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝╚══════╝
⭐ WINDOWS CUSTOMIZER v4.2.0 ⭐

┌────────────────────────────────────────┐
│ 📊 ÉTAT DU SYSTÈME                     │
└────────────────────────────────────────┘
💿 Image install.wim : 5.84 GB (1 édition)
⚙️  Personnalisée    : ✅ Oui
💾 Sauvegarde        : ✅ Disponible
🗂️  Espace temporaire : 0 GB (propre)
```

### Ordre d'exécution recommandé

#### 🎯 Processus complet (Option [1])

**Option automatique** - Toutes les étapes en une seule commande :

```
[1] → Processus complet
```

Exécute dans l'ordre :
1. ✂️ Extraction de l'édition Windows choisie
2. 🎨 Personnalisation et optimisations
3. 🖼️ Application du branding Xpolaris
4. 💿 Création de l'ISO avec Rufus

#### 📋 Processus manuel

**Pour plus de contrôle**, exécutez les options séparément :

```
[2] → Extraire une seule édition Windows
[3] → Personnaliser l'image
[4] → Appliquer le branding Xpolaris
[5] → Générer le logo OEM
[6] → Créer l'ISO finale avec Rufus
```

---

## 🔧 OPTIONS DU MENU

### [1] 🚀 Processus complet

**Automatise TOUT le workflow en une seule commande** :

#### Étapes exécutées :
1. **Extraction** de l'édition Windows choisie (sélection interactive)
2. **Suppression** des composants Windows inutiles :
   - Internet Explorer 11
   - Windows Media Player Legacy
   - WordPad
   - Télécopie et numérisation
3. **Personnalisation complète** :
   - Optimisations registre (télémétrie, Cortana, widgets)
   - Configuration Explorateur (extensions visibles, fichiers cachés)
   - Effets visuels optimisés
   - Nettoyage DISM approfondi
4. **Création** de l'ISO finale bootable (avec oscdimg/Rufus)
5. **Nettoyage** des fichiers temporaires (ISO conservée)

✅ **Recommandé pour 99% des utilisateurs** - Installation Windows optimale !  
⏱️ **Durée** : 20-40 minutes (selon la puissance du PC)  

> 💡 **Note** : Si vous souhaitez personnaliser finement (choisir quels composants supprimer, garder WordPad, etc.), utilisez plutôt les **options individuelles [2] à [6]**.

---

### 📋 Processus manuel (pour personnalisation avancée)

**Utilisez les options individuelles** si vous voulez contrôler chaque étape :

```
[2] → Extraire une seule édition Windows
[3] → Personnaliser l'image (optimisations)
[4] → Supprimer des composants (choix granulaire)
[6] → Créer l'ISO finale
```

---

### [2] ✂️ Extraire une seule édition Windows

**Réduit la taille de l'image** en extrayant uniquement l'édition souhaitée.

**Avantages :**
- 📉 Réduction de ~60% de la taille (5 GB → 2 GB)
- ⚡ Installation plus rapide
- 🎯 Pas de choix d'édition à l'installation

**Éditions disponibles :**
- Index 1 : Windows Home
- Index 2 : Windows Home N
- Index 3 : Windows Home Single Language
- Index 4 : Windows Education
- Index 5 : Windows Education N
- **Index 6 : Windows Pro** ← Recommandé
- Index 7 : Windows Pro N
- Index 8 : Windows Pro Education
- Index 9 : Windows Pro Education N
- Index 10 : Windows Pro for Workstations
- Index 11 : Windows Pro N for Workstations

⚠️ **Important** : Créez une sauvegarde avant (Option [8])

---

### [3] 🎨 Personnaliser l'image

**Applique 15+ optimisations système** :

#### 🚫 Désactivation télémétrie et confidentialité
- Diagnostic data collection → Off
- Telemetry → Security only
- Activity History → Disabled
- Advertising ID → Disabled

#### ⚡ Optimisations performances
- Superfetch → Disabled
- Game Bar → Disabled
- Background apps → Limited
- Startup apps → Optimized

#### 🎨 Interface et préférences
- Dark mode → Enabled
- Taskbar alignment → Left
- File Explorer → This PC par défaut
- Show file extensions → Enabled
- Hidden files → Visible

#### 📦 Applications supprimées
- OneDrive (complètement désinstallé)
- Cortana
- Get Started
- Office Hub
- Skype
- Xbox Game Bar

---

### [4] 🖼️ Appliquer le branding Xpolaris

**Personnalisation complète du système** :

✅ **Fond d'écran Full HD** : 1920x1080, logo Xpolaris 600x600 centré sur fond noir  
✅ **Nom du système** : "Xpolaris"  
✅ **Nom OEM** : "Xpolaris"  
✅ **Infos OEM** : Manufacturer, Model, SupportHours, SupportPhone, SupportURL  
✅ **Applications automatiques** : 6 apps installées via winget au 1er démarrage  
✅ **Nettoyage bloatware** : Suppression automatique des apps indésirables

**Fichiers copiés dans l'ISO** :
- `XpolarisWallpaper.bmp` → `sources\` et `sources\$OEM$\$$\Setup\Scripts\`
- `RemoveBloatware.ps1` → `sources\` et `sources\$OEM$\$$\Setup\Scripts\`
- `Xpolaris-Apps-Manager.ps1` → `sources\` et `sources\$OEM$\$$\Setup\Scripts\` + **Bureau Administrateur**
- `Xpolaris-Apps-Manager.cmd` → `sources\$OEM$\$$\Setup\Scripts\` + **Bureau Administrateur**
- `ApplyWallpaper.ps1` → `sources\` et `sources\$OEM$\$$\Setup\Scripts\`
- `SetupComplete.cmd` → Créé dans `sources\$OEM$\$$\Setup\Scripts\`

**Résultat après installation** :
- Fond d'écran Xpolaris appliqué automatiquement (30 sec après connexion)
- 6 applications installées (1 min après connexion) :
  - 🌐 Google Chrome
  - 📦 7-Zip
  - 🎬 VLC Media Player
  - 📝 Notepad++
  - 🖥️ TeamViewer
  - 💿 Virtual CloneDrive
- Bloatware supprimé (Candy Crush, Xbox Game Bar, OneDrive, etc.)
- **Script de dépannage disponible sur le Bureau** (Xpolaris-Apps-Manager.cmd)
- 4 fichiers de logs créés dans `C:\` pour débogage

**Résultat :**
```
Paramètres > Système > Informations système
────────────────────────────────────────
Appareil : Xpolaris
Fabricant : Xpolaris
Logo : [🖼️ Logo Xpolaris]
```

---

### [5] 🎨 Générer le logo OEM

**Crée le logo système** à partir de `Xpolaris.jpg`

**Processus :**
1. Charge l'image `Xpolaris.jpg` (1544x980)
2. Redimensionne en **120x120 pixels** (standard OEM)
3. Ajoute une barre semi-transparente
4. Dessine le texte "Xpolaris" en blanc
5. Sauvegarde en `C:\Windows\System32\oemlogo.bmp`

✅ **Qualité professionnelle** avec antialiasing haute qualité  
✅ **Standard OEM** - Même taille que Dell, HP, Lenovo (120x120)  
✅ **Taille visuelle** : ~3.2 cm à l'écran

---

### [6] 💿 Créer l'ISO finale

**Génère l'ISO bootable** avec Rufus (ou Windows ADK en fallback)

#### 🔍 Détection automatique de Rufus (3 phases)

**Phase 1** : Dossier du projet
```
E:\Projets Visual Studio\Windows 11\rufus*.exe
```

**Phase 2** : Emplacements standards
```
%USERPROFILE%\Downloads\
%USERPROFILE%\Desktop\
C:\Tools\
C:\
```

**Phase 3** : Recherche globale
- Tous les disques (C:, D:, E:, etc.)
- Profondeur 3 niveaux
- Ignore les dossiers système protégés
- Durée : 5-30 secondes

📥 **Téléchargement automatique** si Rufus introuvable

#### 💿 Création de l'ISO

**Nom du fichier** : `Windows_Custom_Xpolaris.iso`

**Contenu** :
- ✅ Image Windows personnalisée
- ✅ Bootloader EFI et BIOS
- ✅ Fichier `autounattend.xml` (installation automatique)
- ✅ Logo Xpolaris intégré

**Taille finale** : 2-3 GB (édition unique) ou 5-6 GB (multi-éditions)

---

### [7] 🔄 Restaurer l'image originale

**Restaure** `install.wim` depuis la sauvegarde `install.wim.backup`

⚠️ **Attention** : Écrase toutes les modifications !

---

### [8] 💾 Créer une sauvegarde

**Crée** `install.wim.backup` (copie de sécurité)

✅ **Recommandé** avant toute modification

---

### [9] 🧹 Nettoyer les fichiers temporaires

**Supprime** :
- Dossier `TEMP\` (montages DISM)
- Dossier `CustomISO\` (fichiers temporaires ISO)
- Logs et caches

💾 **Libère** : 5-10 GB d'espace disque

---

### [0] ❌ Quitter

**Quitte** l'application avec écran de remerciement

---

## � SCRIPTS DE POST-INSTALLATION

### Architecture automatique

Après l'installation de Windows, **7 étapes** s'exécutent automatiquement via `SetupComplete.cmd` :

#### 📋 Séquence d'exécution

```
[1/5] Copie des fichiers
[2/5] Configuration fond d'écran Xpolaris (Registry)
[3/5] Configuration OEM Registry
[4/6] Activation compte Administrateur
[5/6] Suppression bloatware (exécution immédiate)
[6/7] Création tâche planifiée InstallApps
[7/7] Création tâche planifiée ApplyWallpaper
```

### 🗂️ Scripts disponibles après installation

#### Emplacements

1. **`C:\Windows\Setup\Scripts\`** (dossier système)
   - RemoveBloatware.ps1
   - Xpolaris-Apps-Manager.ps1 🆕 **TOUT-EN-UN**
   - Xpolaris-Apps-Manager.cmd 🆕
   - ApplyWallpaper.ps1

2. **Bureau de l'Administrateur** 🆕
   - Xpolaris-Apps-Manager.cmd (lanceur simplifié)
   - Xpolaris-Apps-Manager.ps1 (script complet)

### 📄 Xpolaris-Apps-Manager.ps1 (TOUT-EN-UN) 🆕

#### Deux modes d'utilisation

**🤖 MODE AUTO** (Tâche planifiée au 1er démarrage)
- Paramètre : `-AutoMode`
- Détecté automatiquement par SetupComplete.cmd
- Installe les 6 applications sans interaction
- Log détaillé : `C:\InstallApps.log`
- Auto-suppression de la tâche planifiée

**🛠️ MODE INTERACTIF** (Double-clic pour dépannage)
- Menu avec 5 options :
  1. Supprimer tâches planifiées (arrêter boucle)
  2. Installer applications manquantes
  3. Supprimer bloatware restant
  4. TOUT CORRIGER (recommandé)
  5. Quitter
- Auto-élévation administrateur
- Résumé de vérification finale

#### Applications installées

1. 🌐 **Google Chrome** - Navigateur web
2. 📦 **7-Zip** - Compression/décompression
3. 🎬 **VLC Media Player** - Lecteur multimédia (version 3.0.20)
4. 📝 **Notepad++** - Éditeur de texte avancé
5. 🖥️ **TeamViewer** - Contrôle à distance
6. 💿 **Virtual CloneDrive** - Montage ISO/images

#### Méthodes d'installation

1. **Winget** (priorité) - Installation via Windows Package Manager
2. **Fallback automatique** - Téléchargement direct si winget indisponible
3. **Auto-suppression tâche** - Évite boucle infinie au démarrage

#### Logs

- **`C:\InstallApps.log`** - Historique détaillé (MODE AUTO uniquement)

#### 💡 Améliorations v2.2.0

- ✅ **Fusion complète** - InstallApps.ps1 + Xpolaris-PostInstall-Fix.ps1
- ✅ **Code VLC unifié** - Pas de duplication (version 3.0.20)
- ✅ **Détection automatique mode** - Auto vs Interactif
- ✅ **Fallback intégré** - Plus besoin de fichier séparé
- ✅ **Moins de fichiers** - Architecture simplifiée

### 📄 RemoveBloatware.ps1

#### Applications supprimées

**Xbox** :
- Microsoft.XboxGameCallableUI
- Microsoft.GamingApp
- Microsoft.XboxGameOverlay
- Microsoft.XboxGamingOverlay
- Microsoft.XboxIdentityProvider
- Microsoft.XboxSpeechToTextOverlay
- Microsoft.GamingServices

**Teams** :
- MSTeams
- MicrosoftTeams

**OneDrive** :
- Désinstallation complète (32-bit et 64-bit)
- Suppression des dossiers
- Blocage définitif via Registry

**Autres** :
- Microsoft.Windows.PeopleExperienceHost
- Microsoft.BingWeather
- Microsoft.GetHelp
- Microsoft.Getstarted
- Microsoft.WindowsCommunicationsApps (Mail, Calendar)
- Microsoft.ZuneMusic
- Microsoft.ZuneVideo
- Cortana (si présent)

#### Services désactivés

- XblAuthManager
- XblGameSave
- XboxGipSvc
- XboxNetApiSvc

#### Logs

- **`C:\RemoveBloatware.log`** - Liste des packages supprimés

---

## 🛠️ DÉPANNAGE AUTOMATIQUE

### 🆕 Xpolaris-PostInstall-Fix.ps1

**Script universel de correction post-installation** qui remplace 4 anciens scripts.

#### 🎯 Fonctionnalités

**Mode interactif** (par défaut) :
```
[1] Supprimer tâches planifiées (arrêter boucle au démarrage)
[2] Installer applications manquantes (VLC, etc.)
[3] Supprimer bloatware restant (Xbox, Teams, OneDrive)
[4] TOUT CORRIGER (recommandé)
[5] Quitter
```

**Mode automatique** (avec paramètres) :
```powershell
.\Xpolaris-PostInstall-Fix.ps1 -FullFix
.\Xpolaris-PostInstall-Fix.ps1 -RemoveTasksOnly
.\Xpolaris-PostInstall-Fix.ps1 -InstallAppsOnly
.\Xpolaris-PostInstall-Fix.ps1 -FixBloatwareOnly
```

#### 🚀 Utilisation

##### **Méthode 1 : Fichier .CMD** (recommandé)

Sur le Bureau, double-cliquez sur :
```
Xpolaris-PostInstall-Fix.cmd
```

- ✅ **Élévation automatique** en administrateur
- ✅ **Bypass politique d'exécution** automatique
- ✅ **Menu interactif** s'affiche

##### **Méthode 2 : Fichier .PS1**

Clic-droit sur :
```
Xpolaris-PostInstall-Fix.ps1
→ "Exécuter avec PowerShell"
```

Le script demande automatiquement l'élévation admin.

#### ⚙️ Corrections automatiques

##### **[1] Supprimer tâches planifiées**

**Problème résolu** : Fenêtre DOS qui apparaît à chaque redémarrage

**Action** :
- Suppression de `XpolarisInstallApps`
- Suppression de `XpolarisApplyWallpaper`

##### **[2] Installer applications manquantes**

**Problème résolu** : VLC non installé ou échec winget

**Action** :
1. Vérification si VLC déjà installé
2. Essai via **winget** (si disponible)
3. **Téléchargement direct** VLC 3.0.20 (version compatible)
4. Installation silencieuse

##### **[3] Supprimer bloatware restant**

**Problème résolu** : Xbox encore présent (erreur 0x80070032)

**Action** :
1. **Arrêt des services Xbox** avant suppression
2. Tentative de suppression forcée
3. Si erreur 0x80070032 : Message "Sera supprimé au prochain redémarrage"

##### **[4] Résumé final**

Affiche :
- ✅ Applications installées
- ✅ Bloatware supprimé (vérification AppxPackage)
- ✅ Tâches planifiées désactivées

#### 📍 Disponibilité dans l'ISO

**Automatiquement copié** lors de la création de l'ISO :
- ✅ Dans `C:\Windows\Setup\Scripts\`
- ✅ Sur le **Bureau de l'Administrateur** (accès immédiat via .cmd)

**Deux fichiers disponibles** :
- `Xpolaris-Apps-Manager.cmd` - Lanceur simplifié (recommandé)
- `Xpolaris-Apps-Manager.ps1` - Script complet

**Plus besoin de clé USB** pour dépannage ! 🎉

---

## �📄 PERSONNALISATION AUTOUNATTEND.XML

Le fichier `autounattend.xml` permet une **installation 100% automatique** de Windows.

### 🎯 Fonctionnalités incluses

✅ **Installation sans intervention** - Aucun clic requis  
✅ **Compte local** - Pas de compte Microsoft obligatoire  
✅ **Bypass réseau** (BypassNRO) - Option "Je n'ai pas internet" disponible  
✅ **Télémétrie désactivée** dès l'installation  
✅ **Applications winget** pré-installées  
✅ **Langue française** - Clavier AZERTY  
✅ **Thème sombre** activé  

### 🔧 Personnalisation

#### 🖥️ Nom de l'ordinateur

```xml
<ComputerName>WIN11-PC</ComputerName>
```
Changez `WIN11-PC` par le nom souhaité.

---

#### 👤 Compte utilisateur

```xml
<LocalAccount wcm:action="add">
    <Name>Admin</Name>
    <DisplayName>Administrateur</DisplayName>
    <Group>Administrators</Group>
    <Password>
        <Value>UABhAHMAcwB3AG8AcgBkADEAMgAzAAEAAAA=</Value>
    </Password>
</LocalAccount>
```

**⚠️ IMPORTANT** : Changez le mot de passe !

**Encoder votre mot de passe :**
```powershell
$Password = "VotreMotDePasse"
$EncodedPassword = [Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($Password + "AdministratorPassword"))
Write-Host $EncodedPassword
```

Copiez le résultat dans la balise `<Value>`.

---

#### 🔑 Clé produit (optionnel)

Décommentez et ajoutez votre clé :
```xml
<UserData>
    <ProductKey>
        <Key>XXXXX-XXXXX-XXXXX-XXXXX-XXXXX</Key>
        <WillShowUI>OnError</WillShowUI>
    </ProductKey>
    <AcceptEula>true</AcceptEula>
</UserData>
```

---

#### 🌍 Langue et fuseau horaire

```xml
<InputLocale>fr-FR</InputLocale>
<SystemLocale>fr-FR</SystemLocale>
<TimeZone>Romance Standard Time</TimeZone>
```

**Autres fuseaux horaires :**
- **Paris/Bruxelles** : `Romance Standard Time`
- **Londres** : `GMT Standard Time`
- **New York** : `Eastern Standard Time`
- **Tokyo** : `Tokyo Standard Time`
- **UTC** : `UTC`

---

#### 📦 Applications installées automatiquement

> ⚠️ **IMPORTANT** : Les applications sont installées **au premier démarrage de Windows** (via tâche planifiée), **PAS dans l'image ISO**. Elles se téléchargent depuis Internet lors de la première connexion.

**Mécanisme d'installation :**
1. `SetupComplete.cmd` copie `InstallApps.ps1` vers `C:\`
2. Tâche planifiée `XpolarisInstallApps` se lance **1 minute après connexion**
3. Script attend que **winget soit disponible** (max 15 minutes)
4. Installe les 6 applications en mode silencieux
5. Crée un log détaillé dans `C:\InstallApps.log`
6. Se supprime automatiquement après exécution

**Applications incluses (via winget) :**
- 🌐 **Google Chrome** (`Google.Chrome`) - Navigateur web
- 📦 **7-Zip** (`7zip.7zip`) - Archiveur
- 🎬 **VLC Media Player** (`VideoLAN.VLC`) - Lecteur multimédia
- 📝 **Notepad++** (`Notepad++.Notepad++`) - Éditeur de texte avancé
- 🖥️ **TeamViewer** (`TeamViewer.TeamViewer`) - Accès à distance
- 💿 **Virtual CloneDrive** (`ElaborateBytes.VirtualCloneDrive`) - Montage ISO

⏱️ **Durée d'installation** : 10-20 minutes au premier démarrage (selon connexion Internet)

⚠️ **IMPORTANT** : 
- **Connexion Internet requise** lors du premier démarrage
- Si winget indisponible : Un **raccourci Bureau** est créé automatiquement pour installation manuelle
- **Log d'installation** : `C:\InstallApps.log` (logs détaillés avec débogage)
- **Si problème** : Consultez la section [Guide de Débogage](#-guide-de-débogage)

**Ajouter une application :**
```xml
<RunSynchronousCommand>
    <Order>17</Order>
    <Path>cmd /c winget install --id VotreApp.ID --silent --accept-source-agreements --accept-package-agreements</Path>
</RunSynchronousCommand>
```

Trouvez l'ID sur : https://winget.run

---

#### 🚫 Bypass réseau (BypassNRO)

**Déjà inclus** dans le fichier :
```xml
<RunSynchronousCommand>
    <Order>4</Order>
    <Path>reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\OOBE" /v BypassNRO /t REG_DWORD /d 1 /f</Path>
    <Description>Activer l'option "Je n'ai pas internet"</Description>
</RunSynchronousCommand>
```

✅ **Résultat** : Le bouton "Je n'ai pas internet" apparaît pendant l'installation, même sans connexion réseau.

---

#### 💾 Configuration des partitions

**Configuration automatique :**
- **300 MB** - Partition EFI (System)
- **128 MB** - Partition MSR (Microsoft Reserved)
- **Reste** - Partition Windows (C:)

⚠️ **Par défaut, le disque est effacé !**

Pour **ne pas effacer** (dual-boot) :
```xml
<!-- <WillWipeDisk>true</WillWipeDisk> -->
```

---

### 📥 Utilisation de l'autounattend.xml

1. **Copiez** `autounattend.xml` à la **racine** de votre clé USB ou ISO
2. **Vérifiez** que le nom est exact : `autounattend.xml` (minuscules)
3. **Bootez** depuis la clé/ISO
4. **L'installation démarre automatiquement** !

**Aucune intervention requise** - Attendez 20-30 minutes.

---

## 📁 STRUCTURE DES FICHIERS

```
📁 Dossier principal (Windows Customizer v3.5.0)
│
├── 📄 Windows-CustomizeMaster.ps1      [Script principal - 1927 lignes, 92 KB]
├── 📄 autounattend.xml                 [Config installation - 298 lignes, 15 KB]
├── 🖼️ XpolarisWallpaper.bmp            [Fond d'écran Full HD - 1920x1080, 1 MB]
├── 📄 RemoveBloatware.ps1              [Nettoyage bloatware - 4 KB]
├── 📄 InstallApps.ps1                  [Installation 6 apps - 7 KB]
├── 📄 ApplyWallpaper.ps1               [Force fond d'écran - 4 KB]
├── 📄 Create-Wallpaper.ps1             [Générateur wallpaper - 3 KB]
├── � Recompile-Exe.ps1                [Script recompilation - 4 KB]
├── 📄 Recompile-Exe.cmd                [Batch recompilation - 1 KB]
├── 📄 GUIDE_COMPLET.md                 [Documentation complète - 42 KB]
│
├── 📁 sources/
│   ├── install.wim                     [Image Windows - 2-5 GB]
│   ├── install_backup.wim              [Sauvegarde - Créée par Option 8]
│   ├── boot.wim                        [Image boot Windows]
│   └── [autres fichiers Windows...]
│
├── 📁 CustomizeWork/                   [Dossier de travail temporaire]
│   ├── CustomISO/                      [ISO personnalisé en construction]
│   ├── Mount/                          [Point de montage DISM]
│   ├── edition_count.txt               [Cache nombre d'éditions]
│   └── install_customized.txt          [Marqueur personnalisation]
│
├── 📁 boot/                            [Structure bootable BIOS]
│   ├── bcd
│   ├── boot.sdi
│   ├── etfsboot.com                    [Fichier critique BIOS]
│   └── ...
│
├── 📁 efi/                             [Structure bootable UEFI]
│   └── microsoft/boot/
│       └── efisys.bin                  [Fichier critique UEFI]
│
└── 📁 [autres dossiers ISO Windows]    [support/, ...]
```

### Fichiers essentiels du projet (10 fichiers)

| Fichier | Taille | Description |
|---------|--------|-------------|
| `Windows-CustomizeMaster.ps1` | 92 KB | Script principal avec toute la logique |
| `autounattend.xml` | 15 KB | Configuration installation automatique Windows |
| `XpolarisWallpaper.bmp` | 1 MB | Fond d'écran Full HD avec logo Xpolaris centré |
| `RemoveBloatware.ps1` | 4 KB | Supprime bloatware au 1er démarrage |
| `InstallApps.ps1` | 7 KB | Installe 6 apps via winget (avec logs débogage) |
| `ApplyWallpaper.ps1` | 4 KB | Force application fond d'écran (3 méthodes) |
| `Create-Wallpaper.ps1` | 3 KB | Génère fond d'écran 1920x1080 à partir du logo |
| `Recompile-Exe.ps1` | 4 KB | Recompile le .exe si corrompu |
| `Recompile-Exe.cmd` | 1 KB | Batch pour recompilation rapide |
| `GUIDE_COMPLET.md` | 42 KB | Documentation complète (ce fichier) |

### Fichiers créés pendant l'installation Windows

Après installation, ces fichiers sont créés automatiquement dans `C:\` :

| Fichier | Objectif | Contenu |
|---------|----------|---------|
| `C:\SetupComplete.log` | Log configuration post-installation | Copie fichiers, création tâches, Registry |
| `C:\ApplyWallpaper.log` | Log application fond d'écran | 3 méthodes (HKLM, HKCU, API Windows) |
| `C:\InstallApps.log` | Log installation applications | Détection winget, installation 6 apps |
| `C:\RemoveBloatware.log` | Log nettoyage bloatware | Suppression packages indésirables |
| `C:\RemoveBloatware.ps1` | Script nettoyage | Copié depuis l'ISO |
| `C:\InstallApps.ps1` | Script installation apps | Copié depuis l'ISO |
| `C:\ApplyWallpaper.ps1` | Script fond d'écran | Copié depuis l'ISO |

### Fichiers à distribuer

**Minimum requis pour utiliser l'outil :**
1. `Windows-CustomizeMaster.ps1` (script principal)
2. `autounattend.xml` (installation automatique)
3. `XpolarisWallpaper.bmp` (fond d'écran)
4. `RemoveBloatware.ps1` (nettoyage)
5. `InstallApps.ps1` (applications)
6. `ApplyWallpaper.ps1` (force wallpaper)
7. Structure ISO Windows complète avec `install.wim`

**Optionnel mais recommandé :**
- `Create-Wallpaper.ps1` (pour regénérer le fond d'écran)
- `GUIDE_COMPLET.md` (documentation)
- `Recompile-Exe.ps1/cmd` (pour dépannage)

---

## 🔧 FICHIERS DE LANCEMENT ET RECOMPILATION

### Fichiers de lancement disponibles

**UN SEUL fichier à utiliser** :

| Fichier | Type | Droits Admin | Notes |
|---------|------|--------------|-------|
| **`Windows-CustomizeMaster.exe`** | EXE | ✅ Auto | ⭐ **SEUL FICHIER À UTILISER** - Double-clic et c'est parti |
| `Windows-CustomizeMaster.ps1` | PS1 | ⚠️ Manuel | Source PowerShell (pour développement uniquement) |

### Fichiers de recompilation (si besoin)

Si l'exécutable ne fonctionne pas, ces fichiers permettent de le recompiler :
- `Recompile-Exe.cmd` (double-clic pour recompiler)
- `Recompile-Exe.ps1` (script de recompilation)

### Recompiler l'exécutable

#### ⚠️ Symptômes d'un exe corrompu
- Taille anormale : **< 500 KB** (doit faire 2-5 MB)
- Écran noir au lancement
- Fermeture immédiate sans affichage

#### ✅ Solution : Recompilation

**Méthode simple** :
```
Double-cliquez sur → Recompile-Exe.cmd
```

Le script va automatiquement :
1. ✅ Vérifier que ps2exe est installé (et l'installer si besoin)
2. ✅ Supprimer l'ancien exe
3. ✅ Compiler le nouveau exe (1-2 minutes)
4. ✅ Valider la taille et l'intégrité

**Méthode manuelle PowerShell** :

### Notes sur ps2exe

- **Faux positifs antivirus** : Normal pour les scripts PowerShell compilés
- **Taille normale** : 2-5 MB (selon la complexité du script)
- **Module requis** : `ps2exe` de PowerShell Gallery
- **Compatibilité** : Windows 10/11 avec PowerShell 5.1+

---

---

## 💿 CRÉATION DE L'ISO BOOTABLE

### Méthode avec oscdimg (Recommandé)

L'outil utilise **oscdimg.exe** du Windows ADK pour créer des ISO bootables optimisés pour VMware/VirtualBox.

#### Installation automatique du Windows ADK

Si oscdimg n'est pas détecté, le script propose :
1. ✅ **Téléchargement automatique** de l'installateur ADK
2. ✅ **Lancement assisté** de l'installation
3. ✅ **Sélection automatique** du composant "Deployment Tools"

**Emplacement typique** :
```
C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Deployment Tools\amd64\Oscdimg\oscdimg.exe
```

#### Paramètres oscdimg utilisés

L'ISO est créé avec les paramètres suivants :
```cmd
oscdimg -m -o -u2 -udfver102 -l"CCSA_X64FRE_FR-FR_DV9" 
        -bootdata:2#p0,e,b"boot\etfsboot.com"#pEF,e,b"efi\microsoft\boot\efisys.bin" 
        [Source] [Destination.iso]
```

**Explication des paramètres :**
- `-m` : Ignore la limite de 31 caractères pour les noms de fichiers
- `-o` : Optimise l'utilisation de l'espace disque
- `-u2` : Système de fichiers UDF (Universal Disk Format)
- `-udfver102` : Version UDF 1.02 pour compatibilité maximale
- `-l"CCSA_X64FRE_FR-FR_DV9"` : **Label de volume Windows standard** (requis pour VMware)
- `-bootdata:2#...` : Configuration dual boot (BIOS Legacy + UEFI)
  - `p0,e,b"boot\etfsboot.com"` : Boot BIOS
  - `pEF,e,b"efi\microsoft\boot\efisys.bin"` : Boot UEFI

#### Durée de création

⏱️ **Temps estimé** : 5-10 minutes pour un ISO de ~6-7 GB

Si la création est **instantanée (quelques secondes)**, il y a une erreur !

#### Compatibilité virtualization

✅ **VMware Workstation** : Label de volume + dual boot reconnus  
✅ **VirtualBox** : Compatible BIOS et UEFI  
✅ **Hyper-V** : Fonctionne en Generation 1 et 2  
✅ **QEMU/KVM** : Compatible avec `-boot d`  

### Mode Debug

Le script affiche maintenant :
1. 📝 La **commande oscdimg complète** avant exécution
2. 🪟 Une **fenêtre CMD** avec la progression en temps réel
3. 📊 Le **pourcentage de fichiers copiés**
4. ✅ Le **code de sortie** (0 = succès)

**En cas d'erreur**, la sortie oscdimg est affichée pour diagnostic.

### Méthode alternative : Rufus (USB uniquement)

Si oscdimg échoue ou pour créer une **clé USB bootable** :

1. Le script cherche Rufus dans :
   - Dossier du projet
   - Downloads
   - Bureau
   - C:\Tools\

2. Si introuvable, propose de télécharger Rufus 4.6

3. **Utilisation** :
   - Sélectionnez `install.wim` (pas le dossier CustomISO)
   - Choisissez votre clé USB
   - Mode : **GPT + UEFI** ou **MBR + BIOS Legacy**

⚠️ **Important** : Rufus ne peut pas créer d'ISO depuis un dossier, uniquement des clés USB.

---

## 🔐 PROBLÈME : COMPTE ADMINISTRATEUR DÉSACTIVÉ

### Symptôme

Après l'installation, Windows affiche :
```
Le compte a été désactivé. Contactez votre administrateur système.
```

### Cause

Windows 11 **désactive automatiquement** le compte "Administrateur" intégré par sécurité, même si créé dans `autounattend.xml`.

### ✅ Solution immédiate : Mode sans échec

**Méthode la plus rapide** :

1. Au démarrage de Windows, appuyez sur **Shift + F8** (ou juste **F8**)
2. Sélectionnez **"Dépannage"** → **"Options avancées"** → **"Paramètres de démarrage"**
3. Cliquez sur **"Redémarrer"**
4. Appuyez sur **F4** pour **"Activer le mode sans échec"**
5. Le compte **Administrateur** sera automatiquement actif
6. Connectez-vous (mot de passe vide)
7. **Créez un nouveau compte utilisateur** :
   ```
   Paramètres → Comptes → Famille et autres utilisateurs → Ajouter un utilisateur
   ```
8. Redémarrez en mode normal
9. Connectez-vous avec le nouveau compte

### ✅ Solution permanente : Correction autounattend.xml

**Déjà appliqué dans v3.5.0+** : Le script active automatiquement le compte au premier démarrage.

Ajout dans `<FirstLogonCommands>` :
```xml
<SynchronousCommand wcm:action="add">
    <Order>1</Order>
    <CommandLine>cmd /c net user Administrateur /active:yes</CommandLine>
    <Description>Activer le compte Administrateur</Description>
</SynchronousCommand>
```

**Pour appliquer la correction** :
1. Modifiez `autounattend.xml` (déjà fait dans ce projet)
2. Relancez **Option [6]** pour recréer l'ISO
3. Réinstallez Windows avec le nouvel ISO

### Informations de connexion

**Compte par défaut** :
- 👤 **Utilisateur** : `Administrateur`
- 🔑 **Mot de passe** : *(aucun - vide)*

⚠️ **Recommandation de sécurité** : Créez immédiatement un compte utilisateur avec mot de passe fort après la première connexion.

---

## ❓ FAQ

### 🔹 Erreur "Fichiers de boot manquants" ou "Structure ISO incomplète"

**Symptômes** :
- ❌ `Fichiers de boot manquants après copie`
- ❌ `boot\etfsboot.com MANQUANT`
- ❌ `efi\microsoft\boot\efisys.bin MANQUANT`
- ⚠️ `STRUCTURE ISO INCOMPLÈTE` dans le menu principal

**Cause** : Vous avez copié **uniquement** le dossier `sources\` au lieu de **toute l'ISO Windows**.

**Solution complète** :
1. **Montez votre ISO Windows** :
   - Clic droit sur le fichier `.iso` → **"Monter"**
   - Ou double-cliquez sur l'ISO
   - Une lettre de lecteur apparaît (ex: D:, E:)

2. **Ouvrez le lecteur monté** et vérifiez que vous voyez :
   ```
   boot/        ← Important !
   efi/         ← Important !
   sources/
   support/
   autorun.inf
   bootmgr      ← Important !
   bootmgr.efi  ← Important !
   setup.exe
   ```

3. **Sélectionnez TOUT** : `Ctrl+A`

4. **Copiez** : `Ctrl+C`

5. **Collez dans le dossier du script** : 
   ```
   E:\Projets Visual Studio\Windows Customizer v3.5.0\
   ```

6. **Attendez la fin de la copie** (~5-10 minutes, selon la taille)

7. **Relancez le script** : L'avertissement aura disparu ! ✅

> 💡 **Note** : Sans les dossiers `boot\` et `efi\`, impossible de créer une ISO bootable.

---

### 🔹 L'exécutable .exe affiche un écran noir

**Problème connu** : ps2exe peut avoir des limitations avec certaines configurations système.

**Solutions** :
1. **Fermez VS Code** avant de lancer l'exécutable (évite les conflits de ressources)
2. **Lancez en tant qu'administrateur** (clic droit → Exécuter en tant qu'administrateur)
3. **Alternative** : Utilisez le script PowerShell directement :
   ```powershell
   .\Windows-CustomizeMaster.ps1
   ```

---

### 🔹 Rufus n'est pas détecté automatiquement

**Vérifications :**
1. Rufus doit être nommé `rufus*.exe` (ex: `rufus-4.11p.exe`)
2. Placez-le dans un des emplacements :
   - Dossier du projet
   - Downloads
   - Bureau
   - C:\Tools\
   - Racine d'un disque

**Alternative** : L'outil télécharge automatiquement Rufus 4.6 depuis GitHub si introuvable.

---

### 🔹 Erreur "Échec de l'installation de Windows 11" pendant l'installation

**Symptômes** : Message d'erreur pendant la phase "Installation en cours de Windows 11"

**Causes fréquentes** :
1. Commandes invalides dans `autounattend.xml` (redirections `>`, syntaxe incorrecte)
2. Fichiers manquants dans `sources\$OEM$\$$\Setup\Scripts\`
3. Scripts PowerShell qui échouent (RemoveBloatware.ps1, InstallApps.ps1)
4. Trop de commandes dans `RunSynchronous` ou `FirstLogonCommands`
5. Configuration disque incompatible avec le matériel

**Solutions** :

**✅ Solution 1 : Utiliser autounattend.xml corrigé (Recommandé)**
1. Le fichier a été automatiquement corrigé (suppression redirections invalides)
2. Recréez l'ISO avec options [4] + [6]
3. Réinstallez Windows avec le nouvel ISO

**✅ Solution 2 : Utiliser la version minimale**
1. Renommez : `autounattend.xml` → `autounattend-complet.xml`
2. Renommez : `autounattend-minimal.xml` → `autounattend.xml`
3. Recréez l'ISO avec [4] + [6]
4. Installez Windows (configuration minimale, sans personnalisations)

**Version minimale inclut** :
- ✅ Langue française (fr-FR)
- ✅ Configuration disque automatique
- ✅ Compte utilisateur local "Xpolaris"
- ✅ Bypass réseau (BypassNRO)
- ✅ Activation compte Administrateur
- ❌ Pas de scripts PowerShell
- ❌ Pas de FirstLogonCommands
- ❌ Pas de personnalisations Xpolaris

**✅ Solution 3 : Installation manuelle (sans autounattend.xml)**
1. Supprimez `autounattend.xml` de la racine de l'ISO
2. Installez Windows normalement (saisies manuelles)
3. Après installation, exécutez manuellement :
   ```powershell
   C:\RemoveBloatware.ps1
   C:\InstallApps.ps1
   C:\ApplyWallpaper.ps1
   ```

**🔍 Diagnostic avancé** :

Si l'erreur persiste, vérifiez :

1. **Logs d'installation Windows** (après échec, avant redémarrage) :
   ```
   X:\Windows\Panther\setupact.log
   X:\Windows\Panther\setuperr.log
   ```

2. **Fichiers présents dans l'ISO** :
   ```
   sources\$OEM$\$$\Setup\Scripts\SetupComplete.cmd
   sources\$OEM$\$$\Setup\Scripts\RemoveBloatware.ps1
   sources\$OEM$\$$\Setup\Scripts\InstallApps.ps1
   sources\$OEM$\$$\Setup\Scripts\ApplyWallpaper.ps1
   sources\$OEM$\$$\Setup\Scripts\XpolarisWallpaper.bmp
   ```

3. **Test en VM** :
   - Testez l'installation dans VirtualBox/VMware avant l'installation réelle
   - Permet de voir les erreurs sans risque

---

### 🔹 "Je n'ai pas internet" n'apparaît pas pendant l'installation

**Cause** : Le fichier `autounattend.xml` n'est pas à la racine de la clé USB/ISO.

**Solution** :
1. Vérifiez que `autounattend.xml` est à la **racine** (pas dans un sous-dossier)
2. Nom exact : `autounattend.xml` (minuscules)
3. Recréez l'ISO avec Option [6]

---

### 🔹 L'installation demande une clé produit

**Cause** : Section `<ProductKey>` commentée ou absente.

**Solutions** :
1. Utilisez une clé générique Windows (KMS)
2. Ajoutez votre clé dans `autounattend.xml`
3. Appuyez sur "Je n'ai pas de clé produit" et activez après installation

---

### 🔹 Le logo Xpolaris n'apparaît pas dans "Informations système"

**Vérifications :**
1. Les fichiers `XpolarisLogo.ps1` et `Xpolaris.jpg` sont bien présents dans le dossier du script
2. L'ISO a été créée avec l'option [6] "Créer support bootable"
3. L'installation Windows s'est bien déroulée depuis cette ISO

**Diagnostic post-installation :**
1. Fichier `C:\Windows\System32\oemlogo.bmp` existe ?
2. Registre modifié ? (`HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation`)

**Solution** : 
- Si les fichiers sont absents du dossier : Ajoutez-les et recréez l'ISO
- Si le logo n'apparaît pas après installation : Exécutez manuellement `C:\XpolarisLogo.ps1` (copié lors de l'installation)

> 💡 **Note** : `XpolarisLogo_Preview.ps1` sert uniquement à prévisualiser le logo localement, pas pour l'installation.

---

### 🔹 L'installation est en anglais malgré autounattend.xml

**Cause** : ISO Windows anglais + `autounattend.xml` français

**Solutions** :
1. Utilisez une ISO française Windows
2. Modifiez `<InputLocale>` et `<SystemLocale>` dans `autounattend.xml`
3. Installez le pack langue après installation

---

### 🔹 Windows fait planter VS Code au lancement du script

**Problème connu** : Le script utilise beaucoup de ressources (DISM, montages).

**Solutions** :
1. **Fermez VS Code** avant d'exécuter l'outil (solution recommandée)
2. Lancez l'exécutable depuis l'Explorateur Windows (hors VS Code)
3. Augmentez la RAM allouée à VS Code (settings.json)

⚠️ **Important** : Ne pas lancer le script `.ps1` depuis le terminal VS Code !

---

### 🔹 Erreur "DISM failed to mount"

**Causes possibles :**
1. Pas assez d'espace disque (minimum 15 GB)
2. Antivirus bloque DISM
3. Image `install.wim` corrompue

**Solutions** :
1. Libérez de l'espace avec Option [9]
2. Désactivez temporairement l'antivirus
3. Restaurez depuis la sauvegarde (Option [7])
4. Téléchargez une nouvelle ISO Windows

---

### 🔹 Comment utiliser avec Windows 10 ?

**Le script est universel !**

1. Montez/Extrayez votre ISO Windows 10
2. Placez les fichiers du script dans le dossier
3. Lancez `Xpolaris-WindowsCustomizer.bat`
4. Choisissez l'édition Windows 10 souhaitée (Option [2])
5. Continuez normalement

✅ Fonctionne avec **Windows 10 Home, Pro, Enterprise, LTSC**

---

### 🔹 Comment utiliser avec Windows Server ?

**Compatible également !**

Même processus que Windows 10/11 :
- Windows Server 2019
- Windows Server 2022
- Windows Server 2025

⚠️ **Note** : Certaines optimisations (Xbox, Cortana) ne s'appliquent pas sur Server.

---

### 🔹 L'ISO créée ne boote pas

**Vérifications :**
1. Clé USB formatée en **GPT** (UEFI) ou **MBR** (BIOS Legacy)
2. Option "Secure Boot" dans le BIOS
3. Rufus configuré en mode "Standard Windows Installation"

**Solution** : Recréez la clé USB avec Rufus :
- **UEFI** : GPT + FAT32
- **BIOS** : MBR + NTFS

---

### 🔹 Puis-je modifier les optimisations appliquées ?

**Oui !** Éditez `Windows-CustomizeMaster.ps1` :

Cherchez la fonction `Start-CustomizeImage` (ligne ~600) :
```powershell
function Start-CustomizeImage {
    # ...
    
    # Désactiver la télémétrie
    reg add "HKLM\$RegPath\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v AllowTelemetry /t REG_DWORD /d 0 /f
    
    # Commentez/supprimez les optimisations non désirées
}
```

---

### 🔹 Comment ajouter des applications à autounattend.xml ?

1. Trouvez l'ID winget sur https://winget.run
2. Ajoutez dans `autounattend.xml` :

```xml
<RunSynchronousCommand>
    <Order>17</Order>
    <Path>cmd /c winget install --id VotreApp.ID --silent --accept-source-agreements --accept-package-agreements</Path>
    <Description>Installation VotreApp</Description>
</RunSynchronousCommand>
```

3. Incrémentez `<Order>` pour chaque nouvelle application

---

## 🎓 SUPPORT ET CONTRIBUTION

### 📧 Contact

**Projet** : Xpolaris Windows Customizer  
**Version** : 2.2.0  
**Date** : 21 décembre 2025  
**Licence** : Usage personnel et éducatif

### 🐛 Signaler un bug

Si vous rencontrez un problème :
1. Vérifiez la section [FAQ](#-faq)
2. Consultez les logs dans le dossier `TEMP\`
3. Notez le message d'erreur exact
4. Testez avec une nouvelle ISO Windows propre

### ⭐ Fonctionnalités futures

- Support multi-langue (EN, ES, DE)
- Interface graphique WPF (alternative console)
- Export de configuration personnalisée
- Intégration pilotes automatique
- Mode silencieux complet

---

## � GUIDE DE DÉBOGAGE

### 📊 Fichiers de Logs Automatiques

Après l'installation de Windows, **4 fichiers de log** sont créés automatiquement dans `C:\` pour vous aider à diagnostiquer les problèmes :

| Fichier | Objectif | Vérifie |
|---------|----------|---------|
| `C:\SetupComplete.log` | Configuration post-installation | Copie des fichiers, création tâches planifiées |
| `C:\ApplyWallpaper.log` | Application fond d'écran | Fond d'écran Xpolaris appliqué (3 méthodes) |
| `C:\InstallApps.log` | Installation applications | winget disponible, 6 apps installées |
| `C:\RemoveBloatware.log` | Nettoyage bloatware | Suppression packages indésirables |

### 🕐 Chronologie d'Exécution

```
Installation Windows
        ↓
[AVANT 1ère connexion]
        ↓
    SetupComplete.cmd                 → C:\SetupComplete.log
    • Copie XpolarisWallpaper.bmp vers C:\Windows\Web\Wallpaper\
    • Copie InstallApps.ps1 vers C:\
    • Copie ApplyWallpaper.ps1 vers C:\
    • Configure Registry OEM
    • Crée 2 tâches planifiées
        ↓
[1ère connexion utilisateur]
        ↓
    T+30 secondes
        ↓
    XpolarisApplyWallpaper            → C:\ApplyWallpaper.log
    • Vérifie fichier wallpaper (1 MB)
    • Registry HKLM (tous utilisateurs)
    • Registry HKCU (utilisateur actuel)
    • API Windows (force rafraîchissement)
    • Se supprime automatiquement
        ↓
    T+1 minute
        ↓
    XpolarisInstallApps               → C:\InstallApps.log
    • Attend 60 secondes (démarrage complet)
    • Détecte winget (max 15 minutes)
    • Installe 6 applications (Chrome, 7-Zip, VLC, etc.)
    • OU crée raccourci Bureau si winget indisponible
    • Se supprime automatiquement
        ↓
[Installation terminée]
```

### ❌ Problème : Fond d'écran non appliqué

**Symptômes** : Fond d'écran noir ou bleu par défaut au lieu du logo Xpolaris

**Diagnostic** :

1. **Vérifier le fichier log** :
   ```powershell
   Get-Content C:\ApplyWallpaper.log
   ```
   Recherchez : `[OK] Fond d'ecran applique via API Windows`

2. **Vérifier si le fichier existe** :
   ```powershell
   Test-Path "C:\Windows\Web\Wallpaper\XpolarisWallpaper.bmp"
   ```
   Si `False` → Vérifiez `C:\SetupComplete.log`

3. **Vérifier la Registry** :
   ```powershell
   Get-ItemProperty "HKCU:\Control Panel\Desktop" -Name Wallpaper
   Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name Wallpaper
   ```

**Solutions** :

1. **Attendre 1-2 minutes** après la connexion (tâche planifiée en cours)

2. **Appliquer manuellement** :
   ```powershell
   powershell -ExecutionPolicy Bypass -File C:\ApplyWallpaper.ps1
   ```

3. **Vérifier la tâche planifiée** :
   ```powershell
   schtasks /Query /TN "XpolarisApplyWallpaper"
   ```

4. **Forcer via l'interface** :
   - Clic droit Bureau → Personnaliser → Arrière-plan
   - Parcourir → `C:\Windows\Web\Wallpaper\XpolarisWallpaper.bmp`

### ❌ Problème : Applications non installées

**Symptômes** : Chrome, 7-Zip, VLC, Notepad++, TeamViewer, Virtual CloneDrive absents

**Diagnostic** :

1. **Vérifier le fichier log** :
   ```powershell
   Get-Content C:\InstallApps.log
   ```
   Recherchez : `[OK] winget est disponible` ou `[ERREUR] winget n'est pas disponible`

2. **Vérifier winget** :
   ```powershell
   winget --version
   ```
   Si erreur → Installez **App Installer** depuis Microsoft Store

**Solutions** :

1. **Attendre 5-10 minutes** après la connexion (détection winget peut prendre du temps)

2. **Vérifier la connexion Internet** :
   ```powershell
   Test-Connection google.com -Count 2
   ```

3. **Utiliser le raccourci Bureau** (créé automatiquement si winget indisponible) :
   - Double-cliquez sur `Installer Applications Xpolaris.lnk`

4. **Installation manuelle** :
   ```powershell
   powershell -ExecutionPolicy Bypass -File C:\InstallApps.ps1
   ```

5. **Installation manuelle app par app** :
   ```powershell
   winget install Google.Chrome
   winget install 7zip.7zip
   winget install VideoLAN.VLC
   winget install Notepad++.Notepad++
   winget install TeamViewer.TeamViewer
   winget install ElaborateBytes.VirtualCloneDrive
   ```

### 🧪 Commandes de Diagnostic

```powershell
# Lister tous les logs
Get-ChildItem C:\ -Filter *.log | Select Name, Length, LastWriteTime

# Vérifier les tâches planifiées Xpolaris
schtasks /Query /TN "XpolarisApplyWallpaper"
schtasks /Query /TN "XpolarisInstallApps"

# Vérifier les fichiers copiés
Get-ChildItem C:\ -Filter *.ps1 | Select-Object Name, Length

# Afficher les applications installées via winget
winget list

# Forcer la réexécution des scripts
powershell -ExecutionPolicy Bypass -File C:\ApplyWallpaper.ps1
powershell -ExecutionPolicy Bypass -File C:\InstallApps.ps1
```

### ✅ Checklist de Validation Post-Installation

Après le 1er démarrage, vérifiez :

- [ ] **4 fichiers `.log`** présents dans `C:\`
- [ ] **Fond d'écran Xpolaris** affiché (logo centré sur fond noir)
- [ ] **6 applications** installées (Menu Démarrer)
- [ ] **Bloatware supprimé** (pas de Candy Crush, Xbox Game Bar, etc.)
- [ ] **Compte Administrateur** activé
- [ ] **Tâches planifiées** supprimées automatiquement (après exécution)

### 📦 Applications Installées Automatiquement

| Application | ID winget | Taille | Installation |
|------------|-----------|--------|--------------|
| 🌐 Google Chrome | `Google.Chrome` | ~90 MB | Silencieuse |
| 📦 7-Zip | `7zip.7zip` | ~2 MB | Silencieuse |
| 🎬 VLC Media Player | `VideoLAN.VLC` | ~40 MB | Silencieuse |
| 📝 Notepad++ | `Notepad++.Notepad++` | ~5 MB | Silencieuse |
| 🖥️ TeamViewer | `TeamViewer.TeamViewer` | ~25 MB | Silencieuse |
| 💿 Virtual CloneDrive | `ElaborateBytes.VirtualCloneDrive` | ~2 MB | Silencieuse |

**Durée totale** : 10-20 minutes (selon connexion Internet)

---

## 📜 CHANGELOG

### v3.0.0 (01/02/2026) - Interface Graphique WPF 🎨

#### 🎨 NOUVELLE Interface Graphique (GUI)

**Fichiers ajoutés** :
- ✅ **Xpolaris-GUI.ps1** (50 KB) - Interface graphique WPF complète
- ✅ **Compile-GUI.ps1** (3 KB) - Script de compilation GUI vers EXE
- ✅ **Xpolaris-GUI.exe** (60 KB) - Exécutable interface graphique
- ✅ **README-VERSIONS.md** - Documentation comparative Console vs GUI

**Caractéristiques GUI v3.0.0** :
- ✅ **Design moderne Windows 11** : Fluent Design, coins arrondis, ombres portées
- ✅ **4 onglets organisés** :
  - 📁 **Sélection ISO** : Parcourir ou Drag & Drop
  - 🎨 **Personnalisation** : Checkboxes pour composants/bloatware/apps
  - 💿 **Création ISO** : Processus complet automatisé avec progress bar
  - 📋 **Logs** : Console temps réel avec export
- ✅ **Thème commutable** : Sombre 🌙 (par défaut) / Clair ☀️
- ✅ **Drag & Drop** : Glisser-déposer fichiers ISO directement
- ✅ **Progress bars animées** : Visualisation des étapes (0-100%)
- ✅ **Logs en temps réel** : Style terminal (Consolas, fond noir, texte vert)
- ✅ **Export logs** : Sauvegarde des logs vers fichier texte
- ✅ **Interface responsive** : Fenêtre redimensionnable 1100x750px

**Sélection multiple** :
- ✅ Composants Windows à supprimer (5 options)
- ✅ Bloatware à supprimer (12 options)
- ✅ Applications à installer (6 options)
- ✅ Options avancées (5 options)

**Fonctionnalités avancées** :
- ✅ **Chargement éditions** : Liste automatique des éditions Windows dans l'ISO
- ✅ **Bouton d'arrêt** : Interrompre le processus en cours
- ✅ **Validation intelligente** : Vérification fichiers avant traitement
- ✅ **Fenêtre À propos** : Informations version et crédits

#### 📊 Deux Versions Maintenues

| Version | Fichier | Interface | Public cible |
|---------|---------|-----------|--------------|
| **Console v2.2.0** | Xpolaris-Windows-Customizer.exe | Texte ASCII | Utilisateurs avancés, automation |
| **GUI v3.0.0** 🆕 | Xpolaris-GUI.exe | Graphique WPF | Débutants, confort visuel |

**Philosophie** :
- ✅ **Deux interfaces, même puissance** : Fonctionnalités identiques
- ✅ **Choix utilisateur** : Chacun selon sa préférence
- ✅ **Compatibilité préservée** : Version console toujours disponible
- ✅ **Architecture unifiée** : Même backend de personnalisation

#### 🔧 Améliorations Techniques

**Compilation** :
- ✅ **ps2exe GUI mode** : `-noConsole:$true` (pas de console en arrière-plan)
- ✅ **Icône personnalisable** : Support fichier .ico (optionnel)
- ✅ **Métadonnées complètes** : Titre, description, version, copyright
- ✅ **Backup automatique** : Ancien EXE renommé en Xpolaris-GUI-OLD.exe

**Code XAML** :
- ✅ **5 styles personnalisés** : ModernButton, CheckBox, TextBlock, GroupBox, TabItem
- ✅ **Layout fluide** : Grid avec RowDefinitions/ColumnDefinitions
- ✅ **Événements WPF** : Click, DragOver, Drop, Add_*
- ✅ **Dispatcher threading** : Mise à jour UI depuis threads background

#### 📖 Documentation Mise à Jour

**GUIDE_COMPLET.md** :
- ✅ **Nouvelle section** : "VERSIONS DISPONIBLES : CONSOLE & GUI"
- ✅ **Tableau comparatif** : 9 critères (facilité, vitesse, mémoire, etc.)
- ✅ **Guide GUI détaillé** : 4 onglets documentés avec captures ASCII
- ✅ **Installation rapide** : 3 méthodes (GUI, Console, PowerShell)
- ✅ **Structure fichiers** : Passage de 5 à 7 fichiers (+ GUI)

**README-VERSIONS.md** (nouveau) :
- ✅ **Comparaison complète** : Console vs GUI
- ✅ **Captures d'écran** : Représentation ASCII des interfaces
- ✅ **Guide de choix** : Recommandations selon profil utilisateur
- ✅ **Changelog intégré** : Historique v2.2.0 → v3.0.0

#### 🎯 Expérience Utilisateur

**Améliorations UX** :
- ✅ **Première utilisation** : GUI recommandé pour débutants
- ✅ **Feedback visuel** : Progress bars, couleurs, icônes
- ✅ **Messages d'erreur** : MessageBox WPF avec icônes
- ✅ **Validation temps réel** : Désactivation boutons selon contexte
- ✅ **Logs horodatés** : Format [HH:mm:ss] automatique

**Accessibilité** :
- ✅ **Police moderne** : Segoe UI 13-14pt
- ✅ **Contraste élevé** : Thème sombre optimisé
- ✅ **Fenêtre centrée** : WindowStartupLocation="CenterScreen"
- ✅ **Curseur main** : Effet visuel sur boutons (Cursor="Hand")

---

### v2.2.0 (28/12/2025) - Consolidation Finale : Architecture Unifiée

#### 🎨 Nouveautés Visuelles
- ✅ **4 nouveaux logos modernes** générés à partir de XpolarisWallpaper.bmp
- ✅ **4 fonds d'écran Full HD** (1920x1080) avec logos intégrés
- ✅ **Aperçu composite** (XpolarisLogos_Preview.png) et documentation (README_LOGOS.md)

#### 📦 Consolidation des Scripts (9 → 5 fichiers, -44%)

**🔥 FUSION FINALE** :
- ✅ **InstallApps.ps1 + Xpolaris-PostInstall-Fix.ps1** → **Xpolaris-Apps-Manager.ps1** (TOUT-EN-UN)
- ✅ **Réduction de 44%** du nombre de fichiers vs version initiale
- ✅ **Architecture simplifiée** : Un seul fichier pour installation + dépannage

**Fichiers finaux** :
  - Windows-CustomizeMaster.ps1 (98 KB) - Script principal
  - Recompile-Exe.ps1 (2 KB) - Compilateur EXE
  - RemoveBloatware.ps1 (7 KB) - Nettoyage bloatware
  - **Xpolaris-Apps-Manager.ps1 (25 KB)** 🆕 - **Installation AUTO + Dépannage INTERACTIF**
  - ApplyWallpaper.ps1 (3 KB) - Application fond d'écran

#### 🤖 Nouveau Script Universel : Xpolaris-Apps-Manager.ps1

**MODE AUTO** (Tâche planifiée au 1er démarrage) :
- Paramètre `-AutoMode` détecté automatiquement
- Installation silencieuse des 6 applications
- Fallback intégré si winget indisponible
- Auto-suppression de la tâche planifiée
- Log détaillé : `C:\InstallApps.log`

**MODE INTERACTIF** (Double-clic pour dépannage) :
- Menu avec 5 options :
  1. Supprimer tâches planifiées
  2. Installer applications manquantes
  3. Supprimer bloatware restant
  4. TOUT CORRIGER (recommandé)
  5. Quitter
- Auto-élévation administrateur
- Vérification finale avec résumé

**Avantages de la fusion** :
- ✅ Code VLC unifié (pas de duplication, version 3.0.20)
- ✅ Détection automatique du mode d'exécution
- ✅ Un seul fichier à maintenir
- ✅ Architecture claire et logique

#### 🐛 Corrections Critiques
- ✅ **Encodage UTF-8 sans BOM** : Suppression emojis dans RemoveBloatware.ps1
  - Remplacement 🌐📦🎬📝🖥️💿 par [WEB][7Z][VLC][NPP][TV][VCD]
  - Fix erreurs PowerShell "Unexpected token" sur caractères spéciaux
- ✅ **Boucle infinie** : Auto-suppression tâche planifiée au démarrage du script
- ✅ **VLC incompatible** : Version 3.0.20 (downgrade depuis 3.0.21) + fallback
- ✅ **Xbox removal 0x80070032** : Arrêt services XblAuthManager, XblGameSave, XboxGipSvc
- ✅ **Politique d'exécution VM** : Ajout -ExecutionPolicy Bypass dans lanceur .cmd

#### 📊 Amélioration Système de Logs
- ✅ **SetupComplete.log** : Affiche [7/7] progression + vérification copies
- ✅ **InstallApps.log** : Détection winget 15 min + activation fallback si timeout
- ✅ **RemoveBloatware.log** : Liste 15+ packages supprimés (Teams, OneDrive, Xbox, etc.)
- ✅ **ApplyWallpaper.log** : 3 méthodes application (Registry HKLM/HKCU + API Windows)

#### 🔧 Optimisations Techniques
- ✅ **SetupComplete.cmd** : Appel avec paramètre `-AutoMode` pour mode automatique
- ✅ **Windows-CustomizeMaster.ps1** : Auto-copie Xpolaris-Apps-Manager vers ISO
  - Destination 1 : sources\$OEM$\$$\Setup\Scripts\
  - Destination 2 : sources\$OEM$\$$\Users\Administrateur\Desktop\ (lanceur .cmd)
- ✅ **Intégration ISO** : Scripts dépannage disponibles dès 1ère connexion

#### 📖 Documentation Enrichie
- ✅ **GUIDE_COMPLET.md** : Passage de 1481 à 1850+ lignes
- ✅ **Nouvelle section** : "Xpolaris-Apps-Manager.ps1 (TOUT-EN-UN)"
  - Deux modes d'utilisation (AUTO vs INTERACTIF)
  - Liste complète des 6 applications
  - Méthodes d'installation (winget + fallback)
- ✅ **Section mise à jour** : "Dépannage Automatique"
  - Utilisation du nouveau script unifié
  - Disponibilité sur le Bureau (fichier .cmd)

  - Types de corrections (VLC, Xbox, Apps, Tâches)
- ✅ **Table des matières** : Étendue à 14 sections (au lieu de 12)
- ✅ **Structure des fichiers consolidée** : Tableau comparatif avant/après

#### 🧪 Tests et Validation
- ✅ **Test VM** : Validation complète sur machine virtuelle
- ✅ **Test ISO** : Régénération après corrections du 28/12
- ✅ **Vérifications** :
  - 4/6 apps installées (Chrome, 7-Zip, Notepad++, TeamViewer)
  - Bloatware partiellement supprimé (Teams, OneDrive OK ; Xbox pending reboot)
  - Scripts dépannage présents sur Bureau après installation
  - Aucune erreur encodage UTF-8

---

### v3.5.0 (26/12/2025) - Débogage Complet
- ✅ **Système de logs automatiques** (4 fichiers dans C:\)
- ✅ **ApplyWallpaper.ps1** : Force application fond d'écran (3 méthodes)
- ✅ **InstallApps.ps1 amélioré** : Attente 15 min + raccourci Bureau
- ✅ **SetupComplete.cmd avec logs détaillés** (C:\SetupComplete.log)
- ✅ **Tâches planifiées auto-suppression** après exécution
- ✅ **Guide débogage intégré** dans documentation complète
- ✅ **Fond d'écran Full HD** (1920x1080, logo 600x600 centré)
- 🔧 FirstLogonCommands réduit à 1 commande (RemoveBloatware)
- 🔧 Applications installées via tâche planifiée (au lieu de FirstLogonCommands)

### v2.2.0 (22/12/2025) - Version Universelle + Corrections majeures
- ✅ Généricisation pour toutes versions Windows
- ✅ Interface ASCII professionnelle avec logo Xpolaris
- ✅ Nom ISO générique : `Windows_Custom_Xpolaris.iso`
- ✅ Détection Rufus optimisée (3 phases globales)
- ✅ Bypass réseau (BypassNRO) intégré
- ✅ Menu restructuré avec bordures et émojis
- ✅ **Processus Complet VRAIMENT complet** : Inclut suppression composants Windows (IE, Media Player, WordPad)
- ✅ **Barre de progression montage** : Message finalisation à 95%
- ✅ **Option retour [0]** dans extraction d'édition
- ✅ **Détection structure ISO** : Avertissement si boot/efi manquants
- ✅ **Correction oscdimg pour VMware** : Label de volume + chemins relatifs
- ✅ **Mode debug oscdimg** : Affichage commande + sortie temps réel
- ✅ **Activation automatique compte Administrateur** dans autounattend.xml
- ✅ **Documentation complète** : Création ISO + Dépannage compte + Applications winget
- ✅ **Fix chemins avec espaces** : Wrapper batch temporaire
- ✅ **Ordre des étapes corrigé** : Extraction → Suppression composants → Personnalisation → ISO → Nettoyage
- 🐛 Suppression option [9] obsolète (compilation .exe)

### v2.1.2 (20/12/2025)
- ✅ Recherche Rufus globale sur tous les disques (depth 3)
- ✅ Téléchargement automatique Rufus 4.6 si absent
- 🐛 Fix détection pattern `rufus*.exe`

### v2.1.1 (20/12/2025)
- ✅ Détection Rufus par pattern (rufus-4.11p.exe compatible)
- ✅ Recherche multi-emplacements (Downloads, Desktop, C:\)

### v2.1.0 (19/12/2025)
- ✅ Intégration Rufus comme outil principal ISO
- ✅ Windows ADK en fallback
- ✅ Auto-download Rufus depuis GitHub

### v2.0.5 (18/12/2025)
- ✅ Bypass réseau (BypassNRO) dans autounattend.xml
- ✅ Option "Je n'ai pas internet" activée

### v2.0.0 (15/12/2025)
- 🎉 Version initiale consolidée
- ✅ Menu interactif 9 options
- ✅ Branding Xpolaris complet
- ✅ Logo OEM 120x120 pixels

---

## 🏆 CRÉDITS

**Développé avec** : PowerShell 7.x  
**Outils utilisés** :
- DISM (Deployment Image Servicing and Management)
- Rufus 4.6+ (Portable USB Creator)
- ps2exe 0.5.0.33 (PowerShell to EXE Compiler)
- System.Drawing .NET Framework (Image Processing)

**Inspiré par** :
- Scripts NTLite
- Communauté Windows Debloater
- MSMG Toolkit

---

**⭐ Merci d'utiliser Xpolaris Windows Customizer ! ⭐**

---

*Documentation complète - Dernière mise à jour : 28 décembre 2025*
