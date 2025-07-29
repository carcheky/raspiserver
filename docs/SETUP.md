# Setup Guide - RaspiServer Installation

This guide provides step-by-step instructions for setting up RaspiServer on your system.

## 📋 Prerequisites

### Hardware Requirements

- **Minimum**: Raspberry Pi 4 (4GB RAM)
- **Recommended**: Raspberry Pi 4 (8GB RAM) or x86_64 system
- **Storage**: 32GB+ microSD card or SSD
- **Network**: Ethernet connection (recommended)

### Software Requirements

- **OS**: Raspberry Pi OS (64-bit) or Ubuntu 20.04+
- **Docker**: Version 20.10+
- **Docker Compose**: Version 2.0+
- **Git**: For cloning repository

## 🚀 Installation Steps

### Step 1: System Preparation

#### Update System
```bash
sudo apt update && sudo apt upgrade -y
sudo reboot
```

#### Install Dependencies
```bash
# Essential packages
sudo apt install -y curl wget git htop nano

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
sudo usermod -aG docker $USER
sudo systemctl enable docker
```

#### Install Docker Compose
```bash
# For ARM64 (Raspberry Pi)
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Verify installation
docker --version
docker-compose --version
```

### Step 2: Clone Repository

```bash
# Create directory
mkdir -p ~/mediacheky
cd ~/mediacheky

# Clone repository
git clone https://github.com/carcheky/raspiserver.git
cd raspiserver

# Initialize submodules (required for arr-scripts)
git submodule update --init --recursive
```

### Step 3: Configure Environment

#### Create Environment File
```bash
cp .env.dist .env
nano .env
```

#### Key Environment Variables

```bash
# System Configuration
PUID=1000                    # Your user ID (run 'id' to get)
PGID=1000                    # Your group ID
TIMEZONE=Europe/Madrid       # Your timezone
DOMAIN=yourdomain.com        # Your domain (optional)

# Storage Configuration
VOLUMES_DIR=./volumes        # Docker volumes location
MEDIA_DIR=/mnt/media         # Media storage path
DOWNLOADS_DIR=/mnt/downloads # Downloads path

# Network Configuration
JELLYFIN_PORT=8096
SONARR_PORT=8989
RADARR_PORT=7878
JELLYSEERR_PORT=5055
HOMEASSISTANT_PORT=8123

# VPN Configuration (if using)
NORDVPN_USER=your_username
NORDVPN_PASS=your_password
NORDVPN_COUNTRY=Spain
NORDVPN_GROUP=P2P
```

### Step 4: Storage Setup

#### Create Media Directories
```bash
# Create media structure
sudo mkdir -p /mnt/media/{movies,tv,music,books}
sudo mkdir -p /mnt/downloads/{complete,incomplete}

# Set permissions
sudo chown -R $USER:$USER /mnt/media /mnt/downloads
sudo chmod -R 755 /mnt/media /mnt/downloads
```

#### External Storage (Optional)
```bash
# Mount external drive (example)
sudo mkdir -p /mnt/external
sudo mount /dev/sda1 /mnt/external

# Make permanent (add to /etc/fstab)
echo '/dev/sda1 /mnt/external ext4 defaults,nofail 0 2' | sudo tee -a /etc/fstab
```

### Step 5: Configure Services

#### Copy Docker Compose Template
```bash
cp docker-compose.example.yml docker-compose.yml
nano docker-compose.yml
```

#### Select Services to Enable

Uncomment the services you want to run:

**Minimal Setup (Basic Media Server)**
```yaml
include:
  - services/multimedia/jellyfin.yml
  - services/multimedia/sonarr.yml
  - services/multimedia/radarr.yml
  - services/others/qbittorrent.yml
```

**Full Media Stack**
```yaml
include:
  # Multimedia
  - services/multimedia/jellyfin.yml
  - services/multimedia/sonarr.yml
  - services/multimedia/radarr.yml
  - services/multimedia/jellyseerr.yml
  - services/multimedia/bazarr.yml
  - services/multimedia/prowlarr.yml
  - services/others/qbittorrent.yml
  
  # Home Automation
  - services/automation/homeassistant.yml
  
  # Network
  - services/network/pihole.yml
```

