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
    if [[ -n "$radarr_eventtype" ]] || [[ "$(hostname)" =~ radarr ]] || [[ -f "/config/config.xml" ]] && grep -q "Radarr" "/config/config.xml" 2>/dev/null; then
        echo "radarr"
    elif [[ -n "$sonarr_eventtype" ]] || [[ "$(hostname)" =~ sonarr ]] || [[ -f "/config/config.xml" ]] && grep -q "Sonarr" "/config/config.xml" 2>/dev/null; then
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

# Directorios principales
readonly BASE_DIR="/flags"
readonly MEDIA_ROOT="/BibliotecaMultimedia"
readonly MOVIES_DIR="$MEDIA_ROOT/Peliculas"
readonly SERIES_DIR="$MEDIA_ROOT/Series"

# Directorios de trabajo
readonly OVERLAY_DIR="$BASE_DIR/4x3"
readonly CACHE_DIR="$BASE_DIR/cache"
readonly QUEUE_DIR="$BASE_DIR/queue"
readonly TMP_DIR="$BASE_DIR/tmp"
readonly LOG_DIR="$BASE_DIR/logs"

# Archivos de bloqueo (diferenciados por contenedor)
readonly SCAN_LOCK="$BASE_DIR/scan-$(detect_container_type).lock"
readonly PROCESS_LOCK="$BASE_DIR/process-$(detect_container_type).lock"

# Archivos de cola
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
    
    echo "[$timestamp] [$level] $message" | tee -a "${LOG_FILE:-/tmp/lang-flags.log}"
    
    # Solo mostrar DEBUG si está habilitado
    if [[ "$level" == "DEBUG" ]] && [[ "$DEBUG" != "true" ]]; then
        return
    fi
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
    local dirs=("$BASE_DIR" "$CACHE_DIR" "$QUEUE_DIR" "$TMP_DIR" "$LOG_DIR")
    
    for dir in "${dirs[@]}"; do
        if ! mkdir -p "$dir" 2>/dev/null; then
            log_warning "No se pudo crear directorio: $dir"
        fi
    done
}

