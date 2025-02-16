#!/bin/bash

# Verificar si exiftool está instalado, si no, instalar dependencias
# if ! command -v jq &>/dev/null; then
apt update && apt install -y libimage-exiftool-perl jq ffmpeg imagemagick
# fi

# Directorios: asegúrate de que estas rutas estén bien configuradas.
OVERLAY_DIR="/BibliotecaMultimedia/flags/4x3"

# Función para aplicar el overlay sobre la imagen (thumb o folder.jpg)
function add_overlay() {
    if [ "${creatortool}" != "52524" ]; then
        local final_image="$1"
        local type="$2"
        offset_x=0
        offset_y=0
        increment_x=300 # Ajusta según lo necesites
        increment_y=0   # Ajusta según lo necesites
        gravity="SouthWest"
        resize=1920x2880
        if [ "$type" == "serie" ]; then
            gravity="South"
            resize=1920x1080
        fi
        for flag_file in "${flag_files[@]}"; do
            if [ -f "$OVERLAY_DIR/$flag_file" ]; then
                convert "$final_image" -resize ${resize}^ -gravity center -extent ${resize} tmp_thumb && mv tmp_thumb "$final_image"

                convert "$final_image" \
                    \( -density 300 "$OVERLAY_DIR/$flag_file" -background none -resize "${increment_x}x${increment_x}" \) \
                    -gravity ${gravity} -geometry +${offset_x}+${offset_y} -composite \
                    "$final_image"

                chmod 644 "$final_image"
                chown nobody "$final_image"
                exiftool -creatortool="52524" -overwrite_original "$final_image"
                # echo $final_image $offset_x $offset_y
                offset_x=$((offset_x + increment_x))
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
    )
    flag_files=()

    for lang in "${langs[@]}"; do
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
        echo
    done

}

full_logic() {
    while true; do
        sleep 120

        MOVIES_DIR="/BibliotecaMultimedia/se-borraran"
        run_on_dir

        MOVIES_DIR="/BibliotecaMultimedia/Peliculas/"
        run_on_dir

        MOVIES_DIR="/BibliotecaMultimedia/Series"
        run_on_dir

        sleep 1d
    done
}

full_logic &
