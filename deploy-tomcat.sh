#!/bin/bash

ENGINE=${1:-podman}
IMAGE_NAME="java-maven-tomcat-local"
CONTAINER_NAME="java-maven-app"

# Source the secrets from Vault into the current shell memory
if [ -f "./.setenv.sh" ]; then
    source ./.setenv.sh
else
    echo "Error: setenv.sh not found. Cannot retrieve secrets."
    exit 1
fi

# Clean up old container and image
echo "🧹 Cleaning up old containers and images..."
$ENGINE stop $CONTAINER_NAME 2>/dev/null || true
$ENGINE rm $CONTAINER_NAME 2>/dev/null || true
$ENGINE rmi $IMAGE_NAME 2>/dev/null || true

echo "Preparing Local Tomcat Environment..."

# Build the image
echo "Building container image..."
if ! $ENGINE build -f Dockerfile.maven -t $IMAGE_NAME  .; then
    echo "Error: Failed to build container image"
    exit 1
fi
echo "✓ Image built successfully"

# Run the container
echo "Starting container..."
if ! $ENGINE run -d \
  --name $CONTAINER_NAME \
  -v $(pwd)/target:/app/target:Z \
  -e WAR_SOURCE=local \
  -p 8080:8080 \
  --env-file <(env) \
  $IMAGE_NAME; then
    echo "Error: Failed to start container"
    exit 1
fi
# -v $(pwd)/target:/app/target:Z \
# -e WAR_SOURCE=local \
echo ""
echo "✓ Container started successfully"
echo "  Access the application at: http://localhost:8080"
echo "  View logs: $ENGINE logs -f $CONTAINER_NAME"
echo "  Stop container: $ENGINE stop $CONTAINER_NAME"