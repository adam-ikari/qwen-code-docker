# Qwen-Code Docker Runner

This project provides a convenient Dockerized environment for the [`@qwen-code/qwen-code`](https://www.npmjs.com/package/@qwen-code/qwen-code) command-line interface (CLI) tool. It allows you to use the `qwen` command without needing to install Node.js or the package directly on your local machine.

The setup includes helper scripts to build, run, and test the Docker image, as well as a GitHub Actions workflow to automatically build and publish new versions to Docker Hub.

## Features

- **Portable Environment**: Run `qwen-code` anywhere Docker is installed.
- **Version Tagging**: Images are automatically tagged with the `qwen-code` version.
- **Easy-to-Use Scripts**:
  - `build.sh`: Build a local Docker image.
  - `run.sh`: Run `qwen` commands as if they were installed locally.
  - `test.sh`: Verify that the local image is working correctly.
- **Automated Builds**: A GitHub Action checks for new versions daily and publishes them to Docker Hub.

## Prerequisites

- **Docker**: Must be installed and running.
- **Bash**: For executing the helper scripts (`.sh` files).
- **npm**: Required by the `build.sh` script to query the latest package version from the npm registry.

## Quick Start

### Recommended: Download and Use qwen.sh

1. Download the qwen.sh script from GitHub:

```bash
curl -O https://raw.githubusercontent.com/adam-ikari/qwen-code-docker/main/scripts/qwen.sh
chmod +x qwen.sh
```

2. Set environment variables (as described below)

3. Run commands:

```bash
./qwen.sh [command]
```

### Alternative: Pull from Docker Hub

For users who prefer using Docker directly:

**Set Environment Variables** (choose one method):

1. Temporary (current session only):
```bash
export OPENAI_API_KEY="your_api_key_here"
export OPENAI_BASE_URL="your_api_base_url_here"
export OPENAI_MODEL="your_api_model_here"
```

2. Permanent (add to shell config file ~/.bashrc or ~/.zshrc):
```bash
echo 'export OPENAI_API_KEY="your_api_key_here"
export OPENAI_BASE_URL="your_api_base_url_here"
export OPENAI_MODEL="your_api_model_here"' >> ~/.bashrc
source ~/.bashrc
```

Then run the container:
```bash
docker run --rm -it \
  -v "$(pwd)":/app \
  -v "${HOME}/.qwen":/app/.qwen \
  -w /app \
  -e OPENAI_API_KEY \
  -e OPENAI_BASE_URL \
  -e OPENAI_MODEL \
  adam-ikari/qwen-code:latest [command]
```

### Alternative: Build Locally

For advanced users who want to build the image themselves:

**1. Build the Docker Image**

First, make the scripts executable:

```bash
chmod +x build.sh run.sh
```

Then run the build script:

```bash
./build.sh
```

This creates local image tags: `qwen-code:<version>` and `qwen-code:latest`.

**2. Run `qwen` Commands**

Use the helper script:

```bash
OPENAI_API_KEY="your_api_key_here" \
OPENAI_BASE_URL="your_api_base_url_here" \
OPENAI_MODEL="your_api_model_here" \
./qwen.sh [command]
```

```bash
# View the version (verifies the installation)
./qwen.sh --version

# View the help menu
./qwen.sh --help

# Run a command that operates on a local file
# (Assuming 'qwen analyze' is a valid command)
touch my_file.js
./qwen.sh analyze my_file.js
```

## Scripts Explained

#### `build.sh`

This script automates the build process:

1.  Queries the npm registry for the latest version of `@qwen-code/qwen-code`.
2.  Builds the Docker image using the `Dockerfile`.
3.  Tags the image with the specific version number (e.g., `qwen-code:1.2.3`).
4.  Saves a compressed `.tar.gz` archive of the image in the project root.

#### `qwen.sh`

This is your main entry point for using the tool. It acts as a wrapper around the `docker run` command:

- Runs the `qwen-code:latest` image.
- Mounts the current directory (`pwd`) to the `/app` directory inside the container.
- Mounts the host's `~/.qwen` directory to `/home` inside the container (for persistent configuration and data storage).
- Sets `/app` as the working directory.
- Passes all script arguments directly to the `qwen` command.
- Automatically cleans up the container (`--rm`) after execution.

The script will automatically create the `~/.qwen` directory if it doesn't exist.

## Automated Builds with GitHub Actions

The `.github/workflows/daily-update.yml` file defines a GitHub Actions workflow that automates the process of keeping the Docker Hub image up-to-date.

- **Trigger**: Runs on a daily schedule (`cron`) and can also be triggered manually (`workflow_dispatch`).
- **Logic**:
  1.  Fetches the latest version number of `@qwen-code/qwen-code` from npm.
  2.  Checks if a Docker Hub image with that version tag already exists.
  3.  If the tag does **not** exist, it proceeds to build a new image.
  4.  The new image is pushed to Docker Hub with two tags: the specific version and `latest`.

To use this action in your own fork, you must configure the following repository secrets in `Settings > Secrets and variables > Actions`:

- `DOCKERHUB_USERNAME`: Your Docker Hub username.
- `DOCKERHUB_TOKEN`: A Docker Hub Access Token.

You also need to update the `DOCKER_IMAGE_NAME` environment variable in the workflow file to point to your Docker Hub repository.

## Loading the Saved Image

The `build.sh` script creates a `qwen-code-x.y.z.tar.gz` file. You can transfer this file to another machine and load it into Docker without needing to rebuild it:

```bash
docker load < qwen-code-x.y.z.tar.gz
