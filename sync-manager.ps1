# ============================================================================
# GitHub Sync Manager v2.0
# Interactive menu for project synchronization via Nextcloud
# Interaktives Menü für Projekt-Synchronisation über Nextcloud
# ============================================================================

param(
    [string]$NextcloudPath = "$env:USERPROFILE\Nextcloud"
)

$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

# Konfiguration / Configuration
$GitHubSource = "C:\Users\david\Desktop\GitHub"
$SyncToolsPath = "C:\Users\david\Desktop\GitHub-Sync-Tools"
$AutoCloseDelay = 3  # Seconds before auto-close / Sekunden bis automatisches Schließen

# Farben / Colors
$Colors = @{
    Title = "Cyan"
    Success = "Green"
    Warning = "Yellow"
    Error = "Red"
    Info = "White"
    Prompt = "Magenta"
}

# Sprache / Language (DE=Deutsch, EN=English)
# Will be set by Select-Language function
$Lang = "DE"

# ============================================================================
# HILFSFUNKTIONEN / HELPER FUNCTIONS
# ============================================================================

function Select-Language {
    Clear-Host
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

    if ($key.Character -eq "1") {
        return "DE"
    }
    elseif ($key.Character -eq "2") {
        return "EN"
    }
    else {
        return "DE"  # Default to German
    }
}

