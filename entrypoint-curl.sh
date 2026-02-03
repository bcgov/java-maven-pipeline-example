#!/bin/bash
set -e

echo "Starting deployment setup..."

# Default to github if not set
WAR_SOURCE="${WAR_SOURCE:-github}"
WAR_PATH="/tmp/app.war"

if [ "$WAR_SOURCE" = "local" ]; then
  echo "Using local WAR from target/ folder."
  LOCAL_WAR=$(ls /app/target/*.war 2>/dev/null | head -1)
  if [ -z "$LOCAL_WAR" ]; then
    echo "Error: No WAR file found in target/ folder."
    exit 1
  fi
  cp "$LOCAL_WAR" "$WAR_PATH"
  echo "✓ WAR file copied from $LOCAL_WAR ($(du -h "$WAR_PATH" | cut -f1))"
else
  echo "Using WAR from GitHub Maven package."
  OWNER="bcgov"
  REPO="java-maven-pipeline-example"
  GROUP_ID="bcgov.example"
  ARTIFACT_ID="java-maven-pipeline-example"
  VERSION="1.0.1-107-SNAPSHOT"
  BUILD_ID="1.0.1-107-20260129.225533-2"

  GROUP_PATH=$(echo "$GROUP_ID" | tr '.' '/')
  DOWNLOAD_URL="https://maven.pkg.github.com/${OWNER}/${REPO}/${GROUP_PATH}/${ARTIFACT_ID}/${VERSION}/${ARTIFACT_ID}-${BUILD_ID}.war"

  echo "Downloading from: $DOWNLOAD_URL"

  # Download using curl with GitHub token
  HTTP_CODE=$(curl -L -w "%{http_code}" -H "Authorization: token ${GITHUB_TOKEN}" \
    -o "$WAR_PATH" \
    "$DOWNLOAD_URL")

  echo "HTTP Response Code: $HTTP_CODE"

  if [ "$HTTP_CODE" != "200" ]; then
    echo "Error: Failed to download WAR file (HTTP $HTTP_CODE)"
    echo "Response content:"
    head -20 "$WAR_PATH"
    exit 1
  fi

  if ! head -c 4 "$WAR_PATH" | grep -q "PK"; then
    echo "Error: Downloaded file is not a valid WAR/ZIP file (missing PK header)"
    echo "File size: $(du -h "$WAR_PATH" | cut -f1)"
    echo "First few lines of response:"
    head -20 "$WAR_PATH"
    exit 1
  fi
  echo "✓ WAR file downloaded successfully ($(du -h "$WAR_PATH" | cut -f1))"
fi

echo "Deploying WAR to Tomcat..."
mv "$WAR_PATH" /usr/local/tomcat/webapps/${APP_CONTEXT:-ROOT}.war

ls -lh /usr/local/tomcat/webapps/

exec /usr/local/tomcat/bin/catalina.sh run
