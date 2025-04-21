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
DEBUG=false # Default debug mode is off

# Parse arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -v|--verbose) DEBUG=true ;;
        all) MODE="all" ;;
        movies) MODE="movies" ;;
        tvshows) MODE="tvshows" ;;
        -j|--jobs) shift; MAX_PARALLEL_JOBS=$1 ;;
        *) ;;
    esac
    shift
done

# Si no se especifica, usar el número de núcleos disponibles menos 1 (mínimo 2)
if [ -z "$MAX_PARALLEL_JOBS" ]; then
    CORES=$(nproc 2>/dev/null || echo 4)
    MAX_PARALLEL_JOBS=$((CORES - 1))
    [ "$MAX_PARALLEL_JOBS" -lt 2 ] && MAX_PARALLEL_JOBS=2
fi

CUSTOM_CREATOR_TOOL="carcheky"                     # Default to current date
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

# Ensure the temporary directory exists
install_deps() {
    $DEBUG && echo "Script is running as user: $(whoami), group: $(id -gn)" >&2
    local packages=("perl-image-exiftool" "jq" "imagemagick" "ffmpeg" "inkscape" "rsvg-convert" "exiftool")
    local script_dir="/custom-cont-init.d"
    local script_file="$script_dir/lang_flags-install_deps.sh"

    mkdir -p "$script_dir"

    {
        echo "#!/bin/bash"
        echo "apk update && apk add --no-cache ${packages[*]}"
    } >"$script_file"

    chmod +x "$script_file"
    $DEBUG && echo "Dependency installation script created at $script_file" >&2
}

# Function to extract languages from the movie file using ffprobe
get_languages() {
    local video_file="$1"
    if [ -f "$video_file" ]; then
        mapfile -t langs < <(ffprobe "$video_file" -show_entries stream_tags=language -select_streams a -v 0 -of json | jq --raw-output '.streams[].tags.language // empty' | sort -u)
    else
        $DEBUG && echo "Error: Video file $video_file not found." >&2
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
    $DEBUG && echo "Starting add_overlay for image: $1, type: $2" >&2

    local final_image="$1"
    local type="$2"

    # Generate creatortool using exiftool
    creatortool=$(exiftool -f -s3 -"creatortool" "$final_image")
    if [ -z "$creatortool" ]; then
        $DEBUG && echo "Warning: creatortool has no value for image: $final_image" >&2
    fi
    $DEBUG && echo "Debug: CUSTOM_CREATOR_TOOL is set to: $CUSTOM_CREATOR_TOOL" >&2
    $DEBUG && echo "Debug: creatortool is set to: $creatortool" >&2

    $DEBUG && echo "Checking if creatortool matches CUSTOM_CREATOR_TOOL..." >&2
    if [ "${creatortool}" != "$CUSTOM_CREATOR_TOOL" ]; then
        $DEBUG && echo "creatortool does not match CUSTOM_CREATOR_TOOL. Proceeding with overlay application." >&2
        offset_x=0
        offset_y=0
        if [ -f "$final_image" ]; then
            $DEBUG && echo "Processing image: $final_image" >&2

            dimensions=$(identify -format "%wx%h" "$final_image" 2>/dev/null)
            if [ -z "$dimensions" ]; then
                $DEBUG && echo "Error: Unable to retrieve dimensions for $final_image. Skipping." >&2
                return
            fi

            width=$(echo $dimensions | cut -d 'x' -f 1)
            height=$(echo $dimensions | cut -d 'x' -f 2)

            if ! [[ "$width" =~ ^[0-9]+$ ]] || ! [[ "$height" =~ ^[0-9]+$ ]]; then
                $DEBUG && echo "Error: Invalid dimensions ($dimensions) for $final_image. Skipping." >&2
                return
            fi

            $DEBUG && echo "Image dimensions: ${width}x${height}" >&2

            # Check if the image is horizontal or vertical
            if [ "$width" -gt "$height" ]; then
                $DEBUG && echo "Image is horizontal." >&2
                gravity="SouthEast"
                resize=$poster_resize
                offset_x=100
            else
                $DEBUG && echo "Image is vertical." >&2
                gravity="SouthWest"
                resize=$vertical_resize
            fi

            # Check if it is a thumb or folder.jpg
            if [ "$type" == "thumb" ]; then
                $DEBUG && echo "Image type is thumb." >&2
                gravity="SouthWest"
                offset_x=150
            fi

            # Resize the poster image (without cropping)
            magick "$final_image" -resize "$resize" "$final_image"

            for flag_file in "${flag_files[@]}"; do
                if [ -f "$OVERLAY_DIR/$flag_file" ]; then
                    $DEBUG && echo "Adding flag: $flag_file to image: $final_image" >&2

                    magick "$final_image" \
                        \( -density $flag_width "$OVERLAY_DIR/$flag_file" -resize "${flag_width}x${flag_height}" \) \
                        -gravity ${gravity} -geometry +${offset_x}+${offset_y} -composite \
                        "$final_image"

                    [ -f folder.jpg_exiftool_tmp ] && rm folder.jpg_exiftool_tmp -f
                    $DEBUG && echo "-> Added $flag_file to $(pwd)/$final_image" >&2

                    if command -v exiftool >/dev/null 2>&1; then
                        exiftool -creatortool="$CUSTOM_CREATOR_TOOL" -overwrite_original "$final_image" 1>/dev/null
                    else
                        $DEBUG && echo "Error: exiftool not found. Skipping metadata update." >&2
                    fi

                    if [[ "$resize" == "$poster_resize" ]]; then
                        offset_x=$((offset_x + flag_width))
                    else
                        offset_y=$((offset_y + flag_height))
                    fi
                else
                    $DEBUG && echo "Flag file $flag_file not found in $OVERLAY_DIR." >&2
                fi
            done
        else
            $DEBUG && echo "Image file $final_image not found." >&2
        fi
    else
        $DEBUG && echo "creatortool matches CUSTOM_CREATOR_TOOL. Skipping overlay application." >&2
    fi
    $DEBUG && echo "Finished add_overlay for image: $1, type: $2" >&2
}

