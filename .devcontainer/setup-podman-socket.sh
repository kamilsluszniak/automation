#!/bin/bash
# Create a Docker-compatible socket for Podman
# This allows Cursor/VS Code to use Podman as if it were Docker

PODMAN_SOCK="/run/user/$(id -u)/podman/podman.sock"
DOCKER_SOCK="/var/run/docker.sock"

# Check if Podman socket exists
if [ ! -S "$PODMAN_SOCK" ]; then
    echo "Error: Podman socket not found at $PODMAN_SOCK"
    echo "Please start Podman socket: systemctl --user start podman.socket"
    exit 1
fi

# Create Docker socket directory if it doesn't exist
if [ ! -d "$(dirname $DOCKER_SOCK)" ]; then
    echo "Creating /var/run directory..."
    sudo mkdir -p /var/run
fi

# Create symlink (requires sudo for /var/run)
if [ -e "$DOCKER_SOCK" ]; then
    if [ -L "$DOCKER_SOCK" ]; then
        CURRENT_LINK=$(readlink "$DOCKER_SOCK")
        if [ "$CURRENT_LINK" = "$PODMAN_SOCK" ]; then
            echo "Docker socket is already correctly linked to Podman socket!"
            exit 0
        else
            echo "Removing existing symlink (points to: $CURRENT_LINK)..."
            sudo rm "$DOCKER_SOCK"
        fi
    else
        echo "Removing existing socket/file at $DOCKER_SOCK..."
        sudo rm "$DOCKER_SOCK"
    fi
fi

echo "Creating Docker socket symlink to Podman socket..."
sudo ln -s "$PODMAN_SOCK" "$DOCKER_SOCK"
echo "Socket created successfully!"

echo ""
echo "You can now use Cursor devcontainers with Podman!"
echo "Try reopening the folder in container."
