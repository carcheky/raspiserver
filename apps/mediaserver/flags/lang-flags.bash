#!/bin/bash

# PROTECCIÓN: Solo ejecutar dentro de contenedores
if [[ ! -f /.dockerenv ]] && [[ -z "$SONARR_INSTANCE_NAME" ]] && [[ -z "$RADARR_INSTANCE_NAME" ]]; then
    echo "❌ ERROR: Este script SOLO debe ejecutarse dentro de contenedores Sonarr/Radarr"
    echo "❌ NO ejecutar en el host - puede dañar el sistema"
    echo "❌ Uso correcto: ejecutar desde dentro del contenedor Docker"
    exit 1
fi

# Script para procesamiento de flags de idioma en metadatos
# Versión: 2.1
# Autor: MediaCheky
# Descripción: Procesa colas de imágenes para agregar overlays de idioma

# ========================
# Configurable Variables
# ========================
scriptName="Lang-Flags"
scriptVersion="2.1"
DEBUG=false

# ========================
# Logging Functions
# ========================

# Logging estructurado con timestamps
log_with_level() {
    local level="$1"
    local message="$2"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$level] $message" | tee -a "${LOG_FILE:-/tmp/lang-flags.log}"
}

log_info() {
    log_with_level "INFO" "$1"
}

log_error() {
    log_with_level "ERROR" "$1" >&2
}

log_warning() {
    log_with_level "WARNING" "$1" >&2
}

log_debug() {
    if [ "$DEBUG" = true ]; then
        log_with_level "DEBUG" "$1"
    fi
}

# Configuración del archivo de log
logfileSetup() {
    local log_dir="/config/logs"
    if [ ! -d "$log_dir" ]; then
        mkdir -p "$log_dir" 2>/dev/null || log_dir="/config"
    fi

    LOG_FILE="$log_dir/$scriptName-$(date +"%Y_%m_%d_%H_%M").log"

    # Crear archivo de log si no existe
    if [ ! -f "$LOG_FILE" ]; then
        touch "$LOG_FILE" 2>/dev/null || LOG_FILE="/tmp/lang-flags.log"
        chmod 666 "$LOG_FILE" 2>/dev/null || true
    fi

    # Limpiar logs antiguos (más de 5 días)
    find "$log_dir" -type f -name "$scriptName-*.log" -mtime +5 -delete 2>/dev/null || true

    log_info "Log iniciado: $LOG_FILE"
}

# ========================
# Directory Management
# ========================

# Crear directorio de forma segura
create_directory_safe() {
    local dir="$1"
    if [[ -n "$dir" ]] && mkdir -p "$dir" 2>/dev/null; then
        chmod 755 "$dir" 2>/dev/null || true
        log_debug "Directorio creado: $dir"
        return 0
    else
        log_error "No se pudo crear directorio: $dir"
        return 1
    fi
}

# ========================
# Configuration Variables
# ========================

# Configuración de directorios
FLAGS_DIR="/flags"
METADATA_CACHE_DIR="$FLAGS_DIR/cache/metadata"
QUEUE_DIR="$FLAGS_DIR/queue"
TMP_DIR="$FLAGS_DIR/tmp"
OVERLAY_DIR="$FLAGS_DIR/4x3"

# Archivos de cola
RADARR_QUEUE_FILE="$QUEUE_DIR/radarr_queue.txt"
SONARR_QUEUE_FILE="$QUEUE_DIR/sonarr_queue.txt"
QUEUE_LOCK_FILE="$QUEUE_DIR/monitor.lock"

# Configuración de medios
MOVIES_DIR="/BibliotecaMultimedia/Peliculas"
SERIES_DIR="/BibliotecaMultimedia/Series"

# Configuración de overlay
flag_width=400
flag_height=300
poster_resize="2560x1440"
vertical_resize="1920x2880"

# Variables de optimización
CACHE_EXPIRE_DAYS=7
MAX_PARALLEL_JOBS=1
MONITOR_INTERVAL=30
IMAGEMAGICK_MEMORY_LIMIT="1GiB"
FORCE_UPDATE=false
NFO_WAIT_SECONDS=30

# ========================
# Queue Management
# ========================

