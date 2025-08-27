#!/bin/bash

# Script para migrar de Traefik a docker-gen + nginx
# Actualiza automáticamente todos los archivos de servicio

set -e

SERVICES_DIR="services"
BACKUP_DIR="services.backup.$(date +%Y%m%d_%H%M%S)"

echo "🚀 Migrando de Traefik a docker-gen + nginx..."

# Crear backup
echo "📦 Creando backup en $BACKUP_DIR..."
cp -r "$SERVICES_DIR" "$BACKUP_DIR"

# Función para extraer el nombre del servicio del archivo
get_service_name() {
    local file="$1"
    basename "$file" .yml
}

# Función para obtener el puerto del servicio
get_service_port() {
    local file="$1"
    local service_name="$2"
    
    # Buscar el puerto en el archivo
    local port=$(grep -E "^\s*-\s+.*:[0-9]+.*#.*HTTP" "$file" | head -1 | sed -E 's/.*:([0-9]+).*/\1/')
    
    # Puertos por defecto para servicios conocidos
    case "$service_name" in
        "jellyfin") echo "8096" ;;
        "sonarr") echo "8989" ;;
        "radarr") echo "7878" ;;
        "bazarr") echo "6767" ;;
        "prowlarr") echo "9696" ;;
        "jellyseerr") echo "5055" ;;
        "lidarr") echo "8686" ;;
        "readarr") echo "8787" ;;
        "mylar3") echo "8090" ;;
        "homarr") echo "7575" ;;
        "qbittorrent") echo "8080" ;;
        "netdata") echo "19999" ;;
        "uptime-kuma") echo "3001" ;;
        "authelia") echo "9091" ;;
        "adguardhome") echo "3000" ;;
        "pihole") echo "80" ;;
        "homeassistant") echo "8123" ;;
        "portainer") echo "9000" ;;
        "code") echo "8443" ;;
        *) echo "${port:-8080}" ;;
    esac
}

# Función para determinar si un servicio necesita WebSocket
needs_websocket() {
    local service_name="$1"
    case "$service_name" in
        "jellyfin"|"homeassistant"|"netdata"|"uptime-kuma"|"code") echo "true" ;;
        *) echo "false" ;;
    esac
}

# Función para procesar cada archivo
process_service_file() {
    local file="$1"
    local service_name=$(get_service_name "$file")
    local port=$(get_service_port "$file" "$service_name")
    local websocket=$(needs_websocket "$service_name")
    
    echo "🔧 Procesando $service_name (puerto: $port, websocket: $websocket)..."
    
    # Quitar label de traefik
    sed -i '/traefik\.enable=true/d' "$file"
    
    # Buscar si ya existe la sección environment
    if grep -q "^\s*environment:" "$file"; then
        # Agregar variables docker-gen al environment existente
        sed -i "/^\s*environment:/a\\      # RaspiServer reverse proxy configuration\\n      - RASPISERVER_ENABLE=true\\n      - RASPISERVER_SUBDOMAIN=${service_name}\\n      - RASPISERVER_PORT=${port}\\n      - RASPISERVER_PROTOCOL=http\\n      - RASPISERVER_WEBSOCKET=${websocket}\\n      - RASPISERVER_MAX_BODY_SIZE=100M" "$file"
    else
        # Agregar sección environment antes de volumes
        sed -i "/^\s*volumes:/i\\    environment:\\n      # RaspiServer reverse proxy configuration\\n      - RASPISERVER_ENABLE=true\\n      - RASPISERVER_SUBDOMAIN=${service_name}\\n      - RASPISERVER_PORT=${port}\\n      - RASPISERVER_PROTOCOL=http\\n      - RASPISERVER_WEBSOCKET=${websocket}\\n      - RASPISERVER_MAX_BODY_SIZE=100M" "$file"
    fi
    
    echo "✅ $service_name actualizado"
}

# Procesar todos los archivos YAML en services/
find "$SERVICES_DIR" -name "*.yml" -type f | while read -r file; do
    # Saltar nginx-auto.yml que acabamos de crear
    if [[ "$file" == *"nginx-auto.yml"* ]] || [[ "$file" == *"nginx-proxy.yml"* ]]; then
        continue
    fi
    
    # Verificar si el archivo tiene labels de traefik
    if grep -q "traefik\.enable=true" "$file"; then
        process_service_file "$file"
    fi
done

echo ""
echo "🎉 Migración completada!"
echo "📦 Backup guardado en: $BACKUP_DIR"
echo ""
echo "📋 Próximos pasos:"
echo "1. Añadir nginx-auto al docker-compose.yml:"
echo "   - services/network/nginx-auto.yml"
echo ""
echo "2. Configurar variables en .env:"
echo "   RASPISERVER_DOMAINS=cckdev.es,localhost"
echo "   LETSENCRYPT_EMAIL=tu@email.com"
echo ""
echo "3. Crear directorios de volúmenes:"
echo "   mkdir -p volumes/nginx/{conf.d,certs,vhost.d,html,acme}"
echo ""
echo "4. Reiniciar servicios:"
echo "   docker-compose down && docker-compose up -d"
echo ""
echo "5. Los servicios estarán disponibles en:"
echo "   - servicio.cckdev.es"
echo "   - servicio.localhost"
