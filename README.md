# java-maven-pipeline-example
Pipeline testing example for Java + Maven + Tomcat application

# Running Locally
(need maven and java installed)
```
mvn package
java -jar target/dependency/webapp-runner.jar target/*.war
```
The application will be available on http://localhost:8080.

<!-- README.md.tpl:START -->

## Working With the Polaris Pipeline

This repository uses the Polaris Pipeline to build and deploy.

Refer to [nr-polaris-docs](https://github.com/bcgov/nr-polaris-docs) for more information about how to use the Polaris Pipeline.

## Resources

[NRM Architecture Confluence: GitHub Repository Best Practices](https://apps.nrs.gov.bc.ca/int/confluence/x/TZ_9CQ)

<!-- README.md.tpl:END -->
