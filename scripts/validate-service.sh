#!/bin/bash

# =============================================================================
# Individual Service Validator
# =============================================================================
# Validates a single service configuration and functionality
# Usage: ./validate-service.sh [SERVICE_NAME] [CATEGORY]
# Example: ./validate-service.sh jellyfin multimedia
# =============================================================================

# Configuration
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SERVICES_DIR="${REPO_ROOT}/services"
TIMEOUT=60

# Create temporary env file for validation
TEST_ENV_FILE="/tmp/raspiserver-validation.env"
cat > "$TEST_ENV_FILE" << EOF
PUID=1000
PGID=1000
TIMEZONE=UTC
DOMAIN=localhost
VOLUMES_DIR=/tmp/volumes
MEDIA_DIR=/tmp/media
DOWNLOADS_DIR=/tmp/downloads
CONFIG_DIR=/tmp/config

# Common service ports (will be overridden by actual values)
JELLYFIN_PORT=8096
PLEX_PORT=32400
SONARR_PORT=8989
RADARR_PORT=7878
JELLYSEERR_PORT=5055
QBITTORRENT_PORT=8080
PROWLARR_PORT=9696
BAZARR_PORT=6767
LIDARR_PORT=8686
READARR_PORT=8787
MYLAR3_PORT=8090
HOMEASSISTANT_PORT=8123
PORTAINER_PORT=9000
PIHOLE_PORT=80
NEXTCLOUD_PORT=8081
ADGUARDHOME_PORT=3000
UPTIME_KUMA_PORT=3001
WATCHTOWER_PORT=8080
NETDATA_PORT=19999
HOMARR_PORT=7575
DOCKGE_PORT=5001
RASPISERVER_ADMIN_PORT=5000
N8N_PORT=5678
ACTIVEPIECES_PORT=8080
ESPHOME_PORT=6052
KENER_PORT=3000
AUTHELIA_PORT=9091
CLOUDFLARED_PORT=8080
TELEGRAF_PORT=8125
EOF

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}ℹ${NC}  $1"
}

print_success() {
    echo -e "${GREEN}✅${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC}  $1"
}

print_error() {
    echo -e "${RED}❌${NC} $1"
}

print_test() {
    echo -e "${NC}🧪 Testing: $1${NC}"
}

# Usage function
usage() {
    echo "Usage: $0 [SERVICE_NAME] [CATEGORY]"
    echo
    echo "Available categories:"
    for cat in automation management multimedia network others productivity; do
        echo "  - $cat"
    done
    echo
    echo "Examples:"
    echo "  $0 jellyfin multimedia"
    echo "  $0 homeassistant automation"
    echo "  $0 nextcloud productivity"
    echo
    echo "Or use auto-discovery:"
    echo "  $0 jellyfin"
    exit 1
}

# Auto-discover service category
find_service_category() {
    local service_name="$1"
    
    for category in automation management multimedia network others productivity; do
        if [ -f "$SERVICES_DIR/$category/$service_name.yml" ]; then
            echo "$category"
            return 0
        fi
    done
    
    return 1
}

# Validate arguments
if [ $# -eq 0 ]; then
    usage
fi

SERVICE_NAME="$1"
SERVICE_CATEGORY="$2"

# Auto-discover category if not provided
if [ -z "$SERVICE_CATEGORY" ]; then
    print_status "🔍 Auto-discovering category for service: $SERVICE_NAME"
    if SERVICE_CATEGORY=$(find_service_category "$SERVICE_NAME"); then
        print_success "Found service in category: $SERVICE_CATEGORY"
    else
        print_error "Service '$SERVICE_NAME' not found in any category"
        usage
    fi
fi

SERVICE_FILE="$SERVICES_DIR/$SERVICE_CATEGORY/$SERVICE_NAME.yml"

# Check if service file exists
if [ ! -f "$SERVICE_FILE" ]; then
    print_error "Service file not found: $SERVICE_FILE"
    exit 1
fi

print_status "🔍 Validating service: $SERVICE_NAME"
print_status "📁 Category: $SERVICE_CATEGORY"
print_status "📄 File: $SERVICE_FILE"
echo

# Test results tracking
TESTS_PASSED=0
TESTS_FAILED=0
TESTS_WARNINGS=0

# Function to record test result
record_result() {
    local status="$1"
    local message="$2"
    
    case "$status" in
        "PASS")
            print_success "$message"
            ((TESTS_PASSED++))
            ;;
        "FAIL")
            print_error "$message"
            ((TESTS_FAILED++))
            ;;
        "WARN")
            print_warning "$message"
            ((TESTS_WARNINGS++))
            ;;
    esac
}

# Test 1: YAML Syntax Validation
print_test "YAML Syntax Validation"
# Try docker compose first, then docker-compose
if command -v docker >/dev/null 2>&1 && docker compose --env-file "$TEST_ENV_FILE" -f "$SERVICE_FILE" config > /dev/null 2>&1; then
    record_result "PASS" "YAML syntax is valid (docker compose)"
elif command -v docker-compose >/dev/null 2>&1 && docker-compose --env-file "$TEST_ENV_FILE" -f "$SERVICE_FILE" config > /dev/null 2>&1; then
    record_result "PASS" "YAML syntax is valid (docker-compose)"
