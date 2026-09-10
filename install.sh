#!/usr/bin/env bash

set -Eeuo pipefail

# =============================================================================
# hypr-dots installer
# =============================================================================

DOTFILES="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

PACMAN_FILE="$DOTFILES/packages/pacman.txt"
AUR_FILE="$DOTFILES/packages/aur.txt"
STOW_DIR="$DOTFILES/stow"

BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y-%m-%d_%H-%M-%S)"


# -----------------------------------------------------------------------------
# Output
# -----------------------------------------------------------------------------

info() {
    printf '\n==> %s\n' "$1"
}

die() {
    printf '\nerror: %s\n' "$1" >&2
    exit 1
}


# -----------------------------------------------------------------------------
# Checks
# -----------------------------------------------------------------------------

[[ -f /etc/arch-release ]] || die "This installer is intended for Arch Linux."

(( EUID != 0 )) || die "Run this script as your normal user, not as root."

[[ -f "$PACMAN_FILE" ]] || die "Missing packages/pacman.txt"
[[ -f "$AUR_FILE" ]] || die "Missing packages/aur.txt"
[[ -d "$STOW_DIR" ]] || die "Missing stow directory"


# -----------------------------------------------------------------------------
# Package lists
# -----------------------------------------------------------------------------

mapfile -t PACMAN_PACKAGES < <(
    awk 'NF && $1 !~ /^#/' "$PACMAN_FILE"
)

mapfile -t AUR_PACKAGES < <(
    awk 'NF && $1 !~ /^#/' "$AUR_FILE"
)


# -----------------------------------------------------------------------------
# Sudo
# -----------------------------------------------------------------------------

info "Requesting sudo access"
sudo -v


# -----------------------------------------------------------------------------
# Multilib
# -----------------------------------------------------------------------------

enable_multilib() {
    if grep -Eq '^[[:space:]]*\[multilib\]' /etc/pacman.conf; then
        info "multilib is already enabled"
        return
    fi

    info "Enabling multilib"

    sudo cp -n \
        /etc/pacman.conf \
        /etc/pacman.conf.hypr-dots.bak

    sudo sed -i \
        '/^[[:space:]]*#\[multilib\]/,/^[[:space:]]*#Include[[:space:]]*=[[:space:]]*\/etc\/pacman.d\/mirrorlist/ s/^[[:space:]]*#//' \
        /etc/pacman.conf

    grep -Eq '^[[:space:]]*\[multilib\]' /etc/pacman.conf \
        || die "Failed to enable multilib."
}

enable_multilib


# -----------------------------------------------------------------------------
# Official packages
# -----------------------------------------------------------------------------

info "Updating Arch Linux"
sudo pacman -Syu --noconfirm

info "Installing official packages"
sudo pacman -S \
    --needed \
    --noconfirm \
    "${PACMAN_PACKAGES[@]}"


# -----------------------------------------------------------------------------
# yay
# -----------------------------------------------------------------------------

install_yay() {
    if command -v yay >/dev/null 2>&1; then
        info "yay is already installed"
        return
    fi

    info "Installing yay"

    local build_dir
    build_dir="$(mktemp -d)"

    git clone \
        --depth 1 \
        https://aur.archlinux.org/yay.git \
        "$build_dir/yay"

    (
        cd "$build_dir/yay"
        makepkg -si --needed --noconfirm
    )

    rm -rf "$build_dir"
}

install_yay


# -----------------------------------------------------------------------------
# AUR packages
# -----------------------------------------------------------------------------

if (( ${#AUR_PACKAGES[@]} > 0 )); then
    info "Installing AUR packages"

    yay -S \
        --needed \
        --noconfirm \
        "${AUR_PACKAGES[@]}"
fi


# -----------------------------------------------------------------------------
# Backup conflicting dotfiles
# -----------------------------------------------------------------------------

backup_path() {
    local path="$1"
    local resolved
    local relative

    if [[ ! -e "$path" && ! -L "$path" ]]; then
        return
    fi

    resolved="$(readlink -f -- "$path" 2>/dev/null || true)"

    # Already managed by this repository
    if [[ "$resolved" == "$DOTFILES/"* ]]; then
        return
    fi

    relative="${path#"$HOME"/}"

    mkdir -p "$BACKUP_DIR/$(dirname -- "$relative")"

    info "Backing up $path"
    mv -- "$path" "$BACKUP_DIR/$relative"
}

backup_path "$HOME/.bashrc"
backup_path "$HOME/.bash_profile"
backup_path "$HOME/.blerc"
backup_path "$HOME/.vimrc"

backup_path "$HOME/.config/bash"
backup_path "$HOME/.config/kitty"
backup_path "$HOME/.config/fastfetch"
backup_path "$HOME/.config/hypr"
backup_path "$HOME/.config/rofi"
backup_path "$HOME/.config/waybar"

backup_path "$HOME/.local/bin/waybar-toggle"


# -----------------------------------------------------------------------------
# Stow
# -----------------------------------------------------------------------------

mapfile -t STOW_PACKAGES < <(
    find "$STOW_DIR" \
        -mindepth 1 \
        -maxdepth 1 \
        -type d \
        -printf '%f\n' |
    sort
)

info "Installing dotfiles with GNU Stow"

stow --no-folding \
    -d "$STOW_DIR" \
    -t "$HOME" \
    "${STOW_PACKAGES[@]}"


# -----------------------------------------------------------------------------
# Machine-specific Hyprland config
# -----------------------------------------------------------------------------

LOCAL_CONF="$HOME/.config/hypr/local.conf"
LOCAL_EXAMPLE="$HOME/.config/hypr/local.conf.example"

if [[ ! -e "$LOCAL_CONF" && -f "$LOCAL_EXAMPLE" ]]; then
    info "Creating generic Hyprland local.conf"
    cp "$LOCAL_EXAMPLE" "$LOCAL_CONF"
fi


# -----------------------------------------------------------------------------
# User directories
# -----------------------------------------------------------------------------

info "Creating standard user directories"
xdg-user-dirs-update


# -----------------------------------------------------------------------------
# Services
# -----------------------------------------------------------------------------

info "Enabling system services"

sudo systemctl enable --now NetworkManager.service
sudo systemctl enable --now bluetooth.service


# -----------------------------------------------------------------------------
# Shell
# -----------------------------------------------------------------------------

BASH_PATH="$(command -v bash)"
CURRENT_SHELL="$(getent passwd "$(id -un)" | cut -d: -f7)"

if [[ "$CURRENT_SHELL" != "$BASH_PATH" ]]; then
    info "Setting Bash as login shell"
    sudo usermod --shell "$BASH_PATH" "$(id -un)"
fi


# -----------------------------------------------------------------------------
# TTY login instead of display manager
# -----------------------------------------------------------------------------

info "Configuring TTY login"

for dm in sddm gdm lightdm; do
    if systemctl list-unit-files "$dm.service" 2>/dev/null |
        grep -q "^$dm.service"; then

        sudo systemctl disable "$dm.service" || true
    fi
done

sudo systemctl set-default multi-user.target


# -----------------------------------------------------------------------------
# Done
# -----------------------------------------------------------------------------

printf '\n'
printf '%s\n' '============================================================'
printf '%s\n' ' Installation complete'
printf '%s\n' '============================================================'
printf '\n'
printf '%s\n' 'Reboot, log in from the TTY, then run:'
printf '\n'
printf '%s\n' '    start-hyprland'
printf '\n'
