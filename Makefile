ifeq (feature,$(firstword $(MAKECMDGOALS)))
  name := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
  $(eval $(name):;@:)
endif


default: start


up: .env
	@echo "Starting raspiserver..."
	@docker compose up -d --remove-orphans

stop: .env
	@echo "Stopping raspiserver..."
	@docker compose down

restart: .env
	@echo "Restarting raspiserver..."
	@docker compose restart

swag: .env
	@echo "Starting Swag..."
	@docker compose up swag -d --force-recreate

swagl: .env
	@make swag
	@docker compose logs swag -f

ha: .env
	@echo "Starting Home Assistant..."
	@docker compose up homeassistant -d --force-recreate

hal: .env
	@make ha
	@docker compose logs homeassistant -f

jf: .env
	@echo "Starting JF..."
	@docker compose up jellyfin -d --force-recreate

jfl: .env
	@make jf
	@docker compose logs jellyfin -f

ra: .env
	@echo "Starting room-assistant..."
	@docker compose up room-assistant -d --force-recreate

ral: .env
	@make ra
	@docker compose logs room-assistant -f

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

# pull changes in stable branch then
# merge latest changes in stable branch into beta branch
beta-update: .env
	@echo "Pulling changes in stable branch..."
	@git checkout stable
	@git pull
	@echo "Merging latest changes in stable branch into beta branch..."
	@git checkout beta
	@git merge stable --no-edit
	@git push

# pull changes in beta branch then
# merge latest changes in beta branch into stable branch
release: .env
	@echo "Pulling changes in stable branch..."
	@git checkout stable
	@git pull
	@echo "Merging latest changes in stable branch into beta branch..."
	@git checkout beta
	@git merge stable --no-edit
	@git push
	@echo "Pulling changes in beta branch..."
	@git checkout beta
	@git pull
	@echo "Merging latest changes in beta branch into stable branch..."
	@git checkout stable
	@git merge beta --no-edit
	@git push
	@git checkout beta

commit: .env
	@echo "Committing changes..."
	@cz c
	@git push

feature:
	@echo "Creating new feature branch..."
	@git checkout -b feature/$(name)

clean:
	@git branch | grep -v "master" | xargs git branch -D