# Limpiar duplicados de archivos de cola
clean_queue_duplicates() {
    local queue_file="$1"

    if [ ! -f "$queue_file" ] || [ ! -s "$queue_file" ]; then
        return 0
    fi

    log_debug "Limpiando duplicados de $(basename "$queue_file")"

    local original_count=$(wc -l <"$queue_file" 2>/dev/null || echo 0)
    local temp_file="$FLAGS_DIR/temp_clean_$$_$(date +%s).tmp"

    if touch "$temp_file" 2>/dev/null; then
        # Ordenar por path del archivo y timestamp, mantener solo la entrada más reciente por path
        if sort -t'|' -k3,3 -k1,1r "$queue_file" 2>/dev/null | awk -F'|' '!seen[$3]++' >"$temp_file" 2>/dev/null; then
            local clean_count=$(wc -l <"$temp_file" 2>/dev/null || echo 0)
            local removed_count=$((original_count - clean_count))

            if [ $removed_count -gt 0 ] && [ -s "$temp_file" ]; then
                if cp "$temp_file" "$queue_file" 2>/dev/null; then
                    log_debug "Se eliminaron $removed_count entradas duplicadas de $(basename "$queue_file")"
                fi
            fi
        fi
        rm -f "$temp_file" 2>/dev/null || true
    fi
}

# Configurar archivos de cola
setup_queue_files() {
    local queue_locations=(
        "$FLAGS_DIR/queue"
        "/tmp/lang-flags-queue"
        "/var/tmp/lang-flags-queue"
    )

    for queue_dir in "${queue_locations[@]}"; do
        if create_directory_safe "$queue_dir"; then
            QUEUE_DIR="$queue_dir"
            RADARR_QUEUE_FILE="$QUEUE_DIR/radarr_queue.txt"
            SONARR_QUEUE_FILE="$QUEUE_DIR/sonarr_queue.txt"
            QUEUE_LOCK_FILE="$QUEUE_DIR/monitor.lock"
            log_debug "Usando directorio de cola: $QUEUE_DIR"
            break
        fi
    done

    # Crear archivos de cola
    touch "$RADARR_QUEUE_FILE" "$SONARR_QUEUE_FILE" 2>/dev/null || {
        log_warning "No se pueden crear archivos de cola, funcionalidad limitada"
    }

    chmod 666 "$RADARR_QUEUE_FILE" "$SONARR_QUEUE_FILE" 2>/dev/null || true

    # Limpiar duplicados existentes
    clean_queue_duplicates "$RADARR_QUEUE_FILE" 2>/dev/null || true
    clean_queue_duplicates "$SONARR_QUEUE_FILE" 2>/dev/null || true

    log_debug "Configuración de archivos de cola completada"
}

# ========================
# Cron and Queue Processor
# ========================

# Configurar procesador de cola con cron
setup_queue_processor() {
    local cron_locations=(
        "/etc/cron.d"
        "/tmp"
        "$FLAGS_DIR/cron"
    )

    local cron_file=""
    for location in "${cron_locations[@]}"; do
        if [[ -w "$location" ]] || create_directory_safe "$location"; then
            cron_file="$location/lang-flags-queue"
            break
        fi
    done

    if [[ -n "$cron_file" ]]; then
        # Crear cron job
        cat >"$cron_file" <<'EOF'
# Lang-Flags Queue Processor
SHELL=/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

# Procesar cola cada minuto
* * * * * root bash /flags/lang-flags.bash --process-queue >/dev/null 2>&1
EOF
        chmod 644 "$cron_file" 2>/dev/null || true
        log_info "Cron job configurado en: $cron_file"

        # Recargar cron si es posible
        if command -v crond >/dev/null; then
            killall -HUP crond 2>/dev/null || true
        elif command -v cron >/dev/null; then
            service cron reload 2>/dev/null || true
        fi
    else
        log_warning "No se pudo configurar cron, usando fallback a proceso en background"
        # Fallback a proceso background
        start_background_queue_processor
    fi
}

# Iniciar procesador de cola en background como fallback
start_background_queue_processor() {
    (
        while true; do
            process_queue_files
            sleep 60
        done
    ) &
    log_info "Procesador de cola iniciado en background (PID: $!)"
}

