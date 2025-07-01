#!/bin/bash
echo "[$(date)] Lang-Flags-Beta: Inicializando sistema..."

# 1. Configurar entorno completo (dependencias + cron)
echo "[$(date)] Lang-Flags-Beta: Ejecutando setup..."
/flags/lang-flags-beta.bash setup

# 2. Lanzar boot_process en segundo plano
echo "[$(date)] Lang-Flags-Beta: Lanzando boot_process en segundo plano..."
/flags/lang-flags-beta.bash boot_process &

echo "[$(date)] Lang-Flags-Beta: Inicialización completada"
