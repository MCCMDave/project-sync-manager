# ============================================================================
# Create Shortcut for Sync Manager
# Erstellt eine Verknüpfung zum Sync Manager
# ============================================================================

# Language Selection / Sprachauswahl
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

# Text translations
$Texts = @{
    DE = @{
        Creating = "Erstelle Verknüpfung..."
        Success = "✅ Verknüpfung erstellt!"
        Description = "GitHub Sync Manager - Interaktives Menü"
    }
    EN = @{
        Creating = "Creating shortcut..."
        Success = "✅ Shortcut created!"
        Description = "GitHub Sync Manager - Interactive Menu"
    }
}

Write-Host ""
Write-Host $Texts[$Lang].Creating -ForegroundColor Cyan

$WshShell = New-Object -ComObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("$PSScriptRoot\⚡ Sync Manager.lnk")
$Shortcut.TargetPath = "powershell.exe"
$Shortcut.Arguments = '-NoExit -ExecutionPolicy Bypass -File "' + "$PSScriptRoot\sync-manager.ps1" + '"'
$Shortcut.WorkingDirectory = $PSScriptRoot
$Shortcut.IconLocation = "imageres.dll,1"
$Shortcut.Description = $Texts[$Lang].Description
$Shortcut.Save()

Write-Host $Texts[$Lang].Success -ForegroundColor Green
Write-Host ""
