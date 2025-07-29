#!/bin/bash

# Este script verifica que todos los servicios en las carpetas de apps
# tengan su correspondiente en la carpeta services
# Si existe, no hace nada; si no existe, lo crea

BASE_DIR="/home/user/mediacheky/raspiserver"
SERVICES_DIR="${BASE_DIR}/services"
APPS_DIR="${BASE_DIR}/apps"

# Mapeo de servicios (nombre en services : ruta en apps)
declare -A service_mapping

# Función para verificar si un servicio tiene correspondiente en services
check_service() {
  local service_name="$1"
  local apps_path="$2"
  
  # Extraer el nombre del servicio del archivo
  local service_basename=$(basename "$apps_path")
  local service_type=$(echo "$service_basename" | sed 's/docker-compose\.\(.*\)\.yml/\1/')
  
  if [ "$service_type" = "$service_basename" ]; then
    # Si no sigue el patrón docker-compose.*.yml, usar otro método
    service_type=$(grep -m 1 "container_name:" "$apps_path" | awk '{print $2}')
    
    if [ -z "$service_type" ]; then
      echo "No se pudo determinar el tipo de servicio para $apps_path"
      return
    fi
  fi
  
  local target_service="${SERVICES_DIR}/service-${service_type}.yml"
  
  if [ -f "$target_service" ]; then
    echo "✅ Servicio $service_type ya existe en services"
  else
    echo "❌ Servicio $service_type no existe en services, creando..."
    cp "$apps_path" "$target_service"
    echo "✅ Servicio $service_type creado en services"
  fi
  
  # Guardar en el mapeo
  service_mapping["service-${service_type}.yml"]="$apps_path"
}

# Función para procesar una carpeta de apps
process_apps_folder() {
  local folder="$1"
  
  if [ ! -d "$folder" ]; then
    echo "La carpeta $folder no existe"
    return
  fi
  
  echo "Procesando carpeta: $folder"
  
  for file in "$folder"/*.yml; do
    if [ -f "$file" ]; then
      check_service "$(basename "$folder")" "$file"
    fi
  done
}

# Procesar todas las carpetas en apps
for dir in "$APPS_DIR"/*; do
  if [ -d "$dir" ]; then
    process_apps_folder "$dir"
  fi
done

# Verificar si hay servicios en services que no están en el mapeo
echo -e "\nVerificando si hay servicios adicionales en services..."
for service in "$SERVICES_DIR"/*.yml; do
  if [ -f "$service" ]; then
    service_name=$(basename "$service")
    if [ -z "${service_mapping[$service_name]}" ]; then
      echo "⚠️ El servicio $service_name no tiene correspondiente en apps"
    fi
  fi
done

echo -e "\nProceso completado."
