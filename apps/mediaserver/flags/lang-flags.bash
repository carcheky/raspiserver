#!/bin/bash

# PROMPT USED TO GENERATE THIS SCRIPT:
# "Create a bash script for a media server that automatically adds language flag overlays to movie and TV show images. The script should:
# 1. Extract audio language tracks from video files using ffprobe
# 2. Map language codes to SVG flag files
# 3. Apply flag overlays to poster images (folder.jpg) and episode thumbnails using ImageMagick
# 4. Track processed images using exiftool's creatortool metadata to avoid reprocessing
# 5. Handle both manual processing mode and event-based processing from Radarr/Sonarr
# 6. Support different layout for horizontal vs vertical posters
# 7. Include debug mode with verbose logging
# 8. Process movies, TV shows, or both with command line arguments
# 9. Wait for NFO files to be generated before processing
# The script should be configurable and work in a Docker environment with proper dependency installation.
#
# Additional requirements based on follow-up questions:
#
# Q: What are the key configurable variables needed for the script?
# A: The script needs the following configurable variables:
#    - DEBUG: Boolean flag for enabling verbose logging (default: false)
#    - CUSTOM_CREATOR_TOOL: String identifier used in exiftool metadata to mark processed images ("carcheky")
#    - OVERLAY_DIR: Directory containing flag SVG files ("/flags/4x3")
#    - flag_width/flag_height: Dimensions for the flag overlays (400x300 pixels)
#    - poster_resize: Resolution for horizontal posters ("2560x1440")
#    - vertical_resize: Resolution for vertical posters ("1920x2880")
#    - TMP_DIR: Temporary directory for intermediate files ("/tmp/lang-flags")
#    - MOVIES_DIR: Base directory for movie content ("/BibliotecaMultimedia/Peliculas")
#    - SERIES_DIR: Base directory for TV series content ("/BibliotecaMultimedia/Series")
#    - A_BORRAR_DIR: Directory for folders to be deleted ("/BibliotecaMultimedia/se-borraran")
#
# Q: How should the script handle flag positioning for different image orientations?
# A: For horizontal posters, place flags at bottom right (SouthEast gravity), for vertical posters place at bottom left (SouthWest gravity)
#
# Q: How should the script identify already processed images?
# A: Use exiftool to check if 'creatortool' metadata field equals the CUSTOM_CREATOR_TOOL value ("carcheky")
#
# Q: What should happen to folders without valid media files?
# A: Move them to A_BORRAR_DIR directory
#
# Q: What language mappings do you need?
# A: Map common ISO language codes to their corresponding country flag SVG files (spa→es.svg, eng→gb.svg, etc.)
#
# Q: How should the script integrate with Radarr/Sonarr?
# A: Detect environment variables set by Radarr/Sonarr (radarr_eventtype, sonarr_eventtype, etc.) and process relevant paths
#
# Q: How should we handle Jellyfin cache after processing images?
# A: Delete cache directories at /jellyfin-config/cache and /jellyfin-config/.cache
#
# Q: How long should the script wait for NFO files before timing out?
# A: Up to 300 seconds (5 minutes) timeout value
#
# Q: What command line arguments should be supported?
# A: -v/--verbose for debug mode, 'all' for processing everything, 'movies' for just movies, 'tvshows' for just TV shows"

# ========================
# Configurable Variables
# ========================
scriptName="Lang-Flags"
scriptVersion="1.0"
DEBUG=false # Default debug mode is off

# Global array to track all spawned child processes
CHILD_PIDS=()

# Configuración para la gestión de salida según Sonarr/Radarr
# stdout -> Debug, stderr -> Info
# Función para manejar salidas según Sonarr/Radarr
log() {
    m_time=$(date "+%F %T")
    echo $m_time" :: $scriptName :: $scriptVersion :: "$1
    echo $m_time" :: $scriptName :: $scriptVersion :: "$1 >>"/config/logs/$logFileName"
}

# Debug log envía a stdout (nivel Debug en Sonarr/Radarr)
debug_log() {
    $DEBUG && log "DEBUG :: $1"
}

# Error log envía a stderr (nivel Info en Sonarr/Radarr)
error_log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') :: Lang-Flags :: ERROR :: $1" >&2
    echo "$(date '+%Y-%m-%d %H:%M:%S') :: Lang-Flags :: ERROR :: $1" >>"/config/logs/$logFileName"
}

# Configuración del archivo de log
logfileSetup() {
    logFileName="$scriptName-$(date +"%Y_%m_%d_%I_%M_%p").txt"

    # Borrar archivos de log más antiguos que 5 días
    find "/config/logs" -type f -iname "$scriptName-*.txt" -mtime +5 -delete 2>/dev/null || true

    if [ ! -f "/config/logs/$logFileName" ]; then
        mkdir -p "/config/logs" 2>/dev/null || true
        echo "" >"/config/logs/$logFileName"
        chmod 666 "/config/logs/$logFileName" 2>/dev/null || true
    fi
}

