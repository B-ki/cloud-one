srcsPath = srcs/

all:    build up 

clean:
	docker container ls -aq | xargs --no-run-if-empty docker container rm -f

fclean: clean
	docker volume ls | xargs --no-run-if-empty docker volume rm -f
	sudo rm -rf /home/rmorel/data/wp
	sudo rm -rf /home/rmorel/data/mysql

volumes:
	sudo mkdir -p /home/rmorel/data/wp
	sudo mkdir -p /home/rmorel/data/mysql

build:  volumes
	cd $(srcsPath) && docker compose build

up:
	cd $(srcsPath) && docker compose up -d 

re: fclean volumes build up

.PHONY: all clean fclean build up
