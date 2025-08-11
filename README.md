# Cloud-One

A containerized WordPress hosting solution with automated SSL certificates and Traefik reverse proxy, designed for cloud deployment on Scaleway infrastructure.

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                          Internet                               │
│                   (HTTPS Traffic)                               │
└─────────────────────────┬───────────────────────────────────────┘
                          │
                    ┌─────▼─────┐
                    │  Traefik  │ :80, :443
                    │ (Gateway) │ SSL Termination + Auto Redirect
                    │           │ Let's Encrypt ACME
                    └─────┬─────┘ Docker Service Discovery
                          │
                          │ HTTP (Internal)
              ┌───────────▼───────────┐
              │   Nginx-Internal       │ :80 (Exposed)
              │   (Web Server)         │ Static Files + FastCGI Proxy
              └───────────┬───────────┘
                          │ FastCGI :9000
              ┌───────────▼───────────┐
              │     WordPress        │ :9000 (Exposed)
              │    (PHP-FPM)         │ PHP Processing
              └───────────┬───────────┘
                          │ MySQL Protocol
              ┌───────────▼───────────┐
              │      MariaDB           │ :3306 (Exposed)
              │    (Database)          │ Data Storage
              └───────────────────────┘

    ┌─────────────────────────────────────┐
    │           phpMyAdmin                │ :8080 (Published)
    │        (DB Management)              │ Direct Host Access
    │      Connected to MariaDB           │ Development/Admin
    └─────────────────────────────────────┘

    Docker Network: "network" (Bridge)
    Volumes: mariadb-data, wordpress-data, traefik-data
```

## Description

Cloud-One is a production-ready WordPress hosting stack that combines:

- **Traefik v3**: Modern reverse proxy with automatic SSL certificate management via Let's Encrypt, HTTP to HTTPS redirection, and Docker service discovery
- **Nginx**: High-performance internal web server optimized for static content delivery and FastCGI proxy to WordPress
- **WordPress**: PHP-FPM based WordPress installation with optimized container configuration
- **MariaDB**: Reliable MySQL-compatible database with persistent storage
- **phpMyAdmin**: Web-based database administration interface accessible on port 8080

The stack implements a 4-layer architecture designed for production deployment with:
- **SSL termination** at Traefik level with automatic certificate renewal
- **Static file optimization** via Nginx caching and compression
- **Container isolation** with dedicated Docker network for inter-service communication
- **Data persistence** using bind-mounted volumes for MySQL and WordPress data
- **Infrastructure as Code** deployment using Ansible for cloud environments

### Technical Architecture Details

**Network Configuration:**
- All services communicate through a dedicated Docker bridge network named `network`
- Only essential ports are published to the host: 80/443 (Traefik) and 8080 (phpMyAdmin)
- Inter-container communication uses service names for DNS resolution

**Service Exposure:**
- **Traefik**: Publishes ports 80/443 for public web access
- **Nginx-Internal**: Exposes port 80 only to the internal Docker network
- **WordPress**: Exposes port 9000 for FastCGI communication with Nginx
- **MariaDB**: Exposes port 3306 only to internal network (secured)
- **phpMyAdmin**: Publishes port 8080 for direct host access (development)

**SSL/TLS Configuration:**
- Automatic HTTPS redirection from port 80 to 443
- Let's Encrypt certificates with HTTP-01 challenge
- Staging environment configured by default (change to production in docker-compose.yml)
- Certificate storage in named volume `traefik-data`

**Data Persistence:**
- WordPress files: `${DATA_PATH}/wp` bind mount
- MySQL data: `${DATA_PATH}/mysql` bind mount  
- Traefik configuration: `traefik-data` named volume

## Getting Started

### Prerequisites

- Docker and Docker Compose
- Make
- Ansible (for cloud deployment)
- SSH access to target server (for cloud deployment)

### Local Development

For development and testing purposes, you can work with the project locally before cloud deployment:

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd cloud-one
   ```

2. **Create environment configuration**
   ```bash
   cp .env.sample .env
   # Edit .env with your configuration (use localhost for local testing)
   ```

3. **Test deployment locally** (optional)
   ```bash
   # Test the stack locally with Docker Compose
   docker compose up -d
   ```

4. **Prepare for cloud deployment**
   ```bash
   # Configure for production deployment
   make ansible-setup
   # Edit deployment/inventory.yml with your server details
   ```

**Note:** The primary focus is cloud deployment. Local testing is optional and mainly for development purposes.

### Cloud Deployment

Cloud-One is designed for automated deployment on cloud infrastructure using Ansible. The deployment process installs Docker, configures the environment, and deploys the entire WordPress stack remotely.

1. **Setup Ansible environment**
   ```bash
   make ansible-setup
   ```
   This installs required Ansible collections and prepares the deployment environment.

2. **Configure deployment variables**
   - Update the server IP in `deployment/inventory.yml`
   - Ensure your `.env` file contains production values
   - Verify SSH key access to target server (`~/.ssh/id_ed25519`)

3. **Deploy infrastructure**
   ```bash
   make ansible-deploy
   ```
   This command will:
   - Install Docker and Docker Compose on the target server
   - Copy all necessary files (docker-compose.yml, services/, .env)
   - Build and start all containers
   - Configure SSL certificates with Let's Encrypt
   - Test HTTP/HTTPS connectivity

4. **Verify deployment**
   ```bash
   make ansible-status   # Check container status
   make ansible-logs     # View service logs
   ```

5. **Access your WordPress site**
   - Website: `https://your-domain.com`
   - phpMyAdmin: `http://your-server-ip:8080`

**Deployment Requirements:**
- Target server: Ubuntu 20.04 LTS (or compatible)
- SSH daemon running with key-based authentication
- Python installed on target server
- Domain name pointing to server IP (for SSL certificates)

### Available Commands

**Ansible Deployment Commands:**
```bash
make all              # Deploy to remote server with Ansible (same as ansible-deploy)
make ansible-deploy   # 🚀 Deploy Cloud-One stack to Scaleway server
make ansible-setup    # 🔧 Setup Ansible environment and dependencies
make ansible-ping     # 📡 Test SSH connection to remote server
make ansible-status   # 📊 Check containers status on remote server
make ansible-logs     # 📋 Fetch logs from remote server
make ansible-stop     # ⏹️  Stop containers on remote server
make ansible-restart  # 🔄 Restart containers on remote server
```

**Remote Management Commands:**
```bash
make stop             # Stop containers on remote server
make clean            # Remove containers on remote server
make fclean           # 🚨 DESTROY all Docker resources on remote server (DESTRUCTIVE)
make build            # Build Docker images on remote server
make up               # Start containers on remote server
make re               # Full remote rebuild (fclean + ansible-deploy)
make volumes          # Create required data directories on remote server
make help             # Show all available commands with descriptions
```

**Note:** All commands operate on the remote Scaleway server via Ansible. No local Docker execution.

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

- [ ] Add the functionnality to download Resume when clicking on it
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