check_dependencies() {
    local required=("exiftool" "jq" "convert" "ffprobe" "mediainfo" "mkvinfo" "rsvg-convert" "at")
    local missing=()
    
    for cmd in "${required[@]}"; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            missing+=("$cmd")
        fi
    done
    
    if [[ ${#missing[@]} -gt 0 ]]; then
        log_error "Dependencias faltantes: ${missing[*]}"
        return 1
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
        local season_poster="$series_dir/season$(printf "%02d" "$season_num")-poster.jpg"
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
    
    # Calcular tamaño de bandera (25% del ancho del poster, mínimo 80px, máximo 200px)
    local flag_width=$((poster_width * 25 / 100))
    if [[ $flag_width -lt 80 ]]; then flag_width=80; fi
    if [[ $flag_width -gt 200 ]]; then flag_width=200; fi
    
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
        
        # Paso 1: Convertir SVG a PNG pequeño (bandera) con color explícito
        if ! rsvg-convert -w "$flag_width" -h "$((flag_width * 3 / 4))" --format=png --background-color=transparent "$flag_file" -o "$temp_flag" 2>/dev/null; then
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
            # Ajustar posición para siguiente bandera
            y_offset=$((y_offset + (flag_width * 3 / 4) + 5))
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

get_video_checksum() {
    local video_file="$1"
    
    if [[ ! -f "$video_file" ]]; then
        return 1
    fi
    
    # Generar checksum del archivo de video (usando size + fecha de modificación para rapidez)
    local file_size=$(stat -c %s "$video_file" 2>/dev/null || echo 0)
    local file_mtime=$(stat -c %Y "$video_file" 2>/dev/null || echo 0)
    
    echo "${file_size}_${file_mtime}" | md5sum | cut -d' ' -f1
}

is_image_processed() {
    local image_file="$1"
    
    if [[ ! -f "$image_file" ]]; then
        return 1
    fi
    
    # SISTEMA UNIFICADO: Solo verificar UserComment con checksum
    local user_comment=$(exiftool -f -s3 -"UserComment" "$image_file" 2>/dev/null)
    
    if [[ -n "$user_comment" && "$user_comment" == LangFlags:* ]]; then
        return 0  # Ya procesada (tiene checksum válido)
    fi
    
    return 1  # No procesada
}

update_image_exif_checksum() {
    local image_file="$1"
    local video_checksum="$2"
    
    if [[ ! -f "$image_file" || -z "$video_checksum" ]]; then
        return 1
    fi
    
    # SISTEMA UNIFICADO: Solo UserComment con checksum (silenciar completamente exiftool)
    if exiftool -overwrite_original -UserComment="LangFlags:$video_checksum" "$image_file" >/dev/null 2>&1; then
        log_debug "Cache EXIF actualizado en: $(basename "$image_file") (UserComment=LangFlags:$video_checksum)"
        return 0
    else
        log_warning "No se pudo actualizar UserComment en: $(basename "$image_file")"
        return 1
    fi
}

get_image_exif_checksum() {
    local image_file="$1"
    
    if [[ ! -f "$image_file" ]]; then
        return 1
    fi
    
    # Extraer checksum del campo UserComment
    local checksum=$(exiftool -f -s3 -"UserComment" "$image_file" 2>/dev/null | grep "LangFlags:" | cut -d: -f2)
    
    if [[ -n "$checksum" ]]; then
        echo "$checksum"
        return 0
    else
        return 1
    fi
}

get_video_checksum_cached() {
    local video_file="$1"
    
    if [[ ! -f "$video_file" ]]; then
        return 1
    fi
    
    # OPTIMIZACIÓN: Intentar leer checksum del EXIF del video primero
    local cached_checksum=$(exiftool -f -s3 -"UserComment" "$video_file" 2>/dev/null | grep "LangFlags:" | cut -d: -f2)
    
    if [[ -n "$cached_checksum" ]]; then
        # NO hacer log aquí - solo retornar el checksum
        echo "$cached_checksum"
        return 0
    fi
    
    # Si no hay cache, calcular checksum (SIN guardarlo en el video para evitar problemas de permisos)
    local calculated_checksum
    calculated_checksum=$(get_video_checksum "$video_file")
    
    if [[ -n "$calculated_checksum" ]]; then
        # NO hacer log aquí - solo retornar el checksum calculado
        echo "$calculated_checksum"
        return 0
    fi
    
    return 1
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
    
    # Obtener checksum actual del archivo de video (usando cache optimizado)
    local current_checksum
    current_checksum=$(get_video_checksum_cached "$media_path" 2>/dev/null || echo "")
    
    for poster_file in "${poster_files[@]}"; do
        # MÉTODO UNIFICADO: Solo verificar UserComment con checksum
        local stored_checksum
        if stored_checksum=$(get_image_exif_checksum "$poster_file"); then
            if [[ -n "$current_checksum" && "$stored_checksum" == "$current_checksum" ]]; then
                log_debug "Cache HIT: $(basename "$poster_file") checksum coincide ($stored_checksum)"
                continue  # Esta imagen está actualizada
            else
                log_debug "Cache MISS: $(basename "$poster_file") checksum diferente ($stored_checksum vs $current_checksum)"
                return 0  # Necesita procesamiento
            fi
        else
            log_debug "Cache MISS: $(basename "$poster_file") sin UserComment válido"
            return 0  # Necesita procesamiento
        fi
    done
    
    # Si llegamos aquí, todas las imágenes tienen el checksum correcto
    log_debug "Cache HIT: Todas las imágenes actualizadas para: $media_path"
    return 1  # No necesita procesamiento
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
    
    # Obtener checksum del video para marcar en las imágenes (usando cache optimizado)
    local video_checksum
    video_checksum=$(get_video_checksum_cached "$media_path" 2>/dev/null)
    if [[ -z "$video_checksum" ]]; then
        log_warning "No se pudo calcular checksum del video: $media_path"
        video_checksum=""
    fi
    
    # 8. Aplicar overlays a cada imagen válida
    local success_count=0
    for poster_image in "${valid_images[@]}"; do
        log_debug "Procesando imagen: $poster_image"
        
        if apply_language_overlays "$poster_image" "${languages[@]}"; then
            # Marcar imagen como procesada guardando SOLO el checksum del video
            if [[ -n "$video_checksum" ]]; then
                if update_image_exif_checksum "$poster_image" "$video_checksum"; then
                    log_debug "Checksum guardado en EXIF: $poster_image"
                else
                    log_warning "No se pudo guardar checksum en: $poster_image"
                fi
            else
                log_warning "No hay checksum del video para guardar"
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
# PROGRAMACIÓN DIFERIDA CON AT
# =============================================================================

# =============================================================================
# PROGRAMACIÓN DIFERIDA (ELIMINADA - SE USA SOLO CRON)
# =============================================================================

# Nota: La funcionalidad de programación diferida con 'at' ha sido eliminada.
# Todo el procesamiento se maneja inmediatamente o via cron cada 5 minutos.



# =============================================================================
# FUNCIONES DE ESCANEO SIN LOCKS (PARA USO CON LOCKS EXTERNOS)
# =============================================================================

scan_movies_no_lock() {
    local force_mode="${1:-false}"
    
    if [[ ! -d "$MOVIES_DIR" ]]; then
        log_warning "Directorio de películas no encontrado: $MOVIES_DIR"
        return 1
    fi

    if [[ "$force_mode" == "true" ]]; then
        log_info "Añadiendo TODAS las películas a cola (modo force)..."
    else
        log_info "Añadiendo películas pendientes a cola (verificando cache)..."
    fi

    local added_count=0
    local skipped_count=0
    local temp_file=$(mktemp)

    # Buscar archivos de video excluyendo trailers, extras, etc.
    find "$MOVIES_DIR" -type f \( -name "*.mkv" -o -name "*.mp4" -o -name "*.avi" -o -name "*.m4v" \) \
        ! -path "*/trailers/*" \
        ! -path "*/extras/*" \
        ! -path "*/behind the scenes/*" \
        ! -path "*/deleted scenes/*" \
        ! -path "*/featurettes/*" \
        ! -path "*/interviews/*" \
        ! -path "*/scenes/*" \
        ! -path "*/shorts/*" \
        ! -path "*/other/*" \
        ! -name "*trailer*" \
        ! -name "*-trailer.*" \
        ! -name "*_trailer.*" \
        ! -name "*Trailer*" \
        ! -name "*TRAILER*" \
        ! -name "*preview*" \
        ! -name "*teaser*" | sort > "$temp_file"

    while IFS= read -r video_file; do
        if [[ -n "$video_file" ]] && is_video_file "$video_file"; then
            # Verificar si necesita procesamiento (solo si no es modo force)
            if [[ "$force_mode" != "true" ]] && ! needs_processing "$video_file" "movie" false; then
                ((skipped_count++))
                log_debug "Omitiendo película actualizada: $(basename "$video_file")"
                continue
            fi

            if add_to_queue "$video_file" "movie"; then
                ((added_count++))
            fi
        fi
    done < "$temp_file"

    rm -f "$temp_file"

    if [[ "$force_mode" == "true" ]]; then
        log_info "✓ $added_count películas añadidas a cola (modo force)"
    else
        log_info "✓ $added_count películas añadidas a cola, $skipped_count omitidas (ya procesadas)"
    fi
}

scan_tvshows_no_lock() {
    local force_mode="${1:-false}"
    
    if [[ ! -d "$SERIES_DIR" ]]; then
        log_warning "Directorio de series no encontrado: $SERIES_DIR"
        return 1
    fi

    if [[ "$force_mode" == "true" ]]; then
        log_info "Añadiendo TODAS las series a cola (modo force)..."
    else
        log_info "Añadiendo series pendientes a cola (verificando cache)..."
    fi

    local added_count=0
    local skipped_count=0
    local temp_file=$(mktemp)

    # Buscar archivos de video excluyendo trailers, extras, etc.
    find "$SERIES_DIR" -type f \( -name "*.mkv" -o -name "*.mp4" -o -name "*.avi" -o -name "*.m4v" \) \
        ! -path "*/trailers/*" \
        ! -path "*/extras/*" \
        ! -path "*/behind the scenes/*" \
        ! -path "*/deleted scenes/*" \
        ! -path "*/featurettes/*" \
        ! -path "*/interviews/*" \
        ! -path "*/scenes/*" \
        ! -path "*/shorts/*" \
        ! -path "*/other/*" \
        ! -name "*trailer*" \
        ! -name "*-trailer.*" \
        ! -name "*_trailer.*" \
        ! -name "*Trailer*" \
        ! -name "*TRAILER*" \
        ! -name "*preview*" \
        ! -name "*teaser*" | sort > "$temp_file"

    while IFS= read -r video_file; do
        if [[ -n "$video_file" ]] && is_video_file "$video_file"; then
            # Verificar si necesita procesamiento (solo si no es modo force)
            if [[ "$force_mode" != "true" ]] && ! needs_processing "$video_file" "tvshow" false; then
                ((skipped_count++))
                log_debug "Omitiendo serie/episodio actualizado: $(basename "$video_file")"
                continue
            fi

            if add_to_queue "$video_file" "tvshow"; then
                ((added_count++))
            fi
        fi
    done < "$temp_file"

    rm -f "$temp_file"

    if [[ "$force_mode" == "true" ]]; then
        log_info "✓ $added_count series/episodios añadidos a cola (modo force)"
    else
        log_info "✓ $added_count series/episodios añadidos a cola, $skipped_count omitidos (ya procesados)"
    fi
}

# =============================================================================
# CONFIGURACIÓN COMPLETA DEL ENTORNO
# =============================================================================

setup_environment() {
    log_info "=== Configuración completa del entorno Lang-Flags ==="
    
    # 0. Limpiar estado previo (locks y procesos del contenedor actual)
    log_info "Paso 0/4: Limpiando estado previo del contenedor ${CONTAINER_TYPE}..."
    
    # Detectar tipo de contenedor actual
    local current_container=$(detect_container_type)
    
    # Limpiar solo los locks del contenedor actual
    for lock_type in "scan" "process"; do
        local lock_file="$BASE_DIR/${lock_type}-${current_container}.lock"
        if [[ -f "$lock_file" ]]; then
            log_info "Eliminando lock existente: $lock_file"
            rm -f "$lock_file" 2>/dev/null || true
        fi
    done
    
    # También limpiar locks antiguos sin diferenciación (por compatibilidad)
    for old_lock in "$BASE_DIR/scan.lock" "$BASE_DIR/process.lock"; do
        if [[ -f "$old_lock" ]]; then
            log_info "Eliminando lock antiguo sin diferenciación: $old_lock"
            rm -f "$old_lock" 2>/dev/null || true
        fi
    done
    
    # Terminar procesos previos del script
    local script_name="lang-flags-beta.bash"
    local current_pid=$$
    local found_processes=false
    
    log_info "Buscando procesos previos del script (PID actual: $current_pid)..."
    
    # Terminar procesos previos del script
    local script_name="lang-flags-beta.bash"
    local current_pid=$$
    local found_processes=false
    
    log_info "Buscando procesos previos del script (PID actual: $current_pid)..."
    
    # Buscar procesos activos del script (excluyendo el actual y procesos padre)
    local script_processes=$(ps -eo pid,ppid,comm,args | grep -F "$script_name" | grep -v grep | grep -v "^[[:space:]]*$current_pid[[:space:]]")
    
    if [[ -n "$script_processes" ]]; then
        log_debug "Procesos encontrados:\n$script_processes"
        
        while IFS= read -r line; do
            [[ -z "$line" ]] && continue
            
            local pid=$(echo "$line" | awk '{print $1}')
            local ppid=$(echo "$line" | awk '{print $2}')
            local args=$(echo "$line" | awk '{for(i=4;i<=NF;i++) printf "%s ", $i; print ""}')
            
            # Validar que es un PID numérico válido y no es el proceso actual
            if [[ "$pid" =~ ^[0-9]+$ ]] && [[ "$pid" != "$current_pid" ]] && [[ "$pid" -gt 1 ]]; then
                # Evitar matar el proceso si es setup o si es el proceso padre
                if [[ ! "$args" =~ setup ]] && [[ "$ppid" != "$current_pid" ]]; then
                    # Verificar que el proceso aún existe antes de matarlo
                    if kill -0 "$pid" 2>/dev/null; then
                        log_info "Terminando proceso previo: PID $pid ($args)"
                        kill "$pid" 2>/dev/null || true
                        found_processes=true
                    else
                        log_debug "Proceso PID $pid ya no existe"
                    fi
                else
                    log_debug "Ignorando proceso setup o proceso padre: PID $pid"
                fi
            else
                log_debug "PID inválido o proceso actual: $pid"
            fi
        done <<< "$script_processes"
    else
        log_info "No se encontraron procesos previos del script"
    fi
    
    if [[ "$found_processes" == "true" ]]; then
        log_info "Esperando 3 segundos para que terminen los procesos..."
        sleep 3
    else
        log_info "No se encontraron procesos previos del script"
    fi
    
    log_info "✓ Estado previo limpiado correctamente"
    
    # 1. Instalar dependencias del sistema
    log_info "Paso 1/4: Instalando dependencias del sistema..."
    
    local installed=false
    
    # Detectar y usar el gestor de paquetes disponible
    if command -v apt-get >/dev/null 2>&1; then
        export DEBIAN_FRONTEND=noninteractive
        apt-get update -qq >/dev/null 2>&1
        apt-get install -y -qq imagemagick libimage-exiftool-perl jq ffmpeg mediainfo mkvtoolnix librsvg2-bin curl wget bc cron >/dev/null 2>&1
        installed=true
        log_info "✓ Dependencias instaladas con apt-get (incluyendo 'at')"
    elif command -v apk >/dev/null 2>&1; then
        apk add --no-cache imagemagick exiftool jq ffmpeg mediainfo mkvtoolnix librsvg rsvg-convert curl wget bc bash dcron >/dev/null 2>&1
        installed=true
        log_info "✓ Dependencias instaladas con apk (incluyendo 'at')"
    elif command -v yum >/dev/null 2>&1; then
        yum install -y -q ImageMagick perl-Image-ExifTool jq ffmpeg mediainfo mkvtoolnix librsvg2 curl wget bc cronie >/dev/null 2>&1
        installed=true
        log_info "✓ Dependencias instaladas con yum (incluyendo 'at')"
    fi
    
    if ! $installed; then
        log_error "✗ No se pudo instalar dependencias: gestor de paquetes no compatible"
        return 1
    fi
    
    # Verificar instalación de dependencias
    if check_dependencies; then
        log_info "✓ Todas las dependencias están disponibles"
    else
        log_error "✗ Faltan dependencias después de la instalación"
        return 1
    fi
    
    # 2. Configurar cron para procesamiento automático
    log_info "Paso 2/3: Configurando cron para procesamiento automático..."
    
    local cron_file="/etc/cron.d/lang-flags"
    
    # Definir todas las entradas de cron (evita duplicados al sobreescribir)
    local cron_entries=(
        "*/5 * * * * root /flags/lang-flags-beta.bash processqueue >/dev/null 2>&1"
        "0 3 * * 0 root /flags/lang-flags-beta.bash >/dev/null 2>&1  # Semanal automático (detecta origen)"
        "0 2 1 * * root /flags/lang-flags-beta.bash -f >/dev/null 2>&1  # Mensual forzado automático"
    )
    
    # Siempre sobreescribir archivo cron para evitar duplicados
    {
        echo "# Lang-Flags automatización - Generado automáticamente"
        printf '%s\n' "${cron_entries[@]}"
    } > "$cron_file" 2>/dev/null || {
        log_warning "No se pudo crear archivo cron, intentando crontab..."
        
        # Intentar con crontab del usuario (limpiar entradas previas)
        (
            crontab -l 2>/dev/null | grep -v lang-flags
            printf '%s\n' "${cron_entries[@]}" | sed 's/^[^[:space:]]*[[:space:]]*[^[:space:]]*[[:space:]]*[^[:space:]]*[[:space:]]*[^[:space:]]*[[:space:]]*[^[:space:]]*[[:space:]]*root[[:space:]]*//'
        ) | crontab - 2>/dev/null || {
            log_error "✗ No se pudo configurar cron"
            return 1
        }
        
        log_info "✓ Cron configurado con crontab (${#cron_entries[@]} entradas)"
        return 0
    }
    
    chmod 644 "$cron_file" 2>/dev/null
    log_info "✓ Cron configurado en: $cron_file (${#cron_entries[@]} entradas)"
    
    # Iniciar servicio cron
    log_info "Iniciando servicio cron..."
    
    # Intentar iniciar cron
    local cron_started=false
    if command -v service >/dev/null 2>&1; then
        if service cron start >/dev/null 2>&1 || service crond start >/dev/null 2>&1; then
            cron_started=true
            log_debug "✓ Servicio cron iniciado con 'service'"
        fi
    elif command -v systemctl >/dev/null 2>&1; then
        if systemctl start cron >/dev/null 2>&1 || systemctl start crond >/dev/null 2>&1; then
            cron_started=true
            log_debug "✓ Servicio cron iniciado con 'systemctl'"
        fi
    fi
    
    if ! $cron_started; then
        log_warning "⚠ No se pudo iniciar servicio cron automáticamente"
    else
        log_info "✓ Servicio cron configurado y funcionando"
    fi
    
    # 3. Generar script de inicialización del contenedor
    log_info "Paso 3/3: Generando script de inicialización del contenedor..."
    
    if generate_container_init_script; then
        log_info "✓ Script de inicialización generado correctamente"
    else
        log_warning "⚠ No se pudo generar script de inicialización (no crítico)"
    fi
    
    log_info "=== ✓ Configuración del entorno completada exitosamente ==="
    log_info "El sistema está listo para procesar overlays de idioma automáticamente."
    log_info "Use '$0 all' para añadir la biblioteca completa a las colas de procesamiento."
    
    return 0
}

generate_container_init_script() {
    local init_script="/custom-cont-init.d/lang_flags-install_deps.sh"

    log_debug "Generando script de inicialización del contenedor (siempre sobreescribe)..."

    # Crear directorio si no existe
    mkdir -p "/custom-cont-init.d" 2>/dev/null || {
        log_debug "No se pudo crear /custom-cont-init.d"
        return 1
    }

    # Siempre borrar archivo existente para sobreescribir
    rm -f "$init_script" 2>/dev/null || true

    # Generar script simplificado que usa la función boot_process
    cat > "$init_script" << 'EOF'
#!/bin/bash
echo "[$(date)] Lang-Flags-Beta: Inicializando sistema..."

# 1. Configurar entorno completo (dependencias + cron)
echo "[$(date)] Lang-Flags-Beta: Ejecutando setup..."
/flags/lang-flags-beta.bash setup

# 2. Lanzar boot_process en segundo plano
echo "[$(date)] Lang-Flags-Beta: Lanzando boot_process en segundo plano..."
/flags/lang-flags-beta.bash boot_process &

echo "[$(date)] Lang-Flags-Beta: Inicialización completada"
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

# =============================================================================
# AÑADIR ELEMENTOS A LA COLA
# =============================================================================

add_to_queue() {
    local media_path="$1"
    local media_type="$2"
    
    if [[ -z "$media_path" || ! -f "$media_path" ]]; then
        log_error "Archivo no válido: $media_path"
        return 1
    fi
    
    # Determinar cola apropiada
    local queue_file
    if [[ "$media_type" == "movie" ]]; then
        queue_file="$RADARR_QUEUE"
    elif [[ "$media_type" == "tvshow" || "$media_type" == "series" ]]; then
        queue_file="$SONARR_QUEUE"
    else
        # Auto-detectar tipo basado en ruta
        if [[ "$media_path" =~ $MOVIES_DIR ]]; then
            queue_file="$RADARR_QUEUE"
            media_type="movie"
        elif [[ "$media_path" =~ $SERIES_DIR ]]; then
            queue_file="$SONARR_QUEUE"
            media_type="tvshow"
        else
            log_error "No se pudo determinar el tipo de medios para: $media_path"
            return 1
        fi
    fi
    
    # Verificar si ya está en cola
    if [[ -f "$queue_file" ]] && grep -Fq "|$media_path" "$queue_file"; then
        log_debug "Elemento ya en cola: $media_path"
        return 0
    fi
    
    # Añadir a cola
    echo "$(date +%s)|Manual|$media_path" >> "$queue_file"
    log_info "✓ Añadido a cola ($media_type): $media_path"
    
    return 0
}
# =============================================================================
# PROCESAMIENTO AUTOMÁTICO CON DETECCIÓN DE ORIGEN
# =============================================================================

auto_scan_and_process() {
    log_info "=== PROCESAMIENTO AUTOMÁTICO INICIADO ==="
    
    # 1. Intentar adquirir lock de escaneo
    if ! acquire_lock "$SCAN_LOCK" 300 "auto-scan"; then
        log_warning "No se pudo adquirir lock de escaneo, otro proceso está ejecutándose"
        return 1
    fi
    
    # Configurar limpieza al salir
    trap 'cleanup_locks; exit' EXIT INT TERM
    
    # 2. Detectar origen y escanear correspondientemente (sin espera)
    local scan_movies=false
    local scan_series=false
    
    # Detectar si viene de Radarr basado en variables de entorno oficiales
    if [[ -n "$radarr_eventtype" ]]; then
        log_info "Origen detectado: RADARR (evento: $radarr_eventtype) - Escaneando solo películas"
        if [[ -n "$radarr_movie_path" ]]; then
            log_info "Ruta específica: $radarr_movie_path"
        fi
        scan_movies=true
    # Detectar si viene de Sonarr basado en variables de entorno oficiales
    elif [[ -n "$sonarr_eventtype" ]]; then
        log_info "Origen detectado: SONARR (evento: $sonarr_eventtype) - Escaneando solo series"
        if [[ -n "$sonarr_series_path" ]]; then
            log_info "Ruta específica: $sonarr_series_path"
        elif [[ -n "$sonarr_episodefile_path" ]]; then
            log_info "Archivo específico: $sonarr_episodefile_path"
        fi
        scan_series=true
    else
        # Detectar por hostname/contenedor
        local hostname=$(hostname 2>/dev/null || echo "")
        if [[ "$hostname" =~ radarr ]]; then
            log_info "Origen detectado por hostname: RADARR ($hostname) - Escaneando solo películas"
            scan_movies=true
        elif [[ "$hostname" =~ sonarr ]]; then
            log_info "Origen detectado por hostname: SONARR ($hostname) - Escaneando solo series"
            scan_series=true
        # Detectar por directorio de trabajo/estructura
        elif [[ "$PWD" =~ radarr ]] || [[ -d "/config" && -f "/config/config.xml" ]] && grep -q "radarr" "/config/config.xml" 2>/dev/null; then
            log_info "Origen detectado por directorio: RADARR - Escaneando solo películas"
            scan_movies=true
        elif [[ "$PWD" =~ sonarr ]] || [[ -d "/config" && -f "/config/config.xml" ]] && grep -q "sonarr" "/config/config.xml" 2>/dev/null; then
            log_info "Origen detectado por directorio: SONARR - Escaneando solo series"
            scan_series=true
        else
            # Solo como último recurso, escanear ambos
            log_warning "Origen no detectado - Escaneando películas y series (fallback)"
            scan_movies=true
            scan_series=true
        fi
    fi
    
    # 3. Ejecutar escaneos correspondientes (solo elementos pendientes)
    local scan_success=true
    
    if [[ "$scan_movies" == "true" ]]; then
        log_info "Añadiendo películas pendientes a cola..."
        if ! scan_movies_no_lock false; then  # false = no force, solo pendientes
            log_error "Error escaneando películas"
            scan_success=false
        fi
    fi
    
    if [[ "$scan_series" == "true" ]]; then
        log_info "Añadiendo series pendientes a cola..."
        if ! scan_tvshows_no_lock false; then  # false = no force, solo pendientes
            log_error "Error escaneando series"
            scan_success=false
        fi
    fi
    
    # 4. Liberar lock de escaneo
    release_lock "$SCAN_LOCK"
    
    if [[ "$scan_success" != "true" ]]; then
        log_error "Error durante el escaneo, no se procesará la cola"
        return 1
    fi
    
    # 5. Verificar si hay elementos en las colas
    local radarr_count=$(wc -l < "$RADARR_QUEUE" 2>/dev/null || echo 0)
    local sonarr_count=$(wc -l < "$SONARR_QUEUE" 2>/dev/null || echo 0)
    local total_count=$((radarr_count + sonarr_count))
    
    if [[ "$total_count" -eq 0 ]]; then
        log_info "No hay elementos en las colas para procesar"
        return 0
    fi
    
    log_info "Elementos en colas: $radarr_count (películas) + $sonarr_count (series) = $total_count total"
    
    # 6. Procesar inmediatamente (ya no se usa programación diferida)
    log_info "Procesando colas inmediatamente..."
    if ! acquire_lock "$PROCESS_LOCK" 600 "immediate-process"; then
        log_warning "No se pudo adquirir lock de procesamiento"
        return 1
    fi
    
    if process_all_queues; then
        log_info "✓ Procesamiento completado exitosamente"
    else
        log_error "Error durante el procesamiento de colas"
        release_lock "$PROCESS_LOCK"
        return 1
    fi
    
    release_lock "$PROCESS_LOCK"
    
    log_info "=== PROCESAMIENTO AUTOMÁTICO FINALIZADO ==="
    return 0
}

# =============================================================================
# FUNCIÓN PRINCIPAL
# =============================================================================

show_help() {
    cat << 'EOF'
Lang-Flags-Beta v3.0 - Script de Overlays de Idioma para Radarr/Sonarr

MODOS DE EJECUCIÓN:
  (sin argumentos)          Procesamiento automático con detección de origen y locks
  all [-f]                  Añadir biblioteca a colas (-f: forzar todo, sin -f: solo pendientes)
  movies [-f]               Añadir películas a cola (-f: forzar todas, sin -f: solo pendientes)
  series [-f]               Añadir series a cola (-f: forzar todas, sin -f: solo pendientes)
  additem <path> [type]     Añadir elemento específico a cola (type: movie|series)
  processqueue, queue       Procesar elementos en las colas (con lock)
  debug-events              Verificar detección de variables de entorno de eventos
  boot_process              Proceso de inicialización (auto-scan + process, para contenedores)
  set-deps, --install-deps  Instalar dependencias del sistema
  set-cron, --setup-cron    Configurar cron para procesamiento automático
  test                      Verificar configuración
  help, --help              Mostrar esta ayuda

PROCESAMIENTO AUTOMÁTICO (sin argumentos):
  1. Adquiere lock de escaneo (.lock)
  2. Detecta origen (Radarr/Sonarr) y escanea correspondientemente
  3. Libera lock de escaneo
  4. Adquiere lock de procesamiento
  5. Procesa todas las colas
  6. Libera lock de procesamiento

PARÁMETROS:
  -f, --force               Forzar procesamiento (ignorar cache EXIF)

EJEMPLOS:
  $0                        # Procesamiento automático con locks y detección
  $0 all                    # Añadir solo elementos pendientes a colas
  $0 all -f                 # Forzar añadir TODA la biblioteca a colas
  $0 movies -f              # Forzar añadir TODAS las películas a cola
  $0 series                 # Añadir solo series pendientes a cola
  $0 additem "/path/movie.mkv" movie   # Añadir película específica a cola
  $0 processqueue           # Procesar cola manualmente
  $0 set-deps               # Instalar dependencias
  $0 set-cron               # Configurar cron

EVENTOS AUTOMÁTICOS:
  El script se ejecuta automáticamente desde Radarr/Sonarr via webhooks
  y procesa elementos añadiéndolos a colas. El sistema de locks evita 
  ejecuciones concurrentes. El procesamiento se realiza via cron cada 5 minutos.

DETECCIÓN DE ORIGEN:
  - Radarr: Variables radarr_eventtype, radarr_movie_path
  - Sonarr: Variables sonarr_eventtype, sonarr_series_path, sonarr_episodefile_path
  - Eventos soportados: Download, Rename, Grab, Test

PROCESAMIENTO:
  Los elementos se añaden a colas y son procesados automáticamente
  cada 5 minutos via cron (/etc/cron.d/lang-flags).

EOF
}

debug_processing() {
    local video_file="$1"
    
    if [[ ! -f "$video_file" ]]; then
        echo "ERROR: Archivo no encontrado: $video_file"
        return 1
    fi
    
    echo "=== DEBUGGING NEEDS_PROCESSING ==="
    echo "Video: $video_file"
    echo ""
    
    # 1. Calcular checksum actual (usando cache optimizado)
    local current_checksum
    if ! current_checksum=$(get_video_checksum "$video_file"); then
        echo "ERROR: No se pudo calcular checksum del video"
        return 1
    fi
    echo "1. Checksum actual del video: $current_checksum"
    
    # 2. Encontrar imágenes
    local poster_result
    if ! poster_result=$(find_poster_image "$video_file" "movie"); then
        echo "ERROR: No se encontraron imágenes"
        return 1
    fi
    echo "2. Imágenes encontradas: $poster_result"
    
    # 3. Verificar cada imagen
    local poster_files
    IFS=';' read -ra poster_files <<< "$poster_result"
    for poster_file in "${poster_files[@]}"; do
        echo "3. Verificando: $(basename "$poster_file")"
        
        # Verificar UserComment
        local user_comment=$(exiftool -f -s3 -"UserComment" "$poster_file" 2>/dev/null)
        echo "   UserComment: ${user_comment:-'(no set)'}"
        
        # Extraer checksum almacenado
        local stored_checksum=$(get_image_exif_checksum "$poster_file" 2>/dev/null)
        echo "   Checksum almacenado: ${stored_checksum:-'(no set)'}"
        
        # Verificar is_image_processed
        if is_image_processed "$poster_file"; then
            echo "   is_image_processed: TRUE"
        else
            echo "   is_image_processed: FALSE"
        fi
    done
    
    # 4. Resultado needs_processing
    if needs_processing "$video_file" "movie" false; then
        echo "4. Needs processing: TRUE"
    else
        echo "4. Needs processing: FALSE"
    fi
    
    echo "=== DEBUG COMPLETADO ==="
}

debug_event_detection() {
    echo "=== DEBUG DETECCIÓN DE EVENTOS ==="
    echo "Variables de entorno encontradas:"
    echo "  radarr_eventtype: ${radarr_eventtype:-'no definida'}"
    echo "  radarr_movie_path: ${radarr_movie_path:-'no definida'}"
    echo "  radarr_moviefile_path: ${radarr_moviefile_path:-'no definida'}"
    echo "  sonarr_eventtype: ${sonarr_eventtype:-'no definida'}"
    echo "  sonarr_series_path: ${sonarr_series_path:-'no definida'}"
    echo "  sonarr_episodefile_path: ${sonarr_episodefile_path:-'no definida'}"
    echo ""
    
    # Simular lógica de detección
    local scan_movies=false
    local scan_series=false
    
    if [[ -n "$radarr_eventtype" ]]; then
        echo "RESULTADO: RADARR detectado (evento: $radarr_eventtype)"
        if [[ -n "$radarr_movie_path" ]]; then
            echo "  Ruta específica: $radarr_movie_path"
        fi
        scan_movies=true
    elif [[ -n "$sonarr_eventtype" ]]; then
        echo "RESULTADO: SONARR detectado (evento: $sonarr_eventtype)"
        if [[ -n "$sonarr_series_path" ]]; then
            echo "  Ruta específica: $sonarr_series_path"
        elif [[ -n "$sonarr_episodefile_path" ]]; then
            echo "  Archivo específico: $sonarr_episodefile_path"
        fi
        scan_series=true
    else
        echo "RESULTADO: Origen no detectado - escanear ambos"
        scan_movies=true
        scan_series=true
    fi
    
    echo "Configuración:"
    echo "  scan_movies: $scan_movies"
    echo "  scan_series: $scan_series"
    echo "=== FIN DEBUG ==="
}

# =============================================================================
# FUNCIÓN BOOT PROCESS (PARA INICIALIZACIÓN DEL CONTENEDOR)
# =============================================================================

boot_process() {
    log_info "=== BOOT PROCESS INICIADO ==="
    
    # Esperar 2 minutos para que el contenedor se estabilice
    log_info "Esperando 120 segundos para estabilización del contenedor..."
    sleep 120
    
    # 1. Ejecutar procesamiento automático (detecta origen y procesa correspondientemente)
    log_info "Iniciando procesamiento automático..."
    if auto_scan_and_process; then
        log_info "✓ Procesamiento automático completado"
    else
        log_warning "⚠ Error en procesamiento automático"
    fi
    
    # 2. Procesar colas inmediatamente
    log_info "Procesando colas..."
    if acquire_lock "$PROCESS_LOCK" 600 "boot-process"; then
        if process_all_queues; then
            log_info "✓ Procesamiento de colas completado"
        else
            log_warning "⚠ Error procesando colas"
        fi
        release_lock "$PROCESS_LOCK"
    else
        log_warning "⚠ No se pudo adquirir lock para procesamiento de colas"
    fi
    
    log_info "=== BOOT PROCESS COMPLETADO ==="
    return 0
}

# =============================================================================
# PROCESAMIENTO DE COLAS
# =============================================================================

process_all_queues() {
    log_info "=== PROCESANDO TODAS LAS COLAS ==="
    
    local total_processed=0
    local total_failed=0
    
    # Procesar cola de Radarr (películas)
    if [[ -f "$RADARR_QUEUE" ]]; then
        local radarr_count=$(wc -l < "$RADARR_QUEUE" 2>/dev/null || echo 0)
        if [[ "$radarr_count" -gt 0 ]]; then
            log_info "Procesando cola de Radarr: $radarr_count elementos"
            
            # Procesamiento línea por línea con eliminación inmediata
            while [[ -s "$RADARR_QUEUE" ]]; do
                # Leer primera línea de la cola
                local first_line=$(head -n 1 "$RADARR_QUEUE" 2>/dev/null)
                [[ -z "$first_line" ]] && break
                
                # Extraer datos de la línea
                IFS='|' read -r timestamp origin path <<< "$first_line"
                [[ -z "$path" ]] && {
                    # Eliminar línea vacía inmediatamente
                    sed -i '1d' "$RADARR_QUEUE" 2>/dev/null || tail -n +2 "$RADARR_QUEUE" > "$RADARR_QUEUE.tmp" && mv "$RADARR_QUEUE.tmp" "$RADARR_QUEUE"
                    continue
                }
                
                log_info "Procesando película: $path"
                
                if process_media_item "$path" "movie"; then
                    ((total_processed++))
                    log_info "✓ Procesado correctamente: $(basename "$path") - ELIMINANDO de cola INMEDIATAMENTE"
                    # Eliminar primera línea de la cola INMEDIATAMENTE
                    sed -i '1d' "$RADARR_QUEUE" 2>/dev/null || {
                        tail -n +2 "$RADARR_QUEUE" > "$RADARR_QUEUE.tmp" && mv "$RADARR_QUEUE.tmp" "$RADARR_QUEUE"
                    }
                else
                    ((total_failed++))
                    log_warning "✗ Error procesando: $(basename "$path") - MANTENIDO en cola para reintento"
                    # Mover elemento fallido al final de la cola para evitar bucle infinito
                    sed -i '1d' "$RADARR_QUEUE" 2>/dev/null || {
                        tail -n +2 "$RADARR_QUEUE" > "$RADARR_QUEUE.tmp" && mv "$RADARR_QUEUE.tmp" "$RADARR_QUEUE"
                    }
                    echo "$timestamp|$origin|$path" >> "$RADARR_QUEUE"
                fi
                
                # Pequeña pausa entre procesamiento
                sleep 1
            done
        else
            log_info "Cola de Radarr vacía"
        fi
    else
        log_info "No existe cola de Radarr"
    fi
    
    # Procesar cola de Sonarr (series)
    if [[ -f "$SONARR_QUEUE" ]]; then
        local sonarr_count=$(wc -l < "$SONARR_QUEUE" 2>/dev/null || echo 0)
        if [[ "$sonarr_count" -gt 0 ]]; then
            log_info "Procesando cola de Sonarr: $sonarr_count elementos"
            
            # Procesamiento línea por línea con eliminación inmediata
            while [[ -s "$SONARR_QUEUE" ]]; do
                # Leer primera línea de la cola
                local first_line=$(head -n 1 "$SONARR_QUEUE" 2>/dev/null)
                [[ -z "$first_line" ]] && break
                
                # Extraer datos de la línea
                IFS='|' read -r timestamp origin path <<< "$first_line"
                [[ -z "$path" ]] && {
                    # Eliminar línea vacía inmediatamente
                    sed -i '1d' "$SONARR_QUEUE" 2>/dev/null || tail -n +2 "$SONARR_QUEUE" > "$SONARR_QUEUE.tmp" && mv "$SONARR_QUEUE.tmp" "$SONARR_QUEUE"
                    continue
                }
                
                log_info "Procesando serie/episodio: $path"
                
                if process_media_item "$path" "tvshow"; then
                    ((total_processed++))
                    log_info "✓ Procesado correctamente: $(basename "$path") - ELIMINANDO de cola INMEDIATAMENTE"
                    # Eliminar primera línea de la cola INMEDIATAMENTE
                    sed -i '1d' "$SONARR_QUEUE" 2>/dev/null || {
                        tail -n +2 "$SONARR_QUEUE" > "$SONARR_QUEUE.tmp" && mv "$SONARR_QUEUE.tmp" "$SONARR_QUEUE"
                    }
                else
                    ((total_failed++))
                    log_warning "✗ Error procesando: $(basename "$path") - MANTENIDO en cola para reintento"
                    # Mover elemento fallido al final de la cola para evitar bucle infinito
                    sed -i '1d' "$SONARR_QUEUE" 2>/dev/null || {
                        tail -n +2 "$SONARR_QUEUE" > "$SONARR_QUEUE.tmp" && mv "$SONARR_QUEUE.tmp" "$SONARR_QUEUE"
                    }
                    echo "$timestamp|$origin|$path" >> "$SONARR_QUEUE"
                fi
                
                # Pequeña pausa entre procesamiento
                sleep 1
            done
        else
            log_info "Cola de Sonarr vacía"
        fi
    else
        log_info "No existe cola de Sonarr"
    fi
    
    # Resumen final
    log_info "=== PROCESAMIENTO COMPLETADO ==="
    log_info "Total procesados: $total_processed"
    log_info "Total fallidos: $total_failed"
    
    if [[ "$total_processed" -gt 0 ]]; then
        return 0
    elif [[ "$total_failed" -gt 0 ]]; then
        return 1
    else
        log_info "No había elementos para procesar"
        return 0
    fi
}

handle_radarr_event() {
    log_info "=== EVENTO RADARR DETECTADO ==="
    log_info "Tipo de evento: ${radarr_eventtype:-unknown}"
    
    case "${radarr_eventtype,,}" in
        "download"|"rename"|"movieadded"|"movieupdated")
            if [[ -n "$radarr_movie_path" && -d "$radarr_movie_path" ]]; then
                log_info "Procesando película específica: $radarr_movie_path"
                find "$radarr_movie_path" -type f \( -name "*.mkv" -o -name "*.mp4" -o -name "*.avi" -o -name "*.m4v" \) \
                    ! -path "*/trailers/*" ! -path "*/extras/*" \
                    ! -name "*trailer*" ! -name "*Trailer*" \
                    | while IFS= read -r video_file; do
                    if [[ -n "$video_file" ]]; then
                        add_to_queue "$video_file" "movie"
                    fi
                done
                
                # Elementos añadidos a cola, el cron cada 5 minutos los procesará
                log_info "Elementos añadidos a cola. Procesamiento automático via cron cada 5 minutos."
            else
                log_warning "No se especificó ruta de película válida: ${radarr_movie_path:-'no definida'}"
            fi
            ;;
        "test")
            log_info "Evento de test de Radarr recibido correctamente"
            ;;
        *)
            log_warning "Evento Radarr no soportado: $radarr_eventtype"
            ;;
    esac
    
    log_info "=== EVENTO RADARR PROCESADO ==="
}

handle_sonarr_event() {
    log_info "=== EVENTO SONARR DETECTADO ==="
    log_info "Tipo de evento: ${sonarr_eventtype:-unknown}"
    
    case "${sonarr_eventtype,,}" in
        "download"|"rename"|"seriesadd"|"episodefileadded")
            if [[ -n "$sonarr_episodefile_path" && -f "$sonarr_episodefile_path" ]]; then
                log_info "Procesando episodio específico: $sonarr_episodefile_path"
                add_to_queue "$sonarr_episodefile_path" "tvshow"
            elif [[ -n "$sonarr_series_path" && -d "$sonarr_series_path" ]]; then
                log_info "Procesando serie completa: $sonarr_series_path"
                find "$sonarr_series_path" -type f \( -name "*.mkv" -o -name "*.mp4" -o -name "*.avi" -o -name "*.m4v" \) \
                    ! -path "*/trailers/*" ! -path "*/extras/*" \
                    ! -name "*trailer*" ! -name "*Trailer*" \
                    | while IFS= read -r video_file; do
                    if [[ -n "$video_file" ]]; then
                        add_to_queue "$video_file" "tvshow"
                    fi
                done
            else
                log_warning "No se especificó ruta válida. Serie: ${sonarr_series_path:-'no definida'}, Episodio: ${sonarr_episodefile_path:-'no definida'}"
            fi
            
            # Elementos añadidos a cola, el cron cada 5 minutos los procesará
            log_info "Elementos añadidos a cola. Procesamiento automático via cron cada 5 minutos."
            ;;
        "test")
            log_info "Evento de test de Sonarr recibido correctamente"
            ;;
        *)
            log_warning "Evento Sonarr no soportado: $sonarr_eventtype"
            ;;
    esac
    
    log_info "=== EVENTO SONARR PROCESADO ==="
}

