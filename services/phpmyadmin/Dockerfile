FROM debian:bullseye

RUN apt-get update && apt-get install -y \
    apache2 \
    php \
    php-mysql \
    php-mysqli \
    php-mbstring \
    php-zip \
    php-gd \
    php-json \
    php-curl \
    wget \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /var/www/html

RUN wget https://www.phpmyadmin.net/downloads/phpMyAdmin-latest-all-languages.tar.gz \
    && tar xzf phpMyAdmin-latest-all-languages.tar.gz \
    && mv phpMyAdmin-*-all-languages/* . \
    && rm -rf phpMyAdmin-*-all-languages* \
    && rm -f /var/www/html/index.html \
    && chown -R www-data:www-data /var/www/html

COPY tools/setup.sh /usr/local/bin/
COPY tools/config.inc.php /var/www/html/

RUN chmod +x /usr/local/bin/setup.sh

EXPOSE 80

ENTRYPOINT ["/usr/local/bin/setup.sh"]
CMD ["apache2ctl", "-D", "FOREGROUND"]