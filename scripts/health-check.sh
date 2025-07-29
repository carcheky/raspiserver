#!/bin/bash

# =============================================================================
# RaspiServer System Health Check Script
# =============================================================================
# This script performs comprehensive health checks on the RaspiServer platform
# =============================================================================

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(dirname "$SCRIPT_DIR")"

# Configuration
COMPOSE_FILE="${BASE_DIR}/docker-compose.yml"
ENV_FILE="${BASE_DIR}/.env"

# =============================================================================
# UTILITY FUNCTIONS
# =============================================================================

print_header() {
    echo -e "\n${BLUE}=== $1 ===${NC}"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

# =============================================================================
# HEALTH CHECK FUNCTIONS
# =============================================================================

check_prerequisites() {
    print_header "System Prerequisites"
    
    # Check Docker
    if command -v docker &> /dev/null; then
        local docker_version=$(docker --version | cut -d' ' -f3 | cut -d',' -f1)
        print_success "Docker installed: $docker_version"
    else
        print_error "Docker is not installed"
        return 1
    fi
    
    # Check Docker Compose
    if command -v docker-compose &> /dev/null; then
        local compose_version=$(docker-compose --version | cut -d' ' -f3 | cut -d',' -f1)
        print_success "Docker Compose installed: $compose_version"
    else
        print_error "Docker Compose is not installed"
        return 1
    fi
    
    # Check Docker service
    if systemctl is-active --quiet docker; then
        print_success "Docker service is running"
    else
        print_error "Docker service is not running"
        return 1
    fi
    
    # Check user groups
    if groups $USER | grep -q docker; then
        print_success "User is in docker group"
    else
        print_warning "User is not in docker group - you may need sudo"
    fi
}

check_configuration() {
    print_header "Configuration Files"
    
    # Check .env file
    if [[ -f "$ENV_FILE" ]]; then
        print_success ".env file exists"
        
        # Check for required variables
        local required_vars=("PUID" "PGID" "TIMEZONE" "VOLUMES_DIR")
        for var in "${required_vars[@]}"; do
            if grep -q "^$var=" "$ENV_FILE"; then
                local value=$(grep "^$var=" "$ENV_FILE" | cut -d'=' -f2)
                print_success "$var is set: $value"
            else
                print_error "$var is not set in .env"
            fi
        done
    else
        print_error ".env file not found"
        print_info "Copy .env.dist to .env and configure it"
        return 1
    fi
    
    # Check docker-compose.yml
    if [[ -f "$COMPOSE_FILE" ]]; then
        print_success "docker-compose.yml exists"
        
        # Validate compose file
        if docker-compose -f "$COMPOSE_FILE" config > /dev/null 2>&1; then
            print_success "docker-compose.yml is valid"
        else
            print_error "docker-compose.yml has syntax errors"
            return 1
        fi
    else
        print_error "docker-compose.yml not found"
        print_info "Copy docker-compose.example.yml to docker-compose.yml"
        return 1
    fi
}

check_directories() {
    print_header "Directory Structure"
    
    # Source .env file to get variables
    if [[ -f "$ENV_FILE" ]]; then
        source "$ENV_FILE"
    fi
    
    local directories=(
        "${BASE_DIR}/volumes"
        "${BASE_DIR}/services" 
        "${BASE_DIR}/configs"
        "${BASE_DIR}/docs"
    )
    
    for dir in "${directories[@]}"; do
        if [[ -d "$dir" ]]; then
            print_success "$(basename "$dir")/ directory exists"
        else
            print_warning "$(basename "$dir")/ directory missing"
        fi
    done
    
    # Check volumes directory permissions
    if [[ -d "${BASE_DIR}/volumes" ]]; then
        local volume_owner=$(stat -c '%U' "${BASE_DIR}/volumes")
        if [[ "$volume_owner" == "$USER" ]]; then
            print_success "volumes/ directory has correct ownership"
        else
            print_warning "volumes/ directory owner: $volume_owner (expected: $USER)"
        fi
    fi
}

check_services() {
    print_header "Docker Services"
    
    if [[ ! -f "$COMPOSE_FILE" ]]; then
        print_error "docker-compose.yml not found, skipping service checks"
        return 1
    fi
    
    # Get list of services
    local services
    if ! services=$(docker-compose -f "$COMPOSE_FILE" config --services 2>/dev/null); then
        print_error "Could not get service list from docker-compose.yml"
        return 1
    fi
    
    if [[ -z "$services" ]]; then
        print_warning "No services configured in docker-compose.yml"
        return 0
    fi
    
    print_info "Configured services: $(echo "$services" | wc -l)"
    
    # Check each service
    while IFS= read -r service; do
        local status
        if status=$(docker-compose -f "$COMPOSE_FILE" ps -q "$service" 2>/dev/null); then
            if [[ -n "$status" ]]; then
                local container_status
                container_status=$(docker inspect --format='{{.State.Status}}' "$status" 2>/dev/null || echo "unknown")
                case "$container_status" in
                    "running")
                        print_success "$service: running"
                        ;;
                    "exited")
                        print_error "$service: exited"
                        ;;
                    "restarting")
                        print_warning "$service: restarting"
                        ;;
                    *)
                        print_warning "$service: $container_status"
                        ;;
                esac
            else
                print_warning "$service: not started"
            fi
        else
            print_error "$service: error checking status"
        fi
    done <<< "$services"
}

