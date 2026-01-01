# ============================================================================
# Smart-Sync v1.1 - Einfach und effektiv
# Synchronisiert Code-Dateien nach Nextcloud (ohne venv, cache, etc.)
# ============================================================================

$Source = "C:\Users\david\Desktop\GitHub"
$Dest = "C:\Users\david\Desktop\nextcloud\GitHub"

# Ausschluesse (werden NICHT kopiert)
$Excludes = @("venv", ".venv", "__pycache__", "node_modules", ".git", "*.log", "*.db", ".env")

Write-Host ""
Write-Host "=== Smart-Sync (GitHub -> Nextcloud) ===" -ForegroundColor Cyan
Write-Host ""

# Projekte finden
$projects = Get-ChildItem -Path $Source -Directory | Where-Object { $_.Name -notlike ".*" }

foreach ($project in $projects) {
    $srcPath = $project.FullName
    $dstPath = Join-Path $Dest $project.Name

    Write-Host "[$($project.Name)]" -ForegroundColor Yellow

    # Robocopy mit Excludes (MIR = Mirror, nur geaenderte Dateien)
    $excludeDirs = $Excludes | Where-Object { $_ -notlike "*.*" }
    $excludeFiles = $Excludes | Where-Object { $_ -like "*.*" }

    $args = @($srcPath, $dstPath, "/MIR", "/XD") + $excludeDirs + @("/XF") + $excludeFiles + @("/R:1", "/W:1", "/NJH", "/NJS", "/NDL", "/NC", "/NS", "/NP")

    $output = & robocopy @args 2>&1
    $exitCode = $LASTEXITCODE

    if ($exitCode -le 7) {
        # Zaehle kopierte Dateien
        $copied = ($output | Select-String "^\s+Newer" | Measure-Object).Count +
                  ($output | Select-String "^\s+New File" | Measure-Object).Count

        if ($copied -gt 0) {
            Write-Host "  OK: $copied Dateien aktualisiert" -ForegroundColor Green
        } else {
            Write-Host "  OK: Keine Aenderungen" -ForegroundColor Gray
        }
    } else {
        Write-Host "  WARNUNG: Exit Code $exitCode" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "Fertig! Sync nach: $Dest" -ForegroundColor Cyan
Write-Host ""
