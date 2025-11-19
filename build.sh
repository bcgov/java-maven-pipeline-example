#!/usr/bin/env bash

# Exit on error
set -e

# Check arguments
if [ $# -lt 1 ]; then
  echo "Usage: $0 [docker|podman]"
  exit 1
fi

# Source environment variables
source .docker/setenv.sh

ENGINE=$1
MAVEN_IMAGE=maven:3.9.11-amazoncorretto-17

# Validate engine
if [[ "$ENGINE" != "docker" && "$ENGINE" != "podman" ]]; then
  echo "Error: ENGINE must be 'docker' or 'podman'"
  exit 1
fi

# Build command template
BUILD_CMD="$ENGINE run --rm \
  -v ${PWD}:/workspace \
  -w /workspace \
  -v $(pwd)/.github/polaris-maven-settings.xml:/root/.m2/settings.xml:ro \
  -e ARTIFACTORY_USERNAME=${ARTIFACTORY_USERNAME} \
  -e ARTIFACTORY_PASSWORD=${ARTIFACTORY_PASSWORD} \
  ${MAVEN_IMAGE} \
  mvn -B -DskipTests package"

# Run the build
echo "Running build with $ENGINE..."
eval "$BUILD_CMD"

echo "Build completed using $ENGINE."
