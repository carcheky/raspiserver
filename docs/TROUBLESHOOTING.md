# Troubleshooting Guide - RaspiServer

Common issues and solutions for the RaspiServer platform.

## 📋 Table of Contents

- [General Troubleshooting](#general-troubleshooting)
- [Service-Specific Issues](#service-specific-issues)
- [Network Issues](#network-issues)
- [Storage Issues](#storage-issues)
- [Performance Issues](#performance-issues)
- [Security Issues](#security-issues)

## 🔧 General Troubleshooting

### Basic Health Checks

#### Check Docker Status
```bash
# Docker service status
sudo systemctl status docker

# Docker version
docker --version
docker-compose --version

# Container status
docker-compose ps
```

#### Check System Resources
```bash
# Memory usage
free -h

# Disk space
df -h

# CPU usage
htop

# Docker resource usage
docker stats
```

#### Check Service Logs
```bash
# All services
docker-compose logs

# Specific service
docker-compose logs -f service-name

# Last 100 lines
docker-compose logs --tail=100 service-name
```

### Common Commands

#### Restart Services
```bash
# Restart all services
docker-compose restart

# Restart specific service
docker-compose restart service-name

# Stop and start (full restart)
docker-compose down && docker-compose up -d
```

#### Update Services
```bash
# Pull latest images
docker-compose pull

# Update running services
docker-compose up -d

# Update specific service
docker-compose pull service-name
docker-compose up -d service-name
```

#### Clean Up Docker
```bash
# Remove unused containers
docker container prune

# Remove unused images
docker image prune

# Remove unused volumes (BE CAREFUL!)
docker volume prune

# Full cleanup (BE VERY CAREFUL!)
docker system prune -a
```

## 🚨 Service-Specific Issues

### Jellyfin

#### Issue: Video Won't Play / Transcoding Fails
**Symptoms**: Videos buffer constantly or won't start
**Solutions**:
```bash
# Check transcoding logs
docker-compose logs jellyfin | grep -i transcode

# Verify hardware acceleration
docker-compose exec jellyfin ls -la /dev/dri

# Check ffmpeg capabilities
docker-compose exec jellyfin ffmpeg -hwaccels
```

**Common Fixes**:
- Disable hardware acceleration temporarily
- Check video codec compatibility
- Verify sufficient CPU/memory

#### Issue: Library Not Updating
**Symptoms**: New media files don't appear
**Solutions**:
```bash
# Check file permissions
ls -la /path/to/media

# Fix permissions
sudo chown -R $USER:$USER /path/to/media
sudo chmod -R 755 /path/to/media

# Force library scan
# Go to Jellyfin dashboard > Libraries > Scan All Libraries
```

### Sonarr/Radarr

#### Issue: Downloads Not Starting
**Symptoms**: Episodes/movies queued but not downloading
**Solutions**:
```bash
# Check qBittorrent connection
docker-compose logs sonarr | grep -i qbittorrent

# Test download client
# Go to Settings > Download Clients > Test
```

**Common Fixes**:
- Verify qBittorrent is running and accessible
- Check download client settings
- Verify indexer connections

#### Issue: Files Not Moving After Download
**Symptoms**: Downloads complete but don't appear in media folders
**Solutions**:
```bash
# Check completed downloads
ls -la /downloads/complete/

# Check Sonarr/Radarr logs
docker-compose logs radarr | grep -i "import"

# Verify path mappings
# Downloads: /downloads
# Media: /media
```

**Common Fixes**:
- Check path mappings in settings
- Verify file permissions
- Check available disk space

### qBittorrent

#### Issue: VPN Not Working
**Symptoms**: Real IP visible, ISP warnings
**Solutions**:
```bash
# Check NordVPN container
docker-compose logs nordvpn

# Check qBittorrent network
docker-compose exec qbittorrent curl ifconfig.me

# Verify kill switch
docker-compose exec qbittorrent ping 8.8.8.8
```

**Common Fixes**:
- Restart NordVPN container
- Check credentials in .env
- Verify VPN server selection

#### Issue: Can't Access Web UI
**Symptoms**: qBittorrent web interface unreachable
**Solutions**:
```bash
# Check if container is running
docker-compose ps qbittorrent

# Check port binding
docker-compose ps | grep 8080

# Reset admin password
docker-compose exec qbittorrent cat /config/qBittorrent/config/qBittorrent.conf | grep WebUI
```

### Home Assistant

#### Issue: Add-ons Won't Install
**Symptoms**: HACS or add-ons fail to install
**Solutions**:
```bash
# Check logs
docker-compose logs homeassistant

# Check disk space
df -h

# Restart Home Assistant
docker-compose restart homeassistant
```

#### Issue: Integrations Not Working
**Symptoms**: Devices not responding or updating
**Solutions**:
- Check device connectivity
- Restart integration
- Check Home Assistant logs
- Verify network configuration

### Pi-hole

#### Issue: DNS Not Working
**Symptoms**: Ads not blocked, DNS resolution fails
**Solutions**:
```bash
# Check Pi-hole logs
docker-compose logs pihole

# Test DNS resolution
nslookup google.com your-pi-ip

# Check router DNS settings
```

**Common Fixes**:
- Set router DNS to Pi-hole IP
- Flush DNS cache on devices
- Check Pi-hole admin interface

## 🌐 Network Issues

### Port Conflicts

#### Issue: Port Already in Use
**Symptoms**: Service fails to start with port binding error
**Solutions**:
```bash
# Check what's using the port
sudo netstat -tulpn | grep :8096

# Kill process using port
sudo kill -9 PID

# Change port in .env file
nano .env
```

### DNS Issues

#### Issue: Services Can't Resolve Hostnames
**Symptoms**: Container networking errors
**Solutions**:
```bash
# Check Docker DNS
docker-compose exec service-name nslookup google.com

# Check container networking
docker network ls
docker network inspect bridge
```

### Firewall Issues

#### Issue: External Access Blocked
**Symptoms**: Services unreachable from other devices
**Solutions**:
```bash
# Check UFW status
sudo ufw status

# Allow specific ports
sudo ufw allow 8096/tcp

# Check iptables rules
sudo iptables -L
```

## 💾 Storage Issues

### Disk Space

#### Issue: No Space Left on Device
**Symptoms**: Services crash, downloads fail
**Solutions**:
```bash
# Check disk usage
df -h

# Find large files
sudo du -h / | sort -rh | head -20

# Clean Docker
docker system prune -a

# Clean logs
sudo truncate -s 0 /var/log/*.log
```

### Permissions

#### Issue: Permission Denied Errors
**Symptoms**: Files can't be read/written
**Solutions**:
```bash
# Check current permissions
ls -la problematic-directory

# Fix ownership
sudo chown -R $USER:$USER directory

# Fix permissions
sudo chmod -R 755 directory

# Check PUID/PGID in .env
id
nano .env
```

### Mount Issues

#### Issue: External Storage Not Accessible
**Symptoms**: Media files not found
**Solutions**:
```bash
# Check mounts
mount | grep media

# Check /etc/fstab
cat /etc/fstab

# Remount drive
sudo umount /mnt/media
sudo mount -a
```

## ⚡ Performance Issues

### High CPU Usage

#### Issue: System Slow, High Load
**Solutions**:
```bash
# Check top processes
htop

# Check Docker stats
docker stats

# Limit container resources
# Add to docker-compose.yml:
# deploy:
#   resources:
#     limits:
#       cpus: '2.0'
#       memory: 1G
```

### High Memory Usage

#### Issue: Out of Memory Errors
**Solutions**:
```bash
# Check memory usage
free -h

# Check swap usage
swapon --show

# Add swap file
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
```

### Slow Network

#### Issue: Streaming Buffers, Slow Downloads
**Solutions**:
```bash
# Check network speed
speedtest-cli

# Check VPN impact
# Compare speeds with/without VPN

# Check transcoding settings
# Lower quality settings in Jellyfin
```

## 🔒 Security Issues

### Certificate Issues

#### Issue: SSL/TLS Errors
**Solutions**:
```bash
# Check certificate validity
openssl x509 -in cert.pem -text -noout

# Renew Let's Encrypt certificates
certbot renew

# Check nginx configuration
nginx -t
```

### Authentication Issues

#### Issue: Can't Login to Services
**Solutions**:
```bash
# Reset service passwords
# Check service documentation for reset procedures

# Check authentication logs
docker-compose logs service-name | grep -i auth

# Verify user credentials
```

## 🆘 Emergency Procedures

### Complete System Recovery

#### If Services Won't Start
```bash
# Stop everything
docker-compose down

# Check system health
docker system df
df -h
free -h

# Clean up if needed
docker system prune

# Start essential services only
docker-compose up -d essential-service-name
```

#### If System is Unresponsive
```bash
# SSH into system
ssh user@pi-ip

# Check system load
uptime
htop

# Kill problematic containers
docker kill container-name

# Reboot if necessary
sudo reboot
```

### Backup Recovery

#### Restore from Backup
```bash
# Stop services
docker-compose down

# Restore volumes
tar -xzf volumes-backup.tar.gz

# Restore configurations
tar -xzf configs-backup.tar.gz

# Start services
docker-compose up -d
```

## 📞 Getting Help

### Information to Gather

Before asking for help, collect:
```bash
# System information
uname -a
cat /etc/os-release

# Docker information
docker --version
docker-compose --version

# Service status
docker-compose ps

# Recent logs
docker-compose logs --tail=50 problematic-service

# System resources
free -h
df -h
```

### Where to Get Help

1. **Documentation**: Check [docs/](../README.md)
2. **GitHub Issues**: Search existing issues
3. **Service Forums**: Check specific service communities
4. **Discord/Reddit**: Home server communities

### Creating Good Bug Reports

Include:
- Clear description of the problem
- Steps to reproduce
- Expected vs actual behavior
- System information
- Relevant log excerpts
- Configuration files (remove secrets!)

---

**Remember**: Always backup your configuration before making major changes!
