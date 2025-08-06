#!/bin/bash

if [ ! -d "/var/lib/mysql/$MYSQL_WP_DATABASE" ]
then
        echo "Installing and configuring mariadb..."

        mysqld_safe --user=mysql --datadir=/var/lib/mysql &
        sleep 3

        # Set root password (initially no password)
        mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD';"
        
        # Delete anonymous users
        mysql -u root -p$MYSQL_ROOT_PASSWORD -e "DELETE FROM mysql.user WHERE User='';"
        # Delete test database
        mysql -u root -p$MYSQL_ROOT_PASSWORD -e "DROP DATABASE IF EXISTS test;"
        # Remove any potential leftover database
        mysql -u root -p$MYSQL_ROOT_PASSWORD -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';"
        
        # Create wordpress database and user, and grant privileges
        mysql -u root -p$MYSQL_ROOT_PASSWORD -e "CREATE DATABASE $MYSQL_WP_DATABASE;"
        mysql -u root -p$MYSQL_ROOT_PASSWORD -e "CREATE USER '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASS';"
        mysql -u root -p$MYSQL_ROOT_PASSWORD -e "GRANT ALL PRIVILEGES ON $MYSQL_WP_DATABASE.* TO '$MYSQL_USER'@'%';"
        mysql -u root -p$MYSQL_ROOT_PASSWORD -e "FLUSH PRIVILEGES;"
        sleep 1
        mysqladmin shutdown
else
        echo "Mysql wordpress database already installed"
fi

exec "$@"
