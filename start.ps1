# ============================================================================
# Project Sync Manager - Hauptmenue v2.1
# Kombiniert alle Sync- und Backup-Tools
# ============================================================================

$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

$Colors = @{
    Title = "Cyan"
    Success = "Green"
    Warning = "Yellow"
    Error = "Red"
    Info = "White"
    Highlight = "Magenta"
}

function Show-MainMenu {
    Clear-Host
    Write-Host ""
    Write-Host "============================================================================" -ForegroundColor $Colors.Title
    Write-Host "  PROJECT SYNC MANAGER v2.1" -ForegroundColor $Colors.Title
    Write-Host "============================================================================" -ForegroundColor $Colors.Title
    Write-Host ""
    Write-Host "  [SYNC]" -ForegroundColor $Colors.Highlight
    Write-Host "  [1] Smart Sync     - Nur geaenderte Dateien syncen" -ForegroundColor $Colors.Info
    Write-Host "  [2] Manual Sync    - ZIP-Export fuer USB/manuellen Transfer" -ForegroundColor $Colors.Info
    Write-Host "  [3] Full Sync      - Komplett-Sync zu Nextcloud (alter Modus)" -ForegroundColor $Colors.Info
    Write-Host ""
    Write-Host "  [BACKUP]" -ForegroundColor $Colors.Highlight
    Write-Host "  [4] DB Backup      - Datenbanken vom Pi sichern" -ForegroundColor $Colors.Info
    Write-Host ""
    Write-Host "  [TOOLS]" -ForegroundColor $Colors.Highlight
    Write-Host "  [5] System Info    - System-Informationen anzeigen" -ForegroundColor $Colors.Info
    Write-Host "  [6] Sync Status    - Status aller Projekte pruefen" -ForegroundColor $Colors.Info
    Write-Host "  [7] Create venv    - Virtual Environments erstellen" -ForegroundColor $Colors.Info
    Write-Host ""
    Write-Host "  [0] Beenden" -ForegroundColor $Colors.Error
    Write-Host ""
    Write-Host "============================================================================" -ForegroundColor $Colors.Title
    Write-Host ""
    Write-Host "Welches Tool? " -NoNewline -ForegroundColor $Colors.Highlight
}

# Hauptschleife
do {
    Show-MainMenu

    $key = [Console]::ReadKey($true)
    $choice = $key.KeyChar.ToString()

    switch ($choice) {
        "1" {
            & "$ScriptDir\smart-sync.ps1"
        }
        "2" {
            & "$ScriptDir\manual-sync.ps1"
        }
        "3" {
            & "$ScriptDir\sync-manager.ps1"
        }
        "4" {
            & "$ScriptDir\backup-databases.ps1"
        }
        "5" {
            # System Info aus sync-manager.ps1 aufrufen
            & "$ScriptDir\sync-manager.ps1"
            # Der User kann dort Option 1 waehlen
        }
        "6" {
            & "$ScriptDir\sync-manager.ps1"
            # Der User kann dort Option 2 waehlen
        }
        "7" {
            & "$ScriptDir\sync-manager.ps1"
            # Der User kann dort Option 5 waehlen
        }
        "0" {
            Write-Host ""
            Write-Host "Auf Wiedersehen!" -ForegroundColor $Colors.Success
            exit
        }
        default {
            Write-Host ""
            Write-Host "Ungueltige Auswahl!" -ForegroundColor $Colors.Error
            Start-Sleep -Seconds 1
        }
    }

} while ($true)
