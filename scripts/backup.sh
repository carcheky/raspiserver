#!/bin/bash

# =============================================================================
# RaspiServer Backup Script
# =============================================================================
# This script creates comprehensive backups of the RaspiServer configuration
# and data, allowing for easy restoration if needed.
# =============================================================================

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(dirname "$SCRIPT_DIR")"
BACKUP_DIR="${BASE_DIR}/backups"
TIMESTAMP=$(date '+%Y%m%d_%H%M%S')
BACKUP_NAME="raspiserver_backup_${TIMESTAMP}"

# Default settings
COMPRESS=true
INCLUDE_VOLUMES=false
INCLUDE_MEDIA=false
KEEP_BACKUPS=7  # Number of backups to keep

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

show_help() {
    cat << EOF
RaspiServer Backup Script

Usage: $0 [OPTIONS]

Options:
    -h, --help              Show this help message
    -o, --output DIR        Backup directory (default: ./backups)
    -n, --name NAME         Backup name prefix (default: raspiserver_backup)
    --no-compress           Don't compress the backup
    --include-volumes       Include Docker volumes in backup
    --include-media         Include media files in backup (WARNING: large!)
    --keep NUM              Number of backups to keep (default: 7)
    --dry-run               Show what would be backed up without doing it

Backup includes:
    • Configuration files (.env, docker-compose.yml)
    • Service configurations (configs/)
    • Documentation (docs/)
    • Scripts and utilities
    • Docker service definitions

Optional (with flags):
    • Docker volumes (container data)
    • Media files (movies, TV shows, etc.)

Examples:
    $0                      # Basic backup
    $0 --include-volumes    # Include container data
    $0 --dry-run           # Preview what will be backed up
    $0 -o /mnt/backup      # Backup to different location

EOF
}

# =============================================================================
# BACKUP FUNCTIONS
# =============================================================================

validate_environment() {
    print_header "Validating Environment"
    
    # Check if we're in the right directory
    if [[ ! -f "${BASE_DIR}/docker-compose.yml" ]] && [[ ! -f "${BASE_DIR}/docker-compose.example.yml" ]]; then
        print_error "Not in RaspiServer directory (no docker-compose files found)"
        exit 1
    fi
    
    # Create backup directory
    if [[ ! -d "$BACKUP_DIR" ]]; then
        mkdir -p "$BACKUP_DIR"
        print_success "Created backup directory: $BACKUP_DIR"
    else
        print_success "Backup directory exists: $BACKUP_DIR"
    fi
    
    # Check available space
    local available_space
    available_space=$(df -BG "$BACKUP_DIR" | awk 'NR==2 {print $4}' | sed 's/G//')
    
    if [[ $available_space -lt 1 ]]; then
        print_error "Insufficient disk space for backup (less than 1GB available)"
        exit 1
    else
        print_success "Available disk space: ${available_space}GB"
    fi
}

create_backup_structure() {
    print_header "Creating Backup Structure"
    
    local backup_path="${BACKUP_DIR}/${BACKUP_NAME}"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        print_info "[DRY RUN] Would create: $backup_path"
        return 0
    fi
    
    mkdir -p "$backup_path"
    print_success "Created backup directory: $backup_path"
    
    # Create backup info file
    cat > "${backup_path}/backup_info.txt" << EOF
RaspiServer Backup Information
==============================

Backup Date: $(date)
Backup Name: $BACKUP_NAME
Script Version: 1.0
Host: $(hostname)
User: $(whoami)
Base Directory: $BASE_DIR

Backup Contents:
EOF
    
    CURRENT_BACKUP_PATH="$backup_path"
}

backup_configurations() {
    print_header "Backing Up Configurations"
    
    local files_to_backup=(
        ".env"
        ".env.dist"
        "docker-compose.yml"
        "docker-compose.example.yml"
        "Makefile"
        "CHANGELOG.md"
    )
    
    for file in "${files_to_backup[@]}"; do
        if [[ -f "${BASE_DIR}/$file" ]]; then
            if [[ "$DRY_RUN" == "true" ]]; then
                print_info "[DRY RUN] Would backup: $file"
            else
                cp "${BASE_DIR}/$file" "${CURRENT_BACKUP_PATH}/"
                print_success "Backed up: $file"
                echo "  • $file" >> "${CURRENT_BACKUP_PATH}/backup_info.txt"
            fi
        else
            print_warning "File not found: $file"
        fi
    done
}

