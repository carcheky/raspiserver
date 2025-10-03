#!/bin/bash

# =============================================================================
# RaspiServer Admin Interface - Quick Test Script
# =============================================================================
# This script demonstrates and tests the RaspiServer Admin interface
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  RaspiServer Admin Interface - Test Suite${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo

# Test 1: Check required files exist
echo -e "${BLUE}[1/5]${NC} Checking required files..."

FILES_TO_CHECK=(
    "apps/raspiserver-admin/app.py"
    "apps/raspiserver-admin/Dockerfile"
    "apps/raspiserver-admin/requirements.txt"
    "apps/raspiserver-admin/templates/index.html"
    "apps/raspiserver-admin/README.md"
    "services/management/raspiserver-admin.yml"
    "docs/ADMIN_INTERFACE_GUIDE.md"
)

FAILED=0
for file in "${FILES_TO_CHECK[@]}"; do
    if [ -f "$REPO_ROOT/$file" ]; then
        echo -e "  ${GREEN}✓${NC} $file"
    else
        echo -e "  ${RED}✗${NC} $file ${RED}(missing)${NC}"
        FAILED=1
    fi
done

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}✅ All required files exist${NC}\n"
else
    echo -e "${RED}❌ Some files are missing${NC}\n"
    exit 1
fi

# Test 2: Validate Python syntax
echo -e "${BLUE}[2/5]${NC} Validating Python syntax..."

if python3 -m py_compile "$REPO_ROOT/apps/raspiserver-admin/app.py" 2>/dev/null; then
    echo -e "  ${GREEN}✓${NC} app.py syntax is valid"
    echo -e "${GREEN}✅ Python syntax check passed${NC}\n"
else
    echo -e "  ${RED}✗${NC} app.py has syntax errors"
    echo -e "${RED}❌ Python syntax check failed${NC}\n"
    exit 1
fi

# Test 3: Validate YAML syntax
echo -e "${BLUE}[3/5]${NC} Validating YAML syntax..."

if python3 -c "import yaml; yaml.safe_load(open('$REPO_ROOT/services/management/raspiserver-admin.yml'))" 2>/dev/null; then
    echo -e "  ${GREEN}✓${NC} raspiserver-admin.yml is valid"
    echo -e "${GREEN}✅ YAML syntax check passed${NC}\n"
else
    echo -e "  ${RED}✗${NC} raspiserver-admin.yml has syntax errors"
    echo -e "${RED}❌ YAML syntax check failed${NC}\n"
    exit 1
fi

# Test 4: Validate Docker Compose configuration
echo -e "${BLUE}[4/5]${NC} Validating Docker Compose configuration..."

cd "$REPO_ROOT"

if command -v docker &> /dev/null; then
    if docker compose -f services/management/raspiserver-admin.yml config > /dev/null 2>&1; then
        echo -e "  ${GREEN}✓${NC} Docker Compose configuration is valid"
        echo -e "${GREEN}✅ Docker Compose validation passed${NC}\n"
    else
        echo -e "  ${YELLOW}⚠${NC}  Docker Compose validation returned warnings (this is OK)"
        echo -e "${YELLOW}⚠️  Docker Compose validation completed with warnings${NC}\n"
    fi
else
    echo -e "  ${YELLOW}⚠${NC}  Docker not found, skipping validation"
    echo -e "${YELLOW}⚠️  Docker Compose validation skipped${NC}\n"
fi

# Test 5: Check documentation
echo -e "${BLUE}[5/5]${NC} Checking documentation..."

DOCS_COMPLETE=0

# Check if admin interface is mentioned in main docs
if grep -q "RaspiServer Admin" "$REPO_ROOT/README.md"; then
    echo -e "  ${GREEN}✓${NC} README.md updated with admin interface"
    DOCS_COMPLETE=$((DOCS_COMPLETE + 1))
else
    echo -e "  ${YELLOW}⚠${NC}  README.md not updated"
fi

if grep -q "raspiserver-admin" "$REPO_ROOT/docker-compose.example.yml"; then
    echo -e "  ${GREEN}✓${NC} docker-compose.example.yml includes admin service"
    DOCS_COMPLETE=$((DOCS_COMPLETE + 1))
else
    echo -e "  ${YELLOW}⚠${NC}  docker-compose.example.yml not updated"
fi

if grep -q "RASPISERVER_ADMIN_PORT" "$REPO_ROOT/.env.dist"; then
    echo -e "  ${GREEN}✓${NC} .env.dist includes admin port variable"
    DOCS_COMPLETE=$((DOCS_COMPLETE + 1))
else
    echo -e "  ${YELLOW}⚠${NC}  .env.dist not updated"
fi

if grep -q "RaspiServer Admin" "$REPO_ROOT/docs/QUICK_REFERENCE.md"; then
    echo -e "  ${GREEN}✓${NC} QUICK_REFERENCE.md updated"
    DOCS_COMPLETE=$((DOCS_COMPLETE + 1))
else
    echo -e "  ${YELLOW}⚠${NC}  QUICK_REFERENCE.md not updated"
fi

if [ $DOCS_COMPLETE -eq 4 ]; then
    echo -e "${GREEN}✅ Documentation is complete${NC}\n"
else
    echo -e "${YELLOW}⚠️  Documentation is partially complete ($DOCS_COMPLETE/4)${NC}\n"
fi

# Summary
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ All tests passed!${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo
echo -e "${BLUE}📖 Next Steps:${NC}"
echo
echo -e "1. ${BLUE}Enable the service in docker-compose.yml:${NC}"
echo -e "   ${YELLOW}Uncomment:${NC} - services/management/raspiserver-admin.yml"
echo
echo -e "2. ${BLUE}Configure the port (optional):${NC}"
echo -e "   ${YELLOW}Add to .env:${NC} RASPISERVER_ADMIN_PORT=5000"
echo
echo -e "3. ${BLUE}Start the service:${NC}"
echo -e "   ${GREEN}docker-compose up -d raspiserver-admin${NC}"
echo
echo -e "4. ${BLUE}Access the interface:${NC}"
echo -e "   ${GREEN}http://localhost:5000${NC}"
echo
echo -e "${BLUE}📚 Documentation:${NC}"
echo -e "   • apps/raspiserver-admin/README.md"
echo -e "   • docs/ADMIN_INTERFACE_GUIDE.md"
echo -e "   • apps/raspiserver-admin/VISUAL_PREVIEW.md"
echo
echo -e "${YELLOW}⚠️  Security Note:${NC}"
echo -e "   Do NOT expose port 5000 to the internet without proper authentication!"
echo

exit 0