check_system_resources() {
    print_header "System Resources"
    
    # Memory usage
    local mem_info
    mem_info=$(free -h | grep '^Mem:')
    local mem_total=$(echo "$mem_info" | awk '{print $2}')
    local mem_used=$(echo "$mem_info" | awk '{print $3}')
    local mem_available=$(echo "$mem_info" | awk '{print $7}')
    
    print_info "Memory: $mem_used used / $mem_total total ($mem_available available)"
    
    # Disk usage
    local disk_info
    disk_info=$(df -h "${BASE_DIR}" | tail -1)
    local disk_used=$(echo "$disk_info" | awk '{print $5}' | sed 's/%//')
    local disk_total=$(echo "$disk_info" | awk '{print $2}')
    local disk_available=$(echo "$disk_info" | awk '{print $4}')
    
    print_info "Disk: ${disk_used}% used ($disk_available available / $disk_total total)"
    
    if [[ $disk_used -gt 90 ]]; then
        print_error "Disk usage is critically high (${disk_used}%)"
    elif [[ $disk_used -gt 80 ]]; then
        print_warning "Disk usage is high (${disk_used}%)"
    else
        print_success "Disk usage is normal (${disk_used}%)"
    fi
    
    # Docker system info
    if command -v docker &> /dev/null && systemctl is-active --quiet docker; then
        local docker_info
        docker_info=$(docker system df --format "table {{.Type}}\t{{.TotalCount}}\t{{.Size}}" 2>/dev/null || echo "")
        if [[ -n "$docker_info" ]]; then
            print_info "Docker system usage:"
            echo "$docker_info" | sed 's/^/  /'
        fi
    fi
}

check_network() {
    print_header "Network Connectivity"
    
    # Check internet connectivity
    if ping -c 1 8.8.8.8 > /dev/null 2>&1; then
        print_success "Internet connectivity available"
    else
        print_error "No internet connectivity"
    fi
    
    # Check Docker networks
    if command -v docker &> /dev/null; then
        local networks
        networks=$(docker network ls --format "{{.Name}}" 2>/dev/null || echo "")
        if [[ -n "$networks" ]]; then
            print_info "Docker networks:"
            echo "$networks" | sed 's/^/  /'
        fi
    fi
    
    # Check port availability
    local common_ports=(80 443 8096 8123 8989 7878)
    for port in "${common_ports[@]}"; do
        if netstat -tuln 2>/dev/null | grep -q ":$port "; then
            print_info "Port $port is in use"
        fi
    done
}

show_logs() {
    print_header "Recent Service Logs"
    
    if [[ ! -f "$COMPOSE_FILE" ]]; then
        print_error "docker-compose.yml not found, cannot show logs"
        return 1
    fi
    
    local services
    services=$(docker-compose -f "$COMPOSE_FILE" ps --services 2>/dev/null || echo "")
    
    if [[ -z "$services" ]]; then
        print_info "No running services found"
        return 0
    fi
    
    print_info "Recent logs from running services:"
    docker-compose -f "$COMPOSE_FILE" logs --tail=5 --timestamps 2>/dev/null || true
}

# =============================================================================
# MAIN FUNCTION
# =============================================================================

main() {
    echo -e "${BLUE}"
    echo "┌─────────────────────────────────────────────────────────────┐"
    echo "│                  RaspiServer Health Check                  │"
    echo "└─────────────────────────────────────────────────────────────┘"
    echo -e "${NC}"
    
    local exit_code=0
    
    # Run all checks
    check_prerequisites || exit_code=1
    check_configuration || exit_code=1
    check_directories
    check_services
    check_system_resources
    check_network
    
    # Show logs if requested
    if [[ "${1:-}" == "--logs" ]] || [[ "${1:-}" == "-l" ]]; then
        show_logs
    fi
    
    # Summary
    print_header "Health Check Summary"
    if [[ $exit_code -eq 0 ]]; then
        print_success "System appears healthy"
        print_info "Use --logs flag to see recent service logs"
    else
        print_error "Issues detected - please review the output above"
        print_info "Check the documentation: docs/TROUBLESHOOTING.md"
    fi
    
    return $exit_code
}

# =============================================================================
# SCRIPT EXECUTION
# =============================================================================

# Show help if requested
if [[ "${1:-}" == "--help" ]] || [[ "${1:-}" == "-h" ]]; then
    echo "RaspiServer Health Check Script"
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -h, --help     Show this help message"
    echo "  -l, --logs     Show recent service logs"
    echo ""
    echo "This script checks:"
    echo "  • System prerequisites (Docker, Docker Compose)"
    echo "  • Configuration files (.env, docker-compose.yml)"
    echo "  • Directory structure and permissions"
    echo "  • Service status and health"
    echo "  • System resources (memory, disk, network)"
    echo ""
    exit 0
fi

# Change to base directory
cd "$BASE_DIR"

# Run main function
main "$@"
