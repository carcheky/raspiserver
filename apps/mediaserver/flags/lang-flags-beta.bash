#!/bin/bash

# =============================================================================
# LANG-FLAGS BETA - Script de Overlays de Idioma para Radarr/Sonarr
# =============================================================================
# Versión: 3.0-beta
# Autor: MediaCheky
# Descripción: Detecta idiomas y aplica overlays de banderas a posters
# =============================================================================

# PROTECCIÓN: Solo ejecutar dentro de contenedores
if [[ ! -f /.dockerenv ]] && [[ -z "$SONARR_INSTANCE_NAME" ]] && [[ -z "$RADARR_INSTANCE_NAME" ]]; then
    echo "❌ ERROR: Este script SOLO debe ejecutarse dentro de contenedores Sonarr/Radarr"
    echo "❌ NO ejecutar en el host - puede dañar el sistema"
    exit 1
fi

# =============================================================================
# CONFIGURACIÓN GLOBAL
# =============================================================================

readonly SCRIPT_NAME="Lang-Flags-Beta"
readonly SCRIPT_VERSION="3.0-beta"
readonly DEBUG=${DEBUG:-false}

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
    local required=("exiftool" "jq" "convert" "ffprobe" "mediainfo" "mkvinfo" "rsvg-convert")
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
        # Para películas: buscar folder.jpg en el directorio de la película
        local movie_dir=$(dirname "$media_path")
        local poster_file="$movie_dir/folder.jpg"
        
        if [[ -f "$poster_file" ]]; then
            echo "$poster_file"
            return 0
        fi
        
        # Si no se encuentra en el directorio actual, buscar en el directorio padre
        # (para casos como trailers/, extras/, etc.)
        local parent_dir=$(dirname "$movie_dir")
        local parent_poster="$parent_dir/folder.jpg"
        
        if [[ -f "$parent_poster" ]]; then
            log_debug "Poster encontrado en directorio padre: $parent_poster" >&2
            echo "$parent_poster"
            return 0
        fi
        
        log_warning "Poster de película no encontrado: $poster_file (ni en $parent_poster)" >&2
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
        
        # 3. Poster de serie
        local series_poster="$series_dir/folder.jpg"
        if [[ -f "$series_poster" ]]; then
            images_to_process+=("$series_poster")
            log_debug "Poster de serie encontrado: $series_poster" >&2
        fi
        
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
    
    # Obtener dimensiones del poster
    local poster_width=$(exiftool -f -s3 -"ImageWidth" "$poster_file" 2>/dev/null)
    local poster_height=$(exiftool -f -s3 -"ImageHeight" "$poster_file" 2>/dev/null)
    if [[ -z "$poster_width" || "$poster_width" -eq 0 || -z "$poster_height" || "$poster_height" -eq 0 ]]; then
        log_warning "No se pudieron obtener dimensiones de imagen: $poster_file"
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
    
    # Verificar si imagen ya fue procesada (método del script original)
    local creatortool=$(exiftool -f -s3 -"creatortool" "$image_file" 2>/dev/null)
    
    if [[ "$creatortool" == "993" ]]; then
        return 0  # Ya procesada
    fi
    
    return 1  # No procesada
}

