# RaspiServer

A comprehensive Docker-based server solution featuring multimedia streaming, home automation, VPN protection, and productivity tools.

## 🚀 Quick Start

```bash
# Clone and setup
git clone https://github.com/carcheky/raspiserver.git
cd raspiserver
cp .env.dist .env && cp docker-compose.example.yml docker-compose.yml

# Edit .env and docker-compose.yml, then start
docker-compose up -d
```

## 📚 Documentation

Complete documentation is available in the [`docs/`](docs/) directory:

- **[📖 Main Documentation](docs/README.md)** - Comprehensive overview and guides
- **[🚀 Setup Guide](docs/SETUP.md)** - Step-by-step installation instructions  
- **[⚙️ Services Guide](docs/SERVICES.md)** - Individual service configurations
- **[🏗️ Architecture](docs/ARCHITECTURE.md)** - Technical architecture details

## 🎬 Featured Services

- **Jellyfin** - Media streaming server
- **Sonarr/Radarr** - Automated media management
- **Home Assistant** - Smart home automation
- **qBittorrent** - VPN-protected downloading
- **Pi-hole** - Network-wide ad blocking

## 🛠️ Quick Commands

```bash
# View service status
docker-compose ps

# Update all services
docker-compose pull && docker-compose up -d

# View logs
docker-compose logs -f service-name

# Stop all services
docker-compose down
```

## 🔍 Service Validation

RaspiServer includes a comprehensive validation system for all 42 services:

```bash
# Validate individual service
make validate-service SERVICE=jellyfin

# Validate all services
make validate-all

# Generate GitHub issues for systematic validation
make generate-issues

# List all available services
make list-services
```

For detailed validation procedures, see [📋 Service Validation Guide](docs/SERVICE_VALIDATION_GUIDE.md).

## 📊 System Requirements

- **Minimum**: Raspberry Pi 4 (4GB RAM)
- **Recommended**: Raspberry Pi 4 (8GB RAM) or x86_64 system
- **Storage**: 32GB+ (SSD recommended)
- **OS**: Raspberry Pi OS 64-bit or Ubuntu 20.04+

## 🆘 Support

- 📖 Check the [documentation](docs/)
- 🐛 Open an [issue](https://github.com/carcheky/raspiserver/issues)
- 💬 Join the discussion

---

**Made with ❤️ for the self-hosting community**
