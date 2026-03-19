<#
.SYNOPSIS
    Installs the MariaDB client tools on Windows.

.DESCRIPTION
    Installs the MariaDB client package (mariadb.exe, mariadb-dump.exe,
    mariadb-admin.exe) via winget (Windows Package Manager) or, as a fallback,
    by downloading the MSI installer from the official MariaDB download page.

    A credentials template file (my.ini) is written to %APPDATA%\MariaDB\
    so you can store connection defaults without embedding passwords in scripts.

.EXAMPLE
    .\install-windows.ps1
    .\install-windows.ps1 -Method MSI -MariaDBVersion "11.4"
#>

param(
    [ValidateSet("winget", "MSI", "auto")]
    [string]$Method = "auto",

    # Full version string used for the MSI download URL (e.g. "11.4.5").
    # Only used when Method is "MSI". Run without arguments to use winget (recommended).
    [string]$MariaDBVersion = ""
)

$ErrorActionPreference = "Stop"

Write-Host "=== MariaDB Client Tools Installer — Windows ===" -ForegroundColor Cyan
Write-Host ""

# ── Step 1: Choose install method ─────────────────────────────────────────
Write-Host "[1/4] Selecting install method ..." -ForegroundColor Yellow

function Test-WingetAvailable {
    try {
        $null = winget --version 2>&1
        return $true
    } catch {
        return $false
    }
}

$useWinget = $false

switch ($Method) {
    "winget" { $useWinget = $true }
    "MSI"    { $useWinget = $false }
    "auto"   { $useWinget = Test-WingetAvailable }
}

if ($useWinget) {
    Write-Host "      Method: winget (Windows Package Manager)" -ForegroundColor Green
} else {
    Write-Host "      Method: MSI download from mariadb.org" -ForegroundColor Green
}

# ── Step 2: Install ────────────────────────────────────────────────────────
Write-Host "[2/4] Installing MariaDB client tools ..." -ForegroundColor Yellow

