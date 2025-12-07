#!/usr/bin/env bash
set -euo pipefail

IMAGE="$1"           # e.g. yourrepo/resume-site:abc12345
CONTAINER_NAME="resume-site"
PORT="80"

# Pull the new image
docker pull "$IMAGE"

# Stop and remove existing container if exists
if docker ps -a --format '{{.Names}}' | grep -qw "$CONTAINER_NAME"; then
  docker rm -f "$CONTAINER_NAME" || true
fi

# Run the new container
docker run -d --name "$CONTAINER_NAME" -p ${PORT}:80 --restart unless-stopped "$IMAGE"

# Clean up unused images
docker image prune -f

echo "Deployed $IMAGE"
