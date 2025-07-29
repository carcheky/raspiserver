#!/bin/bash

# =============================================================================
# LANG-FLAGS - Script de Overlays de Idioma para Radarr/Sonarr
# =============================================================================
# Versión: 6.42.0
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
        echo "📝 Comando: docker exec $container_name /flags/lang-flags.bash $*"

        # Ejecutar el script dentro del contenedor con los mismos argumentos
        if docker exec "$container_name" /flags/lang-flags.bash "$@"; then
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

readonly SCRIPT_NAME="Lang-Flags"
readonly SCRIPT_VERSION="6.42.0"
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
readonly PROCESSING_DELAY=10

# Configuración de programación automática
readonly SCHEDULE_DELAY_MINUTES=5  # Tiempo en minutos para programar tareas con 'at' (fácil de cambiar)
readonly SCHEDULE_DELAY_MINUTES_FROM_WEBHOOK=5  # Tiempo en minutos para programar después de webhook (mínimo 5 min)

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
    if ! echo "$$" >"$lock_file" 2>/dev/null; then
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
    local dirs=("$BASE_DIR" "$DATA_DIR" "$QUEUE_DIR" "$TMP_DIR" "$LOG_DIR")

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
        log_error "Dependencias críticas faltantes: ${missing[*]}"
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
    if [[ "$file_path" =~ .*/trailers/.* ]] ||
        [[ "$file_path" =~ .*/extras/.* ]] ||
        [[ "$file_path" =~ .*/behind.the.scenes/.* ]] ||
        [[ "$file_path" =~ .*/deleted.scenes/.* ]] ||
        [[ "$file_path" =~ .*/featurettes/.* ]] ||
        [[ "$file_path" =~ .*/interviews/.* ]] ||
        [[ "$file_path" =~ .*/scenes/.* ]] ||
        [[ "$file_path" =~ .*/shorts/.* ]] ||
        [[ "$file_path" =~ .*/other/.* ]]; then
        return 0 # Es trailer/extra
    fi

    # Verificar nombres de archivo que contengan palabras clave
    local filename=$(basename "$file_path")
    if [[ "$filename" =~ .*[Tt]railer.* ]] ||
        [[ "$filename" =~ .*TRAILER.* ]] ||
        [[ "$filename" =~ .*[Pp]review.* ]] ||
        [[ "$filename" =~ .*[Tt]easer.* ]] ||
        [[ "$filename" =~ .*-trailer\..* ]] ||
        [[ "$filename" =~ .*_trailer\..* ]]; then
        return 0 # Es trailer/extra
    fi

    return 1 # No es trailer/extra
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
                for ((i = 0; i < len; i += 3)); do
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
    done <<<"$nfo_files"

    return 0
}

# =============================================================================
# GESTIÓN DE OVERLAYS
# =============================================================================

normalize_language_code() {
    local lang="$1"

    # Convertir códigos de idioma a códigos de país para banderas
    case "${lang,,}" in
    "es" | "spa" | "spanish" | "español") echo "es" ;;
    "en" | "eng" | "english" | "inglés") echo "gb" ;;
    "fr" | "fre" | "french" | "francés") echo "fr" ;;
    "de" | "ger" | "german" | "alemán") echo "de" ;;
    "it" | "ita" | "italian" | "italiano") echo "it" ;;
    "pt" | "por" | "portuguese" | "portugués") echo "pt" ;;
    "ja" | "jpn" | "japanese" | "japonés") echo "jp" ;;
    "ko" | "kor" | "korean" | "coreano") echo "kr" ;;
    "zh" | "chi" | "chinese" | "chino") echo "cn" ;;
    "ru" | "rus" | "russian" | "ruso") echo "ru" ;;
    *) echo "es" ;; # Por defecto español
    esac
}

