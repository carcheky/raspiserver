# 📘 Guía de la Interfaz de Administración RaspiServer

## 📋 Índice

1. [Introducción](#introducción)
2. [Instalación](#instalación)
3. [Uso de la Interfaz](#uso-de-la-interfaz)
4. [Gestión de Servicios](#gestión-de-servicios)
5. [Gestión de Variables de Entorno](#gestión-de-variables-de-entorno)
6. [Seguridad](#seguridad)
7. [Solución de Problemas](#solución-de-problemas)

## 🎯 Introducción

La **Interfaz de Administración RaspiServer** es una herramienta web que permite gestionar visualmente todos los servicios y configuraciones de tu servidor RaspiServer sin necesidad de editar archivos manualmente.

### Características Principales

✅ **Gestión Visual de Servicios**
- Activa o desactiva servicios con un simple clic
- Visualiza qué servicios están activos
- Organización por categorías (Multimedia, Red, Automatización, etc.)

✅ **Editor de Variables de Entorno**
- Edita variables `.env` desde la web
- Búsqueda y filtrado de variables
- Organización por secciones

✅ **Información del Sistema**
- Estado de archivos de configuración
- Verificación de requisitos
- Instrucciones de uso

## 🚀 Instalación

### Opción 1: Usando Docker Compose (Recomendado)

1. **Edita tu `docker-compose.yml`** y añade la siguiente línea en la sección `include:`:

```yaml
include:
  - services/management/raspiserver-admin.yml
```

2. **Configura el puerto** (opcional) en tu archivo `.env`:

```bash
RASPISERVER_ADMIN_PORT=5000
```

3. **Inicia el servicio**:

```bash
docker-compose up -d raspiserver-admin
```

4. **Accede a la interfaz** en tu navegador:

```
http://localhost:5000
```

O usa la IP de tu servidor:

```
http://tu-ip:5000
```

### Opción 2: Ejecución Manual (Desarrollo)

1. **Navega al directorio**:

```bash
cd apps/raspiserver-admin
```

2. **Instala las dependencias**:

```bash
pip install -r requirements.txt
```

3. **Configura la variable de entorno**:

```bash
export RASPISERVER_PATH=/ruta/completa/a/raspiserver
```

4. **Ejecuta la aplicación**:

```bash
python app.py
```

## 🎨 Uso de la Interfaz

La interfaz se divide en tres pestañas principales:

### 1️⃣ Pestaña de Servicios (📦)

Esta pestaña muestra todos los servicios disponibles organizados por categorías:

- **🎬 Multimedia**: Jellyfin, Sonarr, Radarr, Bazarr, etc.
- **🌐 Red y Seguridad**: Pi-hole, NordVPN, Authelia, etc.
- **📊 Automatización y Monitoreo**: Home Assistant, Netdata, etc.
- **🔧 Gestión**: Portainer, Dockge, Homarr, etc.
- **☁️ Productividad**: Nextcloud, n8n, etc.
- **🔄 Otros**: qBittorrent, Telegram Bot, etc.

#### Indicadores Visuales:

- **Tarjeta con fondo azul claro** = Servicio activo
- **Tarjeta con fondo gris** = Servicio inactivo
- **Switch verde** = Servicio activo
- **Switch gris** = Servicio inactivo

### 2️⃣ Pestaña de Variables de Entorno (⚙️)

Aquí puedes editar todas las variables de entorno de tu archivo `.env`:

- Variables organizadas por secciones
- Barra de búsqueda para filtrar
- Comentarios explicativos para cada variable
- Botón de guardado al final

### 3️⃣ Pestaña de Información del Sistema (ℹ️)

Muestra:
- Estado de archivos de configuración
- Directorio base del proyecto
- Instrucciones de uso
- Advertencias de seguridad

## 🔧 Gestión de Servicios

### Activar un Servicio

1. Ve a la pestaña **📦 Servicios**
2. Busca el servicio que deseas activar
3. Haz clic en el **switch** (botón deslizante)
4. Verás una notificación verde confirmando la activación
5. La tarjeta del servicio cambiará a fondo azul claro

### Desactivar un Servicio

1. Ve a la pestaña **📦 Servicios**
2. Busca el servicio activo (fondo azul claro)
3. Haz clic en el **switch** para desactivarlo
4. Verás una notificación confirmando la desactivación
5. La tarjeta volverá al fondo gris

### Aplicar los Cambios

⚠️ **IMPORTANTE**: Los cambios se guardan en `docker-compose.yml`, pero **NO se aplican automáticamente**.

Para aplicar los cambios, ejecuta en tu terminal:

```bash
# Aplica los cambios (inicia nuevos servicios, detiene desactivados)
docker-compose up -d

# O reinicia todos los servicios
docker-compose down && docker-compose up -d
```

### Ejemplo Completo: Activar Stack de Medios

Para activar un servidor de medios completo:

1. Activa **Jellyfin** (servidor de streaming)
2. Activa **Sonarr** (gestión de series)
3. Activa **Radarr** (gestión de películas)
4. Activa **Prowlarr** (gestión de indexers)
5. Activa **qBittorrent** (cliente de torrents)
6. Activa **Jellyseerr** (interfaz de peticiones)

Luego ejecuta:

```bash
docker-compose up -d
```

## ⚙️ Gestión de Variables de Entorno

### Editar Variables

1. Ve a la pestaña **⚙️ Variables de Entorno**
2. Usa la barra de búsqueda para encontrar la variable (ej: "JELLYFIN")
3. Haz clic en el campo de texto y edita el valor
4. Haz clic en **💾 Guardar Cambios** al final de la página
5. Verás una notificación verde confirmando que se guardaron

### Variables Importantes

#### Sistema
```bash
PUID=1000                    # ID de usuario (ejecuta: id -u)
PGID=1000                    # ID de grupo (ejecuta: id -g)
TIMEZONE=Europe/Madrid       # Tu zona horaria
```

#### Rutas
```bash
RASPISERVER=/ruta/al/proyecto
MEDIA_DIR=/mnt/media
DOWNLOADS_DIR=/mnt/downloads
```

#### Puertos
```bash
JELLYFIN_PORT=8096
SONARR_PORT=8989
RADARR_PORT=7878
PORTAINER_PORT=9000
```

#### Seguridad
```bash
PASSWORD=CambiameAhora!
MYSQL_ROOT_PASSWORD=CambiameAhora!
NORDVPN_USER=tu_usuario
NORDVPN_PASS=tu_contraseña
```

### Aplicar Cambios de Variables

Después de modificar variables, reinicia los servicios afectados:

```bash
# Para un servicio específico
docker-compose restart jellyfin

# Para todos los servicios
docker-compose down && docker-compose up -d
```

## 🔒 Seguridad

### ⚠️ Advertencias Importantes

1. **NO expongas el puerto 5000 a Internet** directamente
2. Esta interfaz tiene **acceso completo** a tu configuración
3. Cambia **todas las contraseñas por defecto** antes de usar en producción
4. Usa detrás de un **proxy reverso con autenticación**

### Protección con Nginx

Ejemplo de configuración con autenticación básica:

```nginx
# Crear usuario y contraseña
sudo htpasswd -c /etc/nginx/.htpasswd admin

# Configuración de Nginx
location /raspi-admin/ {
    auth_basic "RaspiServer Admin";
    auth_basic_user_file /etc/nginx/.htpasswd;
    proxy_pass http://localhost:5000/;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
}
```

### Protección con Authelia

Si usas Authelia para autenticación:

```yaml
# En tu configuración de Traefik
labels:
  - "traefik.enable=true"
  - "traefik.http.routers.raspi-admin.middlewares=authelia@docker"
```

### Limitar Acceso por IP

Solo permite acceso desde tu red local:

```bash
# Firewall UFW
sudo ufw allow from 192.168.1.0/24 to any port 5000

# iptables
sudo iptables -A INPUT -p tcp --dport 5000 -s 192.168.1.0/24 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 5000 -j DROP
```

## 🔍 Solución de Problemas

### El servicio no inicia

**Síntoma**: El contenedor no arranca o se reinicia constantemente.

**Solución**:

```bash
# Ver logs del contenedor
docker-compose logs raspiserver-admin

# Verificar que el puerto no esté en uso
sudo netstat -tlnp | grep 5000

# Si el puerto está ocupado, cámbialo en .env
echo "RASPISERVER_ADMIN_PORT=5001" >> .env

# Reconstruir e iniciar
docker-compose build raspiserver-admin
docker-compose up -d raspiserver-admin
```

### Error de permisos en archivos

**Síntoma**: No se pueden guardar cambios en `.env` o `docker-compose.yml`.

**Solución**:

```bash
# Verificar permisos
ls -la docker-compose.yml .env

# Ajustar permisos si es necesario
sudo chown $USER:$USER docker-compose.yml .env
chmod 644 docker-compose.yml .env

# Reiniciar el contenedor
docker-compose restart raspiserver-admin
```

### No aparecen servicios en la interfaz

**Síntoma**: La pestaña de servicios está vacía o no carga.

**Solución**:

```bash
# Verificar que el directorio de servicios existe
ls -la services/

# Ver logs para detectar errores
docker-compose logs -f raspiserver-admin

# Verificar el montaje de volúmenes
docker inspect raspiserver-admin | grep -A 10 Mounts
```

### Los cambios no se aplican

**Síntoma**: Activas/desactivas servicios pero no hay cambios en `docker-compose.yml`.

**Solución**:

```bash
# Verificar que el archivo existe y es editable
ls -la docker-compose.yml

# Si no existe, cópialo del ejemplo
cp docker-compose.example.yml docker-compose.yml

# Verificar permisos del contenedor
docker exec raspiserver-admin ls -la /raspiserver/

# Reiniciar el contenedor
docker-compose restart raspiserver-admin
```

### Error 404 al acceder

**Síntoma**: Al abrir `http://localhost:5000` aparece "Cannot GET /".

**Solución**:

```bash
# Verificar que el contenedor está corriendo
docker ps | grep raspiserver-admin

# Ver logs del contenedor
docker-compose logs raspiserver-admin

# Reconstruir la imagen
docker-compose build raspiserver-admin --no-cache
docker-compose up -d raspiserver-admin
```

### Cambios en .env no tienen efecto

**Síntoma**: Modificas variables pero los servicios siguen usando valores antiguos.

**Solución**:

```bash
# Las variables de entorno se leen al iniciar el contenedor
# Debes reiniciar los servicios afectados

# Opción 1: Reiniciar todo
docker-compose down && docker-compose up -d

# Opción 2: Reiniciar servicio específico
docker-compose restart nombre-del-servicio

# Opción 3: Recrear el servicio
docker-compose up -d --force-recreate nombre-del-servicio
```

## 📚 Recursos Adicionales

- [Documentación Principal](../../docs/README.md)
- [Guía de Configuración de Servicios](../../CONFIGURACION_SERVICIOS.md)
- [Referencia Rápida](../../docs/QUICK_REFERENCE.md)
- [README del Admin](../raspiserver-admin/README.md)

## 🤝 Soporte

Si tienes problemas:

1. Consulta esta guía y la sección de solución de problemas
2. Revisa los logs: `docker-compose logs raspiserver-admin`
3. Busca en [GitHub Issues](https://github.com/carcheky/raspiserver/issues)
4. Abre un nuevo issue si no encuentras solución

## 📝 Notas

- Los cambios en servicios requieren ejecutar `docker-compose up -d` para aplicarse
- Los cambios en variables de entorno requieren reiniciar los servicios afectados
- Siempre haz backup de tus archivos de configuración antes de hacer cambios importantes
- Esta interfaz es complementaria a Portainer y Dockge, no los reemplaza

---

**¡Disfruta de tu servidor RaspiServer! 🎉**
