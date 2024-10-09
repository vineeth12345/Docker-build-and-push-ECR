# Use a base image with necessary tools
FROM ubuntu:20.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    jq \
    git \
    build-essential \
    unzip \
    libicu-dev \
    zip 
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && unzip awscliv2.zip && ./aws/install

# Create a non-root user
RUN useradd -m -s /bin/bash runner

# Install GitHub runner
RUN mkdir /actions-runner && chown runner:runner /actions-runner
WORKDIR /actions-runner
RUN curl -O -L https://github.com/actions/runner/releases/download/v2.319.1/actions-runner-linux-x64-2.319.1.tar.gz
RUN tar xzf ./actions-runner-linux-x64-2.319.1.tar.gz && chown -R runner:runner /actions-runner

# Ensure runner user has permissions to the /_work directory
RUN mkdir -p /_work/_update && chown -R runner:runner /_work

# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Switch to non-root user
USER runner

ARG GIT_REPO_URL
LABEL org.opencontainers.source=${GIT_REPO_URL}

ENTRYPOINT ["/entrypoint.sh"]