backup_directories() {
    print_header "Backing Up Directories"
    
    local dirs_to_backup=(
        "docs"
        "configs"
        "services"
        "scripts"
        "apps"
        "flags"
    )
    
    for dir in "${dirs_to_backup[@]}"; do
        if [[ -d "${BASE_DIR}/$dir" ]]; then
            if [[ "$DRY_RUN" == "true" ]]; then
                local size
                size=$(du -sh "${BASE_DIR}/$dir" | cut -f1)
                print_info "[DRY RUN] Would backup: $dir ($size)"
            else
                cp -r "${BASE_DIR}/$dir" "${CURRENT_BACKUP_PATH}/"
                local size
                size=$(du -sh "${CURRENT_BACKUP_PATH}/$dir" | cut -f1)
                print_success "Backed up: $dir ($size)"
                echo "  • $dir/ ($size)" >> "${CURRENT_BACKUP_PATH}/backup_info.txt"
            fi
        else
            print_warning "Directory not found: $dir"
        fi
    done
}

backup_volumes() {
    if [[ "$INCLUDE_VOLUMES" != "true" ]]; then
        print_info "Skipping volumes backup (use --include-volumes to enable)"
        return 0
    fi
    
    print_header "Backing Up Docker Volumes"
    
    if [[ ! -d "${BASE_DIR}/volumes" ]]; then
        print_warning "Volumes directory not found"
        return 0
    fi
    
    if [[ "$DRY_RUN" == "true" ]]; then
        local size
        size=$(du -sh "${BASE_DIR}/volumes" | cut -f1)
        print_info "[DRY RUN] Would backup: volumes ($size)"
        return 0
    fi
    
    # Stop services before backing up volumes
    print_info "Stopping services for volume backup..."
    if docker-compose -f "${BASE_DIR}/docker-compose.yml" down > /dev/null 2>&1; then
        print_success "Services stopped"
        
        # Backup volumes
        cp -r "${BASE_DIR}/volumes" "${CURRENT_BACKUP_PATH}/"
        local size
        size=$(du -sh "${CURRENT_BACKUP_PATH}/volumes" | cut -f1)
        print_success "Backed up: volumes ($size)"
        echo "  • volumes/ ($size)" >> "${CURRENT_BACKUP_PATH}/backup_info.txt"
        
        # Restart services
        print_info "Restarting services..."
        if docker-compose -f "${BASE_DIR}/docker-compose.yml" up -d > /dev/null 2>&1; then
            print_success "Services restarted"
        else
            print_warning "Could not restart services automatically"
        fi
    else
        print_warning "Could not stop services, skipping volume backup"
    fi
}

