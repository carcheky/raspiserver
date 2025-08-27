# =============================================================================
# RaspiServer Makefile
# =============================================================================
# Convenient shortcuts for common RaspiServer operations
# Usage: make <target>
# =============================================================================

.PHONY: help setup up down restart logs status clean backup health update docs

# Default target
.DEFAULT_GOAL := help

# Variables
COMPOSE_FILE := docker-compose.yml
ENV_FILE := .env

# =============================================================================
# HELP & INFORMATION
# =============================================================================

help: ## Show this help message
	@echo "RaspiServer Management Commands"
	@echo "==============================="
	@echo ""
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)
	@echo ""
	@echo "Examples:"
	@echo "  make setup     # Initial setup"
	@echo "  make up        # Start all services"
	@echo "  make logs      # View service logs"
	@echo "  make health    # Run health check"
	@echo ""

# =============================================================================
# SETUP & INITIALIZATION
# =============================================================================

setup: ## Initial setup - copy configuration templates
	@echo "Setting up RaspiServer..."
	@echo "🔄 Initializing git submodules..."
	@git submodule update --init --recursive
	@echo "✓ Git submodules initialized"
	@if [ ! -f $(ENV_FILE) ]; then \
		cp .env.dist $(ENV_FILE); \
		echo "✓ Created .env file from template"; \
		echo "⚠ Please edit .env with your settings"; \
	else \
		echo "✓ .env file already exists"; \
	fi
	@if [ ! -f $(COMPOSE_FILE) ]; then \
		cp docker-compose.example.yml $(COMPOSE_FILE); \
		echo "✓ Created docker-compose.yml from template"; \
		echo "⚠ Please edit docker-compose.yml to enable desired services"; \
	else \
		echo "✓ docker-compose.yml already exists"; \
	fi
	@mkdir -p volumes backups
	@echo "✓ Created necessary directories"
	@echo "📚 Next steps:"
	@echo "   1. Edit .env with your configuration"
	@echo "   2. Edit docker-compose.yml to enable services"
	@echo "   3. Run 'make up' to start services"

check-env: ## Check if environment is properly configured
	@if [ ! -f $(ENV_FILE) ]; then \
		echo "❌ .env file not found. Run 'make setup' first."; \
		exit 1; \
	fi
	@if [ ! -f $(COMPOSE_FILE) ]; then \
		echo "❌ docker-compose.yml not found. Run 'make setup' first."; \
		exit 1; \
	fi

# =============================================================================
# SERVICE MANAGEMENT
# =============================================================================

up: check-env ## Start all services
	@echo "🚀 Starting RaspiServer services..."
	@docker-compose up -d --remove-orphans
	@echo "✅ Services started successfully"
	@echo "💡 Use 'make status' to check service health"

down: check-env ## Stop all services
	@echo "🛑 Stopping RaspiServer services..."
	@docker-compose down
	@echo "✅ Services stopped successfully"

restart: check-env ## Restart all services
	@echo "🔄 Restarting RaspiServer services..."
	@docker-compose restart
	@echo "✅ Services restarted successfully"

pull: check-env ## Pull latest images without starting
	@echo "📥 Pulling latest Docker images..."
	@docker-compose pull
	@echo "✅ Images updated successfully"

update: check-env ## Update and restart services
	@echo "🔄 Updating RaspiServer services..."
	@docker-compose pull
	@docker-compose up -d --remove-orphans
	@echo "✅ Services updated successfully"

# =============================================================================
# MONITORING & MAINTENANCE
# =============================================================================

status: check-env ## Show service status
	@echo "📊 RaspiServer Service Status"
	@echo "=============================="
	@docker-compose ps --format "table {{.Name}}\t{{.Status}}\t{{.Ports}}"

logs: check-env ## Show service logs
	@echo "📋 Recent service logs:"
	@docker-compose logs --tail=50 --timestamps

logs-follow: check-env ## Follow service logs in real-time
	@docker-compose logs --follow --timestamps

logs-service: check-env ## Show logs for specific service (usage: make logs-service SERVICE=jellyfin)
	@if [ -z "$(SERVICE)" ]; then \
		echo "❌ Please specify SERVICE. Example: make logs-service SERVICE=jellyfin"; \
		exit 1; \
	fi
	@docker-compose logs --tail=100 --timestamps $(SERVICE)

health: ## Run comprehensive health check
	@echo "🏥 Running RaspiServer health check..."
	@./scripts/health-check.sh

# =============================================================================
# BACKUP & RESTORE
# =============================================================================

backup: ## Create a backup of configurations
	@echo "💾 Creating RaspiServer backup..."
	@./scripts/backup.sh

backup-full: ## Create a full backup including volumes
	@echo "💾 Creating full RaspiServer backup (including volumes)..."
	@./scripts/backup.sh --include-volumes

