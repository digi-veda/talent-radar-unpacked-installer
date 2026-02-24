Param(
  [string]$ExtensionDir = ""
)

$ErrorActionPreference = "Stop"

function Exit-WithError {
  Param([string]$Message)
  Write-Host ""
  Write-Host "ERROR: $Message" -ForegroundColor Red
  exit 1
}

function Resolve-DefaultExtensionDir {
  if ($ExtensionDir -and $ExtensionDir.Trim().Length -gt 0) {
    return $ExtensionDir
  }
  return (Join-Path $PSScriptRoot "extension")
}

function Open-ChromeExtensionsPage {
  $chromeCandidates = @(
    (Join-Path $Env:ProgramFiles "Google\Chrome\Application\chrome.exe"),
    (Join-Path ${Env:ProgramFiles(x86)} "Google\Chrome\Application\chrome.exe"),
    (Join-Path $Env:LocalAppData "Google\Chrome\Application\chrome.exe")
  ) | Where-Object { $_ -and $_.Trim().Length -gt 0 }

  foreach ($chromePath in $chromeCandidates) {
    if (Test-Path -LiteralPath $chromePath) {
      Start-Process -FilePath $chromePath -ArgumentList "chrome://extensions" | Out-Null
      return $true
    }
  }

  $chromeCommand = Get-Command chrome -ErrorAction SilentlyContinue
  if ($chromeCommand) {
    Start-Process -FilePath $chromeCommand.Source -ArgumentList "chrome://extensions" | Out-Null
    return $true
  }

  try {
    Start-Process "chrome://extensions" | Out-Null
    return $true
  } catch {
    return $false
  }
}

$resolvedExtensionDir = Resolve-DefaultExtensionDir
$manifestPath = Join-Path $resolvedExtensionDir "manifest.json"

if (-not (Test-Path -LiteralPath $resolvedExtensionDir -PathType Container)) {
  Exit-WithError "Extension folder not found: $resolvedExtensionDir"
}
if (-not (Test-Path -LiteralPath $manifestPath -PathType Leaf)) {
  Exit-WithError "manifest.json not found in extension folder: $resolvedExtensionDir"
}

try {
  $resolvedExtensionDir = (Resolve-Path -LiteralPath $resolvedExtensionDir).Path
} catch {
  Exit-WithError "Cannot resolve extension folder path: $resolvedExtensionDir"
}

Write-Host ""
Write-Host "Talent Radar - Unpacked Install Helper" -ForegroundColor Cyan
Write-Host "Extension folder: $resolvedExtensionDir" -ForegroundColor Gray
Write-Host ""

$opened = Open-ChromeExtensionsPage
if ($opened) {
  Write-Host "Opened chrome://extensions in Chrome." -ForegroundColor Green
} else {
  Write-Host "Could not open Chrome automatically." -ForegroundColor Yellow
  Write-Host "Please open Chrome and go to: chrome://extensions"
}

Write-Host ""
Write-Host "Complete these steps in Chrome:" -ForegroundColor Cyan
Write-Host "1. Enable Developer mode (top-right toggle)." -ForegroundColor White
Write-Host "2. Click Load unpacked." -ForegroundColor White
Write-Host "3. Select this folder:" -ForegroundColor White
Write-Host "   $resolvedExtensionDir" -ForegroundColor Yellow
Write-Host ""

$confirmation = Read-Host "Type 'done' after extension is loaded"
if ($confirmation -ne "done") {
  Write-Host "Installer finished. Re-run this script if needed." -ForegroundColor Yellow
  exit 0
}

Write-Host ""
Write-Host "Install flow completed." -ForegroundColor Green
Write-Host "If extension is not visible, click Refresh on chrome://extensions and retry Load unpacked." -ForegroundColor Gray
