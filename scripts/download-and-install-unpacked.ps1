Param(
  [string]$VersionTag = "",
  [string]$Repo = "digi-veda/talent-radar-unpacked-installer"
)

$ErrorActionPreference = "Stop"

function Get-DownloadUrl {
  Param(
    [string]$ReleaseTag,
    [string]$Repository
  )

  $assetName = "talent-radar-unpacked-installer.zip"
  if ($ReleaseTag -and $ReleaseTag.Trim().Length -gt 0) {
    return "https://github.com/$Repository/releases/download/$ReleaseTag/$assetName"
  }
  return "https://github.com/$Repository/releases/latest/download/$assetName"
}

$workDir = Join-Path $env:TEMP ("talent-radar-installer-" + [Guid]::NewGuid().ToString("N"))
$zipPath = Join-Path $workDir "talent-radar-unpacked-installer.zip"
$extractDir = Join-Path $workDir "bundle"
New-Item -Path $workDir -ItemType Directory -Force | Out-Null

$gh = Get-Command gh -ErrorAction SilentlyContinue
if ($gh) {
  Write-Host "Downloading installer via gh release download..." -ForegroundColor Cyan
  if ($VersionTag -and $VersionTag.Trim().Length -gt 0) {
    & gh release download $VersionTag --repo $Repo --pattern "talent-radar-unpacked-installer.zip" --dir $workDir --clobber
  } else {
    & gh release download --repo $Repo --pattern "talent-radar-unpacked-installer.zip" --dir $workDir --clobber
  }
  if ($LASTEXITCODE -ne 0) {
    throw "gh release download failed. Ensure 'gh auth login' has access to $Repo."
  }
} else {
  $downloadUrl = Get-DownloadUrl -ReleaseTag $VersionTag -Repository $Repo
  Write-Host "Downloading installer zip..." -ForegroundColor Cyan
  Write-Host $downloadUrl -ForegroundColor Gray
  Invoke-WebRequest -Uri $downloadUrl -OutFile $zipPath
}

if (-not (Test-Path -LiteralPath $zipPath -PathType Leaf)) {
  throw "Installer zip was not downloaded."
}

Write-Host "Extracting bundle..." -ForegroundColor Cyan
Expand-Archive -Path $zipPath -DestinationPath $extractDir -Force

$installerPath = Join-Path $extractDir "install-unpacked.ps1"
if (-not (Test-Path -LiteralPath $installerPath -PathType Leaf)) {
  throw "install-unpacked.ps1 not found in extracted bundle."
}

Write-Host ""
Write-Host "Launching unpacked install helper..." -ForegroundColor Green
& powershell -ExecutionPolicy Bypass -File $installerPath
