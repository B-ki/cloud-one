DOCKER = docker
COMPOSE = $(DOCKER) compose
ANSIBLE = ansible-playbook -i inventory.yml
ANSIBLE_CMD = ansible -i deployment/inventory.yml
ALL_CONTAINERS = wordpress mariadb nginx-internal nginx-proxy nginx-ssl phpmyadmin

all:    ansible-deploy 

stop:
	@echo "Stopping containers on remote server..."
	$(ANSIBLE_CMD) scaleway-server -m shell -a "cd /root/cloud-one && docker compose down"

clean:
	@echo "Removing containers on remote server..."
	$(ANSIBLE_CMD) scaleway-server -m shell -a "cd /root/cloud-one && docker compose down --remove-orphans"

fclean: 
	@echo "DESTRUCTIVE: This will destroy ALL Docker resources on the REMOTE server"
	@echo "Remote containers, volumes, networks, and images will be deleted."
	@read -p "Are you sure? Type 'DESTROY' to continue: " confirm && [ "$$confirm" = "DESTROY" ]
	@echo "Cleaning remote Docker resources..."
	$(ANSIBLE_CMD) scaleway-server -m shell -a "cd /root/cloud-one && docker compose down --volumes --remove-orphans"
	$(ANSIBLE_CMD) scaleway-server -m shell -a "docker images --filter 'reference=cloud-one-*' --quiet | xargs -r docker rmi 2>/dev/null || true"
	$(ANSIBLE_CMD) scaleway-server -m shell -a "docker system prune -f"
	@echo "Cleaning remote data directories..."
	$(ANSIBLE_CMD) scaleway-server -m shell -a "rm -rf /root/data/* 2>/dev/null || true"

ansible-deploy:
	@echo "Deploying Cloud-One to Scaleway with Ansible..."
	cd deployment && $(ANSIBLE) deploy.yml

ansible-ping:
	@echo "Testing connection to Scaleway server..."
	$(ANSIBLE_CMD) scaleway-server -m ping

ansible-status:
	@echo "Checking Docker containers status on remote server..."
	$(ANSIBLE_CMD) scaleway-server -m shell -a "cd /root/cloud-one && docker compose ps"

ansible-logs:
	@echo "Fetching logs from remote server..."
	$(ANSIBLE_CMD) scaleway-server -m shell -a "cd /root/cloud-one && docker compose logs --tail=50"

ansible-stop:
	@echo "Stopping containers on remote server..."
	$(ANSIBLE_CMD) scaleway-server -m shell -a "cd /root/cloud-one && docker compose down"

ansible-restart:
	@echo "Restarting containers on remote server..."
	$(ANSIBLE_CMD) scaleway-server -m shell -a "cd /root/cloud-one && docker compose down && docker compose up -d"

ansible-setup:
	@echo "Setting up Ansible environment..."
	cd deployment && ./setup-ansible.sh

volumes:
	@echo "Creating data directories on remote server..."
	$(ANSIBLE_CMD) scaleway-server -m shell -a "mkdir -p /root/data/wp /root/data/mysql"

build:  volumes
	@echo "Building images on remote server..."
	$(ANSIBLE_CMD) scaleway-server -m shell -a "cd /root/cloud-one && docker compose build"

up:
	@echo "Starting containers on remote server..."
	$(ANSIBLE_CMD) scaleway-server -m shell -a "cd /root/cloud-one && docker compose up -d"

re: fclean ansible-deploy

.PHONY: all clean fclean volumes build up re ansible-setup ansible-deploy ansible-ping ansible-status ansible-logs ansible-stop ansible-restart help