# Verificar eventos de prueba inmediatamente al inicio del script, antes de cualquier otra operación
logfileSetup
# Handle event type test at beginning of script, with proper logging message
if [ "$radarr_eventtype" == "Test" ]; then
    log "$(date '+%Y-%m-%d %H:%M:%S') :: Lang-Flags :: Tested Successfully"
    exit 0
fi
if [ "$sonarr_eventtype" == "Test" ]; then
    log "$(date '+%Y-%m-%d %H:%M:%S') :: Lang-Flags :: Tested Successfully"
    exit 0
fi

# Check if we're running in an interactive terminal that supports ANSI escape sequences
check_terminal_support() {
    # Check if stdout is a terminal and if TERM is set to something that supports ANSI
    if [ -t 1 ] && [ -n "$TERM" ] && [ "$TERM" != "dumb" ]; then
        # Try simple ANSI test
        if echo -e "\033[1A" >/dev/null 2>&1; then
            echo "true"
            return
        fi
    fi
    echo "false"
}

INTERACTIVE_TERMINAL=$(check_terminal_support)
$DEBUG && debug_log "Interactive terminal with ANSI support: $INTERACTIVE_TERMINAL"

# Function to handle script interruption and cleanup
cleanup() {
    log "Script interrupted. Cleaning up..."

    # Clean up FIFOs
    cleanup_fifos

    # Kill all child processes
    for pid in "${CHILD_PIDS[@]}"; do
        if kill -0 $pid 2>/dev/null; then
            kill -TERM $pid 2>/dev/null || kill -KILL $pid 2>/dev/null
            $DEBUG && debug_log "Killed process $pid"
        fi
    done

    log "All child processes terminated."
    exit 1
}

# Clean up FIFO files on exit
cleanup_fifos() {
    # Delete any temporary FIFOs we created
    rm -f /tmp/series_status_$$_* 2>/dev/null
}

# # Set trap to catch interrupts and call cleanup function
# # Eliminamos EXIT del trap para que no se ejecute la función cleanup al salir normalmente
# trap cleanup INT TERM HUP

# Parse arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
    -v | --verbose) DEBUG=true ;;
    all) MODE="all" ;;
    movies) MODE="movies" ;;
    tvshows) MODE="tvshows" ;;
    -j | --jobs)
        shift
        MAX_PARALLEL_JOBS=$1
        ;;
    *) ;;
    esac
    shift
done

# Si no se especifica, usar un solo hilo por defecto
if [ -z "$MAX_PARALLEL_JOBS" ]; then
    MAX_PARALLEL_JOBS=1
fi

CUSTOM_CREATOR_TOOL="carcheky"                   # Default to current date
OVERLAY_DIR="/flags/4x3"                         # Directory containing overlay flag files
flag_width=400                                   # Width of the flag overlay (updated to match z-lang-overlay)
flag_height=300                                  # Height of the flag overlay (updated to match z-lang-overlay)
poster_resize="2560x1440"                        # Resize dimensions for horizontal posters
vertical_resize="1920x2880"                      # Resize dimensions for vertical posters
TMP_DIR="/tmp/lang-flags"                        # Temporary directory for intermediate files
MOVIES_DIR="/BibliotecaMultimedia/Peliculas"     # Directory containing movie folders
SERIES_DIR="/BibliotecaMultimedia/Series"        # Directory containing series folders
A_BORRAR_DIR="/BibliotecaMultimedia/se-borraran" # Directory for files to be deleted

# ========================
# Functions
# ========================

# Function to update terminal display in place (if supported)
update_status() {
    local message="$1"
    local is_new_line="$2"

    if [ "$INTERACTIVE_TERMINAL" = "true" ]; then
        # Clear the current line
        echo -ne "\r\033[K"

        # Print the message
        echo -ne "$message"

        # Add a newline if requested
        if [ "$is_new_line" = "true" ]; then
            echo ""
        fi
    else
        # Fallback for non-interactive terminals
        echo "$message"
    fi
}

# Function to clear the previous status lines (if supported)
clear_status_lines() {
    local lines="$1"

    if [ "$INTERACTIVE_TERMINAL" = "true" ]; then
        for ((i = 0; i < $lines; i++)); do
            echo -ne "\033[1A\033[K" # Move up one line and clear it
        done
    fi
}

