#!/bin/bash

# Customizable variables
CUSTOM_CREATOR_TOOL=$(date) # Default to current date
OVERLAY_DIR="/flags/4x3" # Directory containing overlay flag files
flag_width=400 # Width of the flag overlay (updated to match z-lang-overlay)
flag_height=300 # Height of the flag overlay (updated to match z-lang-overlay)
poster_resize="2560x1440" # Resize dimensions for horizontal posters
vertical_resize="1920x2880" # Resize dimensions for vertical posters
TMP_DIR="/tmp/lang-flags" # Temporary directory for intermediate files

# Ensure the temporary directory exists
mkdir -p "$TMP_DIR"

# Check and install dependencies
install_deps() {
    echo "Script is running as user: $(whoami), group: $(id -gn)" >&2
    local packages=("perl-image-exiftool" "jq" "imagemagick" "ffmpeg" "inkscape" "rsvg-convert")
    local script_dir="/custom-cont-init.d"
    local script_file="$script_dir/lang_flags-install_deps.sh"

    mkdir -p "$script_dir"

    if [ ! -f "$script_file" ]; then
        {
            echo "#!/bin/bash"
            echo "apk update && apk add --no-cache ${packages[*]}"
        } >"$script_file"

        chmod +x "$script_file"
        echo "Dependency installation script created at $script_file" >&2
    fi
}

install_deps

# Print the number of instances of this script currently running
script_name=$(basename "$0")
instance_count=$(pgrep -fc "$script_name")
echo "Number of instances of $script_name running: $instance_count" >&2

# Identify source (Radarr or Sonarr) and log environment variables
if [ -n "$radarr_eventtype" ]; then
    echo "Source: Radarr" >&2
    echo "Radarr Event Type: $radarr_eventtype" >&2
    echo "Radarr Download ID: $radarr_download_id" >&2
    echo "Radarr Download Client: $radarr_download_client" >&2
    echo "Radarr Is Upgrade: $radarr_isupgrade" >&2
    echo "Radarr Movie ID: $radarr_movie_id" >&2
    echo "Radarr Movie IMDb ID: $radarr_movie_imdbid" >&2
    echo "Radarr Movie Title: $radarr_movie_title" >&2
    echo "Radarr Movie Year: $radarr_movie_year" >&2
    echo "Radarr Movie Path: $radarr_movie_path" >&2
    echo "Radarr Movie File Path: $radarr_moviefile_path" >&2
    echo "Radarr Movie File Quality: $radarr_moviefile_quality" >&2
    echo "Radarr Movie File Release Group: $radarr_moviefile_releasegroup" >&2
elif [ -n "$sonarr_eventtype" ]; then
    echo "Source: Sonarr" >&2
    echo "Sonarr Event Type: $sonarr_eventtype" >&2
    echo "Sonarr Is Upgrade: $sonarr_isupgrade" >&2
    echo "Sonarr Series ID: $sonarr_series_id" >&2
    echo "Sonarr Series Title: $sonarr_series_title" >&2
    echo "Sonarr Series Path: $sonarr_series_path" >&2
    echo "Sonarr Series TVDB ID: $sonarr_series_tvdbid" >&2
    echo "Sonarr Series TVMaze ID: $sonarr_series_tvmazeid" >&2
    echo "Sonarr Series IMDB ID: $sonarr_series_imdbid" >&2
    echo "Sonarr Series Type: $sonarr_series_type" >&2
    echo "Sonarr Series Year: $sonarr_series_year" >&2
    echo "Sonarr Episode File ID: $sonarr_episodefile_id" >&2
    echo "Sonarr Episode File Path: $sonarr_episodefile_path" >&2
    echo "Sonarr Episode File Quality: $sonarr_episodefile_quality" >&2
    echo "Sonarr Episode File Release Group: $sonarr_episodefile_releasegroup" >&2
else
    echo "Error: Neither Radarr nor Sonarr event detected." >&2
    exit 1
fi

sleep 5

# Check if radarr_eventtype is set to "Test"
if [ "${radarr_eventtype}" == "Test" ]; then
    echo "Test event detected. Script executed successfully." >&1
    exit 0
fi

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
function add_overlay() {
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

    if [ "${creatortool}" != "$CUSTOM_CREATOR_TOOL" ]; then
        offset_x=0
        offset_y=0
        if [ -f "$final_image" ]; then
            echo "Processing image: $final_image" >&2

            dimensions=$(identify -format "%wx%h" "$final_image")
            width=$(echo $dimensions | cut -d 'x' -f 1)
            height=$(echo $dimensions | cut -d 'x' -f 2)
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
        echo "Creator tool matches $CUSTOM_CREATOR_TOOL, skipping overlay." >&2
    fi
    echo "Finished add_overlay for image: $1, type: $2" >&2
}

# Function to wait for nfo and process the image
wait_for_nfo_and_process() {
    local movie_path="$1"
    echo "Checking for movie.nfo or tvshow.nfo in $movie_path..." >&2

    while [ ! -f "$movie_path/movie.nfo" ] && [ ! -f "$movie_path/tvshow.nfo" ]; do
        sleep 1
    done

    if [ -f "$movie_path/movie.nfo" ]; then
        echo "movie.nfo found in $movie_path! Identified as a movie." >&2
        local mkv_file="$radarr_moviefile_path"
        if [ -z "$mkv_file" ] || [ ! -f "$mkv_file" ]; then
            echo "Error: No valid .mkv file found for the movie." >&2
            return
        fi

        while [ ! -f "$movie_path/folder.jpg" ] || [ ! -f "$movie_path/backdrop.jpg" ]; do
            echo "Waiting for folder.jpg and backdrop.jpg in $movie_path..." >&2
            sleep 1
        done

        get_languages "$mkv_file"

        if [ -f "$movie_path/folder.jpg" ]; then
            add_overlay "$movie_path/folder.jpg" "folder"
        else
            echo "Error: folder.jpg not found in $movie_path." >&2
        fi

        if [ -f "$movie_path/backdrop.jpg" ]; then
            add_overlay "$movie_path/backdrop.jpg" "backdrop"
        else
            echo "Error: backdrop.jpg not found in $movie_path." >&2
        fi
    elif [ -f "$movie_path/tvshow.nfo" ]; then
        echo "tvshow.nfo found in $movie_path! Identified as a series." >&2
        # Add series-specific processing logic here if needed
    fi
}

# Launch a background process for each movie folder
if [ -n "$radarr_movie_path" ]; then
    wait_for_nfo_and_process "$radarr_movie_path" &
fi

# Log successful execution to stdout
echo "Script executed successfully." >&1
