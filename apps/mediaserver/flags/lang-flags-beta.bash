#!/bin/bash

# =============================================================================
# LANG-FLAGS BETA - Script de Overlays de Idioma para Radarr/Sonarr
# =============================================================================
# Versión: 3.0-beta
# Autor: MediaCheky
# Descripción: Detecta idiomas y aplica overlays de banderas a posters
# =============================================================================

# PROTECCIÓN: Solo ejecutar dentro de contenedores
if [[ ! -f /.dockerenv ]] && [[ -z "$sonarr_eventtype" ]] && [[ -z "$radarr_eventtype" ]]; then
    echo "❌ ERROR: Este script SOLO debe ejecutarse dentro de contenedores Sonarr/Radarr"
    echo "❌ NO ejecutar en el host - puede dañar el sistema"
    
    # Intentar autoejecución dentro del contenedor apropiado
    echo "🔄 Intentando autoejecutar dentro del contenedor..."
    
    # Detectar contenedor disponible
    container_name=""
    
    # Buscar contenedor Radarr
    if docker ps --format "{{.Names}}" | grep -i radarr >/dev/null 2>&1; then
        container_name=$(docker ps --format "{{.Names}}" | grep -i radarr | head -1)
        echo "📡 Contenedor Radarr encontrado: $container_name"
    # Buscar contenedor Sonarr si no hay Radarr
    elif docker ps --format "{{.Names}}" | grep -i sonarr >/dev/null 2>&1; then
        container_name=$(docker ps --format "{{.Names}}" | grep -i sonarr | head -1)
        echo "📺 Contenedor Sonarr encontrado: $container_name"
    fi
    
    if [[ -n "$container_name" ]]; then
        echo "🚀 Ejecutando script dentro del contenedor: $container_name"
        echo "📝 Comando: docker exec $container_name /flags/lang-flags-beta.bash $*"
        
        # Ejecutar el script dentro del contenedor con los mismos argumentos
        if docker exec "$container_name" /flags/lang-flags-beta.bash "$@"; then
            echo "✅ Script ejecutado exitosamente dentro del contenedor"
            exit 0
        else
            echo "❌ Error ejecutando script dentro del contenedor"
            exit 1
        fi
    else
        echo "❌ No se encontraron contenedores Radarr/Sonarr ejecutándose"
        echo "💡 Sugerencia: Verificar que los contenedores estén iniciados"
        echo "💡 Comando para verificar: docker ps | grep -E '(radarr|sonarr)'"
        exit 1
    fi
fi

# =============================================================================
# DETECCIÓN DE CONTENEDOR
# =============================================================================

detect_container_type() {
    # Detectar tipo de contenedor para locks diferenciados
    if [[ -n "$radarr_eventtype" ]] || [[ "$(hostname)" =~ radarr ]] || ([[ -f "/config/config.xml" ]] && grep -q "Radarr" "/config/config.xml" 2>/dev/null); then
        echo "radarr"
    elif [[ -n "$sonarr_eventtype" ]] || [[ "$(hostname)" =~ sonarr ]] || ([[ -f "/config/config.xml" ]] && grep -q "Sonarr" "/config/config.xml" 2>/dev/null); then
        echo "sonarr"
    else
        echo "unknown"
    fi
}

# =============================================================================
# CONFIGURACIÓN GLOBAL
# =============================================================================

readonly SCRIPT_NAME="Lang-Flags-Beta"
readonly SCRIPT_VERSION="3.0-beta"
readonly DEBUG=false

# Directorios principales - detectar entorno automáticamente
if [[ -d "/flags" ]]; then
    readonly BASE_DIR="/flags"
else
    readonly BASE_DIR="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
fi
readonly DATA_DIR="$BASE_DIR/data"
readonly MEDIA_ROOT="/BibliotecaMultimedia"
readonly MOVIES_DIR="$MEDIA_ROOT/Peliculas"
readonly SERIES_DIR="$MEDIA_ROOT/Series"

# Directorios de trabajo
readonly OVERLAY_DIR="$BASE_DIR/4x3"
readonly CACHE_DIR="$DATA_DIR/cache"
readonly QUEUE_DIR="$DATA_DIR/queue"
readonly TMP_DIR="$DATA_DIR/tmp"
readonly LOG_DIR="$DATA_DIR/logs"

# Archivos de bloqueo (diferenciados por contenedor) - en data
readonly SCAN_LOCK="$DATA_DIR/scan-$(detect_container_type).lock"
readonly PROCESS_LOCK="$DATA_DIR/process-$(detect_container_type).lock"

# Archivos de cola - en data
readonly RADARR_QUEUE="$QUEUE_DIR/radarr.queue"
readonly SONARR_QUEUE="$QUEUE_DIR/sonarr.queue"

# Configuración de procesamiento
readonly OVERLAY_SIZE="400x300"
readonly POSTER_MAX_SIZE="2560x1440"
readonly CACHE_EXPIRE_HOURS=24
readonly PROCESSING_DELAY=10

# =============================================================================
# SISTEMA DE LOGGING
# =============================================================================

setup_logging() {
    local log_file="$LOG_DIR/lang-flags-$(date +%Y%m%d).log"
    mkdir -p "$LOG_DIR"
    touch "$log_file" 2>/dev/null || log_file="/tmp/lang-flags.log"
    
    # Rotar logs antiguos
    find "$LOG_DIR" -name "lang-flags-*.log" -mtime +7 -delete 2>/dev/null || true
    
    export LOG_FILE="$log_file"
}

log() {
    local level="$1"
    local message="$2"
    local timestamp="$(date '+%Y-%m-%d %H:%M:%S')"
    
    # Solo mostrar DEBUG si está habilitado
    if [[ "$level" == "DEBUG" ]] && [[ "$DEBUG" != "true" ]]; then
        return
    fi
    
    echo "[$timestamp] [$level] $message" | tee -a "${LOG_FILE:-/tmp/lang-flags.log}"
}

log_info() { log "INFO" "$1"; }
log_error() { log "ERROR" "$1" >&2; }
log_warning() { log "WARNING" "$1" >&2; }
log_debug() { log "DEBUG" "$1"; }

# =============================================================================
# SISTEMA DE BLOQUEO ROBUSTO
# =============================================================================

acquire_lock() {
    local lock_file="$1"
    local timeout="$2"
    local process_name="${3:-unknown}"
    local start_time=$(date +%s)
    
    log_debug "Intentando adquirir lock: $lock_file (timeout: ${timeout}s, proceso: $process_name)"
    
    # Verificar si el archivo de lock existe y es válido
    while [[ -f "$lock_file" ]]; do
        local current_time=$(date +%s)
        local elapsed=$((current_time - start_time))
        
        # Verificar timeout
        if [[ "$elapsed" -ge "$timeout" ]]; then
            log_error "Timeout esperando lock $lock_file después de ${timeout}s"
            return 1
        fi
        
        # Verificar si el proceso que tiene el lock sigue ejecutándose
        if [[ -s "$lock_file" ]]; then
            local lock_pid=$(cat "$lock_file" 2>/dev/null)
            if [[ -n "$lock_pid" ]] && ! kill -0 "$lock_pid" 2>/dev/null; then
                log_warning "Lock obsoleto detectado (PID $lock_pid no existe), eliminando"
                rm -f "$lock_file" 2>/dev/null
                break
            fi
        fi
        
        log_debug "Esperando lock $lock_file... (${elapsed}s/${timeout}s)"
        sleep 2
    done
    
    # Crear el lock file con el PID actual
    if ! echo "$$" > "$lock_file" 2>/dev/null; then
        log_error "No se pudo crear lock file: $lock_file"
        return 1
    fi
    
    log_debug "✓ Lock adquirido: $lock_file (PID: $$, proceso: $process_name)"
    return 0
}

