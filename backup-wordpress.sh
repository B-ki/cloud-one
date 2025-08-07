#!/bin/bash

# WordPress Backup Script for Cloud-One
# Run this script on your Scaleway server to create backups

BACKUP_DIR="backups"
DATE=$(date +%Y%m%d_%H%M%S)

echo "Starting WordPress backup..."

# Create backup directory
mkdir -p $BACKUP_DIR

# Export WordPress database
echo "Exporting WordPress database..."
docker exec mariadb mysqldump -u wp_user_2025 -p'SecureWP2025!Database' wordpress > $BACKUP_DIR/wordpress_db_${DATE}.sql

if [ $? -eq 0 ]; then
    echo "✅ Database backup created: $BACKUP_DIR/wordpress_db_${DATE}.sql"
else
    echo "❌ Database backup failed"
    exit 1
fi

# Create uploads backup
echo "Creating uploads directory backup..."
docker exec wordpress tar -czf /tmp/wordpress_uploads_${DATE}.tar.gz -C /var/www/wordpress wp-content/uploads
docker cp wordpress:/tmp/wordpress_uploads_${DATE}.tar.gz $BACKUP_DIR/
docker exec wordpress rm /tmp/wordpress_uploads_${DATE}.tar.gz

if [ $? -eq 0 ]; then
    echo "✅ Uploads backup created: $BACKUP_DIR/wordpress_uploads_${DATE}.tar.gz"
else
    echo "❌ Uploads backup failed"
fi

# Create a latest backup (without timestamp) for easy automation
echo "Creating 'latest' backup copies..."
cp $BACKUP_DIR/wordpress_db_${DATE}.sql $BACKUP_DIR/wordpress_db_latest.sql
cp $BACKUP_DIR/wordpress_uploads_${DATE}.tar.gz $BACKUP_DIR/wordpress_uploads_latest.tar.gz

echo ""
echo "🎉 Backup completed!"
echo "Files created:"
echo "  - $BACKUP_DIR/wordpress_db_${DATE}.sql"
echo "  - $BACKUP_DIR/wordpress_uploads_${DATE}.tar.gz"
echo "  - $BACKUP_DIR/wordpress_db_latest.sql (for repository)"
echo "  - $BACKUP_DIR/wordpress_uploads_latest.tar.gz (for repository)"
echo ""
echo "To transfer to local repository, run from your local machine:"
echo "  scp root@51.159.139.86:~/backups/wordpress_db_latest.sql ./backups/"
echo "  scp root@51.159.139.86:~/backups/wordpress_uploads_latest.tar.gz ./backups/"