if ($useWinget) {
    # winget installs the full MariaDB server package (which includes the client tools).
    # The package ID for the community edition is MariaDB.Server.
    # NOTE: No client-only winget package exists; we install the server package and warn the user.
    Write-Host "      Running: winget install --id MariaDB.Server --accept-package-agreements --accept-source-agreements" -ForegroundColor Cyan
    Write-Host "      ⚠ winget installs the full server package (includes client tools). Consider -Method MSI for client-only install." -ForegroundColor Yellow

    $existingInstall = winget list --id MariaDB.Server 2>&1 | Select-String "MariaDB"
    if ($existingInstall) {
        Write-Host "      MariaDB is already installed. Checking for upgrades ..." -ForegroundColor Green
        winget upgrade --id MariaDB.Server --accept-package-agreements --accept-source-agreements
    } else {
        winget install --id MariaDB.Server --accept-package-agreements --accept-source-agreements
    }

    # Refresh PATH in current session
    $env:PATH = [System.Environment]::GetEnvironmentVariable("PATH", "Machine") + ";" +
                [System.Environment]::GetEnvironmentVariable("PATH", "User")

} else {
    # MSI download fallback
    $arch = $env:PROCESSOR_ARCHITECTURE
    # Map Windows arch to MariaDB package suffix (used in both folder name and filename)
    $msiArch = switch ($arch) {
        "AMD64" { "winx64" }
        "ARM64" { "winarm64" }
        default {
            Write-Warning "Unknown architecture '$arch' — defaulting to winx64."
            "winx64"
        }
    }

    # Resolve the full version string (e.g. "11.4.5")
    if (-not $MariaDBVersion) {
        Write-Host "      Fetching latest stable MariaDB version from downloads API ..." -ForegroundColor Yellow
        try {
            $apiResponse = Invoke-RestMethod -Uri "https://downloads.mariadb.org/rest-api/mariadb/" -UseBasicParsing
            # The API returns a list of release objects; pick the latest stable GA release
            $latestRelease = $apiResponse.major_releases |
                Where-Object { $_.release_status -eq "Stable" } |
                Sort-Object release_id -Descending |
                Select-Object -First 1
            $MariaDBVersion = $latestRelease.latest_release
            Write-Host "      Latest stable version: $MariaDBVersion" -ForegroundColor Green
        } catch {
            Write-Error "Could not determine the latest MariaDB version automatically. Provide -MariaDBVersion '11.4.x' and re-run."
            exit 1
        }
    }

    $msiFolder   = "${msiArch}-packages"
    $msiFilename = "mariadb-${MariaDBVersion}-${msiArch}.msi"
    $downloadUrl = "https://downloads.mariadb.org/mariadb/${MariaDBVersion}/${msiFolder}/${msiFilename}"
    $tmpMsi      = "$env:TEMP\mariadb-installer.msi"

    Write-Host "      Downloading MariaDB $MariaDBVersion MSI ..." -ForegroundColor Yellow
    Write-Host "      URL: $downloadUrl" -ForegroundColor Cyan
    Invoke-WebRequest -Uri $downloadUrl -OutFile $tmpMsi -UseBasicParsing
    $sizeMB = [math]::Round((Get-Item $tmpMsi).Length / 1MB, 1)
    Write-Host "      Downloaded $sizeMB MB" -ForegroundColor Green

    Write-Host "      Running MSI installer (silent, no server service) ..." -ForegroundColor Yellow
    # ADDLOCAL=CLIENT installs only the client tools without registering a Windows service
    Start-Process msiexec.exe -ArgumentList "/i `"$tmpMsi`" /quiet /norestart ADDLOCAL=CLIENT" -Wait -NoNewWindow

    Remove-Item $tmpMsi -Force

    # Refresh PATH in current session
    $env:PATH = [System.Environment]::GetEnvironmentVariable("PATH", "Machine") + ";" +
                [System.Environment]::GetEnvironmentVariable("PATH", "User")
}

Write-Host "      Done." -ForegroundColor Green

# ── Step 3: Create credentials template ────────────────────────────────────
Write-Host "[3/4] Creating credentials template (my.ini) ..." -ForegroundColor Yellow

$configDir = "$env:APPDATA\MariaDB"
$configFile = "$configDir\my.ini"

if (!(Test-Path $configDir)) {
    New-Item -ItemType Directory -Path $configDir -Force | Out-Null
}

if (!(Test-Path $configFile)) {
    $configTemplate = @'
# MariaDB client configuration — Windows
# Location: %APPDATA%\MariaDB\my.ini
#
# Uncomment and fill in your connection defaults to avoid typing them each time.
# IMPORTANT: Restrict access to this file — do NOT commit it to source control.

[client]
# host     = localhost
# port     = 3306
# user     = myuser
# password = mypassword
# database = mydb
default-character-set = utf8mb4
'@
    $configTemplate | Out-File -FilePath $configFile -Encoding UTF8
    Write-Host "      Template written to: $configFile" -ForegroundColor Green
} else {
    Write-Host "      $configFile already exists — not overwritten." -ForegroundColor Green
}

# ── Step 4: Verify ─────────────────────────────────────────────────────────
Write-Host "[4/4] Verifying installation ..." -ForegroundColor Yellow

# First try PATH, then scan common install directories on disk
$mariadbExe = $null
foreach ($candidate in @("mariadb", "mysql")) {
    try {
        $null = Get-Command $candidate -ErrorAction Stop
        $mariadbExe = (Get-Command $candidate).Source
        break
    } catch {}
}

# Fallback: scan Program Files for the binary (PATH may not be refreshed yet)
if ($null -eq $mariadbExe) {
    $diskSearch = Get-ChildItem "C:\Program Files\MariaDB*\bin\mariadb.exe" -ErrorAction SilentlyContinue |
        Sort-Object FullName -Descending |
        Select-Object -First 1
    if ($diskSearch) {
        $mariadbExe = $diskSearch.FullName
    }
}

if ($null -ne $mariadbExe) {
    $version = & $mariadbExe --version 2>&1
    Write-Host ""
    Write-Host "=== Installation successful! ===" -ForegroundColor Green
    Write-Host "  Binary: $mariadbExe"
    Write-Host "  $version"
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Cyan
    Write-Host "  Open a NEW terminal, then run:"
    Write-Host "  mariadb -h 127.0.0.1 -u root -p     # connect to local server"
    Write-Host "  mariadb --help                       # show all options"
    Write-Host ""
    Write-Host "  If 'mariadb' is not in PATH, use the full path:" -ForegroundColor Yellow
    Write-Host "  & `"$mariadbExe`""
    Write-Host ""
    Write-Host "Connection defaults can be stored in:" -ForegroundColor Cyan
    Write-Host "  $configFile"
} else {
    Write-Warning "Verification failed — mariadb.exe not found in PATH or standard install directories."
    Write-Warning "Check C:\Program Files\MariaDB*\bin\ manually, or open a new terminal and try again."
    exit 1
}
