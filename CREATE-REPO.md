# GitHub Repository erstellen

## Methode 1: GitHub CLI (Empfohlen - Schnellste) ⚡

### Installation:

```powershell
# Via winget (Windows 11/10)
winget install GitHub.cli

# ODER via Scoop (falls installiert)
scoop install gh

# ODER Download: https://cli.github.com/
```

### Nach Installation - Repository erstellen:

```powershell
# 1. GitHub Login
gh auth login

# 2. Navigiere zum Projekt
cd C:\Users\david\Desktop\GitHub\project-sync-manager

# 3. Erstelle Repository und pushe
gh repo create project-sync-manager --public --source=. --remote=origin --push

# Fertig! 🎉
```

**Das war's! Repository ist erstellt und gepusht!**

---

## Methode 2: Manuell via GitHub Website (Klassisch)

### Schritt 1: Repository auf GitHub erstellen

1. Gehe zu: https://github.com/new
2. Fülle aus:
   - **Repository name:** `project-sync-manager`
   - **Description:** `Intelligent sync tool for development projects with Nextcloud support`
   - **Public** ✅
   - **NICHT** "Add a README" (haben wir schon!)
   - **NICHT** "Add .gitignore" (haben wir schon!)
   - **License:** Apache License 2.0 ✅
3. Klicke "Create repository"

### Schritt 2: Lokales Repo verbinden und pushen

```powershell
cd C:\Users\david\Desktop\GitHub\project-sync-manager

# Remote hinzufügen (ERSETZE: MCCMDave mit deinem GitHub-Username!)
git remote add origin https://github.com/MCCMDave/project-sync-manager.git

# Branch zu main umbenennen (falls noch master)
git branch -M main

# Push
git push -u origin main
```

---

## Methode 3: Automatisches Script (Falls GitHub CLI nicht gewünscht)

Ich habe ein Script erstellt das dich durch den Prozess führt:

```powershell
.\setup-github-repo.ps1
```

Dieses Script:
1. Prüft ob GitHub CLI installiert ist
2. Falls nein: Öffnet GitHub im Browser
3. Zeigt dir genau die Befehle die du ausführen musst
4. Pusht automatisch nach Bestätigung

---

## Was nach dem Push passiert:

✅ Repository ist auf GitHub
✅ README.md wird automatisch als Projekt-Seite angezeigt
✅ LICENSE wird erkannt
✅ Andere können es klonen/forken
✅ GitHub Actions möglich (falls du später CI/CD willst)

---

## Empfehlung:

**Installiere GitHub CLI** - es ist das offizielle Tool und macht alles viel einfacher!

Nach Installation kannst du zukünftig mit einem Befehl Repos erstellen:
```powershell
gh repo create NAME --public --source=. --push
```

Das ist **wesentlich schneller** als die manuelle Methode!

---

## Falls du Hilfe brauchst:

Sag mir welche Methode du verwenden möchtest, dann helfe ich dir durch den Prozess! 😊
