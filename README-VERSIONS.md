# 🎨 Xpolaris Windows Customizer - Versions disponibles

## 📦 Vue d'ensemble

Ce projet propose **DEUX versions** complètes pour personnaliser votre Windows :

| Version | Fichier | Interface | Avantages |
|---------|---------|-----------|-----------|
| **Console** (v2.2.0) | `Xpolaris-Windows-Customizer.exe` | Texte/ASCII | Léger, rapide, compatible serveurs |
| **GUI** (v3.0.0) | `Xpolaris-GUI.exe` | Graphique WPF | Moderne, intuitif, visuel |

---

## 🖥️ Version Console (v2.2.0)

### Caractéristiques
- ✅ Interface texte ASCII art stylisée
- ✅ Menu numérique [1] à [5]
- ✅ Barres de progression textuelles
- ✅ Léger (~2-3 MB)
- ✅ Compatible PowerShell 5.1+
- ✅ Idéal pour scripts automatisés

### Utilisation
```cmd
Xpolaris-Windows-Customizer.exe
```

### Captures d'écran
```
╔════════════════════════════════════════════════════╗
║         XPOLARIS WINDOWS CUSTOMIZER v2.2.0         ║
╚════════════════════════════════════════════════════╝

[1] Monter une image Windows
[2] Personnaliser l'image
[3] Supprimer le bloatware
[4] Créer l'ISO final
[5] Quitter
```

---

## 🎨 Version GUI (v3.0.0) - **NOUVEAU**

### Caractéristiques
- ✅ Interface graphique moderne Windows 11
- ✅ Thème sombre/clair commutable
- ✅ Onglets organisés (ISO / Personnalisation / Création / Logs)
- ✅ Drag & Drop pour fichiers ISO
- ✅ Checkboxes pour sélection multiple
- ✅ Barres de progression animées
- ✅ Logs en temps réel
- ✅ Fenêtre redimensionnable

### Utilisation
```cmd
Xpolaris-GUI.exe
```

### Fonctionnalités avancées

#### 🔹 Onglet "Sélection ISO"
- Parcourir ou glisser-déposer votre ISO Windows
- Charger automatiquement les éditions disponibles
- Afficher les informations du fichier (nom, taille)

#### 🔹 Onglet "Personnalisation"
**Suppression de composants :**
- Internet Explorer
- Windows Media Player Legacy
- WordPad
- Paint (ancien)
- Notepad (ancien)

**Bloatware à supprimer :**
- Xbox (Console, Game Bar, etc.)
- Microsoft Teams
- OneDrive
- Cortana
- 3D Viewer
- Office Hub
- Get Help
- Feedback Hub
- Maps
- Solitaire Collection
- People
- Groove Music

**Applications à installer :**
- 🌐 Google Chrome
- 📦 7-Zip
- 🎬 VLC Media Player
- 📝 Notepad++
- 🖥️ TeamViewer
- 💿 Virtual CloneDrive

**Options avancées :**
- Désactiver la télémétrie
- Activer le thème sombre
- Désactiver Cortana complètement
- Afficher les extensions de fichiers
- Désactiver l'hibernation

#### 🔹 Onglet "Création ISO"
- Processus complet automatisé
- Progression visuelle étape par étape
- Bouton d'arrêt d'urgence
- Nom de fichier personnalisable

#### 🔹 Onglet "Logs"
- Console de logs en temps réel
- Export des logs vers fichier
- Effacement rapide
- Style terminal (Consolas, fond noir, texte vert)

### Captures d'écran
```
┌─────────────────────────────────────────────────────┐
│  ⚡ XPOLARIS WINDOWS CUSTOMIZER PRO     🌙 Thème   │
│  Version 3.0.0 - Interface Graphique Moderne        │
├─────────────────────────────────────────────────────┤
│  📁 Sélection ISO  │ 🎨 Personnalisation │ 💿 ...  │
├─────────────────────────────────────────────────────┤
│                                                     │
│  ╔═══════════════════════════════════════════╗    │
│  ║  Fichier ISO Source                       ║    │
│  ╠═══════════════════════════════════════════╣    │
│  ║  [C:\Windows11.iso        ] [📂 Parcourir]║    │
│  ║  💡 Glissez-déposez votre ISO ici         ║    │
│  ╚═══════════════════════════════════════════╝    │
│                                                     │
│  🚀 DÉMARRER LE PROCESSUS COMPLET                  │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━ 45%                   │
│  Extraction de l'édition Windows...                │
│                                                     │
├─────────────────────────────────────────────────────┤
│  ✓ Prêt              v3.0.0 | Xpolaris © 2026     │
└─────────────────────────────────────────────────────┘
```

---

## 🔧 Recompilation

### Version Console
```powershell
.\Recompile-Exe.ps1
```
Compile `Windows-CustomizeMaster.ps1` → `Xpolaris-Windows-Customizer.exe`

### Version GUI
```powershell
.\Compile-GUI.ps1
```
Compile `Xpolaris-GUI.ps1` → `Xpolaris-GUI.exe`

---

## 🎯 Quelle version choisir ?

