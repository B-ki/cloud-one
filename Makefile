srcsPath = src/

DOCKER = docker
COMPOSE = $(DOCKER) compose

all:    build up 

ALL_CONTAINERS = wordpress mariadb nginx phpmyadmin

clean:
	$(DOCKER) container stop $(ALL_CONTAINERS)

fclean: clean
	$(DOCKER) container rm -f $(ALL_CONTAINERS)

volumes:
	mkdir -p /home/rmorel/data/wp
	mkdir -p /home/rmorel/data/mysql

build:  volumes
	cd $(srcsPath) && $(COMPOSE) build 

up:
	cd $(srcsPath) && $(COMPOSE) up -d 

re: fclean volumes build up

.PHONY: all clean fclean build up
