#!/usr/bin/env bash
set -euo pipefail

# Interactive helper to build the Maven artifact, package it for ORAS,
# create annotations, and optionally preview or run ORAS push/pull.

REPO_ROOT=$(cd "$(dirname "$0")/.." && pwd)
cd "$REPO_ROOT"

echo "Starting ORAS local test helper in: $REPO_ROOT"

# Portable prompt helpers that work in bash and zsh
prompt_read() {
  # $1 = variable name, $2 = prompt
  local _var="$1"
  local _prompt="$2"
  printf "%s" "${_prompt}"
  # shellcheck disable=SC2162
  IFS= read -r "${_var}"
}

prompt_read_secret() {
  # $1 = variable name, $2 = prompt
  local _var="$1"
  local _prompt="$2"
  printf "%s" "${_prompt}"
  stty -echo || true
  # shellcheck disable=SC2162
  IFS= read -r "${_var}" || true
  stty echo || true
  printf "\n"
}

# Validate basic files
if [ ! -f ./env.sh ]; then
  echo "env.sh not found in repo root"
  exit 1
fi
if [ ! -x ./mvnw ]; then
  echo "mvnw wrapper not found or not executable"
  exit 1
fi

echo "Sourcing env.sh (build mode, --skip-vault)..."
# shellcheck disable=SC1091
source ./env.sh build ./ --skip-vault

echo "Building package (tests skipped)..."
./mvnw --batch-mode -Dmaven.test.skip=true clean package

ARTIFACT_ID=$(mvn help:evaluate -Dexpression=project.artifactId -q -DforceStdout --file ./pom.xml)
PACKAGING=$(mvn help:evaluate -Dexpression=project.packaging -q -DforceStdout --file ./pom.xml)
PROJECT_VERSION="${VERSION}"

ARTIFACT_FILE="target/${ARTIFACT_ID}-${PROJECT_VERSION}.${PACKAGING}"
if [ ! -f "$ARTIFACT_FILE" ]; then
  echo "Expected artifact not found: $ARTIFACT_FILE"
  ls -al target || true
  exit 1
fi

TAR_NAME="${ARTIFACT_ID}-${PROJECT_VERSION}.tar.gz"
echo "Creating tarball: $TAR_NAME"
tar -C target -czf "$TAR_NAME" "$(basename "$ARTIFACT_FILE")"

echo
echo "Tarball created:"
ls -lh "$TAR_NAME"
echo "Contents:"
tar -tzf "$TAR_NAME"
echo "Checksum:"; sha256sum "$TAR_NAME" || true
echo "Size (bytes):"; stat -c%s "$TAR_NAME" || true

# Create annotation.json (prefer jq if available)
REPO_URL="https://github.com/bcgov/java-maven-pipeline-example"
if command -v jq >/dev/null 2>&1; then
  jq -n --arg id "$ARTIFACT_ID" --arg v "$PROJECT_VERSION" --arg src "$REPO_URL" '{
    "$manifest": {
      "org.opencontainers.image.description": ("Build artifact for " + $id + " version " + $v),
      "org.opencontainers.image.licenses": "Apache-2.0",
      "org.opencontainers.image.source": $src,
      "org.opencontainers.image.title": ($id + "-artifact"),
      "org.opencontainers.image.version": $v
    }
  }' > annotation.json
  echo "annotation.json created via jq"
else
  printf '{"$manifest": {"org.opencontainers.image.description": "Build artifact for %s version %s", "org.opencontainers.image.licenses": "Apache-2.0", "org.opencontainers.image.source": "%s", "org.opencontainers.image.title": "%s-artifact", "org.opencontainers.image.version": "%s"}}\n' "$ARTIFACT_ID" "$PROJECT_VERSION" "$REPO_URL" "$ARTIFACT_ID" "$PROJECT_VERSION" > annotation.json
  echo "annotation.json created (no jq)"
fi

echo
prompt_read GHCR_USER "Enter your GitHub user: "
prompt_read_secret GHCR_TOKEN "Enter your GitHub Token: "

if command -v oras >/dev/null 2>&1; then
  echo "Logging in to ghcr.io (token is read from stdin)..."
  if ! printf "%s" "$GHCR_TOKEN" | oras login ghcr.io -u "$GHCR_USER" --password-stdin; then
    echo "Warning: ORAS login failed or ORAS not configured to accept the token"
  else
    echo "Login succeeded"
  fi
else
  echo "oras CLI not found in PATH. Install ORAS to push/pull artifacts." 
fi

unset GHCR_TOKEN || true

ORAS_REPO="ghcr.io/bcgov/java-maven-pipeline-example"
PROJECT_TAG="$PROJECT_VERSION"

# Ensure artifacts directory exists and will be ignored by git
mkdir -p artifacts

MANIFEST_FILE="artifacts/${ARTIFACT_ID}-${PROJECT_VERSION}-manifest.json"

echo
echo "Preview ORAS push command (no automatic push):"
echo "oras push --annotation-file annotation.json --export-manifest ${MANIFEST_FILE} ${ORAS_REPO}/package:${PROJECT_TAG} ${TAR_NAME}"

prompt_read RUN_PUSH "Do you want to run the push now? (y/N) "
if printf "%s" "$RUN_PUSH" | grep -Eiq "^([yY][eE][sS]|[yY])$"; then
  if command -v oras >/dev/null 2>&1; then
    oras push --annotation-file annotation.json --export-manifest "${MANIFEST_FILE}" ${ORAS_REPO}/package:${PROJECT_TAG} ${TAR_NAME}
    echo "Push complete. Manifest written to ${MANIFEST_FILE}."
  else
    echo "oras not installed; cannot push."
  fi
fi

prompt_read RUN_PULL "Do you want to pull the pushed artifact to ./artifact-out to verify? (y/N) "
if printf "%s" "$RUN_PULL" | grep -Eiq "^([yY][eE][sS]|[yY])$"; then
  mkdir -p artifact-out
  if command -v oras >/dev/null 2>&1; then
    oras pull --output ./artifact-out ${ORAS_REPO}/package:${PROJECT_TAG}
    echo "Pulled to ./artifact-out"
    ls -la artifact-out
  else
    echo "oras not installed; cannot pull."
  fi
fi

echo "Done."
