#!/bin/bash

# ========================
# Configurable Variables
# ========================
CUSTOM_CREATOR_TOOL=$(date)                      # Default to current date
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
    echo "Script is running as user: $(whoami), group: $(id -gn)" >&2
    local packages=("perl-image-exiftool" "jq" "imagemagick" "ffmpeg" "inkscape" "rsvg-convert" "exiftool")
    local script_dir="/custom-cont-init.d"
    local script_file="$script_dir/lang_flags-install_deps.sh"

    mkdir -p "$script_dir"

    {
        echo "#!/bin/bash"
        echo "apk update && apk add --no-cache ${packages[*]}"
    } >"$script_file"

    chmod +x "$script_file"
    echo "Dependency installation script created at $script_file" >&2
}

# Function to extract languages from the movie file using ffprobe
get_languages() {
    local video_file="$1"
    if [ -f "$video_file" ]; then
        mapfile -t langs < <(ffprobe "$video_file" -show_entries stream_tags=language -select_streams a -v 0 -of json | jq --raw-output '.streams[].tags.language // empty' | sort -u)
    else
        echo "Error: Video file $video_file not found." >&2
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
    echo "Starting add_overlay for image: $1, type: $2" >&2

    local final_image="$1"
    local type="$2"

    # Generate creatortool using exiftool
    creatortool=$(exiftool -f -s3 -"creatortool" "$final_image")
    if [ -z "$creatortool" ]; then
        echo "Warning: creatortool has no value for image: $final_image" >&2
    fi
    echo "Debug: CUSTOM_CREATOR_TOOL is set to: $CUSTOM_CREATOR_TOOL" >&2
    echo "Debug: creatortool is set to: $creatortool" >&2

    echo "Checking if creatortool matches CUSTOM_CREATOR_TOOL..." >&2
    if [ "${creatortool}" != "$CUSTOM_CREATOR_TOOL" ]; then
        echo "creatortool does not match CUSTOM_CREATOR_TOOL. Proceeding with overlay application." >&2
        offset_x=0
        offset_y=0
        if [ -f "$final_image" ]; then
            echo "Processing image: $final_image" >&2

            dimensions=$(identify -format "%wx%h" "$final_image" 2>/dev/null)
            if [ -z "$dimensions" ]; then
                echo "Error: Unable to retrieve dimensions for $final_image. Skipping." >&2
                return
            fi

            width=$(echo $dimensions | cut -d 'x' -f 1)
            height=$(echo $dimensions | cut -d 'x' -f 2)

            if ! [[ "$width" =~ ^[0-9]+$ ]] || ! [[ "$height" =~ ^[0-9]+$ ]]; then
                echo "Error: Invalid dimensions ($dimensions) for $final_image. Skipping." >&2
                return
            fi

            echo "Image dimensions: ${width}x${height}" >&2

            # Check if the image is horizontal or vertical
            if [ "$width" -gt "$height" ]; then
                echo "Image is horizontal." >&2
                gravity="SouthEast"
                resize=$poster_resize
                offset_x=100
            else
                echo "Image is vertical." >&2
                gravity="SouthWest"
                resize=$vertical_resize
            fi

            # Check if it is a thumb or folder.jpg
            if [ "$type" == "thumb" ]; then
                echo "Image type is thumb." >&2
                gravity="SouthWest"
                offset_x=150
            fi

            # Resize the poster image (without cropping)
            magick "$final_image" -resize "$resize" "$final_image"

            for flag_file in "${flag_files[@]}"; do
                if [ -f "$OVERLAY_DIR/$flag_file" ]; then
                    echo "Adding flag: $flag_file to image: $final_image" >&2

                    magick "$final_image" \
                        \( -density $flag_width "$OVERLAY_DIR/$flag_file" -resize "${flag_width}x${flag_height}" \) \
                        -gravity ${gravity} -geometry +${offset_x}+${offset_y} -composite \
                        "$final_image"

                    chmod 644 "$final_image" || echo "Warning: Unable to change permissions for $final_image" >&2
                    chown nobody "$final_image" 2>/dev/null || echo "Warning: Unable to change ownership for $final_image" >&2
                    [ -f folder.jpg_exiftool_tmp ] && rm folder.jpg_exiftool_tmp -f
                    echo "-> Added $flag_file to $(pwd)/$final_image" >&2

                    if command -v exiftool >/dev/null 2>&1; then
                        exiftool -creatortool="$CUSTOM_CREATOR_TOOL" -overwrite_original "$final_image" 1>/dev/null
                    else
                        echo "Error: exiftool not found. Skipping metadata update." >&2
                    fi

                    if [[ "$resize" == "$poster_resize" ]]; then
                        offset_x=$((offset_x + flag_width))
                    else
                        offset_y=$((offset_y + flag_height))
                    fi
                else
                    echo "Flag file $flag_file not found in $OVERLAY_DIR." >&2
                fi
            done
        else
            echo "Image file $final_image not found." >&2
        fi
    else
        echo "creatortool matches CUSTOM_CREATOR_TOOL. Skipping overlay application." >&2
    fi
    echo "Finished add_overlay for image: $1, type: $2" >&2
}

