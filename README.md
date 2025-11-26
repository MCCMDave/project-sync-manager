# Project Sync Manager 🔄

Intelligent synchronization tool for development projects with Nextcloud support. Designed for multi-PC workflows while excluding large virtual environments and caches.

**English Version** | [Deutsche Version](README.de.md)

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](LICENSE)
[![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-blue.svg)](https://microsoft.com/powershell)

---

## ✨ Features

- 🎮 **Interactive Menu** - Easy-to-use CLI interface
- 📊 **System Information** - Comprehensive system diagnostics
- 📦 **Smart Export** - Exports only essential files (excludes venv, cache)
- 🔄 **Two Sync Methods**:
  - Nextcloud continuous sync (automatic)
  - Manual ZIP-based sync (perfect for Raspberry Pi)
- 💾 **Virtual Environment Management** - Create identical venvs across PCs
- 🚫 **Intelligent Exclusion** - Automatically excludes unnecessary files
- 📝 **Requirements Export** - Ensures identical Python environments
- 🌍 **Multi-Language** - English and German support

---

## 🎯 Use Cases

### Perfect for:
- 👨‍💻 Developers working on multiple PCs
- 🏠 Home lab setups with Raspberry Pi
- 📚 Students syncing between school/home
- 💼 Professional developers with multiple workstations

### Solves:
- ❌ venv folders are too large to sync
- ❌ Nextcloud runs continuously (Pi performance)
- ❌ Different Python versions on different PCs
- ❌ Cache and build files pollute sync

---

## 🚀 Quick Start

### Prerequisites
- Windows 10/11 with PowerShell 5.1+
- Python 3.8+
- Git (optional)
- Nextcloud client (for automatic sync) OR USB/network storage (for manual sync)

### Installation

1. **Clone or Download**
   ```powershell
   git clone https://github.com/YOUR_USERNAME/project-sync-manager.git
   cd project-sync-manager
   ```

2. **Run Sync Manager**
   ```powershell
   .\sync-manager.ps1
   ```

   Or double-click: `⚡ Sync Manager.lnk`

---

## 📋 Menu Options

```
============================================================================
  GitHub Sync Manager
============================================================================

  [1] 📊 System Information
  [2] 🔍 Sync Status
  [3] 📦 Export Requirements (PC 1)
  [4] 🚀 Setup Nextcloud Sync
  [5] 💾 Create venv (PC 2)
  [6] 🛠️  Create Nextcloud Exclude File
  [7] 📋 Show All Steps
  [0] ❌ Exit
```

### [1] System Information
Shows detailed system diagnostics:
- OS version and architecture
- PowerShell version
- Python, Git, Docker status
- Nextcloud path and status
- Hardware specifications
- Admin rights

### [2] Sync Status
Displays status of all projects:
- Project size
- Git repository status
- venv presence
- requirements.txt status
- .claude folder

### [3] Export Requirements (PC 1)
Exports Python dependencies:
- Scans all projects for venv
- Runs `pip freeze`
- Creates/updates requirements.txt
- **Must run BEFORE syncing!**

### [4] Setup Nextcloud Sync
Copies projects to Nextcloud:
- Creates GitHub folder in Nextcloud
- Copies all projects
- Auto-excludes: venv, __pycache__, .git, *.log
- Uses robocopy for reliability

### [5] Create venv (PC 2)
Creates identical venv on second PC:
- Reads requirements.txt
- Creates new venv
- Installs all dependencies
- Ensures version parity with PC 1

### [6] Create Exclude File
Creates `.sync_exclude.lst`:
- Excludes venv from sync
- Excludes __pycache__
- Excludes logs
- Excludes node_modules
- **Important: Restart Nextcloud after creating!**

### [7] Show All Steps
Complete step-by-step guide

---

## 🔄 Sync Methods

### Method 1: Nextcloud Continuous Sync

**When to use:**
- ✅ Always-on desktop PC
- ✅ Good internet connection
- ✅ Want automatic synchronization

**Setup:**
1. Run Option [3] - Export Requirements
2. Run Option [4] - Setup Nextcloud Sync
3. Run Option [6] - Create Exclude File
4. Wait for Nextcloud to sync
5. On PC 2: Run Option [5] - Create venv

**Note:** Nextcloud runs continuously in background!

---

### Method 2: Manual ZIP Sync (Recommended for Pi)

**When to use:**
- ✅ Nextcloud on Raspberry Pi
- ✅ Want to control when to sync
- ✅ Limited bandwidth
- ✅ No continuous background process

**Setup:**
1. Run `manual-sync.ps1` on PC 1
2. Choose [1] Export
3. Copy ZIP to PC 2 (USB, network, or manual Nextcloud upload)
4. On PC 2: Run `manual-sync.ps1`
5. Choose [2] Import
6. Run `sync-manager.ps1` Option [5] to create venv

**Advantages:**
- ⚡ No continuous Nextcloud load
- 📦 Compressed archives (smaller)
- 🎯 You control when to sync
- 🥧 Perfect for Raspberry Pi

---

## 📁 What Gets Synced?

### ✅ Included (Synced)
- Source code (.py, .ps1, .js, etc.)
- requirements.txt (essential!)
- Configuration files
- Documentation
- .claude folders (Claude AI data)
- LICENSE files
- README files

### ❌ Excluded (Not Synced)
- venv/ (virtual environments)
- __pycache__/ (Python cache)
- .git/ (Git history)
- *.log (log files)
- node_modules/ (Node.js)
- *.pyc, *.pyo (compiled Python)

**Result:** ZIP archives are 10-50MB instead of 100-500MB!

---

## 🛠️ Advanced Usage

### Custom Nextcloud Path
```powershell
.\sync-manager.ps1 -NextcloudPath "D:\MyNextcloud"
```

### Create Symlink (Optional)
Work with familiar paths:
```powershell
# Run as Administrator!
New-Item -ItemType SymbolicLink -Path "C:\Users\YourName\Desktop\GitHub" -Target "C:\Users\YourName\Nextcloud\GitHub"
```

Then both work:
- `C:\Users\YourName\Desktop\GitHub` (Symlink)
- `C:\Users\YourName\Nextcloud\GitHub` (Real folder)

---

## 📖 Typical Workflow

### On PC 1 (Source):
1. [1] Check system info
2. [3] Export requirements ⚠️ Important!
3. [4] Setup Nextcloud sync OR use manual-sync.ps1
4. [6] Create exclude file
5. Wait for sync

### On PC 2 (Destination):
1. Wait for Nextcloud sync OR import ZIP
2. [1] Check system info
3. [5] Create venv
4. Done! 🎉

---

## ⚠️ Important Notes

### Never Sync venv!
- venv folders are huge (100-500 MB per project)
- Don't work across different PCs
- Must be recreated on each PC
- That's why `.sync_exclude.lst` is crucial!

### requirements.txt is Key
- Contains ALL Python packages with exact versions
- Small (text file only)
- Enables identical venv on all PCs
- MUST be exported before syncing!

### .claude Folders
- Contains Claude AI configuration and chat history
- WILL be synced (important!)
- Relatively small
- Should NOT be excluded

---

## 🐛 Troubleshooting

### "Nextcloud not found"
→ Adjust path: `.\sync-manager.ps1 -NextcloudPath "Your\Path"`

### "Cannot create venv"
→ Check if Python is installed (Option 1)
→ Check if requirements.txt exists (Option 2)

### "Exclude file not working"
→ Restart Nextcloud client
→ Check if file exists: `Nextcloud\GitHub\.sync_exclude.lst`

### "Projects not syncing"
→ Check Nextcloud status
→ Check if GitHub folder exists in Nextcloud
→ Use Option [2] for status check

---

## 📚 Documentation

- [Full Guide](docs/USAGE.md)
- [FAQ](docs/FAQ.md)
- [Troubleshooting](docs/TROUBLESHOOTING.md)

---

## 📄 License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.

```
Copyright 2025 Dave Vaupel

Licensed under the Apache License, Version 2.0
```

---

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

---

## 👤 Author

**Dave Vaupel**
- GitHub: [@MCCMDave](https://github.com/MCCMDave)

---

## 🙏 Acknowledgments

- Inspired by multi-PC development workflows
- Built for Raspberry Pi Nextcloud users
- Powered by PowerShell

---

**Built to solve the venv sync problem! 🚀**

*Star ⭐ this repo if it helped you!*