main() {
    setup_logging
    create_dirs
    
    log_info "=== $SCRIPT_NAME v$SCRIPT_VERSION iniciado ==="
    log_info "PID: $$, Usuario: $(whoami), Argumentos: $*"
    
    # Siempre generar y ejecutar script de inicialización del contenedor
    local init_script_was_missing=false
    if [[ ! -f "/custom-cont-init.d/lang_flags-install_deps.sh" ]]; then
        init_script_was_missing=true
    fi
    
    generate_container_init_script
    
    # Si el script no existía, ejecutarlo inmediatamente
    if [[ "$init_script_was_missing" == "true" && -f "/custom-cont-init.d/lang_flags-install_deps.sh" ]]; then
        log_info "Ejecutando script de inicialización recién creado..."
        /custom-cont-init.d/lang_flags-install_deps.sh
    fi
    
    # Manejar eventos de Sonarr/Radarr (tienen prioridad)
    if [[ -n "$radarr_eventtype" ]]; then
        handle_radarr_event
        exit 0
    elif [[ -n "$sonarr_eventtype" ]]; then
        handle_sonarr_event
        exit 0
    fi
    
    # Procesar argumentos de línea de comandos
    local force_mode=false
    local main_command="$1"
    
    # Verificar si se pasó el parámetro -f
    if [[ "$2" == "-f" || "$1" == "-f" ]]; then
        force_mode=true
        # Si -f es el primer argumento, el comando real es el segundo
        if [[ "$1" == "-f" ]]; then
            main_command="$2"
        fi
    fi
    
    case "$main_command" in
        "all"|"--scan-all")
            if ! check_dependencies; then
                log_error "Dependencias faltantes. Ejecute: $0 set-deps"
                exit 1
            fi
            
            # Adquirir lock de escaneo primero
            if ! acquire_lock "$SCAN_LOCK" 300 "scan-all-movies-series"; then
                log_error "No se pudo adquirir lock de escaneo, otro proceso está ejecutándose"
                exit 1
            fi
            
            # Configurar limpieza al salir
            trap 'cleanup_locks; exit' EXIT INT TERM
            
            if [[ "$force_mode" == "true" ]]; then
                log_info "Añadiendo TODA la biblioteca a colas (modo force)..."
            else
                log_info "Añadiendo biblioteca pendiente a colas (verificando cache)..."
            fi
            
            # Escanear sin locks internos (ya tenemos el lock)
            local scan_success=true
            if ! scan_movies_no_lock "$force_mode"; then
                scan_success=false
            fi
            if ! scan_tvshows_no_lock "$force_mode"; then
                scan_success=false
            fi
            
            # Liberar lock de escaneo
            release_lock "$SCAN_LOCK"
            
            if [[ "$scan_success" != "true" ]]; then
                log_error "Error durante el escaneo"
                exit 1
            fi
            
            log_info "✓ Biblioteca añadida a colas. Procesando inmediatamente..."
            
            # Procesar colas inmediatamente después de añadir elementos
            if ! acquire_lock "$PROCESS_LOCK" 60 "immediate-process"; then
                log_warning "No se pudo adquirir lock de procesamiento, el cron procesará más tarde"
            else
                trap 'cleanup_locks; exit' EXIT INT TERM
                process_all_queues
                release_lock "$PROCESS_LOCK"
                log_info "✓ Procesamiento inmediato completado."
            fi
            ;;
        "movies"|"--scan-movies")
            if ! check_dependencies; then
                log_error "Dependencias faltantes. Ejecute: $0 set-deps"
                exit 1
            fi
            
            # Adquirir lock de escaneo primero
            if ! acquire_lock "$SCAN_LOCK" 300 "scan-movies"; then
                log_error "No se pudo adquirir lock de escaneo, otro proceso está ejecutándose"
                exit 1
            fi
            
            # Configurar limpieza al salir
            trap 'cleanup_locks; exit' EXIT INT TERM
            
            if [[ "$force_mode" == "true" ]]; then
                log_info "Añadiendo TODAS las películas a cola (modo force)..."
            else
                log_info "Añadiendo películas pendientes a cola (verificando cache)..."
            fi
            
            # Escanear sin locks internos (ya tenemos el lock)
            local scan_success=true
            if ! scan_movies_no_lock "$force_mode"; then
                scan_success=false
            fi
            
            # Liberar lock de escaneo
            release_lock "$SCAN_LOCK"
            
            if [[ "$scan_success" != "true" ]]; then
                log_error "Error durante el escaneo"
                exit 1
            fi
            
            log_info "✓ Películas añadidas a cola. Procesando inmediatamente..."
            
            # Procesar colas inmediatamente después de añadir elementos
            if ! acquire_lock "$PROCESS_LOCK" 60 "immediate-process"; then
                log_warning "No se pudo adquirir lock de procesamiento, el cron procesará más tarde"
            else
                trap 'cleanup_locks; exit' EXIT INT TERM
                process_all_queues
                release_lock "$PROCESS_LOCK"
                log_info "✓ Procesamiento inmediato completado."
            fi
            ;;
        "series"|"--scan-series"|"tvshows"|"--scan-tvshows")
            if ! check_dependencies; then
                log_error "Dependencias faltantes. Ejecute: $0 set-deps"
                exit 1
            fi
            
            # Adquirir lock de escaneo primero
            if ! acquire_lock "$SCAN_LOCK" 300 "scan-series"; then
                log_error "No se pudo adquirir lock de escaneo, otro proceso está ejecutándose"
                exit 1
            fi
            
            # Configurar limpieza al salir
            trap 'cleanup_locks; exit' EXIT INT TERM
            
            if [[ "$force_mode" == "true" ]]; then
                log_info "Añadiendo TODAS las series a cola (modo force)..."
            else
                log_info "Añadiendo series pendientes a cola (verificando cache)..."
            fi
            
            # Escanear sin locks internos (ya tenemos el lock)
            local scan_success=true
            if ! scan_tvshows_no_lock "$force_mode"; then
                scan_success=false
            fi
            
            # Liberar lock de escaneo
            release_lock "$SCAN_LOCK"
            
            if [[ "$scan_success" != "true" ]]; then
                log_error "Error durante el escaneo"
                exit 1
            fi
            
            log_info "✓ Series añadidas a cola. Procesando inmediatamente..."
            
            # Procesar colas inmediatamente después de añadir elementos
            if ! acquire_lock "$PROCESS_LOCK" 60 "immediate-process"; then
                log_warning "No se pudo adquirir lock de procesamiento, el cron procesará más tarde"
            else
                trap 'cleanup_locks; exit' EXIT INT TERM
                process_all_queues
                release_lock "$PROCESS_LOCK"
                log_info "✓ Procesamiento inmediato completado."
            fi
            ;;
        "additem"|"--add-item")
            local media_path="$2"
            local media_type="$3"
            
            if [[ -z "$media_path" ]]; then
                log_error "Debe especificar ruta del archivo"
                log_info "Uso: $0 additem <ruta_archivo> [movie|series]"
                exit 1
            fi
            
            add_to_queue "$media_path" "$media_type"
            ;;
        "setup"|"--setup")
            log_info "Configurando entorno completo..."
            setup_environment
            ;;
        "set-deps"|"--install-deps"|"install-deps")
            log_info "Configurando entorno completo (instalación de dependencias)..."
            setup_environment
            ;;
        "set-cron"|"--setup-cron"|"setup-cron")
            log_info "Configurando entorno completo (configuración de cron)..."
            setup_environment
            ;;
        "test"|"--test")
            log_info "=== VERIFICACIÓN DE CONFIGURACIÓN ==="
            log_info "Directorios:"
            log_info "  - Base: $BASE_DIR"
            log_info "  - Películas: $MOVIES_DIR"
            log_info "  - Series: $SERIES_DIR"
            log_info "  - Overlays: $OVERLAY_DIR"
            
            log_info "Dependencias:"
            if check_dependencies; then
                log_info "  ✓ Todas las dependencias están disponibles"
            else
                log_warning "  ✗ Faltan dependencias (ejecute: $0 set-deps)"
            fi
            
            log_info "Colas:"
            log_info "  - Radarr: $(wc -l < "$RADARR_QUEUE" 2>/dev/null || echo 0) elementos"
            log_info "  - Sonarr: $(wc -l < "$SONARR_QUEUE" 2>/dev/null || echo 0) elementos"
            
            log_info "✓ Verificación completada"
            ;;
        "debug-lang"|"--debug-lang")
            local test_file="$2"
            if [[ -z "$test_file" ]]; then
                test_file="/BibliotecaMultimedia/Peliculas/Blade (1998)/Blade (1998) {imdb-tt0120611} [ES ES-VO][Bluray-1080p][AC3 5.1][ES+EN][8bit][x264][ES+EN].mkv"
            fi
            debug_language_detection "$test_file"
            ;;
        "debug-processing"|"--debug-processing")
            local test_file="$2"
            if [[ -z "$test_file" ]]; then
                test_file="/BibliotecaMultimedia/Peliculas/Blade (1998)/Blade (1998) {imdb-tt0120611} [ES ES-VO][Bluray-1080p][DTS 5.1][ES+EN][8bit][x264][ES+EN]-HDO.mkv"
            fi
            debug_processing "$test_file"
            ;;
        "debug-checksum"|"--debug-checksum")
            local test_file="$2"
            if [[ -z "$test_file" ]]; then
                log_error "Uso: $0 debug-checksum <archivo_video>"
                exit 1
            fi
            if [[ ! -f "$test_file" ]]; then
                log_error "Archivo no encontrado: $test_file"
                exit 1
            fi
            get_video_checksum "$test_file"
            ;;
        "help"|"--help"|"-h")
            show_help
            ;;
        "")
            log_info "Ejecutando procesamiento automático (sin argumentos)..."
            auto_scan_and_process
            ;;
        "processqueue"|"queue"|"--process-queue")
            if ! check_dependencies; then
                log_warning "Dependencias faltantes, configurando entorno..."
                setup_environment || {
                    log_error "Error configurando entorno"
                    exit 1
                }
            fi
            
            # Adquirir lock para procesamiento manual
            if ! acquire_lock "$PROCESS_LOCK" 600 "manual-process"; then
                log_warning "No se pudo adquirir lock de procesamiento, otro proceso está ejecutándose"
                exit 1
            fi
            
            trap 'cleanup_locks; exit' EXIT INT TERM
            process_all_queues
            release_lock "$PROCESS_LOCK"
            ;;
        "debug-events"|"--debug-events")
            debug_event_detection
            ;;
        "boot_process"|"boot-process"|"--boot-process")
            boot_process
            ;;
        *)
            log_error "Modo desconocido: $1"
            log_info "Use '$0 help' para ver los modos disponibles"
            exit 1
            ;;
    esac
    
    log_info "=== $SCRIPT_NAME completado ==="
}

