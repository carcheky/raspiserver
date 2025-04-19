#!/bin/bash

set -euo pipefail

# Validate paths and variables
OVERLAY_DIR="/BibliotecaMultimedia/flags/4x3" # Directory containing flag overlay images
MOVIES_DIR="/BibliotecaMultimedia/Peliculas" # Directory to process (set dynamically in the script)
CUSTOM_CREATOR_TOOL="carcheky" # Custom identifier for processed files
flag_width=400 # Width of the flag overlay
flag_height=300 # Height of the flag overlay
LOG_FILE="/config/logs/z-lang-overlay.log" # Log file path

# Ensure the log directory exists
mkdir -p "$(dirname "$LOG_FILE")"
touch "$LOG_FILE"

# Function to log messages
function log_message() {
    local message="$1"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $message" | tee -a "$LOG_FILE"
}

# Ensure the overlay directory exists
if [ ! -d "$OVERLAY_DIR" ]; then
    log_message "Error: OVERLAY_DIR does not exist or is not a valid directory."
    exit 1
fi

if [ ! -d "$MOVIES_DIR" ]; then
    log_message "Error: MOVIES_DIR does not exist or is not a valid directory."
    exit 1
fi

# Function to install required dependencies
function install_deps() {
    # List of required packages
    PACKAGES=("libimage-exiftool-perl" "jq" "imagemagick" "ffmpeg" "inkscape" "librsvg2-bin")

    log_message "Checking and installing missing dependencies..."

    # Check for missing packages
    MISSING_PACKAGES=()
    for pkg in "${PACKAGES[@]}"; do
        dpkg -s "$pkg" &>/dev/null || MISSING_PACKAGES+=("$pkg")
    done

    # Install missing packages if any
    if [ ${#MISSING_PACKAGES[@]} -gt 0 ]; then
        log_message "Installing missing packages: ${MISSING_PACKAGES[*]}"
        apt update && apt install -y "${MISSING_PACKAGES[@]}"
    fi

    log_message "Dependencies installation completed."
}

# Function to apply the overlay to an image (e.g., thumb or folder.jpg)
function add_overlay() {
    # Skip processing if the file has already been processed
    if [ "${creatortool}" != "$CUSTOM_CREATOR_TOOL" ]; then
        local final_image="$1" # Target image file
        local type="$2" # Type of image (e.g., "thumb" or "folder.jpg")
        offset_x=0
        offset_y=0

        log_message "Applying overlay to $final_image of type $type."

        # Check if the target image exists
        if [ -f "$final_image" ]; then
            # Get image dimensions
            dimensions=$(identify -format "%wx%h" "$final_image")
            width=$(echo $dimensions | cut -d 'x' -f 1)
            height=$(echo $dimensions | cut -d 'x' -f 2)

            # Determine orientation (horizontal or vertical)
            if [ "$width" -gt "$height" ]; then
                # Horizontal image
                gravity="SouthEast"
                resize=2560x1440
                offset_x=100
            else
                # Vertical image
                gravity="SouthWest"
                resize=1920x2880
            fi

            # Adjust gravity and offset for thumbnails
            if [ "$type" == "thumb" ]; then
                gravity="SouthWest"
                offset_x=150
            fi

            # Apply overlays for each flag file
            for flag_file in "${flag_files[@]}"; do
                if [ -f "$OVERLAY_DIR/$flag_file" ]; then
                    # Resize the image to the target dimensions
                    convert "$final_image" -resize ${resize}^ -gravity center -extent ${resize} tmp_thumb && mv tmp_thumb "$final_image"

                    # Add the overlay to the image
                    convert "$final_image" \
                        \( -density $flag_width "$OVERLAY_DIR/$flag_file" -resize "${flag_width}x${flag_height}" \) \
                        -gravity ${gravity} -geometry +${offset_x}+${offset_y} -composite \
                        "$final_image"

                    # Set permissions and ownership
                    chmod 644 "$final_image"
                    chown nobody "$final_image"

                    # Clean up temporary files
                    [ -f folder.jpg_exiftool_tmp ] && rm folder.jpg_exiftool_tmp -f

                    # Add metadata to indicate the file has been processed
                    echo "-> Adding $flag_file to $(pwd)/$final_image" && exiftool -creatortool="$CUSTOM_CREATOR_TOOL" -overwrite_original "$final_image" 1>/dev/null

                    # Adjust offsets for subsequent overlays
                    if [[ "$resize" == "2560x1440" ]]; then
                        offset_x=$((offset_x + flag_width))
                    else
                        offset_y=$((offset_y + flag_height))
                    fi
                fi
            done
        fi

        log_message "Overlay applied successfully to $final_image."
    fi
}

# Function to extract available languages from an .mkv file using ffprobe
function get_languages() {
    local video_file="$1" # Input video file

    log_message "Extracting languages from $video_file."

    # Extract audio track languages, sort, and remove duplicates
    langs=$(ffprobe "$video_file" -show_entries stream=index:stream_tags=language -select_streams a -v 0 -of json=c=1 | jq --raw-output '.streams[].tags.language')
    mapfile -t langs < <(ffprobe "$video_file" -show_entries stream_tags=language -select_streams a -v 0 -of json | jq --raw-output '.streams[].tags.language' | sort -u)

    # Map ISO 639-3 codes to corresponding flag file names
    declare -A map
    map=(
        ["spa"]="es.svg"
        ["eng"]="gb.svg"
        ["fra"]="fr.svg"
        ["deu"]="de.svg"
        ["ita"]="it.svg"
        ["por"]="pt.svg"
        ["jpn"]="jp.svg"
        ["ara"]="ae.svg" # Arabic
        ["rus"]="ru.svg" # Russian
        ["chi"]="cn.svg" # Chinese
        ["kor"]="kr.svg" # Korean
        ["dut"]="nl.svg" # Dutch
        ["pol"]="pl.svg" # Polish
        ["swe"]="se.svg" # Swedish
        ["fin"]="fi.svg" # Finnish
        ["nor"]="no.svg" # Norwegian
        ["dan"]="dk.svg" # Danish
        ["tur"]="tr.svg" # Turkish
        ["hin"]="in.svg" # Hindi
        ["bel"]="be.svg" # Belgian
    )

    flag_files=()

    # Populate the list of flag files based on detected languages
    for lang in "${langs[@]}"; do
        flag_files+=("${map[$lang]:-$lang}") # Use the original code if no mapping exists
    done

    log_message "Languages extracted: ${langs[*]}."
}

# Function to determine the type of content in the current directory
function check_content_type() {
    local folder="$(pwd)" # Current directory

    log_message "Checking content type in directory $(pwd)."

    # Check for .mkv files to determine content type
    if compgen -G "*.mkv" >/dev/null; then
        echo "movie"
        return
    else
        echo "series"
        return
    fi

    echo "unknown"
}

# Function to process directories and apply overlays
function run_on_dir() {
    log_message "Processing directory: $MOVIES_DIR."

    cd "$OVERLAY_DIR" || exit
    cd "$MOVIES_DIR" || exit
    for dir in */; do
        cd "$MOVIES_DIR/$dir" || continue
        if [[ "$(check_content_type)" == "movie" ]]; then
            echo
            echo "MOVIE: $dir"
            mlink=$(readlink -f *.mkv)
            get_languages "$mlink"
            creatortool=$(exiftool -f -s3 -"creatortool" folder.jpg)
            add_overlay folder.jpg
            add_overlay backdrop.jpg

        elif [[ "$(check_content_type)" == "series" ]]; then
            echo "SERIES: $dir"

            mapfile -t chapters < <(find . -type f -name "*.mkv")

            for chapter in "${chapters[@]}"; do
                get_languages "$chapter"
                thumb_file="${chapter%.mkv}-thumb.jpg"
                creatortool=$(exiftool -f -s3 -"creatortool" "$thumb_file")

                if [ "${creatortool}" != "$CUSTOM_CREATOR_TOOL" ]; then
                    add_overlay "$thumb_file" thumb
                fi
            done

        else
            echo "Unable to determine the content type in the folder. Unexpected case!"
        fi
        cd "$MOVIES_DIR" || exit
    done

    log_message "Finished processing directory: $MOVIES_DIR."
}

# Function to resize all flag images
function resize_all_flags() {
    log_message "Resizing all flag images in $OVERLAY_DIR."

    if [ ! -f "$OVERLAY_DIR/resized" ]; then
        for flag_file in "$OVERLAY_DIR"/*.svg; do
            if [ -f "$flag_file" ]; then
                convert -verbose "$flag_file" -resize "${flag_width}x${flag_height}!" "$flag_file"
            fi
        done
        touch "$OVERLAY_DIR/resized"
    fi

    log_message "Flag images resized successfully."
}

# Main logic to process directories and apply overlays
function full_logic() {
    log_message "Starting main logic."

    sleep 300 # Initial delay to allow the system to stabilize
    resize_all_flags

    while true; do
        for MOVIES_DIR in "/BibliotecaMultimedia/se-borraran" "/BibliotecaMultimedia/Peliculas/" "/BibliotecaMultimedia/Series"; do
            if [ -d "$MOVIES_DIR" ]; then
                run_on_dir
            else
                log_message "Warning: $MOVIES_DIR does not exist. Skipping..."
            fi
        done
        log_message "Main logic completed. Sleeping for 1 day."
        sleep 1d # Wait for 1 day before the next iteration
    done
}

# Handle script interruptions and clean up
trap "log_message 'Script interrupted. Cleaning up...'; exit 1" SIGINT SIGTERM

# Start dependency installation and main logic in the background
log_message "Starting script execution."
install_deps &
full_logic &
