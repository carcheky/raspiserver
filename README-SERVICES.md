# MediaCheky - Configuración de Servicios

## Estructura del Proyecto

El proyecto está estructurado para permitir una gestión modular y eficiente de los servicios Docker:

- **docker-compose.yml**: Archivo principal que incluye los servicios individuales
- **services/**: Directorio que contiene archivos YAML organizados por categorías
  - **multimedia/**: Servicios de entretenimiento (Jellyfin, Radarr, Sonarr, etc.)
  - **network/**: Servicios de red (NordVPN, Proxy, etc.)
  - **automation/**: Servicios de automatización (Home Assistant, N8N, etc.)
  - **productivity/**: Servicios de productividad (Nextcloud, Code, etc.)
  - **management/**: Servicios de gestión (Portainer, Dockge, etc.)
  - **others/**: Otros servicios (Watchtower, etc.)
- **volumes/**: Almacenamiento persistente para los servicios
- **config/**: Directorio para archivos de configuración
- **media/**: Directorio para archivos multimedia
- **data/**: Directorio para datos persistentes
- **.env**: Archivo de configuración con variables de entorno (copiar desde .env.dist)

## Variables de Entorno

Se han estandarizado las variables de entorno para facilitar la configuración:

- **CONFIG_DIR**: Directorio para archivos de configuración
- **MEDIA_DIR**: Directorio para archivos multimedia
- **DATA_DIR**: Directorio para datos persistentes
- **VOLUMES_DIR**: Directorio para volúmenes Docker

Además, cada servicio tiene variables específicas para configurar sus puertos, por ejemplo:
- **JELLYFIN_PORT**: Puerto para el servicio Jellyfin
- **SONARR_PORT**: Puerto para el servicio Sonarr

## Cómo utilizar

### Configuración Inicial

1. Copia el archivo `.env.dist` a `.env` y edita las variables según tu configuración:
   ```
   cp .env.dist .env
   nano .env
   ```

2. Edita el archivo `docker-compose.yml` y descomenta los servicios que desees activar.

3. Para probar un conjunto reducido de servicios, puedes utilizar:
   ```
   docker compose -f docker-compose-test.yml up -d
   ```

### Servicios Disponibles

#### Servicios Principales
- **homeassistant**: Sistema de automatización del hogar
- **mqtt**: Broker para comunicación IoT
- **jellyfin**: Servidor multimedia
- **jellyseerr**: Gestor de peticiones de contenido
- **bazarr**: Gestor de subtítulos
- **homarr**: Dashboard de servicios
- **adguard**: Bloqueador de publicidad y DNS
- **nextcloud**: Nube personal
- **wireward**: Cliente VPN WireGuard

#### Servicios de Torrents
- **sonarr**: Gestor de series
- **radarr**: Gestor de películas
- **prowlarr**: Indexador de torrents
- **transmission**: Cliente de torrents

#### Servicios Opcionales
- **wizarr**: Gestor de invitaciones para Jellyfin
- **readarr**: Gestor de libros electrónicos
- **mylar3**: Gestor de cómics
- **lidarr**: Gestor de música
- **janitorr**: Mantenimiento y limpieza
- **esphome**: Firmware para dispositivos ESP8266/ESP32
- **romassistant**: Asistente de habitación

#### Servicios Experimentales
- **activepieces**: Automatizaciones
- **authelia**: Autenticación
- **n8n**: Flujos de trabajo
- **plex**: Servidor multimedia alternativo
- **netdata**: Monitoreo del sistema
- **pihole**: DNS con bloqueo de publicidad
- **portainer**: Gestor de Docker
- **telegram**: Notificaciones de Jellyfin
- **thingsboard**: IoT Platform

#### Utilidades
- **nordvpn**: Cliente VPN
- **watchtower**: Actualización automática de contenedores
- **code**: Servidor VS Code

## Iniciar Servicios

Para iniciar los servicios:

```bash
docker-compose up -d
```

## Detener Servicios

Para detener los servicios:

```bash
docker-compose down
```

## Actualizar Servicios

Para actualizar los servicios:

```bash
docker-compose pull
docker-compose up -d
```

## Monitorizar Logs

Para ver los logs de un servicio específico:

```bash
docker-compose logs -f nombre_servicio
```

## Personalizar Servicios

Si necesitas personalizar un servicio, puedes modificar su archivo correspondiente en `services/categoria/`.

Cada servicio está definido en su propio archivo para facilitar la gestión y mantenimiento.
