#!/bin/bash

# =============================================================================
# Service Issues Generator
# =============================================================================
# Generates GitHub issues for individual service validation
# This script creates one issue per service for systematic validation
# =============================================================================

# Configuration
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SERVICES_DIR="${REPO_ROOT}/services"
ISSUES_DIR="${REPO_ROOT}/generated-issues"

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

# Create issues directory
mkdir -p "$ISSUES_DIR"

print_status "🏗️ Generating service validation issues..."
print_status "Services directory: $SERVICES_DIR"
print_status "Output directory: $ISSUES_DIR"
echo

# Service categories mapping
declare -A CATEGORY_DESCRIPTIONS
CATEGORY_DESCRIPTIONS["automation"]="🤖 Automation & Monitoring Services"
CATEGORY_DESCRIPTIONS["management"]="⚙️ Management & Infrastructure Services"
CATEGORY_DESCRIPTIONS["multimedia"]="🎬 Multimedia Services"
CATEGORY_DESCRIPTIONS["network"]="🌐 Network & Security Services"
CATEGORY_DESCRIPTIONS["others"]="🔧 Other Services"  
CATEGORY_DESCRIPTIONS["productivity"]="☁️ Productivity & Workflow Services"

# Counter for statistics
total_services=0
total_categories=0

# Function to generate issue content for a service
generate_service_issue() {
    local service_file="$1"
    local category="$2"
    local service_name=$(basename "$service_file" .yml)
    
    cat << EOF
---
title: "[Service Validation] $service_name - Validation and Testing"
labels: 
  - service-validation
  - testing
  - $category
assignees: []
---

# 🔍 Service Validation: $service_name

**Service Category:** ${CATEGORY_DESCRIPTIONS[$category]}  
**Service File:** \`services/$category/$service_name.yml\`  
**Validation Date:** $(date +"%Y-%m-%d")

## 📋 Validation Checklist

### Configuration Validation
- [ ] 📄 YAML file follows [SERVICE_STANDARDS.md](../docs/SERVICE_STANDARDS.md)
- [ ] 🏷️ Container name matches service name
- [ ] 🔄 Restart policy is \`unless-stopped\`
- [ ] 🌍 Standard environment variables (PUID, PGID, TZ) are defined
- [ ] 📂 Volume mappings use proper paths and permissions
- [ ] 🔌 Port mappings are defined and documented

### Docker Compose Validation  
- [ ] 🐳 Service can be parsed with \`docker-compose config\`
- [ ] ✅ No syntax errors in YAML
- [ ] 🔗 Dependencies are properly declared
- [ ] 📊 Resource limits are appropriate

### Startup and Functionality Tests
- [ ] 🚀 Service starts successfully: \`make start-$service_name\`
- [ ] 📋 No critical errors in startup logs
- [ ] ⏱️ Service becomes healthy within reasonable time
- [ ] 🔌 Service is accessible on defined ports
- [ ] 🏥 Health check passes (if implemented)

### Security and Best Practices
- [ ] 🛡️ Non-root user permissions (PUID/PGID)
- [ ] 🔐 Secrets handled properly
- [ ] 📁 Read-only mounts where appropriate
- [ ] 🚫 No privileged mode unless necessary

### Documentation and Integration
- [ ] 📚 Service documented in [docs/SERVICES.md](../docs/SERVICES.md)
- [ ] 🏷️ Proper labels for management tools
- [ ] 🔄 Integration with related services tested
- [ ] 📖 Environment variables documented

## 🧪 Test Commands

\`\`\`bash
# Validate configuration
docker-compose -f services/$category/$service_name.yml config

# Start service
make start-$service_name

# Check logs
make logs-$service_name

# Check status
docker-compose ps $service_name

# Test connectivity (adjust port as needed)
curl -f http://localhost:\${PORT}/health || echo "No health endpoint"
\`\`\`

## 📊 Test Results

### Configuration Test
- [ ] YAML syntax: ✅ Valid / ⚠️ Issues / ❌ Invalid
- [ ] Standards compliance: ✅ Full / ⚠️ Partial / ❌ Non-compliant

### Startup Test  
- [ ] Container start: ✅ Success / ⚠️ Warnings / ❌ Failed
- [ ] Service logs: ✅ Clean / ⚠️ Warnings / ❌ Errors

### Functionality Test
- [ ] Port access: ✅ Accessible / ❌ Not accessible  
- [ ] Basic function: ✅ Working / ⚠️ Limited / ❌ Broken

## 📝 Issues Found

<!-- List any issues discovered during validation -->

## 📈 Performance Notes

<!-- Note any performance observations -->

## ✅ Final Status

- [ ] **✅ PASSED** - Service is fully functional and compliant
- [ ] **⚠️ PARTIAL** - Service works but has minor issues that should be addressed
- [ ] **❌ FAILED** - Service has significant issues that prevent proper operation

---

**Validation completed by:** @  
**Date completed:** 
**Service version:** <!-- Container image version tested -->

EOF
}

# Process each category
for category_dir in "$SERVICES_DIR"/*; do
    if [ -d "$category_dir" ]; then
        category=$(basename "$category_dir")
        print_status "Processing category: $category"
        
        category_count=0
        
        # Process each service in the category
        for service_file in "$category_dir"/*.yml; do
            if [ -f "$service_file" ]; then
                service_name=$(basename "$service_file" .yml)
                issue_file="$ISSUES_DIR/service-validation-$category-$service_name.md"
                
                print_status "  Generating issue for: $service_name"
                generate_service_issue "$service_file" "$category" > "$issue_file"
                
                ((category_count++))
                ((total_services++))
            fi
        done
        
        print_success "Generated $category_count issues for $category services"
        ((total_categories++))
    fi
done

echo
print_success "🎉 Issue generation completed!"
print_success "📊 Total categories processed: $total_categories"
print_success "📋 Total service issues generated: $total_services"
print_success "📁 Issues saved to: $ISSUES_DIR"
echo

print_warning "📌 Next steps:"
echo "   1. Review generated issues in $ISSUES_DIR"
echo "   2. Create issues in GitHub using the generated markdown files"
echo "   3. Run individual service validation using: make validate-service SERVICE=service-name"
echo "   4. Update this script if new services are added"
echo

print_status "🔗 You can use GitHub CLI to create issues:"
echo "   gh issue create --title \"[Service Validation] service-name\" --body-file generated-issues/service-validation-category-service.md"