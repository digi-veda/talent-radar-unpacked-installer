# Talent Radar Installer Scripts

## Customer entry script
- `self-install-fixed-path.ps1`
- `upgrade-fixed-path.ps1`

Fixed local path install (recommended for non-technical users):

```powershell
powershell -ExecutionPolicy Bypass -Command "irm https://raw.githubusercontent.com/digi-veda/talent-radar-unpacked-installer/main/scripts/self-install-fixed-path.ps1 | iex"
```

Fixed local path upgrade:

```powershell
powershell -ExecutionPolicy Bypass -Command "irm https://raw.githubusercontent.com/digi-veda/talent-radar-unpacked-installer/main/scripts/upgrade-fixed-path.ps1 | iex"
```
