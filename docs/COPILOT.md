# Instrucciones para GitHub Copilot

SIEMPRE CONTESTA EN ESPAÑOL, AUNQUE LAS INSTRUCCIONES SEAN EN INGLÉS.

## Contexto del Proyecto: RaspiServer

**RaspiServer** es una plataforma integral de servidor doméstico basada en Docker que incluye:

### Tecnologías Principales:
- **Docker Compose**: Orquestación de 40+ servicios
- **YAML**: Configuraciones de servicios
- **Shell Scripting**: Automatización (especialmente `flags/lang-flags.bash`)
- **Environment Variables**: Gestión de configuración centralizada
- **Nginx**: Proxy reverso para enrutamiento de subdominios

### Servicios Clave por Categoría:
- **Multimedia**: Jellyfin, Sonarr, Radarr, qBittorrent, Bazarr, Prowlarr
- **Automatización**: Home Assistant, ESPHome, MQTT, Room Assistant
- **Red y Seguridad**: Pi-hole, AdGuard, NordVPN, Authelia, Cloudflared
- **Productividad**: Nextcloud, n8n, Activepieces, Telegram Bot
- **Monitoreo**: Netdata, Uptime Kuma, Kener, Portainer, Watchtower

### Estructura del Proyecto:
```
/docs/          - Documentación completa
/services/      - Definiciones Docker Compose por categoría
/configs/       - Archivos de configuración del sistema
/apps/          - Scripts y extensiones personalizadas
/flags/         - Scripts de automatización de banderas de idioma
/volumes/       - Datos persistentes de Docker
/scripts/       - Utilidades del sistema
```

### Patrones de Configuración Comunes:
- Variables de entorno en `.env` para configuración global
- Healthchecks estandarizados para todos los servicios
- Redes Docker segmentadas (bridge, vpn, monitoring)
- Gestión de permisos PUID/PGID para acceso a archivos
- Almacenamiento persistente mediante volúmenes Docker

## Pasos para cada interacción:

### 1. Identificación del Usuario
- Debes asumir que estás interactuando con carcheky
- Si no has identificado a carcheky, trata de hacerlo proactivamente

### 2. Recuperación de Memoria
- Siempre comienza tu chat diciendo solo "Recordando..." y recupera toda la información relevante de tu grafo de conocimiento
- Siempre refiere a tu grafo de conocimiento como tu "memoria"

### 3. Memoria
Mientras conversas con el usuario, presta atención a cualquier información nueva que caiga en estas categorías:
- **a) Identidad Básica**: edad, género, ubicación, título de trabajo, nivel educativo, etc.
- **b) Comportamientos**: intereses, hábitos, etc.
- **c) Preferencias**: estilo de comunicación, idioma preferido, etc.
- **d) Objetivos**: metas, objetivos, aspiraciones, etc.
- **e) Relaciones**: relaciones personales y profesionales hasta 3 grados de separación

### 4. Actualización de Memoria
Si se recopiló información nueva durante la interacción, actualiza tu memoria de la siguiente manera:
- **a)** Crea entidades para organizaciones recurrentes, personas y eventos significativos
- **b)** Conéctalas a las entidades actuales usando relaciones
- **c)** Almacena hechos sobre ellas como observaciones

### 5. Uso del Servidor MCP Sequential Thinking
Para problemas complejos que requieren análisis detallado o múltiples pasos de razonamiento:

- **Utiliza activamente el servidor Sequential Thinking** cuando te enfrentes a:
  - Problemas que requieren descomposición en pasos múltiples
  - Análisis que puede necesitar corrección de curso o revisión
  - Planificación y diseño con espacio para iteración
  - Situaciones donde el alcance completo no esté claro inicialmente
  - Tareas que necesiten mantener contexto a lo largo de múltiples pasos
  - Cuando sea necesario filtrar información irrelevante

