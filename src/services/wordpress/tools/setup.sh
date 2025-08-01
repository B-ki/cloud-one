#!/bin/bash

#Wait for MariaDB to start
while ! mysqladmin ping -h"$MYSQL_HOSTNAME" --silent; do
    sleep 1
done

# if wordpress is not installed
if ! wp core is-installed --allow-root; then
        echo "Installing wordpres..."
        wp config create --dbhost=$MYSQL_HOSTNAME:3306 --dbname=$MYSQL_WP_DATABASE --dbuser=$MYSQL_USER --dbpass=$MYSQL_PASS --allow-root

        wp core install --url=$DOMAIN_NAME --title="Bigception website" --admin_name=$WP_ADMIN_USER --admin_password=$WP_ADMIN_PASS --admin_email=$WP_ADMIN_MAIL --allow-root
else
	echo "Wordpress already installed"
fi

php-fpm7.3 -F