else
    if command -v docker >/dev/null 2>&1; then
        # Try to get more detailed error
        error_output=$(docker compose --env-file "$TEST_ENV_FILE" -f "$SERVICE_FILE" config 2>&1)
        record_result "FAIL" "YAML syntax errors found"
        echo "Error details: $error_output"
    elif command -v docker-compose >/dev/null 2>&1; then
        error_output=$(docker-compose --env-file "$TEST_ENV_FILE" -f "$SERVICE_FILE" config 2>&1)
        record_result "FAIL" "YAML syntax errors found" 
        echo "Error details: $error_output"
    else
        record_result "WARN" "Docker not available for syntax validation"
    fi
fi

# Test 2: Service Standards Compliance
print_test "Service Standards Compliance"
compliance_issues=0

# Check for required fields
if ! grep -q "restart:" "$SERVICE_FILE"; then
    record_result "WARN" "Missing restart policy"
    ((compliance_issues++))
fi

if ! grep -q "unless-stopped" "$SERVICE_FILE"; then
    record_result "WARN" "Restart policy should be 'unless-stopped'"
    ((compliance_issues++))
fi

# Check for standard environment variables
if ! grep -q "PUID" "$SERVICE_FILE"; then
    record_result "WARN" "Missing PUID environment variable"
    ((compliance_issues++))
fi

if ! grep -q "PGID" "$SERVICE_FILE"; then
    record_result "WARN" "Missing PGID environment variable"
    ((compliance_issues++))
fi

if ! grep -q "TZ" "$SERVICE_FILE"; then
    record_result "WARN" "Missing TZ environment variable"
    ((compliance_issues++))
fi

if [ $compliance_issues -eq 0 ]; then
    record_result "PASS" "Service follows basic standards"
else
    record_result "WARN" "Service has $compliance_issues compliance issues"
fi

# Test 3: Container Name Validation
print_test "Container Name Validation"
if grep -q "container_name:" "$SERVICE_FILE"; then
    container_name=$(grep "container_name:" "$SERVICE_FILE" | awk '{print $2}' | tr -d '"' | head -1)
    if [ "$container_name" = "$SERVICE_NAME" ]; then
        record_result "PASS" "Container name matches service name"
    else
        record_result "WARN" "Container name '$container_name' differs from service name '$SERVICE_NAME'"
    fi
else
    record_result "WARN" "No container_name specified"
fi

# Test 4: Volume Configuration
print_test "Volume Configuration"
if grep -q "volumes:" "$SERVICE_FILE"; then
    volume_count=$(grep -A 20 "volumes:" "$SERVICE_FILE" | grep -c ":" || true)
    if [ $volume_count -gt 0 ]; then
        record_result "PASS" "Volume mappings configured"
    else
        record_result "WARN" "No volume mappings found"
    fi
else
    record_result "WARN" "No volumes section found"
fi

# Test 5: Port Configuration
print_test "Port Configuration"
if grep -q "ports:" "$SERVICE_FILE"; then
    record_result "PASS" "Port mappings configured"
else
    record_result "WARN" "No port mappings found (may be intentional)"
fi

# Test 6: Resource Limits
print_test "Resource Limits"
if grep -q "deploy:" "$SERVICE_FILE" && grep -q "resources:" "$SERVICE_FILE"; then
    record_result "PASS" "Resource limits configured"
elif grep -q "mem_limit\|cpus\|memory" "$SERVICE_FILE"; then
    record_result "PASS" "Resource limits configured (legacy format)"
else
    record_result "WARN" "No resource limits configured"
fi

# Test 7: Health Check
print_test "Health Check Configuration"
if grep -q "healthcheck:" "$SERVICE_FILE"; then
    record_result "PASS" "Health check configured"
else
    record_result "WARN" "No health check configured"
fi

# Test 8: Labels
print_test "Service Labels"
if grep -q "labels:" "$SERVICE_FILE"; then
    record_result "PASS" "Service labels configured"
else
    record_result "WARN" "No service labels found"
fi

# Test 9: Dependencies
print_test "Dependencies"
if grep -q "depends_on:" "$SERVICE_FILE"; then
    record_result "PASS" "Service dependencies declared"
else
    record_result "WARN" "No dependencies declared (may be correct)"
fi

# Test 10: Documentation Check
print_test "Documentation"
if grep -q "$SERVICE_NAME" "$REPO_ROOT/docs/SERVICES.md" 2>/dev/null; then
    record_result "PASS" "Service documented in SERVICES.md"
else
    record_result "WARN" "Service not found in SERVICES.md documentation"
fi

# Summary
echo
print_status "📊 Validation Summary for $SERVICE_NAME"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "✅ Tests Passed:  ${GREEN}$TESTS_PASSED${NC}"
echo -e "⚠️  Tests Warning: ${YELLOW}$TESTS_WARNINGS${NC}"
echo -e "❌ Tests Failed:  ${RED}$TESTS_FAILED${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Cleanup
rm -f "$TEST_ENV_FILE"

# Final recommendation
total_tests=$((TESTS_PASSED + TESTS_WARNINGS + TESTS_FAILED))
if [ $TESTS_FAILED -eq 0 ] && [ $TESTS_WARNINGS -eq 0 ]; then
    echo -e "${GREEN}🎉 VALIDATION PASSED${NC} - Service is fully compliant"
    exit 0
elif [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${YELLOW}⚠️  VALIDATION PARTIAL${NC} - Service works but has minor issues"
    echo "Consider addressing the warnings above"
    exit 0
else
    echo -e "${RED}❌ VALIDATION FAILED${NC} - Service has significant issues"
    echo "Please fix the failed tests before deployment"
    exit 1
fi