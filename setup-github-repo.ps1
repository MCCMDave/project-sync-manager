# ============================================================================
# GitHub Repository Setup Script
# Hilft beim Erstellen des GitHub Repositories
# ============================================================================

$ErrorActionPreference = "Stop"

# Farben
$Colors = @{
    Title = "Cyan"
    Success = "Green"
    Warning = "Yellow"
    Error = "Red"
    Info = "White"
    Prompt = "Magenta"
}

function Show-Header {
    param([string]$Title)
    Clear-Host
    Write-Host ""
    Write-Host "============================================================================" -ForegroundColor $Colors.Title
    Write-Host "  $Title" -ForegroundColor $Colors.Title
    Write-Host "============================================================================" -ForegroundColor $Colors.Title
    Write-Host ""
}

Show-Header "GitHub Repository Setup"

# Projekt-Info
$repoName = "project-sync-manager"
$description = "Intelligent sync tool for development projects with Nextcloud support"
$projectPath = $PSScriptRoot

Write-Host "Projekt:" -ForegroundColor $Colors.Title
Write-Host "  Name:         $repoName" -ForegroundColor $Colors.Info
Write-Host "  Beschreibung: $description" -ForegroundColor $Colors.Info
Write-Host "  Pfad:         $projectPath" -ForegroundColor $Colors.Info
Write-Host ""

# Prüfe Git Status
Write-Host "Git Status:" -ForegroundColor $Colors.Title

Set-Location $projectPath

try {
    $gitStatus = git status --short 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ✅ Git Repository initialisiert" -ForegroundColor $Colors.Success

        $commits = git log --oneline 2>&1 | Measure-Object
        Write-Host "  ✅ Commits: $($commits.Count)" -ForegroundColor $Colors.Success

        if ($gitStatus) {
            Write-Host "  ⚠️  Uncommitted Changes vorhanden" -ForegroundColor $Colors.Warning
        } else {
            Write-Host "  ✅ Alle Änderungen committed" -ForegroundColor $Colors.Success
        }
    }
} catch {
    Write-Host "  ❌ Kein Git Repository" -ForegroundColor $Colors.Error
    Write-Host ""
    Write-Host "Bitte zuerst Git initialisieren:" -ForegroundColor $Colors.Warning
    Write-Host "  git init" -ForegroundColor $Colors.Info
    Write-Host "  git add ." -ForegroundColor $Colors.Info
    Write-Host "  git commit -m 'Initial commit'" -ForegroundColor $Colors.Info
    exit 1
}

Write-Host ""

# Prüfe ob GitHub CLI installiert ist
Write-Host "GitHub CLI Status:" -ForegroundColor $Colors.Title

$hasGhCli = $false
try {
    $ghVersion = gh --version 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ✅ GitHub CLI installiert: $($ghVersion[0])" -ForegroundColor $Colors.Success
        $hasGhCli = $true

        # Prüfe Auth-Status
        $ghAuth = gh auth status 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "  ✅ Bei GitHub angemeldet" -ForegroundColor $Colors.Success
        } else {
            Write-Host "  ⚠️  Nicht bei GitHub angemeldet" -ForegroundColor $Colors.Warning
        }
    }
} catch {
    Write-Host "  ❌ GitHub CLI nicht installiert" -ForegroundColor $Colors.Warning
    Write-Host "     Download: https://cli.github.com/" -ForegroundColor $Colors.Info
    Write-Host "     Oder: winget install GitHub.cli" -ForegroundColor $Colors.Info
}

Write-Host ""
Write-Host "============================================================================" -ForegroundColor $Colors.Title
Write-Host ""

