#!/bin/bash
apk update && apk add --no-cache perl-image-exiftool jq imagemagick ffmpeg inkscape rsvg-convert exiftool
# Detectar automáticamente qué procesar basado en configuración de Radarr/Sonarr
if ls -f /config/radarr* >/dev/null 2>&1; then
  bash /flags/lang-flags.sh -j 1 -f movies
elif ls -f /config/sonarr* >/dev/null 2>&1; then
  bash /flags/lang-flags.sh -j 1 -f tvshows
fi
