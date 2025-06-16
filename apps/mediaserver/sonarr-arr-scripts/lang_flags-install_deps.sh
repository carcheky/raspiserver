#!/bin/bash

echo "[$(date)] Lang-Flags: Instalando dependencias..."

# Instalar dependencias de forma desatendida
export DEBIAN_FRONTEND=noninteractive

if command -v apt-get >/dev/null 2>&1; then
    apt-get update -qq >/dev/null 2>&1
    apt-get install -y -qq \
        imagemagick \
        libimage-exiftool-perl \
        jq \
        ffmpeg \
        curl \
        wget \
        bc \
        >/dev/null 2>&1
elif command -v apk >/dev/null 2>&1; then
    apk add --no-cache \
        imagemagick \
        exiftool \
        jq \
        ffmpeg \
        curl \
        wget \
        bc \
        bash \
        >/dev/null 2>&1
fi

echo "[$(date)] Lang-Flags: Estableciendo permisos de cron..."

# Establecer permisos para poder crear cron después
if [[ -d "/etc/cron.d" ]]; then
    chmod 777 "/etc/cron.d" 2>/dev/null
elif mkdir -p "/etc/cron.d" 2>/dev/null; then
    chmod 777 "/etc/cron.d" 2>/dev/null
fi

echo "[$(date)] Lang-Flags: Configurando cron para procesamiento de colas..."

# Configurar cron job para procesar colas automáticamente
cat > /etc/cron.d/lang-flags-queue << 'CRONEOF'
# Lang-Flags Queue Processor - Se autodesactiva cuando las colas están vacías
SHELL=/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

# Procesar cola cada minuto
* * * * * root bash /flags/lang-flags.bash --process-queue >/dev/null 2>&1
CRONEOF

chmod 644 /etc/cron.d/lang-flags-queue 2>/dev/null

# Recargar cron para aplicar cambios
if command -v crond >/dev/null; then
    pkill -HUP crond 2>/dev/null || true
fi

echo "[$(date)] Lang-Flags: Cron job configurado - se autodesactivará cuando las colas estén vacías"

echo "[$(date)] Lang-Flags: Inicialización completada"
