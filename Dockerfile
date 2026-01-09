FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# Install build dependencies
RUN apt-get update && apt-get install -y \
    squashfs-tools \
    xorriso \
    grub-pc-bin \
    grub-efi-amd64-bin \
    mtools \
    wget \
    git \
    curl \
    rsync \
    sudo \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /soadium
COPY . /soadium

# Make builder executable
RUN chmod +x builder/build_distro.sh

CMD ["./builder/build_distro.sh"]
