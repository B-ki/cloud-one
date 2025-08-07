#!/bin/bash

set -e

echo "Starting phpMyAdmin setup..."

chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html

mkdir -p /var/www/html/tmp
chown www-data:www-data /var/www/html/tmp
chmod 777 /var/www/html/tmp

#echo "Waiting for MariaDB to be ready..."
#while ! nc -z mariadb 3306; do
#    sleep 1
#done
#echo "MariaDB is ready!"

echo "phpMyAdmin setup completed successfully!"

exec "$@"
