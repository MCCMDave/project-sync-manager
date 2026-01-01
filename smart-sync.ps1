# ============================================================================
# Smart Sync v1.0
# Intelligente Synchronisation - nur geaenderte Dateien
# ============================================================================

param(
    [string]$NextcloudPath = "C:\Users\david\Desktop\nextcloud\GitHub",
    [string]$GitHubPath = "C:\Users\david\Desktop\GitHub",
    [switch]$DryRun,
    [switch]$Force
)

$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# Farben
$Colors = @{
    Title = "Cyan"
    Success = "Green"
    Warning = "Yellow"
    Error = "Red"
    Info = "White"
    Highlight = "Magenta"
}

# Ausschluss-Muster (werden NICHT synchronisiert)
$ExcludePatterns = @(
    "venv", ".venv", "env",           # Python Virtual Environments
    "__pycache__", "*.pyc", "*.pyo",  # Python Cache
    "node_modules",                    # Node.js
    ".git",                            # Git (optional - Code ist eh in GitHub)
    "*.log", "logs",                   # Logs
    "*.db", "*.sqlite",                # Datenbanken (werden separat gesichert!)
    ".env", "*.env.local",            # Secrets (NIEMALS syncen!)
    "dist", "build", "*.egg-info",    # Build-Artefakte
    ".vscode", ".idea",               # IDE
    "Thumbs.db", "Desktop.ini",       # Windows
    ".DS_Store"                        # macOS
)

# Wichtige Dateien die IMMER synchronisiert werden
$ImportantPatterns = @(
    "requirements.txt",
    "package.json",
    "docker-compose.yml",
    "Dockerfile",
    "*.md",
    "*.ps1",
    "*.py",
    "*.js",
    "*.html",
    "*.css",
    "*.json",
    "*.yml",
    "*.yaml"
)

function Show-Header {
    param([string]$Title)
    Clear-Host
    Write-Host ""
    Write-Host "============================================================================" -ForegroundColor $Colors.Title
    Write-Host "  $Title" -ForegroundColor $Colors.Title
    Write-Host "============================================================================" -ForegroundColor $Colors.Title
    Write-Host ""
}

function Get-ProjectsWithChanges {
    <#
    .SYNOPSIS
    Findet Projekte mit uncommitted Changes oder neueren Dateien
    #>

    $projects = Get-ChildItem -Path $GitHubPath -Directory |
                Where-Object { $_.Name -notlike ".*" }

    $changedProjects = @()

    foreach ($project in $projects) {
        $gitPath = Join-Path $project.FullName ".git"
        $hasChanges = $false
        $changeType = ""

        if (Test-Path $gitPath) {
            # Git-basierte Pruefung
            Push-Location $project.FullName
            $status = git status --porcelain 2>&1

            if ($status) {
                $hasChanges = $true
                $changeType = "Git Changes"
            }
            Pop-Location
        }

        # Datei-basierte Pruefung (fuer Nicht-Git oder zusaetzliche Sicherheit)
        $ncProject = Join-Path $NextcloudPath $project.Name

        if (Test-Path $ncProject) {
            # Vergleiche neueste Dateien
            $localNewest = Get-ChildItem -Path $project.FullName -Recurse -File -ErrorAction SilentlyContinue |
                           Where-Object { $_.FullName -notmatch "(venv|__pycache__|node_modules|\.git)" } |
                           Sort-Object LastWriteTime -Descending |
                           Select-Object -First 1

            $ncNewest = Get-ChildItem -Path $ncProject -Recurse -File -ErrorAction SilentlyContinue |
                        Where-Object { $_.FullName -notmatch "(venv|__pycache__|node_modules|\.git)" } |
                        Sort-Object LastWriteTime -Descending |
                        Select-Object -First 1

            if ($localNewest -and $ncNewest) {
                if ($localNewest.LastWriteTime -gt $ncNewest.LastWriteTime) {
                    $hasChanges = $true
                    if ($changeType) { $changeType += " + " }
                    $changeType += "Newer Files"
                }
            }
        } else {
            # Projekt existiert noch nicht in Nextcloud
            $hasChanges = $true
            $changeType = "New Project"
        }

        if ($hasChanges -or $Force) {
            $changedProjects += @{
                Name = $project.Name
                Path = $project.FullName
                ChangeType = if ($Force) { "Force Sync" } else { $changeType }
            }
        }
    }

    return $changedProjects
}

function Sync-Project {
    param(
        [string]$Name,
        [string]$SourcePath,
        [string]$ChangeType
    )

    Write-Host ""
    Write-Host "[$Name] - $ChangeType" -ForegroundColor $Colors.Title

    $destPath = Join-Path $NextcloudPath $Name

    # Erstelle Ziel-Ordner
    if (-not (Test-Path $destPath)) {
        if (-not $DryRun) {
            New-Item -ItemType Directory -Path $destPath -Force | Out-Null
        }
        Write-Host "  Ordner erstellt" -ForegroundColor $Colors.Info
    }

    # Zaehler
    $copied = 0
    $skipped = 0
    $totalSize = 0

    # Hole alle Dateien (mit Ausschluessen)
    $files = Get-ChildItem -Path $SourcePath -Recurse -File -ErrorAction SilentlyContinue

    foreach ($file in $files) {
        $relativePath = $file.FullName.Substring($SourcePath.Length + 1)
        $skip = $false

        # Pruefe Ausschluesse
        foreach ($pattern in $ExcludePatterns) {
            if ($relativePath -like "*$pattern*") {
                $skip = $true
                break
            }
        }

        if ($skip) {
            $skipped++
            continue
        }

        # Ziel-Pfad
        $destFile = Join-Path $destPath $relativePath
        $destDir = Split-Path $destFile -Parent

        # Pruefe ob Datei neuer ist
        $needsCopy = $true
        if (Test-Path $destFile) {
            $destTime = (Get-Item $destFile).LastWriteTime
            if ($file.LastWriteTime -le $destTime) {
                $needsCopy = $false
                $skipped++
            }
        }

        if ($needsCopy) {
            if ($DryRun) {
                Write-Host "  [DRY] $relativePath" -ForegroundColor $Colors.Warning
            } else {
                # Erstelle Ordner
                if (-not (Test-Path $destDir)) {
                    New-Item -ItemType Directory -Path $destDir -Force | Out-Null
                }
                Copy-Item -Path $file.FullName -Destination $destFile -Force
            }
            $copied++
            $totalSize += $file.Length
        }
    }

    # Statistik
    $sizeKB = [math]::Round($totalSize / 1KB, 2)
    if ($copied -gt 0) {
        Write-Host "  [OK] $copied Dateien kopiert ($sizeKB KB)" -ForegroundColor $Colors.Success
    } else {
        Write-Host "  [OK] Keine Aenderungen" -ForegroundColor $Colors.Info
    }

    if ($skipped -gt 0) {
        Write-Host "  Uebersprungen: $skipped (venv, cache, etc.)" -ForegroundColor $Colors.Info
    }
}

