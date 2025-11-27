# ============================================================================
# Manuelle Synchronisation (OHNE Nextcloud-Dauerlauf)
# Erstellt ZIP-Archive für manuelle Übertragung
# ============================================================================

param(
    [switch]$Export,
    [switch]$Import,
    [string]$ArchivePath = "$env:USERPROFILE\Desktop\GitHub-Sync"
)

$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

# ============================================================================
# LANGUAGE SELECTION (if not using switches)
# ============================================================================

if (-not $Export -and -not $Import) {
    Write-Host ""
    Write-Host "============================================================================" -ForegroundColor Cyan
    Write-Host "      MANUAL SYNC - ZIP EXPORT/IMPORT" -ForegroundColor Cyan
    Write-Host "============================================================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Select Language / Sprache wählen:" -ForegroundColor Yellow
    Write-Host "  1. English" -ForegroundColor White
    Write-Host "  2. Deutsch" -ForegroundColor White
    Write-Host "  0. Exit / Beenden" -ForegroundColor White
    Write-Host ""
    Write-Host "Press 1, 2, or 0 / Drücke 1, 2 oder 0" -ForegroundColor Gray

    # Wait for single keypress (no Enter required)
    $langChoice = ""
    while ($langChoice -notin @("1", "2", "0")) {
        $key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        $langChoice = $key.Character
    }

    Write-Host "Selected / Gewählt: $langChoice" -ForegroundColor Green

    switch ($langChoice) {
        "1" { $Lang = "DE" }  # Default to DE for now
        "2" { $Lang = "DE" }
        "0" {
            Write-Host ""
            Write-Host "Exiting in 3 seconds... / Wird in 3 Sekunden beendet..." -ForegroundColor Yellow
            for ($i = 3; $i -gt 0; $i--) {
                Write-Host "  $i..." -ForegroundColor Gray
                Start-Sleep -Seconds 1
            }
            exit 0
        }
    }

    Clear-Host
}

# Konfiguration
$GitHubSource = "C:\Users\david\Desktop\GitHub"

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

