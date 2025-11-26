# Project Sync Manager 🔄

Intelligentes Synchronisations-Tool für Entwicklungsprojekte mit Nextcloud-Unterstützung. Entwickelt für Multi-PC-Workflows, schließt automatisch große Virtual Environments und Caches aus.

[English Version](README.md) | **Deutsche Version**

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](LICENSE)
[![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-blue.svg)](https://microsoft.com/powershell)

---

## ✨ Features

- 🎮 **Interaktives Menü** - Einfach zu bedienende CLI-Oberfläche
- 📊 **System-Informationen** - Umfassende System-Diagnose
- 📦 **Intelligenter Export** - Exportiert nur wesentliche Dateien (ohne venv, Cache)
- 🔄 **Zwei Sync-Methoden**:
  - Nextcloud kontinuierliche Synchronisation (automatisch)
  - Manuelle ZIP-basierte Synchronisation (perfekt für Raspberry Pi)
- 💾 **Virtual Environment Management** - Erstellt identische venvs auf allen PCs
- 🚫 **Intelligente Ausschlüsse** - Schließt automatisch unnötige Dateien aus
- 📝 **Requirements Export** - Stellt identische Python-Umgebungen sicher
- 🌍 **Mehrsprachig** - Englisch und Deutsch

---

## 🎯 Anwendungsfälle

### Perfekt für:
- 👨‍💻 Entwickler die an mehreren PCs arbeiten
- 🏠 Home-Lab-Setups mit Raspberry Pi
- 📚 Studenten die zwischen Schule/Zuhause synchronisieren
- 💼 Professionelle Entwickler mit mehreren Workstations

### Löst:
- ❌ venv-Ordner sind zu groß zum Synchronisieren
- ❌ Nextcloud läuft dauerhaft (Pi-Performance)
- ❌ Verschiedene Python-Versionen auf verschiedenen PCs
- ❌ Cache- und Build-Dateien verschmutzen Sync

---

## 🚀 Schnellstart

### Voraussetzungen
- Windows 10/11 mit PowerShell 5.1+
- Python 3.8+
- Git (optional)
- Nextcloud-Client (für automatischen Sync) ODER USB/Netzwerk-Speicher (für manuellen Sync)

### Installation

1. **Klonen oder Herunterladen**
   ```powershell
   git clone https://github.com/YOUR_USERNAME/project-sync-manager.git
   cd project-sync-manager
   ```

2. **Sync Manager starten**
   ```powershell
   .\sync-manager.ps1
   ```

   Oder Doppelklick auf: `⚡ Sync Manager.lnk`

---

## 📋 Menü-Optionen

```
============================================================================
  GitHub Sync Manager
============================================================================

  [1] 📊 System-Informationen anzeigen
  [2] 🔍 Sync-Status prüfen
  [3] 📦 Requirements exportieren (PC 1)
  [4] 🚀 Sync zu Nextcloud einrichten
  [5] 💾 venv-Ordner erstellen (PC 2)
  [6] 🛠️  Nextcloud-Exclude-Datei erstellen
  [7] 📋 Alle Schritte anzeigen
  [0] ❌ Beenden
```

### [1] System-Informationen
Zeigt detaillierte System-Diagnose:
- OS-Version und Architektur
- PowerShell-Version
- Python, Git, Docker Status
- Nextcloud-Pfad und Status
- Hardware-Spezifikationen
- Admin-Rechte

### [2] Sync-Status
Zeigt Status aller Projekte:
- Projekt-Größe
- Git-Repository-Status
- venv vorhanden
- requirements.txt Status
- .claude-Ordner

### [3] Requirements exportieren (PC 1)
Exportiert Python-Dependencies:
- Scannt alle Projekte nach venv
- Führt `pip freeze` aus
- Erstellt/aktualisiert requirements.txt
- **MUSS vor dem Sync ausgeführt werden!**

### [4] Sync zu Nextcloud einrichten
Kopiert Projekte nach Nextcloud:
- Erstellt GitHub-Ordner in Nextcloud
- Kopiert alle Projekte
- Schließt automatisch aus: venv, __pycache__, .git, *.log
- Verwendet robocopy für Zuverlässigkeit

### [5] venv erstellen (PC 2)
Erstellt identische venv auf zweitem PC:
- Liest requirements.txt
- Erstellt neue venv
- Installiert alle Dependencies
- Stellt Versions-Parität mit PC 1 sicher

### [6] Exclude-Datei erstellen
Erstellt `.sync_exclude.lst`:
- Schließt venv vom Sync aus
- Schließt __pycache__ aus
- Schließt Logs aus
- Schließt node_modules aus
- **Wichtig: Nextcloud nach Erstellung neu starten!**

### [7] Alle Schritte anzeigen
Komplette Schritt-für-Schritt-Anleitung

---

## 🔄 Sync-Methoden

### Methode 1: Nextcloud Kontinuierliche Synchronisation

**Wann verwenden:**
- ✅ Immer eingeschalteter Desktop-PC
- ✅ Gute Internetverbindung
- ✅ Automatische Synchronisation gewünscht

**Setup:**
1. Option [3] ausführen - Requirements exportieren
2. Option [4] ausführen - Nextcloud-Sync einrichten
3. Option [6] ausführen - Exclude-Datei erstellen
4. Warten bis Nextcloud synchronisiert
5. Auf PC 2: Option [5] ausführen - venv erstellen

**Hinweis:** Nextcloud läuft dauerhaft im Hintergrund!

---

### Methode 2: Manuelle ZIP-Synchronisation (Empfohlen für Pi)

**Wann verwenden:**
- ✅ Nextcloud auf Raspberry Pi
- ✅ Kontrolle über Sync-Zeitpunkt gewünscht
- ✅ Begrenzte Bandbreite
- ✅ Kein dauerhafter Hintergrund-Prozess

**Setup:**
1. `manual-sync.ps1` auf PC 1 ausführen
2. [1] Export wählen
3. ZIP auf PC 2 kopieren (USB, Netzwerk, oder manueller Nextcloud-Upload)
4. Auf PC 2: `manual-sync.ps1` ausführen
5. [2] Import wählen
6. `sync-manager.ps1` Option [5] ausführen um venv zu erstellen

**Vorteile:**
- ⚡ Keine dauerhafte Nextcloud-Belastung
- 📦 Komprimierte Archive (kleiner)
- 🎯 Du kontrollierst wann synchronisiert wird
- 🥧 Perfekt für Raspberry Pi

---

## 📁 Was wird synchronisiert?

### ✅ Enthalten (Synchronisiert)
- Quellcode (.py, .ps1, .js, etc.)
- requirements.txt (essentiell!)
- Konfigurationsdateien
- Dokumentation
- .claude-Ordner (Claude AI Daten)
- LICENSE-Dateien
- README-Dateien

### ❌ Ausgeschlossen (NICHT synchronisiert)
- venv/ (Virtual Environments)
- __pycache__/ (Python Cache)
- .git/ (Git-Verlauf)
- *.log (Logdateien)
- node_modules/ (Node.js)
- *.pyc, *.pyo (kompiliertes Python)

**Resultat:** ZIP-Archive sind 10-50MB statt 100-500MB!

---

## 🛠️ Erweiterte Verwendung

### Eigener Nextcloud-Pfad
```powershell
.\sync-manager.ps1 -NextcloudPath "D:\MeinNextcloud"
```

### Symlink erstellen (Optional)
Mit gewohnten Pfaden arbeiten:
```powershell
# Als Administrator ausführen!
New-Item -ItemType SymbolicLink -Path "C:\Users\DeinName\Desktop\GitHub" -Target "C:\Users\DeinName\Nextcloud\GitHub"
```

Dann funktioniert beides:
- `C:\Users\DeinName\Desktop\GitHub` (Symlink)
- `C:\Users\DeinName\Nextcloud\GitHub` (Echter Ordner)

---

## 📖 Typischer Workflow

### Auf PC 1 (Quelle):
1. [1] System-Infos prüfen
2. [3] Requirements exportieren ⚠️ Wichtig!
3. [4] Nextcloud-Sync einrichten ODER manual-sync.ps1 verwenden
4. [6] Exclude-Datei erstellen
5. Auf Sync warten

### Auf PC 2 (Ziel):
1. Auf Nextcloud-Sync warten ODER ZIP importieren
2. [1] System-Infos prüfen
3. [5] venv erstellen
4. Fertig! 🎉

---

## ⚠️ Wichtige Hinweise

### Niemals venv synchronisieren!
- venv-Ordner sind riesig (100-500 MB pro Projekt)
- Funktionieren nicht zwischen verschiedenen PCs
- Müssen auf jedem PC neu erstellt werden
- Darum ist `.sync_exclude.lst` entscheidend!

### requirements.txt ist der Schlüssel
- Enthält ALLE Python-Pakete mit exakten Versionen
- Klein (nur Textdatei)
- Ermöglicht identische venv auf allen PCs
- MUSS vor dem Sync exportiert werden!

### .claude-Ordner
- Enthält Claude AI Konfiguration und Chat-Verlauf
- WIRD synchronisiert (wichtig!)
- Relativ klein
- Sollte NICHT ausgeschlossen werden

---

## 🐛 Fehlerbehebung

### "Nextcloud nicht gefunden"
→ Pfad anpassen: `.\sync-manager.ps1 -NextcloudPath "Dein\Pfad"`

### "venv kann nicht erstellt werden"
→ Prüfe ob Python installiert ist (Option 1)
→ Prüfe ob requirements.txt existiert (Option 2)

### "Exclude-Datei funktioniert nicht"
→ Nextcloud-Client neu starten
→ Prüfe ob Datei existiert: `Nextcloud\GitHub\.sync_exclude.lst`

### "Projekte werden nicht synchronisiert"
→ Nextcloud-Status prüfen
→ Prüfe ob GitHub-Ordner in Nextcloud existiert
→ Option [2] für Status-Check verwenden

---

## 📚 Dokumentation

- [Vollständige Anleitung](docs/USAGE.md)
- [FAQ](docs/FAQ.md)
- [Fehlerbehebung](docs/TROUBLESHOOTING.md)

---

## 📄 Lizenz

Dieses Projekt ist unter der Apache License 2.0 lizenziert - siehe [LICENSE](LICENSE) Datei für Details.

```
Copyright 2025 Dave Vaupel

Licensed under the Apache License, Version 2.0
```

---

## 🤝 Mitwirken

Beiträge sind willkommen! Bitte erstelle gerne einen Pull Request.

---

## 👤 Autor

**Dave Vaupel**
- GitHub: [@MCCMDave](https://github.com/MCCMDave)

---

## 🙏 Danksagungen

- Inspiriert von Multi-PC-Entwicklungs-Workflows
- Entwickelt für Raspberry Pi Nextcloud-Nutzer
- Powered by PowerShell

---

**Entwickelt um das venv-Sync-Problem zu lösen! 🚀**

*Star ⭐ das Repo falls es dir geholfen hat!*