function Get-Text {
    param([string]$Key)

    $Texts = @{
        DE = @{
            Title = "GitHub Sync Manager"
            SystemInfo = "System-Informationen anzeigen"
            SyncStatus = "Sync-Status prüfen"
            ExportReq = "Requirements exportieren (PC 1)"
            SetupSync = "Sync zu Nextcloud einrichten"
            CreateVenv = "venv-Ordner erstellen (PC 2)"
            CreateExclude = "Nextcloud-Exclude-Datei erstellen"
            ShowSteps = "Alle Schritte anzeigen"
            Exit = "Beenden"
            AutoClose = "Schließt automatisch in {0} Sekunden..."
            PressKey = "Drücke eine beliebige Taste..."
        }
        EN = @{
            Title = "GitHub Sync Manager"
            SystemInfo = "Show system information"
            SyncStatus = "Check sync status"
            ExportReq = "Export requirements (PC 1)"
            SetupSync = "Setup Nextcloud sync"
            CreateVenv = "Create venv folders (PC 2)"
            CreateExclude = "Create Nextcloud exclude file"
            ShowSteps = "Show all steps"
            Exit = "Exit"
            AutoClose = "Auto-closing in {0} seconds..."
            PressKey = "Press any key..."
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

function Show-Menu {
    Show-Header (Get-Text "Title")

    Write-Host "  [1] 📊 $(Get-Text 'SystemInfo')" -ForegroundColor $Colors.Info
    Write-Host "  [2] 🔍 $(Get-Text 'SyncStatus')" -ForegroundColor $Colors.Info
    Write-Host "  [3] 📦 $(Get-Text 'ExportReq')" -ForegroundColor $Colors.Info
    Write-Host "  [4] 🚀 $(Get-Text 'SetupSync')" -ForegroundColor $Colors.Info
    Write-Host "  [5] 💾 $(Get-Text 'CreateVenv')" -ForegroundColor $Colors.Info
    Write-Host "  [6] 🛠️  $(Get-Text 'CreateExclude')" -ForegroundColor $Colors.Info
    Write-Host "  [7] 📋 $(Get-Text 'ShowSteps')" -ForegroundColor $Colors.Info
    Write-Host "  [0] ❌ $(Get-Text 'Exit')" -ForegroundColor $Colors.Error
    Write-Host ""
    Write-Host "============================================================================" -ForegroundColor $Colors.Title
    Write-Host ""
}

function Wait-AutoClose {
    Write-Host ""
    $Message = Get-Text "AutoClose"
    Write-Host ($Message -f $AutoCloseDelay) -ForegroundColor $Colors.Warning

    $TimeoutJob = Start-Job -ScriptBlock {
        Start-Sleep -Seconds $args[0]
    } -ArgumentList $AutoCloseDelay

    while ($TimeoutJob.State -eq 'Running') {
        if ([Console]::KeyAvailable) {
            $null = [Console]::ReadKey($true)
            Stop-Job $TimeoutJob
            Remove-Job $TimeoutJob
            return
        }
        Start-Sleep -Milliseconds 100
    }

    Remove-Job $TimeoutJob
}

# ============================================================================
# OPTION 1: SYSTEM-INFORMATIONEN
# ============================================================================

function Show-SystemInfo {
    Show-Header "System-Informationen"

    # Betriebssystem
    $os = Get-CimInstance Win32_OperatingSystem
    Write-Host "[BETRIEBSSYSTEM]" -ForegroundColor $Colors.Title
    Write-Host "  Name:         $($os.Caption)" -ForegroundColor $Colors.Info
    Write-Host "  Version:      $($os.Version)" -ForegroundColor $Colors.Info
    Write-Host "  Build:        $($os.BuildNumber)" -ForegroundColor $Colors.Info
    Write-Host "  Architektur:  $($os.OSArchitecture)" -ForegroundColor $Colors.Info
    Write-Host "  Sprache:      $((Get-Culture).Name)" -ForegroundColor $Colors.Info
    Write-Host ""

    # PowerShell
    Write-Host "[POWERSHELL]" -ForegroundColor $Colors.Title
    Write-Host "  Version:      $($PSVersionTable.PSVersion)" -ForegroundColor $Colors.Info
    Write-Host "  Edition:      $($PSVersionTable.PSEdition)" -ForegroundColor $Colors.Info
    if ($PSVersionTable.PSVersion.Major -lt 7) {
        Write-Host "  Hinweis:      PowerShell 7 empfohlen (schneller, moderner)" -ForegroundColor $Colors.Warning
    } else {
        Write-Host "  Status:       ✅ PowerShell 7 installiert" -ForegroundColor $Colors.Success
    }
    Write-Host ""

    # Python
    Write-Host "[PYTHON]" -ForegroundColor $Colors.Title
    try {
        $pythonVersion = python --version 2>&1
        $pythonPath = (Get-Command python -ErrorAction SilentlyContinue).Source
        Write-Host "  Version:      $pythonVersion" -ForegroundColor $Colors.Success
        Write-Host "  Pfad:         $pythonPath" -ForegroundColor $Colors.Info

        # Pip Version
        $pipVersion = python -m pip --version 2>&1
        Write-Host "  Pip:          $pipVersion" -ForegroundColor $Colors.Info
    } catch {
        Write-Host "  Status:       ❌ Nicht gefunden" -ForegroundColor $Colors.Error
        Write-Host "  Hinweis:      Installiere Python von https://www.python.org" -ForegroundColor $Colors.Warning
    }
    Write-Host ""

    # Git
    Write-Host "[GIT]" -ForegroundColor $Colors.Title
    try {
        $gitVersion = git --version 2>&1
        $gitPath = (Get-Command git -ErrorAction SilentlyContinue).Source
        Write-Host "  Version:      $gitVersion" -ForegroundColor $Colors.Success
        Write-Host "  Pfad:         $gitPath" -ForegroundColor $Colors.Info
    } catch {
        Write-Host "  Status:       ❌ Nicht gefunden" -ForegroundColor $Colors.Error
    }
    Write-Host ""

    # Docker
    Write-Host "[DOCKER]" -ForegroundColor $Colors.Title
    try {
        $dockerVersion = docker --version 2>&1
        Write-Host "  Version:      $dockerVersion" -ForegroundColor $Colors.Success

        $dockerRunning = docker ps 2>&1
        if ($LASTEXITCODE -eq 0) {
            $containerCount = (docker ps --format "{{.ID}}" | Measure-Object).Count
            Write-Host "  Status:       ✅ Running ($containerCount Container)" -ForegroundColor $Colors.Success
        } else {
            Write-Host "  Status:       ⚠️  Installiert, aber nicht gestartet" -ForegroundColor $Colors.Warning
        }
    } catch {
        Write-Host "  Status:       ❌ Nicht installiert" -ForegroundColor $Colors.Error
    }
    Write-Host ""

    # Nextcloud
    Write-Host "[NEXTCLOUD]" -ForegroundColor $Colors.Title
    if (Test-Path $NextcloudPath) {
        Write-Host "  Pfad:         $NextcloudPath" -ForegroundColor $Colors.Success
        Write-Host "  Status:       ✅ Gefunden" -ForegroundColor $Colors.Success

        # Größe
        $size = (Get-ChildItem -Path $NextcloudPath -Recurse -File -ErrorAction SilentlyContinue |
                 Measure-Object -Property Length -Sum).Sum / 1GB
        Write-Host "  Größe:        $([math]::Round($size, 2)) GB" -ForegroundColor $Colors.Info

        # GitHub-Ordner in Nextcloud
        $nextcloudGithub = Join-Path $NextcloudPath "GitHub"
        if (Test-Path $nextcloudGithub) {
            Write-Host "  GitHub:       ✅ Ordner existiert" -ForegroundColor $Colors.Success
        } else {
            Write-Host "  GitHub:       ❌ Ordner existiert nicht" -ForegroundColor $Colors.Warning
        }
    } else {
        Write-Host "  Status:       ❌ Nicht gefunden unter $NextcloudPath" -ForegroundColor $Colors.Error
        Write-Host "  Hinweis:      Passe den Pfad an mit: -NextcloudPath `"Dein\Pfad`"" -ForegroundColor $Colors.Warning
    }
    Write-Host ""

    # Hardware
    Write-Host "[HARDWARE]" -ForegroundColor $Colors.Title
    $cpu = Get-CimInstance Win32_Processor | Select-Object -First 1
    $ram = [math]::Round((Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory / 1GB, 2)
    Write-Host "  CPU:          $($cpu.Name)" -ForegroundColor $Colors.Info
    Write-Host "  Kerne:        $($cpu.NumberOfCores) Cores ($($cpu.NumberOfLogicalProcessors) Threads)" -ForegroundColor $Colors.Info
    Write-Host "  RAM:          $ram GB" -ForegroundColor $Colors.Info
    Write-Host ""

    # Berechtigungen
    Write-Host "[BERECHTIGUNGEN]" -ForegroundColor $Colors.Title
    $isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    if ($isAdmin) {
        Write-Host "  Status:       ✅ Administrator" -ForegroundColor $Colors.Success
        Write-Host "  Hinweis:      Symlinks können erstellt werden" -ForegroundColor $Colors.Success
    } else {
        Write-Host "  Status:       ⚠️  Normaler Benutzer" -ForegroundColor $Colors.Warning
        Write-Host "  Hinweis:      Für Symlinks als Admin ausführen" -ForegroundColor $Colors.Warning
    }
    Write-Host ""

    # Export-Option anbieten
    Write-Host "Möchten Sie diese Informationen exportieren? (J/N): " -ForegroundColor $Colors.Prompt -NoNewline
    $exportChoice = [Console]::ReadKey($true)
    Write-Host ""

    if ($exportChoice.Key -eq 'J' -or $exportChoice.Key -eq 'Y') {
        $exportPath = Join-Path $env:USERPROFILE "Desktop\system-info-$(Get-Date -Format 'yyyy-MM-dd-HHmm').txt"

        # Sammle alle Infos in String
        $report = @"
SYSTEM-INFORMATIONEN - $(Get-Date -Format 'dd.MM.yyyy HH:mm')
============================================================================

[BETRIEBSSYSTEM]
  Name:         $($os.Caption)
  Version:      $($os.Version)
  Build:        $($os.BuildNumber)
  Architektur:  $($os.OSArchitecture)
  Sprache:      $((Get-Culture).Name)

[POWERSHELL]
  Version:      $($PSVersionTable.PSVersion)
  Edition:      $($PSVersionTable.PSEdition)

[PYTHON]
  Version:      $(try { python --version 2>&1 } catch { "Nicht installiert" })
  Pip:          $(try { python -m pip --version 2>&1 } catch { "N/A" })

[GIT]
  Version:      $(try { git --version 2>&1 } catch { "Nicht installiert" })

[DOCKER]
  Version:      $(try { docker --version 2>&1 } catch { "Nicht installiert" })
  Status:       $(try { if ((docker ps 2>&1) -and $LASTEXITCODE -eq 0) { "Running" } else { "Nicht gestartet" } } catch { "Nicht installiert" })

[NEXTCLOUD]
  Pfad:         $NextcloudPath
  Status:       $(if (Test-Path $NextcloudPath) { "Gefunden" } else { "Nicht gefunden" })

[HARDWARE]
  CPU:          $($cpu.Name)
  Kerne:        $($cpu.NumberOfCores) Cores ($($cpu.NumberOfLogicalProcessors) Threads)
  RAM:          $ram GB

[BERECHTIGUNGEN]
  Status:       $(if ($isAdmin) { "Administrator" } else { "Normaler Benutzer" })

============================================================================
Exportiert von GitHub Sync Manager v2.0
"@

        $report | Out-File -FilePath $exportPath -Encoding UTF8
        Write-Host "✅ Exportiert nach: $exportPath" -ForegroundColor $Colors.Success
        Start-Sleep -Seconds 2
    }

    Wait-AutoClose
}

# ============================================================================
# OPTION 2: SYNC-STATUS PRÜFEN
# ============================================================================

function Show-SyncStatus {
    Show-Header "Sync-Status"

    Write-Host "[GITHUB-PROJEKTE]" -ForegroundColor $Colors.Title
    Write-Host ""

    if (-not (Test-Path $GitHubSource)) {
        Write-Host "  ❌ GitHub-Ordner nicht gefunden: $GitHubSource" -ForegroundColor $Colors.Error
        Wait-AutoClose
        return
    }

    $projects = Get-ChildItem -Path $GitHubSource -Directory

    foreach ($project in $projects) {
        Write-Host "  📁 $($project.Name)" -ForegroundColor $Colors.Title

        # Größe
        $size = (Get-ChildItem -Path $project.FullName -Recurse -File -ErrorAction SilentlyContinue |
                 Measure-Object -Property Length -Sum).Sum / 1MB
        Write-Host "     Größe: $([math]::Round($size, 2)) MB" -ForegroundColor $Colors.Info

        # Git Status
        $gitPath = Join-Path $project.FullName ".git"
        if (Test-Path $gitPath) {
            Write-Host "     Git: ✅ Repository" -ForegroundColor $Colors.Success
        } else {
            Write-Host "     Git: ❌ Kein Repository" -ForegroundColor $Colors.Warning
        }

        # venv Check
        $venvPaths = @(
            (Join-Path $project.FullName "venv"),
            (Join-Path $project.FullName "backend\venv"),
            (Join-Path $project.FullName ".venv")
        )

        $hasVenv = $false
        foreach ($venvPath in $venvPaths) {
            if (Test-Path $venvPath) {
                $venvSize = (Get-ChildItem -Path $venvPath -Recurse -File -ErrorAction SilentlyContinue |
                            Measure-Object -Property Length -Sum).Sum / 1MB
                Write-Host "     venv: ✅ Gefunden ($([math]::Round($venvSize, 2)) MB)" -ForegroundColor $Colors.Success
                $hasVenv = $true
                break
            }
        }
        if (-not $hasVenv) {
            Write-Host "     venv: ❌ Nicht gefunden" -ForegroundColor $Colors.Warning
        }

        # Requirements.txt Check
        $reqPaths = @(
            (Join-Path $project.FullName "requirements.txt"),
            (Join-Path $project.FullName "backend\requirements.txt")
        )

        $hasReq = $false
        foreach ($reqPath in $reqPaths) {
            if (Test-Path $reqPath) {
                $packageCount = (Get-Content $reqPath | Where-Object { $_ -and $_ -notmatch '^#' }).Count
                Write-Host "     requirements.txt: ✅ Gefunden ($packageCount Pakete)" -ForegroundColor $Colors.Success
                $hasReq = $true
                break
            }
        }
        if (-not $hasReq) {
            Write-Host "     requirements.txt: ❌ Nicht gefunden" -ForegroundColor $Colors.Warning
        }

        # .claude Check
        $claudePath = Join-Path $project.FullName ".claude"
        if (Test-Path $claudePath) {
            $claudeSize = (Get-ChildItem -Path $claudePath -Recurse -File -ErrorAction SilentlyContinue |
                          Measure-Object -Property Length -Sum).Sum / 1MB
            Write-Host "     .claude: ✅ Gefunden ($([math]::Round($claudeSize, 2)) MB)" -ForegroundColor $Colors.Success
        } else {
            Write-Host "     .claude: ❌ Nicht gefunden" -ForegroundColor $Colors.Info
        }

        Write-Host ""
    }

    # Nextcloud GitHub-Ordner Status
    $nextcloudGithub = Join-Path $NextcloudPath "GitHub"
    Write-Host "[NEXTCLOUD SYNC]" -ForegroundColor $Colors.Title
    Write-Host ""

    if (Test-Path $nextcloudGithub) {
        Write-Host "  ✅ GitHub-Ordner in Nextcloud gefunden" -ForegroundColor $Colors.Success
        Write-Host "     Pfad: $nextcloudGithub" -ForegroundColor $Colors.Info

        $ncProjects = Get-ChildItem -Path $nextcloudGithub -Directory
        Write-Host "     Projekte: $($ncProjects.Count)" -ForegroundColor $Colors.Info

        # Exclude File Check
        $excludeFile = Join-Path $nextcloudGithub ".sync_exclude.lst"
        if (Test-Path $excludeFile) {
            Write-Host "     .sync_exclude.lst: ✅ Vorhanden" -ForegroundColor $Colors.Success
        } else {
            Write-Host "     .sync_exclude.lst: ⚠️  Nicht gefunden (sollte erstellt werden!)" -ForegroundColor $Colors.Warning
        }
    } else {
        Write-Host "  ❌ GitHub-Ordner nicht in Nextcloud" -ForegroundColor $Colors.Warning
        Write-Host "     Verwende Option [4] um Sync einzurichten" -ForegroundColor $Colors.Info
    }
    Write-Host ""

    Wait-AutoClose
}

# ============================================================================
# OPTION 3: REQUIREMENTS EXPORTIEREN
# ============================================================================

function Export-Requirements {
    Show-Header "Requirements exportieren"

    Write-Host "Exportiere Python-Dependencies für alle Projekte..." -ForegroundColor $Colors.Info
    Write-Host ""

    if (-not (Test-Path $GitHubSource)) {
        Write-Host "❌ GitHub-Ordner nicht gefunden: $GitHubSource" -ForegroundColor $Colors.Error
        Wait-AutoClose
        return
    }

    $projects = Get-ChildItem -Path $GitHubSource -Directory
    $exported = 0

    foreach ($project in $projects) {
        Write-Host "📁 $($project.Name)..." -ForegroundColor $Colors.Title

        # Suche nach venv
        $venvPaths = @(
            (Join-Path $project.FullName "backend\venv"),
            (Join-Path $project.FullName "venv"),
            (Join-Path $project.FullName ".venv")
        )

        $venvFound = $false
        $venvPath = $null

        foreach ($path in $venvPaths) {
            if (Test-Path $path) {
                $venvPath = $path
                $venvFound = $true
                break
            }
        }

        if (-not $venvFound) {
            Write-Host "   ⚠️  Keine venv gefunden - überspringe" -ForegroundColor $Colors.Warning
            Write-Host ""
            continue
        }

        # Exportiere Requirements
        $activateScript = Join-Path $venvPath "Scripts\Activate.ps1"

        if (Test-Path $activateScript) {
            $projectPath = $project.FullName
            if (Test-Path (Join-Path $projectPath "backend")) {
                $projectPath = Join-Path $projectPath "backend"
            }

            $requirementsPath = Join-Path $projectPath "requirements.txt"

            try {
                # Aktiviere venv und exportiere
                $oldLocation = Get-Location
                Set-Location $projectPath

                & $activateScript
                pip freeze > $requirementsPath 2>&1 | Out-Null
                deactivate 2>&1 | Out-Null

                Set-Location $oldLocation

                if (Test-Path $requirementsPath) {
                    $packageCount = (Get-Content $requirementsPath | Where-Object { $_ -and $_ -notmatch '^#' }).Count
                    Write-Host "   ✅ Exportiert: $packageCount Pakete" -ForegroundColor $Colors.Success
                    Write-Host "      → $requirementsPath" -ForegroundColor $Colors.Info
                    $exported++
                } else {
                    Write-Host "   ❌ Export fehlgeschlagen" -ForegroundColor $Colors.Error
                }
            } catch {
                Write-Host "   ❌ Fehler: $_" -ForegroundColor $Colors.Error
            }
        } else {
            Write-Host "   ❌ Activate.ps1 nicht gefunden" -ForegroundColor $Colors.Error
        }

        Write-Host ""
    }

    Write-Host "============================================================================" -ForegroundColor $Colors.Title
    Write-Host "Zusammenfassung: $exported Projekt(e) exportiert" -ForegroundColor $Colors.Success
    Write-Host "============================================================================" -ForegroundColor $Colors.Title
    Write-Host ""

    Wait-AutoClose
}

# ============================================================================
# OPTION 4: SYNC ZU NEXTCLOUD EINRICHTEN
# ============================================================================

function Setup-NextcloudSync {
    Show-Header "Sync zu Nextcloud einrichten"

    # Prüfe Nextcloud
    if (-not (Test-Path $NextcloudPath)) {
        Write-Host "❌ Nextcloud nicht gefunden unter: $NextcloudPath" -ForegroundColor $Colors.Error
        Write-Host ""
        Write-Host "Bitte gib den korrekten Pfad an:" -ForegroundColor $Colors.Warning
        Write-Host "Hinweis: Anführungszeichen werden automatisch entfernt" -ForegroundColor $Colors.Info
        $newPath = Read-Host "Nextcloud-Pfad"

        # Remove quotes if present
        $newPath = $newPath.Trim('"').Trim("'")

        if (Test-Path $newPath) {
            $script:NextcloudPath = $newPath
        } else {
            Write-Host "❌ Pfad nicht gefunden: $newPath" -ForegroundColor $Colors.Error
            Wait-AutoClose
            return
        }
    }

    Write-Host "✅ Nextcloud gefunden: $NextcloudPath" -ForegroundColor $Colors.Success
    Write-Host ""

    # Erstelle GitHub-Ordner in Nextcloud
    $nextcloudGithub = Join-Path $NextcloudPath "GitHub"

    if (-not (Test-Path $nextcloudGithub)) {
        Write-Host "Erstelle GitHub-Ordner in Nextcloud..." -ForegroundColor $Colors.Info
        New-Item -ItemType Directory -Path $nextcloudGithub | Out-Null
        Write-Host "✅ Ordner erstellt" -ForegroundColor $Colors.Success
    } else {
        Write-Host "✅ GitHub-Ordner existiert bereits" -ForegroundColor $Colors.Success
    }
    Write-Host ""

    # Kopiere Projekte (Ordner)
    Write-Host "Kopiere Projekte nach Nextcloud..." -ForegroundColor $Colors.Info
    Write-Host "(venv, __pycache__, .git, *.log werden ausgeschlossen)" -ForegroundColor $Colors.Warning
    Write-Host ""

    if (Test-Path $GitHubSource) {
        # 1. Kopiere alle Projekt-Ordner
        $projects = Get-ChildItem -Path $GitHubSource -Directory

        foreach ($project in $projects) {
            Write-Host "  📁 $($project.Name)..." -ForegroundColor $Colors.Info

            $source = $project.FullName
            $dest = Join-Path $nextcloudGithub $project.Name

            # Robocopy mit Excludes
            robocopy $source $dest /MIR /XD venv __pycache__ .git .venv node_modules /XF *.pyc *.pyo *.log /R:2 /W:3 /NJH /NJS /NDL /NC /NS | Out-Null

            if ($LASTEXITCODE -le 7) {
                Write-Host "     ✅ Kopiert" -ForegroundColor $Colors.Success
            } else {
                Write-Host "     ⚠️  Warnung (Exit Code: $LASTEXITCODE)" -ForegroundColor $Colors.Warning
            }
        }

        Write-Host ""
        Write-Host "Kopiere Hauptordner-Dateien..." -ForegroundColor $Colors.Info

        # 2. Kopiere wichtige Dateien aus dem Hauptordner
        $mainFiles = Get-ChildItem -Path $GitHubSource -File -Include "*.txt", "*.md", "*.ps1", "*.json" -ErrorAction SilentlyContinue

        foreach ($file in $mainFiles) {
            Write-Host "  📄 $($file.Name)..." -ForegroundColor $Colors.Info
            $destFile = Join-Path $nextcloudGithub $file.Name
            Copy-Item -Path $file.FullName -Destination $destFile -Force
            Write-Host "     ✅ Kopiert" -ForegroundColor $Colors.Success
        }
    }

    Write-Host ""
    Write-Host "============================================================================" -ForegroundColor $Colors.Title
    Write-Host "Sync eingerichtet!" -ForegroundColor $Colors.Success
    Write-Host "============================================================================" -ForegroundColor $Colors.Title
    Write-Host ""
    Write-Host "Nächste Schritte:" -ForegroundColor $Colors.Info
    Write-Host "1. Erstelle .sync_exclude.lst mit Option [6]" -ForegroundColor $Colors.Info
    Write-Host "2. Warte bis Nextcloud synchronisiert" -ForegroundColor $Colors.Info
    Write-Host "3. Auf PC 2: Verwende Option [5] um venv zu erstellen" -ForegroundColor $Colors.Info
    Write-Host ""

    Wait-AutoClose
}

# ============================================================================
# OPTION 5: VENV ERSTELLEN (PC 2)
# ============================================================================

function Create-Venvs {
    Show-Header "venv-Ordner erstellen (PC 2)"

    Write-Host "Dieses Tool erstellt identische venv auf PC 2" -ForegroundColor $Colors.Info
    Write-Host ""

    # Bestimme Quell-Ordner
    Write-Host "Wo liegen die synchronisierten Projekte?" -ForegroundColor $Colors.Prompt
    Write-Host "  [1] Nextcloud: $NextcloudPath\GitHub" -ForegroundColor $Colors.Info
    Write-Host "  [2] Lokales GitHub: $GitHubSource" -ForegroundColor $Colors.Info
    Write-Host "  [3] Anderer Pfad" -ForegroundColor $Colors.Info
    Write-Host ""

    $choice = Read-Host "Auswahl"

    $sourcePath = ""
    switch ($choice) {
        "1" { $sourcePath = Join-Path $NextcloudPath "GitHub" }
        "2" { $sourcePath = $GitHubSource }
        "3" {
            $sourcePath = Read-Host "Pfad eingeben"
        }
        default {
            Write-Host "❌ Ungültige Auswahl" -ForegroundColor $Colors.Error
            Wait-AutoClose
            return
        }
    }

    if (-not (Test-Path $sourcePath)) {
        Write-Host "❌ Pfad nicht gefunden: $sourcePath" -ForegroundColor $Colors.Error
        Wait-AutoClose
        return
    }

    Write-Host ""
    Write-Host "Scanne Projekte in: $sourcePath" -ForegroundColor $Colors.Info
    Write-Host ""

    $projects = Get-ChildItem -Path $sourcePath -Directory

    foreach ($project in $projects) {
        # Suche nach requirements.txt
        $reqPaths = @(
            (Join-Path $project.FullName "backend\requirements.txt"),
            (Join-Path $project.FullName "requirements.txt")
        )

        $reqFound = $false
        $reqPath = $null
        $projectPath = $project.FullName

        foreach ($path in $reqPaths) {
            if (Test-Path $path) {
                $reqPath = $path
                $reqFound = $true
                if ($path.Contains("backend")) {
                    $projectPath = Join-Path $project.FullName "backend"
                }
                break
            }
        }

        if (-not $reqFound) {
            Write-Host "📁 $($project.Name): ⚠️  Keine requirements.txt - überspringe" -ForegroundColor $Colors.Warning
            continue
        }

        Write-Host "📁 $($project.Name)" -ForegroundColor $Colors.Title
        Write-Host "   Requirements: ✅ Gefunden" -ForegroundColor $Colors.Success

        # Prüfe ob venv bereits existiert
        $venvPath = Join-Path $projectPath "venv"

        if (Test-Path $venvPath) {
            Write-Host "   venv existiert bereits - überschreiben? (j/n): " -ForegroundColor $Colors.Prompt -NoNewline
            $overwrite = Read-Host

            if ($overwrite -ne "j") {
                Write-Host "   ⏭️  Übersprungen" -ForegroundColor $Colors.Warning
                Write-Host ""
                continue
            }

            Remove-Item -Path $venvPath -Recurse -Force
            Write-Host "   Alte venv gelöscht" -ForegroundColor $Colors.Info
        }

        # Erstelle venv
        Write-Host "   Erstelle venv..." -ForegroundColor $Colors.Info

        try {
            Set-Location $projectPath

            python -m venv venv 2>&1 | Out-Null

            if (Test-Path "venv\Scripts\Activate.ps1") {
                Write-Host "   ✅ venv erstellt" -ForegroundColor $Colors.Success

                # Aktiviere und installiere
                Write-Host "   Installiere Dependencies..." -ForegroundColor $Colors.Info

                & ".\venv\Scripts\Activate.ps1"
                python -m pip install --upgrade pip 2>&1 | Out-Null
                pip install -r requirements.txt 2>&1 | Out-Null
                deactivate 2>&1 | Out-Null

                Write-Host "   ✅ Dependencies installiert" -ForegroundColor $Colors.Success
            } else {
                Write-Host "   ❌ venv-Erstellung fehlgeschlagen" -ForegroundColor $Colors.Error
            }
        } catch {
            Write-Host "   ❌ Fehler: $_" -ForegroundColor $Colors.Error
        }

        Write-Host ""
    }

    Write-Host "============================================================================" -ForegroundColor $Colors.Title
    Write-Host "venv-Erstellung abgeschlossen!" -ForegroundColor $Colors.Success
    Write-Host "============================================================================" -ForegroundColor $Colors.Title
    Write-Host ""

    Wait-AutoClose
}

# ============================================================================
# OPTION 6: EXCLUDE-DATEI ERSTELLEN
# ============================================================================

function Create-ExcludeFile {
    Show-Header "Nextcloud Exclude-Datei erstellen"

    $nextcloudGithub = Join-Path $NextcloudPath "GitHub"

    if (-not (Test-Path $nextcloudGithub)) {
        Write-Host "❌ GitHub-Ordner in Nextcloud nicht gefunden" -ForegroundColor $Colors.Error
        Write-Host "   Verwende zuerst Option [4] um Sync einzurichten" -ForegroundColor $Colors.Warning
        Wait-AutoClose
        return
    }

    $excludeFile = Join-Path $nextcloudGithub ".sync_exclude.lst"

    $excludeContent = @"
# Python Virtual Environments
venv/
.venv/
env/
ENV/
__pycache__/
*.pyc
*.pyo
*.pyd

# Logs
*.log
logs/

# Node modules
node_modules/

# IDE
.vscode/
.idea/
*.swp
*.swo

# OS
.DS_Store
Thumbs.db
Desktop.ini

# Build
dist/
build/
*.egg-info/

# Git (optional - auskommentieren falls gewünscht)
# .git/
"@

    Write-Host "Erstelle .sync_exclude.lst..." -ForegroundColor $Colors.Info
    Write-Host "Pfad: $excludeFile" -ForegroundColor $Colors.Info
    Write-Host ""

    $excludeContent | Out-File -FilePath $excludeFile -Encoding UTF8

    Write-Host "✅ Exclude-Datei erstellt!" -ForegroundColor $Colors.Success
    Write-Host ""
    Write-Host "Folgende Dateien/Ordner werden NICHT synchronisiert:" -ForegroundColor $Colors.Info
    Write-Host ""

    $excludeContent.Split("`n") | Where-Object { $_ -and $_ -notmatch '^#' -and $_.Trim() } | ForEach-Object {
        Write-Host "  ❌ $_" -ForegroundColor $Colors.Warning
    }

    Write-Host ""
    Write-Host "Hinweis: Nextcloud muss neu gestartet werden damit die Änderungen wirksam werden!" -ForegroundColor $Colors.Warning
    Write-Host ""

    Wait-AutoClose
}

# ============================================================================
# OPTION 7: ALLE SCHRITTE
# ============================================================================

function Show-AllSteps {
    Show-Header "Komplette Sync-Anleitung"

    Write-Host "[VORBEREITUNG]" -ForegroundColor $Colors.Title
    Write-Host ""
    Write-Host "1. System-Infos prüfen (Option 1)" -ForegroundColor $Colors.Info
    Write-Host "   → Prüfe ob Python, Git, Docker installiert sind" -ForegroundColor $Colors.Info
    Write-Host ""
    Write-Host "2. Sync-Status prüfen (Option 2)" -ForegroundColor $Colors.Info
    Write-Host "   → Zeigt alle Projekte und deren Status" -ForegroundColor $Colors.Info
    Write-Host ""
    Write-Host "============================================================================" -ForegroundColor $Colors.Title
    Write-Host ""
    Write-Host "[PC 1 - VORBEREITUNG]" -ForegroundColor $Colors.Title
    Write-Host ""
    Write-Host "3. Requirements exportieren (Option 3)" -ForegroundColor $Colors.Info
    Write-Host "   → Exportiert alle Python-Dependencies" -ForegroundColor $Colors.Info
    Write-Host "   → Erstellt requirements.txt in jedem Projekt" -ForegroundColor $Colors.Info
    Write-Host ""
    Write-Host "4. Sync zu Nextcloud einrichten (Option 4)" -ForegroundColor $Colors.Info
    Write-Host "   → Kopiert Projekte nach Nextcloud/GitHub" -ForegroundColor $Colors.Info
    Write-Host "   → Schließt venv, __pycache__, etc. aus" -ForegroundColor $Colors.Info
    Write-Host ""
    Write-Host "5. Exclude-Datei erstellen (Option 6)" -ForegroundColor $Colors.Info
    Write-Host "   → Erstellt .sync_exclude.lst" -ForegroundColor $Colors.Info
    Write-Host "   → Verhindert Sync von venv und Cache" -ForegroundColor $Colors.Info
    Write-Host ""
    Write-Host "6. Warte bis Nextcloud synchronisiert" -ForegroundColor $Colors.Warning
    Write-Host ""
    Write-Host "============================================================================" -ForegroundColor $Colors.Title
    Write-Host ""
    Write-Host "[PC 2 - EINRICHTUNG]" -ForegroundColor $Colors.Title
    Write-Host ""
    Write-Host "7. Warte bis Nextcloud synchronisiert ist" -ForegroundColor $Colors.Info
    Write-Host ""
    Write-Host "8. venv-Ordner erstellen (Option 5)" -ForegroundColor $Colors.Info
    Write-Host "   → Erstellt venv aus requirements.txt" -ForegroundColor $Colors.Info
    Write-Host "   → Installiert alle Dependencies identisch" -ForegroundColor $Colors.Info
    Write-Host ""
    Write-Host "9. Fertig! 🎉" -ForegroundColor $Colors.Success
    Write-Host "   → Alle Änderungen werden automatisch synchronisiert" -ForegroundColor $Colors.Success
    Write-Host "   → venv wird auf jedem PC lokal neu erstellt" -ForegroundColor $Colors.Success
    Write-Host ""
    Write-Host "============================================================================" -ForegroundColor $Colors.Title
    Write-Host ""
    Write-Host "[SYMLINK (OPTIONAL)]" -ForegroundColor $Colors.Title
    Write-Host ""
    Write-Host "Falls du mit dem gewohnten Pfad arbeiten willst:" -ForegroundColor $Colors.Info
    Write-Host ""
    Write-Host "Als Administrator ausführen:" -ForegroundColor $Colors.Warning
    Write-Host '  New-Item -ItemType SymbolicLink -Path "C:\Users\david\Desktop\GitHub" -Target "$NextcloudPath\GitHub"' -ForegroundColor $Colors.Info
    Write-Host ""
    Write-Host "Dann funktioniert beides:" -ForegroundColor $Colors.Success
    Write-Host "  → C:\Users\david\Desktop\GitHub (Symlink)" -ForegroundColor $Colors.Info
    Write-Host "  → $NextcloudPath\GitHub (Echt)" -ForegroundColor $Colors.Info
    Write-Host ""

    Wait-AutoClose
}

# ============================================================================
# ADMIN CHECK & ELEVATION
# ============================================================================

function Test-Admin {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($identity)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Request-AdminRights {
    if (-not (Test-Admin)) {
        Write-Host ""
        Write-Host "⚠️  Dieses Skript benötigt Administrator-Rechte für einige Funktionen." -ForegroundColor $Colors.Warning
        Write-Host "Möchten Sie als Administrator neu starten? (J/N): " -ForegroundColor $Colors.Prompt -NoNewline

        $response = [Console]::ReadKey($true)
        Write-Host ""

        if ($response.Key -eq 'J' -or $response.Key -eq 'Y') {
            Write-Host "Starte neu mit Admin-Rechten..." -ForegroundColor $Colors.Info
            Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
            exit
        }
        else {
            Write-Host "Fortfahren ohne Admin-Rechte..." -ForegroundColor $Colors.Warning
            Write-Host "Einige Funktionen (z.B. Symlinks) werden nicht verfügbar sein." -ForegroundColor $Colors.Warning
            Write-Host ""
            Write-Host "Drücke ENTER zum Fortfahren..." -ForegroundColor $Colors.Info
            Read-Host
        }
    }
}

# ============================================================================
# MAIN MENU LOOP
# ============================================================================

# Select language at startup
$Lang = Select-Language

# Request admin rights on startup
Request-AdminRights

do {
    Show-Menu

    # Read single key without Enter
    $key = [Console]::ReadKey($true)
    $choice = $key.KeyChar.ToString()

    switch ($choice) {
        "1" { Show-SystemInfo }
        "2" { Show-SyncStatus }
        "3" { Export-Requirements }
        "4" { Setup-NextcloudSync }
        "5" { Create-Venvs }
        "6" { Create-ExcludeFile }
        "7" { Show-AllSteps }
        "0" {
            Write-Host ""
            Write-Host "Auf Wiedersehen! 👋 / Goodbye! 👋" -ForegroundColor $Colors.Success
            Write-Host ""
            Wait-AutoClose
            exit
        }
        default {
            Write-Host ""
            Write-Host "❌ Ungültige Auswahl! / Invalid choice!" -ForegroundColor $Colors.Error
            Start-Sleep -Seconds 1
        }
    }
} while ($true)
