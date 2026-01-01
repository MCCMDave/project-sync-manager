# Project Sync Manager

Einfache Backup- und Sync-Tools fuer GitHub-Projekte.

## Scripts

### `backup-databases.ps1`
Sichert Datenbanken vom Raspberry Pi nach Nextcloud.

```powershell
.\backup-databases.ps1
```

**Ausgabe:**
```
=== DB-Backup (Pi -> Nextcloud) ===

[kitchen]
  OK: 628 KB -> kitchen_2026-01-01.db
[karten]
  OK: 188 KB -> karten_2026-01-01.db

Fertig! Backups in: nextcloud\GitHub\backups\
```

**Features:**
- SSH-basiert (scp)
- Tages-Rotation (30 Tage)
- `*_latest.db` immer aktuell

---

### `smart-sync.ps1`
Synchronisiert Code-Dateien nach Nextcloud (ohne venv, cache, etc.).

```powershell
.\smart-sync.ps1
```

**Ausgabe:**
```
=== Smart-Sync (GitHub -> Nextcloud) ===

[kitchenhelper-ai]
  OK: 3 Dateien aktualisiert
[lernkarten-api]
  OK: Keine Aenderungen
...
```

**Ausgeschlossen:**
- `venv`, `.venv`, `node_modules`
- `__pycache__`, `*.pyc`
- `.git`, `*.log`, `*.db`
- `.env` (Secrets!)

---

## Voraussetzungen

- Windows PowerShell 5.1+
- SSH-Zugang zum Pi (`ssh pi` muss funktionieren)
- Nextcloud-Ordner unter `C:\Users\david\Desktop\nextcloud`

## Lizenz

Apache 2.0