# Procesar archivos de cola
process_queue_files() {
    local queue_files=("$RADARR_QUEUE_FILE" "$SONARR_QUEUE_FILE")

    for queue_file in "${queue_files[@]}"; do
        if [ -f "$queue_file" ] && [ -s "$queue_file" ]; then
            while IFS='|' read -r timestamp event_type file_path; do
                if [[ -n "$file_path" ]] && [[ -f "$file_path" ]]; then
                    log_info "Procesando desde cola: $file_path"
                    process_single_item "$file_path"
                fi
            done <"$queue_file"

            # Limpiar archivo de cola después de procesar
            >"$queue_file"
        fi
    done
}

# ========================
# Setup and Initialization
# ========================

# Asegurar que todos los directorios requeridos existan
ensure_directories_exist() {
    local required_dirs=(
        "$FLAGS_DIR"
        "$METADATA_CACHE_DIR"
        "$QUEUE_DIR"
        "$TMP_DIR"
        "$OVERLAY_DIR"
        "$TMP_DIR/processed"
        "$TMP_DIR/logs"
    )

    for dir in "${required_dirs[@]}"; do
        create_directory_safe "$dir" || {
            log_warning "No se pudo crear directorio: $dir"
        }
    done
}

# Instalación de dependencias (simplificada y sin sudo)
install_deps() {
    log_info "Verificando dependencias..."

    # Lista de comandos requeridos
    local required_commands=("exiftool" "jq" "convert" "ffmpeg")
    local missing_commands=()

    for cmd in "${required_commands[@]}"; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            missing_commands+=("$cmd")
        fi
    done

    if [ ${#missing_commands[@]} -gt 0 ]; then
        log_warning "Comandos faltantes: ${missing_commands[*]}"
        log_info "Las dependencias deben instalarse por el administrador del contenedor"
        return 1
    else
        log_info "Todas las dependencias están disponibles"
        return 0
    fi
}

# ========================
# Main Processing Functions
# ========================

# Verificar si un video ya fue procesado
is_video_processed() {
    local video_file="$1"

    if [ "$FORCE_UPDATE" = true ]; then
        log_debug "Actualización forzada habilitada para: $video_file"
        return 1
    fi

    if [ ! -f "$video_file" ]; then
        log_debug "Archivo de video no encontrado: $video_file"
        return 1
    fi

    # Verificar cache de metadatos
    local cache_file="$METADATA_CACHE_DIR/$(basename "$video_file").processed"
    if [ -f "$cache_file" ]; then
        local cache_time=$(stat -c %Y "$cache_file" 2>/dev/null || echo 0)
        local video_time=$(stat -c %Y "$video_file" 2>/dev/null || echo 0)

        if [ "$cache_time" -gt "$video_time" ]; then
            log_debug "Video ya procesado (cache válido): $video_file"
            return 0
        fi
    fi

    return 1
}

# Procesar un elemento individual
process_single_item() {
    local item_path="$1"

    if [ ! -e "$item_path" ]; then
        log_warning "Elemento no encontrado: $item_path"
        return 1
    fi

    log_info "Procesando: $item_path"

    # Determinar si es película o serie
    if [[ "$item_path" == *"$MOVIES_DIR"* ]]; then
        process_movie "$item_path"
    elif [[ "$item_path" == *"$SERIES_DIR"* ]]; then
        process_tv_show "$item_path"
    else
        log_warning "Tipo de contenido no reconocido: $item_path"
        return 1
    fi
}

# Procesar película
process_movie() {
    local movie_path="$1"
    log_info "Procesando película: $movie_path"

    # Buscar archivos de video
    local video_files=$(find "$(dirname "$movie_path")" -name "*.mkv" -o -name "*.mp4" -o -name "*.avi" 2>/dev/null)

    if [ -z "$video_files" ]; then
        log_warning "No se encontraron archivos de video en: $(dirname "$movie_path")"
        return 1
    fi

    # Procesar cada archivo de video
    echo "$video_files" | while read -r video_file; do
        if [ -f "$video_file" ]; then
            if ! is_video_processed "$video_file"; then
                log_debug "Procesando archivo de video: $video_file"
                # Aquí iría la lógica de procesamiento de overlays
                mark_video_processed "$video_file"
            fi
        fi
    done
}

# Procesar serie de TV
process_tv_show() {
    local series_path="$1"
    log_info "Procesando serie: $series_path"

    # Buscar archivos de video en temporadas
    local video_files=$(find "$(dirname "$series_path")" -name "*.mkv" -o -name "*.mp4" -o -name "*.avi" 2>/dev/null)

    if [ -z "$video_files" ]; then
        log_warning "No se encontraron archivos de video en: $(dirname "$series_path")"
        return 1
    fi

    # Procesar cada archivo de video
    echo "$video_files" | while read -r video_file; do
        if [ -f "$video_file" ]; then
            if ! is_video_processed "$video_file"; then
                log_debug "Procesando episodio: $video_file"
                # Aquí iría la lógica de procesamiento de overlays
                mark_video_processed "$video_file"
            fi
        fi
    done
}

# Marcar video como procesado
mark_video_processed() {
    local video_file="$1"
    local cache_file="$METADATA_CACHE_DIR/$(basename "$video_file").processed"

    create_directory_safe "$(dirname "$cache_file")"
    touch "$cache_file" 2>/dev/null || {
        log_warning "No se pudo crear archivo de cache: $cache_file"
    }
}

# ========================
# Event Handling
# ========================

# Manejar eventos de Sonarr/Radarr
handle_events() {
    # Verificar eventos de prueba
    if [ "$radarr_eventtype" = "Test" ] || [ "$sonarr_eventtype" = "Test" ]; then
        log_info "Evento de prueba recibido - Script funcionando correctamente"
        exit 0
    fi

    # Procesar eventos de Radarr
    if [ -n "$radarr_eventtype" ] && [ -n "$radarr_movie_path" ]; then
        log_info "Evento Radarr: $radarr_eventtype para $radarr_movie_path"
        echo "$(date '+%Y-%m-%d %H:%M:%S')|$radarr_eventtype|$radarr_movie_path" >>"$RADARR_QUEUE_FILE"
        return 0
    fi

    # Procesar eventos de Sonarr
    if [ -n "$sonarr_eventtype" ] && [ -n "$sonarr_episodefile_path" ]; then
        log_info "Evento Sonarr: $sonarr_eventtype para $sonarr_episodefile_path"
        echo "$(date '+%Y-%m-%d %H:%M:%S')|$sonarr_eventtype|$sonarr_episodefile_path" >>"$SONARR_QUEUE_FILE"
        return 0
    fi

    return 1
}

# ========================
# Argument Parsing
# ========================

# Parsear argumentos
parse_arguments() {
    while [[ "$#" -gt 0 ]]; do
        case $1 in
        -v | --verbose)
            DEBUG=true
            ;;
        -f | --force)
            FORCE_UPDATE=true
            ;;
        -q | --queue)
            MODE="queue"
            if [[ "$2" =~ ^[0-9]+$ ]]; then
                shift
                NFO_WAIT_SECONDS=$1
            fi
            ;;
        -m | --monitor)
            shift
            MONITOR_INTERVAL=$1
            MODE="monitor"
            ;;
        -j | --jobs)
            shift
            MAX_PARALLEL_JOBS=$1
            ;;
        --process-queue)
            MODE="process_queue"
            ;;
        --setup-cron)
            setup_queue_processor
            exit 0
            ;;
        --install-deps)
            install_deps
            exit $?
            ;;
        all)
            MODE="all"
            ;;
        movies)
            MODE="movies"
            ;;
        tvshows)
            MODE="tvshows"
            ;;
        *)
            log_warning "Argumento desconocido: $1"
            ;;
        esac
        shift
    done
}

