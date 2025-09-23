# 🔍 Service Validation System Guide

This guide explains how to use the comprehensive service validation system for RaspiServer.

## Overview

The RaspiServer validation system provides tools to systematically validate all 42 services in the infrastructure. It ensures each service follows standards, works correctly, and is properly documented.

## Components

### 1. Individual Service Validator
**Script:** `scripts/validate-service.sh`

Validates a single service against multiple criteria:
- YAML syntax and Docker Compose compatibility
- Service standards compliance
- Container configuration
- Resource limits and health checks
- Documentation coverage

**Usage:**
```bash
# Auto-discover category
./scripts/validate-service.sh jellyfin

# Specify category explicitly
./scripts/validate-service.sh jellyfin multimedia

# Using Makefile
make validate-service SERVICE=jellyfin
```

### 2. All Services Validator
**Script:** `scripts/validate-all-services.sh`

Validates all services and generates comprehensive reports:
- Processes all 42 services across 6 categories
- Generates markdown reports with statistics
- Provides overall compliance metrics

**Usage:**
```bash
./scripts/validate-all-services.sh

# Using Makefile
make validate-all
```

### 3. Issue Generator
**Script:** `scripts/generate-service-issues.sh`

Creates GitHub issues for systematic service tracking:
- Generates one issue per service (42 total)
- Uses structured GitHub issue template
- Includes validation checklists and test commands

**Usage:**
```bash
./scripts/generate-service-issues.sh

# Using Makefile
make generate-issues
```

### 4. GitHub Issue Template
**File:** `.github/ISSUE_TEMPLATE/service-validation.yml`

Structured template for service validation tracking with:
- Service information fields
- Comprehensive validation checklist
- Test results documentation
- Status tracking

## Validation Criteria

### ✅ Configuration Standards
- [ ] YAML syntax validation
- [ ] Container name matches service name
- [ ] Restart policy is `unless-stopped`
- [ ] Standard environment variables (PUID, PGID, TZ)
- [ ] Proper volume mappings
- [ ] Port configuration

### 🐳 Docker Compose Compliance
- [ ] Service parses with `docker compose config`
- [ ] No syntax errors
- [ ] Dependencies properly declared
- [ ] Resource limits defined

### 🔐 Security & Best Practices
- [ ] Non-root user permissions
- [ ] Proper secrets handling
- [ ] Read-only mounts where appropriate
- [ ] No unnecessary privileged mode

### 📚 Documentation
- [ ] Service documented in `docs/SERVICES.md`
- [ ] Environment variables documented
- [ ] Proper service labels

## Makefile Targets

| Target | Description | Example |
|--------|-------------|---------|
| `validate-service` | Validate single service | `make validate-service SERVICE=jellyfin` |
| `validate-all` | Validate all services | `make validate-all` |
| `generate-issues` | Generate GitHub issues | `make generate-issues` |
| `list-services` | List all services by category | `make list-services` |

## Service Categories

The system validates services across 6 categories:

### 🤖 Automation (6 services)
- esphome, homeassistant, kener, mqtt, netdata, uptime-kuma

### ⚙️ Management (4 services)  
- dockge, homarr, portainer, watchtower

### 🎬 Multimedia (14 services)
- bazarr, janitorr, jellyfin, jellyseerr, jellystat, lidarr, mylar3, plex, prowlarr, radarr, readarr, sonarr, soulseekqt, wizarr

### 🌐 Network (7 services)
- adguardhome, authelia, cloudflared, meshnet, nordvpn, pihole, wireward

### 🔧 Others (6 services)
- code, cosmos, proxy, qbittorrent, romassistant, thingsboard

### ☁️ Productivity (5 services)
- activepieces, n8n, nextcloud-docker-socket-proxy, nextcloud, telegram

## Validation Results

### Status Levels
- **✅ PASSED** - Service is fully compliant
- **⚠️ PARTIAL** - Service works but has minor issues  
- **❌ FAILED** - Service has significant issues

### Example Output
```
🧪 Testing: YAML Syntax Validation
✅ YAML syntax is valid (docker compose)
🧪 Testing: Service Standards Compliance
✅ Service follows basic standards
🧪 Testing: Container Name Validation
✅ Container name matches service name

📊 Validation Summary for jellyfin
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ Tests Passed:  9
⚠️  Tests Warning: 1
❌ Tests Failed:  0
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⚠️  VALIDATION PARTIAL - Service works but has minor issues
```

## Workflow

### For Individual Services
1. **Validate:** `make validate-service SERVICE=servicename`
2. **Review:** Check results and address any issues
3. **Document:** Update documentation if needed
4. **Test:** Verify service works as expected

### For Systematic Validation
1. **Generate Issues:** `make generate-issues`
2. **Create GitHub Issues:** Use generated markdown files
3. **Validate All:** `make validate-all`
4. **Review Reports:** Check generated reports in `validation-reports/`
5. **Address Issues:** Fix failing services
6. **Track Progress:** Update GitHub issues as services are validated

## Generated Files

### Issues Directory
- **Location:** `generated-issues/`
- **Format:** `service-validation-{category}-{service}.md`
- **Count:** 42 files (one per service)

### Reports Directory  
- **Location:** `validation-reports/`
- **Format:** `validation-report-YYYYMMDD_HHMMSS.md`
- **Content:** Comprehensive validation results

## Best Practices

1. **Regular Validation**: Run validation regularly to catch regressions
2. **Issue Tracking**: Use GitHub issues to track service validation progress
3. **Documentation Updates**: Keep documentation current as services change
4. **Standards Compliance**: Address warnings to improve maintainability
5. **Automation**: Integrate validation into CI/CD pipelines where possible

## Troubleshooting

### Common Issues
- **Docker not available**: Install Docker or Docker Compose
- **Environment variables missing**: Scripts use test environment automatically
- **Permission errors**: Ensure scripts are executable (`chmod +x`)
- **Service not found**: Check service name and category

### Debug Commands
```bash
# Check service exists
ls services/*/servicename.yml

# Test Docker Compose syntax manually
docker compose -f services/category/service.yml config

# View detailed error output
./scripts/validate-service.sh servicename 2>&1 | less
```

## Integration with Existing Tools

The validation system integrates with existing RaspiServer tools:
- **Makefile**: New targets for easy access
- **SERVICE_STANDARDS.md**: Validation criteria reference existing standards
- **SERVICES.md**: Documentation compliance checks
- **GitHub Issues**: Structured tracking and progress monitoring

## Next Steps

1. Run `make generate-issues` to create GitHub issues for all services
2. Use `make validate-all` to get baseline validation report
3. Start validating services individually with `make validate-service SERVICE=name`
4. Track progress using GitHub issues
5. Address failed validations to improve infrastructure reliability

---

*This validation system ensures all 42 RaspiServer services meet quality standards and work reliably in the infrastructure.*