# Function to wait for nfo and process the image
wait_for_nfo_and_process() {
    local content_path="$1"
    local is_all_mode="$2" # Pass "true" if running in "all" mode
    local skip_header="$3" # New parameter to skip the header in batch mode

    $DEBUG && echo "Processing folder: $content_path" >&2

    $DEBUG && echo "Checking for movie.nfo or tvshow.nfo in $content_path..." >&2

    # Check if there are no .mkv files in the folder
    if ! find "$content_path" -maxdepth 1 -type f -name '*.mkv' | grep -q . && \
       ! find "$content_path" -mindepth 2 -type f -name '*.mkv' | grep -q .; then
        echo "WARNING: No .mkv file found in $content_path. Moving to $A_BORRAR_DIR." >&2
        mkdir -p "$A_BORRAR_DIR"
        mv "$content_path" "$A_BORRAR_DIR/"
        return
    fi

    local timeout=300 # 5 minutes in seconds
    local elapsed=0
    while [ ! -f "$content_path/movie.nfo" ] && [ ! -f "$content_path/tvshow.nfo" ]; do
        sleep 1
        elapsed=$((elapsed + 1))
        if [ "$elapsed" -ge "$timeout" ]; then
            $DEBUG && echo "Timeout reached while waiting for .nfo files in $content_path." >&2
            return
        fi
    done

    if [ -f "$content_path/movie.nfo" ]; then
        # Only print the header if not already printed in batch mode
        if [ "$skip_header" != "true" ]; then
            echo "Processing MOVIE: $(basename "$content_path")" >&2
        fi

        local mkv_file="${radarr_moviefile_path:-$(find "$content_path" -maxdepth 1 -type f -name '*.mkv' | head -n 1)}"
        if [ -z "$mkv_file" ] || [ ! -f "$mkv_file" ]; then
            $DEBUG && echo "Error: No valid .mkv file found for the movie in $content_path." >&2
            return
        fi

        get_languages "$mkv_file"

        if [ "$is_all_mode" == "true" ]; then
            # Process folder.jpg and backdrop.jpg if they exist, without waiting
            [ -f "$content_path/folder.jpg" ] && add_overlay "$content_path/folder.jpg" "folder" || $DEBUG && echo "Skipping: folder.jpg not found in $content_path." >&2
            [ -f "$content_path/backdrop.jpg" ] && add_overlay "$content_path/backdrop.jpg" "backdrop" || $DEBUG && echo "Skipping: backdrop.jpg not found in $content_path." >&2
        else
            # Wait for folder.jpg and backdrop.jpg with a timeout
            elapsed=0
            while [ ! -f "$content_path/folder.jpg" ] || [ ! -f "$content_path/backdrop.jpg" ]; do
                $DEBUG && echo "Waiting for folder.jpg and backdrop.jpg in $content_path..." >&2
                sleep 1
                elapsed=$((elapsed + 1))
                if [ "$elapsed" -ge "$timeout" ]; then
                    $DEBUG && echo "Timeout reached while waiting for folder.jpg or backdrop.jpg in $content_path." >&2
                    return
                fi
            done

            if [ -f "$content_path/folder.jpg" ]; then
                add_overlay "$content_path/folder.jpg" "folder"
            else
                $DEBUG && echo "Error: folder.jpg not found in $content_path." >&2
            fi

            if [ -f "$content_path/backdrop.jpg" ]; then
                add_overlay "$content_path/backdrop.jpg" "backdrop"
            else
                $DEBUG && echo "Error: backdrop.jpg not found in $content_path." >&2
            fi
        fi
    elif [ -f "$content_path/tvshow.nfo" ]; then
        # Only print the header if not already printed in batch mode
        if [ "$skip_header" != "true" ]; then
            echo "Processing SERIES: $(basename "$content_path")" >&2
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
                $DEBUG && echo "No MKV files found in series directory or subdirectories. Skipping series main images." >&2
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
            echo "  • Processing season $season_count/$total_seasons: $season_name in $(basename "$content_path")" >&2

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
                    echo "    ◦ Processing episode $episode_count/$total_episodes: $episode_name in $season_name" >&2
                    get_languages "$mkv_file"
                    add_overlay "$thumb_file" "thumb"
                else
                    $DEBUG && echo "Warning: MKV file not found for thumb: $thumb_file" >&2
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
                $DEBUG && echo "Waiting for thumb file: $thumb_file" >&2
                sleep 1
                elapsed=$((elapsed + 1))
                if [ "$elapsed" -ge "$timeout" ]; then
                    $DEBUG && echo "Timeout reached while waiting for thumb file." >&2
                    return
                fi
            done

            if [ -f "$thumb_file" ]; then
                get_languages "$sonarr_episodefile_path"
                add_overlay "$thumb_file" "thumb"
                echo "  • Processing event episode: $episode_basename in $season_name" >&2
            else
                $DEBUG && echo "Error: Thumb file not found for episode: $sonarr_episodefile_path" >&2
            fi
        fi
    else
        $DEBUG && echo "No movie.nfo or tvshow.nfo found in $content_path. Skipping." >&2
    fi
}

