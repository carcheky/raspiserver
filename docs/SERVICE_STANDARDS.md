# RaspiServer Service Template and Standards
# ==========================================
# This document defines the standard format for RaspiServer service definitions

## Standard Service Template

```yaml
services:
  service-name:
    image: linuxserver/service-name:latest  # Use LinuxServer images when available
    container_name: service-name            # Same as service name
    restart: unless-stopped                 # Consistent restart policy
    environment:
      # Standard environment variables (required for all services)
      - PUID=${PUID}
      - PGID=${PGID}
      - TZ=${TIMEZONE}
      # Service-specific environment variables
      - SERVICE_SPECIFIC_VAR=${VAR_NAME:-default_value}
    volumes:
      # Configuration volume (required)
      - ${VOLUMES_DIR}/service-config:/config
      # Data volumes (as needed)
      - ${MEDIA_DIR}:/media:ro               # Read-only for media consumption
      - ${DOWNLOADS_DIR}:/downloads:rw       # Read-write for downloads
      # Custom scripts and configurations
      - ./apps/service-name:/custom-scripts:ro
    ports:
      - ${SERVICE_PORT:-default}:internal_port
    # Health check (recommended for all services)
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:port/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 60s
    # Dependencies (when required)
    depends_on:
      - dependency-service
    # Resource limits (recommended)
    deploy:
      resources:
        limits:
          cpus: '2'
          memory: 2G
        reservations:
          cpus: '0.5'
          memory: 512M
    # Labels for organization and automation
    labels:
      - "traefik.enable=true"
      - "com.centurylinklabs.watchtower.enable=true"
      - "raspiserver.category=category-name"
      - "raspiserver.description=Service description"
```

## Service Categories

- **media-streaming**: Jellyfin, Plex
- **media-management**: Sonarr, Radarr, Bazarr, Prowlarr
- **downloads**: qBittorrent, Transmission
- **automation**: Home Assistant, ESPHome
- **monitoring**: Netdata, Uptime Kuma
- **network**: Pi-hole, AdGuard Home
- **productivity**: Nextcloud
- **management**: Portainer, Watchtower

## Best Practices

1. **Consistent Naming**: Use lowercase with hyphens
2. **Resource Limits**: Set appropriate CPU and memory limits
3. **Health Checks**: Implement for all services with web interfaces
4. **Volume Mappings**: Use standard paths and permissions
5. **Environment Variables**: Define defaults and use consistent naming
6. **Labels**: Include category and description for organization
7. **Dependencies**: Explicitly define service dependencies
8. **Restart Policy**: Use `unless-stopped` for better control

## Security Considerations

1. **Read-Only Mounts**: Use `:ro` for files that shouldn't be modified
2. **Minimal Privileges**: Don't run containers as root when possible
3. **Network Isolation**: Use custom networks for service groups
4. **Secrets Management**: Use environment variables for sensitive data

## Validation Checklist

- [ ] Service follows naming conventions
- [ ] Includes standard environment variables (PUID, PGID, TZ)
- [ ] Has appropriate volume mappings
- [ ] Includes health check where applicable
- [ ] Sets resource limits
- [ ] Uses correct restart policy
- [ ] Includes descriptive labels
- [ ] Defines dependencies if needed