### Step 6: Deploy Services

#### Start Services
```bash
# Create required directories
mkdir -p volumes

# Start services
docker-compose up -d

# Check status
docker-compose ps
```

#### Verify Installation
```bash
# Check logs
docker-compose logs

# Check service health
docker-compose ps --format "table {{.Name}}\t{{.Status}}\t{{.Ports}}"
```

## 🔧 Initial Configuration

### Jellyfin Setup

1. Open `http://your-ip:8096`
2. Run initial setup wizard
3. Add media libraries:
   - Movies: `/media/movies`
   - TV Shows: `/media/tv`
   - Music: `/media/music`

### Sonarr/Radarr Setup

1. **Sonarr**: `http://your-ip:8989`
2. **Radarr**: `http://your-ip:7878`

Configuration steps:
1. Add download client (qBittorrent)
2. Add indexers (via Prowlarr if enabled)
3. Set media paths
4. Configure quality profiles

### qBittorrent Setup

1. Open `http://your-ip:8080`
2. Default credentials: `admin`/`adminadmin`
3. Change password
4. Configure downloads path: `/downloads`

### Home Assistant (if enabled)

1. Open `http://your-ip:8123`
2. Run initial setup
3. Install HACS (Home Assistant Community Store)
4. Configure integrations

## 🌐 Network Configuration

### Port Forwarding

If accessing from outside your network:

```
Service          Port    Protocol
Jellyfin         8096    TCP
Home Assistant   8123    TCP
```

### Reverse Proxy (Optional)

For subdomain access, configure nginx:

1. Enable nginx service in docker-compose
2. Configure DNS records
3. Set up SSL certificates

### VPN Protection

For secure torrenting:

1. Configure NordVPN credentials in `.env`
2. Enable NordVPN service
3. Route qBittorrent through VPN

## 🛡️ Security Considerations

### Basic Security
```bash
# Change default passwords
# Use strong passwords
# Enable UFW firewall
sudo ufw enable
sudo ufw allow 22    # SSH
sudo ufw allow 8096  # Jellyfin
sudo ufw allow 8123  # Home Assistant
```

### SSL/TLS
- Use Let's Encrypt certificates
- Configure nginx for HTTPS
- Redirect HTTP to HTTPS

### Access Control
- Use VPN for remote access
- Configure authentication for services
- Regular security updates

## 📊 Monitoring & Maintenance

### Health Checks
```bash
# Service status
docker-compose ps

# Resource usage
docker stats

# Disk space
df -h

# System resources
htop
```

### Backup Strategy
```bash
# Backup configurations
tar -czf configs-backup.tar.gz configs/ .env

# Backup volumes
tar -czf volumes-backup.tar.gz volumes/

# Schedule regular backups
crontab -e
# Add: 0 2 * * * /path/to/backup-script.sh
```

### Updates
```bash
# Update services
docker-compose pull
docker-compose up -d

# Update system
sudo apt update && sudo apt upgrade -y
```

## 🔍 Troubleshooting

### Common Issues

#### Permission Errors
```bash
# Fix volume permissions
sudo chown -R $USER:$USER ./volumes
sudo chmod -R 755 ./volumes
```

#### Port Conflicts
```bash
# Check port usage
sudo netstat -tulpn | grep :8096
```

#### Service Won't Start
```bash
# Check logs
docker-compose logs service-name

# Restart service
docker-compose restart service-name
```

#### Out of Disk Space
```bash
# Clean Docker
docker system prune -a

# Clean old images
docker image prune -a
```

### Log Locations
```
Docker logs: docker-compose logs service-name
System logs: /var/log/syslog
Service logs: ./volumes/service-name/logs/
```

## 📚 Next Steps

After installation:

1. [Configure individual services](SERVICES.md)
2. [Set up home automation](SERVICES.md#home-automation)
3. [Configure monitoring tools](SERVICES.md#monitoring--management)
4. [Review backup procedures](TROUBLESHOOTING.md#backup-recovery)

## 🆘 Getting Help

- Check [Troubleshooting Guide](TROUBLESHOOTING.md)
- Review service logs
- Join community forums
- Open GitHub issue

---

**Tip**: Start with minimal services and gradually add more as you become comfortable with the setup.
