# 📋 Flujo del Script Lang-Flags con Sonarr

## 🎯 **Escenario: Sonarr añade una serie nueva**

```
┌─────────────────────────────────────────────────────────────────┐
│                    SONARR DESCARGA EPISODIO                    │
└─────────────────────┬───────────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────────────┐
│            Sonarr ejecuta SCRIPT PERSONALIZADO                 │
│          (lang-flags.bash como Custom Script)                  │
│                                                                 │
│ Variables de entorno establecidas por Sonarr:                  │
│ • sonarr_eventtype="Download"                                  │
│ • sonarr_series_path="/BibliotecaMultimedia/Series/Serie"      │
│ • sonarr_episodefile_path="/path/to/episode.mkv"              │
└─────────────────────┬───────────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────────────┐
│                  SCRIPT LANG-FLAGS INICIA                      │
│                                                                 │
│ 1. Detecta MODE="queue_only" (auto-detectado)                  │
│ 2. Llama a process_radarr_sonarr_event()                      │
└─────────────────────┬───────────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────────────┐
│              AÑADIR A COLA DE PROCESAMIENTO                    │
│                                                                 │
│ • add_to_sonarr_queue()                                        │
│ • Añade entrada a: /flags/queue/sonarr_queue.txt              │
│ • Formato: timestamp|series_path|episode_file|wait_seconds     │
│ • Log: "Series added to processing queue: [NombreSerie]"       │
│ • TERMINA INMEDIATAMENTE (no procesa ahora)                   │
└─────────────────────┬───────────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────────────┐
│                MONITOR DE COLA (BACKGROUND)                    │
│                                                                 │
│ • Se ejecuta cada 180 segundos por defecto                     │
│ • Función: start_queue_monitor()                               │
│ • Verifica si hay elementos en las colas                       │
│ • Si encuentra elementos, llama a process_queue()              │
└─────────────────────┬───────────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────────────┐
│                   PROCESAR COLA                                │
│                                                                 │
│ 1. Lee /flags/queue/sonarr_queue.txt                          │
│ 2. Para cada elemento:                                         │
│    • Espera NFO_WAIT_SECONDS (30s por defecto)                │
│    • Llama a wait_for_nfo_and_process()                       │
│    • Procesa la serie y episodios                             │
│ 3. Limpia el archivo de cola al terminar                      │
└─────────────────────┬───────────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────────────┐
│               PROCESAMIENTO REAL DE IMÁGENES                   │
│                                                                 │
│ Para Series:                                                    │
│ • Busca tvshow.nfo                                            │
│ • Procesa folder.jpg y backdrop.jpg principales               │
│ • Recorre Season XX/ folders                                  │
│ • Procesa cada *-thumb.jpg de episodios                       │
│ • Aplica overlays de banderas según idiomas del audio         │
│ • Marca imágenes como procesadas                              │
└─────────────────────┬───────────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────────────┐
│                        FINALIZA                                │
│                                                                 │
│ • Limpia cache de Jellyfin                                     │
│ • Monitor continúa ejecutándose cada 180s                      │
│ • Si no hay más elementos en cola, termina                     │
└─────────────────────────────────────────────────────────────────┘
```

## ⚠️ **PROBLEMAS IDENTIFICADOS:**

### 1. **Espera Innecesaria**
- Espera 30 segundos **después** de encontrar NFO
- No necesario si las imágenes ya están disponibles

### 2. **Monitor Separado**
- El monitor corre independientemente
- Puede crear múltiples instancias

### 3. **Procesamiento Redundante**
- Procesa TODA la serie cada vez
- No solo el episodio nuevo

### 4. **No Hay Validación**
- No verifica si las imágenes existen antes de procesar
- Puede fallar silenciosamente
