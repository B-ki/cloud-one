DOCKER = docker
COMPOSE = $(DOCKER) compose
TERRAFORM = terraform
ALL_CONTAINERS = wordpress mariadb nginx-internal nginx-proxy nginx-ssl phpmyadmin

all:    build up 

stop:
	$(DOCKER) container stop $(ALL_CONTAINERS) 2>/dev/null || true

clean:
	$(DOCKER) container rm -f $(ALL_CONTAINERS) 2>/dev/null || true

fclean: clean
	@echo "🚨 DESTRUCTIVE: This will destroy ALL Docker resources for this project only"
	@echo "Project containers, volumes, networks, and images will be deleted."
	@read -p "Are you sure? Type 'DESTROY' to continue: " confirm && [ "$$confirm" = "DESTROY" ]
	@echo "🧹 Cleaning project Docker resources..."
	$(COMPOSE) down --volumes --remove-orphans 2>/dev/null || true
	$(DOCKER) images --filter "reference=$$(basename $$(pwd))-*" --quiet | xargs -r $(DOCKER) rmi 2>/dev/null || true
	$(DOCKER) rmi nginxproxy/nginx-proxy nginxproxy/acme-companion 2>/dev/null || true
	@echo "🧹 Cleaning project data directories..."
	rm -rf $${DATA_PATH:-./data}/* 2>/dev/null || true

terraform-replace:
	@echo "🧽 Cleaning remote Docker resources via Terraform..."
	$(TERRAFORM) apply -replace="null_resource.scaleway_setup"

volumes:
	mkdir -p $${DATA_PATH:-./data}/wp
	mkdir -p $${DATA_PATH:-./data}/mysql

build:  volumes
	$(COMPOSE) build 

up:
	$(COMPOSE) up -d 

re: fclean volumes build up

# Help target
help:
	@echo "Available targets:"
	@echo "  all               - Build and start containers"
	@echo "  stop              - Stop containers"
	@echo "  clean             - Delete containers (after stopping)"
	@echo "  fclean            - 🚨 DESTROY all Docker resources for this project"
	@echo "  terraform-replace - Deploy/redeploy via Terraform"
	@echo "  volumes           - Create required data directories"
	@echo "  build             - Build Docker images"
	@echo "  up                - Start containers"
	@echo "  re                - Full rebuild (fclean + build + up)"
	@echo "  help              - Show this help"

.PHONY: all clean fclean fclean-local terraform-replace clean-remote volumes build up dev re help