| Critère | Console | GUI |
|---------|---------|-----|
| **Facilité d'utilisation** | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| **Vitesse d'exécution** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ |
| **Consommation mémoire** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ |
| **Automatisation** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ |
| **Expérience visuelle** | ⭐⭐ | ⭐⭐⭐⭐⭐ |
| **Support Drag & Drop** | ❌ | ✅ |
| **Thème personnalisable** | ❌ | ✅ |
| **Logs en temps réel** | ⭐⭐ | ⭐⭐⭐⭐⭐ |

### 💡 Recommandations

**Utilisez la version CONSOLE si :**
- Vous préférez les interfaces textuelles
- Vous voulez automatiser via scripts
- Vous travaillez en SSH/RDP
- Vous avez des ressources limitées

**Utilisez la version GUI si :**
- Vous préférez les interfaces graphiques
- C'est votre première utilisation
- Vous voulez voir la progression visuellement
- Vous aimez les interfaces modernes Windows 11

---

## 📂 Structure des fichiers

```
Windows Customizer v2.2.0/
│
├── 📄 Sources PowerShell
│   ├── Windows-CustomizeMaster.ps1      (Script console)
│   ├── Xpolaris-GUI.ps1                 (Script GUI)
│   ├── Xpolaris-Apps-Manager.ps1        (Post-installation)
│   ├── XpolarisLogo.ps1                 (Logo ASCII)
│   └── XpolarisLogo_Preview.ps1         (Prévisualisation)
│
├── 🔧 Scripts de compilation
│   ├── Recompile-Exe.ps1                (Compile version console)
│   ├── Recompile-Exe.cmd                (Lanceur CMD)
│   └── Compile-GUI.ps1                  (Compile version GUI)
│
├── 💻 Exécutables
│   ├── Xpolaris-Windows-Customizer.exe  (Version console v2.2.0)
│   └── Xpolaris-GUI.exe                 (Version GUI v3.0.0) ⭐ NOUVEAU
│
├── 📚 Documentation
│   ├── GUIDE_COMPLET.md                 (Documentation complète)
│   └── README-VERSIONS.md               (Ce fichier)
│
└── 📁 Dossiers de travail
    ├── CustomizeWork/                   (Fichiers temporaires)
    ├── boot/                            (Bootloader)
    ├── efi/                             (EFI)
    └── sources/                         (Sources Windows)
```

---

## 🚀 Démarrage rapide

### Première utilisation (GUI recommandé)

1. **Lancer l'interface**
   ```cmd
   Xpolaris-GUI.exe
   ```

2. **Sélectionner votre ISO**
   - Onglet "📁 Sélection ISO"
   - Cliquer sur "📂 Parcourir" ou glisser-déposer
   - Cliquer sur "🔍 Charger les éditions"

3. **Personnaliser**
   - Onglet "🎨 Personnalisation"
   - Cocher/décocher les options désirées

4. **Créer l'ISO**
   - Onglet "💿 Création ISO"
   - Cliquer sur "🚀 DÉMARRER LE PROCESSUS COMPLET"

5. **Suivre la progression**
   - Onglet "📋 Logs" pour les détails

### Utilisation avancée (Console)

```powershell
# Lancer en mode console
.\Xpolaris-Windows-Customizer.exe

# Suivre le menu interactif
[1] Monter une image Windows
[2] Personnaliser l'image
[3] Supprimer le bloatware
[4] Créer l'ISO final
[5] Quitter
```

---

## 🔄 Compatibilité

| OS | Console | GUI |
|----|---------|-----|
| Windows 11 | ✅ | ✅ |
| Windows 10 (1809+) | ✅ | ✅ |
| Windows Server 2019+ | ✅ | ⚠️ (nécessite .NET Desktop) |

**Prérequis :**
- PowerShell 5.1 ou supérieur
- .NET Framework 4.7.2+ (pour GUI)
- Droits administrateur
- Windows ADK (pour oscdimg.exe)

---

## 📝 Changelog

### Version 3.0.0 (1 février 2026) - **Interface GUI WPF**
- ✅ **NOUVEAU** : Interface graphique complète
- ✅ Thème sombre/clair commutable
- ✅ Onglets organisés
- ✅ Drag & Drop pour ISO
- ✅ Logs en temps réel avec export
- ✅ Progress bars animées
- ✅ Design moderne Windows 11

### Version 2.2.0 (28 décembre 2025) - Consolidation Finale
- ✅ Fusion InstallApps + PostInstall → Apps-Manager
- ✅ Réduction de 9 → 5 scripts (-44%)
- ✅ Mode AUTO + INTERACTIF unifié
- ✅ Documentation complète

---

## 🤝 Support

**Questions / Bugs :**
- Consultez `GUIDE_COMPLET.md` pour la documentation complète
- Vérifiez les logs dans l'onglet "📋 Logs" (GUI)
- Testez les deux versions en cas de problème

**Contribution :**
- Les deux versions sont maintenues activement
- Scripts sources disponibles dans le dossier racine

---

## 📄 Licence

© 2026 Xpolaris - Tous droits réservés

---

**Profitez de votre Windows personnalisé sans bloatware ! 🎉**