# Ensure the temporary directory exists
install_deps() {
    debug_log "Script is running as user: $(whoami), group: $(id -gn)"
    local packages=("perl-image-exiftool" "jq" "imagemagick" "ffmpeg" "inkscape" "rsvg-convert" "exiftool")
    local script_dir="/custom-cont-init.d"
    local script_file="$script_dir/lang_flags-install_deps.sh"

    mkdir -p "$script_dir"

    {
        echo "#!/bin/bash
apk update && apk add --no-cache perl-image-exiftool jq imagemagick ffmpeg inkscape rsvg-convert exiftool
(
  sleep 120
  if ls -f /config/radarr* >/dev/null 2>&1; then
    echo "Running lang-flags for Radarr"
    bash /flags/lang-flags.sh -j 1 -f movies
  elif ls -f /config/sonarr* >/dev/null 2>&1; then
    echo "Running lang-flags for Sonarr"
    bash /flags/lang-flags.sh -j 1 -f tvshows
  fi
) &
"
    } >"$script_file"

    chmod +x "$script_file"
    debug_log "Dependency installation script created at $script_file"
}

# Function to extract languages from the movie file using ffprobe
get_languages() {
    local video_file="$1"
    if [ -f "$video_file" ]; then
        mapfile -t langs < <(ffprobe "$video_file" -show_entries stream_tags=language -select_streams a -v 0 -of json | jq --raw-output '.streams[].tags.language // empty' | sort -u)
    else
        debug_log "Error: Video file $video_file not found."
        langs=()
    fi
    declare -A map
    map=(
        ["spa"]="es.svg"
        ["eng"]="gb.svg"
        ["fra"]="fr.svg"
        ["deu"]="de.svg"
        ["ita"]="it.svg"
        ["por"]="pt.svg"
        ["jpn"]="jp.svg"
        ["ara"]="ae.svg"
        ["rus"]="ru.svg"
        ["chi"]="cn.svg"
        ["kor"]="kr.svg"
        ["dut"]="nl.svg"
        ["pol"]="pl.svg"
        ["swe"]="se.svg"
        ["fin"]="fi.svg"
        ["nor"]="no.svg"
        ["dan"]="dk.svg"
        ["tur"]="tr.svg"
        ["hin"]="in.svg"
        ["bel"]="be.svg"
    )
    flag_files=()
    for lang in "${langs[@]}"; do
        flag_files+=("${map[$lang]:-$lang}")
    done
}

# Function to apply the overlay on the image (thumb or folder.jpg)
add_overlay() {
    debug_log "Starting add_overlay for image: $1, type: $2"

    local final_image="$1"
    local type="$2"

    # Generate creatortool using exiftool
    creatortool=$(exiftool -f -s3 -"creatortool" "$final_image")
    if [ -z "$creatortool" ]; then
        debug_log "Warning: creatortool has no value for image: $final_image"
    fi
    debug_log "Debug: CUSTOM_CREATOR_TOOL is set to: $CUSTOM_CREATOR_TOOL"
    debug_log "Debug: creatortool is set to: $creatortool"

    debug_log "Checking if creatortool matches CUSTOM_CREATOR_TOOL..."
    if [ "${creatortool}" != "$CUSTOM_CREATOR_TOOL" ]; then
        debug_log "creatortool does not match CUSTOM_CREATOR_TOOL. Proceeding with overlay application."
        offset_x=0
        offset_y=0
        if [ -f "$final_image" ]; then
            debug_log "Processing image: $final_image"

            dimensions=$(identify -format "%wx%h" "$final_image" 2>/dev/null)
            if [ -z "$dimensions" ]; then
                debug_log "Error: Unable to retrieve dimensions for $final_image. Skipping."
                return
            fi

            width=$(echo $dimensions | cut -d 'x' -f 1)
            height=$(echo $dimensions | cut -d 'x' -f 2)

            if ! [[ "$width" =~ ^[0-9]+$ ]] || ! [[ "$height" =~ ^[0-9]+$ ]]; then
                debug_log "Error: Invalid dimensions ($dimensions) for $final_image. Skipping."
                return
            fi

            debug_log "Image dimensions: ${width}x${height}"

            # Check if the image is horizontal or vertical
            if [ "$width" -gt "$height" ]; then
                debug_log "Image is horizontal."
                gravity="SouthEast"
                resize=$poster_resize
                offset_x=100
            else
                debug_log "Image is vertical."
                gravity="SouthWest"
                resize=$vertical_resize
            fi

            # Check if it is a thumb or folder.jpg
            if [ "$type" == "thumb" ]; then
                debug_log "Image type is thumb."
                gravity="SouthWest"
                offset_x=150
            fi

            # Resize the poster image (without cropping)
            magick "$final_image" -resize "$resize" "$final_image"

            for flag_file in "${flag_files[@]}"; do
                if [ -f "$OVERLAY_DIR/$flag_file" ]; then
                    debug_log "Adding flag: $flag_file to image: $final_image"

                    magick "$final_image" \
                        \( -density $flag_width "$OVERLAY_DIR/$flag_file" -resize "${flag_width}x${flag_height}" \) \
                        -gravity ${gravity} -geometry +${offset_x}+${offset_y} -composite \
                        "$final_image"

                    [ -f folder.jpg_exiftool_tmp ] && rm folder.jpg_exiftool_tmp -f
                    debug_log "-> Added $flag_file to $(pwd)/$final_image"

                    if command -v exiftool >/dev/null 2>&1; then
                        exiftool -creatortool="$CUSTOM_CREATOR_TOOL" -overwrite_original "$final_image" 1>/dev/null
                    else
                        debug_log "Error: exiftool not found. Skipping metadata update."
                    fi

                    if [[ "$resize" == "$poster_resize" ]]; then
                        offset_x=$((offset_x + flag_width))
                    else
                        offset_y=$((offset_y + flag_height))
                    fi
                else
                    debug_log "Flag file $flag_file not found in $OVERLAY_DIR."
                fi
            done
        else
            debug_log "Image file $final_image not found."
        fi
    else
        debug_log "creatortool matches CUSTOM_CREATOR_TOOL. Skipping overlay application."
    fi
    debug_log "Finished add_overlay for image: $1, type: $2"
}

