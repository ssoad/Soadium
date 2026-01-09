# Soadium OS

**Soadium OS** is a premium, developer-focused Linux experience based on Ubuntu. It provides a polished GNOME desktop interface, pre-configured AI/Dev tools, and a distinct visual identity.

Soadium works in two ways:
1.  **Soadium OS (Distro)**: A standalone, bootable OS (ISO) that installs Soadium from scratch.
2.  **Soadium Overlay**: An installation script that transforms an existing Ubuntu setup into Soadium.

---

## 🚀 Getting Started

### Option A: Standalone Installer (Overlay)
Transform any existing Ubuntu 24.04+ installation into Soadium OS.

1.  **Clone the repository**:
    ```bash
    git clone https://github.com/ssoad/Soadium.git
    cd Soadium
    ```
2.  **Run the Installer**:
    ```bash
    chmod +x install.sh
    sudo ./install.sh
    ```
3.  **Reboot** to finalize changes.

### Option B: Build Custom ISO (Distro)
Generate a bootable `soadium-os.iso` to install on bare metal. Ideally run this via Docker to ensure a clean build environment.

1.  **Build the Builder Image**:
    ```bash
    docker build -t soadium-builder .
    ```

2.  **Run the Build**:
    (Requires privileged mode to mount filesystems)
    ```bash
    mkdir -p output
    docker run --privileged -v $(pwd)/output:/soadium/output soadium-builder
    ```

3.  **Result**:
    - The new ISO will be located at `output/soadium-os.iso`.
    - Flash this to a USB using Etcher or similar tools.

---

## 🛠 Project Structure

- **`install.sh`**: The "Overlay" installer script for existing systems.
- **`builder/`**: Logic for unpacking/repacking the Ubuntu ISO.
    - `build_distro.sh`: Main remastering script.
- **`profile/`**: The "Concept" of the OS. Files here are injected into the ISO.
    - `filesystem/`: Overlays for `/etc`, `/usr`, etc.
- **`resources/`**: Configuration assets.
    - `calamares/`: Settings for the OS installer GUI.
- **`scripts/`**: core setup logic used by both the Overlay and Distro builder.
    - `0_privacy.sh`: Disables telemetry.
    - `1_dev_ai.sh`: Installs VS Code, Docker, Ollama.
    - `2_ui.sh`: Sets up themes and fonts.

## ✨ Features
- **Base**: Ubuntu 24.04 LTS (Noble Numbat).
- **Desktop**: GNOME 46 with custom "Glassmorphism" theme.
- **Dev Stack**: VS Code, Docker, Python, Node.js (pre-installed).
- **AI Stack**: Local LLM runtime (Ollama) ready to go.
- **Privacy**: Canonical telemetry disabled by default.

---
*Built with ❤️ by ssoad*
