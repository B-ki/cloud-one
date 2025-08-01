#!/bin/bash

if [ ! -d "/var/lib/mysql/$MYSQL_WP_DATABASE" ]
then
        echo "Installing and configuring mariadb..."

        service mysql start
        sleep 1

        # Change root password
	mysql -e "UPDATE mysql.user SET Password = PASSWORD('$MYSQL_ROOT_PW') WHERE User = 'root'"
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
        mysql -e "CREATE USER $MYSQL_USER@'%' IDENTIFIED BY '$MYSQL_PASSWORD';"
        mysql -e "GRANT ALL PRIVILEGES ON $MYSQL_WP_DATABASE.* TO $MYSQL_USER@'%';"
        mysql -e "FLUSH PRIVILEGES"
        sleep 1
        service mysql stop
else
        echo "Mysql wordpress database already installed"
fi

exec "$@"
