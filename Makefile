default: up

up:
	code *.code-workspace
	docker compose up -d

stop:
	docker compose stop

kill:
	docker compose kill

down:
	docker compose down

build:
	docker compose down
	docker compose build
	docker compose up -d

logs:
	docker compose logs
