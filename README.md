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


Refer to [nr-polaris-docs](https://bcgov.github.io/nr-polaris-docs/#/) for more information about how to use the Polaris Pipeline.

## Resources

[NRM Architecture Confluence: GitHub Repository Best Practices](https://apps.nrs.gov.bc.ca/int/confluence/x/TZ_9CQ)
<!-- README.md.tpl:END -->

<!-- README-buildenv.md.tpl:START -->

### Setting Up Your Build Environment

Use the `env.sh` script to initialize your build or development runtime environment.

Refer to [nr-polaris-docs](https://bcgov.github.io/nr-polaris-docs/#/BUILD) for more information on how `env.sh` sets up the build environment.

#### Usage

```bash
source env.sh [mode] [path] [--skip-vault]
```

**Parameters:**
- `mode`: `build` (default) or `local`
  - `build` mode: Setup for builds
  - `local` mode: Setup for local development runtime
- `path`: Directory containing catalog-info.yaml (default: current directory)
- `--skip-vault`: Skip Vault authentication (for offline/CI scenarios)

#### Examples

<!-- Single Service Repository -->
```bash
# Load build environment
source env.sh

# Load local development runtime environment
source env.sh local

# Skip Vault authentication
source env.sh build --skip-vault
```

<!-- Please add section showing how to build this application after the template marker -->

<!-- README-buildenv.md.tpl:END -->

### Building

After sourcing `env.sh`, run the following to complete the build:

```bash
./mvnw -Dmaven.test.skip=true clean package
```

<!-- README-localenv.md.tpl:START -->
#### Local Development Runtime Environment

Use the `env.sh` script to initialize with the `local` mode to setup the environment to run your application locally on your development machine.

```bash
source env.sh local ...
```

Refer to [nr-polaris-docs](https://bcgov.github.io/nr-polaris-docs/#/LOCAL) for more information on how `env.sh` sets up the local development runtime environment and how to customize the environment.

<!-- Please add section showing how to run this application after the template marker -->

<!-- README-localenv.md.tpl:END -->
