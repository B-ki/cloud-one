FROM debian:buster

RUN apt-get update && apt-get install -y mariadb-server

COPY tools/setup.sh /usr/local/bin/

RUN chmod +x /usr/local/bin/setup.sh

EXPOSE 3306

ENTRYPOINT [ "/usr/local/bin/setup.sh" ]
CMD [ "mysqld_safe", "--bind-address=0.0.0.0" ]