find_poster_image() {
    local media_path="$1"
    local media_type="$2" # "movie" o "tvshow"

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
            local result=$(
                IFS=';'
                echo "${found_images[*]}"
            )
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
            local result=$(
                IFS=';'
                echo "${images_to_process[*]}"
            )
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
    log_debug "Dimensiones originales del poster: ${poster_width}x${poster_height}px"

    # REDIMENSIONAR A ALTURA ESTÁNDAR para consistencia visual
    # Altura estándar objetivo (ajustable según necesidades)
    local target_height=700

    # Calcular nuevo ancho manteniendo proporción usando aritmética entera
    # aspect_ratio = width / height * 1000 (para precisión)
    local aspect_ratio_x1000=$((poster_width * 1000 / poster_height))
    local new_width=$((target_height * aspect_ratio_x1000 / 1000))

    # Redimensionar imagen si es necesario
    if [[ "$poster_height" -ne "$target_height" ]]; then
        log_info "📏 Redimensionando ${poster_width}x${poster_height} → ${new_width}x${target_height}: $(basename "$poster_file")"

        if ! convert "$poster_file" -resize "${new_width}x${target_height}!" "$poster_file" 2>/dev/null; then
            log_warning "Error redimensionando imagen: $poster_file"
            return 1
        fi

        # Actualizar dimensiones para cálculos posteriores
        poster_width="$new_width"
        poster_height="$target_height"
        log_debug "Imagen redimensionada exitosamente"
    else
        log_debug "Imagen ya tiene la altura objetivo: ${target_height}px"
    fi

    # Tamaño proporcional de bandera (8% de la altura estándar)
    # Esto asegura que las banderas se vean del mismo tamaño visual en todas las imágenes
    local flag_height=$((target_height * 8 / 100))
    local flag_width=$((flag_height * 4 / 3)) # Mantener proporción 4:3

    # Procesar idiomas uno por uno
    local applied_overlays=0

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

        # Paso 3: Aplicar transparencia y posicionar bandera abajo al centro
        # Aplicar 70% de transparencia a la bandera
        if ! convert "$temp_flag" -alpha set -channel A -evaluate multiply 0.7 +channel "$temp_flag" 2>/dev/null; then
            log_warning "Error aplicando transparencia a bandera"
            rm -f "$temp_flag" "$temp_overlay"
            continue
        fi

        # Calcular posición: banderas alineadas horizontalmente en la parte inferior central
        # Calcular ancho total necesario para todas las banderas
        local total_flags=${#languages[@]}
        local total_width=$((total_flags * flag_width + (total_flags - 1) * 5)) # 5px separación entre banderas
        local start_x=$(((poster_width - total_width) / 2))

        # Posición X para esta bandera específica
        local x_offset=$((start_x + applied_overlays * (flag_width + 5)))
        # Posición Y fija en la parte inferior
        local y_offset=$((poster_height - flag_height - 10))

        if ! convert "$temp_overlay" "$temp_flag" -colorspace sRGB -geometry "+${x_offset}+${y_offset}" -composite "$temp_overlay" 2>/dev/null; then
            log_warning "Error posicionando bandera"
            rm -f "$temp_flag" "$temp_overlay"
            continue
        fi

        # Paso 4: Aplicar overlay al poster (preservar color)
        if convert "$poster_file" "$temp_overlay" -colorspace sRGB -flatten "$poster_file" 2>/dev/null; then
            log_info "✓ Overlay aplicado: $lang → $(basename "$poster_file")"
            ((applied_overlays++))
            # Las banderas se alinean horizontalmente en la parte inferior central
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
    local video_file="$2" # Recibe la ruta completa del video

    if [[ ! -f "$image_file" || -z "$video_file" ]]; then
        return 1
    fi

    # SISTEMA SIMPLIFICADO: Verificar UserComment con nombre del archivo (sin ruta)
    local user_comment=$(exiftool -f -s3 -"UserComment" "$image_file" 2>/dev/null)
    local video_filename=$(basename "$video_file")
    local expected_comment="LangFlags:$video_filename"

    # LÓGICA CORREGIDA PARA SERIES:
    # - Sin EXIF o EXIF vacío: Imagen procesada por Jellyfin, lista para overlay
    # - Con EXIF "LangFlags:" (cualquier episodio): Imagen YA procesada, NO procesar
    # - Con otro EXIF: Estado intermedio, no procesada
    
    if [[ -z "$user_comment" ]] || [[ "$user_comment" == "-" ]] || [[ "${user_comment// /}" == "" ]]; then
        return 1  # Sin EXIF = Jellyfin procesó, pero lang-flags no
    elif [[ "$user_comment" == LangFlags:* ]]; then
        return 0  # CUALQUIER EXIF LangFlags = YA PROCESADA, no añadir a cola
    else
        return 1  # EXIF incorrecto = necesita procesamiento
    fi
}

update_image_exif_filename() {
    local image_file="$1"
    local video_file="$2" # Recibe la ruta completa del video

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
        log_debug "Imágenes no encontradas (Jellyfin no ha procesado): $media_path"
        return 0  # Necesita procesamiento cuando esté listo
    fi
    # Verificar cache en cada imagen usando SISTEMA UNIFICADO
    local poster_files
    if [[ "$media_type" == "movie" ]]; then
        IFS=';' read -ra poster_files <<<"$poster_result"
    else
        IFS=';' read -ra poster_files <<<"$poster_result"
    fi

    # Obtener identificador actual del archivo de video (ruta completa)
    local current_video_path
    current_video_path=$(get_video_identifier_cached "$media_path" 2>/dev/null || echo "")

    for poster_file in "${poster_files[@]}"; do
        # MÉTODO SIMPLIFICADO: Solo verificar EXIF
        if is_image_processed "$poster_file" "$current_video_path"; then
            log_debug "Cache HIT: $(basename "$poster_file") ruta coincide ($current_video_path)"
            continue # Esta imagen está actualizada
        else
            log_debug "Cache MISS: $(basename "$poster_file") ruta diferente o no procesada"
            return 0 # Necesita procesamiento
        fi
    done

    # Si llegamos aquí, todas las imágenes tienen el identificador correcto
    log_debug "Cache HIT: Todas las imágenes actualizadas para: $media_path"
    return 1 # No necesita procesamiento
}

# =============================================================================
# FUNCIONES DE VERIFICACIÓN DE PROCESAMIENTO
# =============================================================================

# Función para limpiar caché de un elemento específico (webhook events)
remove_from_cache() {
    local media_path="$1"
    local media_type="$2"

    log_debug "Limpiando caché EXIF para: $media_path (tipo: $media_type)"

    # Obtener todas las imágenes asociadas al archivo
    local poster_images_result
    if poster_images_result=$(find_poster_image "$media_path" "$media_type" 2>/dev/null); then
        # Convertir a array
        local poster_images=()
        IFS=';' read -ra poster_images <<<"$poster_images_result"

        # Limpiar caché EXIF para cada imagen
        local cleaned_count=0

        for image in "${poster_images[@]}"; do
            if [[ -f "$image" ]]; then
                local image_basename=$(basename "$image")

                # Limpiar EXIF
                if command -v exiftool >/dev/null 2>&1; then
                    exiftool -overwrite_original -UserComment="" "$image" 2>/dev/null || true
                    log_debug "EXIF limpiado para: $image_basename"
                    ((cleaned_count++))
                fi
            fi
        done

        if [[ "$cleaned_count" -gt 0 ]]; then
            log_info "🧹 Caché EXIF limpiada para: $(basename "$media_path") ($cleaned_count imagen(es))"
        else
            log_debug "No se encontraron imágenes para limpiar caché: $(basename "$media_path")"
        fi
    else
        log_debug "No se encontraron imágenes asociadas para limpiar caché: $media_path"
    fi

    return 0
}

delete_images_for_webhook() {
    local media_path="$1"
    local media_type="$2"

    log_debug "Borrando imágenes para webhook: $media_path (tipo: $media_type)"

    # Obtener todas las imágenes asociadas al archivo
    local poster_images_result
    if poster_images_result=$(find_poster_image "$media_path" "$media_type" 2>/dev/null); then
        # Convertir a array
        local poster_images=()
        IFS=';' read -ra poster_images <<<"$poster_images_result"

        # Borrar cada imagen encontrada
        local deleted_count=0

        for image in "${poster_images[@]}"; do
            if [[ -f "$image" ]]; then
                local image_basename=$(basename "$image")
                
                # Borrar el archivo de imagen
                if rm -f "$image" 2>/dev/null; then
                    log_debug "Imagen borrada: $image_basename"
                    ((deleted_count++))
                else
                    log_warning "No se pudo borrar imagen: $image_basename"
                fi
            fi
        done

        if [[ "$deleted_count" -gt 0 ]]; then
            log_info "🗑️ Imágenes borradas para webhook: $(basename "$media_path") ($deleted_count imagen(es))"
        else
            log_debug "No se encontraron imágenes para borrar: $(basename "$media_path")"
        fi
    else
        log_debug "No se encontraron imágenes asociadas para borrar: $media_path"
    fi

    return 0
}

# =============================================================================
# FUNCIONES DE PROCESAMIENTO POR TIPO
# =============================================================================

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
    cat >"$init_script" <<'EOF'
#!/bin/bash
# Auto-setup para Lang-Flags - Ejecutado al inicio del contenedor
# Generado automáticamente por lang-flags.bash

if [[ -f "/flags/lang-flags.bash" ]]; then
    bash /flags/lang-flags.bash setup
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

stop_lang_flags_processes() {
    log_info "🛑 Verificando procesos lang-flags en curso..."
    
    # Buscar procesos con lang-flags.bash (excluyendo el proceso actual)
    local current_pid=$$
    local processes=$(pgrep -f "lang-flags.bash" 2>/dev/null || true)
    
    # Filtrar el proceso actual
    if [[ -n "$processes" ]]; then
        local filtered_processes=""
        for pid in $processes; do
            if [[ "$pid" != "$current_pid" ]]; then
                filtered_processes="$filtered_processes $pid"
            fi
        done
        processes=$(echo "$filtered_processes" | xargs)
    fi
    
    if [[ -n "$processes" ]]; then
        log_info "🔍 Encontrados procesos lang-flags en curso: $processes"
        
        # Intentar terminar graciosamente primero
        for pid in $processes; do
            if [[ -n "$pid" ]] && kill -0 "$pid" 2>/dev/null; then
                log_info "🛑 Terminando proceso graciosamente: $pid"
                kill -TERM "$pid" 2>/dev/null || true
            fi
        done
        
        # Esperar un poco para terminación gracil
        log_info "⏱️ Esperando terminación gracil..."
        sleep 3
        
        # Verificar si siguen activos y forzar terminación
        local remaining=$(pgrep -f "lang-flags.bash" 2>/dev/null || true)
        if [[ -n "$remaining" ]]; then
            # Filtrar el proceso actual nuevamente
            local filtered_remaining=""
            for pid in $remaining; do
                if [[ "$pid" != "$current_pid" ]]; then
                    filtered_remaining="$filtered_remaining $pid"
                fi
            done
            remaining=$(echo "$filtered_remaining" | xargs)
        fi
        
        if [[ -n "$remaining" ]]; then
            log_warning "⚠️ Forzando terminación de procesos restantes: $remaining"
            for pid in $remaining; do
                if [[ -n "$pid" ]] && kill -0 "$pid" 2>/dev/null; then
                    log_warning "💀 Terminando proceso forzosamente: $pid"
                    kill -KILL "$pid" 2>/dev/null || true
                fi
            done
        fi
        
        # Verificación final
        sleep 1
        local final_check=$(pgrep -f "lang-flags.bash" 2>/dev/null || true)
        if [[ -n "$final_check" ]]; then
            # Filtrar el proceso actual nuevamente
            local filtered_final=""
            for pid in $final_check; do
                if [[ "$pid" != "$current_pid" ]]; then
                    filtered_final="$filtered_final $pid"
                fi
            done
            final_check=$(echo "$filtered_final" | xargs)
        fi
        
        if [[ -z "$final_check" ]]; then
            log_info "✅ Todos los procesos lang-flags han sido detenidos"
        else
            log_warning "⚠️ Algunos procesos podrían seguir activos: $final_check"
        fi
    else
        log_info "✅ No se encontraron procesos lang-flags en curso"
    fi
    
    # Limpiar archivos lock si existen
    if [[ -f "$SCAN_LOCK" ]]; then
        log_info "🔒 Eliminando lock de escaneo: $SCAN_LOCK"
        rm -f "$SCAN_LOCK"
    fi
    
    if [[ -f "$PROCESS_LOCK" ]]; then
        log_info "🔒 Eliminando lock de procesamiento: $PROCESS_LOCK"
        rm -f "$PROCESS_LOCK"
    fi
}

start_atd_service() {
    log_info "🚀 Iniciando servicio atd..."
    
    # Verificar si at está instalado
    if ! command -v at >/dev/null 2>&1; then
        log_warning "⚠️ Comando 'at' no encontrado, saltando inicio de atd"
        return 1
    fi
    
    # Configurar permisos de at para usuarios críticos (root, abc, 1000)
    local current_user=$(whoami)
    log_info "🔑 Configurando permisos de 'at' para usuario: $current_user"
    
    # Lista de usuarios que deben tener acceso a at
    local required_users=("root" "abc" "1000" "$current_user")
    
    # Asegurar que los usuarios críticos tienen permisos para usar at
    if [[ -f "/etc/at.allow" ]]; then
        # Si existe at.allow, añadir usuarios que falten
        for user in "${required_users[@]}"; do
            if ! grep -q "^${user}$" /etc/at.allow 2>/dev/null; then
                echo "$user" >> /etc/at.allow 2>/dev/null || log_warning "⚠️ No se pudo añadir $user a /etc/at.allow"
                log_info "✅ Usuario $user añadido a /etc/at.allow"
            fi
        done
    else
        # Si no existe at.allow, crearlo con los usuarios críticos
        {
            echo "root"
            echo "abc"
            echo "1000"
            echo "$current_user"
        } > /etc/at.allow 2>/dev/null || log_warning "⚠️ No se pudo crear /etc/at.allow"
        log_info "✅ Creado /etc/at.allow con usuarios críticos"
    fi
    
    # Remover usuarios críticos de at.deny si existen
    if [[ -f "/etc/at.deny" ]]; then
        for user in "${required_users[@]}"; do
            if grep -q "^${user}$" /etc/at.deny 2>/dev/null; then
                sed -i "/^${user}$/d" /etc/at.deny 2>/dev/null || log_warning "⚠️ No se pudo modificar /etc/at.deny para $user"
                log_info "✅ Usuario $user removido de /etc/at.deny"
            fi
        done
    fi
    
    # Verificar si atd ya está corriendo
    if pgrep -x "atd" >/dev/null 2>&1; then
        log_info "✅ Servicio atd ya está corriendo"
    else
        # Intentar iniciar atd
        if atd >/dev/null 2>&1; then
            log_info "✅ Servicio atd iniciado exitosamente"
            
            # Verificar que efectivamente está corriendo
            if pgrep -x "atd" >/dev/null 2>&1; then
                log_info "✅ Servicio atd confirmado en ejecución"
            else
                log_error "❌ Servicio atd no se pudo iniciar correctamente"
                return 1
            fi
        else
            log_error "❌ Error al intentar iniciar servicio atd"
            return 1
        fi
    fi
    
    # Test de permisos de at
    log_info "🧪 Verificando permisos de 'at'..."
    local test_output
    test_output=$(echo "echo 'test'" | at "now + 1 minute" 2>&1)
    local test_exit_code=$?
    
    if [[ $test_exit_code -eq 0 ]]; then
        log_info "✅ Permisos de 'at' verificados correctamente"
        # Limpiar la tarea de test
        local job_id=$(echo "$test_output" | grep -o "job [0-9]*" | grep -o "[0-9]*")
        if [[ -n "$job_id" ]]; then
            atrm "$job_id" 2>/dev/null
            log_debug "🧹 Tarea de test $job_id eliminada"
        fi
        return 0
    else
        log_error "❌ Test de permisos de 'at' falló: $test_output"
        return 1
    fi
}

setup_queue_permissions() {
    log_info "🔐 Configurando permisos de archivos de cola..."
    
    # Obtener usuario actual
    local current_user=$(whoami)
    
    # Lista de usuarios que deben tener acceso a los archivos de cola
    local required_users=("root" "abc" "1000" "$current_user")
    
    # Crear directorio de cola si no existe
    mkdir -p "$QUEUE_DIR"
    
    # Configurar permisos del directorio de cola
    # Grupo: staff (común en Alpine/Docker) o el grupo del usuario actual
    local target_group="staff"
    if ! getent group "$target_group" >/dev/null 2>&1; then
        target_group=$(id -gn "$current_user")
    fi
    
    # Configurar directorio con permisos de grupo
    chmod 775 "$QUEUE_DIR" 2>/dev/null || log_warning "⚠️ No se pudo configurar permisos del directorio de cola"
    chgrp "$target_group" "$QUEUE_DIR" 2>/dev/null || log_warning "⚠️ No se pudo cambiar grupo del directorio de cola"
    log_info "✅ Directorio de cola configurado con permisos compartidos"
    
    # Configurar permisos de archivos de cola existentes
    local queue_files=("$RADARR_QUEUE" "$SONARR_QUEUE" "$QUEUE_DIR/generic.queue")
    
    for queue_file in "${queue_files[@]}"; do
        if [[ -f "$queue_file" ]]; then
            # Configurar permisos de archivo (rw-rw-r--)
            chmod 664 "$queue_file" 2>/dev/null || log_warning "⚠️ No se pudo configurar permisos de $queue_file"
            chgrp "$target_group" "$queue_file" 2>/dev/null || log_warning "⚠️ No se pudo cambiar grupo de $queue_file"
            log_info "✅ Permisos configurados para $(basename "$queue_file")"
        fi
    done
    
    # Configurar umask para que archivos futuros tengan permisos correctos
    # umask 002 permite rw-rw-r-- por defecto
    umask 002
    
    log_info "✅ Permisos de archivos de cola configurados correctamente"
    return 0
}

setup_dependencies() {
    log_info "🔧 Iniciando instalación de dependencias para Lang-Flags..."

    # Detener procesos lang-flags en curso antes de continuar
    stop_lang_flags_processes

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
    local packages_apk="exiftool imagemagick librsvg rsvg-convert ffmpeg mediainfo mkvtoolnix jq at"
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
        
        # Iniciar servicio atd si está disponible
        start_atd_service
        
        # Configurar permisos de archivos de cola
        setup_queue_permissions
        
        # Programar escaneo inicial apropiado según el contenedor
        local container_type=$(detect_container_type)
        case "$container_type" in
        "radarr")
            log_info "🎬 Programando escaneo inicial de películas..."
            schedule_process "movies"
            ;;
        "sonarr")
            log_info "📺 Programando escaneo inicial de series..."
            schedule_process "series"
            ;;
        *)
            log_info "🎭 Programando escaneo inicial completo..."
            schedule_process "all"
            ;;
        esac
        
        log_info "🚀 Lang-Flags está listo para usar"
        return 0
    else
        log_error "❌ Algunas dependencias siguen faltando después de la instalación"
        return 1
    fi
}