backup_media() {
    if [[ "$INCLUDE_MEDIA" != "true" ]]; then
        print_info "Skipping media backup (use --include-media to enable)"
        return 0
    fi
    
    print_header "Backing Up Media Files"
    
    # Source .env file if it exists to get MEDIA_DIR
    if [[ -f "${BASE_DIR}/.env" ]]; then
        source "${BASE_DIR}/.env"
    fi
    
    local media_dir="${MEDIA_DIR:-/mnt/media}"
    
    if [[ ! -d "$media_dir" ]]; then
        print_warning "Media directory not found: $media_dir"
        return 0
    fi
    
    if [[ "$DRY_RUN" == "true" ]]; then
        local size
        size=$(du -sh "$media_dir" | cut -f1)
        print_info "[DRY RUN] Would backup: media files ($size)"
        print_warning "[DRY RUN] This could be very large!"
        return 0
    fi
    
    print_warning "Media backup can be very large and time-consuming!"
    read -p "Are you sure you want to continue? (y/N): " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        mkdir -p "${CURRENT_BACKUP_PATH}/media"
        cp -r "$media_dir"/* "${CURRENT_BACKUP_PATH}/media/" 2>/dev/null || true
        local size
        size=$(du -sh "${CURRENT_BACKUP_PATH}/media" | cut -f1)
        print_success "Backed up: media files ($size)"
        echo "  • media/ ($size)" >> "${CURRENT_BACKUP_PATH}/backup_info.txt"
    else
        print_info "Skipping media backup"
    fi
}

compress_backup() {
    if [[ "$COMPRESS" != "true" ]] || [[ "$DRY_RUN" == "true" ]]; then
        return 0
    fi
    
    print_header "Compressing Backup"
    
    local archive_path="${BACKUP_DIR}/${BACKUP_NAME}.tar.gz"
    
    if tar -czf "$archive_path" -C "$BACKUP_DIR" "$BACKUP_NAME"; then
        local original_size
        local compressed_size
        original_size=$(du -sh "${CURRENT_BACKUP_PATH}" | cut -f1)
        compressed_size=$(du -sh "$archive_path" | cut -f1)
        
        print_success "Created compressed backup: $archive_path"
        print_info "Original size: $original_size"
        print_info "Compressed size: $compressed_size"
        
        # Remove uncompressed backup
        rm -rf "${CURRENT_BACKUP_PATH}"
        print_success "Removed uncompressed backup"
    else
        print_error "Failed to compress backup"
        return 1
    fi
}

cleanup_old_backups() {
    if [[ "$DRY_RUN" == "true" ]]; then
        print_info "[DRY RUN] Would clean up old backups (keeping $KEEP_BACKUPS)"
        return 0
    fi
    
    print_header "Cleaning Up Old Backups"
    
    # Find and remove old backups
    local old_backups
    old_backups=$(find "$BACKUP_DIR" -name "raspiserver_backup_*" -type f -o -name "raspiserver_backup_*" -type d | sort -r | tail -n +$((KEEP_BACKUPS + 1)))
    
    if [[ -n "$old_backups" ]]; then
        while IFS= read -r backup; do
            rm -rf "$backup"
            print_success "Removed old backup: $(basename "$backup")"
        done <<< "$old_backups"
    else
        print_info "No old backups to clean up"
    fi
}

# =============================================================================
# MAIN FUNCTION
# =============================================================================

main() {
    echo -e "${BLUE}"
    echo "┌─────────────────────────────────────────────────────────────┐"
    echo "│                   RaspiServer Backup Tool                  │"
    echo "└─────────────────────────────────────────────────────────────┘"
    echo -e "${NC}"
    
    validate_environment
    create_backup_structure
    
    # Create backup
    backup_configurations
    backup_directories
    backup_volumes
    backup_media
    
    if [[ "$DRY_RUN" != "true" ]]; then
        compress_backup
        cleanup_old_backups
        
        print_header "Backup Complete"
        print_success "Backup created successfully"
        
        if [[ "$COMPRESS" == "true" ]]; then
            print_info "Backup location: ${BACKUP_DIR}/${BACKUP_NAME}.tar.gz"
        else
            print_info "Backup location: ${CURRENT_BACKUP_PATH}"
        fi
        
        print_info "To restore this backup, see: docs/TROUBLESHOOTING.md"
    else
        print_header "Dry Run Complete"
        print_info "This was a dry run - no files were actually backed up"
    fi
}

# =============================================================================
# ARGUMENT PARSING
# =============================================================================

# Initialize variables
DRY_RUN=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -o|--output)
            BACKUP_DIR="$2"
            shift 2
            ;;
        -n|--name)
            BACKUP_NAME="$2_${TIMESTAMP}"
            shift 2
            ;;
        --no-compress)
            COMPRESS=false
            shift
            ;;
        --include-volumes)
            INCLUDE_VOLUMES=true
            shift
            ;;
        --include-media)
            INCLUDE_MEDIA=true
            shift
            ;;
        --keep)
            KEEP_BACKUPS="$2"
            shift 2
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        *)
            print_error "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# Run main function
cd "$BASE_DIR"
main