# =============================================================================
# EJECUCIÓN
# =============================================================================

# Manejo de señales
trap 'log_info "Script interrumpido"; exit 1' INT TERM

# Ejecutar función principal
main "$@"

# =============================================================================
# FUNCIÓN DE TEST PARA DEBUGGING
# =============================================================================

debug_language_detection() {
    local video_file="$1"
    
    if [[ ! -f "$video_file" ]]; then
        echo "ERROR: Archivo no encontrado: $video_file"
        return 1
    fi
    
    echo "=== DEBUGGING DETECCIÓN DE IDIOMAS ==="
    echo "Archivo: $video_file"
    echo ""
    
    # MediaInfo
    echo "1. MediaInfo Audio:"
    local audio_langs=$(mediainfo --Output="Audio;%Language/String3%" "$video_file" 2>/dev/null | grep -v "^$" | sort -u)
    echo "   Resultado: '$audio_langs'"
    
    echo "2. MediaInfo Text:"
    local sub_langs=$(mediainfo --Output="Text;%Language/String3%" "$video_file" 2>/dev/null | grep -v "^$" | sort -u)
    echo "   Resultado: '$sub_langs'"
    
    # Procesamiento
    echo "3. Procesando idiomas concatenados:"
    local all_langs="$audio_langs $sub_langs"
    echo "   Combined: '$all_langs'"
    
    local languages=()
    for lang_string in $all_langs; do
        if [[ -n "$lang_string" && "$lang_string" != "Unknown" ]]; then
            echo "   Procesando: '$lang_string' (longitud: ${#lang_string})"
            # Si es un string largo, intentar separar códigos de 3 caracteres
            if [[ ${#lang_string} -gt 3 ]]; then
                local i=0
                while [[ $i -lt ${#lang_string} ]]; do
                    local lang_code="${lang_string:$i:3}"
                    if [[ ${#lang_code} -eq 3 && "$lang_code" != "und" ]]; then
                        languages+=("$lang_code")
                        echo "     Extraído: '$lang_code'"
                    fi
                    ((i+=3))
                done
            else
                # Idioma individual
                if [[ "$lang_string" != "und" ]]; then
                    languages+=("$lang_string")
                    echo "     Individual: '$lang_string'"
                fi
            fi
        fi
    done
    
    echo "4. Idiomas finales: ${languages[*]}"
    
    # FFprobe
    echo "5. FFprobe audio:"
    ffprobe -v quiet -select_streams a -show_entries stream_tags=language -of csv=p=0 "$video_file" 2>/dev/null | head -3
    log_info "=== $SCRIPT_NAME completado ==="
}