# =============================================================================
# FUNCIONES AUXILIARES PARA GESTIÓN DE PROGRAMACIONES AT
# =============================================================================

get_langflags_job_count() {
    local job_count=0
    while IFS= read -r job_line; do
        if [[ -n "$job_line" ]]; then
            local job_id=$(echo "$job_line" | awk '{print $1}')
            if at -c "$job_id" 2>/dev/null | grep -q "lang-flags.bash"; then
                ((job_count++))
            fi
        fi
    done < <(atq 2>/dev/null)
    echo "$job_count"
}

cancel_all_langflags_jobs() {
    local cancelled_count=0
    while IFS= read -r job_line; do
        if [[ -n "$job_line" ]]; then
            local job_id=$(echo "$job_line" | awk '{print $1}')
            if at -c "$job_id" 2>/dev/null | grep -q "lang-flags.bash"; then
                if atrm "$job_id" 2>/dev/null; then
                    log_debug "✓ Cancelada tarea lang-flags: $job_id"
                    ((cancelled_count++))
                else
                    log_warning "⚠️ No se pudo cancelar tarea: $job_id"
                fi
            fi
        fi
    done < <(atq 2>/dev/null)
    echo "$cancelled_count"
}

# =============================================================================
# SISTEMA DE PROGRAMACIÓN AUTOMÁTICA CON 'at' - VERSIÓN ROBUSTA
# =============================================================================

