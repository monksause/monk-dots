#!/usr/bin/env bash
# =============================================================================
#  install.sh — dotfiles bootstrap
#  Detects distro, installs all required packages, then uses GNU Stow to

#  Expected stow package layout (each config dir mirrors $HOME):
#    ~/.dotfiles/alacritty/.config/alacritty/  →  ~/.config/alacritty/
#    ~/.dotfiles/fish/.config/fish/            →  ~/.config/fish/
#    ... and so on.
#
#  Usage:
#    ./install.sh            — install packages + stow all configs
#    ./install.sh --unstow   — remove all stow-managed symlinks
#    ./install.sh --restow   — restow (useful after pulling upstream changes)
# =============================================================================

set -euo pipefail

DOTFILES_DIR="${HOME}/.dotfiles"

# Stow packages (must match directory names inside ~/.dotfiles)
CONFIGS=(alacritty fish hypr kitty rofi swaync swayosd)

# Parse flag
ACTION="stow"
[[ "${1:-}" == "--unstow"  ]] && ACTION="unstow"
[[ "${1:-}" == "--restow"  ]] && ACTION="restow"

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
                stow
                alacritty fish kitty
                hyprland xdg-desktop-portal-hyprland
                awww hyprlock hypridle
                rofi-wayland waybar
                flameshot pavucontrol blueman nm-connection-editor
                pipewire pipewire-pulse wireplumber
            )
            # AUR packages (swaync, swayosd)
            PKGS_AUR=(swaync swayosd nmgui-bin)

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
                stow
                alacritty fish kitty
                hyprland xdg-desktop-portal-hyprland
                awww hyprlock hypridle
                rofi-wayland waybar
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
                stow
                alacritty fish kitty
                hyprland xdg-desktop-portal-hyprland
                rofi waybar
                sway-notification-center   # package name for swaync on apt
                flameshot pavucontrol blueman network-manager-gnome
                pipewire pipewire-audio wireplumber
                awww
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

    # nmgui — binary install for non-Arch distros
    if [[ "${DISTRO}" != "arch" ]]; then
        install_nmgui
    fi

    success "Package installation complete."
}

# ── nmgui (Fedora + Debian only) ──────────────────────────────────────────────
install_nmgui() {
    info "Installing nmgui…"
    sudo curl -L https://github.com/s-adi-dev/nmgui/releases/download/v1.0.0/main.bin \
        -o /usr/bin/nmgui
    sudo chmod +x /usr/bin/nmgui
    curl -sL https://raw.githubusercontent.com/s-adi-dev/nmgui/main/nmgui.desktop \
        | sudo tee /usr/share/applications/nmgui.desktop > /dev/null
    success "nmgui installed."
}

# ── Stow dotfiles ─────────────────────────────────────────────────────────────
stow_configs() {
    [[ -d "${DOTFILES_DIR}" ]] \
        || die "~/.dotfiles not found! Clone your dotfiles there first."

    case "${ACTION}" in
        stow)
            info "Stowing configs into ${HOME}…"
            STOW_FLAGS=("--verbose=1" "--target=${HOME}" "--dir=${DOTFILES_DIR}")
            ;;
        unstow)
            info "Unstowing configs from ${HOME}…"
            STOW_FLAGS=("--verbose=1" "--target=${HOME}" "--dir=${DOTFILES_DIR}" "--delete")
            ;;
        restow)
            info "Restowing configs (delete + re-link)…"
            STOW_FLAGS=("--verbose=1" "--target=${HOME}" "--dir=${DOTFILES_DIR}" "--restow")
            ;;
    esac

    for pkg in "${CONFIGS[@]}"; do
        if [[ ! -d "${DOTFILES_DIR}/${pkg}" ]]; then
            warn "Package directory missing, skipping: ${DOTFILES_DIR}/${pkg}"
            continue
        fi
        stow "${STOW_FLAGS[@]}" "${pkg}" \
            && success "${ACTION}: ${pkg}" \
            || warn "stow conflict on '${pkg}' — check for existing files and remove or back them up."
    done
}

# ── Entry point ───────────────────────────────────────────────────────────────
main() {
    echo -e "\n${BOLD}╔══════════════════════════════════╗"
    echo -e   "║   dotfiles bootstrap — install.sh  ║"
    echo -e   "╚══════════════════════════════════╝${RESET}\n"

    detect_distro

    if [[ "${ACTION}" == "stow" ]]; then
        install_packages
    else
        info "Skipping package install (action: ${ACTION})"
    fi

    stow_configs

    echo ""
    success "All done! Log out and back in (or reboot) to start Hyprland."
}

main "$@"
