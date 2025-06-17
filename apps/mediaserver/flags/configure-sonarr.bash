#!/bin/bash

# Script para configurar automáticamente Sonarr para ejecutar lang-flags.bash
# cuando se descarguen nuevos episodios

log_info() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [INFO] $1"
}

log_error() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [ERROR] $1" >&2
}

# Configuración
SONARR_URL="http://localhost:8989"
SCRIPT_PATH="/flags/lang-flags.bash"

# Función para obtener la API key de Sonarr
get_sonarr_api_key() {
    if [[ -f "/config/config.xml" ]]; then
        grep -o '<ApiKey>[^<]*</ApiKey>' /config/config.xml | sed 's/<ApiKey>\(.*\)<\/ApiKey>/\1/'
    else
        log_error "No se pudo encontrar config.xml de Sonarr"
        return 1
    fi
}

# Función para configurar el script personalizado en Sonarr
configure_sonarr_script() {
    local api_key="$1"
    
    if [[ -z "$api_key" ]]; then
        log_error "API key de Sonarr no encontrada"
        return 1
    fi
    
    log_info "Configurando script personalizado en Sonarr..."
    
    # Verificar si ya existe una conexión para lang-flags
    local existing_connection=$(curl -s -H "X-Api-Key: $api_key" \
        "$SONARR_URL/api/v3/notification" | \
        jq -r '.[] | select(.name == "Lang-Flags Script") | .id' 2>/dev/null)
    
    if [[ -n "$existing_connection" && "$existing_connection" != "null" ]]; then
        log_info "Conexión Lang-Flags ya existe (ID: $existing_connection)"
        return 0
    fi
    
    # Crear nueva conexión
    local payload=$(cat << EOF
{
    "onGrab": false,
    "onDownload": true,
    "onUpgrade": true,
    "onRename": false,
    "onSeriesDelete": false,
    "onEpisodeFileDelete": false,
    "onEpisodeFileDeleteForUpgrade": false,
    "onHealthIssue": false,
    "onApplicationUpdate": false,
    "includeHealthWarnings": false,
    "name": "Lang-Flags Script",
    "implementation": "CustomScript",
    "configContract": "CustomScriptSettings",
    "tags": [],
    "settings": {
        "path": "$SCRIPT_PATH",
        "arguments": ""
    }
}
EOF
)
    
    local response=$(curl -s -w "%{http_code}" -o /tmp/sonarr_response.json \
        -H "Content-Type: application/json" \
        -H "X-Api-Key: $api_key" \
        -X POST \
        -d "$payload" \
        "$SONARR_URL/api/v3/notification")
    
    local http_code="${response: -3}"
    
    if [[ "$http_code" == "201" ]]; then
        log_info "✓ Script personalizado configurado exitosamente en Sonarr"
        log_info "✓ Se ejecutará automáticamente en: Download, Upgrade"
        return 0
    else
        log_error "✗ Error configurando script en Sonarr (HTTP: $http_code)"
        if [[ -f "/tmp/sonarr_response.json" ]]; then
            cat /tmp/sonarr_response.json >&2
        fi
        return 1
    fi
}

# Función principal
main() {
    log_info "=== Configurador automático de Sonarr para Lang-Flags ==="
    
    # Verificar que Sonarr esté ejecutándose
    if ! curl -s "$SONARR_URL/api/v3/system/status" >/dev/null 2>&1; then
        log_error "Sonarr no está respondiendo en $SONARR_URL"
        log_error "Asegúrate de que Sonarr esté ejecutándose"
        return 1
    fi
    
    # Obtener API key
    local api_key=$(get_sonarr_api_key)
    if [[ -z "$api_key" ]]; then
        log_error "No se pudo obtener la API key de Sonarr"
        return 1
    fi
    
    log_info "API key obtenida: ${api_key:0:8}..."
    
    # Configurar script
    if configure_sonarr_script "$api_key"; then
        log_info "🎉 Configuración completada exitosamente"
        log_info "🔄 Ahora Sonarr ejecutará lang-flags.bash automáticamente"
        log_info "📁 Los episodios se añadirán automáticamente a la cola"
        log_info "⏰ El cron procesará la cola cada 15 minutos"
    else
        log_error "❌ Error en la configuración"
        return 1
    fi
}

# Ejecutar función principal
main "$@"