# ========================
# Generar script de inicialización del contenedor (LO PRIMERO)
generate_container_init_script() {
    local init_script="/custom-cont-init.d/lang_flags-install_deps.sh"

    log_debug "Generando script de inicialización del contenedor..."

    # Crear directorio si no existe
    mkdir -p "/custom-cont-init.d" 2>/dev/null || {
        log_debug "No se pudo crear /custom-cont-init.d"
        return 1
    }

    # Borrar archivo existente si existe
    rm -f "$init_script" 2>/dev/null || true

    # Generar el script simple y efectivo
    cat > "$init_script" << 'EOF'
#!/bin/bash

echo "[$(date)] Lang-Flags: Instalando dependencias..."

# Instalar dependencias de forma desatendida
export DEBIAN_FRONTEND=noninteractive

if command -v apt-get >/dev/null 2>&1; then
    apt-get update -qq >/dev/null 2>&1
    apt-get install -y -qq \
        imagemagick \
        libimage-exiftool-perl \
        jq \
        ffmpeg \
        curl \
        wget \
        bc \
        >/dev/null 2>&1
elif command -v apk >/dev/null 2>&1; then
    apk add --no-cache \
        imagemagick \
        exiftool \
        jq \
        ffmpeg \
        curl \
        wget \
        bc \
        bash \
        >/dev/null 2>&1
fi

echo "[$(date)] Lang-Flags: Estableciendo permisos de cron..."

# Establecer permisos para poder crear cron después
if [[ -d "/etc/cron.d" ]]; then
    chmod 777 "/etc/cron.d" 2>/dev/null
elif mkdir -p "/etc/cron.d" 2>/dev/null; then
    chmod 777 "/etc/cron.d" 2>/dev/null
fi

echo "[$(date)] Lang-Flags: Configurando cron para procesamiento de colas..."

# Configurar cron job para procesar colas automáticamente
cat > /etc/cron.d/lang-flags-queue << 'CRONEOF'
# Lang-Flags Queue Processor - Se autodesactiva cuando las colas están vacías
SHELL=/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

# Procesar cola cada minuto
* * * * * root bash /flags/lang-flags.bash --process-queue >/dev/null 2>&1
CRONEOF

chmod 644 /etc/cron.d/lang-flags-queue 2>/dev/null

# Recargar cron para aplicar cambios
if command -v crond >/dev/null; then
    pkill -HUP crond 2>/dev/null || true
fi

echo "[$(date)] Lang-Flags: Cron job configurado - se autodesactivará cuando las colas estén vacías"

echo "[$(date)] Lang-Flags: Inicialización completada"
EOF

    chmod +x "$init_script" 2>/dev/null || true

    if [[ -f "$init_script" ]]; then
        log_info "✓ Script de inicialización generado: $init_script"
        return 0
    else
        log_error "✗ Error generando script de inicialización"
        return 1
    fi
}

