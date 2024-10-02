#!/bin/bash

# Set variables
RUNNER_NAME="${RUNNER_NAME:-$(hostname)}"
RUNNER_WORKDIR="${RUNNER_WORKDIR:-/_work}"
RUNNER_LABELS="${RUNNER_LABELS:-self-hosted,code-scanning}"
GITHUB_URL="https://github.com/vineeth12345/grandnode"
GITHUB_PAT="${{ secrets.GIT_PAT }}"

# Function to get runner token
get_runner_token() {
  echo "Requesting registration token from GitHub..."
  RUNNER_TOKEN=$(curl -s -X POST -H "Authorization: token ${GITHUB_PAT}" https://api.github.com/repos/vineeth12345/grandnode/actions/runners/registration-token | jq -r .token)
  if [ -z "$RUNNER_TOKEN" ]; then
    echo "Failed to get registration token from GitHub"
    exit 1
  fi
}

# Download and configure the GitHub runner
cd /actions-runner
get_runner_token
./config.sh --url ${GITHUB_URL} --token ${RUNNER_TOKEN} --name ${RUNNER_NAME} --work ${RUNNER_WORKDIR} --labels ${RUNNER_LABELS} --unattended --replace

# Run the runner
cleanup() {
    echo "Removing runner..."
    ./config.sh remove --unattended --token ${RUNNER_TOKEN}
}

trap 'cleanup; exit 130' INT
trap 'cleanup; exit 143' TERM

# Run the GitHub Actions runner
./run.sh --once

# Cleanup and exit
cleanup
exit 0