release_lock() {
    local lock_file="$1"
    
    if [[ -f "$lock_file" ]]; then
        local lock_pid=$(cat "$lock_file" 2>/dev/null)
        if [[ "$lock_pid" == "$$" ]]; then
            rm -f "$lock_file" 2>/dev/null
            log_debug "✓ Lock liberado: $lock_file"
        else
            log_warning "Intentando liberar lock que no nos pertenece: $lock_file (PID: $lock_pid vs $$)"
        fi
    fi
}

cleanup_locks() {
    log_debug "Limpiando locks al salir..."
    release_lock "$SCAN_LOCK"
    release_lock "$PROCESS_LOCK"
}

# =============================================================================
# UTILIDADES
# =============================================================================

create_dirs() {
    local dirs=("$BASE_DIR" "$DATA_DIR" "$CACHE_DIR" "$QUEUE_DIR" "$TMP_DIR" "$LOG_DIR")
    
    for dir in "${dirs[@]}"; do
        if ! mkdir -p "$dir" 2>/dev/null; then
            log_warning "No se pudo crear directorio: $dir"
        fi
    done
}

check_dependencies() {
    local required=("exiftool" "jq" "convert" "ffprobe" "mediainfo" "mkvinfo" "rsvg-convert")
    local optional=("at")
    local missing=()
    
    for cmd in "${required[@]}"; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            missing+=("$cmd")
        fi
    done
    
    if [[ ${#missing[@]} -gt 0 ]]; then
        log_error "Dependencias críticas faltantes: ${missing[*]}"
        return 1
    fi
    
    # Verificar dependencias opcionales
    local missing_optional=()
    for cmd in "${optional[@]}"; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            missing_optional+=("$cmd")
        fi
    done
    
    if [[ ${#missing_optional[@]} -gt 0 ]]; then
        log_warning "Dependencias opcionales faltantes: ${missing_optional[*]}"
    fi
    
    return 0
}

is_video_file() {
    local file="$1"
    [[ "$file" =~ \.(mkv|mp4|avi|m4v)$ ]]
}

is_trailer_or_extra() {
    local file_path="$1"
    
    # Verificar rutas que contengan directorios de extras
    if [[ "$file_path" =~ .*/trailers/.* ]] || \
       [[ "$file_path" =~ .*/extras/.* ]] || \
       [[ "$file_path" =~ .*/behind.the.scenes/.* ]] || \
       [[ "$file_path" =~ .*/deleted.scenes/.* ]] || \
       [[ "$file_path" =~ .*/featurettes/.* ]] || \
       [[ "$file_path" =~ .*/interviews/.* ]] || \
       [[ "$file_path" =~ .*/scenes/.* ]] || \
       [[ "$file_path" =~ .*/shorts/.* ]] || \
       [[ "$file_path" =~ .*/other/.* ]]; then
        return 0  # Es trailer/extra
    fi
    
    # Verificar nombres de archivo que contengan palabras clave
    local filename=$(basename "$file_path")
    if [[ "$filename" =~ .*[Tt]railer.* ]] || \
       [[ "$filename" =~ .*TRAILER.* ]] || \
       [[ "$filename" =~ .*[Pp]review.* ]] || \
       [[ "$filename" =~ .*[Tt]easer.* ]] || \
       [[ "$filename" =~ .*-trailer\..* ]] || \
       [[ "$filename" =~ .*_trailer\..* ]]; then
        return 0  # Es trailer/extra
    fi
    
    return 1  # No es trailer/extra
}

# =============================================================================
# DETECCIÓN DE IDIOMAS
# =============================================================================

detect_languages_from_video() {
    local video_file="$1"
    
    if [[ ! -f "$video_file" ]]; then
        return 1
    fi
    
    # Usar ffprobe como en el script original (solo audio tracks)
    local languages=$(ffprobe -v quiet -show_entries stream=index:stream_tags=language -select_streams a -of json "$video_file" 2>/dev/null | jq --raw-output '.streams[].tags.language' 2>/dev/null | grep -v "^null$" | sort -u | tr '\n' ' ')
    
    # Si ffprobe no funciona, intentar con mediainfo (solo audio)
    if [[ -z "$languages" ]] && command -v mediainfo >/dev/null 2>&1; then
        local audio_langs=$(mediainfo --Output="Audio;%Language/String3%" "$video_file" 2>/dev/null | grep -v "^$")
        # Separar idiomas concatenados (ej: "spaeng" -> "spa eng")
        if [[ -n "$audio_langs" ]]; then
            languages=""
            for lang_string in $audio_langs; do
                # Separar códigos de 3 caracteres
                local len=${#lang_string}
                for ((i=0; i<len; i+=3)); do
                    local lang_code="${lang_string:$i:3}"
                    if [[ ${#lang_code} -eq 3 ]]; then
                        languages+="$lang_code "
                    fi
                done
            done
        fi
    fi
    
    # Limpiar y normalizar idiomas
    languages=$(echo "$languages" | tr ' ' '\n' | grep -v "^$" | sort -u | tr '\n' ' ')
    
    # Si no hay idiomas, usar español por defecto
    if [[ -z "$languages" ]]; then
        languages="spa"
    fi
    
    # Retornar solo los códigos de idioma, SIN logs
    echo "$languages" | sed 's/ $//'
}

detect_languages_from_nfo() {
    local media_dir="$1"
    local -n nfo_languages=$2
    
    # Buscar archivos NFO
    local nfo_files=$(find "$media_dir" -name "*.nfo" -type f 2>/dev/null)
    
    if [[ -z "$nfo_files" ]]; then
        return 1
    fi
    
    # Extraer idiomas de archivos NFO
    while IFS= read -r nfo_file; do
        if [[ -f "$nfo_file" ]]; then
            # Buscar tags de idioma en XML
            local langs=$(grep -i "<language>" "$nfo_file" 2>/dev/null | sed 's/<[^>]*>//g' | tr '[:upper:]' '[:lower:]' | tr -d ' ')
            
            if [[ -n "$langs" ]]; then
                nfo_languages+=("$langs")
            fi
        fi
    done <<< "$nfo_files"
    
    return 0
}

# =============================================================================
# GESTIÓN DE OVERLAYS
# =============================================================================

normalize_language_code() {
    local lang="$1"
    
    # Convertir códigos de idioma a códigos de país para banderas
    case "${lang,,}" in
        "es"|"spa"|"spanish"|"español") echo "es" ;;
        "en"|"eng"|"english"|"inglés") echo "gb" ;;
        "fr"|"fre"|"french"|"francés") echo "fr" ;;
        "de"|"ger"|"german"|"alemán") echo "de" ;;
        "it"|"ita"|"italian"|"italiano") echo "it" ;;
        "pt"|"por"|"portuguese"|"portugués") echo "pt" ;;
        "ja"|"jpn"|"japanese"|"japonés") echo "jp" ;;
        "ko"|"kor"|"korean"|"coreano") echo "kr" ;;
        "zh"|"chi"|"chinese"|"chino") echo "cn" ;;
        "ru"|"rus"|"russian"|"ruso") echo "ru" ;;
        *) echo "es" ;; # Por defecto español
    esac
}

