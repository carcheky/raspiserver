# 🎛️ RaspiServer Admin Interface

Interfaz web de administración visual para RaspiServer que permite gestionar servicios y variables de entorno de forma sencilla.

## ✨ Características

- **Gestión Visual de Servicios**: Activa/desactiva servicios con un clic
- **Editor de Variables de Entorno**: Modifica `.env` desde una interfaz web
- **Organización por Categorías**: Servicios agrupados por tipo (Multimedia, Red, Automatización, etc.)
- **Información del Sistema**: Visualiza el estado de configuración
- **Interfaz Moderna**: UI responsive y fácil de usar

## 🚀 Inicio Rápido

### 1. Activar el servicio

Edita tu `docker-compose.yml` y descomenta la línea:

```yaml
include:
  - services/management/raspiserver-admin.yml
```

### 2. Configurar puerto (opcional)

Añade a tu archivo `.env`:

```bash
RASPISERVER_ADMIN_PORT=5000
```

### 3. Iniciar el servicio

```bash
docker-compose up -d raspiserver-admin
```

### 4. Acceder a la interfaz

Abre tu navegador y accede a:

```
http://localhost:5000
```

O usa la IP de tu servidor:

```
http://192.168.1.100:5000
```

## 📖 Uso

### Gestión de Servicios

1. Ve a la pestaña **📦 Servicios**
2. Verás todos los servicios disponibles organizados por categorías
3. Los servicios activos aparecen con fondo azul
4. Haz clic en el switch para activar/desactivar un servicio
5. Los cambios se aplican inmediatamente al `docker-compose.yml`
6. Ejecuta `docker-compose up -d` para aplicar los cambios

### Editor de Variables de Entorno

1. Ve a la pestaña **⚙️ Variables de Entorno**
2. Usa la barra de búsqueda para filtrar variables
3. Las variables están organizadas por secciones
4. Edita los valores según necesites
5. Haz clic en **💾 Guardar Cambios** para aplicar
6. Reinicia los servicios afectados si es necesario

### Información del Sistema

1. Ve a la pestaña **ℹ️ Información del Sistema**
2. Verifica que todos los archivos necesarios existan
3. Lee las instrucciones y consejos de seguridad

## ⚙️ Categorías de Servicios

- **🎬 Multimedia**: Jellyfin, Sonarr, Radarr, Bazarr, Prowlarr, etc.
- **🌐 Red y Seguridad**: Pi-hole, NordVPN, Cloudflared, Authelia, etc.
- **📊 Automatización y Monitoreo**: Home Assistant, Netdata, Uptime Kuma, etc.
- **🔧 Gestión**: Portainer, Dockge, Homarr, Watchtower, etc.
- **☁️ Productividad**: Nextcloud, n8n, Activepieces, etc.
- **🔄 Otros**: qBittorrent, Telegram Bot, etc.

## 🔒 Seguridad

⚠️ **IMPORTANTE**: Esta interfaz tiene acceso completo a tu configuración de Docker.

### Recomendaciones:

1. **No expongas el puerto 5000 a Internet** sin protección adicional
2. Usa detrás de un proxy reverso con autenticación (Authelia, Nginx)
3. Configura un firewall para limitar el acceso
4. Cambia todas las contraseñas por defecto
5. Mantén el servicio actualizado

### Ejemplo con Nginx + Autenticación Básica:

```nginx
location /admin/ {
    auth_basic "Admin Area";
    auth_basic_user_file /etc/nginx/.htpasswd;
    proxy_pass http://localhost:5000/;
}
```

## 🛠️ Solución de Problemas

### El servicio no inicia

```bash
# Ver logs
docker-compose logs raspiserver-admin

# Verificar que el puerto no esté en uso
sudo netstat -tlnp | grep 5000

# Reconstruir la imagen
docker-compose build raspiserver-admin
docker-compose up -d raspiserver-admin
```

### Los cambios no se aplican

```bash
# Verificar permisos de archivos
ls -la docker-compose.yml .env

# Reiniciar el contenedor
docker-compose restart raspiserver-admin
```

### No aparecen los servicios

- Verifica que el directorio `services/` existe
- Comprueba que los archivos `.yml` están en las subcarpetas correctas
- Revisa los logs del contenedor

## 📝 Desarrollo

### Estructura del proyecto

```
apps/raspiserver-admin/
├── app.py              # Backend Flask
├── templates/
│   └── index.html      # Frontend HTML/CSS/JS
├── requirements.txt    # Dependencias Python
├── Dockerfile          # Imagen Docker
└── README.md          # Esta documentación
```

### Ejecutar en modo desarrollo

```bash
cd apps/raspiserver-admin

# Instalar dependencias
pip install -r requirements.txt

# Configurar variable de entorno
export RASPISERVER_PATH=/ruta/a/raspiserver

# Ejecutar
python app.py
```

### Modificar la interfaz

1. Edita `templates/index.html` para cambios en el frontend
2. Edita `app.py` para cambios en el backend
3. Reconstruye la imagen: `docker-compose build raspiserver-admin`
4. Reinicia: `docker-compose up -d raspiserver-admin`

## 🤝 Contribuir

Las contribuciones son bienvenidas. Por favor:

1. Haz un fork del repositorio
2. Crea una rama para tu feature
3. Haz commit de tus cambios
4. Haz push a la rama
5. Abre un Pull Request

## 📄 Licencia

Este proyecto es parte de RaspiServer y está bajo la misma licencia.

## 🆘 Soporte

- 📖 Lee la [documentación principal](../../docs/)
- 🐛 Reporta bugs en [GitHub Issues](https://github.com/carcheky/raspiserver/issues)
- 💬 Únete a la discusión

---

**Hecho con ❤️ para la comunidad de self-hosting**
