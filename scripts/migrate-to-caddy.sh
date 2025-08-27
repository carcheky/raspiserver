#!/bin/bash

# Script para migrar servicios a Caddy
# Reemplaza las etiquetas RASPISERVER por etiquetas Caddy

set -e

SERVICES_DIR="services"
BACKUP_DIR="services.backup.caddy.$(date +%Y%m%d_%H%M%S)"

echo "🚀 Migrando servicios a Caddy..."

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

# Función para procesar cada archivo
process_service_file() {
    local file="$1"
    local service_name=$(get_service_name "$file")
    local port=$(get_service_port "$file" "$service_name")
    
    echo "🔧 Procesando $service_name (puerto: $port)..."
    
    # Quitar etiquetas RASPISERVER
    sed -i '/RASPISERVER_ENABLE/d' "$file"
    sed -i '/RASPISERVER_SUBDOMAIN/d' "$file"
    sed -i '/RASPISERVER_PORT/d' "$file"
    sed -i '/RASPISERVER_PROTOCOL/d' "$file"
    sed -i '/RASPISERVER_WEBSOCKET/d' "$file"
    sed -i '/RASPISERVER_MAX_BODY_SIZE/d' "$file"
    
    # Buscar si ya existe la sección labels
    if grep -q "^\s*labels:" "$file"; then
        # Agregar etiquetas Caddy a labels existentes
        sed -i "/^\s*labels:/a\\      # Caddy reverse proxy configuration\\n      - \"caddy=${service_name}.\${RASPISERVER_DOMAINS:-cckdev.es,localhost}\"\\n      - \"caddy.reverse_proxy={{upstreams ${port}}}\"\\n      - \"caddy.header=/ X-Forwarded-Proto {scheme}\"" "$file"
    else
        # Agregar sección labels antes del final del servicio
        sed -i "/^\s*restart:/a\\    labels:\\n      # Caddy reverse proxy configuration\\n      - \"caddy=${service_name}.\${RASPISERVER_DOMAINS:-cckdev.es,localhost}\"\\n      - \"caddy.reverse_proxy={{upstreams ${port}}}\"\\n      - \"caddy.header=/ X-Forwarded-Proto {scheme}\"" "$file"
    fi
    
    echo "✅ $service_name actualizado para Caddy"
}

# Procesar todos los archivos YAML en services/
find "$SERVICES_DIR" -name "*.yml" -type f | while read -r file; do
    # Saltar archivos de proxy
    if [[ "$file" == *"nginx-auto.yml"* ]] || [[ "$file" == *"nginx-proxy.yml"* ]] || [[ "$file" == *"caddy-auto.yml"* ]]; then
        continue
    fi
    
    # Verificar si el archivo tiene etiquetas RASPISERVER
    if grep -q "RASPISERVER_ENABLE=true" "$file"; then
        process_service_file "$file"
    fi
done

echo ""
echo "🎉 Migración a Caddy completada!"
echo "📦 Backup guardado en: $BACKUP_DIR"
echo ""
echo "📋 Próximos pasos:"
echo "1. Detener nginx si está ejecutándose:"
echo "   docker-compose -f docker-compose-test.yml down"
echo ""
echo "2. Actualizar docker-compose.yml:"
echo "   Cambiar nginx-auto.yml por caddy-auto.yml"
echo ""
echo "3. Crear directorios de volúmenes:"
echo "   mkdir -p volumes/caddy/{data,config}"
echo ""
echo "4. Iniciar servicios:"
echo "   docker-compose up -d"
echo ""
echo "5. Los servicios estarán disponibles automáticamente en:"
echo "   - servicio.cckdev.es"
echo "   - servicio.localhost"
echo "   - localhost/servicio (con configuración adicional)"
