# Java Maven Pipeline Example — Build & Run

This repository demonstrates how to package a Java web application (WAR) and run it locally inside a Tomcat container using either **Podman** or **Docker**.

---

## **Prerequisites**
- **Container Runtime**: Either `podman` (recommended) or `docker`.
- **Environment Setup Tools**: `vault` and `jq` are required for retrieving credentials during the build process.
- **Tomcat Runtime**: Provided via a container image; no local Tomcat installation is needed.

---

## **Important Notes**
- The included `Dockerfile` supports **rootless runtime** by passing `USER_ID` and `GROUP_ID` as build arguments. Defaults are `1000`.
- The build script (`build.sh`) attempts to authenticate with **Vault** to retrieve **Artifactory credentials**. This is required for applications with custom dependencies hosted in Artifactory.

---

## **Build the Application**

### **Using Podman (Recommended for Local Development)**
Run:
```sh
./build.sh --engine podman
```
or
```sh
./build.sh --engine=podman
```

### **Using Docker**
Run:
```sh
./build.sh --engine docker
```
or
```sh
./build.sh --engine=docker
```

This performs the same build process using Docker.

---

## **Run the Application**

### **Using Podman**
Run:
```sh
./run.sh podman
```
This launches the application inside a Tomcat container.

#### **Verify logs and application response:**
```sh
podman logs --tail 200 myapp
curl -sS -D - http://localhost:8080/ -o /dev/null
```
Expected output: HTTP/1.1 200

#### **Verify logs and application response:**
```sh
podman exec myapp id -u
podman exec myapp id -g
```

---

## **Environment Variables**

If you want to change the default Tomcat port, JVM options or runtime user, then update `.docker/runtime/Dockerfile` and `run.sh` accordingly.

<!-- README.md.tpl:START -->

## Working With the Polaris Pipeline

This repository uses the Polaris Pipeline to build and deploy.

Refer to [nr-polaris-docs](https://github.com/bcgov/nr-polaris-docs) for more information about how to use the Polaris Pipeline.

## Resources

[NRM Architecture Confluence: GitHub Repository Best Practices](https://apps.nrs.gov.bc.ca/int/confluence/x/TZ_9CQ)

<!-- README.md.tpl:END -->
