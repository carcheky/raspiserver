# RaspiServer - Self-Hosted Media & Home Automation Platform

A comprehensive Docker-based solution for self-hosted media streaming, automation, and productivity services.

## 🎯 Overview

RaspiServer is a modular, Docker-compose based platform that provides:

- **Media Management**: Complete *arr stack (Sonarr, Radarr, Bazarr, etc.)
- **Streaming**: Jellyfin/Plex media servers with request management
- **Home Automation**: Home Assistant integration
- **Network Security**: VPN, DNS filtering, and reverse proxy
- **Productivity**: Nextcloud and monitoring tools

## 🏗️ Architecture

```
raspiserver/
├── docs/                    # Documentation and guides
├── services/               # Docker Compose service definitions
│   ├── multimedia/        # Media management services
│   ├── automation/        # Home automation services
│   ├── network/          # Network and security services
│   ├── productivity/     # Productivity applications
│   └── others/           # Miscellaneous services
├── configs/               # System and application configurations
├── apps/                  # Custom scripts and app-specific files
├── volumes/              # Docker volumes for persistent data
└── scripts/              # Utility and management scripts
```

## 🚀 Quick Start

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd raspiserver
   ```

2. **Setup environment**
   ```bash
   cp .env.dist .env
   # Edit .env with your configuration
   ```

3. **Choose your services**
   ```bash
   # Edit docker-compose.yml to uncomment desired services
   nano docker-compose.yml
   ```

4. **Deploy**
   ```bash
   docker-compose up -d
   ```

## 📚 Documentation

- **[Service Documentation](SERVICES.md)** - Detailed service descriptions
- **[Setup Guide](SETUP.md)** - Complete installation guide
- **[Architecture](ARCHITECTURE.md)** - System design and structure
- **[Configuration](CONFIGURATION.md)** - Configuration management

## � Management

### Service Management

```bash
# Start specific services
docker-compose up -d jellyfin sonarr radarr

# View logs
docker-compose logs -f [service-name]

# Update services
docker-compose pull && docker-compose up -d
```

### Backup & Maintenance

```bash
# Run maintenance scripts
./scripts/verify-services.sh

# Helper scripts available in scripts/
```

## 📊 Default Services

### Core Media Stack
- **Jellyfin** (`:8096`) - Media server
- **Sonarr** (`:8989`) - TV series management
- **Radarr** (`:7878`) - Movie management
- **Jellyseerr** (`:5055`) - Request management

### Optional Services
- **Bazarr** - Subtitle management
- **Prowlarr** - Indexer management
- **Home Assistant** - Home automation
- **Nextcloud** - File sync and collaboration

## 🔐 Security

- VPN integration with NordVPN
- DNS filtering with AdGuard Home/Pi-hole
- Reverse proxy with Nginx
- SSL/TLS termination

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## 📝 License

[Add your license here]

## 🆘 Support

- Check [troubleshooting guide](docs/TROUBLESHOOTING.md)
- Review service logs: `docker-compose logs [service]`
- Verify service status: `./scripts/verify-services.sh`
