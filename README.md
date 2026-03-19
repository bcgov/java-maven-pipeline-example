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

#### Setting the Artifact Version

The `pom.xml` uses a user-defined `${app.version}` property for the project version. A profile named `version-from-env` activates automatically when the `VERSION` environment variable is present and sets `app.version` to its value. When the variable is absent the POM uses a sentinel default (`UNSET`) so a bare `./mvnw` invocation produces a clearly invalid version rather than a stale hardcoded one. No extra plugins are required — Maven resolves plain user-defined properties in `<version>` natively at install/deploy time.

The `VERSION` file in the project root is the single source of truth for the base version. `.env-build.sh` reads it via `cat VERSION` as its fallback, so local builds and the pipeline always derive the base from the same place. This approach works with any build tool, not just Maven.

| Context | Version resolved |
|---|---|
| **Local build — no env var, no env.sh** | Maven builds with version `UNSET` (clearly invalid, won't be mistaken for a real release) |
| **Local build — after `source env.sh`** | `.env-build.sh` reads the base version from `VERSION` file (unless `VERSION` is already set in the shell) |
| **CI/CD — branch or PR** | "Set VERSION" step computes `<base>-<pr-or-branch>-SNAPSHOT` and writes it to `$GITHUB_ENV`; `env.sh` sees it already set and skips the fallback |
| **CI/CD — tag `v1.2.3`** | "Set VERSION" step strips the `v` prefix and writes `VERSION=1.2.3` to `$GITHUB_ENV` |

To build with a specific version locally:

```bash
export VERSION=1.2.0-SNAPSHOT
source env.sh build --skip-vault
./mvnw clean package
```

Or as a one-liner (no shell modification):

```bash
VERSION=1.2.0-SNAPSHOT ./mvnw clean package
```

To bump the base development version, update only the `VERSION` file — `.env-build.sh` and the pipeline both derive from it automatically.

<!-- Please add section showing how to build this application after the template marker -->

<!-- README-buildenv.md.tpl:END -->

<!-- README-localenv.md.tpl:START -->
#### Local Development Runtime Environment

Use the `env.sh` script to initialize with the `local` mode to setup the environment to run your application locally on your development machine.

```bash
source env.sh local ...
```

Refer to [nr-polaris-docs](https://bcgov.github.io/nr-polaris-docs/#/LOCAL) for more information on how `env.sh` sets up the local development runtime environment and how to customize the environment.

<!-- Please add section showing how to run this application after the template marker -->

<!-- README-localenv.md.tpl:END -->