# Function to wait for nfo and process the image
wait_for_nfo_and_process() {
    local content_path="$1"
    local is_all_mode="$2"     # Pass "true" if running in "all" mode
    local skip_header="$3"     # New parameter to skip the header in batch mode
    local background_wait="$4" # New parameter to control if we wait in background

    debug_log "Processing folder: $content_path"

    debug_log "Checking for movie.nfo or tvshow.nfo in $content_path..."

    # Check if there are no .mkv files in the folder
    if ! find "$content_path" -maxdepth 1 -type f -name '*.mkv' | grep -q . &&
        ! find "$content_path" -mindepth 2 -type f -name '*.mkv' | grep -q .; then
        log "WARNING: No .mkv file found in $content_path. Moving to $A_BORRAR_DIR."
        mkdir -p "$A_BORRAR_DIR"
        mv "$content_path" "$A_BORRAR_DIR/"
        return
    fi

    # Si se solicita espera en segundo plano, ejecutamos el procesamiento en un subproceso
    if [ "$background_wait" = "true" ]; then
        (
            debug_log "Starting background wait process for $content_path"
            _process_content "$content_path" "$is_all_mode" "$skip_header"
            debug_log "Background wait process completed for $content_path"
        ) &
        local bg_pid=$!
        debug_log "Started background process $bg_pid for $content_path"
        CHILD_PIDS+=($bg_pid)
        return
    else
        # Procesamiento normal si no se solicita en segundo plano
        _process_content "$content_path" "$is_all_mode" "$skip_header"
    fi
}