function Export-Projects {
    Show-Header "Projekte für manuelle Übertragung exportieren"

    Write-Host "Diese Methode erstellt ZIP-Archive die du MANUELL übertragen kannst:" -ForegroundColor $Colors.Info
    Write-Host "  - Kein Nextcloud-Dauerlauf nötig" -ForegroundColor $Colors.Success
    Write-Host "  - Keine Pi-Belastung" -ForegroundColor $Colors.Success
    Write-Host "  - DU entscheidest WANN synchronisiert wird" -ForegroundColor $Colors.Success
    Write-Host ""

    # Erstelle Archive-Ordner
    if (-not (Test-Path $ArchivePath)) {
        New-Item -ItemType Directory -Path $ArchivePath | Out-Null
        Write-Host "[OK] Archive-Ordner erstellt: $ArchivePath" -ForegroundColor $Colors.Success
    }

    # 1. Exportiere Requirements ZUERST
    Write-Host ""
    Write-Host "[1/3] Exportiere Requirements..." -ForegroundColor $Colors.Title
    Write-Host ""

    $projects = Get-ChildItem -Path $GitHubSource -Directory

    foreach ($project in $projects) {
        Write-Host "  📁 $($project.Name)..." -ForegroundColor $Colors.Info

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
            Write-Host "     ⚠️  Keine venv - überspringe" -ForegroundColor $Colors.Warning
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
                $oldLocation = Get-Location
                Set-Location $projectPath

                & $activateScript
                pip freeze > $requirementsPath 2>&1 | Out-Null
                deactivate 2>&1 | Out-Null

                Set-Location $oldLocation

                if (Test-Path $requirementsPath) {
                    $packageCount = (Get-Content $requirementsPath | Where-Object { $_ -and $_ -notmatch '^#' }).Count
                    Write-Host "     ✅ Requirements: $packageCount Pakete" -ForegroundColor $Colors.Success
                }
            } catch {
                Write-Host "     ❌ Fehler beim Export" -ForegroundColor $Colors.Error
            }
        }
    }

    # 2. Erstelle temporären Kopie-Ordner (ohne venv)
    Write-Host ""
    Write-Host "[2/3] Erstelle saubere Kopie (ohne venv, Cache, etc.)..." -ForegroundColor $Colors.Title
    Write-Host ""

    $tempCopy = Join-Path $ArchivePath "temp_copy"
    if (Test-Path $tempCopy) {
        Remove-Item -Path $tempCopy -Recurse -Force
    }
    New-Item -ItemType Directory -Path $tempCopy | Out-Null

    foreach ($project in $projects) {
        Write-Host "  📁 $($project.Name)..." -ForegroundColor $Colors.Info

        $source = $project.FullName
        $dest = Join-Path $tempCopy $project.Name

        # Robocopy ohne venv, Cache, Git, Logs
        robocopy $source $dest /MIR /XD venv __pycache__ .git .venv node_modules /XF *.pyc *.pyo *.log /R:1 /W:1 /NJH /NJS /NDL /NC /NS | Out-Null

        if ($LASTEXITCODE -le 7) {
            # Größe berechnen
            $size = (Get-ChildItem -Path $dest -Recurse -File -ErrorAction SilentlyContinue |
                     Measure-Object -Property Length -Sum).Sum / 1MB

            Write-Host "     ✅ Kopiert ($([math]::Round($size, 2)) MB)" -ForegroundColor $Colors.Success
        } else {
            Write-Host "     ⚠️  Warnung" -ForegroundColor $Colors.Warning
        }
    }

    # 3. Erstelle ZIP-Archive
    Write-Host ""
    Write-Host "[3/3] Erstelle ZIP-Archive..." -ForegroundColor $Colors.Title
    Write-Host ""

    $timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm"
    $zipName = "GitHub-Sync_$timestamp.zip"
    $zipPath = Join-Path $ArchivePath $zipName

    Write-Host "  Komprimiere..." -ForegroundColor $Colors.Info

    # Erstelle ZIP
    Compress-Archive -Path "$tempCopy\*" -DestinationPath $zipPath -CompressionLevel Optimal -Force

    # Lösche temp
    Remove-Item -Path $tempCopy -Recurse -Force

    # Größe
    $zipSize = (Get-Item $zipPath).Length / 1MB

    Write-Host ""
    Write-Host "============================================================================" -ForegroundColor $Colors.Title
    Write-Host "  Export abgeschlossen!" -ForegroundColor $Colors.Success
    Write-Host "============================================================================" -ForegroundColor $Colors.Title
    Write-Host ""
    Write-Host "ZIP-Archiv erstellt:" -ForegroundColor $Colors.Success
    Write-Host "  📦 $zipPath" -ForegroundColor $Colors.Info
    Write-Host "  📊 Größe: $([math]::Round($zipSize, 2)) MB" -ForegroundColor $Colors.Info
    Write-Host ""
    Write-Host "Nächste Schritte:" -ForegroundColor $Colors.Title
    Write-Host "  1. Kopiere $zipName auf PC 2" -ForegroundColor $Colors.Info
    Write-Host "     (USB-Stick, Netzwerk, oder: Upload zu Nextcloud MANUELL)" -ForegroundColor $Colors.Info
    Write-Host "  2. Auf PC 2: Entpacke das ZIP" -ForegroundColor $Colors.Info
    Write-Host "  3. Auf PC 2: Führe sync-manager.ps1 Option [5] aus" -ForegroundColor $Colors.Info
    Write-Host ""
    Write-Host "Wichtig:" -ForegroundColor $Colors.Warning
    Write-Host "  - venv wurde NICHT mit-kopiert (absichtlich!)" -ForegroundColor $Colors.Info
    Write-Host "  - requirements.txt ist drin (wichtig!)" -ForegroundColor $Colors.Success
    Write-Host "  - .claude-Ordner ist drin" -ForegroundColor $Colors.Success
    Write-Host ""
}

