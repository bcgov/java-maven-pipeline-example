# java-maven-pipeline-example
Pipeline testing example for Java + Maven + Tomcat application

# Running Locally
(need maven and java installed)
```
mvn package
java -jar target/dependency/webapp-runner.jar target/*.war
```
The application will be available on http://localhost:8080.

## How to Deploy

Follow the [branch model](CONTRIBUTING.md) and create a PR to the main branch to deploy to non-production environments.

This repository uses GitHub Packages to store release builds.

Creating a release will automatically create a package that you can deploy to production.

Read more: [DEPLOY.md](DEPLOY.md)

