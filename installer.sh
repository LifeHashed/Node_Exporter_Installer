#!/bin/bash

set -e

VERSION=""
LATEST_VERSION=""
MODE="install"

# ---------------------------
# Parse arguments
# ---------------------------
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --version)
            VERSION="$2"
            shift
            ;;
        --latest)
            MODE="install"
            ;;
        --uninstall)
            MODE="uninstall"
            ;;
        *)
            echo "Unknown option: $1"
            echo "Usage:"
            echo "  --latest                Install latest version (default)"
            echo "  --version <tag>         Install specific version (e.g. v1.7.0)"
            echo "  --uninstall             Remove Node Exporter"
            exit 1
            ;;
    esac
    shift
done

# ---------------------------
# Uninstall Mode
# ---------------------------
if [[ "$MODE" == "uninstall" ]]; then
    echo "Stopping Node Exporter..."
    systemctl stop node_exporter || true
    systemctl disable node_exporter || true

    echo "Removing systemd service..."
    rm -f /etc/systemd/system/node_exporter.service
    systemctl daemon-reload

    echo "Removing binary..."
    rm -f /usr/local/bin/node_exporter

    echo "Removing user..."
    userdel node_exporter || true

    echo "Cleaning up files..."
    rm -rf *node_exporter*

    echo "Node Exporter uninstalled successfully."
    exit 0
fi

# ---------------------------
# Install Mode
# ---------------------------
if [[ -z "$VERSION" ]]; then
    echo "Fetching latest version..."
    LATEST_VERSION=$(curl -s https://api.github.com/repos/prometheus/node_exporter/releases/latest \
        | grep tag_name | cut -d '"' -f 4)

    VERSION="$LATEST_VERSION"
fi

echo "Installing Node Exporter version: $VERSION"

FILE="node_exporter-${VERSION#v}.linux-amd64.tar.gz"
URL="https://github.com/prometheus/node_exporter/releases/download/${VERSION}/${FILE}"

# Create user
useradd -rs /bin/false node_exporter 2>/dev/null || true

echo "Downloading Node Exporter..."
curl -LO "$URL"

echo "Extracting..."
tar -xvf "$FILE"
mv "node_exporter-${VERSION#v}.linux-amd64/node_exporter" /usr/local/bin/

chmod +x /usr/local/bin/node_exporter

echo "Creating systemd service..."
cat <<EOF > /etc/systemd/system/node_exporter.service
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=default.target
EOF

systemctl daemon-reload
systemctl enable node_exporter
systemctl restart node_exporter

echo "Node Exporter installation completed."
echo "Service status:"
systemctl status node_exporter --no-pager
