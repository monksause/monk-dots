#!/usr/bin/env bash
# =============================================================================
#  install.sh — dotfiles bootstrap
#  Detects distro, installs all required packages, then symlinks ~/.dotfiles/*
#  into ~/.config/
# =============================================================================

set -euo pipefail

DOTFILES_DIR="${HOME}/.dotfiles"
CONFIG_DIR="${HOME}/.config"

# Configs to symlink (must match directory names inside ~/.dotfiles)
CONFIGS=(alacritty fish hypr kitty rofi swaync swayosd)

# ── Colours ──────────────────────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; BOLD='\033[1m'; RESET='\033[0m'

info()    { echo -e "${CYAN}[INFO]${RESET}  $*"; }
success() { echo -e "${GREEN}[OK]${RESET}    $*"; }
warn()    { echo -e "${YELLOW}[WARN]${RESET}  $*"; }
error()   { echo -e "${RED}[ERR]${RESET}   $*" >&2; }
die()     { error "$*"; exit 1; }

# ── Detect distro / package manager ──────────────────────────────────────────
detect_distro() {
    if command -v pacman &>/dev/null; then
        DISTRO="arch"
    elif command -v dnf &>/dev/null; then
        DISTRO="fedora"
    elif command -v apt &>/dev/null; then
        DISTRO="debian"
    else
        die "Unsupported distro — only Arch, Fedora, and Debian-based systems are supported."
    fi
    info "Detected distro family: ${BOLD}${DISTRO}${RESET}"
}

# ── Package lists ─────────────────────────────────────────────────────────────
# Packages available in main repos on all three distros (names vary per distro)
install_packages() {
    case "${DISTRO}" in

        # ── Arch ─────────────────────────────────────────────────────────────
        arch)
            PKGS_MAIN=(
                alacritty fish kitty
                hyprland xdg-desktop-portal-hyprland
                swww hyprlock hypridle
                rofi-wayland
                flameshot pavucontrol blueman nm-connection-editor
                pipewire pipewire-pulse wireplumber
            )
            # AUR packages (swaync, swayosd)
            PKGS_AUR=(swaync swayosd)

            info "Installing main repo packages via pacman…"
            sudo pacman -Syu --needed --noconfirm "${PKGS_MAIN[@]}"

            # Install AUR helper if missing
            if ! command -v yay &>/dev/null && ! command -v paru &>/dev/null; then
                info "No AUR helper found — installing yay…"
                sudo pacman -S --needed --noconfirm git base-devel
                tmpdir=$(mktemp -d)
                git clone https://aur.archlinux.org/yay.git "${tmpdir}/yay"
                (cd "${tmpdir}/yay" && makepkg -si --noconfirm)
                rm -rf "${tmpdir}"
            fi

            AUR_HELPER="$(command -v paru || command -v yay)"
            info "Installing AUR packages via ${AUR_HELPER##*/}…"
            "${AUR_HELPER}" -S --needed --noconfirm "${PKGS_AUR[@]}"
            ;;

        # ── Fedora ────────────────────────────────────────────────────────────
        fedora)
            info "Enabling required COPRs…"
            # swaync
            sudo dnf copr enable -y erikreider/SwayNotificationCenter 2>/dev/null \
                || warn "swaync COPR may already be enabled or unavailable."
            # swayosd
            sudo dnf copr enable -y bhavyagondu/swayosd 2>/dev/null \
                || warn "swayosd COPR may already be enabled or unavailable."
            # hyprland (solopasha's repo is the canonical Fedora Hyprland COPR)
            sudo dnf copr enable -y solopasha/hyprland 2>/dev/null \
                || warn "hyprland COPR may already be enabled or unavailable."

            PKGS_MAIN=(
                alacritty fish kitty
                hyprland xdg-desktop-portal-hyprland
                swww hyprlock hypridle
                rofi-wayland
                SwayNotificationCenter swayosd
                flameshot pavucontrol blueman nm-connection-editor
                pipewire pipewire-pulseaudio wireplumber
            )

            info "Installing packages via dnf…"
            sudo dnf install -y "${PKGS_MAIN[@]}"
            ;;

        # ── Debian / Ubuntu ───────────────────────────────────────────────────
        debian)
            info "Updating apt cache…"
            sudo apt update

            # Hyprland on Debian/Ubuntu requires either a PPA (Ubuntu) or
            # building from source. We add the Hyprland PPA on Ubuntu-based
            # systems; on pure Debian we warn the user.
            if grep -qi "ubuntu" /etc/os-release 2>/dev/null; then
                info "Ubuntu detected — adding hyprland PPA…"
                sudo apt install -y software-properties-common
                sudo add-apt-repository -y ppa:hypr-ubuntu/hyprland
                sudo apt update
            else
                warn "Pure Debian detected. Hyprland is not in official repos."
                warn "You may need to build it from source: https://wiki.hyprland.org/Getting-Started/Installation/"
            fi

            # swaync — available in Ubuntu 24.04+ and Debian sid; fall back gracefully
            # swayosd  — usually needs manual install on Debian; we try apt and warn
            PKGS_MAIN=(
                alacritty fish kitty
                hyprland xdg-desktop-portal-hyprland
                rofi
                sway-notification-center   # package name for swaync on apt
                flameshot pavucontrol blueman network-manager-gnome
                pipewire pipewire-audio wireplumber
                swww
            )

            info "Installing packages via apt…"
            for pkg in "${PKGS_MAIN[@]}"; do
                if apt-cache show "${pkg}" &>/dev/null; then
                    sudo apt install -y "${pkg}"
                else
                    warn "Package '${pkg}' not found in apt repos — skipping. Install manually if needed."
                fi
            done

            # swayosd — not in apt, point user to release binary
            warn "swayosd is not in apt repos. Download the latest release from:"
            warn "  https://github.com/ErikReider/SwayOSD/releases"
            warn "and place the binary in /usr/local/bin/swayosd-server"
            ;;
    esac

    success "Package installation complete."
}

# ── Symlink dotfiles ──────────────────────────────────────────────────────────
symlink_configs() {
    info "Symlinking configs from ${DOTFILES_DIR} → ${CONFIG_DIR}"

    [[ -d "${DOTFILES_DIR}" ]] \
        || die "~/.dotfiles directory not found! Clone your dotfiles there first."

    mkdir -p "${CONFIG_DIR}"

    for cfg in "${CONFIGS[@]}"; do
        src="${DOTFILES_DIR}/${cfg}"
        dst="${CONFIG_DIR}/${cfg}"

        if [[ ! -d "${src}" ]]; then
            warn "Source directory missing, skipping: ${src}"
            continue
        fi

        if [[ -L "${dst}" ]]; then
            warn "Symlink already exists, skipping: ${dst}"
        elif [[ -d "${dst}" ]]; then
            warn "Real directory exists at ${dst}. Backing up → ${dst}.bak"
            mv "${dst}" "${dst}.bak"
            ln -s "${src}" "${dst}"
            success "Linked (after backup): ${dst} → ${src}"
        else
            ln -s "${src}" "${dst}"
            success "Linked: ${dst} → ${src}"
        fi
    done
}

# ── Entry point ───────────────────────────────────────────────────────────────
main() {
    echo -e "\n${BOLD}╔══════════════════════════════════╗"
    echo -e   "║   dotfiles bootstrap — install.sh  ║"
    echo -e   "╚══════════════════════════════════╝${RESET}\n"

    detect_distro
    install_packages
    symlink_configs

    echo ""
    success "All done! Log out and back in (or reboot) to start Hyprland."
}

main "$@"
