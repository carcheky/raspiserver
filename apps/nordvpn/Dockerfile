FROM ubuntu:24.04

# Instala dependencias necesarias y NordVPN
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        wget \
        apt-transport-https \
        ca-certificates && \
    wget -qO /etc/apt/trusted.gpg.d/nordvpn_public.asc https://repo.nordvpn.com/gpg/nordvpn_public.asc && \
    echo "deb https://repo.nordvpn.com/deb/nordvpn/debian stable main" > /etc/apt/sources.list.d/nordvpn.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends nordvpn && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Copia el entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Define el entrypoint
ENTRYPOINT ["/entrypoint.sh"]
CMD ["bash"]