schedule_process() {
    local command="$1"
    local custom_delay="${2:-$SCHEDULE_DELAY_MINUTES}"  # Usar delay personalizado o el por defecto
    
    # Verificar si el comando 'at' está disponible
    if ! command -v at >/dev/null 2>&1; then
        log_warning "⚠️ Comando 'at' no disponible - programación automática deshabilitada"
        return 1
    fi
    
    # Verificar si el servicio atd está ejecutándose
    if ! pgrep -x "atd" >/dev/null 2>&1; then
        log_warning "⚠️ Servicio atd no está ejecutándose - programación automática deshabilitada"
        return 1
    fi
    
    # PASO 1: CANCELAR TODAS LAS TAREAS LANG-FLAGS EXISTENTES (OBLIGATORIO)
    log_info "🗑️ Eliminando TODAS las programaciones lang-flags existentes..."
    
    # Usar función auxiliar para cancelar todas las tareas
    local cancelled_count=$(cancel_all_langflags_jobs)
    
    if [[ $cancelled_count -gt 0 ]]; then
        log_info "🗑️ Canceladas $cancelled_count tarea(s) lang-flags existente(s)"
    else
        log_debug "✓ No se encontraron tareas lang-flags para cancelar"
    fi
    
    # PASO 2: VERIFICACIÓN FINAL - ASEGURAR QUE NO QUEDAN TAREAS
    local final_job_count=$(get_langflags_job_count)
    
    if [[ "$final_job_count" -gt 0 ]]; then
        log_error "❌ ERROR CRÍTICO: Todavía quedan $final_job_count tareas lang-flags después de la limpieza"
        log_error "❌ NO se programará nueva tarea para evitar múltiples programaciones"
        return 1
    fi
    
    log_info "✅ Confirmado: 0 tareas lang-flags existentes, procediendo con programación"
    
    # PASO 3: PROGRAMAR NUEVA TAREA ÚNICA
    log_info "⏰ Programando procesamiento automático ÚNICO en ${custom_delay} minuto(s)..."
    local schedule_time="now + ${custom_delay} minutes"
    local script_path="/flags/lang-flags.bash"
    
    # Crear comando completo con identificador único
    local full_command="cd /flags && bash $script_path $command"
    
    log_debug "DEBUG: Comando a programar: $full_command"
    log_debug "DEBUG: Tiempo programado: $schedule_time"
    
    # Programar tarea - capturar stderr para debug
    local at_output
    local at_exit_code
    at_output=$(echo "$full_command" | at "$schedule_time" 2>&1)
    at_exit_code=$?
    
    log_debug "DEBUG: Salida de at: $at_output"
    log_debug "DEBUG: Exit code de at: $at_exit_code"
    
    if [[ $at_exit_code -eq 0 ]]; then
        log_debug "DEBUG: Comando at ejecutado exitosamente"
        # PASO 4: VERIFICACIÓN POST-PROGRAMACIÓN
        local post_job_count=$(get_langflags_job_count)
        
        if [[ "$post_job_count" -eq 1 ]]; then
            log_info "✅ Programación exitosa: 1 tarea lang-flags activa (correcto)"
            return 0
        else
            log_error "❌ ERROR: Después de programar hay $post_job_count tareas lang-flags activas"
            log_error "❌ Se esperaba exactamente 1 tarea, cancelando todas para evitar duplicados"
            
            # Cancelar todas las tareas para evitar múltiples programaciones
            local cleanup_count=$(cancel_all_langflags_jobs)
            log_warning "⚠️ Se cancelaron $cleanup_count tareas por seguridad"
            
            return 1
        fi
    else
        log_error "❌ Error programando procesamiento automático (exit code: $at_exit_code)"
        log_error "❌ Salida de at: $at_output"
        log_debug "DEBUG: Comando fallido: echo '$full_command' | at '$schedule_time'"
        return 1
    fi
}

