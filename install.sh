#!/usr/bin/env bash
#
# install.sh - set up this bash configuration on Arch, Debian/Ubuntu, Fedora or openSUSE
#
# What it does:
#   1. Detects your package manager (pacman, apt, dnf or zypper)
#   2. Installs the dependencies (zoxide, bat, fastfetch, oh-my-posh, ...)
#   3. Symlinks the config files from this repo into $HOME
#      (anything already there is backed up, never deleted)
#
# Usage:
#   ./install.sh              install dependencies and link the configs
#   ./install.sh --no-deps    only link the configs
#   ./install.sh -y           don't ask for confirmation before installing
#   ./install.sh --help       show this help
#
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
LOCAL_BIN="$HOME/.local/bin"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"

# Same package names on pacman, apt, dnf and zypper
PACKAGES=(zoxide bat fastfetch bash-completion curl unzip)

PM=""
SUDO=""

# ─── Output helpers ──────────────────────────────────────────────────────────

if [ -t 1 ]; then
    BLUE=$'\e[34m'; GREEN=$'\e[32m'; YELLOW=$'\e[33m'; RED=$'\e[31m'; RESET=$'\e[0m'
else
    BLUE=""; GREEN=""; YELLOW=""; RED=""; RESET=""
fi

info()  { printf '%s::%s %s\n'  "$BLUE"   "$RESET" "$*"; }
ok()    { printf '%s✔%s  %s\n'  "$GREEN"  "$RESET" "$*"; }
warn()  { printf '%s!%s  %s\n'  "$YELLOW" "$RESET" "$*" >&2; }
error() { printf '%s✖%s  %s\n'  "$RED"    "$RESET" "$*" >&2; }

usage() {
    cat <<'EOF'
Usage: ./install.sh [options]

Options:
  --no-deps    only link the config files, don't install any packages
  -y, --yes    don't ask for confirmation before installing packages
  -h, --help   show this help

Supported package managers: pacman (Arch), apt (Debian/Ubuntu),
dnf (Fedora), zypper (openSUSE).
EOF
}

# ─── Distro / package manager detection ──────────────────────────────────────

detect_pm() {
    if   command -v pacman  >/dev/null 2>&1; then PM="pacman"
    elif command -v dnf     >/dev/null 2>&1; then PM="dnf"
    elif command -v zypper  >/dev/null 2>&1; then PM="zypper"
    elif command -v apt-get >/dev/null 2>&1; then PM="apt"
    else PM=""
    fi
}

distro_name() {
    if [ -r /etc/os-release ]; then
        # shellcheck disable=SC1091
        . /etc/os-release
        printf '%s' "${PRETTY_NAME:-${NAME:-unknown}}"
    else
        printf 'unknown'
    fi
}

setup_sudo() {
    if [ "$(id -u)" -eq 0 ]; then
        SUDO=""
    elif command -v sudo >/dev/null 2>&1; then
        SUDO="sudo"
    else
        error "Installing packages needs root, but 'sudo' was not found. Run as root, or use --no-deps."
        return 1
    fi
}

pm_install() {
    case "$PM" in
        pacman) $SUDO pacman -S --needed --noconfirm "$@" ;;
        apt)    $SUDO apt-get install -y "$@" ;;
        dnf)    $SUDO dnf install -y "$@" ;;
        zypper) $SUDO zypper --non-interactive install "$@" ;;
    esac
}

confirm() {
    [ "$ASSUME_YES" -eq 1 ] && return 0
    [ -t 0 ] || return 0      # non-interactive run: don't block
    local reply
    read -r -p "Continue? [Y/n] " reply
    case "$reply" in
        ""|[Yy]*) return 0 ;;
        *)        return 1 ;;
    esac
}

# ─── Dependencies ────────────────────────────────────────────────────────────

install_packages() {
    local failed=() pkg

    [ "$PM" = "apt" ] && $SUDO apt-get update

    # Fast path: everything in one go
    if pm_install "${PACKAGES[@]}"; then
        return 0
    fi

    # One of them probably isn't available on this release: go one by one
    warn "Bulk install failed, retrying package by package"
    for pkg in "${PACKAGES[@]}"; do
        pm_install "$pkg" || failed+=("$pkg")
    done

    if [ "${#failed[@]}" -gt 0 ]; then
        warn "Could not install from the repos: ${failed[*]}"
        if printf '%s\n' "${failed[@]}" | grep -qx fastfetch; then
            warn "fastfetch: grab a release from https://github.com/fastfetch-cli/fastfetch/releases"
        fi
    fi
}

