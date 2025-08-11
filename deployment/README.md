# Deployment

This directory contains all Ansible configuration and deployment scripts for Cloud-One.

## Prerequisites

- Python 3.x with pip
- SSH access to target server

## Files

- `ansible.cfg` - Ansible configuration
- `inventory.yml` - Server inventory (Scaleway instance)
- `deploy.yml` - Main deployment playbook
- `requirements.yml` - Ansible collections dependencies
- `setup-ansible.sh` - Setup script for Ansible environment

## Quick Start

From the project root directory:

```bash
# Setup Ansible (first time only) - installs via pip --user
make ansible-setup

# Deploy to Scaleway
make ansible-deploy

# Check status
make ansible-status
```

## Manual Installation

If the setup script fails, install manually:

```bash
# Install Ansible with pip (user installation)
pip3 install --user ansible

# Add to PATH (add to ~/.bashrc or ~/.zshrc for persistence)
export PATH="$HOME/.local/bin:$PATH"

# Install collections
cd deployment/
ansible-galaxy collection install -r requirements.yml
```

## Manual Usage

```bash
# Enter deployment directory
cd deployment/

# Setup Ansible
./setup-ansible.sh

# Deploy
ansible-playbook deploy.yml

# Check connection
ansible scaleway-server -m ping
```
