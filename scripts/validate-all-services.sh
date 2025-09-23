#!/bin/bash

# =============================================================================
# All Services Validator
# =============================================================================
# Validates all services in the RaspiServer infrastructure
# Generates a comprehensive report of service compliance and issues
# =============================================================================

set -e

# Configuration
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SERVICES_DIR="${REPO_ROOT}/services"
REPORTS_DIR="${REPO_ROOT}/validation-reports"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
REPORT_FILE="$REPORTS_DIR/validation-report-$TIMESTAMP.md"

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

# Create reports directory
mkdir -p "$REPORTS_DIR"

print_status "🔍 Starting comprehensive service validation..."
print_status "Services directory: $SERVICES_DIR"
print_status "Report will be saved to: $REPORT_FILE"
echo

# Initialize report
cat > "$REPORT_FILE" << EOF
# RaspiServer Service Validation Report

**Generated:** $(date)  
**Total Services:** $(find "$SERVICES_DIR" -name "*.yml" | wc -l)

## Summary

EOF

# Counters
total_services=0
passed_services=0
partial_services=0
failed_services=0
total_categories=0

# Category results storage
declare -A category_results

# Process each category
for category_dir in "$SERVICES_DIR"/*; do
    if [ -d "$category_dir" ]; then
        category=$(basename "$category_dir")
        print_status "📁 Processing category: $category"
        
        category_passed=0
        category_partial=0
        category_failed=0
        category_total=0
        
        # Add category header to report
        echo "### 📁 $category" >> "$REPORT_FILE"
        echo "" >> "$REPORT_FILE"
        echo "| Service | Status | Issues |" >> "$REPORT_FILE"
        echo "|---------|--------|--------|" >> "$REPORT_FILE"
        
        # Process each service in the category
        for service_file in "$category_dir"/*.yml; do
            if [ -f "$service_file" ]; then
                service_name=$(basename "$service_file" .yml)
                
                print_status "  🔍 Validating: $service_name"
                
                # Run validation and capture results
                if validation_output=$("$REPO_ROOT/scripts/validate-service.sh" "$service_name" "$category" 2>&1); then
                    exit_code=$?
                    
                    # Determine status based on exit code and output
                    if [ $exit_code -eq 0 ]; then
                        if echo "$validation_output" | grep -q "VALIDATION PASSED"; then
                            status="✅ PASSED"
                            issues="None"
                            ((category_passed++))
                            ((passed_services++))
                        else
                            status="⚠️ PARTIAL"
                            issues="Minor warnings"
                            ((category_partial++))
                            ((partial_services++))
                        fi
                    else
                        status="❌ FAILED"
                        issues="Significant issues"
                        ((category_failed++))
                        ((failed_services++))
                    fi
                else
                    status="❌ ERROR"
                    issues="Validation script error"
                    ((category_failed++))
                    ((failed_services++))
                fi
                
                # Add to report
                echo "| $service_name | $status | $issues |" >> "$REPORT_FILE"
                
                ((category_total++))
                ((total_services++))
            fi
        done
        
        # Add category summary to report
        echo "" >> "$REPORT_FILE"
        echo "**$category Summary:** $category_passed passed, $category_partial partial, $category_failed failed (Total: $category_total)" >> "$REPORT_FILE"
        echo "" >> "$REPORT_FILE"
        
        # Store category results
        category_results["$category"]="$category_passed,$category_partial,$category_failed,$category_total"
        
        print_success "Category $category completed: $category_passed passed, $category_partial partial, $category_failed failed"
        ((total_categories++))
    fi
done

# Add overall summary to report
cat >> "$REPORT_FILE" << EOF

## Overall Summary

- **Total Services:** $total_services
- **Categories:** $total_categories
- **✅ Passed:** $passed_services
- **⚠️ Partial:** $partial_services  
- **❌ Failed:** $failed_services

### Success Rate

- **Full Compliance:** $(echo "scale=1; $passed_services * 100 / $total_services" | bc -l)%
- **Functional (Passed + Partial):** $(echo "scale=1; ($passed_services + $partial_services) * 100 / $total_services" | bc -l)%

## Recommendations

EOF

# Add recommendations based on results
if [ $failed_services -gt 0 ]; then
    echo "### 🔴 Critical Issues" >> "$REPORT_FILE"
    echo "- $failed_services services have significant issues that prevent proper operation" >> "$REPORT_FILE"
    echo "- Review and fix failed services before deployment" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"
fi

if [ $partial_services -gt 0 ]; then
    echo "### 🟡 Improvement Opportunities" >> "$REPORT_FILE"
    echo "- $partial_services services work but have minor compliance issues" >> "$REPORT_FILE"
    echo "- Consider addressing warnings for better maintainability" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"
fi

if [ $passed_services -eq $total_services ]; then
    echo "### 🟢 Excellent!" >> "$REPORT_FILE"
    echo "- All services passed validation" >> "$REPORT_FILE"
    echo "- Infrastructure is fully compliant with standards" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"
fi

# Add next steps
cat >> "$REPORT_FILE" << EOF

## Next Steps

1. **Review Failed Services:** Focus on services marked as failed
2. **Address Warnings:** Consider fixing partial services for better compliance  
3. **Create Issues:** Use \`make generate-issues\` to create GitHub issues for tracking
4. **Individual Validation:** Use \`make validate-service SERVICE=name\` for detailed analysis
5. **Continuous Monitoring:** Run this validation regularly

---

*Report generated by validate-all-services.sh*
EOF

# Display final summary
echo
print_status "📊 Validation Summary"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "📁 Categories:     ${BLUE}$total_categories${NC}"
echo -e "🔧 Total Services: ${BLUE}$total_services${NC}"
echo -e "✅ Passed:        ${GREEN}$passed_services${NC}"
echo -e "⚠️  Partial:       ${YELLOW}$partial_services${NC}"
echo -e "❌ Failed:        ${RED}$failed_services${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Overall status
if [ $failed_services -eq 0 ] && [ $partial_services -eq 0 ]; then
    print_success "🎉 ALL SERVICES PASSED - Infrastructure is fully compliant!"
    overall_status="PASSED"
elif [ $failed_services -eq 0 ]; then
    print_warning "⚠️ MOSTLY COMPLIANT - Some services have minor issues"
    overall_status="PARTIAL"
else
    print_error "❌ ISSUES FOUND - $failed_services services need attention"
    overall_status="FAILED"
fi

echo
print_status "📋 Detailed report saved to: $REPORT_FILE"
print_status "🔍 Use 'make validate-service SERVICE=name' for individual service details"
print_status "📋 Use 'make generate-issues' to create GitHub issues for tracking"

# Set exit code based on overall status
case "$overall_status" in
    "PASSED") exit 0 ;;
    "PARTIAL") exit 0 ;;
    "FAILED") exit 1 ;;
esac