update_image_exif_checksum() {
    local image_file="$1"
    local video_checksum="$2"
    
    if [[ ! -f "$image_file" || -z "$video_checksum" ]]; then
        return 1
    fi
    
    # Guardar checksum en metadatos EXIF de la imagen
    exiftool -overwrite_original -UserComment="LangFlags:$video_checksum" "$image_file" 2>/dev/null || {
        log_warning "No se pudo actualizar EXIF de: $(basename "$image_file")"
        return 1
    }
    
    log_debug "Checksum EXIF actualizado en: $(basename "$image_file")"
    return 0
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

needs_processing() {
    local media_path="$1"
    local media_type="$2"
    local force_mode="${3:-false}"
    
    # Si está en modo force, siempre procesar
    if [[ "$force_mode" == "true" ]]; then
        log_debug "Modo force activado, procesando: $media_path"
        return 0
    fi
    
    # Obtener checksum actual del archivo de video
    local current_checksum
    if ! current_checksum=$(get_video_checksum "$media_path"); then
        log_warning "No se pudo calcular checksum de: $media_path"
        return 0  # Si no podemos verificar, mejor procesar
    fi
    
    # Buscar imágenes asociadas al archivo de medios
    local poster_result
    if ! poster_result=$(find_poster_image "$media_path" "$media_type"); then
        log_debug "No se encontraron imágenes, necesita procesamiento: $media_path"
        return 0
    fi
    
    # Verificar checksum en cada imagen
    local poster_files
    if [[ "$media_type" == "movie" ]]; then
        poster_files=("$poster_result")
    else
        IFS=';' read -ra poster_files <<< "$poster_result"
    fi
    
    local needs_update=false
    for poster_file in "${poster_files[@]}"; do
        # Verificar primero si la imagen ya fue procesada (método principal)
        if ! is_image_processed "$poster_file"; then
            log_debug "Imagen no procesada (sin creatortool=993): $(basename "$poster_file")"
            needs_update=true
            break
        fi
        
        # Como verificación adicional, comprobar checksum si está disponible
        local stored_checksum
        if stored_checksum=$(get_image_exif_checksum "$poster_file"); then
            if [[ "$stored_checksum" != "$current_checksum" ]]; then
                log_debug "Checksum diferente en: $(basename "$poster_file") ($stored_checksum vs $current_checksum)"
                needs_update=true
                break
            fi
        fi
    done
    
    if [[ "$needs_update" == "true" ]]; then
        return 0  # Necesita procesamiento
    else
        log_debug "Todas las imágenes están actualizadas: $media_path"
        return 1  # No necesita procesamiento
    fi
}

# =============================================================================
# PROCESAMIENTO PRINCIPAL
# =============================================================================

process_media_item() {
    local media_path="$1"
    local media_type="$2"  # "movie" o "tvshow"
    
    log_info "Procesando $media_type: $media_path"
    
    # 1. Verificar que exista el archivo de video
    if [[ ! -f "$media_path" ]]; then
        log_warning "Archivo de video no encontrado: $media_path"
        return 1
    fi
    
    # 2. Encontrar imágenes correspondientes
    local poster_images_result
    if ! poster_images_result=$(find_poster_image "$media_path" "$media_type"); then
        log_warning "No se encontraron imágenes poster para: $media_path"
        return 1
    fi
    
    # 3. Convertir resultado a array (separado por ;)
    local poster_images=()
    IFS=';' read -ra poster_images <<< "$poster_images_result"
    
    # 4. Verificar que al menos una imagen existe
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
    
    # 5. Extraer idiomas del archivo de video (solo audio tracks)
    log_debug "Extrayendo idiomas de: $media_path"
    local detected_langs
    if ! detected_langs=$(detect_languages_from_video "$media_path"); then
        log_warning "No se pudieron detectar idiomas para: $media_path"
        return 1
    fi
    
    # 6. Convertir string de idiomas a array
    local languages=()
    read -ra languages <<< "$detected_langs"
    
    if [[ ${#languages[@]} -eq 0 ]]; then
        log_warning "No se detectaron idiomas para procesar: $media_path"
        return 1
    fi
    
    log_info "Aplicando overlays para idiomas: ${languages[*]} en ${#valid_images[@]} imagen(es) (${media_type})"
    
    # Obtener checksum del video para marcar en las imágenes
    local video_checksum
    if ! video_checksum=$(get_video_checksum "$media_path"); then
        log_warning "No se pudo calcular checksum del video: $media_path"
        video_checksum=""
    fi
    
    # 7. Aplicar overlays a cada imagen válida
    local success_count=0
    for poster_image in "${valid_images[@]}"; do
        log_debug "Procesando imagen: $poster_image"
        
        if apply_language_overlays "$poster_image" "${languages[@]}"; then
            # Marcar imagen como procesada en EXIF (método principal)
            if command -v exiftool >/dev/null 2>&1; then
                exiftool -overwrite_original -creatortool="993" "$poster_image" >/dev/null 2>&1
                log_debug "Imagen marcada como procesada en EXIF: $poster_image"
                
                # Actualizar checksum del video en la imagen (método adicional)
                if [[ -n "$video_checksum" ]]; then
                    update_image_exif_checksum "$poster_image" "$video_checksum"
                fi
            fi
            ((success_count++))
            log_debug "✓ Overlay aplicado exitosamente: $poster_image"
        else
            log_warning "Error aplicando overlay: $poster_image"
        fi
    done
    
    # 8. Verificar resultado final
    if [[ $success_count -gt 0 ]]; then
        log_info "✓ Procesamiento completado para: $media_path ($success_count/${#valid_images[@]} imágenes procesadas)"
        return 0
    else
        log_warning "Error: No se pudo procesar ninguna imagen para: $media_path"
        return 1
    fi
}

# =============================================================================
# MANEJO DE EVENTOS
# =============================================================================

handle_radarr_event() {
    local event_type="$radarr_eventtype"
    local movie_path="$radarr_movie_path"
    
    log_info "Evento Radarr: $event_type"
    
    # Solo procesar eventos de importación
    if [[ "$event_type" != "Download" && "$event_type" != "MovieAdded" ]]; then
        log_debug "Evento ignorado: $event_type"
        return 0
    fi
    
    # Añadir a cola para procesamiento diferido
    echo "$(date +%s)|$event_type|$movie_path" >> "$RADARR_QUEUE"
    log_info "Película añadida a cola: $movie_path"
}

handle_sonarr_event() {
    local event_type="$sonarr_eventtype"
    local episode_path="$sonarr_episodefile_path"
    
    log_info "Evento Sonarr: $event_type"
    
    # Solo procesar eventos de importación
    if [[ "$event_type" != "Download" && "$event_type" != "EpisodeFileImported" ]]; then
        log_debug "Evento ignorado: $event_type"
        return 0
    fi
    
    # Añadir a cola para procesamiento diferido
    echo "$(date +%s)|$event_type|$episode_path" >> "$SONARR_QUEUE"
    log_info "Episodio añadido a cola: $episode_path"
}

# =============================================================================
# PROCESAMIENTO DE COLA
# =============================================================================

process_queue() {
    local queue_file="$1"
    local media_type="$2"
    
    if [[ ! -f "$queue_file" || ! -s "$queue_file" ]]; then
        return 0
    fi
    
    log_info "Procesando cola: $(basename "$queue_file")"
    
    local temp_file="$queue_file.tmp.$$"
    local processed_count=0
    
    while IFS='|' read -r timestamp event_type media_path; do
        if [[ -z "$media_path" || ! -f "$media_path" ]]; then
            log_debug "Archivo no encontrado, removiendo de cola: $media_path"
            continue
        fi
        
        # Verificar si el archivo es suficientemente antiguo (evitar procesar archivos muy recientes)
        local file_age=$(( $(date +%s) - $(stat -c %Y "$media_path" 2>/dev/null || echo 0) ))
        if [[ $file_age -lt $PROCESSING_DELAY ]]; then
            echo "$timestamp|$event_type|$media_path" >> "$temp_file"
            log_debug "Archivo muy reciente, manteniendo en cola: $media_path"
            continue
        fi
        
        # Procesar el archivo
        if process_media_item "$media_path" "$media_type"; then
            ((processed_count++))
            log_info "✓ Procesado desde cola: $media_path"
        else
            # Mantener en cola si falló el procesamiento
            echo "$timestamp|$event_type|$media_path" >> "$temp_file"
            log_warning "Error procesando, manteniendo en cola: $media_path"
        fi
        
    done < "$queue_file"
    
    # Actualizar archivo de cola
    if [[ -f "$temp_file" ]]; then
        mv "$temp_file" "$queue_file"
    else
        > "$queue_file"  # Vaciar cola si no hay elementos pendientes
    fi
    
    if [[ $processed_count -gt 0 ]]; then
        log_info "Procesados $processed_count elementos de $(basename "$queue_file")"
    fi
}

process_all_queues() {
    log_info "Procesando todas las colas..."
    
    process_queue "$RADARR_QUEUE" "movie"
    process_queue "$SONARR_QUEUE" "tvshow"
    
    log_info "Procesamiento de colas completado"
}

# =============================================================================
# PROCESAMIENTO MASIVO
# =============================================================================

scan_movies() {
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
    
    find "$MOVIES_DIR" -type f \( -name "*.mkv" -o -name "*.mp4" -o -name "*.avi" \) > "$temp_file"
    
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

scan_tvshows() {
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
    
    find "$SERIES_DIR" -type f \( -name "*.mkv" -o -name "*.mp4" -o -name "*.avi" \) > "$temp_file"
    
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
    
    # 1. Instalar dependencias del sistema
    log_info "Paso 1/3: Instalando dependencias del sistema..."
    
    local installed=false
    
    # Detectar y usar el gestor de paquetes disponible
    if command -v apt-get >/dev/null 2>&1; then
        export DEBIAN_FRONTEND=noninteractive
        apt-get update -qq >/dev/null 2>&1
        apt-get install -y -qq imagemagick libimage-exiftool-perl jq ffmpeg mediainfo mkvtoolnix librsvg2-bin curl wget bc cron >/dev/null 2>&1
        installed=true
        log_info "✓ Dependencias instaladas con apt-get"
    elif command -v apk >/dev/null 2>&1; then
        apk add --no-cache imagemagick exiftool jq ffmpeg mediainfo mkvtoolnix librsvg rsvg-convert curl wget bc bash dcron >/dev/null 2>&1
        installed=true
        log_info "✓ Dependencias instaladas con apk"
    elif command -v yum >/dev/null 2>&1; then
        yum install -y -q ImageMagick perl-Image-ExifTool jq ffmpeg mediainfo mkvtoolnix librsvg2 curl wget bc cronie >/dev/null 2>&1
        installed=true
        log_info "✓ Dependencias instaladas con yum"
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
    
    local cron_entry="*/15 * * * * /flags/lang-flags-beta.bash processqueue >/dev/null 2>&1"
    local cron_file="/etc/cron.d/lang-flags"
    
    # Crear archivo cron si no existe
    if [[ ! -f "$cron_file" ]]; then
        echo "$cron_entry" > "$cron_file" 2>/dev/null || {
            log_warning "No se pudo crear archivo cron, intentando crontab..."
            
            # Intentar con crontab del usuario
            (crontab -l 2>/dev/null | grep -v lang-flags; echo "$cron_entry") | crontab - 2>/dev/null || {
                log_error "✗ No se pudo configurar cron"
                return 1
            }
            
            log_info "✓ Cron configurado con crontab"
        }
        
        chmod 644 "$cron_file" 2>/dev/null
        log_info "✓ Cron configurado en: $cron_file"
    else
        log_info "✓ Archivo cron ya existe: $cron_file"
    fi
    
    # Iniciar servicio cron si está disponible
    if command -v service >/dev/null 2>&1; then
        service cron start >/dev/null 2>&1 || service crond start >/dev/null 2>&1
    elif command -v systemctl >/dev/null 2>&1; then
        systemctl start cron >/dev/null 2>&1 || systemctl start crond >/dev/null 2>&1
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

    # Generar script completo que instala dependencias Y configura cron
    cat > "$init_script" << 'EOF'
#!/bin/bash
echo "[$(date)] Lang-Flags-Beta: Inicializando sistema..."
/flags/lang-flags-beta.bash setup
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
# FUNCIÓN PRINCIPAL
# =============================================================================

show_help() {
    cat << 'EOF'
Lang-Flags-Beta v3.0 - Script de Overlays de Idioma para Radarr/Sonarr

MODOS DE EJECUCIÓN:
  all [-f]                  Añadir biblioteca a colas (-f: forzar todo, sin -f: solo pendientes)
  movies [-f]               Añadir películas a cola (-f: forzar todas, sin -f: solo pendientes)
  series [-f]               Añadir series a cola (-f: forzar todas, sin -f: solo pendientes)
  additem <path> [type]     Añadir elemento específico a cola (type: movie|series)
  processqueue, queue       Procesar elementos en las colas (ejecutado por cron)
  set-deps, --install-deps  Instalar dependencias del sistema
  set-cron, --setup-cron    Configurar cron para procesamiento automático
  test                      Verificar configuración
  help, --help              Mostrar esta ayuda

PARÁMETROS:
  -f, --force               Forzar procesamiento (ignorar cache EXIF)

EJEMPLOS:
  $0 all                    # Añadir solo elementos pendientes a colas
  $0 all -f                 # Forzar añadir TODA la biblioteca a colas
  $0 movies -f              # Forzar añadir TODAS las películas a cola
  $0 series                 # Añadir solo series pendientes a cola
  $0 additem "/path/movie.mkv" movie   # Añadir película específica a cola
  $0 processqueue           # Procesar cola
  $0 set-deps               # Instalar dependencias
  $0 set-cron               # Configurar cron

EVENTOS AUTOMÁTICOS:
  El script se ejecuta automáticamente desde Radarr/Sonarr via webhooks
  y procesa elementos añadiéndolos a colas para procesamiento diferido.

EOF
}

main() {
    setup_logging
    create_dirs
    
    log_info "=== $SCRIPT_NAME v$SCRIPT_VERSION iniciado ==="
    log_info "PID: $$, Usuario: $(whoami), Argumentos: $*"
    
    # Siempre generar script de inicialización del contenedor
    generate_container_init_script
    
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
    local main_command="${1:-queue}"
    
    # Verificar si se pasó el parámetro -f
    if [[ "$2" == "-f" || "$1" == "-f" ]]; then
        force_mode=true
        # Si -f es el primer argumento, el comando real es el segundo
        if [[ "$1" == "-f" ]]; then
            main_command="${2:-queue}"
        fi
    fi
    
    case "$main_command" in
        "all"|"--scan-all")
            if ! check_dependencies; then
                log_error "Dependencias faltantes. Ejecute: $0 set-deps"
                exit 1
            fi
            if [[ "$force_mode" == "true" ]]; then
                log_info "Añadiendo TODA la biblioteca a colas (modo force)..."
            else
                log_info "Añadiendo biblioteca pendiente a colas (verificando cache)..."
            fi
            scan_movies "$force_mode"
            scan_tvshows "$force_mode"
            log_info "✓ Biblioteca añadida a colas. El cron procesará automáticamente."
            ;;
        "movies"|"--scan-movies")
            if ! check_dependencies; then
                log_error "Dependencias faltantes. Ejecute: $0 set-deps"
                exit 1
            fi
            if [[ "$force_mode" == "true" ]]; then
                log_info "Añadiendo TODAS las películas a cola (modo force)..."
            else
                log_info "Añadiendo películas pendientes a cola (verificando cache)..."
            fi
            scan_movies "$force_mode"
            log_info "✓ Películas añadidas a cola. El cron procesará automáticamente."
            ;;
        "series"|"--scan-series"|"tvshows"|"--scan-tvshows")
            if ! check_dependencies; then
                log_error "Dependencias faltantes. Ejecute: $0 set-deps"
                exit 1
            fi
            if [[ "$force_mode" == "true" ]]; then
                log_info "Añadiendo TODAS las series a cola (modo force)..."
            else
                log_info "Añadiendo series pendientes a cola (verificando cache)..."
            fi
            scan_tvshows "$force_mode"
            log_info "✓ Series añadidas a cola. El cron procesará automáticamente."
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
        "processqueue"|"queue"|"--process-queue")
            if ! check_dependencies; then
                log_warning "Dependencias faltantes, configurando entorno..."
                setup_environment || {
                    log_error "Error configurando entorno"
                    exit 1
                }
            fi
            process_all_queues
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
        "debug-processing"|"--debug-processing")
            local test_file="$2"
            if [[ -z "$test_file" ]]; then
                test_file="/BibliotecaMultimedia/Peliculas/Blade (1998)/Blade (1998) {imdb-tt0120611} [ES ES-VO][Bluray-1080p][DTS 5.1][ES+EN][8bit][x264][ES+EN]-HDO.mkv"
            fi
            debug_processing "$test_file"
            ;;
        "help"|"--help"|"-h")
            show_help
            ;;
        "")
            log_info "Procesando colas por defecto..."
            if ! check_dependencies; then
                log_warning "Dependencias faltantes, configurando entorno..."
                setup_environment || {
                    log_error "Error configurando entorno"
                    exit 1
                }
            fi
            process_all_queues
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