find_poster_image() {
    local media_path="$1"
    local media_type="$2"  # "movie" o "tvshow"
    
    if [[ "$media_type" == "movie" ]]; then
        # Para películas: buscar TODOS los archivos poster/folder que existan
        local movie_dir=$(dirname "$media_path")
        
        # Lista de nombres de imagen posibles
        local poster_names=("poster.jpg" "folder.jpg" "poster.png" "folder.png")
        local found_images=()
        
        # Buscar en directorio actual
        for poster_name in "${poster_names[@]}"; do
            local poster_file="$movie_dir/$poster_name"
            if [[ -f "$poster_file" ]]; then
                found_images+=("$poster_file")
                log_debug "Poster encontrado: $poster_file" >&2
            fi
        done
        
        # Si no se encuentra ninguno en el directorio actual, buscar en el directorio padre
        # (para casos como trailers/, extras/, etc.)
        if [[ ${#found_images[@]} -eq 0 ]]; then
            local parent_dir=$(dirname "$movie_dir")
            for poster_name in "${poster_names[@]}"; do
                local parent_poster="$parent_dir/$poster_name"
                if [[ -f "$parent_poster" ]]; then
                    found_images+=("$parent_poster")
                    log_debug "Poster encontrado en directorio padre: $parent_poster" >&2
                fi
            done
        fi
        
        # Retornar todas las imágenes encontradas (separadas por ;)
        if [[ ${#found_images[@]} -gt 0 ]]; then
            local result=$(IFS=';'; echo "${found_images[*]}")
            echo "$result"
            return 0
        fi
        
        log_warning "Poster de película no encontrado en: $movie_dir (probados: ${poster_names[*]})" >&2
        return 1
        
    elif [[ "$media_type" == "tvshow" ]]; then
        # Para series: procesar TODAS las imágenes (episodio + temporada + serie)
        local episode_path="$media_path"
        local season_dir=$(dirname "$episode_path")
        local series_dir=$(dirname "$season_dir")
        local episode_basename=$(basename "$episode_path" | sed 's/\.[^.]*$//')
        
        # Lista de imágenes a procesar (orden de prioridad)
        local images_to_process=()
        
        # 1. Thumbnail del episodio específico
        local episode_thumb="$season_dir/${episode_basename}-thumb.jpg"
        if [[ -f "$episode_thumb" ]]; then
            images_to_process+=("$episode_thumb")
            log_debug "Imagen de episodio encontrada: $episode_thumb" >&2
        fi
        
        # 2. Poster de temporada
        local season_num=$(basename "$season_dir" | grep -o '[0-9]\+' | head -1)
        local season_poster="$series_dir/season$(printf "%02d" "$((10#$season_num))")-poster.jpg"
        if [[ -f "$season_poster" ]]; then
            images_to_process+=("$season_poster")
            log_debug "Poster de temporada encontrado: $season_poster" >&2
        fi
        
        # 3. Poster de serie (buscar TODOS los poster.jpg Y folder.jpg que existan)
        local series_poster_names=("poster.jpg" "folder.jpg" "poster.png" "folder.png")
        for poster_name in "${series_poster_names[@]}"; do
            local series_poster="$series_dir/$poster_name"
            if [[ -f "$series_poster" ]]; then
                images_to_process+=("$series_poster")
                log_debug "Poster de serie encontrado: $series_poster" >&2
                # NO hacer break - agregar TODOS los que encuentre
            fi
        done
        
        # Retornar todas las imágenes encontradas (separadas por ;)
        if [[ ${#images_to_process[@]} -gt 0 ]]; then
            local result=$(IFS=';'; echo "${images_to_process[*]}")
            echo "$result"
            return 0
        fi
        
        log_warning "No se encontraron imágenes para serie/temporada/episodio: $series_dir" >&2
        return 1
    fi
    
    return 1
}

apply_language_overlays() {
    local poster_file="$1"
    local -a languages=("${@:2}")
    
    # Verificar que el archivo existe
    if [[ ! -f "$poster_file" ]]; then
        log_warning "Archivo no encontrado: $poster_file"
        return 1
    fi
    
    # Crear copia de seguridad SOLO si DEBUG está activado
    if [[ "$DEBUG" == "true" ]]; then
        local backup_file="${poster_file}.original"
        if [[ ! -f "$backup_file" ]]; then
            cp "$poster_file" "$backup_file" 2>/dev/null || {
                log_error "No se pudo crear backup de: $poster_file"
                return 1
            }
            log_debug "Backup creado: $backup_file"
        fi
    fi
    
    # Obtener dimensiones del poster con múltiples métodos
    local poster_width=$(exiftool -f -s3 -"ImageWidth" "$poster_file" 2>/dev/null)
    local poster_height=$(exiftool -f -s3 -"ImageHeight" "$poster_file" 2>/dev/null)
    
    # Si exiftool falla, intentar con identify de ImageMagick
    if [[ ! "$poster_width" =~ ^[0-9]+$ ]] || [[ ! "$poster_height" =~ ^[0-9]+$ ]]; then
        local dimensions=$(identify -format "%w %h" "$poster_file" 2>/dev/null)
        if [[ -n "$dimensions" ]]; then
            poster_width=$(echo "$dimensions" | cut -d' ' -f1)
            poster_height=$(echo "$dimensions" | cut -d' ' -f2)
        fi
    fi
    
    # Validar que las dimensiones son números válidos
    if [[ ! "$poster_width" =~ ^[0-9]+$ ]] || [[ ! "$poster_height" =~ ^[0-9]+$ ]] || [[ "$poster_width" -eq 0 ]] || [[ "$poster_height" -eq 0 ]]; then
        log_warning "No se pudieron obtener dimensiones válidas de imagen: $poster_file (width: $poster_width, height: $poster_height)"
        return 1
    fi
    log_debug "Dimensiones del poster: ${poster_width}x${poster_height}px"
    
    # Tamaño proporcional de bandera (20% del ancho del poster)
    # Esto asegura que las banderas se vean del mismo tamaño visual en Jellyfin
    local flag_width=$((poster_width / 5))
    local flag_height=$((flag_width * 3 / 4))  # Mantener proporción 4:3
    
    # Procesar idiomas uno por uno
    local applied_overlays=0
    local y_offset=10  # Offset vertical inicial
    
    for lang in "${languages[@]}"; do
        local country_code=$(normalize_language_code "$lang")
        local flag_file="$OVERLAY_DIR/${country_code}.svg"
        
        if [[ ! -f "$flag_file" ]]; then
            log_debug "Bandera no encontrada: $flag_file"
            continue
        fi
        
        log_debug "Aplicando overlay: $lang → $country_code (${flag_width}px)"
        
        # Crear overlay transparente del tamaño del poster
        local temp_overlay="$TMP_DIR/${country_code}_overlay_tmp_$$.png"
        local temp_flag="$TMP_DIR/${country_code}_flag_tmp_$$.png"
        
        # Paso 1: Convertir SVG a PNG con tamaño fijo (120x90px) y color explícito
        if ! rsvg-convert -w "$flag_width" -h "$flag_height" --format=png --background-color=transparent "$flag_file" -o "$temp_flag" 2>/dev/null; then
            log_warning "Error convirtiendo SVG: $flag_file"
            continue
        fi
        
        # Paso 2: Crear overlay transparente del tamaño del poster (forzar color)
        if ! convert -size "${poster_width}x${poster_height}" xc:transparent -colorspace sRGB "$temp_overlay" 2>/dev/null; then
            log_warning "Error creando canvas transparente"
            rm -f "$temp_flag"
            continue
        fi
        
        # Paso 3: Posicionar bandera en esquina superior derecha (preservar color)
        local x_offset=$((poster_width - flag_width - 10))
        if ! convert "$temp_overlay" "$temp_flag" -colorspace sRGB -geometry "+${x_offset}+${y_offset}" -composite "$temp_overlay" 2>/dev/null; then
            log_warning "Error posicionando bandera"
            rm -f "$temp_flag" "$temp_overlay"
            continue
        fi
        
        # Paso 4: Aplicar overlay al poster (preservar color)
        if convert "$poster_file" "$temp_overlay" -colorspace sRGB -flatten "$poster_file" 2>/dev/null; then
            log_info "✓ Overlay aplicado: $lang → $(basename "$poster_file")"
            ((applied_overlays++))
            # Ajustar posición para siguiente bandera (usar altura fija + margen)
            y_offset=$((y_offset + flag_height + 5))
        else
            log_warning "Error aplicando overlay $lang a: $(basename "$poster_file")"
        fi
        
        # Limpiar archivos temporales
        rm -f "$temp_flag" "$temp_overlay"
    done
    
    if [[ $applied_overlays -gt 0 ]]; then
        log_info "✓ $(basename "$poster_file") procesado con $applied_overlays overlay(s)"
        return 0
    else
        log_warning "No se aplicaron overlays a: $(basename "$poster_file")"
        return 1
    fi
}

# =============================================================================
# GESTIÓN DE CACHE BASADO EN EXIF
# =============================================================================

get_video_identifier() {
    local video_file="$1"
    
    if [[ ! -f "$video_file" ]]; then
        return 1
    fi
    
    # Retornar solo el nombre del archivo (sin ruta)
    basename "$video_file"
}

is_image_processed() {
    local image_file="$1"
    local video_file="$2"  # Recibe la ruta completa del video
    
    if [[ ! -f "$image_file" || -z "$video_file" ]]; then
        return 1
    fi
    
    # SISTEMA SIMPLIFICADO: Verificar UserComment con nombre del archivo (sin ruta)
    local user_comment=$(exiftool -f -s3 -"UserComment" "$image_file" 2>/dev/null)
    local video_filename=$(basename "$video_file")
    local expected_comment="LangFlags:$video_filename"
    
    if [[ -n "$user_comment" && "$user_comment" == "$expected_comment" ]]; then
        return 0  # Ya procesada (nombre coincide)
    fi
    
    return 1  # No procesada o nombre diferente
}

update_image_exif_filename() {
    local image_file="$1"
    local video_file="$2"  # Recibe la ruta completa del video
    
    if [[ ! -f "$image_file" || -z "$video_file" ]]; then
        return 1
    fi
    
    # SISTEMA SIMPLIFICADO: Solo UserComment con nombre del archivo (sin ruta)
    local video_filename=$(basename "$video_file")
    if exiftool -overwrite_original -UserComment="LangFlags:$video_filename" "$image_file" >/dev/null 2>&1; then
        log_debug "Cache EXIF actualizado en: $(basename "$image_file") (UserComment=LangFlags:$video_filename)"
        return 0
    else
        log_warning "No se pudo actualizar UserComment en: $(basename "$image_file")"
        return 1
    fi
}

get_image_exif_video_path() {
    local image_file="$1"
    
    if [[ ! -f "$image_file" ]]; then
        return 1
    fi
    
    # Extraer ruta del archivo del campo UserComment
    local video_path=$(exiftool -f -s3 -"UserComment" "$image_file" 2>/dev/null | grep "LangFlags:" | cut -d: -f2-)
    
    if [[ -n "$video_path" ]]; then
        echo "$video_path"
        return 0
    else
        return 1
    fi
}

get_video_identifier_cached() {
    local video_file="$1"
    
    if [[ ! -f "$video_file" ]]; then
        return 1
    fi
    
    # SISTEMA SIMPLIFICADO: Solo retornar la ruta del archivo directamente
    echo "$video_file"
    return 0
}

needs_processing() {
    local media_path="$1"
    local media_type="$2"
    local force_mode="${3:-false}"
    
    # Si está en modo force, siempre procesar
    if [[ "$force_mode" == "true" ]]; then
        log_debug "Modo force activado, procesando: $media_path"
        return 0
    fi
    
    # Buscar imágenes asociadas al archivo de medios
    local poster_result
    if ! poster_result=$(find_poster_image "$media_path" "$media_type"); then
        log_debug "No se encontraron imágenes, necesita procesamiento: $media_path"
        return 0
    fi
    
    # Verificar cache en cada imagen usando SISTEMA UNIFICADO
    local poster_files
    if [[ "$media_type" == "movie" ]]; then
        IFS=';' read -ra poster_files <<< "$poster_result"
    else
        IFS=';' read -ra poster_files <<< "$poster_result"
    fi
    
    # Obtener identificador actual del archivo de video (ruta completa)
    local current_video_path
    current_video_path=$(get_video_identifier_cached "$media_path" 2>/dev/null || echo "")
    
    for poster_file in "${poster_files[@]}"; do
        # MÉTODO ULTRA-OPTIMIZADO: Filtros previos + cache externo + EXIF tradicional
        if is_image_processed_optimized "$poster_file" "$current_video_path"; then
            log_debug "Cache HIT: $(basename "$poster_file") ruta coincide ($current_video_path)"
            continue  # Esta imagen está actualizada
        else
            log_debug "Cache MISS: $(basename "$poster_file") ruta diferente o no procesada"
            return 0  # Necesita procesamiento
        fi
    done
    
    # Si llegamos aquí, todas las imágenes tienen el identificador correcto
    log_debug "Cache HIT: Todas las imágenes actualizadas para: $media_path"
    return 1  # No necesita procesamiento
}

# =============================================================================
# SISTEMA DE CACHE EXTERNO OPTIMIZADO
# =============================================================================

# Variables globales para cache externo
readonly EXTERNAL_CACHE_FILE="$DATA_DIR/lang-flags-cache.txt"

# Función para limpiar caché de un elemento específico (webhook events)
remove_from_cache() {
    local media_path="$1"
    local media_type="$2"
    
    log_debug "Limpiando caché para: $media_path (tipo: $media_type)"
    
    # Obtener todas las imágenes asociadas al archivo
    local poster_images_result
    if poster_images_result=$(find_poster_image "$media_path" "$media_type" 2>/dev/null); then
        # Convertir a array
        local poster_images=()
        IFS=';' read -ra poster_images <<< "$poster_images_result"
        
        # Limpiar caché externa para cada imagen
        local video_basename=$(basename "$media_path")
        local cleaned_count=0
        
        for image in "${poster_images[@]}"; do
            if [[ -f "$image" ]]; then
                local image_basename=$(basename "$image")
                
                # Eliminar de caché externa
                if [[ -f "$EXTERNAL_CACHE_FILE" ]]; then
                    local before_count=$(wc -l < "$EXTERNAL_CACHE_FILE" 2>/dev/null || echo "0")
                    sed -i "/^${image_basename}|${video_basename}|/d" "$EXTERNAL_CACHE_FILE" 2>/dev/null
                    local after_count=$(wc -l < "$EXTERNAL_CACHE_FILE" 2>/dev/null || echo "0")
                    
                    if [[ "$before_count" -gt "$after_count" ]]; then
                        log_debug "Entrada eliminada de caché externa: $image_basename|$video_basename"
                        ((cleaned_count++))
                    fi
                fi
                
                # Limpiar EXIF también
                if command -v exiftool >/dev/null 2>&1; then
                    exiftool -overwrite_original -UserComment="" "$image" 2>/dev/null || true
                    log_debug "EXIF limpiado para: $image_basename"
                fi
            fi
        done
        
        if [[ "$cleaned_count" -gt 0 ]]; then
            log_info "🧹 Caché limpiada para: $(basename "$media_path") ($cleaned_count imagen(es))"
        else
            log_debug "No se encontraron entradas de caché para limpiar: $(basename "$media_path")"
        fi
    else
        log_debug "No se encontraron imágenes asociadas para limpiar caché: $media_path"
    fi
    
    return 0
}

# Función para verificar si imagen está procesada usando cache externo
is_image_processed_external() {
    local image_file="$1"
    local video_file="$2"
    
    if [[ ! -f "$image_file" || -z "$video_file" ]]; then
        return 1
    fi
    
    local image_basename=$(basename "$image_file")
    local video_basename=$(basename "$video_file")
    
    # Primero verificar cache externo (más rápido)
    if [[ -f "$EXTERNAL_CACHE_FILE" ]]; then
        # Buscar entrada en cache: imagen|video|timestamp|processed
        local cache_entry=$(grep "^${image_basename}|${video_basename}|" "$EXTERNAL_CACHE_FILE" 2>/dev/null)
        if [[ -n "$cache_entry" ]]; then
            # Extraer el status de procesado (último campo)
            local processed_status=$(echo "$cache_entry" | cut -d'|' -f4)
            if [[ "$processed_status" == "1" ]]; then
                log_debug "Cache externo HIT: $image_basename ya procesada para $video_basename"
                return 0  # Ya procesada según cache externo
            else
                log_debug "Cache externo HIT: $image_basename NO procesada para $video_basename"
                return 1  # No procesada según cache externo
            fi
        fi
    fi
    
    # Si no está en cache externo, verificar EXIF tradicional
    if is_image_processed "$image_file" "$video_file"; then
        # Actualizar cache externo con resultado positivo
        update_external_cache "$image_file" "$video_file" "1"
        return 0
    else
        # Actualizar cache externo con resultado negativo
        update_external_cache "$image_file" "$video_file" "0"
        return 1
    fi
}

# Función para actualizar cache externo
update_external_cache() {
    local image_file="$1"
    local video_file="$2" 
    local processed_status="$3"  # 1=procesado, 0=no procesado
    
    if [[ -z "$image_file" || -z "$video_file" || -z "$processed_status" ]]; then
        return 1
    fi
    
    local image_basename=$(basename "$image_file")
    local video_basename=$(basename "$video_file")
    local timestamp=$(date +%s)
    
    # Crear directorio si no existe
    mkdir -p "$(dirname "$EXTERNAL_CACHE_FILE")"
    
    # Formato: imagen|video|timestamp|processed_status
    local cache_entry="${image_basename}|${video_basename}|${timestamp}|${processed_status}"
    
    # Eliminar entrada previa si existe
    if [[ -f "$EXTERNAL_CACHE_FILE" ]]; then
        sed -i "/^${image_basename}|${video_basename}|/d" "$EXTERNAL_CACHE_FILE" 2>/dev/null
    fi
    
    # Agregar nueva entrada
    echo "$cache_entry" >> "$EXTERNAL_CACHE_FILE"
    
    log_debug "Cache externo actualizado: $cache_entry"
    return 0
}

# Función para limpiar entradas obsoletas del cache externo
cleanup_external_cache() {
    if [[ ! -f "$EXTERNAL_CACHE_FILE" ]]; then
        return 0
    fi
    
    local current_timestamp=$(date +%s)
    local max_age=$((7 * 24 * 3600))  # 7 días en segundos
    local temp_file="${EXTERNAL_CACHE_FILE}.tmp"
    
    # Filtrar entradas que no sean muy antiguas
    while IFS='|' read -r image video timestamp status; do
        if [[ -n "$timestamp" && $(($current_timestamp - $timestamp)) -lt $max_age ]]; then
            echo "${image}|${video}|${timestamp}|${status}" >> "$temp_file"
        fi
    done < "$EXTERNAL_CACHE_FILE"
    
    # Reemplazar archivo original
    if [[ -f "$temp_file" ]]; then
        mv "$temp_file" "$EXTERNAL_CACHE_FILE"
        log_debug "Cache externo limpiado de entradas obsoletas"
    fi
    
    return 0
}

# =============================================================================
# INSTALACIÓN DE DEPENDENCIAS
# =============================================================================

create_autosetup_script() {
    local init_dir="/custom-cont-init.d"
    local init_script="$init_dir/99-lang-flags-setup.sh"
    
    log_info "📝 Creando script de auto-setup en: $init_script"
    
    # Crear directorio si no existe
    if ! mkdir -p "$init_dir" 2>/dev/null; then
        log_warning "⚠️ No se pudo crear directorio $init_dir (puede requerir permisos root)"
        return 1
    fi
    
    # Crear script de inicialización ultra-simple
    cat > "$init_script" << 'EOF'
#!/bin/bash
# Auto-setup para Lang-Flags - Ejecutado al inicio del contenedor
# Generado automáticamente por lang-flags-beta.bash

if [[ -f "/flags/lang-flags-beta.bash" ]]; then
    bash /flags/lang-flags-beta.bash setup
fi
EOF
    
    # Hacer ejecutable
    if chmod +x "$init_script" 2>/dev/null; then
        log_info "✅ Script de auto-setup creado: $init_script"
        log_info "🔄 Se ejecutará automáticamente al iniciar el contenedor"
        return 0
    else
        log_warning "⚠️ No se pudo hacer ejecutable: $init_script"
        return 1
    fi
}

setup_dependencies() {
    log_info "🔧 Iniciando instalación de dependencias para Lang-Flags..."
    
    # Crear script de auto-setup primero
    create_autosetup_script
    
    # Detectar el gestor de paquetes disponible
    local package_manager=""
    if command -v apt-get >/dev/null 2>&1; then
        package_manager="apt"
    elif command -v apk >/dev/null 2>&1; then
        package_manager="apk"
    elif command -v yum >/dev/null 2>&1; then
        package_manager="yum"
    else
        log_error "❌ No se detectó un gestor de paquetes compatible (apt, apk, yum)"
        return 1
    fi
    
    log_info "📦 Gestor de paquetes detectado: $package_manager"
    
    # Lista de paquetes necesarios por gestor
    local packages_apt="libimage-exiftool-perl imagemagick librsvg2-bin ffmpeg mediainfo mkvtoolnix jq at"
    local packages_apk="exiftool imagemagick librsvg rsvg-convert ffmpeg mediainfo mkvtoolnix jq"
    local packages_yum="perl-Image-ExifTool ImageMagick librsvg2-tools ffmpeg mediainfo mkvtoolnix jq at"
    
    # Instalar según el gestor de paquetes
    case "$package_manager" in
        "apt")
            log_info "🔄 Actualizando repositorios apt..."
            if ! apt-get update >/dev/null 2>&1; then
                log_warning "⚠️ No se pudo actualizar repositorios (puede ser por permisos)"
            fi
            
            log_info "📥 Instalando paquetes: $packages_apt"
            if apt-get install -y $packages_apt >/dev/null 2>&1; then
                log_info "✅ Paquetes APT instalados exitosamente"
            else
                log_error "❌ Error instalando paquetes APT"
                return 1
            fi
            ;;
        "apk")
            log_info "🔄 Actualizando repositorios apk..."
            if ! apk update >/dev/null 2>&1; then
                log_warning "⚠️ No se pudo actualizar repositorios (puede ser por permisos)"
            fi
            
            log_info "📥 Instalando paquetes: $packages_apk"
            if apk add $packages_apk >/dev/null 2>&1; then
                log_info "✅ Paquetes APK instalados exitosamente"
            else
                log_error "❌ Error instalando paquetes APK"
                return 1
            fi
            ;;
        "yum")
            log_info "📥 Instalando paquetes: $packages_yum"
            if yum install -y $packages_yum >/dev/null 2>&1; then
                log_info "✅ Paquetes YUM instalados exitosamente"
            else
                log_error "❌ Error instalando paquetes YUM"
                return 1
            fi
            ;;
    esac
    
    # Verificar instalación
    log_info "🔍 Verificando dependencias instaladas..."
    if check_dependencies; then
        log_info "✅ ¡Todas las dependencias están correctamente instaladas!"
        log_info "🚀 Lang-Flags está listo para usar"
        return 0
    else
        log_error "❌ Algunas dependencias siguen faltando después de la instalación"
        return 1
    fi
}

# =============================================================================
# SISTEMA DE GESTIÓN DE COLAS
# =============================================================================

add_to_queue() {
    local media_path="$1"
    local media_type="$2"  # "movie" o "tvshow"
    local container_type=$(detect_container_type)
    
    # Determinar archivo de cola según el contenedor
    local queue_file=""
    case "$container_type" in
        "radarr")
            queue_file="$RADARR_QUEUE"
            ;;
        "sonarr")
            queue_file="$SONARR_QUEUE"
            ;;
        *)
            # Contenedor desconocido, usar cola genérica
            queue_file="$QUEUE_DIR/generic.queue"
            ;;
    esac
    
    # Crear directorio de cola si no existe
    mkdir -p "$QUEUE_DIR"
    
    # Formato: timestamp|media_type|media_path
    local timestamp=$(date +%s)
    local queue_entry="${timestamp}|${media_type}|${media_path}"
    
    # Verificar si el item ya está en la cola
    if [[ -f "$queue_file" ]] && grep -q "|${media_path}$" "$queue_file" 2>/dev/null; then
        log_debug "Item ya en cola: $media_path"
        return 0
    fi
    
    # Añadir a la cola
    echo "$queue_entry" >> "$queue_file"
    log_info "✓ Añadido a cola: $(basename "$media_path") (tipo: $media_type)"
    return 0
}

process_queue() {
    local container_type=$(detect_container_type)
    
    # Determinar archivo de cola según el contenedor
    local queue_file=""
    case "$container_type" in
        "radarr")
            queue_file="$RADARR_QUEUE"
            ;;
        "sonarr")
            queue_file="$SONARR_QUEUE"
            ;;
        *)
            # Procesar todas las colas disponibles
            local queue_files=("$RADARR_QUEUE" "$SONARR_QUEUE" "$QUEUE_DIR/generic.queue")
            for qf in "${queue_files[@]}"; do
                if [[ -f "$qf" ]]; then
                    process_single_queue "$qf"
                fi
            done
            return $?
            ;;
    esac
    
    # Procesar cola específica del contenedor
    if [[ -f "$queue_file" ]]; then
        process_single_queue "$queue_file"
    else
        log_info "No hay cola para procesar: $queue_file"
        return 0
    fi
}

process_single_queue() {
    local queue_file="$1"
    
    if [[ ! -f "$queue_file" ]]; then
        return 0
    fi
    
    # Contar items en cola
    local queue_count=$(wc -l < "$queue_file" 2>/dev/null || echo "0")
    if [[ "$queue_count" -eq 0 ]]; then
        log_info "Cola vacía: $(basename "$queue_file")"
        return 0
    fi
    
    log_info "📋 Procesando cola: $(basename "$queue_file") ($queue_count items)"
    
    # Crear archivo temporal para items no procesados
    local temp_queue="${queue_file}.tmp"
    local processed_count=0
    local failed_count=0
    
    # Procesar cada item de la cola
    while IFS='|' read -r timestamp media_type media_path; do
        # Validar formato de entrada
        if [[ -z "$media_type" || -z "$media_path" ]]; then
            log_warning "Entrada de cola inválida: $timestamp|$media_type|$media_path"
            continue
        fi
        
        log_info "🎬 Procesando desde cola: $(basename "$media_path") (tipo: $media_type)"
        
        # Procesar item SIN verificar cache (la cola no usa cache)
        if process_media_item "$media_path" "$media_type"; then
            log_debug "✓ Item procesado exitosamente desde cola: $media_path"
            ((processed_count++))
            # NO añadir a temp_queue = eliminar de cola
        else
            log_warning "❌ Error procesando item desde cola: $media_path"
            # Añadir a temp_queue para reintentar
            echo "${timestamp}|${media_type}|${media_path}" >> "$temp_queue"
            ((failed_count++))
        fi
        
    done < "$queue_file"
    
    # Reemplazar cola original con items fallidos
    if [[ -f "$temp_queue" ]]; then
        mv "$temp_queue" "$queue_file"
        log_info "📋 Cola actualizada: $processed_count procesados, $failed_count pendientes"
    else
        # Todos los items procesados exitosamente
        rm -f "$queue_file"
        log_info "✅ Cola completada: $processed_count items procesados, 0 pendientes"
    fi
    
    return 0
}

scan_and_queue() {
    local media_dir="$1"
    local media_type="$2"  # "movie" o "tvshow"
    local force_process="$3"
    
    log_info "🔍 Escaneando directorio para añadir a cola: $media_dir (tipo: $media_type)"
    
    if [[ ! -d "$media_dir" ]]; then
        log_warning "Directorio no encontrado: $media_dir"
        return 1
    fi
    
    # Si está en modo force, limpiar solo cache externo (EXIF se sobreescribe durante procesamiento)
    if [[ "$force_process" == "true" ]]; then
        log_info "🧹 Modo force: limpiando cache externo"
        rm -f "$EXTERNAL_CACHE_FILE"
        log_info "✅ Cache externo eliminado correctamente"
        # NOTA: No limpiamos EXIF masivamente aquí, se sobreescribe durante el procesamiento
    fi
    
    local queued_count=0
    local skipped_count=0
    local scanned_count=0
    
    log_info "🔍 Iniciando escaneo de archivos de video..."
    
    # Escanear archivos de video en el directorio
    while IFS= read -r media_file; do
        ((scanned_count++))
        
        # Log de progreso cada 10 archivos escaneados
        if (( scanned_count % 10 == 0 )); then
            local current_queue_count=$(get_total_queue_count)
            log_info "📊 Progreso: $scanned_count archivos escaneados, $queued_count añadidos, total en cola: $current_queue_count"
        fi
        
        # Filtrar trailers, extras y otros archivos secundarios que no necesitan overlays
        if [[ "$media_file" =~ (trailer|extra|behind.the.scene|other|featurette|deleted.scene|making.of|teaser) ]]; then
            log_debug "Saltando archivo secundario: $(basename "$media_file")"
            continue
        fi
        
        if [[ "$media_file" =~ \.(mkv|mp4|avi|m4v)$ ]]; then
            
            # Con force, añadir todo a la cola sin verificar cache
            if [[ "$force_process" == "true" ]]; then
                add_to_queue "$media_file" "$media_type"
                ((queued_count++))
                log_debug "Force: añadido a cola: $(basename "$media_file")"
            else
                # Sin force, verificar cache antes de añadir a cola
                if needs_processing "$media_file" "$media_type" "false"; then
                    add_to_queue "$media_file" "$media_type"
                    ((queued_count++))
                    log_debug "Cache MISS: añadido a cola: $(basename "$media_file")"
                else
                    ((skipped_count++))
                    log_debug "Cache HIT: saltado: $(basename "$media_file")"
                fi
            fi
            
        fi
    done < <(find "$media_dir" -type f -name "*.mkv" -o -name "*.mp4" -o -name "*.avi" -o -name "*.m4v")
    
    log_info "📋 Escaneo completado: $queued_count añadidos a cola, $skipped_count saltados por cache"
    return 0
}

process_webhook_event() {
    # Detectar tipo de evento y archivo desde variables de entorno
    local event_file=""
    local media_type=""
    
    # Variables de Radarr
    if [[ -n "$radarr_eventtype" && -n "$radarr_moviefile_path" ]]; then
        event_file="$radarr_moviefile_path"
        media_type="movie"
        log_info "📡 Evento Radarr detectado: $radarr_eventtype"
        log_debug "Archivo de evento: $event_file"
    
    # Variables de Sonarr  
    elif [[ -n "$sonarr_eventtype" && -n "$sonarr_episodefile_path" ]]; then
        event_file="$sonarr_episodefile_path"
        media_type="tvshow"
        log_info "📺 Evento Sonarr detectado: $sonarr_eventtype"
        log_debug "Archivo de evento: $event_file"
    
    else
        log_warning "No se detectaron variables de evento de webhook"
        return 1
    fi
    
    # Validar que el archivo existe
    if [[ ! -f "$event_file" ]]; then
        log_warning "Archivo de evento no encontrado: $event_file"
        return 1
    fi
    
    # Limpiar caché del elemento específico para TODOS los eventos webhook
    # Esto garantiza que archivos nuevos/actualizados se reprocesen correctamente
    log_info "🧹 Limpiando caché para evento webhook: $radarr_eventtype$sonarr_eventtype"
    remove_from_cache "$event_file" "$media_type"
    
    # Añadir siempre a cola (sin verificar cache para webhooks)
    add_to_queue "$event_file" "$media_type"
    log_info "✓ Evento añadido a cola para procesamiento"
    
    return 0
}

# =============================================================================
# PROCESAMIENTO PRINCIPAL
# =============================================================================

process_media_item() {
    local media_path="$1"
    local media_type="$2"  # "movie" o "tvshow"
    
    log_info "Procesando $media_type: $media_path"
    
    # 1. Verificar que no sea trailer o contenido extra
    if is_trailer_or_extra "$media_path"; then
        log_debug "Omitiendo trailer/extra: $(basename "$media_path")"
        return 0  # Retornar éxito pero no procesar
    fi
    
    # 2. Verificar que exista el archivo de video
    if [[ ! -f "$media_path" ]]; then
        log_warning "Archivo de video no encontrado: $media_path"
        return 1
    fi
    
    # 3. Encontrar imágenes correspondientes
    local poster_images_result
    if ! poster_images_result=$(find_poster_image "$media_path" "$media_type"); then
        log_warning "No se encontraron imágenes poster para: $media_path"
        return 1
    fi
    
    # 4. Convertir resultado a array (separado por ;)
    local poster_images=()
    IFS=';' read -ra poster_images <<< "$poster_images_result"
    
    # 5. Verificar que al menos una imagen existe
    local valid_images=()
    for image in "${poster_images[@]}"; do
        if [[ -f "$image" ]]; then
            valid_images+=("$image")
        else
            log_warning "Imagen poster no encontrada: $image"
        fi
    done
    
    if [[ ${#valid_images[@]} -eq 0 ]]; then
        log_warning "No se encontraron imágenes válidas para: $media_path"
        return 1
    fi
    
    # 6. Extraer idiomas del archivo de video (solo audio tracks)
    log_debug "Extrayendo idiomas de: $media_path"
    local detected_langs
    if ! detected_langs=$(detect_languages_from_video "$media_path"); then
        log_warning "No se pudieron detectar idiomas para: $media_path"
        return 1
    fi
    
    # 7. Convertir string de idiomas a array
    local languages=()
    read -ra languages <<< "$detected_langs"
    
    if [[ ${#languages[@]} -eq 0 ]]; then
        log_warning "No se detectaron idiomas para procesar: $media_path"
        return 1
    fi
    
    log_info "Aplicando overlays para idiomas: ${languages[*]} en ${#valid_images[@]} imagen(es) (${media_type})"
    
    # Obtener identificador del video para marcar en las imágenes (usando cache optimizado)
    local video_identifier
    video_identifier=$(get_video_identifier_cached "$media_path" 2>/dev/null)
    if [[ -z "$video_identifier" ]]; then
        log_warning "No se pudo obtener identificador del video: $media_path"
        video_identifier=""
    fi
    
    # 8. Aplicar overlays a cada imagen válida
    local success_count=0
    for poster_image in "${valid_images[@]}"; do
        log_debug "Procesando imagen: $poster_image"
        
        if apply_language_overlays "$poster_image" "${languages[@]}"; then
            # Marcar imagen como procesada guardando la ruta del archivo de video
            if [[ -n "$video_identifier" ]]; then
                if update_image_exif_filename "$poster_image" "$video_identifier"; then
                    log_debug "Identificador guardado en EXIF: $poster_image"
                    # Actualizar cache externo tras procesamiento exitoso
                    update_external_cache "$poster_image" "$video_identifier" "1"
                else
                    log_warning "No se pudo guardar identificador en: $poster_image"
                    # Marcar como no procesada en cache externo
                    update_external_cache "$poster_image" "$video_identifier" "0"
                fi
            else
                log_warning "No hay identificador del video para guardar"
            fi
            ((success_count++))
            log_debug "✓ Overlay aplicado exitosamente: $poster_image"
        else
            log_warning "Error aplicando overlay: $poster_image"
        fi
    done
    
    # 9. Verificar resultado final
    if [[ $success_count -gt 0 ]]; then
        log_info "✓ Procesamiento completado para: $media_path ($success_count/${#valid_images[@]} imágenes procesadas)"
        return 0
    else
        log_warning "Error: No se pudo procesar ninguna imagen para: $media_path"
        return 1
    fi
}

# =============================================================================
# FUNCIONES OPTIMIZADAS
# =============================================================================

# Función optimizada con filtros previos + cache externo
is_image_processed_optimized() {
    local image_file="$1"
    local video_file="$2"
    
    if [[ ! -f "$image_file" || -z "$video_file" ]]; then
        return 1
    fi
    
    # FILTRO PREVIO 1: Tamaño de archivo (ultra-rápido)
    local file_size=$(stat -c%s "$image_file" 2>/dev/null || stat -f%z "$image_file" 2>/dev/null)
    if [[ -n "$file_size" && "$file_size" -lt 1024 ]]; then
        log_debug "Filtro tamaño: Archivo muy pequeño ($file_size bytes), saltando: $(basename "$image_file")"
        return 1  # Archivo muy pequeño, probablemente corrupto
    fi
    
    # FILTRO PREVIO 2: Fecha de modificación (ultra-rápido)
    if [[ -f "$video_file" ]]; then
        local image_mtime=$(stat -c%Y "$image_file" 2>/dev/null || stat -f%m "$image_file" 2>/dev/null)
        local video_mtime=$(stat -c%Y "$video_file" 2>/dev/null || stat -f%m "$video_file" 2>/dev/null)
        
        if [[ -n "$image_mtime" && -n "$video_mtime" && "$image_mtime" -gt "$video_mtime" ]]; then
            log_debug "Filtro fecha: Imagen más reciente que video, asumiendo procesada: $(basename "$image_file")"
            return 0  # Imagen modificada después del video = probablemente ya procesada
        fi
    fi
    
    # FILTRO 3: Cache externo (rápido) - sistema ya implementado
    is_image_processed_external "$image_file" "$video_file"
}

# =============================================================================
# FUNCIONES DE PROCESAMIENTO POR TIPO
# =============================================================================

process_movies() {
    local force_process="$1"
    
    log_info "Procesando películas..."
    
    # Escanear y añadir a cola
    scan_and_queue "$MOVIES_DIR" "movie" "$force_process"
    
    # Procesar cola
    process_queue
}

process_series() {
    local force_process="$1"
    
    log_info "Procesando series..."
    
    # Escanear y añadir a cola
    scan_and_queue "$SERIES_DIR" "tvshow" "$force_process"
    
    # Procesar cola
    process_queue
}

process_all() {
    local force_process="$1"
    
    log_info "Procesando toda la biblioteca multimedia..."
    
    # Escanear y añadir a cola ambos tipos
    scan_and_queue "$MOVIES_DIR" "movie" "$force_process"
    scan_and_queue "$SERIES_DIR" "tvshow" "$force_process"
    
    # Procesar cola
    process_queue
}

show_usage() {
    cat << EOF
Uso: $(basename "$0") [COMANDO] [OPCIONES]

COMANDOS:
    movies          Escanear y añadir películas a cola, luego procesar cola
    series          Escanear y añadir series a cola, luego procesar cola
    all             Escanear y añadir toda la biblioteca a cola, luego procesar cola
    webhook         Procesar evento específico de webhook (automático)
    setup           Instalar dependencias necesarias (exiftool, imagemagick, etc.)
    
    Si no se especifica comando:
    - Con variables de webhook: procesa evento específico
    - Sin variables de webhook: procesa toda la biblioteca

OPCIONES:
    -f, --force     Forzar reprocesamiento:
                   - Limpia cache externo y EXIF
                   - Añade todo a cola sin verificar cache
                   - Procesa todo ignorando optimizaciones
    -h, --help      Mostrar esta ayuda

EJEMPLOS:
    $(basename "$0")                    # Auto-detectar: webhook o biblioteca completa
    $(basename "$0") movies             # Escanear películas → cola → procesar
    $(basename "$0") series -f          # Escanear series forzado → cola → procesar
    $(basename "$0") all --force        # Biblioteca completa forzado → cola → procesar
    $(basename "$0") setup              # Instalar dependencias necesarias

FLUJO DEL SISTEMA:
    1. ESCANEO: Verificar cache y añadir items necesarios a cola
    2. COLA: Items pendientes de procesamiento (sin verificación cache)
    3. PROCESAMIENTO: Aplicar overlays y actualizar cache
    
    - Sin -f: Solo añade a cola items que no están en cache
    - Con -f: Limpia cache y añade todo a cola
    - Cola se procesa siempre sin verificar cache
    - Items salen de cola solo tras procesamiento exitoso

NOTAS:
    - Los logs se guardan en: $LOG_DIR
    - Cache externo: $DATA_DIR/lang-flags-cache.txt
    - Colas por contenedor: $RADARR_QUEUE / $SONARR_QUEUE
EOF
}

# =============================================================================
# FUNCIÓN PRINCIPAL Y PARSEO DE ARGUMENTOS
# =============================================================================

get_total_queue_count() {
    local radarr_count=0
    local sonarr_count=0
    
    if [[ -f "$RADARR_QUEUE" ]]; then
        radarr_count=$(wc -l < "$RADARR_QUEUE" 2>/dev/null || echo "0")
    fi
    
    if [[ -f "$SONARR_QUEUE" ]]; then
        sonarr_count=$(wc -l < "$SONARR_QUEUE" 2>/dev/null || echo "0")
    fi
    
    echo $((radarr_count + sonarr_count))
}

main() {
    local command=""
    local force_process="false"
    
    # Parsear argumentos
    while [[ $# -gt 0 ]]; do
        case $1 in
            movies|series|all|webhook|setup)
                command="$1"
                shift
                ;;
            -f|--force)
                force_process="true"
                shift
                ;;
            -h|--help)
                show_usage
                exit 0
                ;;
            *)
                log_error "Argumento desconocido: $1"
                show_usage
                exit 1
                ;;
        esac
    done
    
    # Si no se especifica comando, detectar si es webhook o procesamiento completo
    if [[ -z "$command" ]]; then
        # Si hay variables de webhook, procesar evento específico
        if [[ -n "$radarr_eventtype" || -n "$sonarr_eventtype" ]]; then
            command="webhook"
        else
            # Sin webhook, procesar toda la biblioteca
            command="all"
        fi
    fi
    
    # Crear directorios necesarios
    create_dirs
    
    # Configurar logging
    setup_logging
    
    log_info "Iniciando Lang-Flags Beta - Versión $SCRIPT_VERSION"
    log_info "Comando: $command | Forzar: $force_process"
    
    # Limpiar cache externo al inicio (opcional, solo si no es force)
    if [[ "$force_process" != "true" ]]; then
        cleanup_external_cache
    fi
    
    # Ejecutar comando correspondiente
    case "$command" in
        webhook)
            # Procesar evento de webhook específico (SOLO añadir a cola)
            process_webhook_event
            # NO procesar cola - se procesa en otro momento
            ;;
        movies)
            process_movies "$force_process"
            ;;
        series)
            process_series "$force_process"
            ;;
        all)
            process_all "$force_process"
            ;;
        setup)
            setup_dependencies
            ;;
        *)
            log_error "Comando desconocido: $command"
            show_usage
            exit 1
            ;;
    esac
    
    log_info "Proceso completado. Revisar logs en $LOG_DIR"
}

# =============================================================================
# EJECUCIÓN PRINCIPAL
# =============================================================================

# Ejecutar función principal con todos los argumentos
main "$@"