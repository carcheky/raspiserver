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

# Configurar procesador de cola con cron permanente
setup_queue_processor() {
    local cron_entry="*/15 * * * * bash /flags/lang-flags.bash --process-queue >/dev/null 2>&1"
    local crontab_file="/var/spool/cron/crontabs/root"
    
    # Verificar si ya existe la entrada en el crontab
    if [[ -f "$crontab_file" ]] && grep -q "lang-flags.bash --process-queue" "$crontab_file" 2>/dev/null; then
        log_debug "Cron job permanente ya configurado"
        return 0
    fi
    
    # Crear directorio si no existe
    mkdir -p "$(dirname "$crontab_file")" 2>/dev/null || true
    
    # Añadir entrada al crontab de root
    echo "$cron_entry" >> "$crontab_file" 2>/dev/null && {
        log_info "✓ Cron job permanente configurado: cada 15 minutos"
        # Recargar cron para aplicar cambios
        pkill -HUP crond 2>/dev/null || true
        log_info "🟢 Procesador de cola PERMANENTE activado"
        return 0
    }
    
    log_error "✗ No se pudo configurar el cron job permanente"
    return 1
}

# Eliminar función start_background_queue_processor - no es necesaria
# El cron permanente se encarga de todo

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

# Quitar procesador de cola - NO HACER NADA
# El cron job es permanente y siempre está habilitado
# Solo verificará si hay elementos y procesará si es necesario

