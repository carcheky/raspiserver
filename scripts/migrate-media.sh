mkdir -p apps/mediaserver/volumes/jellyfin-config
mkdir -p apps/mediaserver/volumes/jellyfin-intros
mkdir -p apps/mediaserver/volumes/wizarr-database
mkdir -p apps/mediaserver/volumes/jellyseerr-config
mkdir -p apps/mediaserver/volumes/transmission-config
mkdir -p apps/mediaserver/volumes/prowlarr-config
mkdir -p apps/mediaserver/volumes/radarr-config
mkdir -p apps/mediaserver/volumes/sonarr-config
mkdir -p apps/mediaserver/volumes/bazarr-config

rsync -arv /home/carcheky/mediacheky/RASPICONFIG/jellyfin/config/ apps/mediaserver/volumes/jellyfin-config/
rsync -arv /home/carcheky/mediacheky/RASPICONFIG/jellyfin/intros/ apps/mediaserver/volumes/jellyfin-intros/
rsync -arv /home/carcheky/mediacheky/RASPICONFIG/wizarr/database/ apps/mediaserver/volumes/wizarr-database/
rsync -arv /home/carcheky/mediacheky/RASPICONFIG/jellyseerr/config/ apps/mediaserver/volumes/jellyseerr-config/
rsync -arv /home/carcheky/mediacheky/RASPICONFIG/transmission/config/ apps/mediaserver/volumes/transmission-config/
rsync -arv /home/carcheky/mediacheky/RASPICONFIG/prowlarr/config/ apps/mediaserver/volumes/prowlarr-config/
rsync -arv /home/carcheky/mediacheky/RASPICONFIG/radarr/config/ apps/mediaserver/volumes/radarr-config/
rsync -arv /home/carcheky/mediacheky/RASPICONFIG/sonarr/config/ apps/mediaserver/volumes/sonarr-config/
rsync -arv /home/carcheky/mediacheky/RASPICONFIG/bazarr/config// apps/mediaserver/volumes/bazarr-config/