function Import-Projects {
    Show-Header "Projekte importieren (PC 2)"

    Write-Host "Wähle das ZIP-Archiv zum Importieren:" -ForegroundColor $Colors.Info
    Write-Host ""

    # Suche nach ZIP-Dateien
    $zipFiles = Get-ChildItem -Path $ArchivePath -Filter "GitHub-Sync_*.zip" -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending

    if (-not $zipFiles) {
        Write-Host "❌ Keine ZIP-Archive gefunden in: $ArchivePath" -ForegroundColor $Colors.Error
        Write-Host ""
        Write-Host "Bitte kopiere zuerst das ZIP-Archiv von PC 1 hierher!" -ForegroundColor $Colors.Warning
        return
    }

    # Zeige verfügbare ZIPs
    $i = 1
    foreach ($zip in $zipFiles) {
        $size = $zip.Length / 1MB
        $date = $zip.LastWriteTime
        Write-Host "  [$i] $($zip.Name)" -ForegroundColor $Colors.Info
        Write-Host "      Größe: $([math]::Round($size, 2)) MB | Datum: $date" -ForegroundColor $Colors.Info
        $i++
    }

    Write-Host ""
    $choice = Read-Host "Auswahl (oder 'q' zum Abbrechen)"

    if ($choice -eq 'q') {
        return
    }

    $selectedZip = $zipFiles[$choice - 1]

    if (-not $selectedZip) {
        Write-Host "❌ Ungültige Auswahl!" -ForegroundColor $Colors.Error
        return
    }

    Write-Host ""
    Write-Host "Importiere: $($selectedZip.Name)" -ForegroundColor $Colors.Success
    Write-Host ""

    # Ziel-Ordner
    Write-Host "Wohin entpacken?" -ForegroundColor $Colors.Info
    Write-Host "  [1] C:\Users\$env:USERNAME\Desktop\GitHub" -ForegroundColor $Colors.Info
    Write-Host "  [2] Anderer Pfad" -ForegroundColor $Colors.Info
    Write-Host ""

    $destChoice = Read-Host "Auswahl"

    $destPath = ""
    if ($destChoice -eq "1") {
        $destPath = "C:\Users\$env:USERNAME\Desktop\GitHub"
    } else {
        $destPath = Read-Host "Ziel-Pfad"
    }

    # Erstelle Ziel-Ordner
    if (-not (Test-Path $destPath)) {
        New-Item -ItemType Directory -Path $destPath | Out-Null
    }

    # Entpacke
    Write-Host ""
    Write-Host "Entpacke..." -ForegroundColor $Colors.Info

    Expand-Archive -Path $selectedZip.FullName -DestinationPath $destPath -Force

    Write-Host "✅ Entpackt nach: $destPath" -ForegroundColor $Colors.Success
    Write-Host ""
    Write-Host "Nächster Schritt:" -ForegroundColor $Colors.Title
    Write-Host "  Führe sync-manager.ps1 Option [5] aus um venv zu erstellen" -ForegroundColor $Colors.Info
    Write-Host ""
}

# Main Menu
Show-Header "Manuelle Synchronisation"

Write-Host "Diese Methode verwendet KEIN Nextcloud-Dauerlauf!" -ForegroundColor $Colors.Success
Write-Host "Perfekt wenn dein Nextcloud auf einem Pi läuft." -ForegroundColor $Colors.Success
Write-Host ""
Write-Host "Vorteile:" -ForegroundColor $Colors.Title
Write-Host "  ✅ Keine Nextcloud-Dauerbelastung" -ForegroundColor $Colors.Success
Write-Host "  ✅ DU entscheidest WANN synchronisiert wird" -ForegroundColor $Colors.Success
Write-Host "  ✅ Pi wird nur bei manueller Übertragung belastet" -ForegroundColor $Colors.Success
Write-Host "  ✅ ZIP-Archive sind komprimiert (kleiner)" -ForegroundColor $Colors.Success
Write-Host ""
Write-Host "Was möchtest du tun?" -ForegroundColor $Colors.Title
Write-Host "  [1] Export - Projekte als ZIP exportieren (PC 1)" -ForegroundColor $Colors.Info
Write-Host "  [2] Import - ZIP entpacken (PC 2)" -ForegroundColor $Colors.Info
Write-Host "  [0] Abbrechen" -ForegroundColor $Colors.Warning
Write-Host ""

$choice = Read-Host "Auswahl"

switch ($choice) {
    "1" { Export-Projects }
    "2" { Import-Projects }
    "0" { Write-Host "Abgebrochen" -ForegroundColor $Colors.Info }
    default { Write-Host "Ungültige Auswahl" -ForegroundColor $Colors.Error }
}

Write-Host ""
Write-Host "Drücke eine beliebige Taste..." -ForegroundColor $Colors.Info
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
