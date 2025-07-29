#!/bin/bash

# Script para corregir las rutas en el docker-compose.yml 
# para que apunten a la carpeta services

BASE_DIR="/home/user/mediacheky/raspiserver"
DOCKER_COMPOSE="${BASE_DIR}/docker-compose.yml"

echo "Actualizando docker-compose.yml para usar archivos de la carpeta services..."

# Buscar y reemplazar todas las rutas de apps/*/docker-compose.*.yml por services/service-*.yml
sed -i 's|apps/[^/]*/docker-compose\.\([^.]*\)\.yml|services/service-\1.yml|g' "$DOCKER_COMPOSE"

echo "Actualización completada."