# Wähle Methode
if ($hasGhCli) {
    Write-Host "GitHub CLI ist verfügbar! Empfohlene Methode:" -ForegroundColor $Colors.Success
    Write-Host ""
    Write-Host "Möchtest du das Repository mit GitHub CLI erstellen?" -ForegroundColor $Colors.Prompt
    Write-Host "  [j] Ja, mit GitHub CLI (empfohlen, schnell)" -ForegroundColor $Colors.Success
    Write-Host "  [n] Nein, zeig mir die manuelle Methode" -ForegroundColor $Colors.Info
    Write-Host ""

    $choice = Read-Host "Auswahl (j/n)"

    if ($choice -eq "j") {
        # GitHub CLI Methode
        Show-Header "Repository erstellen mit GitHub CLI"

        Write-Host "Prüfe GitHub-Anmeldung..." -ForegroundColor $Colors.Info

        $ghAuth = gh auth status 2>&1
        if ($LASTEXITCODE -ne 0) {
            Write-Host ""
            Write-Host "Du bist nicht bei GitHub angemeldet." -ForegroundColor $Colors.Warning
            Write-Host "Starte GitHub-Login..." -ForegroundColor $Colors.Info
            Write-Host ""

            gh auth login

            if ($LASTEXITCODE -ne 0) {
                Write-Host ""
                Write-Host "❌ Login fehlgeschlagen" -ForegroundColor $Colors.Error
                exit 1
            }
        }

        Write-Host ""
        Write-Host "Erstelle Repository auf GitHub..." -ForegroundColor $Colors.Info
        Write-Host ""
        Write-Host "Repository-Einstellungen:" -ForegroundColor $Colors.Title
        Write-Host "  Name:         $repoName" -ForegroundColor $Colors.Info
        Write-Host "  Beschreibung: $description" -ForegroundColor $Colors.Info
        Write-Host "  Sichtbarkeit: Public" -ForegroundColor $Colors.Info
        Write-Host "  Lizenz:       Apache-2.0" -ForegroundColor $Colors.Info
        Write-Host ""
        Write-Host "Fortfahren? (j/n): " -ForegroundColor $Colors.Prompt -NoNewline
        $confirm = Read-Host

        if ($confirm -eq "j") {
            Write-Host ""
            Write-Host "Erstelle Repository..." -ForegroundColor $Colors.Info

            # Erstelle Repo und pushe
            gh repo create $repoName `
                --public `
                --description $description `
                --source=. `
                --remote=origin `
                --push

            if ($LASTEXITCODE -eq 0) {
                Write-Host ""
                Write-Host "============================================================================" -ForegroundColor $Colors.Success
                Write-Host "  ✅ Repository erfolgreich erstellt und gepusht!" -ForegroundColor $Colors.Success
                Write-Host "============================================================================" -ForegroundColor $Colors.Success
                Write-Host ""

                # Hole Username
                $ghUser = gh api user --jq '.login' 2>&1

                Write-Host "Repository URL:" -ForegroundColor $Colors.Title
                Write-Host "  https://github.com/$ghUser/$repoName" -ForegroundColor $Colors.Info
                Write-Host ""
                Write-Host "Nächste Schritte:" -ForegroundColor $Colors.Title
                Write-Host "  1. Besuche dein Repository im Browser" -ForegroundColor $Colors.Info
                Write-Host "  2. Passe ggf. die Description an" -ForegroundColor $Colors.Info
                Write-Host "  3. Füge Topics hinzu (powershell, sync, nextcloud, raspberry-pi)" -ForegroundColor $Colors.Info
                Write-Host ""

                Write-Host "Im Browser öffnen? (j/n): " -ForegroundColor $Colors.Prompt -NoNewline
                $openBrowser = Read-Host

                if ($openBrowser -eq "j") {
                    gh repo view --web
                }
            } else {
                Write-Host ""
                Write-Host "❌ Fehler beim Erstellen des Repositories" -ForegroundColor $Colors.Error
            }
        } else {
            Write-Host "Abgebrochen" -ForegroundColor $Colors.Warning
        }
    } else {
        # Manuelle Methode zeigen
        Show-Manual-Method
    }
} else {
    # GitHub CLI nicht verfügbar - zeige manuelle Methode
    Write-Host "GitHub CLI nicht verfügbar - Verwende manuelle Methode" -ForegroundColor $Colors.Info
    Write-Host ""
    Show-Manual-Method
}

function Show-Manual-Method {
    Show-Header "Manuelle Repository-Erstellung"

    Write-Host "Schritt 1: Repository auf GitHub erstellen" -ForegroundColor $Colors.Title
    Write-Host ""
    Write-Host "  1. Öffne im Browser:" -ForegroundColor $Colors.Info
    Write-Host "     https://github.com/new" -ForegroundColor $Colors.Prompt
    Write-Host ""
    Write-Host "  2. Fülle das Formular aus:" -ForegroundColor $Colors.Info
    Write-Host "     Repository name:  $repoName" -ForegroundColor $Colors.Prompt
    Write-Host "     Description:      $description" -ForegroundColor $Colors.Prompt
    Write-Host "     Public:           ✅" -ForegroundColor $Colors.Success
    Write-Host "     Add README:       ❌ (haben wir schon!)" -ForegroundColor $Colors.Warning
    Write-Host "     Add .gitignore:   ❌ (haben wir schon!)" -ForegroundColor $Colors.Warning
    Write-Host "     Choose license:   Apache License 2.0 ✅" -ForegroundColor $Colors.Success
    Write-Host ""
    Write-Host "  3. Klicke 'Create repository'" -ForegroundColor $Colors.Info
    Write-Host ""

    Write-Host "Drücke ENTER wenn du das Repository erstellt hast..." -ForegroundColor $Colors.Prompt
    Read-Host

    Write-Host ""
    Write-Host "Schritt 2: Lokales Repository verbinden" -ForegroundColor $Colors.Title
    Write-Host ""
    Write-Host "Bitte gib deinen GitHub-Username ein:" -ForegroundColor $Colors.Prompt -NoNewline
    $username = Read-Host

    $repoUrl = "https://github.com/$username/$repoName.git"

    Write-Host ""
    Write-Host "Repository URL: $repoUrl" -ForegroundColor $Colors.Info
    Write-Host ""
    Write-Host "Führe folgende Befehle aus:" -ForegroundColor $Colors.Title
    Write-Host ""
    Write-Host "cd `"$projectPath`"" -ForegroundColor $Colors.Prompt
    Write-Host "git remote add origin $repoUrl" -ForegroundColor $Colors.Prompt
    Write-Host "git branch -M main" -ForegroundColor $Colors.Prompt
    Write-Host "git push -u origin main" -ForegroundColor $Colors.Prompt
    Write-Host ""

    Write-Host "Soll ich diese Befehle jetzt ausführen? (j/n): " -ForegroundColor $Colors.Prompt -NoNewline
    $execute = Read-Host

    if ($execute -eq "j") {
        Write-Host ""
        Write-Host "Füge Remote hinzu..." -ForegroundColor $Colors.Info
        git remote add origin $repoUrl

        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ Remote hinzugefügt" -ForegroundColor $Colors.Success
        }

        Write-Host "Benenne Branch zu main um..." -ForegroundColor $Colors.Info
        git branch -M main

        Write-Host "Pushe zu GitHub..." -ForegroundColor $Colors.Info
        git push -u origin main

        if ($LASTEXITCODE -eq 0) {
            Write-Host ""
            Write-Host "============================================================================" -ForegroundColor $Colors.Success
            Write-Host "  ✅ Repository erfolgreich gepusht!" -ForegroundColor $Colors.Success
            Write-Host "============================================================================" -ForegroundColor $Colors.Success
            Write-Host ""
            Write-Host "Repository URL:" -ForegroundColor $Colors.Title
            Write-Host "  https://github.com/$username/$repoName" -ForegroundColor $Colors.Info
            Write-Host ""

            Write-Host "Im Browser öffnen? (j/n): " -ForegroundColor $Colors.Prompt -NoNewline
            $openBrowser = Read-Host

            if ($openBrowser -eq "j") {
                Start-Process "https://github.com/$username/$repoName"
            }
        } else {
            Write-Host ""
            Write-Host "❌ Fehler beim Pushen" -ForegroundColor $Colors.Error
            Write-Host ""
            Write-Host "Mögliche Probleme:" -ForegroundColor $Colors.Warning
            Write-Host "  - Repository existiert nicht auf GitHub" -ForegroundColor $Colors.Info
            Write-Host "  - Falscher Username" -ForegroundColor $Colors.Info
            Write-Host "  - Keine Git-Authentifizierung" -ForegroundColor $Colors.Info
            Write-Host ""
            Write-Host "Prüfe und versuche es erneut mit:" -ForegroundColor $Colors.Info
            Write-Host "  git push -u origin main" -ForegroundColor $Colors.Prompt
        }
    } else {
        Write-Host ""
        Write-Host "Befehle wurden nicht ausgeführt." -ForegroundColor $Colors.Warning
        Write-Host "Du kannst sie manuell ausführen wenn du bereit bist." -ForegroundColor $Colors.Info
    }
}

Write-Host ""
Write-Host "Drücke eine beliebige Taste zum Beenden..." -ForegroundColor $Colors.Info
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