# Function to wait for nfo and process the image
wait_for_nfo_and_process() {
    local content_path="$1"
    local is_all_mode="$2" # Pass "true" if running in "all" mode
    echo "Checking for movie.nfo or tvshow.nfo in $content_path..." >&2

    # Check if there are no .mkv files in the folder
    if ! find "$content_path" -maxdepth 1 -type f -name '*.mkv' | grep -q .; then
        echo "========================================" >&2
        echo "WARNING: No .mkv file found in $content_path." >&2
        echo "THIS FOLDER WILL BE MOVED TO $A_BORRAR_DIR." >&2
        echo "========================================" >&2

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
            echo "Timeout reached while waiting for .nfo files in $content_path." >&2
            return
        fi
    done

    if [ -f "$content_path/movie.nfo" ]; then
        echo "movie.nfo found in $content_path! Identified as a movie." >&2
        local mkv_file="${radarr_moviefile_path:-$(find "$content_path" -maxdepth 1 -type f -name '*.mkv' | head -n 1)}"
        if [ -z "$mkv_file" ] || [ ! -f "$mkv_file" ]; then
            echo "Error: No valid .mkv file found for the movie in $content_path." >&2
            return
        fi

        get_languages "$mkv_file"

        if [ "$is_all_mode" == "true" ]; then
            # Process folder.jpg and backdrop.jpg if they exist, without waiting
            [ -f "$content_path/folder.jpg" ] && add_overlay "$content_path/folder.jpg" "folder" || echo "Skipping: folder.jpg not found in $content_path." >&2
            [ -f "$content_path/backdrop.jpg" ] && add_overlay "$content_path/backdrop.jpg" "backdrop" || echo "Skipping: backdrop.jpg not found in $content_path." >&2
        else
            # Wait for folder.jpg and backdrop.jpg with a timeout
            elapsed=0
            while [ ! -f "$content_path/folder.jpg" ] || [ ! -f "$content_path/backdrop.jpg" ]; do
                echo "Waiting for folder.jpg and backdrop.jpg in $content_path..." >&2
                sleep 1
                elapsed=$((elapsed + 1))
                if [ "$elapsed" -ge "$timeout" ]; then
                    echo "Timeout reached while waiting for folder.jpg or backdrop.jpg in $content_path." >&2
                    return
                fi
            done

            if [ -f "$content_path/folder.jpg" ]; then
                add_overlay "$content_path/folder.jpg" "folder"
            else
                echo "Error: folder.jpg not found in $content_path." >&2
            fi

            if [ -f "$content_path/backdrop.jpg" ]; then
                add_overlay "$content_path/backdrop.jpg" "backdrop"
            else
                echo "Error: backdrop.jpg not found in $content_path." >&2
            fi
        fi
    elif [ -f "$content_path/tvshow.nfo" ]; then
        echo "tvshow.nfo found in $content_path! Identified as a series." >&2
        # Add series-specific processing logic here if needed
    fi
}

# Function to process all movies or series in a base directory
process_all() {
    local movies_dir="$1"
    local series_dir="$2"
    echo "Processing all movies in $movies_dir and all series in $series_dir..." >&2

    # Process movies
    for dir in "$movies_dir"/*/; do
        if [ -d "$dir" ]; then
            echo "Processing movie directory: $dir" >&2
            wait_for_nfo_and_process "$dir" "true"
        fi
    done

    # Process series
    # for dir in "$series_dir"/*/; do
    #     if [ -d "$dir" ]; then
    #         echo "Processing series directory: $dir" >&2
    #         wait_for_nfo_and_process "$dir" "true"
    #     fi
    # done

    wait # Wait for all background processes to finish
    echo "Finished processing all directories in $movies_dir and $series_dir." >&2
}

# Function to handle Radarr or Sonarr events
process_radarr_sonarr_event() {
    if [ -n "$radarr_eventtype" ]; then
        echo "Source: Radarr" >&2
        echo "Radarr Event Type: $radarr_eventtype" >&2
        if [ -n "$radarr_movie_path" ]; then
            wait_for_nfo_and_process "$radarr_movie_path" "false"
        fi
    elif [ -n "$sonarr_eventtype" ]; then
        echo "Source: Sonarr" >&2
        echo "Sonarr Event Type: $sonarr_eventtype" >&2
        if [ -n "$sonarr_series_path" ]; then
            wait_for_nfo_and_process "$sonarr_series_path" "false"
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
            echo "Deleting cache directory: $dir" >&2
            rm -rf "$dir"
            echo "Cache directory $dir deleted." >&2
        else
            echo "Cache directory $dir does not exist. Skipping." >&2
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
echo "Number of instances of $script_name running: $instance_count" >&2

# Main logic
if [ "$1" == "all" ]; then
    process_all "$MOVIES_DIR" "$SERIES_DIR"
    cleanup_jellyfin_cache
else
    process_radarr_sonarr_event
    cleanup_jellyfin_cache
fi

# Log successful execution to stdout
echo "Script executed successfully." >&1