# Función interna que realiza el verdadero procesamiento después de esperar los archivos
_process_content() {
    local content_path="$1"
    local is_all_mode="$2"
    local skip_header="$3"

    local timeout=300 # 5 minutes in seconds
    local elapsed=0

    # Esperar por NFO files
    debug_log "Waiting for NFO files in $content_path..."
    while [ ! -f "$content_path/movie.nfo" ] && [ ! -f "$content_path/tvshow.nfo" ]; do
        sleep 1
        elapsed=$((elapsed + 1))
        if [ "$elapsed" -ge "$timeout" ]; then
            debug_log "Timeout reached while waiting for .nfo files in $content_path."
            return
        fi
    done

    if [ -f "$content_path/movie.nfo" ]; then
        # Only print the header if not already printed in batch mode
        if [ "$skip_header" != "true" ]; then
            log "Processing MOVIE: $(basename "$content_path")"
        fi

        local mkv_file="${radarr_moviefile_path:-$(find "$content_path" -maxdepth 1 -type f -name '*.mkv' | head -n 1)}"
        if [ -z "$mkv_file" ] || [ ! -f "$mkv_file" ]; then
            debug_log "Error: No valid .mkv file found for the movie in $content_path."
            return
        fi

        get_languages "$mkv_file"

        if [ "$is_all_mode" == "true" ]; then
            # Process folder.jpg and backdrop.jpg if they exist, without waiting
            [ -f "$content_path/folder.jpg" ] && add_overlay "$content_path/folder.jpg" "folder" || debug_log "Skipping: folder.jpg not found in $content_path."
            [ -f "$content_path/backdrop.jpg" ] && add_overlay "$content_path/backdrop.jpg" "backdrop" || debug_log "Skipping: backdrop.jpg not found in $content_path."
        else
            # Wait for folder.jpg and backdrop.jpg with a timeout
            elapsed=0
            debug_log "Waiting for image files in background for $content_path..."
            while [ ! -f "$content_path/folder.jpg" ] || [ ! -f "$content_path/backdrop.jpg" ]; do
                sleep 1
                elapsed=$((elapsed + 1))
                if [ "$elapsed" -ge "$timeout" ]; then
                    debug_log "Timeout reached while waiting for folder.jpg or backdrop.jpg in $content_path."
                    return
                fi
            done

            if [ -f "$content_path/folder.jpg" ]; then
                add_overlay "$content_path/folder.jpg" "folder"
            else
                debug_log "Error: folder.jpg not found in $content_path."
            fi

            if [ -f "$content_path/backdrop.jpg" ]; then
                add_overlay "$content_path/backdrop.jpg" "backdrop"
            else
                debug_log "Error: backdrop.jpg not found in $content_path."
            fi
        fi
    elif [ -f "$content_path/tvshow.nfo" ]; then
        # Only print the header if not already printed in batch mode
        if [ "$skip_header" != "true" ]; then
            log "Processing SERIES: $(basename "$content_path")"
        fi

        # Process series main images (folder.jpg and backdrop.jpg)
        if [ -f "$content_path/folder.jpg" ]; then
            # For main series folder, use any episode to get languages
            local any_mkv_file=$(find "$content_path" -type f -name "*.mkv" | head -n 1)
            if [ -n "$any_mkv_file" ] && [ -f "$any_mkv_file" ]; then
                get_languages "$any_mkv_file"
                add_overlay "$content_path/folder.jpg" "folder"

                if [ -f "$content_path/backdrop.jpg" ]; then
                    add_overlay "$content_path/backdrop.jpg" "backdrop"
                fi
            else
                debug_log "No MKV files found in series directory or subdirectories. Skipping series main images."
            fi
        fi

        # Process season folders
        season_dirs=()
        for season_dir in "$content_path"/Season*/; do
            if [ -d "$season_dir" ] && [ -f "${season_dir}season.nfo" ]; then
                season_dirs+=("$season_dir")
            fi
        done

        total_seasons=${#season_dirs[@]}
        season_count=0

        for season_dir in "${season_dirs[@]}"; do
            season_count=$((season_count + 1))
            season_name=$(basename "$season_dir")
            series_name=$(basename "$content_path")
            # Extract season number (assuming format "Season XX")
            season_num=$(echo "$season_name" | grep -oE '[0-9]+' | head -1)
            season_num=$(printf "%02d" "$season_num" 2>/dev/null || echo "$season_num")

            log "  • ${series_name}-S${season_num} ($season_count/$total_seasons)"

            # Process each episode's thumb image
            episode_thumbs=()
            for thumb_file in "$season_dir"/*-thumb.jpg; do
                if [ -f "$thumb_file" ]; then
                    episode_thumbs+=("$thumb_file")
                fi
            done

            total_episodes=${#episode_thumbs[@]}
            episode_count=0

            for thumb_file in "${episode_thumbs[@]}"; do
                # Extract the base name without -thumb.jpg
                local base_name="${thumb_file%-thumb.jpg}"
                local mkv_file="${base_name}.mkv"
                local episode_name=$(basename "$base_name")

                if [ -f "$mkv_file" ]; then
                    episode_count=$((episode_count + 1))
                    # Extract episode number from filename (assuming SxxExx format)
                    episode_num=$(echo "$episode_name" | grep -oE 'E[0-9]+|[0-9]+x[0-9]+' | grep -oE '[0-9]+$')
                    episode_num=$(printf "%02d" "$episode_num" 2>/dev/null || echo "$episode_num")

                    log "    ◦ ${series_name}-S${season_num}E${episode_num} ($episode_count/$total_episodes)"

                    # Report progress to parent if fifo exists
                    if [ -p "/tmp/series_status_$$" ]; then
                        echo "S${season_num}E${episode_num} ($episode_count/$total_episodes)" >"/tmp/series_status_$$"
                    fi

                    get_languages "$mkv_file"
                    add_overlay "$thumb_file" "thumb"
                else
                    debug_log "Warning: MKV file not found for thumb: $thumb_file"
                fi
            done
        done

        # Handle Sonarr specific event (process a single episode)
        if [ -n "$sonarr_episodefile_path" ] && [ -f "$sonarr_episodefile_path" ]; then
            local episode_basename=$(basename "$sonarr_episodefile_path" .mkv)
            local episode_dir=$(dirname "$sonarr_episodefile_path")
            local season_name=$(basename "$episode_dir")
            local thumb_file="${episode_dir}/${episode_basename}-thumb.jpg"

            elapsed=0
            while [ ! -f "$thumb_file" ]; do
                debug_log "Waiting for thumb file: $thumb_file"
                sleep 1
                elapsed=$((elapsed + 1))
                if [ "$elapsed" -ge "$timeout" ]; then
                    debug_log "Timeout reached while waiting for thumb file."
                    return
                fi
            done

            if [ -f "$thumb_file" ]; then
                get_languages "$sonarr_episodefile_path"
                add_overlay "$thumb_file" "thumb"

                # Extract season and episode numbers for event episode
                series_name=$(basename "$content_path")
                season_num=$(echo "$season_name" | grep -oE '[0-9]+' | head -1)
                season_num=$(printf "%02d" "$season_num" 2>/dev/null || echo "$season_num")
                episode_num=$(echo "$episode_basename" | grep -oE 'E[0-9]+|[0-9]+x[0-9]+' | grep -oE '[0-9]+$')
                episode_num=$(printf "%02d" "$episode_num" 2>/dev/null || echo "$episode_num")

                log "  • Event: ${series_name}-S${season_num}E${episode_num}"
            else
                debug_log "Error: Thumb file not found for episode: $sonarr_episodefile_path"
            fi
        fi
    else
        debug_log "No movie.nfo or tvshow.nfo found in $content_path. Skipping."
    fi
}

# Function to process all movies or series in a base directory
process_all() {
    log "Processing all movies in $MOVIES_DIR and all series in $SERIES_DIR..."
    debug_log "Starting batch processing with max $MAX_PARALLEL_JOBS parallel jobs..."

    # Función para controlar procesos paralelos
    process_item() {
        local dir="$1"
        local is_dir_valid="$2"
        local skip_header="$3"

        if [ "$is_dir_valid" == "true" ]; then
            wait_for_nfo_and_process "$dir" "true" "$skip_header" "true"
        fi
    }

    # Crear array para almacenar PIDs
    pids=()
    job_count=0

    # Procesar películas en paralelo
    log "Collecting movie directories to process..."
    movie_dirs=()
    for dir in "$MOVIES_DIR"/*/; do
        if [ -d "$dir" ]; then
            movie_dirs+=("$dir")
        fi
    done

    total_movies=${#movie_dirs[@]}
    log "Found $total_movies movie directories to process"

    for dir in "${movie_dirs[@]}"; do
        # Controlar número de trabajos en paralelo
        if [ ${#pids[@]} -ge $MAX_PARALLEL_JOBS ]; then
            # Esperar a que termine un proceso
            wait -n
            # Limpiar PIDs que ya han terminado
            new_pids=()
            for pid in "${pids[@]}"; do
                if kill -0 $pid 2>/dev/null; then
                    new_pids+=($pid)
                fi
            done
            pids=("${new_pids[@]}")
        fi

        log "Processing MOVIE $((job_count + 1))/$total_movies: $(basename "$dir")"
        # Lanzar proceso en segundo plano
        process_item "$dir" "true" "true" &
        pid=$!
        pids+=($pid)
        CHILD_PIDS+=($pid) # Add to global tracking array
        job_count=$((job_count + 1))
    done

    # Esperar a que terminen todos los procesos de películas
    for pid in "${pids[@]}"; do
        wait $pid
    done

    # Resetear contadores para series
    pids=()
    job_count=0

    # Procesar series en paralelo
    log "Collecting TV series directories to process..."
    series_dirs=()
    for dir in "$SERIES_DIR"/*/; do
        if [ -d "$dir" ] && [ -f "$dir/tvshow.nfo" ] && [[ "$(basename "$dir")" != "trailers" ]]; then
            series_dirs+=("$dir")
        fi
    done

    total_series=${#series_dirs[@]}
    log "Found $total_series series directories to process"

    # Track active series for dynamic display
    declare -A active_series
    declare -A series_progress
    status_lines=0

    for dir in "${series_dirs[@]}"; do
        # Controlar número de trabajos en paralelo
        if [ ${#pids[@]} -ge $MAX_PARALLEL_JOBS ]; then
            # Esperar a que termine un proceso
            wait -n
            # Limpiar PIDs que ya han terminado
            new_pids=()
            for pid in "${pids[@]}"; do
                if kill -0 $pid 2>/dev/null; then
                    active_pid=true
                    new_pids+=($pid)
                else
                    # Remove completed PID from active_series
                    for series_name in "${!active_series[@]}"; do
                        if [ "${active_series[$series_name]}" = "$pid" ]; then
                            unset active_series["$series_name"]
                            break
                        fi
                    done
                fi
            done
            pids=("${new_pids[@]}")

            # Update status display
            if [ ${#active_series[@]} -gt 0 ]; then
                # Clear previous status lines
                if [ $status_lines -gt 0 ]; then
                    clear_status_lines $status_lines
                fi

                # Print current status
                status_lines=0
                for series_name in "${!active_series[@]}"; do
                    update_status "  ↳ Processing $series_name: ${series_progress[$series_name]:-Starting...}" "true"
                    status_lines=$((status_lines + 1))
                done
                update_status "Progress: $job_count/$total_series series" "true"
                status_lines=$((status_lines + 1))
            fi
        fi

        series_name=$(basename "$dir")
        if [ "$INTERACTIVE_TERMINAL" = "true" ]; then
            update_status "Processing SERIES $((job_count + 1))/$total_series: $series_name" "true"
        else
            log "Processing SERIES $((job_count + 1))/$total_series: $series_name"
        fi

        # Only create FIFO if we have interactive terminal support
        if [ "$INTERACTIVE_TERMINAL" = "true" ]; then
            # Create a fifo to receive status updates from child process
            fifo="/tmp/series_status_$$_$job_count"
            mkfifo "$fifo" 2>/dev/null

            # Launch background process with status reporting to parent
            (
                wait_for_nfo_and_process "$dir" "true" "true" "true"
                echo "DONE" >"$fifo" 2>/dev/null || true # More robust
            ) &

            pid=$!
            pids+=($pid)
            CHILD_PIDS+=($pid)
            active_series["$series_name"]=$pid

            # Start a background process to monitor status updates
            (
                while read -r status <"$fifo" 2>/dev/null; do
                    if [ "$status" = "DONE" ]; then
                        break
                    fi
                    # Forward status to parent for display
                    series_progress["$series_name"]="$status"
                done

                # Ensure FIFO gets cleaned up
                rm -f "$fifo" 2>/dev/null || true
            ) &
        else
            # Simple execution without status updates for non-interactive terminals
            wait_for_nfo_and_process "$dir" "true" "true" &
            pid=$!
            pids+=($pid)
            CHILD_PIDS+=($pid)
        fi

        job_count=$((job_count + 1))
    done

    # Wait for all series processes to complete
    log "Waiting for all processes to complete..."
    for pid in "${pids[@]}"; do
        wait $pid
    done

    # Clean up any remaining FIFOs
    cleanup_fifos

    debug_log "Finished batch processing."
}

# Function to handle Radarr or Sonarr events
process_radarr_sonarr_event() {
    # IMPORTANTE: Comprobar eventos de prueba al principio, antes de cualquier log u otra operación
    # Esto asegura que con eventos de prueba retornamos éxito inmediatamente
    [ "$radarr_eventtype" == "Test" ] && exit 0
    [ "$sonarr_eventtype" == "Test" ] && exit 0

    if [ -n "$radarr_eventtype" ]; then
        log "Processing Radarr event: $radarr_eventtype"
        debug_log "Radarr Movie Path: $radarr_movie_path"
        debug_log "Radarr Movie File Path: $radarr_moviefile_path"

        if [ -n "$radarr_movie_path" ]; then
            log "Processing MOVIE: $(basename "$radarr_movie_path")"
            wait_for_nfo_and_process "$radarr_movie_path" "false" "false" "true"
        else
            log "Error: radarr_movie_path is empty"
        fi
    elif [ -n "$sonarr_eventtype" ]; then
        log "Processing Sonarr event: $sonarr_eventtype"
        debug_log "Sonarr Series Path: $sonarr_series_path"
        debug_log "Sonarr Episode File Path: $sonarr_episodefile_path"

        if [ -n "$sonarr_series_path" ]; then
            log "Processing SERIES: $(basename "$sonarr_series_path")"
            wait_for_nfo_and_process "$sonarr_series_path" "false" "false" "true"
        else
            log "Error: sonarr_series_path is empty"
        fi
    else
        log "Error: Neither Radarr nor Sonarr event detected."
        exit 1
    fi
}

# Function to clean up Jellyfin cache directories
cleanup_jellyfin_cache() {
    local cache_dirs=("/jellyfin-config/cache" "/jellyfin-config/.cache")
    for dir in "${cache_dirs[@]}"; do
        if [ -d "$dir" ]; then
            debug_log "Deleting cache directory: $dir"
            rm -rf "$dir"
            debug_log "Cache directory $dir deleted."
        else
            debug_log "Cache directory $dir does not exist. Skipping."
        fi
    done
}

# ========================
# Main Script Logic
# ========================

# Ensure the temporary directory exists
mkdir -p "$TMP_DIR"

# Install dependencies
install_deps

# Print the number of instances of this script currently running
script_name=$(basename "$0")
instance_count=$(pgrep -fc "$script_name")
debug_log "Number of instances of $script_name running: $instance_count"

# Main logic
if [ "$MODE" == "all" ]; then
    process_all "$MOVIES_DIR" "$SERIES_DIR"
    cleanup_jellyfin_cache
elif [ "$MODE" == "movies" ]; then
    log "Processing all movies in $MOVIES_DIR..."
    debug_log "Starting movies batch processing with max $MAX_PARALLEL_JOBS parallel jobs..."

    # Crear array para almacenar PIDs
    pids=()
    job_count=0

    # Recopilar todas las carpetas de películas
    log "Collecting movie directories to process..."
    movie_dirs=()
    for dir in "$MOVIES_DIR"/*/; do
        if [ -d "$dir" ]; then
            movie_dirs+=("$dir")
        fi
    done

    total_movies=${#movie_dirs[@]}
    log "Found $total_movies movie directories to process"

    # Procesar películas en paralelo
    for dir in "${movie_dirs[@]}"; do
        # Controlar número de trabajos en paralelo
        if [ ${#pids[@]} -ge $MAX_PARALLEL_JOBS ]; then
            # Esperar a que termine un proceso
            wait -n
            # Limpiar PIDs que ya han terminado
            new_pids=()
            for pid in "${pids[@]}"; do
                if kill -0 $pid 2>/dev/null; then
                    new_pids+=($pid)
                fi
            done
            pids=("${new_pids[@]}")
        fi
    done

    # Esperar a que terminen todos los procesos
    log "Waiting for all movie processes to complete..."
    for pid in "${pids[@]}"; do
        wait $pid
    done

    cleanup_jellyfin_cache
elif [ "$MODE" == "tvshows" ]; then
    log "Processing all TV series in $SERIES_DIR..."
    debug_log "Starting TV series batch processing with max $MAX_PARALLEL_JOBS parallel jobs..."

    # Crear array para almacenar PIDs
    pids=()
    job_count=0

    # Recopilar todas las carpetas de series
    log "Collecting TV series directories to process..."
    series_dirs=()
    for dir in "$SERIES_DIR"/*/; do
        if [ -d "$dir" ] && [ -f "$dir/tvshow.nfo" ] && [[ "$(basename "$dir")" != "trailers" ]]; then
            series_dirs+=("$dir")
        fi
    done

    total_series=${#series_dirs[@]}
    log "Found $total_series series directories to process"

    # Track active series for dynamic display
    declare -A active_series
    declare -A series_progress
    status_lines=0

    # Procesar series en paralelo
    for dir in "${series_dirs[@]}"; do
        # Controlar número de trabajos en paralelo
        if [ ${#pids[@]} -ge $MAX_PARALLEL_JOBS ]; then
            # Esperar a que termine un proceso
            wait -n
            # Limpiar PIDs que ya han terminado
            new_pids=()
            for pid in "${pids[@]}"; do
                if kill -0 $pid 2>/dev/null; then
                    active_pid=true
                    new_pids+=($pid)
                else
                    # Remove completed PID from active_series
                    for series_name in "${!active_series[@]}"; do
                        if [ "${active_series[$series_name]}" = "$pid" ]; then
                            unset active_series["$series_name"]
                            break
                        fi
                    done
                fi
            done
            pids=("${new_pids[@]}")

            # Update status display
            if [ ${#active_series[@]} -gt 0 ]; then
                # Clear previous status lines
                if [ $status_lines -gt 0 ]; then
                    clear_status_lines $status_lines
                fi

                # Print current status
                status_lines=0
                for series_name in "${!active_series[@]}"; do
                    update_status "  ↳ Processing $series_name: ${series_progress[$series_name]:-Starting...}" "true"
                    status_lines=$((status_lines + 1))
                done
                update_status "Progress: $job_count/$total_series series" "true"
                status_lines=$((status_lines + 1))
            fi
        fi

        series_name=$(basename "$dir")
        if [ "$INTERACTIVE_TERMINAL" = "true" ]; then
            update_status "Processing SERIES $((job_count + 1))/$total_series: $series_name" "true"
        else
            log "Processing SERIES $((job_count + 1))/$total_series: $series_name"
        fi

        # Only create FIFO if we have interactive terminal support
        if [ "$INTERACTIVE_TERMINAL" = "true" ]; then
            # Create a fifo to receive status updates from child process
            fifo="/tmp/series_status_$$_$job_count"
            mkfifo "$fifo" 2>/dev/null

            # Launch background process with status reporting to parent
            (
                wait_for_nfo_and_process "$dir" "true" "true" "true"
                echo "DONE" >"$fifo" 2>/dev/null || true # More robust
            ) &

            pid=$!
            pids+=($pid)
            CHILD_PIDS+=($pid)
            active_series["$series_name"]=$pid

            # Start a background process to monitor status updates
            (
                while read -r status <"$fifo" 2>/dev/null; do
                    if [ "$status" = "DONE" ]; then
                        break
                    fi
                    # Forward status to parent for display
                    series_progress["$series_name"]="$status"
                done

                # Ensure FIFO gets cleaned up
                rm -f "$fifo" 2>/dev/null || true
            ) &
        else
            # Simple execution without status updates for non-interactive terminals
            wait_for_nfo_and_process "$dir" "true" "true" &
            pid=$!
            pids+=($pid)
            CHILD_PIDS+=($pid)
        fi

        job_count=$((job_count + 1))
    done

    # Wait for all series processes to complete
    log "Waiting for all processes to complete..."
    for pid in "${pids[@]}"; do
        wait $pid
    done

    # Clean up any remaining FIFOs
    cleanup_fifos

    cleanup_jellyfin_cache
else
    process_radarr_sonarr_event
    cleanup_jellyfin_cache
fi

# Log successful execution to stdout
log "Script executed successfully."
echo $SECONDS
