#!/bin/bash

set -euo pipefail

# Constants
OVERLAY_DIR="/flags/4x3/"
MOVIES_DIR="/BibliotecaMultimedia/Peliculas/"
CUSTOM_CREATOR_TOOL="carcheky"
flag_width=400
flag_height=300
LOG_FILE="/config/logs/z-lang-overlay.log"

# Ensure log directory exists
mkdir -p "$(dirname "$LOG_FILE")"
touch "$LOG_FILE"

# Logging function
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Dependency installation
install_deps() {
    log_message "Entering function: install_deps"
    log_message "Starting dependency installation."
    log_message "Checking for missing dependencies..."
    local PACKAGES=("libimage-exiftool-perl" "jq" "imagemagick" "ffmpeg" "inkscape" "librsvg2-bin")
    local MISSING_PACKAGES=()

    for pkg in "${PACKAGES[@]}"; do
        if ! dpkg -s "$pkg" &>/dev/null; then
            log_message "Dependency missing: $pkg"
            MISSING_PACKAGES+=("$pkg")
        fi
    done

    if [ ${#MISSING_PACKAGES[@]} -gt 0 ]; then
        log_message "Installing missing packages: ${MISSING_PACKAGES[*]}"
        
        # Verificar permisos de root
        if [ "$EUID" -ne 0 ]; then
            log_message "Error: Script must be run as root to install dependencies."
            exit 1
        fi

        # Intentar instalar dependencias y capturar errores
        if ! apt update && apt install -y "${MISSING_PACKAGES[@]}"; then
            log_message "Error: Failed to install dependencies. Check your network connection or package manager configuration."
            exit 1
        fi
    else
        log_message "All dependencies are already installed."
    fi
    log_message "Dependency installation completed."
    log_message "Exiting function: install_deps"
}

# Overlay application
add_overlay() {
    local final_image="$1" type="$2"
    log_message "Starting overlay process for $final_image (type: $type)."

    if [ "${creatortool}" == "$CUSTOM_CREATOR_TOOL" ]; then
        log_message "Skipping $final_image: already processed by $CUSTOM_CREATOR_TOOL."
        return
    fi

    if [ -f "$final_image" ]; then
        log_message "File $final_image exists. Preparing to apply overlays."
        local dimensions=$(identify -format "%wx%h" "$final_image")
        local width=$(echo $dimensions | cut -d 'x' -f 1)
        local height=$(echo $dimensions | cut -d 'x' -f 2)
        log_message "Image dimensions: ${width}x${height}."

        local gravity="SouthEast" resize="2560x1440" offset_x=100 offset_y=0
        [ "$width" -le "$height" ] && gravity="SouthWest" resize="1920x2880"
        [ "$type" == "thumb" ] && gravity="SouthWest" offset_x=150

        for flag_file in "${flag_files[@]}"; do
            if [ -f "$OVERLAY_DIR/$flag_file" ]; then
                log_message "Applying flag $flag_file to $final_image with gravity $gravity and offsets (${offset_x}, ${offset_y})."
                convert "$final_image" -resize ${resize}^ -gravity center -extent ${resize} tmp_thumb && mv tmp_thumb "$final_image"
                convert "$final_image" \
                    \( -density $flag_width "$OVERLAY_DIR/$flag_file" -resize "${flag_width}x${flag_height}" \) \
                    -gravity ${gravity} -geometry +${offset_x}+${offset_y} -composite "$final_image"
                chmod 644 "$final_image"
                chown nobody "$final_image"
                exiftool -creatortool="$CUSTOM_CREATOR_TOOL" -overwrite_original "$final_image" &>/dev/null
                log_message "Successfully applied flag $flag_file to $final_image."
                [ "$resize" == "2560x1440" ] && offset_x=$((offset_x + flag_width)) || offset_y=$((offset_y + flag_height))
            else
                log_message "Flag file $flag_file not found in $OVERLAY_DIR. Skipping."
            fi
        done
    else
        log_message "File $final_image does not exist. Skipping overlay process."
    fi
    log_message "Finished overlay process for $final_image."
}

# Language extraction
get_languages() {
    local video_file="$1"
    log_message "Extracting languages from $video_file."

    # Log the raw output of ffprobe for debugging
    local ffprobe_output
    ffprobe_output=$(ffprobe "$video_file" -show_entries stream_tags=language -select_streams a -v 0 -of json 2>&1)
    log_message "ffprobe output: $ffprobe_output"

    # Extract languages and log them
    mapfile -t langs < <(echo "$ffprobe_output" | jq --raw-output '.streams[].tags.language' | sort -u)
    log_message "Languages detected: ${langs[*]}"

    declare -A map=(["spa"]="es.svg" ["eng"]="gb.svg" ["fra"]="fr.svg" ["deu"]="de.svg" ["ita"]="it.svg" ["por"]="pt.svg" ["jpn"]="jp.svg" ["ara"]="ae.svg" ["rus"]="ru.svg" ["chi"]="cn.svg" ["kor"]="kr.svg" ["dut"]="nl.svg" ["pol"]="pl.svg" ["swe"]="se.svg" ["fin"]="fi.svg" ["nor"]="no.svg" ["dan"]="dk.svg" ["tur"]="tr.svg" ["hin"]="in.svg" ["bel"]="be.svg")
    flag_files=()

    for lang in "${langs[@]}"; do
        flag_files+=("${map[$lang]:-$lang}")
    done
    log_message "Flag files to apply: ${flag_files[*]}"
}

# Content type check
check_content_type() {
    log_message "Checking content type in directory $(pwd)."
    if [ "$(find . -maxdepth 1 -type f -name '*.mkv' | wc -l)" -gt 0 ]; then
        echo "movie"
    else
        echo "unknown"
    fi
}

# Directory processing
run_on_dir() {
    log_message "Processing directory: $MOVIES_DIR."
    cd "$MOVIES_DIR" || { log_message "Error: Failed to change directory to $MOVIES_DIR."; return 1; }

    for dir in */; do
        log_message "Processing subdirectory: $dir."
        cd "$MOVIES_DIR/$dir" || { log_message "Error: Failed to change directory to $MOVIES_DIR/$dir."; continue; }

        local content_type
        content_type=$(check_content_type)
        log_message "Content type detected: $content_type."

        if [ "$content_type" == "movie" ]; then
            log_message "Processing movie: $dir."
            local mlink
            mlink=$(readlink -f *.mkv 2>/dev/null) || { log_message "Error: No .mkv file found in $dir."; continue; }
            log_message "Found movie file: $mlink"
            get_languages "$mlink" || { log_message "Error: Failed to extract languages from $mlink."; continue; }
            creatortool=$(exiftool -f -s3 -"creatortool" folder.jpg 2>/dev/null || echo "") 
            add_overlay folder.jpg "folder" || log_message "Error: Failed to add overlay to folder.jpg."
            add_overlay backdrop.jpg "backdrop" || log_message "Error: Failed to add overlay to backdrop.jpg."
        else
            log_message "Skipping subdirectory $dir due to unknown content type."
        fi
        cd "$MOVIES_DIR" || { log_message "Error: Failed to return to $MOVIES_DIR."; return 1; }
    done
    log_message "Finished processing directory: $MOVIES_DIR."
}

# Resize flag images
resize_all_flags() {
    log_message "Entering function: resize_all_flags"
    log_message "Starting flag resizing in $OVERLAY_DIR."

    # Check if resizing is already done
    if [ -f "$OVERLAY_DIR/resized" ]; then
        log_message "Flag images already resized. Skipping resizing step."
        log_message "Exiting function: resize_all_flags"
        return
    fi

    if [ ! -d "$OVERLAY_DIR" ] || [ -z "$(ls -A "$OVERLAY_DIR"/*.svg 2>/dev/null)" ]; then
        log_message "Error: No flag files found in $OVERLAY_DIR. Ensure the directory contains valid .svg files."
        log_message "Exiting function: resize_all_flags"
        return 1
    fi

    log_message "Resizing all flag images in $OVERLAY_DIR."
    for flag_file in "$OVERLAY_DIR"/*.svg; do
        if [ -f "$flag_file" ]; then
            log_message "Resizing flag: $flag_file"
            convert -verbose "$flag_file" -resize "${flag_width}x${flag_height}!" "$flag_file"
        else
            log_message "Warning: Flag file $flag_file not found."
        fi
    done

    # Mark resizing as completed
    touch "$OVERLAY_DIR/resized"
    log_message "Flag images resized successfully."
    log_message "Exiting function: resize_all_flags"
}

# Main logic
full_logic() {
    log_message "Entering function: full_logic"
    log_message "Starting main logic loop."
    sleep 1
    resize_all_flags || { log_message "Error: Failed to resize flag images."; exit 1; }

    while true; do
        for MOVIES_DIR in "/BibliotecaMultimedia/se-borraran" "/BibliotecaMultimedia/Peliculas/" "/BibliotecaMultimedia/Series"; do
            if [ -d "$MOVIES_DIR" ]; then
                log_message "Processing directory: $MOVIES_DIR."
                run_on_dir || log_message "Error: Failed to process directory $MOVIES_DIR."
            else
                log_message "Warning: $MOVIES_DIR does not exist. Skipping..."
            fi
        done
        log_message "Main logic loop iteration completed. Sleeping for 1 day."
        sleep 1d || { log_message "Error: Sleep interrupted."; exit 1; }
    done
    log_message "Exiting function: full_logic"
}

# Cleanup on interruption
trap "log_message 'Script interrupted. Cleaning up...'; exit 1" SIGINT SIGTERM

# Start script
log_message "Script execution started."
install_deps
log_message "Dependencies installed successfully."
full_logic &
