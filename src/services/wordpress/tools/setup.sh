#!/bin/bash

#Wait for MariaDB to start
while ! mysqladmin ping --silent -h"$MYSQL_HOSTNAME"; do
    sleep 1
done

# Create wp-config.php if it doesn't exist
if [ ! -f wp-config.php ]; then
        echo "Creating wp-config.php with environment variables..."
        cp /tmp/wp-config-template.php wp-config.php
fi

# if wordpress is not installed
if ! wp core is-installed --allow-root; then
        echo "Installing WordPress..."
        wp core install --url=https://$DOMAIN_NAME --title="Bigception website" --admin_name=$WP_ADMIN_USER --admin_password=$WP_ADMIN_PASS --admin_email=$WP_ADMIN_MAIL --allow-root
        
        # Force HTTPS URLs
        echo "Configuring HTTPS URLs..."
        wp option update siteurl "https://$DOMAIN_NAME" --allow-root
        wp option update home "https://$DOMAIN_NAME" --allow-root
        
        # Install and activate Jobstride Resume theme
        echo "Installing Jobstride Resume theme..."
        wp theme install jobstride-resume --activate --allow-root
        
        # Replace any HTTP URLs in database
        echo "Ensuring all URLs use HTTPS..."
        wp search-replace "http://$DOMAIN_NAME" "https://$DOMAIN_NAME" --allow-root
else
	echo "WordPress already installed"
	# Ensure HTTPS URLs even if WordPress exists
	echo "Verifying HTTPS configuration..."
	wp option update siteurl "https://$DOMAIN_NAME" --allow-root
	wp option update home "https://$DOMAIN_NAME" --allow-root
	wp search-replace "http://$DOMAIN_NAME" "https://$DOMAIN_NAME" --allow-root
fi

php-fpm7.4 -F
