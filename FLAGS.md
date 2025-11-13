# Installer Flags & Usage

This document describes the command-line flags supported by the `installer.sh` script in this repository and explains their behavior, examples, and important safety notes.

## Supported Flags

- `--latest`
  - Description: Install the latest released Node Exporter from the Prometheus GitHub releases. This is the default behavior if no flags are supplied.
  - Behavior: The script fetches the latest release tag via the GitHub API (`https://api.github.com/repos/prometheus/node_exporter/releases/latest`), constructs the release tarball filename for `linux-amd64`, downloads it, extracts the `node_exporter` binary to `/usr/local/bin/`, creates a `node_exporter` system user, writes a `systemd` unit at `/etc/systemd/system/node_exporter.service`, enables and restarts the service.
  - Example:

```bash
sudo node_exporter_installer --latest
```

- `--version <tag>`
  - Description: Install a specific release by tag. Example tag format: `v1.7.0`.
  - Behavior: The supplied `<tag>` is used as the version (the script sets `VERSION` to this value). The script expects the GitHub release asset to follow the naming scheme `node_exporter-<version_without_v>.linux-amd64.tar.gz` (the script strips a leading `v` from the tag when building the filename).
  - Example:

```bash
sudo node_exporter_installer --version v1.7.0
```

- `--uninstall`
  - Description: Remove Node Exporter that was installed by the script.
  - Behavior: Stops and disables the `node_exporter` service (if present), removes the service file `/etc/systemd/system/node_exporter.service`, reloads systemd, removes the binary at `/usr/local/bin/node_exporter`, attempts to remove the `node_exporter` user, and runs `rm -rf *node_exporter*` in the current directory as a cleanup step.
  - Example:

```bash
sudo node_exporter_installer --uninstall
```

## Default / No-arg Behavior

Running the installer with no flags is equivalent to `--latest`:

```bash
sudo node_exporter_installer
```

## Important Notes & Implementation Details

- Run as root: The installer performs system-level operations (creating users, writing to `/usr/local/bin`, creating systemd units). Run with `sudo` or as `root`.
- Dependencies: the script uses `curl`, `tar`, `useradd`, and `systemctl`. Ensure those are available on the host.
- Architecture: the script specifically downloads the `linux-amd64` release asset. It does not detect or support other architectures.
- Version tag handling: when you pass `--version vX.Y.Z`, the script strips the leading `v` to build filenames (e.g., `v1.7.0` -> `1.7.0`).
- Failure mode: the script uses `set -e` and exits on the first failing command. If a download or extraction fails the script will abort.
- Service name & port: created systemd unit is named `node_exporter` and the exporter listens on its default port `9100`.

## Safety Warnings

- The uninstall path runs `rm -rf *node_exporter*` in the current working directory. This can be dangerous if run from the wrong directory — double-check your working directory before running `--uninstall`.
- The script tries to remove the `node_exporter` user (`userdel node_exporter`) and ignores errors; ensure that removing that user is acceptable on the target system.
- Review the `installer.sh` script before running it on production systems. It's recommended to test on a disposable VM or container with `systemd` available.

## Quick Examples

- Download the `.deb` from a release and install the package (example release asset name used by this repo):

```bash
wget https://github.com/LifeHashed/Node_Exporter_Installer/releases/download/v.1.0/node-exporter-installer_1.0.deb
sudo apt install ./node-exporter-installer_1.0.deb -y
```

- Install latest Node Exporter after package installation:

```bash
sudo node_exporter_installer --latest
curl http://localhost:9100/metrics
```

## Troubleshooting

- If the installer fails while fetching a release, try fetching the `VERSION` by hand:

```bash
curl -s https://api.github.com/repos/prometheus/node_exporter/releases/latest | grep tag_name
```

- If systemd fails to start the service, inspect logs:

```bash
sudo journalctl -u node_exporter -b --no-pager
sudo systemctl status node_exporter --no-pager
```

## Want the flags in `README.md`?

If you'd like, I can add a short “Flags” section into `README.md` that links to this `FLAGS.md` or copy the brief flag descriptions inline.
