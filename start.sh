#!/usr/bin/env bash
set -euo pipefail

# Accept image from $1 (passed by GitHub Actions) or IMAGE env
IMAGE="${1:-${IMAGE:-}}"

# Trim leading/trailing whitespace (portable)
IMAGE="$(printf '%s' "$IMAGE" | awk '{$1=$1;print}')"

# Show exactly what we'll deploy
printf 'Deploying image: [%s]\n' "$IMAGE"

# Validate non-empty
if [ -z "$IMAGE" ]; then
  echo "FATAL: no image supplied. Usage: $0 <image> OR set IMAGE env var."
  exit 2
fi

# Basic sanity check for docker image reference
if ! printf '%s' "$IMAGE" | grep -Eq '^([a-z0-9]+(\.[a-z0-9]+)?(:[0-9]+)?/)?[A-Za-z0-9._/-]+([:@][A-Za-z0-9._:-]+)?$'; then
  echo "FATAL: image appears invalid: [$IMAGE]"
  exit 3
fi

CONTAINER_NAME="resume-site"
PORT="80"

echo "Pulling image: [$IMAGE]"
docker pull "$IMAGE"

# Stop and remove existing container if it exists
if docker ps -a --format '{{.Names}}' | grep -qw "$CONTAINER_NAME"; then
  echo "Stopping and removing existing container: $CONTAINER_NAME"
  docker rm -f "$CONTAINER_NAME" || true
fi

# Run the new container, mapping remote port 80 to container port 80
echo "Running container $CONTAINER_NAME on port ${PORT}->80"
docker run -d \
  --name "$CONTAINER_NAME" \
  -p ${PORT}:80 \
  --restart unless-stopped \
  "$IMAGE"

# Clean up unused images to save disk space
echo "Cleaning up old images."
docker image prune -f || true

echo "Deployed $IMAGE successfully via start.sh"