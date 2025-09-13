# Final Jenkins

### Setting up a pipeline for the development branch
- Build on a push event to the repository
- Build a Docker image based on any Dockerfile
- Checking the image for vulnerabilities. (When vulnerabilities are detected, the pipeline must be interrupted and a notification sent to the developer)
- If there are no vulnerabilities: continue pipeline. Assign any tag to the image (for example, with a hash of the build launch commit). Upload an image to the Nexus
- The entire pipeline must be protected by a build time timeout

### Setting up the pipeline for the release branch
- Launching using the Git tag
- Downloading a Docker image built on the development branch
- Change the image tag to the one that marks the release commit
- Container deployment
- After a few minutes, make several attempts to verify that the container is working correctly and send a notification to the developer.
