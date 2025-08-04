#!/bin/bash

if [ ! -d "/var/lib/mysql/$MYSQL_WP_DATABASE" ]
then
        echo "Installing and configuring mariadb..."

        mysqld_safe --user=mysql --datadir=/var/lib/mysql &
        sleep 3

        # Change root password
	mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD';"
	#mysql -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');"
        # Delete anonymous users
        mysql -e "DELETE FROM mysql.user WHERE User='';"
        # Delete test database
        mysql -e "DROP DATABASE IF EXISTS test;"
        # Remove any potential leftover database : 
        mysql -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';"
        # Flush privileges :
        mysql -e "FLUSH PRIVILEGES"

        # Create wordpress database and user, and grant privileges : 
        mysql -e "CREATE DATABASE $MYSQL_WP_DATABASE;"
        mysql -e "CREATE USER '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASS';"
        mysql -e "GRANT ALL PRIVILEGES ON $MYSQL_WP_DATABASE.* TO '$MYSQL_USER'@'%';"
        mysql -e "FLUSH PRIVILEGES"
        sleep 1
        mysqladmin shutdown
else
        echo "Mysql wordpress database already installed"
fi

exec "$@"