# ========================
# Verificar si las colas están vacías
are_queues_empty() {
    local queue_files=("$RADARR_QUEUE_FILE" "$SONARR_QUEUE_FILE")
    
    for queue_file in "${queue_files[@]}"; do
        if [[ -f "$queue_file" ]] && [[ -s "$queue_file" ]]; then
            return 1  # No están vacías
        fi
    done
    
    return 0  # Están vacías
}

# Quitar procesador de cola cuando no hay elementos (autodesactivar cron)
remove_queue_processor() {
    local cron_locations=(
        "/etc/cron.d/lang-flags-queue"
        "/tmp/lang-flags-queue"
        "$FLAGS_DIR/cron/lang-flags-queue"
    )

    local removed=false
    for cron_file in "${cron_locations[@]}"; do
        if [[ -f "$cron_file" ]]; then
            rm -f "$cron_file" 2>/dev/null && {
                log_info "✓ Cron job removido: $cron_file (colas vacías)"
                removed=true
            }
        fi
    done

    if [[ "$removed" == true ]]; then
        # Recargar cron para aplicar cambios
        if command -v crond >/dev/null; then
            pkill -HUP crond 2>/dev/null || true
        fi
        log_info "🔴 Procesador de cola desactivado - todas las colas vacías"
    fi
}

# ========================
# Main Execution
# ========================

