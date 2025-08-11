#!/bin/bash

while ! mysqladmin ping --silent -h"$MYSQL_HOSTNAME"; do
    sleep 1
done

if [ ! -f wp-config.php ]; then
        echo "Creating wp-config.php with environment variables..."
        cp /tmp/wp-config-template.php wp-config.php
fi

# if wordpress is not installed
if ! wp core is-installed --allow-root; then
        if [ -f "/tmp/backups/wordpress_db_latest.sql" ]; then
                echo "Backup found! Restoring from backup..."
                
                echo "Importing database backup..."
                wp db import /tmp/backups/wordpress_db_latest.sql --allow-root
                
                if [ -f "/tmp/backups/wordpress_uploads_latest.tar.gz" ]; then
                        echo "Restoring uploads directory..."
                        tar -xzf /tmp/backups/wordpress_uploads_latest.tar.gz -C /var/www/wordpress/
                fi
                
                echo "Installing Jobstride Resume theme..."
                wp theme install jobstride-resume --activate --allow-root
                
                echo "Updating domain URLs..."
                wp search-replace "equancy-cloud-one.duckdns.org" "$DOMAIN_NAME" --allow-root
                wp option update siteurl "https://$DOMAIN_NAME" --allow-root
                wp option update home "https://$DOMAIN_NAME" --allow-root
                
        else
                echo "No backup found. Installing fresh WordPress..."
                wp core install --url=https://$DOMAIN_NAME --title="Bigception website" --admin_name=$WP_ADMIN_USER --admin_password=$WP_ADMIN_PASS --admin_email=$WP_ADMIN_MAIL --allow-root
                
                echo "Installing Jobstride Resume theme..."
                wp theme install jobstride-resume --activate --allow-root
        fi
        
        # force HTTPS URLs
        echo "Configuring HTTPS URLs..."
        wp option update siteurl "https://$DOMAIN_NAME" --allow-root
        wp option update home "https://$DOMAIN_NAME" --allow-root
        
        # replace any HTTP URLs in database
        echo "Ensuring all URLs use HTTPS..."
        wp search-replace "http://$DOMAIN_NAME" "https://$DOMAIN_NAME" --allow-root
else
	echo "WordPress already installed"
	echo "Verifying HTTPS configuration..."
	wp option update siteurl "https://$DOMAIN_NAME" --allow-root
	wp option update home "https://$DOMAIN_NAME" --allow-root
	wp search-replace "http://$DOMAIN_NAME" "https://$DOMAIN_NAME" --allow-root
fi

echo "Setting proper file permissions..."
chown -R www-data:www-data /var/www/wordpress/wp-content/

php-fpm7.4 -F
