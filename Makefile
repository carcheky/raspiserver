# main: funciones.o
# 	gcc -o main main.c funciones.o

# funciones.o: funciones.c header.h
# 	gcc -c funciones.c

default: start


start: .env
	@echo "Starting raspiserver..."
	@docker compose up -d

stop: .env
	@echo "Stopping raspiserver..."
	@docker compose down

restart: .env
	@echo "Restarting raspiserver..."
	@docker compose restart

ha: .env
	@echo "Starting Home Assistant..."
	@docker compose up -d homeassistant --force-recreate

jf: .env
	@echo "Starting JF..."
	@docker compose up -d jellyfin --force-recreate

orphans: .env
	@echo "Removing orphans..."
	@docker compose up -d --remove-orphans

prune: .env
	@echo "Pruning..."
	@docker system prune -a -f

kill: .env
	@echo "Killing all containers..."
	@docker kill $(docker ps -q)

recreate: .env
	@echo "Recreating all containers..."
	@docker compose up -d --force-recreate
