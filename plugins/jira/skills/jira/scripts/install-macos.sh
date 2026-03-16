#!/usr/bin/env bash
# ============================================================================
# Atlassian CLI (acli) — macOS Installer
#
# Usage:
#   chmod +x install-macos.sh
#   ./install-macos.sh                    # installs to ~/.local/bin (no sudo)
#   sudo ./install-macos.sh               # installs to /usr/local/bin
#   ./install-macos.sh /custom/path       # installs to custom directory
#
# Alternative: brew tap atlassian/homebrew-acli && brew install acli
# ============================================================================

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# Determine install directory
if [ $# -ge 1 ]; then
    INSTALL_DIR="$1"
elif [ "$(id -u)" -eq 0 ]; then
    INSTALL_DIR="/usr/local/bin"
else
    INSTALL_DIR="$HOME/.local/bin"
fi

# Detect architecture
ARCH="$(uname -m)"
case "$ARCH" in
    x86_64)  DOWNLOAD_URL="https://acli.atlassian.com/darwin/latest/acli_darwin_amd64/acli" ;;
    arm64)   DOWNLOAD_URL="https://acli.atlassian.com/darwin/latest/acli_darwin_arm64/acli" ;;
    *)
        echo -e "${RED}Error: Unsupported architecture: $ARCH. Only x86_64 (Intel) and arm64 (Apple Silicon) are supported.${NC}"
        exit 1
        ;;
esac

echo -e "${CYAN}=== Atlassian CLI (acli) Installer — macOS ===${NC}"
echo "Architecture : $ARCH"
echo "Install path : $INSTALL_DIR"
echo ""
echo -e "${CYAN}Tip: You can also install via Homebrew:${NC}"
echo "  brew tap atlassian/homebrew-acli && brew install acli"
echo ""

# Step 1: Create install directory
if [ ! -d "$INSTALL_DIR" ]; then
    echo -e "${YELLOW}[1/4] Creating directory $INSTALL_DIR ...${NC}"
    mkdir -p "$INSTALL_DIR"
else
    echo -e "${GREEN}[1/4] Directory $INSTALL_DIR already exists.${NC}"
fi

# Step 2: Download binary
echo -e "${YELLOW}[2/4] Downloading acli ...${NC}"
curl -fSL "$DOWNLOAD_URL" -o "$INSTALL_DIR/acli"
chmod +x "$INSTALL_DIR/acli"
SIZE_MB=$(du -m "$INSTALL_DIR/acli" | cut -f1)
echo -e "${GREEN}      Downloaded ${SIZE_MB} MB${NC}"

# Step 3: PATH check
echo -e "${YELLOW}[3/4] Checking PATH ...${NC}"
if echo "$PATH" | tr ':' '\n' | grep -qx "$INSTALL_DIR"; then
    echo -e "${GREEN}      $INSTALL_DIR is already in PATH.${NC}"
else
    echo -e "${YELLOW}      $INSTALL_DIR is NOT in your PATH.${NC}"
    SHELL_NAME="$(basename "${SHELL:-/bin/zsh}")"
    case "$SHELL_NAME" in
        zsh)  RC_FILE="$HOME/.zshrc" ;;
        bash) RC_FILE="$HOME/.bash_profile" ;;
        fish) RC_FILE="$HOME/.config/fish/config.fish" ;;
        *)    RC_FILE="$HOME/.zprofile" ;;
    esac

    if [ "$SHELL_NAME" = "fish" ]; then
        EXPORT_LINE="set -gx PATH $INSTALL_DIR \$PATH"
    else
        EXPORT_LINE="export PATH=\"$INSTALL_DIR:\$PATH\""
    fi

    if [ -f "$RC_FILE" ] && grep -qF "$INSTALL_DIR" "$RC_FILE" 2>/dev/null; then
        echo -e "${GREEN}      PATH entry already exists in $RC_FILE.${NC}"
    else
        echo "$EXPORT_LINE" >> "$RC_FILE"
        echo -e "${GREEN}      Added to $RC_FILE${NC}"
    fi
    # Update current session
    export PATH="$INSTALL_DIR:$PATH"
fi

# Step 4: Verify
echo -e "${YELLOW}[4/4] Verifying installation ...${NC}"
VERSION="$("$INSTALL_DIR/acli" --version 2>&1)" || true
if [ -n "$VERSION" ]; then
    echo ""
    echo -e "${GREEN}=== Installation successful! ===${NC}"
    echo "  $VERSION"
    echo ""
    echo -e "${CYAN}Next steps:${NC}"
    echo "  source $RC_FILE      # reload PATH (or open a new terminal)"
    echo "  acli --help"
    echo "  acli auth login --web"
else
    echo -e "${RED}Verification failed. Check the download and try again.${NC}"
    exit 1
fi
