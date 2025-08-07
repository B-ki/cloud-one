FROM debian:bullseye

RUN apt update && apt install -y php php-curl php-mysqli php-fpm curl mariadb-client

COPY conf/www.conf /etc/php/7.4/fpm/pool.d/www.conf

WORKDIR /var/www/wordpress

RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp && \
    mkdir -p /run/php

RUN wp core download --allow-root

COPY tools/setup.sh /usr/local/bin/
COPY conf/wp-config.php /tmp/wp-config-template.php

# Copy backups directory (will copy empty dir if no backups exist)
COPY ../../backups /tmp/backups

RUN chmod +x /usr/local/bin/setup.sh

EXPOSE 9000

ENTRYPOINT [ "/usr/local/bin/setup.sh" ]
