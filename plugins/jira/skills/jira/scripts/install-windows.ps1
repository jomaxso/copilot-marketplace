<#
.SYNOPSIS
    Installs the Atlassian CLI (acli) globally on Windows.

.DESCRIPTION
    Downloads the latest acli binary from Atlassian and adds it to the user PATH.
    No admin rights or Java required.

.EXAMPLE
    .\install.ps1
    .\install.ps1 -InstallDir "$HOME\tools\acli"
#>

param(
    [string]$InstallDir = "C:\tools\acli"
)

$ErrorActionPreference = "Stop"

# Detect architecture
$arch = $env:PROCESSOR_ARCHITECTURE
switch ($arch) {
    "AMD64" { $downloadUrl = "https://acli.atlassian.com/windows/latest/acli_windows_amd64/acli.exe" }
    "ARM64" { $downloadUrl = "https://acli.atlassian.com/windows/latest/acli_windows_arm64/acli.exe" }
    default {
        Write-Error "Unsupported architecture: $arch. Only AMD64 and ARM64 are supported."
        exit 1
    }
}

Write-Host "=== Atlassian CLI (acli) Installer ===" -ForegroundColor Cyan
Write-Host "Architecture : $arch"
Write-Host "Install path : $InstallDir"
Write-Host ""

# Step 1: Create install directory
if (!(Test-Path $InstallDir)) {
    Write-Host "[1/4] Creating directory $InstallDir ..." -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $InstallDir -Force | Out-Null
} else {
    Write-Host "[1/4] Directory $InstallDir already exists." -ForegroundColor Green
}

# Step 2: Download binary
$exePath = Join-Path $InstallDir "acli.exe"
Write-Host "[2/4] Downloading acli.exe ..." -ForegroundColor Yellow
Invoke-WebRequest -Uri $downloadUrl -OutFile $exePath -UseBasicParsing
$sizeMB = [math]::Round((Get-Item $exePath).Length / 1MB, 1)
Write-Host "      Downloaded $sizeMB MB" -ForegroundColor Green

# Step 3: Add to user PATH
$currentPath = [Environment]::GetEnvironmentVariable("PATH", "User")
if ($currentPath -notlike "*$InstallDir*") {
    Write-Host "[3/4] Adding $InstallDir to user PATH ..." -ForegroundColor Yellow
    [Environment]::SetEnvironmentVariable("PATH", "$currentPath;$InstallDir", "User")
    $env:PATH += ";$InstallDir"
    Write-Host "      PATH updated." -ForegroundColor Green
} else {
    Write-Host "[3/4] $InstallDir is already in PATH." -ForegroundColor Green
}

# Step 4: Verify
Write-Host "[4/4] Verifying installation ..." -ForegroundColor Yellow
$version = & $exePath --version 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "=== Installation successful! ===" -ForegroundColor Green
    Write-Host "  $version"
    Write-Host ""
    Write-Host "Open a NEW terminal, then run:" -ForegroundColor Cyan
    Write-Host "  acli --help"
    Write-Host "  acli auth login --web"
} else {
    Write-Error "Verification failed. Check the download and try again."
    exit 1
}
