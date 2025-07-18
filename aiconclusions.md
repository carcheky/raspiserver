# AI Conclusions - MediaCheky

## Config Redimensionado Imágenes
- Reducido target_height de 1000px a 700px en lang-flags.bash para optimizar tamaño de posters
- Mejora rendimiento y reduce almacenamiento manteniendo calidad visual

## Reinicio Programado Sonarr
- Programado reinicio automático de contenedor Sonarr en 20min usando at (job 11)
- Fecha: Viernes 18 Jul 15:42:00 2025 para aplicar cambios de configuración

## Fix Conteo Cola Duplicados
- Corregido contador "añadidos" que contaba elementos ya existentes en cola
- add_to_queue() ahora retorna 1 si elemento ya existe, 0 si se añade exitosamente
- Conteo solo incrementa cuando elemento realmente se añade a cola

## Fix Total Cola Específica
- "total en cola" ahora muestra solo elementos de la cola correspondiente
- Series: muestra solo cola Sonarr, Películas: muestra solo cola Radarr
- Nueva función get_specific_queue_count() para conteo por tipo de media
