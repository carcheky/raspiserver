#!/bin/bash

# Directorios: asegúrate de que estas rutas estén bien configuradas.
OVERLAY_DIR="/BibliotecaMultimedia/flags/4x3"
CUSTOM_CREATOR_TOOL=235334
CUSTOM_CREATOR_TOOL=$(date)

# Dependencias
function install_deps() {
    # Lista de paquetes a verificar
    PACKAGES=("libimage-exiftool-perl" "jq" "ffmpeg" "imagemagick" "inotify-tools")

    # Filtra solo los paquetes que faltan
    MISSING_PACKAGES=()
    for pkg in "${PACKAGES[@]}"; do
        dpkg -s "$pkg" &>/dev/null || MISSING_PACKAGES+=("$pkg")
    done

    # Si hay paquetes faltantes, actualiza e instálalos
    if [ ${#MISSING_PACKAGES[@]} -gt 0 ]; then
        echo "Instalando paquetes faltantes: ${MISSING_PACKAGES[*]}"
        apt update && apt install -y "${MISSING_PACKAGES[@]}"
    else
        echo "Todos los paquetes ya están instalados."
    fi
}

# Función para aplicar el overlay sobre la imagen (thumb o folder.jpg)
function add_overlay() {
    if [ "${creatortool}" != "$CUSTOM_CREATOR_TOOL" ]; then
        local final_image="$1"
        local type="$2"
        offset_x=0
        offset_y=0
        increment_x=400 # Ajusta según lo necesites
        increment_y=300   # Ajusta según lo necesites
        gravity="SouthWest"
        resize=1920x2880
        if [ "$type" == "serie" ]; then
            gravity="South"
            resize=1920x1080
        fi
        for flag_file in "${flag_files[@]}"; do
            if [ -f "$OVERLAY_DIR/$flag_file" ]; then
                if [ -f "$final_image" ]; then
                    convert "$final_image" -resize ${resize}^ -gravity center -extent ${resize} tmp_thumb && mv tmp_thumb "$final_image"

                    convert "$final_image" \
                        \( -density $increment_x "$OVERLAY_DIR/$flag_file" -resize "${increment_x}x${increment_y}" \) \
                        -gravity ${gravity} -geometry +${offset_x}+${offset_y} -composite \
                        "$final_image"

                    chmod 644 "$final_image"
                    chown nobody "$final_image"
                    [ -f folder.jpg_exiftool_tmp ] && rm folder.jpg_exiftool_tmp -f
                    echo "-> añadiendo $flag_file a $(pwd)/$final_image (offset: ${offset_x}x${offset_y})" && exiftool -creatortool="$CUSTOM_CREATOR_TOOL" -overwrite_original "$final_image" 1>/dev/null
                    # exiftool -creatortool="$CUSTOM_CREATOR_TOOL" -overwrite_original "$final_image" -v
                        # offset_x=$((offset_x + increment_x))
                    if [[ "$type" == "serie" ]]; then
                        offset_x=$((offset_x + increment_x))
                    else
                        offset_y=$((offset_y + increment_y))
                    fi
                fi
            fi
        done
    fi
}

# Función para extraer los idiomas disponibles del archivo .mkv usando ffprobe.
# Asegúrate de tener ffprobe instalado (si no, ¡instálalo y que siga la fiesta!).
function get_languages() {
    local video_file="$1"
    # Extrae todos los idiomas de las pistas de audio, ordena y quita duplicados.
    langs=$(ffprobe "$video_file" -show_entries stream=index:stream_tags=language -select_streams a -v 0 -of json=c=1 | jq --raw-output '.streams[].tags.language')
    mapfile -t langs < <(ffprobe "$video_file" -show_entries stream_tags=language -select_streams a -v 0 -of json | jq --raw-output '.streams[].tags.language' | sort -u)
    # Mapa de conversión de ISO 639-3 a ISO 639-1
    declare -A map
    map=(
        ["spa"]="es.svg"
        ["eng"]="gb.svg"
        ["fra"]="fr.svg"
        ["deu"]="de.svg"
        ["ita"]="it.svg"
        ["por"]="pt.svg"
        ["jpn"]="jp.svg"
    )
    flag_files=()

    for lang in "${langs[@]}"; do
        # echo $lang
        flag_files+=("${map[$lang]:-$lang}") # Si no está en el mapa, usa el código original
    done
}

# Función para identificar el tipo de contenido en la carpeta.
function check_content_type() {
    local carpeta="$(pwd)"

    if compgen -G "*.mkv" >/dev/null; then
        echo "pelicula"
        return
    else
        echo "serie"
        return
    fi

    echo "desconocido"
}


function run_on_dir() {
    cd "$OVERLAY_DIR" || exit
    cd "$MOVIES_DIR" || exit
    for dir in */; do
        cd "$MOVIES_DIR/$dir" || continue
        echo
        if [[ "$(check_content_type)" == "pelicula" ]]; then
            echo "PELÍCULA: $dir"
            mlink=$(readlink -f *.mkv)
            get_languages "$mlink"
            creatortool=$(exiftool -f -s3 -"creatortool" folder.jpg)
            add_overlay folder.jpg
            # for file in *.jpg; do
            # done

        elif [[ "$(check_content_type)" == "serie" ]]; then
            echo "SERIE: $dir"

            # get chapters
            mapfile -t chapters < <(find . -type f -name "*.mkv")

            for chapter in "${chapters[@]}"; do
                get_languages "$chapter"
                thumb_file="${chapter%.mkv}-thumb.jpg"
                creatortool=$(exiftool -f -s3 -"creatortool" "$thumb_file")
                if [ "${creatortool}" != "345" ]; then
                    add_overlay "$thumb_file" serie
                fi
            done

        else
            echo "No se pudo determinar el tipo de contenido en la carpeta. ¡Esto es un remix inesperado!"
        fi
        # Volvemos al directorio principal para seguir la fiesta.
        cd "$MOVIES_DIR" || exit
    done

}

function watch_folder() {
    DIR="$1"
    EXTENSION="jpg" # Extensiones de imágenes que te interesan

    inotifywait -m -e close_write --format "%w%f" "$DIR" | while read filepath; do
        # Filtrar solo imágenes
        if [[ "$filepath" =~ \.($EXTENSION)$ ]]; then
            echo "Se ha modificado: $filepath"
        fi
    done
}

function full_logic() {
    sleep 180

    MOVIES_DIR="/BibliotecaMultimedia/se-borraran"
    # run_on_dir
    watch_folder $MOVIES_DIR &

    MOVIES_DIR="/BibliotecaMultimedia/Peliculas/"
    # run_on_dir
    watch_folder $MOVIES_DIR &

    MOVIES_DIR="/BibliotecaMultimedia/Series"
    # run_on_dir
    watch_folder $MOVIES_DIR &

}


resize_all_flags() {
    for flag_file in "$OVERLAY_DIR/*.svg"; do
        convert -verbose "$flag_file" -resize 400x300! "$flag_file" 
            # echo  "$OVERLAY_DIR/$flag_file" -resize 400x300^ "$OVERLAY_DIR/$flag_file"
    done
}

install_deps

function test() {
    resize_all_flags


    MOVIES_DIR="/BibliotecaMultimedia/se-borraran"
    run_on_dir
    # watch_folder $MOVIES_DIR
}

test

# full_logic &
