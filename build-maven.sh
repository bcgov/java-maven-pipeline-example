#!/usr/bin/env bash
set -euo pipefail

# Build main artifact
source env.sh build --skip-vault
./mvnw -DskipTests clean package
