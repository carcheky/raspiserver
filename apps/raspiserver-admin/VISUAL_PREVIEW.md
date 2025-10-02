# RaspiServer Admin Interface - Visual Preview

## 🎨 Interfaz Principal

La interfaz consta de tres secciones principales accesibles mediante pestañas:

### 1. Gestión de Servicios (📦 Servicios)

```
┌─────────────────────────────────────────────────────────────────┐
│  🎛️ RaspiServer Admin                                          │
│  Gestión visual de servicios y configuración                   │
├─────────────────────────────────────────────────────────────────┤
│  [📦 Servicios]  [⚙️ Variables]  [ℹ️ Info]                     │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  🎬 Multimedia                                                  │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐       │
│  │ Jellyfin │  │  Sonarr  │  │  Radarr  │  │ Bazarr   │       │
│  │ services/│  │ services/│  │ services/│  │ services/│       │
│  │ [●──────]│  │ [●──────]│  │ [──────○]│  │ [──────○]│       │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘       │
│                                                                 │
│  🌐 Red y Seguridad                                             │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐       │
│  │ Pi-hole  │  │ NordVPN  │  │ Authelia │  │Cloudflare│       │
│  │ services/│  │ services/│  │ services/│  │ services/│       │
│  │ [●──────]│  │ [──────○]│  │ [──────○]│  │ [──────○]│       │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘       │
│                                                                 │
│  🔧 Gestión                                                     │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐       │
│  │Portainer │  │  Dockge  │  │  Homarr  │  │Watchtower│       │
│  │ services/│  │ services/│  │ services/│  │ services/│       │
│  │ [●──────]│  │ [●──────]│  │ [──────○]│  │ [──────○]│       │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘       │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘

Leyenda:
  - Tarjeta con fondo azul: Servicio ACTIVO ✅
  - Tarjeta con fondo gris: Servicio INACTIVO ❌
  - Switch verde [●──────]: ACTIVO
  - Switch gris [──────○]: INACTIVO
```

### 2. Variables de Entorno (⚙️ Variables de Entorno)

```
┌─────────────────────────────────────────────────────────────────┐
│  🎛️ RaspiServer Admin                                          │
│  Gestión visual de servicios y configuración                   │
├─────────────────────────────────────────────────────────────────┤
│  [📦 Servicios]  [⚙️ Variables]  [ℹ️ Info]                     │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  🔍 [Buscar variables...                                    ]  │
│                                                                 │
│  CONFIGURACIÓN DEL SISTEMA                                      │
│  ┌───────────────────────────────────────────────────────────┐ │
│  │ PUID                                                      │ │
│  │ User ID - run: id -u                                      │ │
│  │ [1000                                                   ] │ │
│  └───────────────────────────────────────────────────────────┘ │
│  ┌───────────────────────────────────────────────────────────┐ │
│  │ TIMEZONE                                                  │ │
│  │ Your timezone                                             │ │
│  │ [Europe/Madrid                                          ] │ │
│  └───────────────────────────────────────────────────────────┘ │
│                                                                 │
│  CONFIGURACIÓN DE RED                                           │
│  ┌───────────────────────────────────────────────────────────┐ │
│  │ JELLYFIN_PORT                                             │ │
│  │ Jellyfin media server port                                │ │
│  │ [8096                                                   ] │ │
│  └───────────────────────────────────────────────────────────┘ │
│                                                                 │
│  [💾 Guardar Cambios]                                          │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### 3. Información del Sistema (ℹ️ Información)

```
┌─────────────────────────────────────────────────────────────────┐
│  🎛️ RaspiServer Admin                                          │
│  Gestión visual de servicios y configuración                   │
├─────────────────────────────────────────────────────────────────┤
│  [📦 Servicios]  [⚙️ Variables]  [ℹ️ Info]                     │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌───────────────────────────────────────────────────────────┐ │
│  │ Directorio Base: /home/user/raspiserver                   │ │
│  │ Archivo .env: ✅ Existe                                    │ │
│  │ docker-compose.yml: ✅ Existe                              │ │
│  │ Directorio de servicios: ✅ Existe                         │ │
│  └───────────────────────────────────────────────────────────┘ │
│                                                                 │
│  📖 Instrucciones de Uso                                        │
│  ┌───────────────────────────────────────────────────────────┐ │
│  │ Gestión de Servicios                                      │ │
│  │                                                            │ │
│  │ Activa o desactiva servicios haciendo clic en los         │ │
│  │ switches. Los cambios se aplican inmediatamente al        │ │
│  │ archivo docker-compose.yml.                                │ │
│  │                                                            │ │
│  │ Para aplicar los cambios, ejecuta:                        │ │
│  │   docker-compose up -d                                    │ │
│  └───────────────────────────────────────────────────────────┘ │
│                                                                 │
│  ┌───────────────────────────────────────────────────────────┐ │
│  │ ⚠️ IMPORTANTE: Cambia todas las contraseñas por defecto  │ │
│  │ antes de poner los servicios en producción.               │ │
│  └───────────────────────────────────────────────────────────┘ │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## 🎨 Características Visuales

### Colores

- **Header**: Gradiente púrpura (#667eea → #764ba2)
- **Servicios Activos**: Fondo azul claro (#e7f3ff)
- **Servicios Inactivos**: Fondo gris (#f8f9fa)
- **Switches Activos**: Verde (#28a745)
- **Botones**: Púrpura (#667eea)
- **Notificaciones Success**: Verde (#28a745)
- **Notificaciones Error**: Rojo (#dc3545)

### Animaciones

- Transiciones suaves (0.3s) en botones y tarjetas
- Efecto hover: elevación y sombra
- Notificaciones deslizantes desde la derecha
- Cambio de color gradual en switches

### Diseño Responsivo

- Diseño de grid adaptativo
- Mínimo 280px por tarjeta de servicio
- Se adapta a móviles, tablets y desktop
- Máximo ancho de contenedor: 1400px

## 🚀 Flujo de Trabajo

### Activar un Servicio

1. Usuario hace clic en el switch de un servicio inactivo
2. Switch cambia a verde [●──────]
3. Tarjeta cambia a fondo azul
4. Aparece notificación verde: "Servicio activado correctamente"
5. Backend actualiza docker-compose.yml

### Editar Variables

1. Usuario escribe en el campo de texto
2. Hace clic en "Guardar Cambios"
3. Backend actualiza archivo .env
4. Aparece notificación: "Variables de entorno guardadas correctamente"

## 📱 Compatibilidad

- ✅ Chrome/Edge (versiones modernas)
- ✅ Firefox (versiones modernas)
- ✅ Safari (versiones modernas)
- ✅ Navegadores móviles
- ❌ Internet Explorer (no soportado)

## 🔧 Tecnologías

- **Backend**: Flask (Python 3.11)
- **Frontend**: HTML5, CSS3, JavaScript (Vanilla)
- **API**: REST JSON
- **Persistencia**: Archivos de texto (.env, docker-compose.yml)

---

**URL de acceso**: http://localhost:5000
**Puerto configurable en**: .env (RASPISERVER_ADMIN_PORT)