# Verificar si un archivo está listo para procesar
is_ready_to_process() {
    local file_path="$1"
    local file_dir=$(dirname "$file_path")
    local base_name=$(basename "$file_path" | sed 's/\.[^.]*$//')
    
    # Determinar si es episodio de TV o película
    local is_tv_episode=false
    if [[ "$file_path" =~ [Ss][0-9]+[Ee][0-9]+ ]] || [[ "$file_path" =~ Season ]]; then
        is_tv_episode=true
    fi
    
    # Buscar archivo NFO apropiado
    local nfo_file=""
    if [[ "$is_tv_episode" == true ]]; then
        # Para episodios de TV, buscar season.nfo o cualquier NFO en el directorio
        for nfo in "$file_dir"/season.nfo "$file_dir"/*.nfo; do
            if [[ -f "$nfo" ]]; then
                nfo_file="$nfo"
                log_debug "NFO encontrado para episodio: $nfo"
                break
            fi
        done
    else
        # Para películas, buscar NFO específico del archivo
        for nfo in "$file_dir"/"${base_name}.nfo" "$file_dir"/*.nfo; do
            if [[ -f "$nfo" ]]; then
                nfo_file="$nfo"
                log_debug "NFO encontrado para película: $nfo"
                break
            fi
        done
    fi
    
    # Si no hay NFO, esperar un poco más
    if [[ -z "$nfo_file" ]]; then
        log_debug "NFO no encontrado para: $file_path - esperando que Jellyfin procese"
        return 1
    fi
    
    # Buscar imágenes de poster existentes (más permisivo para episodios)
    local poster_found=false
    if [[ "$is_tv_episode" == true ]]; then
        # Para episodios, buscar posters a nivel de temporada o serie
        local season_dir="$file_dir"
        local series_dir=$(dirname "$season_dir")
        
        for ext in jpg jpeg png; do
            for dir in "$season_dir" "$series_dir"; do
                for pattern in "poster" "folder" "season" "banner" "thumb"; do
                    if [[ -f "$dir/${pattern}.${ext}" ]]; then
                        poster_found=true
                        log_debug "Poster encontrado para episodio: $dir/${pattern}.${ext}"
                        break 3
                    fi
                done
            done
        done
    else
        # Para películas, buscar poster específico
        for ext in jpg jpeg png; do
            for pattern in "poster" "folder" "${base_name}"; do
                if [[ -f "$file_dir/${pattern}.${ext}" ]]; then
                    poster_found=true
                    log_debug "Poster encontrado para película: $file_dir/${pattern}.${ext}"
                    break 2
                fi
            done
        done
    fi
    
    # Si no hay poster, esperar un poco más (pero ser más permisivo para episodios antiguos)
    if [[ "$poster_found" == false ]]; then
        local file_age=$(( $(date +%s) - $(stat -c %Y "$file_path" 2>/dev/null || echo 0) ))
        if [[ "$is_tv_episode" == true ]] && [[ $file_age -gt 3600 ]]; then
            # Para episodios de más de 1 hora, procesar aunque no haya poster
            log_debug "Episodio antiguo sin poster, procesando de todas formas: $file_path"
        else
            log_debug "Poster no encontrado para: $file_path - esperando que Jellyfin genere imágenes"
            return 1
        fi
    fi
    
    # Verificar que el archivo no sea demasiado reciente (dar tiempo a Jellyfin)
    local file_age=$(( $(date +%s) - $(stat -c %Y "$file_path" 2>/dev/null || echo 0) ))
    local min_age=${NFO_WAIT_SECONDS:-30}
    
    if [[ $file_age -lt $min_age ]]; then
        log_debug "Archivo muy reciente ($file_age s), esperando $min_age s mínimo: $file_path"
        return 1
    fi
    
    log_debug "✓ Archivo listo para procesar: NFO encontrado, criterios cumplidos"
    return 0
}

# ========================
# Standard Queue Processing
# ========================

# Función estandarizada para procesar la cola (simplificada)
# El cron es permanente, solo procesa la cola sin gestión automática
standard_queue_processing() {
    local context="${1:-general}"
    
    log_debug "Procesando cola (contexto: $context)"
    
    # Verificar si las colas están vacías antes de procesar
    if are_queues_empty; then
        log_debug "Colas vacías - terminando inmediatamente"
        return 0
    fi
    
    log_info "Procesando elementos en cola..."
    
    # Procesar la cola
    process_queue_files
    
    log_debug "Procesamiento de cola completado (contexto: $context)"
}

# Procesar archivos de cola
process_queue_files() {
    local queue_files=("$RADARR_QUEUE_FILE" "$SONARR_QUEUE_FILE")

    for queue_file in "${queue_files[@]}"; do
        if [ -f "$queue_file" ] && [ -s "$queue_file" ]; then
            local temp_file="${queue_file}.tmp.$$"
            local processed_any=false
            
            # Leer la cola y procesar elemento por elemento
            while IFS='|' read -r timestamp event_type file_path; do
                if [[ -n "$file_path" ]] && [[ -f "$file_path" ]]; then
                    log_info "Verificando desde cola: $file_path"
                    
                    # Verificar si el archivo está listo para procesar (NFO existe, etc.)
                    if is_ready_to_process "$file_path"; then
                        log_info "Procesando desde cola: $file_path"
                        if process_single_item "$file_path"; then
                            log_info "✓ Procesado exitosamente: $file_path"
                            processed_any=true
                        else
                            log_warning "Error procesando, mantener en cola: $file_path"
                            echo "$timestamp|$event_type|$file_path" >> "$temp_file"
                        fi
                    else
                        log_debug "No listo para procesar, mantener en cola: $file_path"
                        echo "$timestamp|$event_type|$file_path" >> "$temp_file"
                    fi
                else
                    log_warning "Archivo no encontrado, removiendo de cola: $file_path"
                fi
            done < "$queue_file"
            
            # Reemplazar la cola con solo los elementos no procesados
            if [[ -f "$temp_file" ]]; then
                mv "$temp_file" "$queue_file"
                log_debug "Cola actualizada: $(wc -l < "$queue_file" 2>/dev/null || echo 0) elementos pendientes"
            else
                > "$queue_file"  # Vaciar si no hay elementos pendientes
                log_debug "Cola vacía: todos los elementos procesados"
            fi
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
    log_info "Instalando dependencias..."

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

    # Crear estructura de directorios
    mkdir -p /flags/queue /flags/cache/metadata /flags/tmp /flags/cron /flags/4x3 2>/dev/null
    chmod -R 755 /flags 2>/dev/null

    # Verificar instalación
    return $(check_dependencies_quiet)
}

# Verificar dependencias silenciosamente
check_dependencies_quiet() {
    local required_commands=("exiftool" "jq" "convert" "ffmpeg")
    
    for cmd in "${required_commands[@]}"; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            return 1
        fi
    done
    return 0
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
        --init)
            MODE="init"
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

    # Solo generar si no existe o si es más antiguo que este script
    if [[ -f "$init_script" ]] && [[ "$init_script" -nt "$0" ]]; then
        log_debug "Script de inicialización ya existe y está actualizado"
        return 0
    fi

    log_debug "Generando script de inicialización del contenedor..."

    # Crear directorio si no existe
    mkdir -p "/custom-cont-init.d" 2>/dev/null || {
        log_debug "No se pudo crear /custom-cont-init.d"
        return 1
    }

    # Borrar archivo existente si existe
    rm -f "$init_script" 2>/dev/null || true

    # Generar script simplificado que llama al principal
    cat > "$init_script" << 'EOF'
#!/bin/bash

echo "[$(date)] Lang-Flags: Inicializando sistema..."

# Llamar al script principal para inicialización
if [[ -f "/flags/lang-flags.bash" ]]; then
    bash /flags/lang-flags.bash --init
else
    echo "[$(date)] Lang-Flags: ERROR - Script principal no encontrado"
    exit 1
fi

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
# Main Execution
# ========================

# Función principal
main() {
    # Configuración inicial
    logfileSetup
    ensure_directories_exist
    setup_queue_files

    log_info "=== $scriptName v$scriptVersion iniciado ==="
    log_info "Usuario: $(whoami), PID: $$"

    # Parsear argumentos
    parse_arguments "$@"

    # Solo generar script de inicialización si no estamos en modo init
    if [[ "$MODE" != "init" ]]; then
        generate_container_init_script
    fi

    # Verificar dependencias solo si no estamos en modo init
    if [[ "$MODE" != "init" ]] && ! check_dependencies_quiet; then
        log_warning "Algunas dependencias pueden estar faltantes"
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
    "init")
        log_info "Modo inicialización - instalando dependencias y configurando cron"
        # Instalar dependencias
        if install_deps; then
            log_info "✓ Dependencias instaladas correctamente"
        else
            log_error "✗ Error instalando dependencias"
        fi
        
        # Configurar cron permanente
        if setup_queue_processor; then
            log_info "✓ Sistema inicializado correctamente"
        else
            log_error "✗ Error configurando cron permanente"
        fi
        ;;
    "process_queue")
        standard_queue_processing "cron-job"
        ;;
    "monitor")
        log_info "Monitor iniciado (intervalo: ${MONITOR_INTERVAL}s)"
        # Asegurar que el cron permanente esté configurado
        setup_queue_processor
        # El monitor solo reporta, no procesa automáticamente
        while true; do
            log_info "Monitor activo - cron permanente procesando cada 15 minutos"
            sleep "$MONITOR_INTERVAL"
        done
        ;;
    "queue_only")
        log_info "Modo solo cola - evento ya procesado"
        # Solo añadir a cola, el cron permanente se encarga del resto
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
