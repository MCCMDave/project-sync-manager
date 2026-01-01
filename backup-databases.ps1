# ============================================================================
# Database Backup Script v1.0
# Sichert Datenbanken von Pi nach Nextcloud
# ============================================================================

param(
    [string]$PiHost = "pi",
    [string]$NextcloudPath = "C:\Users\david\Desktop\nextcloud",
    [switch]$DryRun
)

$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# Konfiguration
$BackupFolder = Join-Path $NextcloudPath "GitHub\backups"
$Timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm"

# Projekte und deren DB-Pfade auf dem Pi
$Projects = @(
    @{
        Name = "kitchenhelper-ai"
        RemotePath = "~/kitchenhelper-ai/database/kitchenhelper.db"
        LocalName = "kitchen"
    },
    @{
        Name = "lernkarten-api"
        RemotePath = "~/lernkarten-api/data/cards.db"
        LocalName = "karten"
    }
)

# Farben
$Colors = @{
    Title = "Cyan"
    Success = "Green"
    Warning = "Yellow"
    Error = "Red"
    Info = "White"
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

function Test-SshConnection {
    Write-Host "Pruefe SSH-Verbindung zu $PiHost..." -ForegroundColor $Colors.Info

    $result = ssh $PiHost "echo 'OK'" 2>&1

    if ($result -eq "OK") {
        Write-Host "  [OK] Verbindung erfolgreich" -ForegroundColor $Colors.Success
        return $true
    } else {
        Write-Host "  [FEHLER] Keine Verbindung: $result" -ForegroundColor $Colors.Error
        return $false
    }
}

function Backup-Database {
    param(
        [string]$ProjectName,
        [string]$RemotePath,
        [string]$LocalName
    )

    Write-Host ""
    Write-Host "[$ProjectName]" -ForegroundColor $Colors.Title

    # Pruefe ob DB existiert
    $exists = ssh $PiHost "test -f $RemotePath && echo 'YES' || echo 'NO'" 2>&1

    if ($exists -ne "YES") {
        Write-Host "  [WARNUNG] Datenbank nicht gefunden: $RemotePath" -ForegroundColor $Colors.Warning
        return $false
    }

    # DB-Groesse holen
    $size = ssh $PiHost "du -h $RemotePath | cut -f1" 2>&1
    Write-Host "  Groesse: $size" -ForegroundColor $Colors.Info

    # Backup-Pfad
    $backupDir = Join-Path $BackupFolder $LocalName
    $backupFile = Join-Path $backupDir "${LocalName}_${Timestamp}.db"
    $latestLink = Join-Path $backupDir "${LocalName}_latest.db"

    # Erstelle Ordner
    if (-not (Test-Path $backupDir)) {
        New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
        Write-Host "  Ordner erstellt: $backupDir" -ForegroundColor $Colors.Info
    }

    if ($DryRun) {
        Write-Host "  [DRY-RUN] Wuerde kopieren: $RemotePath -> $backupFile" -ForegroundColor $Colors.Warning
        return $true
    }

    # Kopiere Datenbank
    Write-Host "  Kopiere..." -ForegroundColor $Colors.Info
    scp "${PiHost}:${RemotePath}" $backupFile 2>&1 | Out-Null

    if (Test-Path $backupFile) {
        $localSize = (Get-Item $backupFile).Length / 1MB
        Write-Host "  [OK] Gesichert: $([math]::Round($localSize, 2)) MB" -ForegroundColor $Colors.Success

        # Kopiere als "latest"
        Copy-Item $backupFile $latestLink -Force
        Write-Host "  [OK] Latest-Link aktualisiert" -ForegroundColor $Colors.Success

        return $true
    } else {
        Write-Host "  [FEHLER] Backup fehlgeschlagen" -ForegroundColor $Colors.Error
        return $false
    }
}

function Remove-OldBackups {
    param(
        [string]$LocalName,
        [int]$KeepDays = 30
    )

    $backupDir = Join-Path $BackupFolder $LocalName

    if (-not (Test-Path $backupDir)) {
        return
    }

    $cutoff = (Get-Date).AddDays(-$KeepDays)
    $oldFiles = Get-ChildItem -Path $backupDir -Filter "*.db" |
                Where-Object { $_.Name -notlike "*_latest.db" -and $_.LastWriteTime -lt $cutoff }

    if ($oldFiles.Count -gt 0) {
        Write-Host ""
        Write-Host "Loesche alte Backups (aelter als $KeepDays Tage):" -ForegroundColor $Colors.Warning
        foreach ($file in $oldFiles) {
            Remove-Item $file.FullName -Force
            Write-Host "  Geloescht: $($file.Name)" -ForegroundColor $Colors.Info
        }
    }
}

function Show-BackupStatus {
    Write-Host ""
    Write-Host "[BACKUP-STATUS]" -ForegroundColor $Colors.Title
    Write-Host ""

    foreach ($project in $Projects) {
        $backupDir = Join-Path $BackupFolder $project.LocalName

        if (Test-Path $backupDir) {
            $files = Get-ChildItem -Path $backupDir -Filter "*.db" |
                     Where-Object { $_.Name -notlike "*_latest.db" } |
                     Sort-Object LastWriteTime -Descending

            $totalSize = ($files | Measure-Object -Property Length -Sum).Sum / 1MB

            Write-Host "  $($project.Name):" -ForegroundColor $Colors.Title
            Write-Host "    Backups: $($files.Count)" -ForegroundColor $Colors.Info
            Write-Host "    Gesamt: $([math]::Round($totalSize, 2)) MB" -ForegroundColor $Colors.Info

            if ($files.Count -gt 0) {
                $latest = $files[0]
                Write-Host "    Letztes: $($latest.Name) ($($latest.LastWriteTime.ToString('dd.MM.yyyy HH:mm')))" -ForegroundColor $Colors.Success
            }
        } else {
            Write-Host "  $($project.Name): Keine Backups" -ForegroundColor $Colors.Warning
        }
        Write-Host ""
    }
}

# ============================================================================
# HAUPTMENUE
# ============================================================================

Show-Header "Datenbank-Backup (Pi -> Nextcloud)"

Write-Host "Backup-Ziel: $BackupFolder" -ForegroundColor $Colors.Info
Write-Host ""
Write-Host "Was moechtest du tun?" -ForegroundColor $Colors.Title
Write-Host ""
Write-Host "  [1] Backup JETZT erstellen" -ForegroundColor $Colors.Info
Write-Host "  [2] Backup-Status anzeigen" -ForegroundColor $Colors.Info
Write-Host "  [3] Alte Backups loeschen (>30 Tage)" -ForegroundColor $Colors.Info
Write-Host "  [4] Dry-Run (nur simulieren)" -ForegroundColor $Colors.Info
Write-Host "  [0] Beenden" -ForegroundColor $Colors.Warning
Write-Host ""

$choice = Read-Host "Auswahl"

switch ($choice) {
    "1" {
        Show-Header "Backup erstellen"

        if (-not (Test-SshConnection)) {
            Write-Host ""
            Write-Host "Tipp: Stelle sicher dass SSH-Key eingerichtet ist!" -ForegroundColor $Colors.Warning
            Write-Host "      ssh-copy-id $PiHost" -ForegroundColor $Colors.Info
            break
        }

        $successCount = 0
        foreach ($project in $Projects) {
            $result = Backup-Database -ProjectName $project.Name -RemotePath $project.RemotePath -LocalName $project.LocalName
            if ($result) { $successCount++ }
        }

        Write-Host ""
        Write-Host "============================================================================" -ForegroundColor $Colors.Title
        Write-Host "  $successCount von $($Projects.Count) Datenbanken gesichert" -ForegroundColor $Colors.Success
        Write-Host "============================================================================" -ForegroundColor $Colors.Title
    }
    "2" {
        Show-Header "Backup-Status"
        Show-BackupStatus
    }
    "3" {
        Show-Header "Alte Backups loeschen"

        foreach ($project in $Projects) {
            Remove-OldBackups -LocalName $project.LocalName -KeepDays 30
        }

        Write-Host ""
        Write-Host "[OK] Bereinigung abgeschlossen" -ForegroundColor $Colors.Success
    }
    "4" {
        Show-Header "Dry-Run (Simulation)"

        if (-not (Test-SshConnection)) {
            break
        }

        foreach ($project in $Projects) {
            Backup-Database -ProjectName $project.Name -RemotePath $project.RemotePath -LocalName $project.LocalName
        }
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
