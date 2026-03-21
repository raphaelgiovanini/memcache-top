#!/bin/bash
#
# memcache-top installer
# Installs memcache-top as a system command available anywhere.
#
# Usage:
#   curl -sL <url>/install.sh | bash
#   ./install.sh
#   ./install.sh --prefix /usr/local
#   ./install.sh --uninstall
#

set -e

PREFIX="${PREFIX:-/usr/local}"
BINDIR="${BINDIR:-$PREFIX/bin}"
SCRIPT_NAME="memcache-top"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'

info()  { echo -e "${GREEN}[+]${NC} $1"; }
warn()  { echo -e "${YELLOW}[!]${NC} $1"; }
error() { echo -e "${RED}[x]${NC} $1"; exit 1; }

usage() {
  cat <<EOF

  ${BOLD}memcache-top installer${NC}

  Usage: $0 [OPTIONS]

  Options:
    --prefix <path>    Installation prefix (default: /usr/local)
    --bindir <path>    Binary directory (default: <prefix>/bin)
    --uninstall        Remove memcache-top from the system
    --check            Check if dependencies are satisfied
    -h, --help         Show this help

  Examples:
    $0                          # Install to /usr/local/bin
    $0 --prefix /opt            # Install to /opt/bin
    $0 --bindir ~/.local/bin    # Install to ~/.local/bin (no root needed)
    $0 --uninstall              # Remove from system

EOF
  exit 0
}

check_deps() {
  local missing=0

  echo ""
  echo -e "  ${BOLD}Checking dependencies...${NC}"
  echo ""

  # Perl
  if command -v perl &>/dev/null; then
    local pv
    pv=$(perl -v 2>/dev/null | grep -oP 'v\d+\.\d+\.\d+' | head -1)
    info "perl $pv found"
  else
    error "perl is required but not found. Install it first."
  fi

  # Required modules (core)
  for mod in IO::Socket Time::HiRes; do
    if perl -M"$mod" -e 1 2>/dev/null; then
      info "perl module $mod (required) - OK"
    else
      warn "perl module $mod (required) - MISSING"
      missing=1
    fi
  done

  # Optional modules
  for mod in Getopt::Long Term::ANSIColor Term::ReadKey; do
    if perl -M"$mod" -e 1 2>/dev/null; then
      info "perl module $mod (optional) - OK"
    else
      warn "perl module $mod (optional) - not installed"
    fi
  done

  echo ""

  if [ "$missing" -eq 1 ]; then
    error "Required dependencies are missing. Install them before proceeding."
  fi

  info "All required dependencies satisfied!"
  echo ""
}

install_deps() {
  echo ""
  echo -e "  ${BOLD}Installing optional Perl modules...${NC}"
  echo ""

  # Try to install optional modules (best-effort)
  if command -v cpanm &>/dev/null; then
    cpanm --notest Term::ReadKey 2>/dev/null && info "Term::ReadKey installed" || warn "Could not install Term::ReadKey (optional)"
  elif command -v cpan &>/dev/null; then
    echo | cpan Term::ReadKey 2>/dev/null && info "Term::ReadKey installed" || warn "Could not install Term::ReadKey (optional)"
  else
    # Try system package managers
    if command -v apt-get &>/dev/null; then
      apt-get install -y libterm-readkey-perl 2>/dev/null && info "Term::ReadKey installed via apt" || warn "Could not install Term::ReadKey (optional)"
    elif command -v yum &>/dev/null; then
      yum install -y perl-TermReadKey 2>/dev/null && info "Term::ReadKey installed via yum" || warn "Could not install Term::ReadKey (optional)"
    elif command -v apk &>/dev/null; then
      apk add --no-cache perl-term-readkey 2>/dev/null && info "Term::ReadKey installed via apk" || warn "Could not install Term::ReadKey (optional)"
    else
      warn "No package manager found to install optional modules."
      warn "Interactive keyboard shortcuts will use fallback mode."
    fi
  fi
}

do_install() {
  echo ""
  echo -e "  ${BOLD}memcache-top installer${NC}"
  echo ""

  # Check perl exists
  command -v perl &>/dev/null || error "perl is required but not found."

  # Find the script
  local src=""
  if [ -f "$SCRIPT_DIR/$SCRIPT_NAME" ]; then
    src="$SCRIPT_DIR/$SCRIPT_NAME"
  elif [ -f "./$SCRIPT_NAME" ]; then
    src="./$SCRIPT_NAME"
  else
    error "Cannot find '$SCRIPT_NAME' script. Run this from the project directory."
  fi

  # Create target directory
  if [ ! -d "$BINDIR" ]; then
    info "Creating directory $BINDIR"
    mkdir -p "$BINDIR" 2>/dev/null || {
      warn "Cannot create $BINDIR without root. Trying with sudo..."
      sudo mkdir -p "$BINDIR"
    }
  fi

  # Copy and set permissions
  info "Installing $SCRIPT_NAME to $BINDIR/$SCRIPT_NAME"
  cp "$src" "$BINDIR/$SCRIPT_NAME" 2>/dev/null || {
    warn "Cannot copy without root. Trying with sudo..."
    sudo cp "$src" "$BINDIR/$SCRIPT_NAME"
  }

  chmod +x "$BINDIR/$SCRIPT_NAME" 2>/dev/null || sudo chmod +x "$BINDIR/$SCRIPT_NAME"

  # Try to install optional dependencies
  install_deps

  # Verify installation
  if command -v "$SCRIPT_NAME" &>/dev/null; then
    info "Installation complete!"
    echo ""
    echo -e "  Run ${BOLD}memcache-top --help${NC} to get started."
  else
    warn "Installed to $BINDIR/$SCRIPT_NAME"
    warn "$BINDIR may not be in your PATH."
    echo ""
    echo -e "  Add it with: ${BOLD}export PATH=\"$BINDIR:\$PATH\"${NC}"
    echo -e "  Or run directly: ${BOLD}$BINDIR/$SCRIPT_NAME --help${NC}"
  fi
  echo ""
}

do_uninstall() {
  echo ""
  echo -e "  ${BOLD}memcache-top uninstaller${NC}"
  echo ""

  if [ -f "$BINDIR/$SCRIPT_NAME" ]; then
    info "Removing $BINDIR/$SCRIPT_NAME"
    rm -f "$BINDIR/$SCRIPT_NAME" 2>/dev/null || {
      warn "Cannot remove without root. Trying with sudo..."
      sudo rm -f "$BINDIR/$SCRIPT_NAME"
    }
    info "memcache-top has been removed."
  else
    warn "memcache-top not found at $BINDIR/$SCRIPT_NAME"
  fi
  echo ""
}

# Parse arguments
ACTION="install"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --prefix)    PREFIX="$2"; BINDIR="$PREFIX/bin"; shift 2;;
    --bindir)    BINDIR="$2"; shift 2;;
    --uninstall) ACTION="uninstall"; shift;;
    --check)     ACTION="check"; shift;;
    -h|--help)   usage;;
    *)           error "Unknown option: $1. Use --help for usage.";;
  esac
done

case "$ACTION" in
  install)   check_deps; do_install;;
  uninstall) do_uninstall;;
  check)     check_deps;;
esac
