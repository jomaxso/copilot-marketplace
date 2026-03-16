#!/usr/bin/env bash
# ============================================================================
# MariaDB Client Tools — Linux Installer
#
# Installs the mariadb-client package (mariadb, mariadb-dump, mariadb-admin)
# using the system package manager, or falls back to the MariaDB official repo.
#
# Usage:
#   chmod +x install-linux.sh
#   ./install-linux.sh           # auto-detects distro
#   sudo ./install-linux.sh      # required for package installation
# ============================================================================

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}=== MariaDB Client Tools Installer — Linux ===${NC}"
echo ""

# ── Step 1: Detect distribution ────────────────────────────────────────────
echo -e "${YELLOW}[1/4] Detecting distribution ...${NC}"
if [ -f /etc/os-release ]; then
    # shellcheck source=/dev/null
    . /etc/os-release
    DISTRO="${ID:-unknown}"
    DISTRO_LIKE="${ID_LIKE:-}"
else
    DISTRO="unknown"
    DISTRO_LIKE=""
fi

echo "      Detected: $DISTRO"

# Normalise to package manager family
if echo "$DISTRO $DISTRO_LIKE" | grep -qiE "debian|ubuntu|mint|pop"; then
    PKG_FAMILY="debian"
elif echo "$DISTRO $DISTRO_LIKE" | grep -qiE "rhel|fedora|centos|rocky|alma|ol"; then
    PKG_FAMILY="rhel"
elif echo "$DISTRO" | grep -qiE "arch|manjaro|endeavour"; then
    PKG_FAMILY="arch"
elif echo "$DISTRO" | grep -qiE "suse|opensuse"; then
    PKG_FAMILY="suse"
else
    PKG_FAMILY="unknown"
fi

# ── Step 2: Check / escalate privileges ────────────────────────────────────
echo -e "${YELLOW}[2/4] Checking privileges ...${NC}"
if [ "$(id -u)" -ne 0 ]; then
    if command -v sudo >/dev/null 2>&1; then
        SUDO="sudo"
        echo "      Using sudo for package installation."
    else
        echo -e "${RED}Error: Root privileges required. Please run as root or install sudo.${NC}"
        exit 1
    fi
else
    SUDO=""
    echo "      Running as root."
fi

# ── Step 3: Install client package ─────────────────────────────────────────
echo -e "${YELLOW}[3/4] Installing MariaDB client tools ...${NC}"
case "$PKG_FAMILY" in
    debian)
        $SUDO apt-get update -qq
        $SUDO apt-get install -y mariadb-client
        ;;
    rhel)
        if command -v dnf >/dev/null 2>&1; then
            $SUDO dnf install -y mariadb
        else
            $SUDO yum install -y mariadb
        fi
        ;;
    arch)
        $SUDO pacman -Sy --noconfirm mariadb-clients
        ;;
    suse)
        $SUDO zypper install -y mariadb-client
        ;;
    *)
        echo -e "${YELLOW}      Unknown distribution. Attempting manual install from MariaDB repo ...${NC}"
        if command -v curl >/dev/null 2>&1; then
            echo "      Downloading mariadb_repo_setup ..."
            curl -fsSL https://downloads.mariadb.com/MariaDB/mariadb_repo_setup | $SUDO bash
            if command -v apt-get >/dev/null 2>&1; then
                $SUDO apt-get install -y mariadb-client
            elif command -v yum >/dev/null 2>&1; then
                $SUDO yum install -y MariaDB-client
            else
                echo -e "${RED}Error: No supported package manager found. Install MariaDB client manually from https://mariadb.org/download/${NC}"
                exit 1
            fi
        else
            echo -e "${RED}Error: curl not found. Install curl and re-run, or install MariaDB client manually from https://mariadb.org/download/${NC}"
            exit 1
        fi
        ;;
esac
echo -e "${GREEN}      Package installed.${NC}"

# ── Step 4: Verify ─────────────────────────────────────────────────────────
echo -e "${YELLOW}[4/4] Verifying installation ...${NC}"

MARIADB_BIN=""
for bin in mariadb mysql; do
    if command -v "$bin" >/dev/null 2>&1; then
        MARIADB_BIN="$bin"
        break
    fi
done

if [ -n "$MARIADB_BIN" ]; then
    VERSION="$($MARIADB_BIN --version 2>&1)"
    echo ""
    echo -e "${GREEN}=== Installation successful! ===${NC}"
    echo "  $VERSION"
    echo ""
    echo -e "${CYAN}Next steps:${NC}"
    echo "  mariadb -h localhost -u root -p     # connect to local server"
    echo "  mariadb --help                      # show all options"
    echo ""
    echo -e "${CYAN}Tip: Store connection defaults in ~/.my.cnf (chmod 600 ~/.my.cnf):${NC}"
    cat <<'CNFTIP'
  [client]
  host     = localhost
  user     = myuser
  password = mypassword
CNFTIP
else
    echo -e "${RED}Verification failed — mariadb binary not found in PATH.${NC}"
    echo "Please check the installation and ensure /usr/bin or the package's bin dir is in PATH."
    exit 1
fi
