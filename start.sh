#!/usr/bin/env bash
set -euo pipefail

# Accept image from $1 or IMAGE env
IMAGE="${1:-${IMAGE:-}}"

# trim leading/trailing whitespace (portable)
IMAGE="$(printf '%s' "$IMAGE" | awk '{$1=$1;print}')"

# show exactly what we'll deploy
printf 'Deploying image: [%s]\n' "$IMAGE"

# Validate non-empty
if [ -z "$IMAGE" ]; then
  echo "FATAL: no image supplied. Usage: $0 <image>  OR set IMAGE env var."
  exit 2
fi

# Basic sanity check for docker image reference (permissive heuristic)
if ! printf '%s' "$IMAGE" | grep -Eq '^([a-z0-9]+(\.[a-z0-9]+)?(:[0-9]+)?/)?[A-Za-z0-9._/-]+([:@][A-Za-z0-9._:-]+)?$'; then
  echo "FATAL: image appears invalid: [$IMAGE]"
  exit 3
fi

CONTAINER_NAME="resume-site"
PORT="80"

echo "Pulling image: [$IMAGE]"
docker pull "$IMAGE"

# Stop and remove existing container if exists
if docker ps -a --format '{{.Names}}' | grep -qw "$CONTAINER_NAME"; then
  echo "Stopping and removing existing container: $CONTAINER_NAME"
  docker rm -f "$CONTAINER_NAME" || true
fi

# Run the new container
echo "Running container $CONTAINER_NAME on port ${PORT}->80"
docker run -d --name "$CONTAINER_NAME" -p ${PORT}:80 --restart unless-stopped "$IMAGE"

# Clean up unused images
docker image prune -f || true

echo "Deployed $IMAGE"

