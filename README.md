# java-maven-pipeline-example
Pipeline testing example for Java + Maven + Tomcat application

# Running Locally
(need maven and java installed)
```
mvn package
java -jar target/dependency/webapp-runner.jar target/*.war
```
The application will be available on http://localhost:8080.
