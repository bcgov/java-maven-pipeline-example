# java-maven-pipeline-example
Pipeline testing example for Java + Maven + Tomcat application

# Running Locally
(need maven and java installed)
```
mvn package
java -jar target/dependency/webapp-runner.jar target/*.war
```
The application will be available on http://localhost:8080.

## How to build and deploy using the Polaris Pipeline

### 1. **Trigger a development build**

A development build is the first step before deploying code to production. Development builds are triggered automatically on version tag pushes or by opening a pull request on the `main` branch, but they can also be triggered manually. Do the following steps to trigger a development build manually:

1. Go to the **Actions** tab in the GitHub repository.
2. Select the `Build and release` workflow.
3. Choose the target branch.
4. Click **"Run workflow"** to start the build.
  
After triggering a build, click the workflow run in the **Actions** tab to view logs and progress.

### 2. **Deploy a development build**

Development builds can only be deployed to the dev and test environments. Do the following steps to trigger a deployment to the dev or test environments: 

**Trigger a deployment to the dev and test environments:**

1. Go to the **Actions** tab in your GitHub repository.
2. Select the Deploy workflow.
3. Select the branch to deploy.
4. Click **"Run workflow"** to start deployment.
6. Click the link to the deployment job in the workflow logs to view the deployment job progress.

### 3. **Trigger a release build**

When ready to deploy code to production, create a release:

  - Go to the [Releases](https://github.com/your-username/your-repo/releases) page of your repository.
  - Click on **"Draft a new release"**.
  - Select the tag you just pushed, or create a new one.
  - Fill in the release title and description (e.g., changelog, highlights).
  - (Optional) Attach binaries or other assets.
  - Click **"Publish release"**.

The Build and release workflow will be triggered automatically to build the release. After it build successfully, you may proceed to trigger a deployment of the release to production.

### 3. **Trigger a deployment to production**

1. Go to the **Actions** tab in your GitHub repository.
2. Select the Deploy workflow.
3. Select the tag (release) to deploy.
4. Click **"Run workflow"** to start deployment.
6. Click the link to the deployment job in the workflow logs to view the deployment job progress.
