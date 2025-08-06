terraform {
  required_providers {
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
  }
}

resource "null_resource" "scaleway_setup" {
  connection {
    type        = "ssh"
    user        = "root"
    host        = "51.159.139.86"
    private_key = file("~/.ssh/id_ed25519")
    timeout     = "5m"
  }

  provisioner "remote-exec" {
    inline = [
      "echo 'Starting Scaleway setup...'",
      
      # Check if Docker is already installed
      "if ! command -v docker &> /dev/null; then",
      "  echo 'Installing Docker...'",
      "  apt-get update -y",
      "  apt-get install -y ca-certificates curl gnupg lsb-release",
      "  mkdir -p /etc/apt/keyrings",
      "  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg --yes",
      "  chmod a+r /etc/apt/keyrings/docker.gpg",
      "  echo \"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable\" | tee /etc/apt/sources.list.d/docker.list > /dev/null",
      "  apt-get update -y",
      "  apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin",
      "  systemctl enable docker",
      "  systemctl start docker",
      "else",
      "  echo 'Docker already installed, skipping...'",
      "fi",
      
      # Ensure Docker is running
      "systemctl start docker",
      
      # Test Docker
      "docker --version",
      "docker compose version",
      "echo 'Docker setup completed!'"
    ]
  }

  provisioner "file" {
    source      = "docker-compose.yml"
    destination = "/root/docker-compose.yml"
  }

  provisioner "file" {
    source      = ".env"
    destination = "/root/.env"
  }

  provisioner "file" {
    source      = "services/"
    destination = "/root/services/"
  }

  provisioner "file" {
	  source = "Makefile"
	  destination = "/root/Makefile"
  }

  provisioner "remote-exec" {
    inline = [
      "echo 'Starting Docker Compose setup...'",
      
      "mkdir -p /root/data/wp",
      "mkdir -p /root/data/mysql",
      
      "cd /root",
      "docker compose up -d",
      "echo 'Waiting for containers to be ready...'",
      "sleep 30",
      
      "echo 'Testing HTTP access...'",
      "curl -f http://equancy-cloud-one.duckdns.org/ || echo 'HTTP test failed!'",
      
      "echo 'Waiting for SSL certificates to be generated...'",
      "sleep 60",
      
      "echo 'Testing HTTPS access...'",
      "curl -f https://equancy-cloud-one.duckdns.org/ || echo 'HTTPS not ready yet (may take a few minutes)'",
      
      "docker compose ps",
      "echo 'nginx-proxy deployment completed!'"
    ]
  }
}
