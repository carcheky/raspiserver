# 🔧 Service Quick Reference

## 🎯 Quick Access Commands

### Service Management
```bash
# Start all services
docker-compose up -d

# Stop all services  
docker-compose down

# Restart specific service
docker-compose restart [service-name]

# View service logs
docker-compose logs -f [service-name]

# Check service status
docker-compose ps
```

### Health Check Commands
```bash
# Check all service health
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# Monitor specific service
docker logs --tail 50 -f [container-name]

# Inspect service configuration
docker inspect [container-name]
```

## 📋 Service Categories Quick Reference

### 🎬 Multimedia Services
| Service | Port | Health Check | Purpose |
|---------|------|--------------|---------|
| **Jellyfin** | 8096 | HTTP /health | Media streaming server |
| **Sonarr** | 8989 | HTTP /ping | TV series automation |
| **Radarr** | 7878 | HTTP /ping | Movie automation |
| **Jellyseerr** | 5055 | HTTP /api/v1/status | Media request management |
| **Prowlarr** | 9696 | HTTP /ping | Indexer management |
| **Readarr** | 8787 | HTTP /ping | Book collection manager |
| **Lidarr** | 8686 | HTTP /ping | Music collection manager |
| **Bazarr** | 6767 | HTTP /ping | Subtitle management |
| **Mylar3** | 8090 | HTTP /ping | Comic collection manager |

### 🌐 Network & Security
| Service | Port | Health Check | Purpose |
|---------|------|--------------|---------|
| **Pi-hole** | 80, 53 | HTTP /admin/api.php | Network-wide ad blocking |
| **NordVPN** | - | Process check | VPN client |
| **Cloudflared** | - | Process check | Cloudflare tunnel |
| **Authelia** | 9091 | HTTP /api/health | Multi-factor authentication |
| **Nginx Proxy Manager** | 81, 80, 443 | HTTP /api | Reverse proxy with SSL |
| **WireGuard** | 51820 | Process check | VPN server |
| **AdGuard Home** | 3000, 53 | HTTP / | DNS filtering |
| **NordVPN Meshnet** | - | Process check | Peer-to-peer networking |

### 🔧 Management & Infrastructure  
| Service | Port | Health Check | Purpose |
|---------|------|--------------|---------|
| **RaspiServer Admin** | 5000 | HTTP / | RaspiServer management interface |
| **Portainer** | 9443 | HTTP /api/system/status | Docker management |
| **Portainer Agent** | 9001 | TCP port check | Docker agent |
| **Watchtower** | - | Process check | Automatic updates |
| **Dockge** | 5001 | HTTP /api/info | Docker stack manager |
| **Homarr** | 7575 | HTTP /api/configs | Service dashboard |
| **VS Code Server** | 8443 | HTTP /healthz | Web-based development |
| **Cosmos Server** | 80, 443 | HTTP / | Infrastructure management |
| **Docker Socket Proxy** | 2375 | TCP port check | Secure Docker access |

### 📊 Monitoring & Automation
| Service | Port | Health Check | Purpose |
|---------|------|--------------|---------|
| **Netdata** | 19999 | HTTP /api/v1/info | System monitoring |
| **Uptime Kuma** | 3001 | HTTP /api/status-page/heartbeat | Service uptime monitoring |
| **Home Assistant** | 8123 | HTTP /api/ | Home automation |
| **ESPHome** | 6052 | HTTP / | IoT device management |
| **MQTT** | 1883 | TCP port check | IoT messaging broker |
| **Kener** | 3000 | HTTP / | Status page monitoring |
| **n8n** | 5678 | HTTP /healthz | Workflow automation |
| **Activepieces** | 80 | HTTP /api/v1/flags | No-code automation |
| **ThingsBoard** | 9090 | HTTP /api/noauth/health | IoT data platform |

### ☁️ Productivity & Workflows
| Service | Port | Health Check | Purpose |
|---------|------|--------------|---------|
| **Nextcloud** | 80 | HTTP /status.php | Cloud storage platform |
| **MariaDB** | 3306 | mysqladmin ping | Database for Nextcloud |
| **Jellystat** | 3000 | HTTP /api/health | Jellyfin analytics |
| **PostgreSQL** | 5432 | pg_isready | Database service |
| **Redis** | 6379 | redis-cli ping | Cache service |

### 🔄 Others
| Service | Port | Health Check | Purpose |
|---------|------|--------------|---------|
| **qBittorrent** | 8080 | HTTP /api/v2/app/version | BitTorrent client |
| **Telegram Bot** | - | Process check | Media notifications |
| **Wizarr** | 5690 | HTTP /api/health | User invitation system |
| **Janitorr** | 8978 | HTTP / | Media cleanup |
| **Plex** | 32400 | HTTP /identity | Alternative media server |
| **Soulseek** | 2234 | TCP port check | P2P music sharing |
| **Room Assistant** | 6415 | HTTP /status | Presence detection |

## 🚨 Troubleshooting Quick Commands

### Common Issues
```bash
# Check Docker system status
docker system df
docker system prune -f

# Check resource usage
docker stats --no-stream

# Check network connectivity
docker network ls
docker network inspect raspiserver_default

# Check volume mounts
docker volume ls
docker volume inspect [volume-name]
```

### Health Check Debugging
```bash
# Manual health check for specific service
docker exec [container-name] [health-check-command]

# Check container resource limits
docker inspect [container-name] | grep -A 10 "Resources"

# Monitor real-time logs
docker-compose logs -f --tail=100 [service-name]
```

### Performance Monitoring
```bash
# Check system resources
htop
free -h
df -h

# Check Docker performance
docker stats
docker system events

# Check service startup times
docker-compose up --timestamps
```

## 📱 Service Access URLs

### Web Interfaces
- **Jellyfin**: http://localhost:8096
- **Home Assistant**: http://localhost:8123  
- **Pi-hole**: http://localhost/admin
- **Portainer**: https://localhost:9443
- **Netdata**: http://localhost:19999
- **Uptime Kuma**: http://localhost:3001
- **Nextcloud**: http://localhost (via nginx proxy)
- **Sonarr**: http://localhost:8989
- **Radarr**: http://localhost:7878
- **Jellyseerr**: http://localhost:5055

### Management Dashboards
- **RaspiServer Admin**: http://localhost:5000
- **Homarr**: http://localhost:7575
- **Dockge**: http://localhost:5001
- **VS Code**: https://localhost:8443
- **Cosmos**: http://localhost (via proxy)

## 🔄 Update Procedures

### Automatic Updates (Watchtower)
Services are automatically updated by Watchtower based on labels:
- **Enable**: `com.centurylinklabs.watchtower.enable=true`
- **Disable**: `com.centurylinklabs.watchtower.enable=false`
- **Monitor only**: `com.centurylinklabs.watchtower.monitor-only=true`

### Manual Updates
```bash
# Update specific service
docker-compose pull [service-name]
docker-compose up -d [service-name]

# Update all services
docker-compose pull
docker-compose up -d
```

## 🎯 Quick Health Check Script
```bash
#!/bin/bash
# Quick health check for all services
echo "🔍 Checking service health..."
docker ps --format "table {{.Names}}\t{{.Status}}" | grep -E "(healthy|Up)"
echo "📊 System resources:"
free -h | head -2
df -h / | tail -1
echo "✅ Health check complete!"
```

---
*Last updated: Project completion at 100% standardization*
