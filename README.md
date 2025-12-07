# Resume Site Deployment

This repository contains a personal resume website built with HTML/CSS and Docker. The site is automatically built and deployed using GitHub Actions.

---

## Features

- Automated Docker image build on push to `main` branch.
- Optional Docker image push to Docker Hub.
- SSH deployment to a remote server.
- Healthcheck to ensure the site is running after deployment.
- Fully CI/CD-enabled workflow.

---

## GitHub Actions Workflow

The workflow is defined in `.github/workflows/deploy.yml` and includes two jobs:

### 1. Build

- Runs on `ubuntu-latest`.
- Steps:
  1. Checkout repository.
  2. Build a Docker image with the tag `docker.io/ifeoma028/resume-site:latest`.
  3. Optional: push the Docker image to a registry.
  4. Export the image tag as an output for deployment.

### 2. Deploy

- Runs after the `build` job.
- Uses SSH to connect to the remote server.
- Steps:
  1. Fetch the Docker image tag from the `build` job.
  2. Run the deployment script on the server (`start.sh`) with the Docker image as an argument.
  3. Perform a healthcheck at `http://127.0.0.1:80/`.
  4. Retry up to 12 times (5 seconds between retries) before failing.
  5. Logs Docker output on failure.

---

## Deployment Script (`start.sh`)

Your server should have a script at `/home/ubuntu/deploy/start.sh` that accepts the Docker image tag as an argument and performs the following:

- Stops the previous container (if running).
- Runs the new Docker container with the given image.
- Exposes the container on port 80.

Example:

```bash
#!/bin/bash
IMAGE="$1"
docker stop resume-site || true
docker rm resume-site || true
docker run -d --name resume-site -p 80:80 "$IMAGE"

## Setup

1. Add your server credentials as GitHub Secrets:

   - **HOST** — server IP or hostname  
   - **USERNAME** — SSH username  
   - **SSH_KEY** — private SSH key  

2. Push your changes to the `main` branch to trigger the workflow.

---

## Healthcheck

After deployment, the workflow will check:

`http://127.0.0.1:80/`

If the site does not become reachable within 12 attempts, the workflow will fail and display the last 200 lines of Docker logs to help with debugging.

## External Check

To confirm the site is accessible from the internet, open your browser and visit:http://YOUR-SERVER-IP/


You can also test externally using `curl`:

```bash
curl -I http://YOUR-SERVER-IP/

A healthy response should return HTTP status 200 OK.