is_queue_empty() {
    local container_type=$(detect_container_type)
    
    # Verificar colas según el contenedor
    case "$container_type" in
    "radarr")
        # Solo verificar cola de Radarr
        if [[ -f "$RADARR_QUEUE" ]] && [[ -s "$RADARR_QUEUE" ]]; then
            return 1  # Cola no vacía
        fi
        ;;
    "sonarr")
        # Solo verificar cola de Sonarr
        if [[ -f "$SONARR_QUEUE" ]] && [[ -s "$SONARR_QUEUE" ]]; then
            return 1  # Cola no vacía
        fi
        ;;
    *)
        # Contenedor desconocido - verificar ambas colas
        if [[ -f "$RADARR_QUEUE" ]] && [[ -s "$RADARR_QUEUE" ]]; then
            return 1  # Cola no vacía
        fi
        if [[ -f "$SONARR_QUEUE" ]] && [[ -s "$SONARR_QUEUE" ]]; then
            return 1  # Cola no vacía
        fi
        # Verificar cola genérica también
        if [[ -f "$QUEUE_DIR/generic.queue" ]] && [[ -s "$QUEUE_DIR/generic.queue" ]]; then
            return 1  # Cola no vacía
        fi
        ;;
    esac
    
    return 0  # Cola vacía
}

# =============================================================================
# SISTEMA DE GESTIÓN DE COLAS
# =============================================================================

add_to_queue() {
    local media_path="$1"
    local media_type="$2" # "movie" o "tvshow"

    # Determinar archivo de cola según el TIPO DE MEDIA, no el contenedor
    local queue_file=""
    case "$media_type" in
    "movie")
        queue_file="$RADARR_QUEUE"
        ;;
    "tvshow")
        queue_file="$SONARR_QUEUE"
        ;;
    *)
        # Tipo desconocido, usar cola genérica
        queue_file="$QUEUE_DIR/generic.queue"
        ;;
    esac

    # Crear directorio de cola si no existe
    mkdir -p "$QUEUE_DIR"

    # Formato: timestamp|media_type|media_path|status
    local timestamp=$(date +%s)
    local queue_entry="${timestamp}|${media_type}|${media_path}|ready"

    # Verificar si el item ya está en la cola (verificación exacta por ruta completa)
    if [[ -f "$queue_file" ]] && grep -Fxq "${media_type}|${media_path}" <(cut -d'|' -f2,3 "$queue_file") 2>/dev/null; then
        log_debug "Item ya en cola: $media_path"
        return 1  # Retorna 1 si ya existe
    fi

    # Añadir a la cola
    echo "$queue_entry" >>"$queue_file"
    
    # Configurar permisos del archivo de cola para acceso multiusuario
    chmod 664 "$queue_file" 2>/dev/null || log_debug "⚠️ No se pudo configurar permisos de $(basename "$queue_file")"
    
    # Intentar cambiar grupo si es posible
    local target_group="staff"
    if ! getent group "$target_group" >/dev/null 2>&1; then
        target_group=$(id -gn)
    fi
    chgrp "$target_group" "$queue_file" 2>/dev/null || log_debug "⚠️ No se pudo cambiar grupo de $(basename "$queue_file")"
    
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
        
        # Después de procesar todas las colas, verificar si hay más elementos
        if ! is_queue_empty; then
            log_info "🔄 Cola no vacía - reprogramando siguiente procesamiento"
            schedule_process "process"
        else
            log_info "✅ Cola vacía - no se requiere reprogramación"
        fi
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

    # Después de procesar, verificar si hay más elementos en cola
    if ! is_queue_empty; then
        log_info "🔄 Cola no vacía - reprogramando siguiente procesamiento"
        schedule_process "process"
    else
        log_info "✅ Cola vacía - no se requiere reprogramación"
    fi
}