# oh-my-posh isn't in the official repos of these distros, so use its own installer
install_oh_my_posh() {
    if command -v oh-my-posh >/dev/null 2>&1; then
        ok "oh-my-posh already installed"
        return 0
    fi

    if ! command -v curl >/dev/null 2>&1; then
        warn "curl is missing, can't install oh-my-posh. See https://ohmyposh.dev/docs/installation/linux"
        return 0
    fi

    info "Installing oh-my-posh to $LOCAL_BIN (official installer from ohmyposh.dev)"
    mkdir -p "$LOCAL_BIN"
    if curl -fsSL https://ohmyposh.dev/install.sh | bash -s -- -d "$LOCAL_BIN"; then
        ok "oh-my-posh installed"
    else
        warn "oh-my-posh installation failed. See https://ohmyposh.dev/docs/installation/linux"
    fi
}

# Debian/Ubuntu ship bat as 'batcat'; the .bashrc expects 'bat'
fix_debian_bat() {
    if ! command -v bat >/dev/null 2>&1 && command -v batcat >/dev/null 2>&1; then
        mkdir -p "$LOCAL_BIN"
        ln -sf "$(command -v batcat)" "$LOCAL_BIN/bat"
        ok "Created $LOCAL_BIN/bat -> batcat"
    fi
}

install_deps() {
    detect_pm
    if [ -z "$PM" ]; then
        warn "No supported package manager found (pacman, apt, dnf, zypper). Install manually: zoxide bat fastfetch oh-my-posh"
        return 0
    fi

    info "Detected $(distro_name) (package manager: $PM)"
    info "Packages to install: ${PACKAGES[*]} (+ oh-my-posh via its official installer)"

    if ! confirm; then
        warn "Skipping dependencies"
        return 0
    fi

    setup_sudo
    install_packages
    fix_debian_bat

    # make freshly installed binaries visible to the checks at the end
    export PATH="$LOCAL_BIN:$PATH"
    install_oh_my_posh
}

# ─── Linking ─────────────────────────────────────────────────────────────────

# link <source in repo> <destination>
# - skips if the destination already points to the source
# - moves anything else out of the way to <destination>.bak.<timestamp>
link() {
    local src="$1" dst="$2"

    if [ ! -e "$src" ]; then
        warn "Missing in repo, skipping: ${src#"$REPO_DIR"/}"
        return 0
    fi

    if [ -L "$dst" ] && [ "$(readlink -f "$dst")" = "$(readlink -f "$src")" ]; then
        ok "Already linked: $dst"
        return 0
    fi

    if [ -e "$dst" ] || [ -L "$dst" ]; then
        mv "$dst" "$dst.bak.$TIMESTAMP"
        warn "Existing $dst moved to $dst.bak.$TIMESTAMP"
    fi

    mkdir -p "$(dirname "$dst")"
    ln -s "$src" "$dst"
    ok "Linked $dst -> $src"
}

link_configs() {
    info "Linking config files from $REPO_DIR"
    link "$REPO_DIR/.bashrc"           "$HOME/.bashrc"
    link "$REPO_DIR/config/oh-my-posh" "$CONFIG_HOME/oh-my-posh"
    link "$REPO_DIR/fastfetch"         "$CONFIG_HOME/fastfetch"
}

# ─── Main ────────────────────────────────────────────────────────────────────

main() {
    local want_deps=1
    ASSUME_YES=0

    for arg in "$@"; do
        case "$arg" in
            --no-deps)  want_deps=0 ;;
            -y|--yes)   ASSUME_YES=1 ;;
            -h|--help)  usage; exit 0 ;;
            *)          error "Unknown option: $arg"; usage; exit 1 ;;
        esac
    done

    [ "$want_deps" -eq 1 ] && install_deps
    link_configs

    echo
    ok "Done. Open a new terminal or run: source ~/.bashrc"

    local tool
    for tool in oh-my-posh zoxide bat fastfetch; do
        command -v "$tool" >/dev/null 2>&1 || warn "'$tool' is still missing, the .bashrc will just skip it"
    done
    info "Tip: set a Nerd Font in your terminal emulator, otherwise the prompt icons won't render."
}

main "$@"