# Function to process all movies or series in a base directory
process_all() {
    echo "Processing all movies in $MOVIES_DIR and all series in $SERIES_DIR..." >&2
    $DEBUG && echo "Starting batch processing with max $MAX_PARALLEL_JOBS parallel jobs..." >&2

    # Función para controlar procesos paralelos
    process_item() {
        local dir="$1"
        local is_dir_valid="$2"
        local skip_header="$3"

        if [ "$is_dir_valid" == "true" ]; then
            wait_for_nfo_and_process "$dir" "true" "$skip_header"
        fi
    }

    # Crear array para almacenar PIDs
    pids=()
    job_count=0

    # Procesar películas en paralelo
    echo "Collecting movie directories to process..." >&2
    movie_dirs=()
    for dir in "$MOVIES_DIR"/*/; do
        if [ -d "$dir" ]; then
            movie_dirs+=("$dir")
        fi
    done

    total_movies=${#movie_dirs[@]}
    echo "Found $total_movies movie directories to process" >&2

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

        echo "Processing MOVIE $((job_count + 1))/$total_movies: $(basename "$dir")" >&2
        # Lanzar proceso en segundo plano
        process_item "$dir" "true" "true" &
        pids+=($!)
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
    echo "Collecting TV series directories to process..." >&2
    series_dirs=()
    for dir in "$SERIES_DIR"/*/; do
        if [ -d "$dir" ] && [ -f "$dir/tvshow.nfo" ] && [[ "$(basename "$dir")" != "trailers" ]]; then
            series_dirs+=("$dir")
        fi
    done

    total_series=${#series_dirs[@]}
    echo "Found $total_series series directories to process" >&2

    for dir in "${series_dirs[@]}"; do
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

        echo "Processing SERIES $((job_count + 1))/$total_series: $(basename "$dir")" >&2
        # Lanzar proceso en segundo plano
        process_item "$dir" "true" "true" &
        pids+=($!)
        job_count=$((job_count + 1))
    done

    # Esperar a que terminen todos los procesos
    echo "Waiting for all processes to complete..." >&2
    for pid in "${pids[@]}"; do
        wait $pid
    done

    $DEBUG && echo "Finished batch processing." >&2
}

# Function to handle Radarr or Sonarr events
process_radarr_sonarr_event() {
    if [ -n "$radarr_eventtype" ]; then
        echo "Processing Radarr event: $radarr_eventtype" >&2
        $DEBUG && echo "Radarr Movie Path: $radarr_movie_path" >&2
        $DEBUG && echo "Radarr Movie File Path: $radarr_moviefile_path" >&2

        if [ -n "$radarr_movie_path" ]; then
            echo "Processing MOVIE: $(basename "$radarr_movie_path")" >&2
            wait_for_nfo_and_process "$radarr_movie_path" "false" "false"
        else
            echo "Error: radarr_movie_path is empty" >&2
        fi
    elif [ -n "$sonarr_eventtype" ]; then
        echo "Processing Sonarr event: $sonarr_eventtype" >&2
        $DEBUG && echo "Sonarr Series Path: $sonarr_series_path" >&2
        $DEBUG && echo "Sonarr Episode File Path: $sonarr_episodefile_path" >&2

        if [ -n "$sonarr_series_path" ]; then
            echo "Processing SERIES: $(basename "$sonarr_series_path")" >&2
            wait_for_nfo_and_process "$sonarr_series_path" "false" "false"
        else
            echo "Error: sonarr_series_path is empty" >&2
        fi
    else
        echo "Error: Neither Radarr nor Sonarr event detected." >&2
        exit 1
    fi
}

# Function to clean up Jellyfin cache directories
cleanup_jellyfin_cache() {
    local cache_dirs=("/jellyfin-config/cache" "/jellyfin-config/.cache")
    for dir in "${cache_dirs[@]}"; do
        if [ -d "$dir" ]; then
            $DEBUG && echo "Deleting cache directory: $dir" >&2
            rm -rf "$dir"
            $DEBUG && echo "Cache directory $dir deleted." >&2
        else
            $DEBUG && echo "Cache directory $dir does not exist. Skipping." >&2
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
$DEBUG && echo "Number of instances of $script_name running: $instance_count" >&2

# Main logic
if [ "$MODE" == "all" ]; then
    process_all "$MOVIES_DIR" "$SERIES_DIR"
    cleanup_jellyfin_cache
elif [ "$MODE" == "movies" ]; then
    echo "Processing all movies in $MOVIES_DIR..." >&2
    $DEBUG && echo "Starting movies batch processing with max $MAX_PARALLEL_JOBS parallel jobs..." >&2

    # Crear array para almacenar PIDs
    pids=()
    job_count=0

    # Recopilar todas las carpetas de películas
    echo "Collecting movie directories to process..." >&2
    movie_dirs=()
    for dir in "$MOVIES_DIR"/*/; do
        if [ -d "$dir" ]; then
            movie_dirs+=("$dir")
        fi
    done

    total_movies=${#movie_dirs[@]}
    echo "Found $total_movies movie directories to process" >&2

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

        echo "Processing MOVIE $((job_count + 1))/$total_movies: $(basename "$dir")" >&2
        # Lanzar proceso en segundo plano
        wait_for_nfo_and_process "$dir" "true" "true" &
        pids+=($!)
        job_count=$((job_count + 1))
    done

    # Esperar a que terminen todos los procesos
    echo "Waiting for all movie processes to complete..." >&2
    for pid in "${pids[@]}"; do
        wait $pid
    done

    cleanup_jellyfin_cache
elif [ "$MODE" == "tvshows" ]; then
    echo "Processing all TV series in $SERIES_DIR..." >&2
    $DEBUG && echo "Starting TV series batch processing with max $MAX_PARALLEL_JOBS parallel jobs..." >&2

    # Crear array para almacenar PIDs
    pids=()
    job_count=0

    # Recopilar todas las carpetas de series
    echo "Collecting TV series directories to process..." >&2
    series_dirs=()
    for dir in "$SERIES_DIR"/*/; do
        if [ -d "$dir" ] && [ -f "$dir/tvshow.nfo" ] && [[ "$(basename "$dir")" != "trailers" ]]; then
            series_dirs+=("$dir")
        fi
    done

    total_series=${#series_dirs[@]}
    echo "Found $total_series series directories to process" >&2

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
                    new_pids+=($pid)
                fi
            done
            pids=("${new_pids[@]}")
        fi

        echo "Processing SERIES $((job_count + 1))/$total_series: $(basename "$dir")" >&2
        # Lanzar proceso en segundo plano
        wait_for_nfo_and_process "$dir" "true" "true" &
        pids+=($!)
        job_count=$((job_count + 1))
    done

    # Esperar a que terminen todos los procesos
    echo "Waiting for all series processes to complete..." >&2
    for pid in "${pids[@]}"; do
        wait $pid
    done

    cleanup_jellyfin_cache
else
    process_radarr_sonarr_event
    cleanup_jellyfin_cache
fi

# Log successful execution to stdout
echo "Script executed successfully." >&1
echo $SECONDS