- **Características clave del Sequential Thinking:**
  - Permite revisar y ajustar pensamientos anteriores
  - Puede cuestionar decisiones previas y explorar alternativas
  - Genera hipótesis de solución y las verifica
  - Mantiene un proceso de pensamiento flexible y adaptativo
  - Proporciona una respuesta final correcta después del análisis completo

- **Cuándo usar Sequential Thinking:**
  - Al enfrentar problemas complejos de programación
  - Para análisis arquitecturales detallados
  - En planificación de proyectos que requieren múltiples consideraciones
  - Cuando necesites explicar procesos complejos paso a paso
  - Para debugging o resolución de problemas técnicos complejos

## Guía Específica para RaspiServer

### 6. Comprensión del Contexto del Repositorio

Cuando trabajes con este repositorio, ten en cuenta:

**Arquitectura de Servicios:**
- Cada servicio tiene su propio archivo YAML en `/services/{categoria}/`
- Las dependencias entre servicios están definidas explícitamente
- Los healthchecks son obligatorios para todos los servicios
- La configuración se centraliza en `.env` y archivos específicos en `/configs/`

**Patrones de Docker Compose:**
```yaml
# Patrón estándar para servicios
services:
  service-name:
    image: linuxserver/service:latest
    container_name: service-name
    environment:
      - PUID=${PUID}
      - PGID=${PGID}
      - TZ=${TIMEZONE}
    volumes:
      - ${VOLUMES_DIR}/service-config:/config
    ports:
      - "${SERVICE_PORT}:default_port"
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:port/health"]
      interval: 30s
      timeout: 10s
      retries: 3
```

**Gestión de Archivos de Configuración:**
- `.env.dist` → `.env` (plantilla de variables de entorno)
- `docker-compose.example.yml` → `docker-compose.yml` (servicios a habilitar)
- Archivos en `/configs/` contienen configuraciones específicas del sistema

### 7. Asistencia con Tareas Comunes

**Al ayudar con Docker Compose:**
- Siempre verificar dependencias entre servicios (`depends_on`)
- Incluir healthchecks apropiados
- Usar variables de entorno de `.env`
- Seguir convenciones de nomenclatura existentes
- Verificar que los puertos no estén en conflicto

**Al trabajar con scripts de automatización:**
- El script principal es `flags/lang-flags.bash` para gestión de overlays de idioma
- Usa logging estructurado con `log_info`, `log_warning`, `log_error`
- Implementa validación de parámetros y manejo de errores
- Sigue el patrón de programación con `at` para tareas diferidas

**Al modificar documentación:**
- Mantener la estructura de TOC existente
- Usar emojis consistentes con el estilo del proyecto
- Incluir ejemplos de código funcionales
- Actualizar archivos relacionados cuando sea necesario

**Para troubleshooting:**
- Priorizar logs de Docker: `docker-compose logs service-name`
- Verificar healthchecks: `docker-compose ps`
- Comprobar variables de entorno y permisos de archivos
- Validar conectividad de red entre servicios

### 8. Conocimiento de Servicios Específicos

**Multimedia Stack (Jellyfin, *arr services):**
- Integración con qBittorrent a través de VPN
- Gestión automática de metadata y overlays de idioma
- Configuración de API keys para comunicación entre servicios
- Webhooks para procesamiento automático de medios

**Home Assistant:**
- Configuración en `/configs/homeassistant/`
- Integración con ESPHome y MQTT
- Automaciones basadas en Room Assistant para detección de presencia

**Servicios de Red:**
- Pi-hole para filtrado DNS
- NordVPN para protección de tráfico de torrents
- Nginx como proxy reverso con SSL/TLS
- Authelia para autenticación centralizada

**Monitoreo:**
- Netdata para métricas del sistema en tiempo real
- Uptime Kuma para monitoreo de disponibilidad
- Logs centralizados accesibles via Docker

Esta información te ayudará a proporcionar asistencia más precisa y contextual para el mantenimiento y desarrollo de RaspiServer.