process_single_queue() {
    local queue_file="$1"

    if [[ ! -f "$queue_file" ]]; then
        return 0
    fi

    # Contar items en cola
    local queue_count=$(wc -l <"$queue_file" 2>/dev/null || echo "0")
    if [[ "$queue_count" -eq 0 ]]; then
        log_info "Cola vacía: $(basename "$queue_file")"
        return 0
    fi

    log_info "📋 Procesando cola: $(basename "$queue_file") ($queue_count items)"

    local processed_count=0
    local failed_count=0
    local current_line_number=1

    # PROCESAMIENTO DIRECTO SIN ARCHIVOS TEMPORALES
    # Procesar línea por línea, solo eliminar si el procesamiento fue exitoso
    while [[ -s "$queue_file" ]]; do
        # Leer la línea actual (línea número $current_line_number)
        local line=$(sed -n "${current_line_number}p" "$queue_file")
        
        # Si no hay más líneas, terminar
        if [[ -z "$line" ]]; then
            break
        fi
        
        # Parsear línea
        IFS='|' read -r timestamp media_type media_path status <<< "$line"
        
        # CHECK SIMPLE: Si no es ready, saltar
        if [[ "$status" != "ready" ]]; then
            ((current_line_number++))
            continue
        fi
        
        # Validar formato de entrada
        if [[ -z "$media_type" || -z "$media_path" ]]; then
            log_warning "Entrada de cola inválida: $line"
            # Eliminar línea inválida
            sed -i "${current_line_number}d" "$queue_file"
            ((failed_count++))
            continue
        fi

        log_info "🎬 Procesando desde cola: $(basename "$media_path") (tipo: $media_type)"

        # LÓGICA CRÍTICA: Solo eliminar de la cola SI el procesamiento fue exitoso
        if process_media_item "$media_path" "$media_type"; then
            log_debug "✓ Item procesado exitosamente: $media_path"
            # ÉXITO: Eliminar línea de la cola
            sed -i "${current_line_number}d" "$queue_file"
            ((processed_count++))
            # NO incrementar current_line_number porque eliminamos la línea actual
        else
            log_warning "❌ Item falló procesamiento (permanece en cola): $(basename "$media_path")"
            ((failed_count++))
            # FALLO: Dejar item en cola y avanzar a la siguiente línea
            ((current_line_number++))
        fi
    done

    log_info "✅ Procesamiento completado: $processed_count procesados, $failed_count permanecen en cola"
    return 0
}

scan_and_queue() {
    local media_dir="$1"
    local media_type="$2" # "movie" o "tvshow"
    local force_process="$3"

    log_info "🔍 Escaneando directorio para añadir a cola: $media_dir (tipo: $media_type)"

    if [[ ! -d "$media_dir" ]]; then
        log_warning "Directorio no encontrado: $media_dir"
        return 1
    fi

    # Si está en modo force, solo limpiar EXIF (durante procesamiento)
    if [[ "$force_process" == "true" ]]; then
        log_info "🧹 Modo force: EXIF se limpiará durante el procesamiento"
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
        if ((scanned_count % 10 == 0)); then
            local current_queue_count=$(get_specific_queue_count "$media_type")
            log_info "📊 Progreso: $scanned_count archivos escaneados, $queued_count añadidos, total en cola: $current_queue_count"
        fi

        # Filtrar trailers, extras y otros archivos secundarios que no necesitan overlays
        if [[ "$media_file" =~ \.(trailer|extra|behind\.the\.scene|other|featurette|deleted\.scene|making\.of|teaser)\. ]] || 
           [[ "$(basename "$media_file")" =~ ^(trailer|extra|behind\.the\.scene|other|featurette|deleted\.scene|making\.of|teaser)[\.\-] ]] ||
           [[ "$media_file" =~ /trailers/ ]]; then
            log_debug "Saltando archivo secundario: $(basename "$media_file")"
            continue
        fi

        if [[ "$media_file" =~ \.(mkv|mp4|avi|m4v)$ ]]; then

            # Con force, añadir todo a la cola sin verificar cache
            if [[ "$force_process" == "true" ]]; then
                if add_to_queue "$media_file" "$media_type"; then
                    ((queued_count++))
                    log_debug "Force: añadido a cola: $(basename "$media_file")"
                else
                    log_debug "Force: ya en cola: $(basename "$media_file")"
                fi
            else
                # Sin force, verificar cache antes de añadir a cola
                if needs_processing "$media_file" "$media_type" "false"; then
                    if add_to_queue "$media_file" "$media_type"; then
                        ((queued_count++))
                        log_debug "Cache MISS: añadido a cola: $(basename "$media_file")"
                    else
                        log_debug "Cache MISS: ya en cola: $(basename "$media_file")"
                    fi
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
    local event_type=""

    # Variables de Radarr
    if [[ -n "$radarr_eventtype" && -n "$radarr_moviefile_path" ]]; then
        event_file="$radarr_moviefile_path"
        media_type="movie"
        event_type="$radarr_eventtype"
        log_info "📡 Evento Radarr detectado: $radarr_eventtype"
        log_debug "Archivo de evento: $event_file"

    # Variables de Sonarr
    elif [[ -n "$sonarr_eventtype" && -n "$sonarr_episodefile_path" ]]; then
        event_file="$sonarr_episodefile_path"
        media_type="tvshow"
        event_type="$sonarr_eventtype"
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

    # Añadir siempre a cola (sin verificar cache para webhooks)
    # La lógica EXIF inteligente en process_media_item() determinará si procesar o esperar
    add_to_queue "$event_file" "$media_type"
    log_info "✓ Evento añadido a cola para procesamiento"

    # Borrar imágenes INMEDIATAMENTE después de añadir a cola
    # En eventos de actualización, reemplazo O downloads que sobreescriben archivos existentes
    local should_delete_images=false
    
    # Verificar tipo de evento
    case "${event_type,,}" in
        *upgrade*|*update*|*replace*)
            should_delete_images=true
            log_info "📝 Evento de actualización detectado: $event_type - borrando imágenes existentes"
            ;;
        *download*)
            # Para eventos Download, verificar si es upgrade usando la variable específica de Radarr/Sonarr
            if [[ "${radarr_isupgrade,,}" == "true" ]] || [[ "${sonarr_isupgrade,,}" == "true" ]]; then
                should_delete_images=true
                log_info "📝 Evento Download con upgrade detectado (isupgrade=true) - borrando imágenes existentes"
            else
                log_debug "Evento Download sin upgrade (isupgrade=false) - manteniendo imágenes existentes"
            fi
            ;;
        *)
            log_debug "Evento de nuevo contenido: $event_type - manteniendo imágenes existentes"
            ;;
    esac
    
    # Ejecutar borrado si es necesario
    if [[ "$should_delete_images" == "true" ]]; then
        delete_images_for_webhook "$event_file" "$media_type"
        log_debug "✅ Imágenes borradas inmediatamente después de añadir a cola"
    fi

    # Usar delay específico para webhooks (mínimo 5 minutos)
    local schedule_delay="$SCHEDULE_DELAY_MINUTES_FROM_WEBHOOK"
    
    # Incrementar delay para eventos de actualización/upgrade para dar aún más tiempo
    # a Jellyfin para descargar/actualizar metadata e imágenes
    case "${event_type,,}" in
        *upgrade*|*update*|*replace*)
            schedule_delay=$((SCHEDULE_DELAY_MINUTES_FROM_WEBHOOK * 2))
            log_info "📝 Evento de actualización: delay extendido a ${schedule_delay} minutos"
            ;;
        *)
            log_debug "Evento estándar: delay webhook de ${schedule_delay} minutos"
            ;;
    esac

    # Programar procesamiento automático con delay apropiado
    log_debug "DEBUG WEBHOOK: Antes de llamar schedule_process (delay: ${schedule_delay}m)"
    if schedule_process "process" "$schedule_delay"; then
        log_debug "DEBUG WEBHOOK: schedule_process exitoso"
    else
        log_error "DEBUG WEBHOOK: schedule_process FALLÓ"
    fi
    log_debug "DEBUG WEBHOOK: Después de llamar schedule_process"

    return 0
}

