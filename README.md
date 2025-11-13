# Node Exporter Installer

Small installer/uninstaller script for Prometheus Node Exporter.

Files
- [installer.sh](installer.sh) — main installer script. Key symbols: [`VERSION`](installer.sh), [`LATEST_VERSION`](installer.sh), [`MODE`](installer.sh).
- [temp.txt](temp.txt) — helper packaging / SCP commands used by the maintainer.

Requirements
- Linux systemd-based distro
- curl, tar, useradd, systemctl
- Run as root (or via sudo)

Overview
The script in [installer.sh](installer.sh) supports:
- Installing the latest release from GitHub (default)
- Installing a specific Git tag via `--version <tag>`
- Uninstalling the installed Node Exporter via `--uninstall`

Usage
- Install latest (default):
  sudo bash installer.sh
  or
  sudo bash installer.sh --latest

- Install a specific version (example):
  sudo bash installer.sh --version v1.7.0

- Uninstall:
  sudo bash installer.sh --uninstall

What the script does
- Determines the version to install using the [`VERSION`](installer.sh) / [`LATEST_VERSION`](installer.sh) variables.
- Downloads the release tarball from GitHub and extracts the `node_exporter` binary to `/usr/local/bin/`.
- Creates a systemd service at `/etc/systemd/system/node_exporter.service` and enables & starts the service.
- Creates a dedicated `node_exporter` user (system user).
- On uninstall, stops & disables the service, removes the binary, user, and service file (see `--uninstall` in [installer.sh](installer.sh)).

Notes & safety
- The script uses `set -e` and will exit on failures.
- The script runs system-level operations; review [installer.sh](installer.sh) before running.
- The script removes files using patterns (e.g., `rm -rf *node_exporter*`) during uninstall — verify you are in the intended working directory before running uninstall.

Quick checks
- Service status: sudo systemctl status node_exporter --no-pager
- Logs: sudo journalctl -u node_exporter -f
