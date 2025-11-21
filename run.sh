#!/usr/bin/env bash

# Exit on error
set -e

# Check arguments
if [ $# -lt 1 ]; then
  echo "Usage: $0 [docker|podman]"
  exit 1
fi

ENGINE=$1
IMAGE_NAME="myapp"
PORT=${PORT:-8080}

# Validate engine
if [[ "$ENGINE" != "docker" && "$ENGINE" != "podman" ]]; then
  echo "Error: ENGINE must be 'docker' or 'podman'"
  exit 1
fi

# Build command template
BUILD_CMD="$ENGINE build \
  -f .docker/runtime/Dockerfile \
  -t myapp ."

# Run the build
echo "Running build with $ENGINE..."
eval "$BUILD_CMD"

echo "Build completed using $ENGINE."

# Run command template
RUN_CMD="$ENGINE run -d\
  -p ${PORT}:${PORT} \
  --name myapp \
  --replace \
  myapp"

# Run app
echo "Running image '$IMAGE_NAME'..."
eval "$RUN_CMD"
