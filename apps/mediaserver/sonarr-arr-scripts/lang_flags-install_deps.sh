#!/bin/bash
apk update && apk add --no-cache perl-image-exiftool jq imagemagick ffmpeg inkscape rsvg-convert exiftool
(
  set -x
  sleep 120
  if ls -f /config/radarr* >/dev/null 2>&1; then
    echo "Running lang-flags for Radarr"
    bash /flags/lang-flags.sh -j 1 -f movies
  elif ls -f /config/sonarr* >/dev/null 2>&1; then
    echo "Running lang-flags for Sonarr"
    bash /flags/lang-flags.sh -j 1 -f tvshows &
  fi
) &

