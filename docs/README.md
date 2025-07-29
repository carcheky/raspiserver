# RaspiServer - Complete Media & Home Automation Stack

A comprehensive Docker-based server solution featuring multimedia streaming, home automation, VPN protection, and productivity tools. Designed for Raspberry Pi and other Linux systems.

## 🚀 Quick Start

```bash
# 1. Clone the repository
git clone https://github.com/carcheky/raspiserver.git
cd raspiserver

# 2. Copy and configure environment
cp .env.dist .env
# Edit .env with your settings

# 3. Copy and customize docker-compose
cp docker-compose.example.yml docker-compose.yml
# Uncomment desired services

# 4. Start the stack
docker-compose up -d
```

## 📋 Table of Contents

- [Architecture Overview](#architecture-overview)
- [Available Services](#available-services)
- [Installation & Setup](#installation--setup)
- [Configuration](#configuration)
- [Usage](#usage)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)

## 🏗️ Architecture Overview

### Directory Structure

```
raspiserver/
├── docs/                          # 📚 Documentation
├── services/                      # 🐳 Docker Compose service definitions
│   ├── multimedia/               # Media streaming & management
│   ├── automation/               # Home automation & monitoring
│   ├── network/                  # VPN, DNS, proxy services
│   ├── productivity/             # Cloud storage & collaboration
│   ├── management/               # System management tools
│   └── others/                   # Miscellaneous services
├── configs/                       # 📋 System and application configs
│   ├── nginx/                    # Reverse proxy configurations
│   ├── raspbian/                 # Raspberry Pi system configs
│   └── homeassistant/           # Home Assistant configurations
├── apps/                          # 🔧 Custom scripts & extensions
│   ├── mediaserver/              # Media server enhancements
│   ├── homeassistant/           # HA custom components
│   ├── nordvpn/                 # VPN container customizations
│   └── tunnel/                   # Tunneling configurations
├── volumes/                       # 💾 Docker persistent data
├── scripts/                       # 🛠️ Utility scripts
├── flags/                         # 🏁 Country flags for UI
└── media/                         # 📁 Media storage
```

### Core Components

- **Docker Compose**: Orchestrates all services
- **Environment Variables**: Centralized configuration via `.env`
- **Reverse Proxy**: Nginx for subdomain routing
- **VPN Protection**: NordVPN integration for secure torrenting
- **Volume Management**: Persistent data storage
- **Health Monitoring**: Service status and uptime tracking

## 🎬 Available Services

### Multimedia Stack
- **Jellyfin** - Media streaming server
- **Sonarr** - TV series management
- **Radarr** - Movie management  
- **Jellyseerr** - Media request management
- **Jellystat** - Jellyfin analytics
- **qBittorrent** - Torrent client with VPN
- **Bazarr** - Subtitle management
- **Prowlarr** - Indexer management
- **Readarr** - Book management
- **Lidarr** - Music management

### Home Automation
- **Home Assistant** - Smart home hub
- **ESPHome** - ESP device management
- **MQTT** - IoT messaging broker

### Network & Security
- **Pi-hole** - Network-wide ad blocking
- **AdGuard Home** - Alternative DNS filtering
- **NordVPN** - VPN protection
- **Cloudflared** - Cloudflare tunnel
- **Authelia** - Authentication gateway

### Productivity
- **Nextcloud** - Self-hosted cloud storage
- **Docker Socket Proxy** - Secure Docker API access

### Monitoring & Management
- **Netdata** - Real-time system monitoring
- **Uptime Kuma** - Service uptime monitoring
- **Kener** - Status page
- **Portainer** - Docker container management

## 🛠️ Installation & Setup

For detailed installation instructions, see:
- [Setup Guide](SETUP.md) - Complete installation walkthrough
- [Services Documentation](SERVICES.md) - Individual service configurations
- [Architecture Details](ARCHITECTURE.md) - Technical deep dive

### Prerequisites

- Linux system (Raspberry Pi 4+ recommended)
- Docker & Docker Compose
- 32GB+ storage (SSD recommended)
- Static IP address (recommended)

### Basic Setup

1. **System Preparation**
   ```bash
   # Update system
   sudo apt update && sudo apt upgrade -y
   
   # Install Docker
   curl -fsSL https://get.docker.com -o get-docker.sh
   sh get-docker.sh
   sudo usermod -aG docker $USER
   ```

2. **Configure Environment**
   ```bash
   cp .env.dist .env
   nano .env  # Edit according to your setup
   ```

3. **Select Services**
   ```bash
   cp docker-compose.example.yml docker-compose.yml
   nano docker-compose.yml  # Uncomment desired services
   ```

4. **Deploy Stack**
   ```bash
   docker-compose up -d
   ```

## ⚙️ Configuration

### Environment Variables

Key variables in `.env`:

```bash
# System Configuration
PUID=1000
PGID=1000
TIMEZONE=Europe/Madrid
DOMAIN=yourdomain.com

# Storage Paths
VOLUMES_DIR=./volumes
MEDIA_DIR=/path/to/media
DOWNLOADS_DIR=/path/to/downloads

# Network Configuration
JELLYFIN_PORT=8096
SONARR_PORT=8989
RADARR_PORT=7878

# VPN Configuration
NORDVPN_USER=your_username
NORDVPN_PASS=your_password
NORDVPN_COUNTRY=Spain
```

### Service Configuration

Each service can be configured through:
- Environment variables in `.env`
- Service-specific config files in `configs/`
- Volume mounts for persistent data

## 🎯 Usage

### Starting Services

```bash
# Start all enabled services
docker-compose up -d

# Start specific service
docker-compose up -d jellyfin

# View logs
docker-compose logs -f service-name
```

### Accessing Services

Services are accessible via:
- **Direct IP**: `http://your-server-ip:port`
- **Domain**: `http://service.yourdomain.com` (with nginx)
- **Local**: `http://localhost:port` (when port forwarded)

### Common Tasks

```bash
# Update all services
docker-compose pull && docker-compose up -d

# Restart a service
docker-compose restart service-name

# Remove a service
docker-compose stop service-name
docker-compose rm service-name
```

## 🔧 Troubleshooting

### Common Issues

1. **Permission Errors**
   ```bash
   # Fix volume permissions
   sudo chown -R $USER:$USER ./volumes
   ```

2. **Port Conflicts**
   ```bash
   # Check port usage
   netstat -tulpn | grep :port
   ```

3. **VPN Connection Issues**
   ```bash
   # Check VPN logs
   docker-compose logs nordvpn
   ```

### Health Checks

```bash
# Check service status
docker-compose ps

# View resource usage
docker stats

# Check disk space
df -h
```

## 📚 Documentation

- [Setup Guide](SETUP.md) - Complete installation guide
- [Services Documentation](SERVICES.md) - Service-specific guides
- [Architecture](ARCHITECTURE.md) - Technical architecture
- [Submodule Sync](SUBMODULE_SYNC.md) - arr-scripts synchronization guide
- [Troubleshooting](TROUBLESHOOTING.md) - Common issues & solutions
- [Contributing](CONTRIBUTING.md) - Development guidelines

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [LinuxServer.io](https://linuxserver.io) for excellent Docker images
- [Home Assistant](https://home-assistant.io) community
- [Jellyfin](https://jellyfin.org) project
- All the amazing open-source projects that make this possible

---

**Made with ❤️ for the self-hosting community**
