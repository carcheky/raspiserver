#!/bin/bash

# Script de debug para capturar variables de entorno de Sonarr
echo "[$(date)] === DEBUG SONARR EVENT ===" >> /flags/debug.log
echo "[$(date)] Todas las variables de entorno:" >> /flags/debug.log
env | grep -E "(sonarr|radarr)" >> /flags/debug.log
echo "[$(date)] Argumentos recibidos: $@" >> /flags/debug.log
echo "[$(date)] =============================" >> /flags/debug.log

# Llamar al script principal
bash /flags/lang-flags.bash "$@"
