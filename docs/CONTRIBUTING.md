# Contributing to RaspiServer

Thank you for your interest in contributing to RaspiServer! This document provides guidelines and information for contributors.

## 📋 Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Environment](#development-environment)
- [Contributing Guidelines](#contributing-guidelines)
- [Pull Request Process](#pull-request-process)
- [Issue Reporting](#issue-reporting)
- [Documentation](#documentation)

## 🤝 Code of Conduct

### Our Pledge

We are committed to providing a welcoming and inclusive environment for all contributors, regardless of:
- Experience level
- Gender identity and expression
- Sexual orientation
- Disability
- Personal appearance
- Body size
- Race, ethnicity, or nationality
- Religion or lack thereof
- Age

### Expected Behavior

- Use welcoming and inclusive language
- Be respectful of differing viewpoints and experiences
- Gracefully accept constructive criticism
- Focus on what is best for the community
- Show empathy towards other community members

### Unacceptable Behavior

- Harassment, trolling, or insulting comments
- Public or private harassment
- Publishing others' private information without permission
- Other conduct which could reasonably be considered inappropriate

## 🚀 Getting Started

### Prerequisites

- Basic knowledge of Docker and Docker Compose
- Understanding of Linux/Unix systems
- Familiarity with Git and GitHub workflow
- Experience with the services you want to contribute to

### Areas of Contribution

We welcome contributions in several areas:

#### 🐳 Service Configurations
- Adding new services
- Improving existing service configurations
- Optimizing resource usage
- Security enhancements

#### 📚 Documentation
- Improving existing documentation
- Adding new guides and tutorials
- Translating documentation
- Creating video tutorials

#### 🔧 Scripts and Automation
- Backup and restore scripts
- Monitoring and alerting
- Deployment automation
- Maintenance utilities

#### 🛠️ Testing and Quality Assurance
- Testing on different platforms
- Performance testing
- Security auditing
- Bug reporting and fixes

## 💻 Development Environment

### Setup

1. **Fork the Repository**
   ```bash
   # Fork on GitHub, then clone your fork
   git clone https://github.com/carcheky/raspiserver.git
   cd raspiserver
   ```

2. **Set Up Development Environment**
   ```bash
   # Add upstream remote
   git remote add upstream https://github.com/carcheky/raspiserver.git
   
   # Copy configuration files
   cp .env.dist .env
   cp docker-compose.example.yml docker-compose.yml
   
   # Edit configurations for your environment
   nano .env
   nano docker-compose.yml
   ```

3. **Create Development Branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

### Testing Changes

#### Service Testing
```bash
# Test specific service
docker-compose up -d service-name

# Check logs
docker-compose logs -f service-name

# Test functionality
curl http://localhost:port/health
```

#### Full Stack Testing
```bash
# Start all services
docker-compose up -d

# Run health checks
./scripts/verify-services.sh

# Check resource usage
docker stats
```

#### Documentation Testing
```bash
# Serve docs locally (if using MkDocs or similar)
mkdocs serve

# Check markdown lint
markdownlint docs/*.md

# Validate links
markdown-link-check docs/*.md
```

## 📝 Contributing Guidelines

### Commit Message Format

We use [Conventional Commits](https://www.conventionalcommits.org/) format:

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

#### Types
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, etc.)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

#### Examples
```bash
feat(jellyfin): add hardware acceleration support
fix(qbittorrent): resolve VPN connection issues
docs(setup): add Raspberry Pi 5 installation guide
refactor(configs): consolidate nginx configurations
```

### Code Style

#### Docker Compose Files
```yaml
# Use consistent formatting
services:
  service-name:
    image: linuxserver/service:latest
    container_name: service-name
    restart: unless-stopped
    environment:
      - PUID=${PUID}
      - PGID=${PGID}
      - TZ=${TIMEZONE}
    volumes:
      - ${VOLUMES_DIR}/service-config:/config
    ports:
      - "${SERVICE_PORT}:internal-port"
    depends_on:
      - dependency-service
```

#### Shell Scripts
```bash
#!/bin/bash
set -euo pipefail

# Use meaningful variable names
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SERVICE_NAME="$1"

# Add error handling
check_dependencies() {
    if ! command -v docker &> /dev/null; then
        echo "Error: Docker is not installed" >&2
        exit 1
    fi
}

# Use functions for reusable code
main() {
    check_dependencies
    # Main logic here
}

main "$@"
```

#### Documentation
```markdown
# Use consistent heading structure
## Level 2 Heading
### Level 3 Heading
#### Level 4 Heading

# Use code blocks with language specification
```bash
docker-compose up -d
```

# Use consistent formatting for commands
```bash
# Comment explaining the command
command --option value
```
```

### Adding New Services

1. **Create Service Configuration**
   ```bash
   # Create new service file
   touch services/category/new-service.yml
   ```

2. **Follow Template Structure**
   ```yaml
   services:
     new-service:
       image: linuxserver/new-service:latest
       container_name: new-service
       restart: unless-stopped
       environment:
         - PUID=${PUID}
         - PGID=${PGID}
         - TZ=${TIMEZONE}
         # Service-specific environment variables
       volumes:
         - ${VOLUMES_DIR}/new-service-config:/config
         # Service-specific volumes
       ports:
         - "${NEW_SERVICE_PORT}:internal-port"
       # Add networks, dependencies, etc. as needed
   ```

3. **Add Environment Variables**
   ```bash
   # Add to .env.dist
   NEW_SERVICE_PORT=8XXX
   ```

4. **Update Documentation**
   - Add service to `docs/SERVICES.md`
   - Update `docs/README.md` if it's a major service
   - Add troubleshooting section if needed

5. **Test Configuration**
   ```bash
   # Test the service
   docker-compose -f services/category/new-service.yml config
   docker-compose up -d new-service
   ```

## 🔄 Pull Request Process

### Before Creating a PR

1. **Ensure your changes work**
   ```bash
   # Test locally
   docker-compose config
   docker-compose up -d changed-service
   ```

2. **Update documentation**
   - Update relevant documentation files
   - Add changelog entry if significant

3. **Follow commit conventions**
   ```bash
   git add .
   git commit -m "feat(service): add new awesome service"
   ```

### Creating the PR

1. **Push to your fork**
   ```bash
   git push origin feature/your-feature-name
   ```

2. **Create PR on GitHub**
   - Use descriptive title following conventional commits
   - Fill out the PR template
   - Link related issues

3. **PR Template Information**
   ```markdown
   ## Description
   Brief description of changes
   
   ## Type of Change
   - [ ] New service addition
   - [ ] Bug fix
   - [ ] Documentation update
   - [ ] Configuration improvement
   
   ## Testing
   - [ ] Tested locally
   - [ ] Documentation updated
   - [ ] No breaking changes
   
   ## Screenshots (if applicable)
   Add screenshots of new features
   ```

### Review Process

1. **Automated Checks**
   - GitHub Actions will run automated tests
   - Fix any failing checks before review

2. **Maintainer Review**
   - Maintainers will review your changes
   - Address feedback promptly
   - Be open to suggestions

3. **Approval and Merge**
   - Once approved, maintainers will merge
   - Your contribution will be included in the next release

## 🐛 Issue Reporting

### Before Creating an Issue

1. **Search existing issues**
   - Check if the issue already exists
   - Add to existing discussion if relevant

2. **Gather information**
   ```bash
   # System information
   uname -a
   docker --version
   docker-compose --version
   
   # Service status
   docker-compose ps
   
   # Recent logs
   docker-compose logs --tail=50 problematic-service
   ```

### Issue Template

```markdown
## Description
Clear description of the issue

## Environment
- OS: [e.g., Raspberry Pi OS 64-bit]
- Docker version: [e.g., 20.10.21]
- Docker Compose version: [e.g., 2.12.2]

## Steps to Reproduce
1. Step one
2. Step two
3. See error

## Expected Behavior
What you expected to happen

## Actual Behavior
What actually happened

## Logs
Relevant log excerpts (remove sensitive information)

## Additional Context
Any other context about the problem
```

## 📚 Documentation

### Documentation Structure

```
docs/
├── README.md           # Main documentation
├── SETUP.md           # Installation guide
├── SERVICES.md        # Service configurations
├── ARCHITECTURE.md    # Technical details
├── TROUBLESHOOTING.md # Common issues
├── CONTRIBUTING.md    # This file
└── COPILOT.md        # AI assistant instructions
```

### Writing Guidelines

#### Style Guide
- Use clear, concise language
- Write for different skill levels
- Include practical examples
- Use consistent formatting

#### Code Examples
- Always test code examples
- Include expected output when relevant
- Use realistic examples
- Explain complex commands

#### Screenshots
- Use consistent browser/theme
- Highlight important areas
- Keep file sizes reasonable
- Use descriptive filenames

### Translation

We welcome documentation translations:

1. Create `docs/lang/` directory (e.g., `docs/es/` for Spanish)
2. Translate documentation files
3. Update main README to link to translations
4. Keep translations updated with changes

## 🎉 Recognition

Contributors will be recognized in several ways:

### Contributors List
- GitHub contributors graph
- CONTRIBUTORS.md file
- Release notes mentions

### Contributor Roles
- **Code Contributors**: Add new features or fix bugs
- **Documentation Contributors**: Improve or translate docs
- **Community Contributors**: Help in discussions and support
- **Maintainers**: Regular contributors with merge permissions

## 📞 Getting Help

### Communication Channels

- **GitHub Issues**: Bug reports and feature requests
- **GitHub Discussions**: General questions and ideas
- **Discord/Matrix**: Real-time chat (if available)

### Mentorship

New contributors can request mentorship:
- Pair programming sessions
- Code review guidance
- Architecture discussions
- Best practices sharing

## 📄 License

By contributing to RaspiServer, you agree that your contributions will be licensed under the same license as the project (MIT License).

---

**Thank you for contributing to RaspiServer! Your efforts help make self-hosting accessible to everyone.**
