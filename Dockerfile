# --- STAGE 1: Build the Application ---
ARG MAVEN_VERSION
ARG TOMCAT_VERSION=10.1-jdk21-temurin-noble
FROM maven:${MAVEN_VERSION} AS build_stage

# Set the working directory
WORKDIR /app

# Verify Java and Maven installation
RUN java -version && mvn -version

# Copy only the pom.xml first to cache dependencies (faster rebuilds)
COPY pom.xml .

# Download and resolve dependencies explicitly with force update
RUN mvn -U clean dependency:resolve dependency:resolve-plugins -DskipTests

# Copy the source code and build the war
COPY src ./src
RUN mvn clean package -DskipTests

# --- STAGE 2: Run in Tomcat 10 ---
FROM tomcat:${TOMCAT_VERSION}

# Remove default apps to keep it clean
RUN rm -rf /usr/local/tomcat/webapps/*

# Copy the built WAR from the build_stage
# Note: Ensure 'java-maven-pipeline-example.war' matches your pom.xml <finalName>
COPY --from=build_stage /app/target/*.war /usr/local/tomcat/webapps/ROOT.war

# Add Tomcat 10 / Jakarta EE support environment variable
#ENV CATALINA_OPTS="-Dconfig.location=/app/rendered/application.properties"

EXPOSE 8080
CMD ["catalina.sh", "run"] 
