# Talent Radar Installer Scripts

## Customer entry script
- `download-and-install-unpacked.ps1`

This downloads the latest installer zip from this repo's releases and runs `install-unpacked.ps1`.

Run in PowerShell:

```powershell
powershell -ExecutionPolicy Bypass -File .\download-and-install-unpacked.ps1
```

Pin to a specific release tag:

```powershell
powershell -ExecutionPolicy Bypass -File .\download-and-install-unpacked.ps1 -VersionTag "installer-20260224-032539"
```
