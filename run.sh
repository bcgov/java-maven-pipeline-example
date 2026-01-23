#!/usr/bin/env bash

# Exit on error
set -e

# Check arguments
if [ $# -lt 1 ]; then
  echo "Usage: $0 [docker|podman]"
  exit 1
fi

ENGINE=$1
shift

POM_PATH="./pom.xml"
IMAGE_NAME="java-maven-pipeline-example-image"
CONTAINER_NAME="java-maven-pipeline-example-app"
PORT=${PORT:-8080}

# Validate engine
if [[ "$ENGINE" != "docker" && "$ENGINE" != "podman" ]]; then
  echo "Error: ENGINE must be 'docker' or 'podman'"
  exit 1
fi

# Build command template
BUILD_CMD="$ENGINE build --build-arg PROJECT_DIR=\"$PROJECT_DIR\" \
  -f $PROJECT_DIR/.docker/runtime/Dockerfile \
  -t $IMAGE_NAME ."

# Run the build
echo "Running build with $ENGINE..."
eval "$BUILD_CMD"

echo "Build completed using $ENGINE."

# Run command template
RUN_CMD="$ENGINE run -d\
  -p ${PORT}:${PORT} \
  --name $CONTAINER_NAME \
  --replace \
  $IMAGE_NAME"

# Run app
echo "Running image '$IMAGE_NAME'..."
eval "$RUN_CMD"
