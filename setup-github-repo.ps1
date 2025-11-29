# ============================================================================
# GitHub Repository Setup Script / GitHub Repository Einrichtungs-Skript
# Hilft beim Erstellen des GitHub Repositories
# Helps creating GitHub Repositories
# ============================================================================

$ErrorActionPreference = "Stop"

# ============================================================================
# LANGUAGE SELECTION / SPRACHAUSWAHL
# ============================================================================

Write-Host ""
Write-Host "============================================================================" -ForegroundColor Cyan
Write-Host "  LANGUAGE / SPRACHE" -ForegroundColor Cyan
Write-Host "============================================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "  [1] Deutsch" -ForegroundColor White
Write-Host "  [2] English" -ForegroundColor White
Write-Host ""
Write-Host "============================================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Wahl / Choice: " -NoNewline -ForegroundColor Magenta

$key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
Write-Host $key.Character -ForegroundColor White

$Lang = if ($key.Character -eq "2") { "EN" } else { "DE" }

# ============================================================================
# COLORS / FARBEN
# ============================================================================

$Colors = @{
    Title = "Cyan"
    Success = "Green"
    Warning = "Yellow"
    Error = "Red"
    Info = "White"
    Prompt = "Magenta"
}

# ============================================================================
# TEXT TRANSLATIONS / TEXTÜBERSETZUNGEN
# ============================================================================