function Show-SyncPreview {
    Show-Header "Sync-Vorschau"

    Write-Host "Suche geaenderte Projekte..." -ForegroundColor $Colors.Info
    Write-Host ""

    $changed = Get-ProjectsWithChanges

    if ($changed.Count -eq 0) {
        Write-Host "[OK] Alles synchron! Keine Aenderungen gefunden." -ForegroundColor $Colors.Success
        return $null
    }

    Write-Host "Folgende Projekte haben Aenderungen:" -ForegroundColor $Colors.Highlight
    Write-Host ""

    $i = 1
    foreach ($project in $changed) {
        Write-Host "  [$i] $($project.Name)" -ForegroundColor $Colors.Title
        Write-Host "      $($project.ChangeType)" -ForegroundColor $Colors.Info
        $i++
    }

    return $changed
}

function Run-SmartSync {
    param([array]$Projects)

    Show-Header "Smart Sync"

    if ($DryRun) {
        Write-Host "=== DRY RUN - Keine Aenderungen werden vorgenommen ===" -ForegroundColor $Colors.Warning
        Write-Host ""
    }

    $successCount = 0

    foreach ($project in $Projects) {
        Sync-Project -Name $project.Name -SourcePath $project.Path -ChangeType $project.ChangeType
        $successCount++
    }

    Write-Host ""
    Write-Host "============================================================================" -ForegroundColor $Colors.Title
    Write-Host "  $successCount Projekt(e) synchronisiert" -ForegroundColor $Colors.Success
    Write-Host "============================================================================" -ForegroundColor $Colors.Title
}

# ============================================================================
# HAUPTMENUE
# ============================================================================

Show-Header "Smart Sync - Intelligente Synchronisation"

Write-Host "Dieser Sync kopiert NUR:" -ForegroundColor $Colors.Info
Write-Host "  [OK] Code-Dateien (*.py, *.js, *.html, etc.)" -ForegroundColor $Colors.Success
Write-Host "  [OK] Konfiguration (requirements.txt, docker-compose.yml)" -ForegroundColor $Colors.Success
Write-Host "  [OK] Dokumentation (*.md)" -ForegroundColor $Colors.Success
Write-Host ""
Write-Host "Dieser Sync ignoriert:" -ForegroundColor $Colors.Warning
Write-Host "  [X] venv, node_modules (zu gross)" -ForegroundColor $Colors.Error
Write-Host "  [X] __pycache__, *.pyc (unnoetiger Cache)" -ForegroundColor $Colors.Error
Write-Host "  [X] .env Dateien (Secrets!)" -ForegroundColor $Colors.Error
Write-Host "  [X] *.db Dateien (nutze backup-databases.ps1)" -ForegroundColor $Colors.Error
Write-Host "  [X] .git (Code ist eh in GitHub)" -ForegroundColor $Colors.Error
Write-Host ""
Write-Host "Optionen:" -ForegroundColor $Colors.Title
Write-Host ""
Write-Host "  [1] Smart Sync (nur geaenderte Projekte)" -ForegroundColor $Colors.Info
Write-Host "  [2] Force Sync (alle Projekte)" -ForegroundColor $Colors.Info
Write-Host "  [3] Vorschau (was wuerde synchronisiert?)" -ForegroundColor $Colors.Info
Write-Host "  [4] Dry-Run (simulieren ohne zu kopieren)" -ForegroundColor $Colors.Info
Write-Host "  [0] Beenden" -ForegroundColor $Colors.Warning
Write-Host ""

$choice = Read-Host "Auswahl"

switch ($choice) {
    "1" {
        $changed = Show-SyncPreview

        if ($changed) {
            Write-Host ""
            $confirm = Read-Host "Jetzt synchronisieren? (j/n)"

            if ($confirm -eq "j") {
                Run-SmartSync -Projects $changed
            }
        }
    }
    "2" {
        $script:Force = $true
        $changed = Get-ProjectsWithChanges
        Run-SmartSync -Projects $changed
    }
    "3" {
        Show-SyncPreview | Out-Null
    }
    "4" {
        $script:DryRun = $true
        $changed = Get-ProjectsWithChanges
        Run-SmartSync -Projects $changed
    }
    "0" {
        Write-Host "Beendet." -ForegroundColor $Colors.Info
        exit
    }
    default {
        Write-Host "Ungueltige Auswahl!" -ForegroundColor $Colors.Error
    }
}

Write-Host ""
Write-Host "Druecke eine beliebige Taste..." -ForegroundColor $Colors.Info
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
