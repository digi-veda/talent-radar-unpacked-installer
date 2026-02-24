# Talent Radar Installer Scripts

## Customer entry script
- `download-and-install-unpacked.ps1`
- `self-install-fixed-path.ps1`
- `upgrade-fixed-path.ps1`

This downloads the latest installer zip from this repo's releases and runs `install-unpacked.ps1`.

Run in PowerShell:

```powershell
powershell -ExecutionPolicy Bypass -File .\download-and-install-unpacked.ps1
```

Pin to a specific release tag:

```powershell
powershell -ExecutionPolicy Bypass -File .\download-and-install-unpacked.ps1 -VersionTag "installer-20260224-034047"
```

Fixed local path install (recommended for non-technical users):

```powershell
powershell -ExecutionPolicy Bypass -Command "irm https://raw.githubusercontent.com/digi-veda/talent-radar-unpacked-installer/main/scripts/self-install-fixed-path.ps1 | iex"
```

Fixed local path upgrade:

```powershell
powershell -ExecutionPolicy Bypass -Command "irm https://raw.githubusercontent.com/digi-veda/talent-radar-unpacked-installer/main/scripts/upgrade-fixed-path.ps1 | iex"
```