# =============================================================================
# PROCESAMIENTO PRINCIPAL
# =============================================================================

process_media_item() {
    local media_path="$1"
    local media_type="$2" # "movie" o "tvshow"

    log_info "Procesando $media_type: $media_path"

    # 1. Verificar que no sea trailer o contenido extra
    if is_trailer_or_extra "$media_path"; then
        log_debug "Omitiendo trailer/extra: $(basename "$media_path")"
        return 0 # Retornar éxito pero no procesar
    fi

    # 2. Verificar que exista el archivo de video
    if [[ ! -f "$media_path" ]]; then
        log_warning "Archivo de video no encontrado, eliminando de cola: $media_path"
        return 0  # Retornar éxito para que se elimine de la cola
    fi

    # 3. Encontrar imágenes correspondientes
    local poster_images_result
    if ! poster_images_result=$(find_poster_image "$media_path" "$media_type"); then
        log_info "⏳ Jellyfin aún no ha procesado las imágenes para: $(basename "$media_path")"
        return 1  # No listo - Jellyfin no ha creado las imágenes aún
    fi

    # 4. Convertir resultado a array (separado por ;)
    local poster_images=()
    IFS=';' read -ra poster_images <<<"$poster_images_result"

    # 5. Verificar que al menos una imagen existe
    local valid_images=()
    for image in "${poster_images[@]}"; do
        if [[ -f "$image" ]]; then
            valid_images+=("$image")
        else
            log_debug "Imagen poster no encontrada (saltando): $image"
        fi
    done

    if [[ ${#valid_images[@]} -eq 0 ]]; then
        log_info "⏳ Jellyfin aún no ha procesado las imágenes para: $(basename "$media_path")"
        return 1  # No listo - Jellyfin no ha creado las imágenes aún
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
    read -ra languages <<<"$detected_langs"

    if [[ ${#languages[@]} -eq 0 ]]; then
        log_warning "No se detectaron idiomas para procesar: $media_path"
        return 1
    fi

    log_info "Aplicando overlays para idiomas: ${languages[*]} en ${#valid_images[@]} imagen(es) (${media_type})"

    # VERIFICACIÓN: Comprobar EXIF de imágenes para debug
    log_debug "🔍 Verificando estado de imágenes..."
    
    local video_filename=$(basename "$media_path")

    for poster_image in "${valid_images[@]}"; do
        local current_exif=$(exiftool -f -s3 -"UserComment" "$poster_image" 2>/dev/null)
        local expected_exif="LangFlags:$video_filename"
        
        log_debug "EXIF Debug - Archivo: $(basename "$poster_image")"
        log_debug "EXIF Debug - Actual: '$current_exif'"
        log_debug "EXIF Debug - Esperado: '$expected_exif'"
        
        # LÓGICA CORREGIDA PARA SERIES:
        # - CUALQUIER EXIF que NO sea "LangFlags:" = Imagen lista para procesar
        # - EXIF con "LangFlags:" = Ya procesada por lang-flags, decidir si reprocesar
        
        if [[ "$current_exif" == LangFlags:* ]]; then
            # Imagen ya procesada por lang-flags
            if [[ "$current_exif" == "$expected_exif" ]]; then
                # EXIF correcto para este episodio específico: Ya procesada, pero reprocesar
                log_debug "✅ Imagen ya procesada por lang-flags para este episodio, reprocesando: $(basename "$poster_image")"
                # CONTINUAR - reprocesar imagen
            else
                # EXIF de otro episodio: Reprocesar para actualizar
                log_debug "✅ Imagen procesada por lang-flags (otro episodio), reprocesando: $(basename "$poster_image")"
                # CONTINUAR - reprocesar imagen
            fi
        else
            # CUALQUIER otro EXIF (vacío, IJG, CREATOR, JSON, etc.) = Imagen lista para procesar
            log_debug "✅ Imagen lista para overlay (EXIF: $(echo "$current_exif" | head -c 50)...): $(basename "$poster_image")"
            # CONTINUAR - imagen lista para procesar
        fi
    done

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
                else
                    log_warning "No se pudo guardar identificador en: $poster_image"
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
# =============================================================================
# FUNCIONES DE PROCESAMIENTO POR TIPO
# =============================================================================

process_movies() {
    local force_process="$1"

    log_info "Procesando películas..."

    # Escanear y añadir a cola SOLAMENTE
    scan_and_queue "$MOVIES_DIR" "movie" "$force_process"

    # NO procesar cola - solo añadir
    
    # Programar procesamiento automático (solo programar, no ejecutar)
    schedule_process "process"
    
    log_info "📋 Escaneo completado. Procesamiento programado automáticamente."
}

process_series() {
    local force_process="$1"

    log_info "Procesando series..."

    # Escanear y añadir a cola SOLAMENTE
    scan_and_queue "$SERIES_DIR" "tvshow" "$force_process"

    # NO procesar cola - solo añadir
    
    # Programar procesamiento automático (solo programar, no ejecutar)
    schedule_process "process"
    
    log_info "📋 Escaneo completado. Procesamiento programado automáticamente."
}

process_all() {
    local force_process="$1"

    log_info "Procesando toda la biblioteca multimedia..."

    # Escanear y añadir a cola ambos tipos SOLAMENTE
    scan_and_queue "$MOVIES_DIR" "movie" "$force_process"
    scan_and_queue "$SERIES_DIR" "tvshow" "$force_process"

    # NO procesar cola - solo añadir
    
    # Programar procesamiento automático (solo programar, no ejecutar)
    schedule_process "process"
    
    log_info "📋 Escaneo completado. Procesamiento programado automáticamente."
}

show_usage() {
    cat <<EOF
Uso: $(basename "$0") [COMANDO] [OPCIONES]

COMANDOS:
    movies          Escanear y añadir películas a cola (NO procesa)
    series          Escanear y añadir series a cola (NO procesa)
    all             Escanear y añadir toda la biblioteca a cola (NO procesa)
    process         Procesar colas existentes SIN escanear nuevos archivos
    webhook         Procesar evento específico de webhook (SOLO añade a cola)
    setup           Instalar dependencias necesarias (exiftool, imagemagick, etc.)
    
    Si no se especifica comando:
    - Con variables de webhook: añade evento específico a cola
    - Sin variables de webhook: añade toda la biblioteca a cola

OPCIONES:
    -f, --force     Forzar reprocesamiento:
                   - Limpia cache EXIF
                   - Añade todo a cola sin verificar cache
                   - Procesa todo ignorando optimizaciones
    -h, --help      Mostrar esta ayuda

SISTEMA DE PROGRAMACIÓN AUTOMÁTICA:
    - Los comandos movies, series, all programan automáticamente
      el procesamiento usando 'at' en ${SCHEDULE_DELAY_MINUTES} minuto(s)
    - Los webhooks programan automáticamente el procesamiento con delay
      específico de ${SCHEDULE_DELAY_MINUTES_FROM_WEBHOOK} minutos (mínimo 5 min)
    - Para eventos de actualización/upgrade, el delay se duplica automáticamente
      (webhooks: ${SCHEDULE_DELAY_MINUTES_FROM_WEBHOOK}×2=$((SCHEDULE_DELAY_MINUTES_FROM_WEBHOOK * 2)) min)
    - Webhooks borran automáticamente las imágenes que se van a editar
      (folder, backdrop, thumbnail, etc.) antes de programar el procesamiento
    - Después de procesar, si hay más elementos en cola, se reprograma
      automáticamente para otro ciclo de procesamiento
    - El setup programa automáticamente un escaneo inicial apropiado
      según el tipo de contenedor (radarr=movies, sonarr=series, otro=all)

ARCHIVOS:
    Cola Radarr:    $RADARR_QUEUE
    Cola Sonarr:    $SONARR_QUEUE
    Logs:           $LOG_DIR/lang-flags-YYYYMMDD.log
    Cache:          $DATA_DIR/lang-flags-cache.txt
    Directorio:     $BASE_DIR

DEPENDENCIAS:
    exiftool, imagemagick, rsvg-convert, ffmpeg, mediainfo, mkvtoolnix, jq, at

EJEMPLOS:
    $(basename "$0") movies -f    # Forzar reprocesamiento películas
    $(basename "$0") setup        # Instalar dependencias + escaneo inicial
    $(basename "$0") process      # Procesar colas existentes
    $(basename "$0")              # Añadir toda la biblioteca a cola

Para más información, revisar logs en: $LOG_DIR

EJEMPLOS:
    $(basename "$0")                    # Auto-detectar: webhook o biblioteca completa (SOLO añade a cola)
    $(basename "$0") movies             # Escanear películas → añadir a cola (NO procesa)
    $(basename "$0") series -f          # Escanear series forzado → añadir a cola (NO procesa)
    $(basename "$0") all --force        # Biblioteca completa forzado → añadir a cola (NO procesa)
    $(basename "$0") process            # Procesar colas existentes (sin escanear)
    $(basename "$0") setup              # Instalar dependencias necesarias

FLUJO DEL SISTEMA:
    1. ESCANEO: Verificar cache y añadir items necesarios a cola
    2. COLA: Items pendientes de procesamiento
    3. PROCESAMIENTO: Solo con comando 'process' - aplicar overlays y actualizar cache
    
    - Sin -f: Solo añade a cola items que no están en cache
    - Con -f: Añade TODO a cola sin verificar cache
    - Webhook: Añade SIEMPRE a cola sin verificar cache
    - Solo 'process' procesa la cola

NOTAS:
    - Los logs se guardan en: $LOG_DIR
    - Cache EXIF: UserComment en metadatos de imagen
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
        radarr_count=$(wc -l <"$RADARR_QUEUE" 2>/dev/null || echo "0")
    fi

    if [[ -f "$SONARR_QUEUE" ]]; then
        sonarr_count=$(wc -l <"$SONARR_QUEUE" 2>/dev/null || echo "0")
    fi

    echo $((radarr_count + sonarr_count))
}

get_specific_queue_count() {
    local media_type="$1"
    local queue_file=""
    
    case "$media_type" in
    "movie")
        queue_file="$RADARR_QUEUE"
        ;;
    "tvshow")
        queue_file="$SONARR_QUEUE"
        ;;
    *)
        # Para tipos desconocidos, usar la cuenta total
        get_total_queue_count
        return
        ;;
    esac

    if [[ -f "$queue_file" ]]; then
        wc -l <"$queue_file" 2>/dev/null || echo "0"
    else
        echo "0"
    fi
}

main() {
    local command=""
    local force_process="false"

    # Parsear argumentos
    while [[ $# -gt 0 ]]; do
        case $1 in
        movies | series | all | webhook | setup | process)
            command="$1"
            shift
            ;;
        -f | --force)
            force_process="true"
            shift
            ;;
        -h | --help)
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

    log_info "Iniciando Lang-Flags - Versión $SCRIPT_VERSION"
    log_info "Comando: $command | Forzar: $force_process"

    # BLOQUEO: Solo una instancia por contenedor (excepto setup que maneja sus propios locks)
    if [[ "$command" != "setup" ]]; then
        log_info "🔒 Verificando bloqueo de instancia única..."
        log_info "⏳ Esperando indefinidamente a que termine la ejecución anterior (si existe)..."
        
        # Esperar indefinidamente hasta obtener el lock (bloqueo)
        if ! acquire_lock "$PROCESS_LOCK" 86400 "lang-flags-main"; then
            log_error "❌ No se pudo obtener el bloqueo después de 24 horas"
            log_error "❌ Proceso abortado por timeout"
            exit 1
        fi
        
        # Configurar limpieza automática al salir
        trap cleanup_locks EXIT
        log_info "✅ Bloqueo adquirido - instancia única confirmada"
    fi

    # Ejecutar comando correspondiente
    case "$command" in
    webhook)
        # Procesar evento de webhook específico (SOLO añadir a cola)
        process_webhook_event
        # NO procesar cola - se procesa en otro momento
        ;;
    process)
        # Procesar colas existentes SIN escanear nuevos archivos
        log_info "🔄 Procesando colas existentes..."
        process_queue
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
