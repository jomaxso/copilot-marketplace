#!/usr/bin/env bash
# ============================================================================
# MariaDB Client Tools — macOS Installer
#
# Installs mariadb-client via Homebrew. If Homebrew is not installed, it
# offers to install it first.
#
# Usage:
#   chmod +x install-macos.sh
#   ./install-macos.sh
# ============================================================================

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}=== MariaDB Client Tools Installer — macOS ===${NC}"
echo ""

# ── Step 1: Check Homebrew ─────────────────────────────────────────────────
echo -e "${YELLOW}[1/3] Checking for Homebrew ...${NC}"
if command -v brew >/dev/null 2>&1; then
    echo -e "${GREEN}      Homebrew found: $(brew --version | head -1)${NC}"
else
    echo -e "${YELLOW}      Homebrew not found.${NC}"
    echo ""
    read -r -p "Install Homebrew now? [y/N] " answer
    case "$answer" in
        [yY][eE][sS]|[yY])
            echo "Installing Homebrew ..."
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            # Add Homebrew to PATH for Apple Silicon
            if [ -f /opt/homebrew/bin/brew ]; then
                eval "$(/opt/homebrew/bin/brew shellenv)"
            fi
            ;;
        *)
            echo -e "${RED}Homebrew is required. Install it from https://brew.sh and re-run this script.${NC}"
            exit 1
            ;;
    esac
fi

# ── Step 2: Install mariadb-client ────────────────────────────────────────
echo -e "${YELLOW}[2/3] Installing mariadb-client via Homebrew ...${NC}"
echo ""
echo -e "${CYAN}Tip: 'mariadb-client' installs only the client tools (no server).${NC}"
echo -e "${CYAN}     Use 'brew install mariadb' if you also need a local server.${NC}"
echo ""

if brew list mariadb-client &>/dev/null; then
    echo -e "${GREEN}      mariadb-client is already installed. Running upgrade ...${NC}"
    brew upgrade mariadb-client || true
elif brew list mariadb &>/dev/null; then
    echo -e "${GREEN}      Full mariadb (with client) is already installed. Running upgrade ...${NC}"
    brew upgrade mariadb || true
else
    brew install mariadb-client
fi

# Ensure Homebrew's opt/mariadb-client/bin is in PATH (brew link is keg-only)
BREW_PREFIX="$(brew --prefix)"
CLIENT_BIN_DIR="${BREW_PREFIX}/opt/mariadb-client/bin"

SHELL_NAME="$(basename "${SHELL:-/bin/zsh}")"
case "$SHELL_NAME" in
    zsh)  RC_FILE="$HOME/.zshrc" ;;
    bash) RC_FILE="$HOME/.bash_profile" ;;
    fish) RC_FILE="$HOME/.config/fish/config.fish" ;;
    *)    RC_FILE="$HOME/.zprofile" ;;
fi

if [ -d "$CLIENT_BIN_DIR" ]; then
    if echo "$PATH" | tr ':' '\n' | grep -qx "$CLIENT_BIN_DIR"; then
        echo -e "${GREEN}      $CLIENT_BIN_DIR already in PATH.${NC}"
    else
        if [ "$SHELL_NAME" = "fish" ]; then
            EXPORT_LINE="fish_add_path $CLIENT_BIN_DIR"
        else
            EXPORT_LINE="export PATH=\"$CLIENT_BIN_DIR:\$PATH\""
        fi
        if [ -f "$RC_FILE" ] && grep -qF "$CLIENT_BIN_DIR" "$RC_FILE" 2>/dev/null; then
            echo -e "${GREEN}      PATH entry already exists in $RC_FILE.${NC}"
        else
            echo "$EXPORT_LINE" >> "$RC_FILE"
            echo -e "${GREEN}      Added PATH entry to $RC_FILE${NC}"
        fi
        export PATH="$CLIENT_BIN_DIR:$PATH"
    fi
fi

# ── Step 3: Verify ─────────────────────────────────────────────────────────
echo -e "${YELLOW}[3/3] Verifying installation ...${NC}"

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
    echo "  source $RC_FILE                     # reload PATH (or open a new terminal)"
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
    echo "Try opening a new terminal or running: source $RC_FILE"
    exit 1
fi
