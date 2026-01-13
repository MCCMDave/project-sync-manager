# ============================================================================
# DB-Backup v1.1 - Einfach und effektiv
# Sichert Datenbanken vom Pi nach Nextcloud
# ============================================================================

$BackupDir = "C:\Users\david\Desktop\nextcloud\GitHub\backups"
$Timestamp = Get-Date -Format "yyyy-MM-dd"

# Datenbanken auf dem Pi
$Databases = @(
    @{ Name = "kitchen"; Path = "/home/dave/khai/database/kitchenhelper.db" },
    @{ Name = "karten";  Path = "/home/dave/lernkarten-api-new/data/cards.db" }
)

Write-Host ""
Write-Host "=== DB-Backup (Pi -> Nextcloud) ===" -ForegroundColor Cyan
Write-Host ""

# Backup-Ordner erstellen
if (-not (Test-Path $BackupDir)) {
    New-Item -ItemType Directory -Path $BackupDir -Force | Out-Null
}

foreach ($db in $Databases) {
    $localDir = Join-Path $BackupDir $db.Name
    $localFile = Join-Path $localDir "$($db.Name)_$Timestamp.db"
    $latestFile = Join-Path $localDir "$($db.Name)_latest.db"

    # Ordner erstellen
    if (-not (Test-Path $localDir)) {
        New-Item -ItemType Directory -Path $localDir -Force | Out-Null
    }

    Write-Host "[$($db.Name)]" -ForegroundColor Yellow

    # Kopieren via SCP
    scp "pi:$($db.Path)" $localFile 2>$null

    if (Test-Path $localFile) {
        $size = [math]::Round((Get-Item $localFile).Length / 1KB, 1)
        Copy-Item $localFile $latestFile -Force
        Write-Host "  OK: ${size} KB -> $($db.Name)_$Timestamp.db" -ForegroundColor Green
    } else {
        Write-Host "  FEHLER: Konnte nicht kopieren" -ForegroundColor Red
    }
}

# Alte Backups loeschen (aelter als 30 Tage)
$cutoff = (Get-Date).AddDays(-30)
Get-ChildItem -Path $BackupDir -Recurse -Filter "*.db" |
    Where-Object { $_.Name -notlike "*_latest.db" -and $_.LastWriteTime -lt $cutoff } |
    ForEach-Object { Remove-Item $_.FullName -Force; Write-Host "Geloescht: $($_.Name)" -ForegroundColor Gray }

Write-Host ""
Write-Host "Fertig! Backups in: $BackupDir" -ForegroundColor Cyan
Write-Host ""
