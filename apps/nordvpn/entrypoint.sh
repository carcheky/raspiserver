#!/bin/bash

# Función para iniciar NordVPN
start() {
    echo "🔄 Iniciando NordVPN..."
    /etc/init.d/nordvpn start || {
        echo "❌ Error al iniciar NordVPN"
        exit 1
    }

    sleep 5

    echo "✅ NordVPN está funcionando."
}

login() {
    echo "🔑 Iniciando sesión en NordVPN con token..."
    nordvpn login --token "${NORDVPN_TOKEN}" || {
        echo "❌ Error al iniciar sesión en NordVPN"
        sleep 15
        exit 1
    }
}

vpn() {
    echo "🔗 Conectando a NordVPN..."
    nordvpn connect || {
        echo "❌ Error al conectar a NordVPN"
        exit 1
    }
}

mesh() {
    echo "🔗 Conectando a NordVPN Mesh..."
    nordvpn set meshnet on || {
        echo "❌ Error al conectar a NordVPN Mesh"
        exit 1
    }
}

vpn-mesh(){
    connect
    meshnet
}

start
login

${@}

nordvpn status
nordvpn settings
exec tail -f /dev/null