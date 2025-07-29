# 🚀 Guía de Configuración y Conexión de Servicios RaspiServer

## 📊 Estado de los Servicios

Primero, verifica que todos los servicios estén ejecutándose:

```bash
docker-compose ps
```

**Servicios activos esperados:**
- ✅ **Jellyfin** - `http://localhost:8096` - Servidor de medios principal
- ✅ **Sonarr** - `http://localhost:8989` - Gestión de series de TV  
- ✅ **Radarr** - `http://localhost:7878` - Gestión de películas
- ✅ **Jellyseerr** - `http://localhost:5055` - Interfaz de solicitudes
- ✅ **Jellystat** - `http://localhost:3002` - Analíticas de Jellyfin
- ✅ **qBittorrent** - `http://localhost:8080` - Cliente de torrents

## 🔧 Configuración Paso a Paso

### 1. 📥 Configurar qBittorrent (Base del stack)

**Acceso inicial:**
- URL: `http://localhost:8080`
- Usuario: `admin`
- Contraseña: `password`

**Configuraciones necesarias:**

1. **Ve a Tools → Options**

2. **En la sección Downloads:**
   - Default Save Path: `/downloads`
   - Keep incomplete torrents in: `/downloads/incomplete`

3. **En la sección Connection:**
   - Puerto: `6881` (ya configurado)
   - Use UPnP/NAT-PMP: Desactivar si usas VPN

4. **En la sección BitTorrent:**
   - DHT: Habilitado
   - PeX: Habilitado
   - LSD: Habilitado

5. **En la sección Web UI:**
   - Enable Web User Interface: ✅
   - IP address: `*`
   - Port: `8080`

**Categorías recomendadas:**
- Crear categoría `movies` con save path `/downloads/movies`
- Crear categoría `tv` con save path `/downloads/tv`
- Crear categoría `music` con save path `/downloads/music`

---

### 2. 🎬 Configurar Jellyfin

**Acceso inicial:**
- URL: `http://localhost:8096`

**Setup inicial:**

1. **Primer acceso:**
   - Selecciona idioma: Español
   - Crear usuario administrador:
     - Nombre: `admin`
     - Contraseña: (tu elección, anótala)

2. **Configurar bibliotecas de medios:**

   **Para Películas:**
   - Tipo de contenido: `Movies`
   - Nombre: `Películas`
   - Carpeta: `/media/movies`
   - Idioma de metadata: `Spanish`
   - País: `Spain`

   **Para Series:**
   - Tipo de contenido: `TV Shows`
   - Nombre: `Series`
   - Carpeta: `/media/tv`
   - Idioma de metadata: `Spanish`
   - País: `Spain`

   **Para Música (opcional):**
   - Tipo de contenido: `Music`
   - Nombre: `Música`
   - Carpeta: `/media/music`

3. **Configuraciones adicionales:**
   - Permitir acceso remoto: ✅
   - Enable automatic port mapping: ✅

---

### 3. 📺 Configurar Sonarr

**Acceso:**
- URL: `http://localhost:8989`

**Configuración inicial:**

1. **Media Management (Settings → Media Management):**
   - **Root Folders:** Agregar `/media/tv`
   - **Completed Download Handling:** ✅ Enable
   - **Rename Episodes:** ✅ Enable
   - **Standard Episode Format:** 
     ```
     {Series Title} - S{season:00}E{episode:00} - {Episode Title} {Quality Full}
     ```

2. **Download Clients (Settings → Download Clients):**
   
   **Agregar qBittorrent:**
   - Clic en el `+` → `qBittorrent`
   - **Configuración:**
     - Name: `qBittorrent`
     - Enable: ✅
     - Host: `qbittorrent`
     - Port: `8080`
     - Username: `admin`
     - Password: `password`
     - Category: `tv`
   - **Test** → **Save**

3. **General (Settings → General):**
   - Anota la **API Key** (la necesitarás para Jellyseerr)

4. **Indexers (Settings → Indexers):**
   - Agrega tus indexers favoritos (Jackett, Prowlarr, etc.)

---

### 4. 🎭 Configurar Radarr

**Acceso:**
- URL: `http://localhost:7878`

**Configuración inicial:**

1. **Media Management (Settings → Media Management):**
   - **Root Folders:** Agregar `/media/movies`
   - **Completed Download Handling:** ✅ Enable
   - **Rename Movies:** ✅ Enable
   - **Standard Movie Format:**
     ```
     {Movie Title} ({Release Year}) {Quality Full}
     ```

2. **Download Clients (Settings → Download Clients):**
   
   **Agregar qBittorrent:**
   - Clic en el `+` → `qBittorrent`
   - **Configuración:**
     - Name: `qBittorrent`
     - Enable: ✅
     - Host: `qbittorrent`
     - Port: `8080`
     - Username: `admin`
     - Password: `password`
     - Category: `movies`
   - **Test** → **Save**

3. **General (Settings → General):**
   - Anota la **API Key** (la necesitarás para Jellyseerr)

4. **Indexers (Settings → Indexers):**
   - Agrega tus indexers favoritos