function Get-Text {
    param([string]$Key)

    $Texts = @{
        DE = @{
            Header = "GitHub Repository Setup"
            ProjectInfo = "Projekt:"
            Name = "Name:"
            Description = "Beschreibung:"
            Path = "Pfad:"
            GitStatus = "Git Status:"
            GitInitialized = "✅ Git Repository initialisiert"
            Commits = "✅ Commits:"
            UncommittedChanges = "⚠️  Uncommitted Changes vorhanden"
            AllCommitted = "✅ Alle Änderungen committed"
            NoGitRepo = "❌ Kein Git Repository"
            PleaseInitGit = "Bitte zuerst Git initialisieren:"
            GitCLIStatus = "GitHub CLI Status:"
            GitCLIInstalled = "✅ GitHub CLI installiert:"
            GitCLILoggedIn = "✅ Bei GitHub angemeldet"
            GitCLINotLoggedIn = "⚠️  Nicht bei GitHub angemeldet"
            GitCLINotInstalled = "❌ GitHub CLI nicht installiert"
            Download = "Download:"
            OrInstall = "Oder:"
            GitCLIAvailable = "GitHub CLI ist verfügbar! Empfohlene Methode:"
            UseGitCLI = "Möchtest du das Repository mit GitHub CLI erstellen?"
            YesCLI = "[j] Ja, mit GitHub CLI (empfohlen, schnell)"
            NoManual = "[n] Nein, zeig mir die manuelle Methode"
            Choice = "Auswahl (j/n)"
            CreateWithCLI = "Repository erstellen mit GitHub CLI"
            CheckingLogin = "Prüfe GitHub-Anmeldung..."
            NotLoggedIn = "Du bist nicht bei GitHub angemeldet."
            StartingLogin = "Starte GitHub-Login..."
            LoginFailed = "❌ Login fehlgeschlagen"
            CreatingRepo = "Erstelle Repository auf GitHub..."
            RepoSettings = "Repository-Einstellungen:"
            Visibility = "Sichtbarkeit: Public"
            License = "Lizenz: Apache-2.0"
            Continue = "Fortfahren? (j/n):"
            Creating = "Erstelle Repository..."
            Success = "✅ Repository erfolgreich erstellt und gepusht!"
            RepoURL = "Repository URL:"
            NextSteps = "Nächste Schritte:"
            Step1 = "1. Besuche dein Repository im Browser"
            Step2 = "2. Passe ggf. die Description an"
            Step3 = "3. Füge Topics hinzu (powershell, sync, nextcloud, raspberry-pi)"
            OpenBrowser = "Im Browser öffnen? (j/n):"
            CreateError = "❌ Fehler beim Erstellen des Repositories"
            Cancelled = "Abgebrochen"
            ManualMethod = "GitHub CLI nicht verfügbar - Verwende manuelle Methode"
            ManualHeader = "Manuelle Repository-Erstellung"
            ManualStep1 = "Schritt 1: Repository auf GitHub erstellen"
            OpenInBrowser = "1. Öffne im Browser:"
            FillForm = "2. Fülle das Formular aus:"
            RepoName = "Repository name:"
            Public = "Public: ✅"
            AddREADME = "Add README: ❌ (haben wir schon!)"
            AddGitignore = "Add .gitignore: ❌ (haben wir schon!)"
            ChooseLicense = "Choose license: Apache License 2.0 ✅"
            ClickCreate = "3. Klicke 'Create repository'"
            PressEnterWhenDone = "Drücke ENTER wenn du das Repository erstellt hast..."
            ManualStep2 = "Schritt 2: Lokales Repository verbinden"
            EnterUsername = "Bitte gib deinen GitHub-Username ein:"
            RunCommands = "Führe folgende Befehle aus:"
            ExecuteNow = "Soll ich diese Befehle jetzt ausführen? (j/n):"
            AddingRemote = "Füge Remote hinzu..."
            RemoteAdded = "✅ Remote hinzugefügt"
            RenamingBranch = "Benenne Branch zu main um..."
            Pushing = "Pushe zu GitHub..."
            PushSuccess = "✅ Repository erfolgreich gepusht!"
            PushError = "❌ Fehler beim Pushen"
            PossibleIssues = "Mögliche Probleme:"
            Issue1 = "- Repository existiert nicht auf GitHub"
            Issue2 = "- Falscher Username"
            Issue3 = "- Keine Git-Authentifizierung"
            CheckAndRetry = "Prüfe und versuche es erneut mit:"
            CommandsNotExecuted = "Befehle wurden nicht ausgeführt."
            ExecuteManually = "Du kannst sie manuell ausführen wenn du bereit bist."
            PressAnyKey = "Drücke eine beliebige Taste zum Beenden..."
        }
        EN = @{
            Header = "GitHub Repository Setup"
            ProjectInfo = "Project:"
            Name = "Name:"
            Description = "Description:"
            Path = "Path:"
            GitStatus = "Git Status:"
            GitInitialized = "✅ Git repository initialized"
            Commits = "✅ Commits:"
            UncommittedChanges = "⚠️  Uncommitted changes present"
            AllCommitted = "✅ All changes committed"
            NoGitRepo = "❌ No Git repository"
            PleaseInitGit = "Please initialize Git first:"
            GitCLIStatus = "GitHub CLI Status:"
            GitCLIInstalled = "✅ GitHub CLI installed:"
            GitCLILoggedIn = "✅ Logged in to GitHub"
            GitCLINotLoggedIn = "⚠️  Not logged in to GitHub"
            GitCLINotInstalled = "❌ GitHub CLI not installed"
            Download = "Download:"
            OrInstall = "Or:"
            GitCLIAvailable = "GitHub CLI is available! Recommended method:"
            UseGitCLI = "Do you want to create the repository with GitHub CLI?"
            YesCLI = "[y] Yes, with GitHub CLI (recommended, fast)"
            NoManual = "[n] No, show me the manual method"
            Choice = "Choice (y/n)"
            CreateWithCLI = "Create repository with GitHub CLI"
            CheckingLogin = "Checking GitHub login..."
            NotLoggedIn = "You are not logged in to GitHub."
            StartingLogin = "Starting GitHub login..."
            LoginFailed = "❌ Login failed"
            CreatingRepo = "Creating repository on GitHub..."
            RepoSettings = "Repository settings:"
            Visibility = "Visibility: Public"
            License = "License: Apache-2.0"
            Continue = "Continue? (y/n):"
            Creating = "Creating repository..."
            Success = "✅ Repository successfully created and pushed!"
            RepoURL = "Repository URL:"
            NextSteps = "Next steps:"
            Step1 = "1. Visit your repository in the browser"
            Step2 = "2. Adjust the description if needed"
            Step3 = "3. Add topics (powershell, sync, nextcloud, raspberry-pi)"
            OpenBrowser = "Open in browser? (y/n):"
            CreateError = "❌ Error creating repository"
            Cancelled = "Cancelled"
            ManualMethod = "GitHub CLI not available - Using manual method"
            ManualHeader = "Manual Repository Creation"
            ManualStep1 = "Step 1: Create repository on GitHub"
            OpenInBrowser = "1. Open in browser:"
            FillForm = "2. Fill out the form:"
            RepoName = "Repository name:"
            Public = "Public: ✅"
            AddREADME = "Add README: ❌ (we already have one!)"
            AddGitignore = "Add .gitignore: ❌ (we already have one!)"
            ChooseLicense = "Choose license: Apache License 2.0 ✅"
            ClickCreate = "3. Click 'Create repository'"
            PressEnterWhenDone = "Press ENTER when you've created the repository..."
            ManualStep2 = "Step 2: Connect local repository"
            EnterUsername = "Please enter your GitHub username:"
            RunCommands = "Run the following commands:"
            ExecuteNow = "Should I execute these commands now? (y/n):"
            AddingRemote = "Adding remote..."
            RemoteAdded = "✅ Remote added"
            RenamingBranch = "Renaming branch to main..."
            Pushing = "Pushing to GitHub..."
            PushSuccess = "✅ Repository successfully pushed!"
            PushError = "❌ Error pushing"
            PossibleIssues = "Possible issues:"
            Issue1 = "- Repository doesn't exist on GitHub"
            Issue2 = "- Wrong username"
            Issue3 = "- No Git authentication"
            CheckAndRetry = "Check and retry with:"
            CommandsNotExecuted = "Commands were not executed."
            ExecuteManually = "You can execute them manually when ready."
            PressAnyKey = "Press any key to exit..."
        }
    }

    return $Texts[$Lang][$Key]
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

Show-Header (Get-Text "Header")

# Project info
$repoName = "project-sync-manager"
$description = "Intelligent sync tool for development projects with Nextcloud support"
$projectPath = $PSScriptRoot

Write-Host (Get-Text "ProjectInfo") -ForegroundColor $Colors.Title
Write-Host "  $(Get-Text 'Name')         $repoName" -ForegroundColor $Colors.Info
Write-Host "  $(Get-Text 'Description')  $description" -ForegroundColor $Colors.Info
Write-Host "  $(Get-Text 'Path')         $projectPath" -ForegroundColor $Colors.Info
Write-Host ""

# Check Git status
Write-Host (Get-Text "GitStatus") -ForegroundColor $Colors.Title

Set-Location $projectPath

try {
    $gitStatus = git status --short 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  $(Get-Text 'GitInitialized')" -ForegroundColor $Colors.Success

        $commits = git log --oneline 2>&1 | Measure-Object
        Write-Host "  $(Get-Text 'Commits') $($commits.Count)" -ForegroundColor $Colors.Success

        if ($gitStatus) {
            Write-Host "  $(Get-Text 'UncommittedChanges')" -ForegroundColor $Colors.Warning
        } else {
            Write-Host "  $(Get-Text 'AllCommitted')" -ForegroundColor $Colors.Success
        }
    }
} catch {
    Write-Host "  $(Get-Text 'NoGitRepo')" -ForegroundColor $Colors.Error
    Write-Host ""
    Write-Host (Get-Text "PleaseInitGit") -ForegroundColor $Colors.Warning
    Write-Host "  git init" -ForegroundColor $Colors.Info
    Write-Host "  git add ." -ForegroundColor $Colors.Info
    Write-Host "  git commit -m 'Initial commit'" -ForegroundColor $Colors.Info
    exit 1
}

