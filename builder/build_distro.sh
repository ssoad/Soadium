#!/bin/bash
set -e

# Soadium OS ISO Builder
# Based on standard Ubuntu remastering process

# Configuration
WORKDIR="$(pwd)/work"
ISO_DIR="$WORKDIR/iso"
SQUASH_DIR="$WORKDIR/squashfs"
OUTPUT_DIR="$(pwd)/output"
UBUNTU_ISO_URL="https://releases.ubuntu.com/24.04/ubuntu-24.04-desktop-amd64.iso"
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
    rsync

mkdir -p "$WORKDIR" "$OUTPUT_DIR"

# 1. Download Base ISO
if [ ! -f "$WORKDIR/$UBUNTU_ISO_NAME" ]; then
    echo -e "${GREEN}[*] Downloading Ubuntu 24.04 Base...${NC}"
    wget -O "$WORKDIR/$UBUNTU_ISO_NAME" "$UBUNTU_ISO_URL"
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

# Copy resolu.conf for networking
cp /etc/resolv.conf "$SQUASH_DIR/etc/"

# Copy Soadium Profile Resources
echo -e "${GREEN}[*] Injecting Soadium resources...${NC}"
cp -r profile/filesystem/* "$SQUASH_DIR/" 2>/dev/null || true

# Bind mounts
mount --bind /dev "$SQUASH_DIR/dev"
mount --bind /run "$SQUASH_DIR/run"

chroot "$SQUASH_DIR" /bin/bash <<EOF
export HOME=/root
export LC_ALL=C
export DEBIAN_FRONTEND=noninteractive

echo "--- In Chroot ---"

# Update Repos
apt-get update

# Install Calamares (Installer)
apt-get install -y calamares calamares-settings-ubuntu

# Install Soadium Core Stack
# (Add your package list here)
apt-get install -y git curl wget vim gnome-tweaks

# Clean up
apt-get clean
rm -rf /tmp/* ~/.bash_history

exit
EOF

# Unmount
umount "$SQUASH_DIR/dev"
umount "$SQUASH_DIR/run"

# 5. Rebuild SquashFS
echo -e "${GREEN}[*] Repacking SquashFS...${NC}"
chmod +w "$ISO_DIR/casper/filesystem.manifest"
chroot "$SQUASH_DIR" dpkg-query -W --showformat='${Package} ${Version}\n' > "$ISO_DIR/casper/filesystem.manifest"
rm "$ISO_DIR/casper/filesystem.squashfs"
mksquashfs "$SQUASH_DIR" "$ISO_DIR/casper/filesystem.squashfs" -comp xy -b 1M

# 6. Generate ISO
echo -e "${GREEN}[*] Generating Soadium ISO...${NC}"
grub-mkrescue -o "$OUTPUT_DIR/soadium-os.iso" "$ISO_DIR"

echo -e "${GREEN}[SUCCESS] ISO Built: $OUTPUT_DIR/soadium-os.iso${NC}"
