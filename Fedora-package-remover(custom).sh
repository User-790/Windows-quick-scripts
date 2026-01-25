#!/usr/bin/env bash

# ================================
#  Unwanted applications list
#  Add or remove package names here
# ================================
UNWANTED_PACKAGES=(
    libreoffice*
    rhythmbox
    cheese
    gnome-weather
    gnome-contacts
    gnome-maps
    gnome-calculator
    gnome-help
    gnome-tour
    gnome-connections
    gnome-boxes
    malcontent-control
)

# Optional: Flatpaks to remove
UNWANTED_FLATPAKS=(
    org.gnome.Weather
    org.gnome.Maps
    org.gnome.Contacts
    org.gnome.Calculator
    org.gnome.Cheese
)

DRY_RUN=false

# Enable dry-run mode
if [[ "$1" == "--dry-run" ]]; then
    DRY_RUN=true
    echo "[DRY RUN] No changes will be made."
fi

remove_item() {
    local cmd="$1"
    local item="$2"

    if $DRY_RUN; then
        echo "[DRY RUN] Would remove: $item"
    else
        echo "Removing: $item"
        eval "$cmd"
    fi
}

echo "Starting removal of unwanted applications..."

# ================================
#  RPM package removal
# ================================
for pkg in "${UNWANTED_PACKAGES[@]}"; do
    if rpm -q $pkg &>/dev/null; then
        remove_item "sudo dnf remove -y $pkg" "$pkg"
    else
        echo "Not installed (skipped): $pkg"
    fi
done

# ================================
#  Flatpak removal
# ================================
if command -v flatpak &>/dev/null; then
    echo "Checking Flatpaks..."
    for fp in "${UNWANTED_FLATPAKS[@]}"; do
        if flatpak list --app | grep -q "$fp"; then
            remove_item "flatpak uninstall -y $fp" "$fp"
        else
            echo "Not installed (skipped): $fp"
        fi
    done
fi

echo "Cleanup complete."