Write-Host ""

# Check if GitHub CLI is installed
Write-Host (Get-Text "GitCLIStatus") -ForegroundColor $Colors.Title

$hasGhCli = $false
try {
    $ghVersion = gh --version 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  $(Get-Text 'GitCLIInstalled') $($ghVersion[0])" -ForegroundColor $Colors.Success
        $hasGhCli = $true

        # Check auth status
        $ghAuth = gh auth status 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "  $(Get-Text 'GitCLILoggedIn')" -ForegroundColor $Colors.Success
        } else {
            Write-Host "  $(Get-Text 'GitCLINotLoggedIn')" -ForegroundColor $Colors.Warning
        }
    }
} catch {
    Write-Host "  $(Get-Text 'GitCLINotInstalled')" -ForegroundColor $Colors.Warning
    Write-Host "     $(Get-Text 'Download') https://cli.github.com/" -ForegroundColor $Colors.Info
    Write-Host "     $(Get-Text 'OrInstall') winget install GitHub.cli" -ForegroundColor $Colors.Info
}

Write-Host ""
Write-Host "============================================================================" -ForegroundColor $Colors.Title
Write-Host ""

# Choose method
$yesKey = if ($Lang -eq "EN") { "y" } else { "j" }
$noKey = "n"

if ($hasGhCli) {
    Write-Host (Get-Text "GitCLIAvailable") -ForegroundColor $Colors.Success
    Write-Host ""
    Write-Host (Get-Text "UseGitCLI") -ForegroundColor $Colors.Prompt
    Write-Host "  $(Get-Text 'YesCLI')" -ForegroundColor $Colors.Success
    Write-Host "  $(Get-Text 'NoManual')" -ForegroundColor $Colors.Info
    Write-Host ""

    $choice = Read-Host (Get-Text "Choice")

    if ($choice -eq $yesKey) {
        # GitHub CLI method
        Show-Header (Get-Text "CreateWithCLI")

        Write-Host (Get-Text "CheckingLogin") -ForegroundColor $Colors.Info

        $ghAuth = gh auth status 2>&1
        if ($LASTEXITCODE -ne 0) {
            Write-Host ""
            Write-Host (Get-Text "NotLoggedIn") -ForegroundColor $Colors.Warning
            Write-Host (Get-Text "StartingLogin") -ForegroundColor $Colors.Info
            Write-Host ""

            gh auth login

            if ($LASTEXITCODE -ne 0) {
                Write-Host ""
                Write-Host (Get-Text "LoginFailed") -ForegroundColor $Colors.Error
                exit 1
            }
        }

        Write-Host ""
        Write-Host (Get-Text "CreatingRepo") -ForegroundColor $Colors.Info
        Write-Host ""
        Write-Host (Get-Text "RepoSettings") -ForegroundColor $Colors.Title
        Write-Host "  $(Get-Text 'Name')         $repoName" -ForegroundColor $Colors.Info
        Write-Host "  $(Get-Text 'Description')  $description" -ForegroundColor $Colors.Info
        Write-Host "  $(Get-Text 'Visibility')" -ForegroundColor $Colors.Info
        Write-Host "  $(Get-Text 'License')" -ForegroundColor $Colors.Info
        Write-Host ""
        Write-Host (Get-Text "Continue") -ForegroundColor $Colors.Prompt -NoNewline
        $confirm = Read-Host

        if ($confirm -eq $yesKey) {
            Write-Host ""
            Write-Host (Get-Text "Creating") -ForegroundColor $Colors.Info

            # Create repo and push
            gh repo create $repoName `
                --public `
                --description $description `
                --source=. `
                --remote=origin `
                --push

            if ($LASTEXITCODE -eq 0) {
                Write-Host ""
                Write-Host "============================================================================" -ForegroundColor $Colors.Success
                Write-Host "  $(Get-Text 'Success')" -ForegroundColor $Colors.Success
                Write-Host "============================================================================" -ForegroundColor $Colors.Success
                Write-Host ""

                # Get username
                $ghUser = gh api user --jq '.login' 2>&1

                Write-Host (Get-Text "RepoURL") -ForegroundColor $Colors.Title
                Write-Host "  https://github.com/$ghUser/$repoName" -ForegroundColor $Colors.Info
                Write-Host ""
                Write-Host (Get-Text "NextSteps") -ForegroundColor $Colors.Title
                Write-Host "  $(Get-Text 'Step1')" -ForegroundColor $Colors.Info
                Write-Host "  $(Get-Text 'Step2')" -ForegroundColor $Colors.Info
                Write-Host "  $(Get-Text 'Step3')" -ForegroundColor $Colors.Info
                Write-Host ""

                Write-Host (Get-Text "OpenBrowser") -ForegroundColor $Colors.Prompt -NoNewline
                $openBrowser = Read-Host

                if ($openBrowser -eq $yesKey) {
                    gh repo view --web
                }
            } else {
                Write-Host ""
                Write-Host (Get-Text "CreateError") -ForegroundColor $Colors.Error
            }
        } else {
            Write-Host (Get-Text "Cancelled") -ForegroundColor $Colors.Warning
        }
    } else {
        # Show manual method
        Show-Manual-Method
    }
} else {
    # GitHub CLI not available - show manual method
    Write-Host (Get-Text "ManualMethod") -ForegroundColor $Colors.Info
    Write-Host ""
    Show-Manual-Method
}

function Show-Manual-Method {
    Show-Header (Get-Text "ManualHeader")

    Write-Host (Get-Text "ManualStep1") -ForegroundColor $Colors.Title
    Write-Host ""
    Write-Host "  $(Get-Text 'OpenInBrowser')" -ForegroundColor $Colors.Info
    Write-Host "     https://github.com/new" -ForegroundColor $Colors.Prompt
    Write-Host ""
    Write-Host "  $(Get-Text 'FillForm')" -ForegroundColor $Colors.Info
    Write-Host "     $(Get-Text 'RepoName')  $repoName" -ForegroundColor $Colors.Prompt
    Write-Host "     $(Get-Text 'Description')      $description" -ForegroundColor $Colors.Prompt
    Write-Host "     $(Get-Text 'Public')" -ForegroundColor $Colors.Success
    Write-Host "     $(Get-Text 'AddREADME')" -ForegroundColor $Colors.Warning
    Write-Host "     $(Get-Text 'AddGitignore')" -ForegroundColor $Colors.Warning
    Write-Host "     $(Get-Text 'ChooseLicense')" -ForegroundColor $Colors.Success
    Write-Host ""
    Write-Host "  $(Get-Text 'ClickCreate')" -ForegroundColor $Colors.Info
    Write-Host ""

    Write-Host (Get-Text "PressEnterWhenDone") -ForegroundColor $Colors.Prompt
    Read-Host

    Write-Host ""
    Write-Host (Get-Text "ManualStep2") -ForegroundColor $Colors.Title
    Write-Host ""
    Write-Host (Get-Text "EnterUsername") -ForegroundColor $Colors.Prompt -NoNewline
    $username = Read-Host

    $repoUrl = "https://github.com/$username/$repoName.git"

    Write-Host ""
    Write-Host "$(Get-Text 'RepoURL') $repoUrl" -ForegroundColor $Colors.Info
    Write-Host ""
    Write-Host (Get-Text "RunCommands") -ForegroundColor $Colors.Title
    Write-Host ""
    Write-Host "cd `"$projectPath`"" -ForegroundColor $Colors.Prompt
    Write-Host "git remote add origin $repoUrl" -ForegroundColor $Colors.Prompt
    Write-Host "git branch -M main" -ForegroundColor $Colors.Prompt
    Write-Host "git push -u origin main" -ForegroundColor $Colors.Prompt
    Write-Host ""

    Write-Host (Get-Text "ExecuteNow") -ForegroundColor $Colors.Prompt -NoNewline
    $execute = Read-Host

    $yesKey = if ($Lang -eq "EN") { "y" } else { "j" }

    if ($execute -eq $yesKey) {
        Write-Host ""
        Write-Host (Get-Text "AddingRemote") -ForegroundColor $Colors.Info
        git remote add origin $repoUrl

        if ($LASTEXITCODE -eq 0) {
            Write-Host (Get-Text "RemoteAdded") -ForegroundColor $Colors.Success
        }

        Write-Host (Get-Text "RenamingBranch") -ForegroundColor $Colors.Info
        git branch -M main

        Write-Host (Get-Text "Pushing") -ForegroundColor $Colors.Info
        git push -u origin main

        if ($LASTEXITCODE -eq 0) {
            Write-Host ""
            Write-Host "============================================================================" -ForegroundColor $Colors.Success
            Write-Host "  $(Get-Text 'PushSuccess')" -ForegroundColor $Colors.Success
            Write-Host "============================================================================" -ForegroundColor $Colors.Success
            Write-Host ""
            Write-Host (Get-Text "RepoURL") -ForegroundColor $Colors.Title
            Write-Host "  https://github.com/$username/$repoName" -ForegroundColor $Colors.Info
            Write-Host ""

            Write-Host (Get-Text "OpenBrowser") -ForegroundColor $Colors.Prompt -NoNewline
            $openBrowser = Read-Host

            if ($openBrowser -eq $yesKey) {
                Start-Process "https://github.com/$username/$repoName"
            }
        } else {
            Write-Host ""
            Write-Host (Get-Text "PushError") -ForegroundColor $Colors.Error
            Write-Host ""
            Write-Host (Get-Text "PossibleIssues") -ForegroundColor $Colors.Warning
            Write-Host "  $(Get-Text 'Issue1')" -ForegroundColor $Colors.Info
            Write-Host "  $(Get-Text 'Issue2')" -ForegroundColor $Colors.Info
            Write-Host "  $(Get-Text 'Issue3')" -ForegroundColor $Colors.Info
            Write-Host ""
            Write-Host (Get-Text "CheckAndRetry") -ForegroundColor $Colors.Info
            Write-Host "  git push -u origin main" -ForegroundColor $Colors.Prompt
        }
    } else {
        Write-Host ""
        Write-Host (Get-Text "CommandsNotExecuted") -ForegroundColor $Colors.Warning
        Write-Host (Get-Text "ExecuteManually") -ForegroundColor $Colors.Info
    }
}

Write-Host ""
Write-Host (Get-Text "PressAnyKey") -ForegroundColor $Colors.Info
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
