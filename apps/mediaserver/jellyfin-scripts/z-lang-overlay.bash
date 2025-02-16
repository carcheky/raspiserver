#!/bin/bash

if not find command -v exiftool; then
    apt update
    apt install -y libimage-exiftool-perl jq ffmpeg imagemagick
fi
clear
# Directorios: asegúrate de que estas rutas estén bien configuradas.
MOVIES_DIR="/BibliotecaMultimedia/se-borraran"
OVERLAY_DIR="/BibliotecaMultimedia/overlay"
cd "$OVERLAY_DIR" || exit
cd "$MOVIES_DIR" || exit

# Función para aplicar el overlay sobre la imagen (thumb o folder.jpg)
function add_overlay() {
    local final_image="$1"
    local flag_file="$2"
    offset_x=0
    offset_y=0
    increment_x=200 # Ajusta según lo necesites
    increment_y=0   # Ajusta según lo necesites

    for flag_file in "${flag_files[@]}"; do
        if [ -f "$OVERLAY_DIR/$flag_file" ]; then

            # echo "Aplicando overlay $flag_file a $final_image"
            convert "$final_image" \
                \( "$OVERLAY_DIR/$flag_file" -resize 200x200 \) \
                -gravity SouthWest -geometry +${offset_x}+${offset_y} -composite \
                "$final_image"
            echo "convert $final_image -resize 200x200 $OVERLAY_DIR/$flag_file -gravity SouthWest -geometry +${offset_x}+${offset_y} -composite $final_image"
            chmod 644 "$final_image"
            chown nobody "$final_image"
            exiftool -creatortool="languageaddedbycarcheky" -overwrite_original "$final_image"
            offset_x=$((offset_x + increment_x))
            offset_y=$((offset_y + increment_y))
        fi
    done

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
        ["eng"]="en"
        ["spa"]="es"
        ["fra"]="fr"
        ["deu"]="de"
        ["ita"]="it"
        ["por"]="pt"
    )
    flag_files=()

    # Recorrer los idiomas y generar nombres de archivos
    for lang in "${langs[@]}"; do
        flag_files+=("${map[$lang]:-$lang}.svg") # Si no está en el mapa, usa el código original
    done

    # Imprimir el array de archivos
    # echo "Archivos de banderas: ${flag_files[@]}"

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

function full_logic() {
    for dir in */; do
        cd "$MOVIES_DIR/$dir" || continue
        if [[ "$(check_content_type)" == "pelicula" ]]; then
            echo "PELÍCULA: $dir"
            mlink=$(readlink -f *.mkv)
            get_languages "$mlink"
            for file in *.jpg; do
                creatortool=$(exiftool -f -s3 -"creatortool" "$file")
                if [ "${creatortool}" != "languageaddedbycarcheky" ]; then
                    add_overlay $file
                fi
            done

        elif [[ "$(check_content_type)" == "serie" ]]; then
            echo "SERIE: $dir"

            # get chapters
            mapfile -t chapters < <(find . -type f -name "*.mkv")
            echo "Archivos generados:"
            printf "%s\n" "${chapters[@]}"

            for chapter in "${chapters[@]}"; do
                get_languages "$chapter"
                thumb_file="${chapter%.mkv}-thumb.jpg"
                add_overlay "$thumb_file"
            done

            

            # | while read -r file; do
            #     # replace .mkv with -thumb.jpg
            #     file="${file%.mkv}-thumb.jpg"
            #     get_languages "$file"
            #     add_overlay "$file"
            # done
        else
            echo "No se pudo determinar el tipo de contenido en la carpeta. ¡Esto es un remix inesperado!"
        fi
        # Volvemos al directorio principal para seguir la fiesta.
        cd "$MOVIES_DIR" || exit
        echo
    done

}

full_logic
