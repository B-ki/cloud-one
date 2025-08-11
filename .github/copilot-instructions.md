# Cloud-One AI Agent Instructions

## Project Overview
Cloud-One is a containerized WordPress hosting solution with Traefik reverse proxy, designed for cloud deployment on Scaleway infrastructure. The stack uses a 4-layer architecture: Traefik (SSL/routing) → Nginx (static files) → WordPress (PHP-FPM) → MariaDB.

The aim of the project is to deploy using Ansible a webserver with Docker and docker-compose on a Scaleway instance.

## AI Agent Instructions

- Do not overengineer solutions, we want straightforward answers easy to understand

## Code Guidelines

### What NOT to Create
- **No additional README files** - Project documentation exists in main README.md
- **No test files or test scripts** - This is a deployment-focused project, not a development framework
- **No example files or templates** - Use existing service configurations as references
- **No documentation files** - Keep explanations in code comments only
- **No helper scripts** - Use existing Makefile targets and backup scripts
