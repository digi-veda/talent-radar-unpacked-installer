Param(
  [string]$Repo = "digi-veda/talent-radar-unpacked-installer",
  [string]$VersionTag = "",
  [string]$InstallRoot = ""
)

$ErrorActionPreference = "Stop"

function Resolve-InstallRoot {
  if ($InstallRoot -and $InstallRoot.Trim().Length -gt 0) {
    return $InstallRoot
  }
  return (Join-Path $env:LOCALAPPDATA "TalentRadarExtension")
}

function Get-DownloadUrl {
  Param(
    [string]$Repository,
    [string]$ReleaseTag
  )
  $assetName = "talent-radar-unpacked-installer.zip"
  if ($ReleaseTag -and $ReleaseTag.Trim().Length -gt 0) {
    return "https://github.com/$Repository/releases/download/$ReleaseTag/$assetName"
  }
  return "https://github.com/$Repository/releases/latest/download/$assetName"
}

function Download-Zip {
  Param(
    [string]$Repository,
    [string]$ReleaseTag,
    [string]$ZipPath
  )

  $gh = Get-Command gh -ErrorAction SilentlyContinue
  if ($gh) {
    $downloadDir = Split-Path -Parent $ZipPath
    if ($ReleaseTag -and $ReleaseTag.Trim().Length -gt 0) {
      & gh release download $ReleaseTag --repo $Repository --pattern "talent-radar-unpacked-installer.zip" --dir $downloadDir --clobber
    } else {
      & gh release download --repo $Repository --pattern "talent-radar-unpacked-installer.zip" --dir $downloadDir --clobber
    }
    if ($LASTEXITCODE -ne 0) {
      throw "gh release download failed."
    }
    return
  }

  $url = Get-DownloadUrl -Repository $Repository -ReleaseTag $ReleaseTag
  Invoke-WebRequest -Uri $url -OutFile $ZipPath
}

function Open-ChromeExtensions {
  $chromeCandidates = @(
    (Join-Path $Env:ProgramFiles "Google\Chrome\Application\chrome.exe"),
    (Join-Path ${Env:ProgramFiles(x86)} "Google\Chrome\Application\chrome.exe"),
    (Join-Path $Env:LocalAppData "Google\Chrome\Application\chrome.exe")
  ) | Where-Object { $_ -and $_.Trim().Length -gt 0 }

  foreach ($chromePath in $chromeCandidates) {
    if (Test-Path -LiteralPath $chromePath) {
      Start-Process -FilePath $chromePath -ArgumentList "chrome://extensions" | Out-Null
      return
    }
  }

  $chromeCommand = Get-Command chrome -ErrorAction SilentlyContinue
  if ($chromeCommand) {
    Start-Process -FilePath $chromeCommand.Source -ArgumentList "chrome://extensions" | Out-Null
    return
  }

  try {
    Start-Process "googlechrome://extensions/" | Out-Null
    return
  } catch {
    # fall through to manual instructions
  }

  Write-Host "Could not find Google Chrome automatically." -ForegroundColor Yellow
  Write-Host "Please open Chrome and go to: chrome://extensions" -ForegroundColor Yellow
}

$targetRoot = Resolve-InstallRoot
$targetExtensionDir = Join-Path $targetRoot "extension"
$workDir = Join-Path $env:TEMP ("talent-radar-self-install-" + [Guid]::NewGuid().ToString("N"))
$zipPath = Join-Path $workDir "talent-radar-unpacked-installer.zip"
$extractDir = Join-Path $workDir "bundle"

New-Item -Path $workDir -ItemType Directory -Force | Out-Null
New-Item -Path $targetRoot -ItemType Directory -Force | Out-Null

Write-Host "Downloading latest installer..." -ForegroundColor Cyan
Download-Zip -Repository $Repo -ReleaseTag $VersionTag -ZipPath $zipPath

Write-Host "Extracting installer..." -ForegroundColor Cyan
Expand-Archive -Path $zipPath -DestinationPath $extractDir -Force

$sourceExtensionDir = Join-Path $extractDir "extension"
$sourceManifest = Join-Path $sourceExtensionDir "manifest.json"
if (-not (Test-Path -LiteralPath $sourceManifest -PathType Leaf)) {
  throw "Downloaded package is invalid (extension/manifest.json missing)."
}

Write-Host "Updating local extension folder..." -ForegroundColor Cyan
if (Test-Path -LiteralPath $targetExtensionDir) {
  Remove-Item -LiteralPath $targetExtensionDir -Recurse -Force
}
Copy-Item -Path $sourceExtensionDir -Destination $targetExtensionDir -Recurse -Force

try {
  $resolvedTarget = (Resolve-Path -LiteralPath $targetExtensionDir).Path
} catch {
  $resolvedTarget = $targetExtensionDir
}

Write-Host ""
Write-Host "Install files ready at:" -ForegroundColor Green
Write-Host $resolvedTarget -ForegroundColor Yellow
Write-Host ""

Open-ChromeExtensions
Write-Host "Chrome Extensions page should now be open." -ForegroundColor Gray
Write-Host "In Chrome:" -ForegroundColor Cyan
Write-Host "1. Enable Developer mode" -ForegroundColor White
Write-Host "2. Click Load unpacked" -ForegroundColor White
Write-Host "3. Select this folder:" -ForegroundColor White
Write-Host "   $resolvedTarget" -ForegroundColor Yellow
