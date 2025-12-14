# Resume Site Deployment

This repository contains a demo resume website built with HTML/CSS and Docker. The site is automatically built and deployed using GitHub Actions.

---


## Project Structure

```bash

resume-site/
├── .github/
│ └── workflows/
│ └── ci-cd.yml # GitHub Actions workflow for CI/CD
├── docker-compose.yml # Docker Compose configuration
├── Dockerfile # Dockerfile for building the site
├── nginx.conf # Nginx configuration
├── public/ # Public HTML files
│ ├── index.html
│ └── implementation.html
├── README.md # Project documentation
└── start.sh # Startup script

```

## Features

- Automated Docker image build on push to `main` branch.
- Optional Docker image push to Docker Hub.
- SSH deployment to a remote server.
- Healthcheck to ensure the site is running after deployment.
- Fully CI/CD-enabled workflow.

---

## Prerequisites

- [Docker](https://www.docker.com/get-started)
- [Docker Compose](https://docs.docker.com/compose/install/)
- (Optional) GitHub account for CI/CD

## Installation

Clone the repository:

```bash
git clone https://github.com/Ifeomacloud/resume-site.git
cd resume-site
```

## Build the Docker image:

```bash
docker-compose build
```

## Usage

Start the site using Docker Compose:
```bash
docker-compose up -d
```

## Open your browser and visit:
```bash
http://localhost
```

## Stop the site:
```bash
docker-compose down
```

## CI/CD
The project includes a GitHub Actions workflow (.github/workflows/ci-cd.yml) for:
- Building the Docker image

- Running basic checks (if any)

- Deploying automatically (configure secrets as needed)

## Customization
- Modify HTML files in public/ to update your resume content.

- Update nginx.conf for custom server configurations.

- Adjust Dockerfile or docker-compose.yml if you want to change the image or service setup.


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

## Example:

```bash
#!/bin/bash
IMAGE="$1"
docker stop resume-site || true
docker rm resume-site || true
docker run -d --name resume-site -p 80:80 "$IMAGE"

```bash

## Setup:

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
curl -I http://YOUR-SERVER-IP/  like http://3.87.224.141/

A healthy response should return HTTP status 200 OK.