debug_processing() {
    local video_file="$1"
    
    if [[ ! -f "$video_file" ]]; then
        echo "ERROR: Archivo no encontrado: $video_file"
        return 1
    fi
    
    echo "=== DEBUGGING NEEDS_PROCESSING ==="
    echo "Video: $video_file"
    echo ""
    
    # 1. Calcular checksum actual
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
    local poster_files=("$poster_result")
    for poster_file in "${poster_files[@]}"; do
        echo ""
        echo "--- Verificando: $(basename "$poster_file") ---"
        
        # Verificar si existe
        if [[ ! -f "$poster_file" ]]; then
            echo "  ❌ No existe"
            continue
        fi
        echo "  ✓ Existe"
        
        # Verificar creatortool (método principal)
        local creatortool=$(exiftool -f -s3 -"creatortool" "$poster_file" 2>/dev/null)
        echo "  CreatorTool: '$creatortool'"
        if [[ "$creatortool" == "993" ]]; then
            echo "  ✓ Marcado como procesado (creatortool=993)"
        else
            echo "  ❌ NO marcado como procesado"
        fi
        
        # Verificar UserComment (checksum)
        local user_comment=$(exiftool -f -s3 -"UserComment" "$poster_file" 2>/dev/null)
        echo "  UserComment: '$user_comment'"
        
        local stored_checksum=""
        if [[ "$user_comment" =~ LangFlags:([a-f0-9]+) ]]; then
            stored_checksum="${BASH_REMATCH[1]}"
            echo "  Checksum almacenado: '$stored_checksum'"
            
            if [[ "$stored_checksum" == "$current_checksum" ]]; then
                echo "  ✓ Checksum coincide"
            else
                echo "  ❌ Checksum NO coincide"
            fi
        else
            echo "  ❌ Sin checksum almacenado"
        fi
        
        # Resultado needs_processing
        if needs_processing "$video_file" "movie" false; then
            echo "  🔄 NECESITA procesamiento"
        else
            echo "  ⏭️  NO necesita procesamiento"
        fi
    done
    
    echo ""
    echo "=== FIN DEBUG ==="
}