---

### 5. 🎯 Configurar Jellyseerr

**Acceso:**
- URL: `http://localhost:5055`

**Setup inicial:**

1. **Configuración de Jellyfin:**
   - Selecciona: `Use Jellyfin`
   - **Jellyfin URL:** `http://jellyfin:8096`
   - Introduce las credenciales del admin de Jellyfin
   - **Test** → **Continue**

2. **Configuración de Sonarr:**
   - **Add Sonarr Server**
   - **Configuración:**
     - Server Name: `Sonarr`
     - Hostname or IP: `sonarr`
     - Port: `8989`
     - API Key: (copiar desde Sonarr → Settings → General)
     - Base URL: (dejar vacío)
     - Quality Profile: `Any`
     - Root Folder: `/media/tv`
     - Language Profile: `Spanish`
   - **Test** → **Add Server**

3. **Configuración de Radarr:**
   - **Add Radarr Server**
   - **Configuración:**
     - Server Name: `Radarr`
     - Hostname or IP: `radarr`
     - Port: `7878`
     - API Key: (copiar desde Radarr → Settings → General)
     - Base URL: (dejar vacío)
     - Quality Profile: `Any`
     - Root Folder: `/media/movies`
     - Minimum Availability: `Released`
   - **Test** → **Add Server**

4. **Configuración de usuario:**
   - Crear usuario administrador
   - Configurar permisos según necesidades

---

### 6. 📈 Configurar Jellystat

**Acceso:**
- URL: `http://localhost:3002`

**Setup inicial:**

1. **Primer acceso:**
   - Crear cuenta de administrador
   - **Jellyfin Configuration:**
     - Jellyfin URL: `http://jellyfin:8096`
     - Username: (usuario admin de Jellyfin)
     - Password: (contraseña de admin de Jellyfin)

2. **Configuraciones adicionales:**
   - Enable library scanning: ✅
   - Sync interval: `30 minutes`
   - Enable user tracking: ✅

---

## 🔗 Flujo de Trabajo Completo

### Cómo funciona la cadena de servicios:

1. **📱 Usuario hace solicitud** → Jellyseerr
2. **🔍 Jellyseerr busca** → Sonarr/Radarr
3. **⬇️ Sonarr/Radarr descarga** → qBittorrent
4. **📁 qBittorrent guarda** → `/downloads/`
5. **🎬 Sonarr/Radarr mueve** → `/media/movies` o `/media/tv`
6. **📺 Jellyfin escanea** → Bibliotecas actualizadas
7. **📊 Jellystat rastrea** → Estadísticas de uso

---

## ⚡ Comandos Útiles

### Verificar estado:
```bash
docker-compose ps
docker-compose logs [nombre_servicio]
```

### Reiniciar servicios:
```bash
docker-compose restart [nombre_servicio]
```

### Ver logs en tiempo real:
```bash
docker-compose logs -f [nombre_servicio]
```

### Actualizar servicios:
```bash
docker-compose pull
docker-compose up -d
```

---

## 🔐 Credenciales por Defecto

| Servicio | URL | Usuario | Contraseña |
|----------|-----|---------|------------|
| qBittorrent | http://localhost:8080 | admin | password |
| Jellyfin | http://localhost:8096 | (configurar) | (configurar) |
| Sonarr | http://localhost:8989 | - | - |
| Radarr | http://localhost:7878 | - | - |
| Jellyseerr | http://localhost:5055 | (configurar) | (configurar) |
| Jellystat | http://localhost:3002 | (configurar) | (configurar) |

---

## 📂 Estructura de Carpetas

```
/media/
├── movies/          # Películas finalizadas
├── tv/             # Series finalizadas
└── music/          # Música (opcional)

/downloads/
├── incomplete/     # Descargas en progreso
├── movies/         # Películas descargadas
├── tv/            # Series descargadas
└── music/         # Música descargada
```

---

## 🔧 Solución de Problemas

### Si un servicio no responde:
1. Verificar que el contenedor esté ejecutándose: `docker-compose ps`
2. Ver los logs: `docker-compose logs [servicio]`
3. Reiniciar el servicio: `docker-compose restart [servicio]`

### Si las conexiones fallan:
1. Verificar que uses los nombres de contenedor (no localhost)
2. Verificar que los puertos estén correctos
3. Verificar las API keys

### Si las descargas no se mueven:
1. Verificar permisos de carpetas
2. Verificar configuración de "Completed Download Handling"
3. Verificar que las categorías en qBittorrent coincidan

---

## ✅ Lista de Verificación

- [ ] qBittorrent configurado con categorías
- [ ] Jellyfin con bibliotecas creadas
- [ ] Sonarr conectado a qBittorrent
- [ ] Radarr conectado a qBittorrent  
- [ ] Jellyseerr conectado a Jellyfin, Sonarr y Radarr
- [ ] Jellystat conectado a Jellyfin
- [ ] Probado el flujo completo: solicitud → descarga → disponible en Jellyfin

¡Una vez completada toda la configuración, tendrás un media server completamente automatizado! 🎉
