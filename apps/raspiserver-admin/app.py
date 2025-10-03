#!/usr/bin/env python3
"""
RaspiServer Admin Interface
A web-based management interface for RaspiServer Docker Compose infrastructure
"""

from flask import Flask, render_template, request, jsonify, send_from_directory
import os
import yaml
import re
from pathlib import Path

app = Flask(__name__)

# Configuration
BASE_DIR = Path(os.environ.get('RASPISERVER_PATH', '/raspiserver'))
ENV_FILE = BASE_DIR / '.env'
ENV_DIST_FILE = BASE_DIR / '.env.dist'
COMPOSE_FILE = BASE_DIR / 'docker-compose.yml'
COMPOSE_EXAMPLE_FILE = BASE_DIR / 'docker-compose.example.yml'
SERVICES_DIR = BASE_DIR / 'services'


def parse_env_file(file_path):
    """Parse .env file and return a dictionary of variables with comments"""
    env_vars = {}
    current_section = "General"
    
    if not file_path.exists():
        return {}
    
    with open(file_path, 'r') as f:
        for line in f:
            line = line.strip()
            
            # Detect section headers
            if line.startswith('# ==='):
                continue
            elif line.startswith('#') and '=' not in line:
                # This is a comment or section header
                if line.count('#') > 1:
                    current_section = line.strip('# ').strip()
                continue
            
            # Parse variable
            if '=' in line and not line.startswith('#'):
                key, value = line.split('=', 1)
                key = key.strip()
                value = value.strip()
                
                # Get inline comment if exists
                comment = ""
                if '#' in value:
                    value, comment = value.split('#', 1)
                    value = value.strip()
                    comment = comment.strip()
                
                env_vars[key] = {
                    'value': value,
                    'comment': comment,
                    'section': current_section
                }
    
    return env_vars


def write_env_file(env_vars, file_path):
    """Write environment variables back to .env file"""
    sections = {}
    
    # Group by section
    for key, data in env_vars.items():
        section = data.get('section', 'General')
        if section not in sections:
            sections[section] = []
        sections[section].append((key, data))
    
    # Write file
    with open(file_path, 'w') as f:
        for section, vars_list in sections.items():
            f.write(f"\n# {'=' * 77}\n")
            f.write(f"# {section}\n")
            f.write(f"# {'=' * 77}\n\n")
            
            for key, data in vars_list:
                value = data['value']
                comment = data.get('comment', '')
                
                if comment:
                    f.write(f"{key}={value}  # {comment}\n")
                else:
                    f.write(f"{key}={value}\n")


def get_available_services():
    """Get all available services from services directory"""
    services = {
        'multimedia': [],
        'network': [],
        'automation': [],
        'management': [],
        'productivity': [],
        'others': []
    }
    
    if not SERVICES_DIR.exists():
        return services
    
    for category in services.keys():
        category_dir = SERVICES_DIR / category
        if category_dir.exists():
            for yml_file in category_dir.glob('*.yml'):
                services[category].append({
                    'name': yml_file.stem,
                    'file': f'services/{category}/{yml_file.name}',
                    'category': category
                })
    
    return services


def get_active_services():
    """Get currently active services from docker-compose.yml"""
    if not COMPOSE_FILE.exists():
        return []
    
    active = []
    with open(COMPOSE_FILE, 'r') as f:
        for line in f:
            line = line.strip()
            # Look for uncommented include lines
            if line.startswith('- services/') and not line.startswith('#'):
                active.append(line.strip('- ').strip())
    
    return active


def toggle_service(service_file, enable=True):
    """Toggle a service in docker-compose.yml"""
    if not COMPOSE_FILE.exists():
        # Create from example if doesn't exist
        if COMPOSE_EXAMPLE_FILE.exists():
            import shutil
            shutil.copy(COMPOSE_EXAMPLE_FILE, COMPOSE_FILE)
        else:
            return False, "docker-compose.yml not found"
    
    lines = []
    found = False
    
    with open(COMPOSE_FILE, 'r') as f:
        lines = f.readlines()
    
    # Find and toggle the service
    for i, line in enumerate(lines):
        stripped = line.strip()
        
        if service_file in stripped:
            found = True
            if enable:
                # Remove comment if exists
                lines[i] = line.lstrip('#').lstrip()
                if not lines[i].startswith('  - '):
                    lines[i] = f"  - {lines[i].lstrip('- ').lstrip()}"
            else:
                # Add comment
                if not stripped.startswith('#'):
                    lines[i] = f"  # {stripped}\n"
    
    if found:
        with open(COMPOSE_FILE, 'w') as f:
            f.writelines(lines)
        return True, "Service toggled successfully"
    
    # If not found and enabling, add it
    if enable and not found:
        # Find include section and add service
        include_idx = -1
        for i, line in enumerate(lines):
            if line.strip() == 'include:':
                include_idx = i
                break
        
        if include_idx >= 0:
            # Add after include
            lines.insert(include_idx + 1, f"  - {service_file}\n")
            with open(COMPOSE_FILE, 'w') as f:
                f.writelines(lines)
            return True, "Service added successfully"
    
    return False, "Service not found in compose file"


@app.route('/')
def index():
    """Main dashboard"""
    return render_template('index.html')


@app.route('/api/env')
def get_env():
    """Get environment variables"""
    env_vars = parse_env_file(ENV_FILE)
    
    # If .env doesn't exist, use .env.dist as template
    if not env_vars and ENV_DIST_FILE.exists():
        env_vars = parse_env_file(ENV_DIST_FILE)
    
    return jsonify(env_vars)


@app.route('/api/env', methods=['POST'])
def update_env():
    """Update environment variables"""
    data = request.json
    
    # Read current env
    env_vars = parse_env_file(ENV_FILE)
    
    # If .env doesn't exist, start from .env.dist
    if not env_vars and ENV_DIST_FILE.exists():
        env_vars = parse_env_file(ENV_DIST_FILE)
    
    # Update values
    for key, value in data.items():
        if key in env_vars:
            env_vars[key]['value'] = value
        else:
            env_vars[key] = {
                'value': value,
                'comment': '',
                'section': 'Custom'
            }
    
    # Write back
    write_env_file(env_vars, ENV_FILE)
    
    return jsonify({'status': 'success', 'message': 'Environment variables updated'})


@app.route('/api/services')
def get_services():
    """Get all available services and their status"""
    available = get_available_services()
    active = get_active_services()
    
    # Mark active services
    result = {}
    for category, services in available.items():
        result[category] = []
        for service in services:
            service['active'] = service['file'] in active
            result[category].append(service)
    
    return jsonify(result)


@app.route('/api/services/toggle', methods=['POST'])
def toggle_service_endpoint():
    """Toggle a service on/off"""
    data = request.json
    service_file = data.get('service')
    enable = data.get('enable', True)
    
    success, message = toggle_service(service_file, enable)
    
    if success:
        return jsonify({'status': 'success', 'message': message})
    else:
        return jsonify({'status': 'error', 'message': message}), 400


@app.route('/api/system/info')
def system_info():
    """Get system information"""
    return jsonify({
        'base_dir': str(BASE_DIR),
        'env_file_exists': ENV_FILE.exists(),
        'compose_file_exists': COMPOSE_FILE.exists(),
        'services_dir_exists': SERVICES_DIR.exists()
    })


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
