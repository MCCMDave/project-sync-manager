# Erstellt Windows Scheduled Tasks fuer automatische Backups
# Ausfuehren als Administrator!

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

Write-Host "=== Scheduled Task Setup ===" -ForegroundColor Cyan
Write-Host ""

# Task 1: Taeglich um 03:00 Uhr - DB Backup
$Action1 = New-ScheduledTaskAction -Execute "powershell.exe" `
    -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$ScriptDir\backup-databases.ps1`"" `
    -WorkingDirectory $ScriptDir

$Trigger1 = New-ScheduledTaskTrigger -Daily -At "03:00"

$Settings = New-ScheduledTaskSettingsSet `
    -AllowStartIfOnBatteries `
    -DontStopIfGoingOnBatteries `
    -StartWhenAvailable `
    -RunOnlyIfNetworkAvailable

Register-ScheduledTask -TaskName "MelucioLabs-DB-Backup" `
    -Action $Action1 `
    -Trigger $Trigger1 `
    -Settings $Settings `
    -Description "Taegliches DB-Backup von Pi nach Nextcloud" `
    -Force

Write-Host "[OK] DB-Backup Task erstellt (taeglich 03:00)" -ForegroundColor Green

# Task 2: Alle 3 Tage um 04:00 Uhr - Code Sync
$Action2 = New-ScheduledTaskAction -Execute "powershell.exe" `
    -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$ScriptDir\smart-sync.ps1`"" `
    -WorkingDirectory $ScriptDir

# Alle 3 Tage
$Trigger2 = New-ScheduledTaskTrigger -Daily -DaysInterval 3 -At "04:00"

Register-ScheduledTask -TaskName "MelucioLabs-Code-Sync" `
    -Action $Action2 `
    -Trigger $Trigger2 `
    -Settings $Settings `
    -Description "Code-Sync nach Nextcloud (alle 3 Tage)" `
    -Force

Write-Host "[OK] Code-Sync Task erstellt (alle 3 Tage 04:00)" -ForegroundColor Green

Write-Host ""
Write-Host "Tasks erstellt! Pruefen mit:" -ForegroundColor Yellow
Write-Host "  Get-ScheduledTask -TaskName 'MelucioLabs*'"
Write-Host ""
Write-Host "Manuell ausfuehren:" -ForegroundColor Yellow
Write-Host "  Start-ScheduledTask -TaskName 'MelucioLabs-DB-Backup'"
Write-Host ""