# Función principal
main() {
    # LO PRIMERO: Generar script de inicialización
    generate_container_init_script
    
    # Configuración inicial
    logfileSetup
    ensure_directories_exist
    setup_queue_files

    log_info "=== $scriptName v$scriptVersion iniciado ==="
    log_info "Usuario: $(whoami), PID: $$"

    # Parsear argumentos
    parse_arguments "$@"

    # Verificar dependencias
    if ! install_deps; then
        log_error "Dependencias faltantes - el script puede no funcionar correctamente"
    fi

    # Manejar eventos de Sonarr/Radarr
    if handle_events; then
        log_info "Evento añadido a la cola"
        exit 0
    fi

    # Determinar modo de ejecución
    if [ -z "$MODE" ]; then
        if [ -n "$sonarr_eventtype" ] || [ -n "$radarr_eventtype" ]; then
            MODE="queue_only"
        else
            MODE="all"
        fi
    fi

    log_info "Modo de ejecución: $MODE"

    # Ejecutar según el modo
    case "$MODE" in
    "process_queue")
        process_queue_files
        # Verificar si las colas están vacías y autodesactivar cron
        if are_queues_empty; then
            remove_queue_processor
        fi
        ;;
    "monitor")
        setup_queue_processor
        log_info "Monitor iniciado (intervalo: ${MONITOR_INTERVAL}s)"
        while true; do
            process_queue_files
            sleep "$MONITOR_INTERVAL"
        done
        ;;
    "queue_only")
        log_info "Modo solo cola - procesando automáticamente"
        # Simplemente procesar las colas y activar procesador en background si hay elementos
        process_queue_files
        start_simple_queue_processor
        ;;
    "all" | "movies" | "tvshows")
        log_info "Procesando todo el contenido disponible"
        # Procesar todo el contenido
        if [[ "$MODE" == "all" || "$MODE" == "movies" ]]; then
            if [ -d "$MOVIES_DIR" ]; then
                find "$MOVIES_DIR" -name "*.mkv" -o -name "*.mp4" -o -name "*.avi" | while read -r video_file; do
                    process_single_item "$video_file"
                done
            fi
        fi

        if [[ "$MODE" == "all" || "$MODE" == "tvshows" ]]; then
            if [ -d "$SERIES_DIR" ]; then
                find "$SERIES_DIR" -name "*.mkv" -o -name "*.mp4" -o -name "*.avi" | while read -r video_file; do
                    process_single_item "$video_file"
                done
            fi
        fi
        ;;
    *)
        log_error "Modo desconocido: $MODE"
        exit 1
        ;;
    esac

    log_info "=== $scriptName completado ==="
}

# ========================
# Script Execution
# ========================

# Manejar interrupciones
trap 'log_info "Script interrumpido - limpiando..."; exit 1' INT TERM

# Ejecutar función principal con todos los argumentos
main "$@"

# Iniciar procesador simple de cola en background
start_simple_queue_processor() {
    local queue_files=("$RADARR_QUEUE_FILE" "$SONARR_QUEUE_FILE")
    local has_items=false
    
    # Verificar si hay elementos en alguna cola
    for queue_file in "${queue_files[@]}"; do
        if [[ -f "$queue_file" ]] && [[ -s "$queue_file" ]]; then
            has_items=true
            break
        fi
    done
    
    if [[ "$has_items" == false ]]; then
        log_debug "No hay elementos en cola, no se inicia procesador"
        return 0
    fi
    
    log_info "Iniciando procesador simple de cola en background..."
    
    # Proceso en background que procesa hasta que las colas estén vacías
    (
        while true; do
            local processed_any=false
            
            for queue_file in "${queue_files[@]}"; do
                if [[ -f "$queue_file" ]] && [[ -s "$queue_file" ]]; then
                    while IFS='|' read -r timestamp event_type file_path; do
                        if [[ -n "$file_path" ]] && [[ -f "$file_path" ]]; then
                            echo "[$(date '+%Y-%m-%d %H:%M:%S')] [INFO] Procesando desde cola: $file_path" >> "${LOG_FILE:-/tmp/lang-flags.log}"
                            process_single_item "$file_path"
                            processed_any=true
                        fi
                    done < "$queue_file"
                    
                    # Limpiar cola después de procesar
                    > "$queue_file"
                fi
            done
            
            # Si no procesamos nada, verificar si quedan elementos
            if [[ "$processed_any" == false ]]; then
                local still_has_items=false
                for queue_file in "${queue_files[@]}"; do
                    if [[ -f "$queue_file" ]] && [[ -s "$queue_file" ]]; then
                        still_has_items=true
                        break
                    fi
                done
                
                if [[ "$still_has_items" == false ]]; then
                    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [INFO] Todas las colas vacías - finalizando procesador" >> "${LOG_FILE:-/tmp/lang-flags.log}"
                    break
                fi
            fi
            
            # Esperar un poco antes del siguiente ciclo
            sleep 10
        done
    ) &
    
    local pid=$!
    log_info "✓ Procesador de cola iniciado (PID: $pid)"
    return 0
}