backup-dry-run: ## Show what would be backed up
	@echo "🔍 Backup dry run..."
	@./scripts/backup.sh --dry-run

# =============================================================================
# DEVELOPMENT & DEBUGGING
# =============================================================================

shell: check-env ## Open shell in a service container (usage: make shell SERVICE=jellyfin)
	@if [ -z "$(SERVICE)" ]; then \
		echo "❌ Please specify SERVICE. Example: make shell SERVICE=jellyfin"; \
		exit 1; \
	fi
	@docker-compose exec $(SERVICE) /bin/bash

debug: check-env ## Show debug information
	@echo "🔍 RaspiServer Debug Information"
	@echo "================================"
	@echo "Docker version:"
	@docker --version
	@echo ""
	@echo "Docker Compose version:"
	@docker-compose --version
	@echo ""
	@echo "System resources:"
	@free -h
	@echo ""
	@echo "Disk usage:"
	@df -h .
	@echo ""
	@echo "Docker system info:"
	@docker system df

validate: check-env ## Validate docker-compose configuration
	@echo "✅ Validating configuration..."
	@docker-compose config > /dev/null
	@echo "✅ Configuration is valid"

# =============================================================================
# CLEANUP & MAINTENANCE
# =============================================================================

clean: ## Clean unused Docker resources
	@echo "🧹 Cleaning unused Docker resources..."
	@docker container prune -f
	@docker image prune -f
	@docker network prune -f
	@echo "✅ Cleanup completed"

clean-all: ## Clean all Docker resources (WARNING: removes everything)
	@echo "⚠️  This will remove ALL unused Docker resources!"
	@read -p "Are you sure? [y/N] " -n 1 -r; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		echo ""; \
		docker system prune -a -f --volumes; \
		echo "✅ Full cleanup completed"; \
	else \
		echo ""; \
		echo "❌ Cleanup cancelled"; \
	fi

reset: ## Reset to clean state (stops services, removes containers)
	@echo "🔄 Resetting RaspiServer to clean state..."
	@docker-compose down --volumes --remove-orphans
	@echo "✅ Reset completed"

# =============================================================================
# DOCUMENTATION
# =============================================================================

docs: ## Open documentation in browser
	@echo "📚 Opening documentation..."
	@if command -v xdg-open > /dev/null; then \
		xdg-open docs/README.md; \
	elif command -v open > /dev/null; then \
		open docs/README.md; \
	else \
		echo "📖 Documentation available at: docs/README.md"; \
	fi

# =============================================================================
# SHORTCUTS FOR COMMON SERVICES
# =============================================================================

jellyfin: check-env ## Start only Jellyfin
	@docker-compose up -d jellyfin

homeassistant: check-env ## Start only Home Assistant  
	@docker-compose up -d homeassistant

media-stack: check-env ## Start media management stack
	@docker-compose up -d jellyfin sonarr radarr jellyseerr qbittorrent

# =============================================================================
# SPECIAL TARGETS
# =============================================================================

# Support for dynamic service targets (e.g., make start-jellyfin)
start-%: check-env
	@echo "🚀 Starting service: $*"
	@docker-compose up -d $*

stop-%: check-env
	@echo "🛑 Stopping service: $*"
	@docker-compose stop $*

restart-%: check-env
	@echo "🔄 Restarting service: $*"
	@docker-compose restart $*

logs-%: check-env
	@echo "📋 Logs for service: $*"
	@docker-compose logs --tail=50 --timestamps $*
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

pl: .env
	@echo "Starting prowlarr..."
	@docker compose up prowlarr -d --force-recreate

pll: .env
	@make pl
	@docker compose logs prowlarr -f

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
	@docker compose up -d --force-recreate --remove-orphans

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
	@git merge beta --no-edit && git push 
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


# =============================================================================
# REVERSE PROXY MANAGEMENT
# =============================================================================

migrate-nginx: ## Migrate from Traefik to docker-gen + nginx
	@echo "🔄 Migrating from Traefik to docker-gen + nginx..."
	@./scripts/migrate-to-nginx-proxy.sh

setup-nginx: ## Setup directories for nginx reverse proxy
	@echo "📁 Setting up nginx directories..."
	@mkdir -p volumes/nginx/{conf.d,certs,vhost.d,html,acme}
	@echo "✅ Nginx directories created"

nginx-config: check-env ## Generate nginx configuration (trigger docker-gen)
	@echo "🔧 Regenerating nginx configuration..."
	@docker-compose kill -s HUP docker-gen || echo "docker-gen not running"
	@echo "✅ Configuration regenerated"

nginx-logs: check-env ## Show nginx logs
	@docker-compose logs --tail=50 --timestamps nginx docker-gen

# =============================================================================
# SPECIAL TARGETS
# =============================================================================

sv:
	ifneq ($(service),)
		docker compose up -d --remove-orphans --force-recrate $(service)
	else
		docker compose up -d --remove-orphans --force-recrate
	endif