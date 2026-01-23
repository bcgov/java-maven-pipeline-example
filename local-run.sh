# Quick Maven build
mvn clean package -DskipTests

# Podman/Docker build
source .env
podman build \
  --build-arg MAVEN_VERSION="$MAVEN_VERSION" \
  --build-arg TOMCAT_VERSION="$TOMCAT_VERSION" \
  -t my-maven-java-app .