# Erstellt eine Verknüpfung zum Sync Manager

$WshShell = New-Object -ComObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("$PSScriptRoot\⚡ Sync Manager.lnk")
$Shortcut.TargetPath = "powershell.exe"
$Shortcut.Arguments = '-NoExit -ExecutionPolicy Bypass -File "' + "$PSScriptRoot\sync-manager.ps1" + '"'
$Shortcut.WorkingDirectory = $PSScriptRoot
$Shortcut.IconLocation = "imageres.dll,1"
$Shortcut.Description = "GitHub Sync Manager - Interaktives Menü"
$Shortcut.Save()

Write-Host "✅ Verknüpfung erstellt!" -ForegroundColor Green
