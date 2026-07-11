#!/bin/bash
set -e

# Soadium OS ISO Builder
# Based on standard Ubuntu remastering process.
# Base image policy: always the latest STABLE point release of the Ubuntu LTS series.

# Load pinned stable versions
BUILDER_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$BUILDER_DIR/../versions.env"

# Configuration
WORKDIR="$(pwd)/work"
ISO_DIR="$WORKDIR/iso"
SQUASH_DIR="$WORKDIR/squashfs"
OUTPUT_DIR="$(pwd)/output"
UBUNTU_RELEASE_BASE="https://releases.ubuntu.com/$UBUNTU_LTS_SERIES"
UBUNTU_ISO_NAME="ubuntu-base.iso"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}=== Soadium OS Builder ===${NC}"

# Check for root (required for mounting/chroot)
if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}Please run as root (or in Docker)${NC}"
  exit 1
fi

# Ensure dependencies
echo -e "${GREEN}[*] Checking dependencies...${NC}"
apt-get update && apt-get install -y \
    squashfs-tools \
    xorriso \
    grub-pc-bin \
    grub-efi-amd64-bin \
    mtools \
    wget \
    curl \
    rsync

mkdir -p "$WORKDIR" "$OUTPUT_DIR"

# 1. Resolve & download the latest stable LTS point release
#    (releases.ubuntu.com only hosts the current point release, so the
#    filename changes over time - resolve it instead of hardcoding)
if [ ! -f "$WORKDIR/$UBUNTU_ISO_NAME" ]; then
    echo -e "${GREEN}[*] Resolving latest stable Ubuntu $UBUNTU_LTS_SERIES LTS point release...${NC}"
    ISO_FILE=$(curl -fsSL "$UBUNTU_RELEASE_BASE/SHA256SUMS" \
        | grep -oE "ubuntu-${UBUNTU_LTS_SERIES}[.0-9]*-desktop-amd64\.iso" \
        | sort -Vu | tail -n1)
    if [ -z "$ISO_FILE" ]; then
        echo -e "${RED}[!] Could not resolve latest point release, falling back to $UBUNTU_FALLBACK_POINT_RELEASE${NC}"
        ISO_FILE="ubuntu-${UBUNTU_FALLBACK_POINT_RELEASE}-desktop-amd64.iso"
    fi
    echo -e "${GREEN}[*] Downloading $ISO_FILE...${NC}"
    wget -O "$WORKDIR/$UBUNTU_ISO_NAME" "$UBUNTU_RELEASE_BASE/$ISO_FILE"

    # Verify checksum against the official stable release manifest
    echo -e "${GREEN}[*] Verifying ISO checksum...${NC}"
    EXPECTED_SHA=$(curl -fsSL "$UBUNTU_RELEASE_BASE/SHA256SUMS" | grep "$ISO_FILE" | awk '{print $1}' | head -n1)
    if [ -n "$EXPECTED_SHA" ]; then
        ACTUAL_SHA=$(sha256sum "$WORKDIR/$UBUNTU_ISO_NAME" | awk '{print $1}')
        if [ "$EXPECTED_SHA" != "$ACTUAL_SHA" ]; then
            echo -e "${RED}[!] Checksum mismatch! Aborting.${NC}"
            rm -f "$WORKDIR/$UBUNTU_ISO_NAME"
            exit 1
        fi
        echo -e "${GREEN}[*] Checksum OK.${NC}"
    fi
else
    echo -e "${GREEN}[*] Base ISO found.${NC}"
fi

# 2. Extract ISO
echo -e "${GREEN}[*] Extracting ISO contents...${NC}"
mkdir -p "$ISO_DIR"
xorriso -osirrox on -indev "$WORKDIR/$UBUNTU_ISO_NAME" -extract / "$ISO_DIR"

# 3. Extract Filesystem (SquashFS)
echo -e "${GREEN}[*] Unpacking SquashFS (Root Filesystem)...${NC}"
mkdir -p "$SQUASH_DIR"
unsquashfs -f -d "$SQUASH_DIR" "$ISO_DIR/casper/filesystem.squashfs"

# 4. Customization (Chroot)
echo -e "${GREEN}[*] Entering Chroot for Customization...${NC}"

# Copy resolv.conf for networking inside the chroot
cp /etc/resolv.conf "$SQUASH_DIR/etc/"

# Copy Soadium Profile Resources
echo -e "${GREEN}[*] Injecting Soadium resources...${NC}"
cp -r profile/filesystem/* "$SQUASH_DIR/" 2>/dev/null || true

# Bind mounts
mount --bind /dev "$SQUASH_DIR/dev"
mount --bind /run "$SQUASH_DIR/run"

chroot "$SQUASH_DIR" /bin/bash <<EOF
set -e
export HOME=/root
export LC_ALL=C
export DEBIAN_FRONTEND=noninteractive

echo "--- In Chroot ---"

# Update repos and pull latest stable LTS package updates
apt-get update
apt-get upgrade -y

# Install Calamares (Installer)
apt-get install -y calamares calamares-settings-ubuntu

# Install Soadium Core Developer Stack (Ubuntu LTS stable packages)
apt-get install -y \
    git curl wget vim zsh tmux htop jq tree unzip \
    build-essential pkg-config \
    python3 python3-pip python3-venv pipx \
    gnome-tweaks gnome-shell-extension-manager \
    ufw

# Clean up
apt-get autoremove -y
apt-get clean
rm -rf /tmp/* /root/.bash_history

exit
EOF

# Unmount & remove the injected resolv.conf
umount "$SQUASH_DIR/dev"
umount "$SQUASH_DIR/run"
rm -f "$SQUASH_DIR/etc/resolv.conf"

# 5. Rebuild SquashFS
echo -e "${GREEN}[*] Repacking SquashFS...${NC}"
chmod +w "$ISO_DIR/casper/filesystem.manifest" || true
chroot "$SQUASH_DIR" dpkg-query -W --showformat='${Package} ${Version}\n' > "$ISO_DIR/casper/filesystem.manifest"
printf '%s' "$(du -sx --block-size=1 "$SQUASH_DIR" | cut -f1)" > "$ISO_DIR/casper/filesystem.size"
rm "$ISO_DIR/casper/filesystem.squashfs"
mksquashfs "$SQUASH_DIR" "$ISO_DIR/casper/filesystem.squashfs" -comp xz -b 1M

# 6. Generate ISO
echo -e "${GREEN}[*] Generating Soadium ISO...${NC}"
grub-mkrescue -o "$OUTPUT_DIR/soadium-os.iso" "$ISO_DIR"

echo -e "${GREEN}[SUCCESS] ISO Built: $OUTPUT_DIR/soadium-os.iso${NC}"
