#!/bin/bash

#Wait for MariaDB to start
while ! mysqladmin ping --silent -h"$MYSQL_HOSTNAME"; do
    sleep 1
done

# Create wp-config.php if it doesn't exist
if [ ! -f wp-config.php ]; then
        echo "Creating wp-config.php..."
        wp config create --dbhost=$MYSQL_HOSTNAME:3306 --dbname=$MYSQL_WP_DATABASE --dbuser=$MYSQL_USER --dbpass=$MYSQL_PASS --allow-root
fi

# if wordpress is not installed
if ! wp core is-installed --allow-root; then
        echo "Installing WordPress..."
        wp core install --url=$DOMAIN_NAME --title="Bigception website" --admin_name=$WP_ADMIN_USER --admin_password=$WP_ADMIN_PASS --admin_email=$WP_ADMIN_MAIL --allow-root
else
	echo "WordPress already installed"
fi

php-fpm7.4 -F
