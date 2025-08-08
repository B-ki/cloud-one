# Cloud-One

A containerized WordPress hosting solution with automated SSL certificates and Traefik reverse proxy, designed for cloud deployment on Scaleway infrastructure.

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                          Internet                               │
└─────────────────────────┬───────────────────────────────────────┘
                          │
                    ┌─────▼─────┐
                    │  Traefik  │ :80, :443
                    │ (Gateway) │ SSL Termination
                    └─────┬─────┘ Let's Encrypt
                          │
              ┌───────────▼───────────┐
              │       Nginx          │ :80
              │  (Web Server)        │ Static Files
              └───────────┬───────────┘
                          │ FastCGI
              ┌───────────▼───────────┐
              │     WordPress        │ :9000
              │   (PHP-FPM)          │ PHP Processing
              └───────────┬───────────┘
                          │ MySQL
              ┌───────────▼───────────┐
              │      MariaDB         │ :3306
              │    (Database)        │ Data Storage
              └───────────────────────┘

         ┌─────────────────────────────┐
         │      phpMyAdmin       │ :8080
         │   (DB Management)     │ Local Access
         └───────────────────────┘
```

## Description

Cloud-One is a production-ready WordPress hosting stack that combines:

- **Traefik**: Reverse proxy with automatic SSL certificate management
- **Nginx**: High-performance web server for static content delivery
- **WordPress**: PHP-FPM based WordPress installation
- **MariaDB**: Reliable MySQL-compatible database
- **phpMyAdmin**: Web-based database administration interface

The stack is optimized for cloud deployment with persistent data storage, automated backups, and infrastructure as code using Terraform.

## Getting Started

### Prerequisites

- Docker and Docker Compose
- Make
- Terraform (for cloud deployment)
- SSH access to target server (for cloud deployment)

### Local Development

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd cloud-one
   ```

2. **Create environment configuration**
   ```bash
   cp .env.sample .env
   # Edit .env with your configuration
   ```

3. **Start the stack**
   ```bash
   make all
   ```

4. **Access services**
   - WordPress: https://your-domain.com
   - phpMyAdmin: http://localhost:8080

### Cloud Deployment

1. **Configure Terraform variables**
   - Update the SSH host and key path in `main.tf`
   - Ensure your `.env` file contains production values

2. **Deploy infrastructure**
   ```bash
   terraform init
   terraform apply
   ```

3. **Verify deployment**
   ```bash
   make terraform-replace  # For redeployment if needed
   ```

### Available Commands

```bash
make all              # Build and start containers
make stop             # Stop all containers
make clean            # Remove containers
make fclean           # Destroy all Docker resources (DESTRUCTIVE)
make build            # Build Docker images
make up               # Start containers
make re               # Full rebuild
make help             # Show all available commands
```

## Configuration

### Environment Variables

Key environment variables (see `.env.sample`):

- `DOMAIN_NAME`: Your domain name
- `DATA_PATH`: Path for persistent data storage
- `MYSQL_*`: Database configuration
- `*_KEY`, `*_SALT`: WordPress security keys

### SSL Certificates

SSL certificates are automatically managed by Traefik using Let's Encrypt ACME HTTP challenge. The configuration uses staging server by default - change to production in `docker-compose.yml` for live certificates.

### Data Persistence

Data is persisted using bind mounts:
- MySQL data: `${DATA_PATH}/mysql`
- WordPress files: `${DATA_PATH}/wp`

## Backup & Recovery

### Creating Backups

Use the provided backup script on your server:

```bash
./services/wordpress/backup-wordpress.sh
```

This creates:
- Database dump: `backups/wordpress_db_latest.sql`
- Uploads archive: `backups/wordpress_uploads_latest.tar.gz`

### Restoring Backups

1. Place backup files in the `services/wordpress/backups/` directory
2. Rebuild the stack: `make re`
3. Backups are automatically restored during WordPress container initialization

## Roadmap

- [ ] Add automated backup scheduling with cron
- [ ] Implement monitoring with Prometheus/Grafana
- [ ] Add Redis caching layer
- [ ] Support for multi-site WordPress installations
- [ ] Blue-green deployment strategy
- [ ] Integration with cloud storage for backups (S3, etc.)
- [ ] Enhanced security hardening
- [ ] CI/CD pipeline for automated deployments

## Development Challenges & Solutions

This section documents the problems encountered during development and the solutions implemented.

### Traffic Management Evolution

**Problem**: Initial attempts with different reverse proxy solutions faced various complexity issues:

1. **Nginx-proxy + Acme-companion**: SSL certificate management proved overly complex with multiple moving parts and difficult configuration synchronization between the proxy and SSL companion containers.

2. **Certbot**: Managing communication between containers for certificate renewal was problematic, especially handling the HTTP-01 challenge workflow in a containerized environment.

**Solution**: Migrated to **Traefik v3** which provides:
- Built-in ACME Let's Encrypt integration
- Automatic service discovery via Docker labels
- Simplified SSL certificate management
- Single container handling both reverse proxy and SSL termination

### WordPress Configuration Issues

**Problem**: WordPress URL and HTTPS detection issues in containerized environment behind reverse proxy.

**Solutions implemented**:

1. **HTTPS Detection**: Added proxy detection in `wp-config.php`:
   ```php
   if (isset($_SERVER['HTTP_X_FORWARDED_PROTO']) && $_SERVER['HTTP_X_FORWARDED_PROTO'] === 'https') {
       $_SERVER['HTTPS'] = 'on';
   }
   ```

2. **Domain Configuration**: Forced HTTPS URLs in WordPress configuration:
   ```php
   define('WP_HOME', 'https://' . getenv('DOMAIN_NAME'));
   define('WP_SITEURL', 'https://' . getenv('DOMAIN_NAME'));
   ```

### File Permissions Issues

**Problem**: WordPress media upload failures due to container file permission mismatches.

**Solutions**:
- Configured proper user/group mapping between host and container
- Set appropriate directory permissions in WordPress Dockerfile
- Used bind mounts with correct ownership for persistent storage

### Container Communication

**Problem**: Inter-container communication issues, especially database connectivity.

**Solutions**:
- Implemented dedicated Docker bridge network
- Used container names for service discovery instead of localhost
- Properly configured database host in WordPress: `getenv('MYSQL_HOSTNAME') . ':3306'`

## Troubleshooting

### Common Issues

1. **SSL certificates not working**
   - Check if port 80/443 are accessible from internet
   - Verify domain DNS points to your server
   - Check Traefik logs: `docker logs traefik`

2. **Database connection errors**
   - Verify MariaDB container is running
   - Check environment variables in `.env`
   - Review database logs: `docker logs mariadb`

3. **File permissions issues**
   - Ensure data directories are writable
   - Check Docker volume mounts in `docker-compose.yml`
   - Verify WordPress container user permissions

4. **WordPress HTTPS redirect loops**
   - Verify proxy headers configuration in `wp-config.php`
   - Check Traefik forwarded headers configuration
   - Ensure WP_HOME and WP_SITEURL use https://

### Logs

View service logs:
```bash
docker logs traefik
docker logs nginx-internal
docker logs wordpress
docker logs mariadb
docker logs phpmyadmin
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## Support

For issues and questions:
- Create an issue in the repository
- Check the troubleshooting section
- Review Docker and Traefik documentation

---

**Note**: This project is designed for educational and development purposes. For production use, review security configurations and implement additional hardening measures.