#!/usr/bin/env python3

import os
import re
import sys
import shutil
from pathlib import Path

# Configuration
SPEC_FILE = "src/v2/spec.yaml.original"
OUTPUT_SPEC = "src/v2/spec.yaml"
COMPONENTS_DIR = "src/v2/components"
PATHS_DIR = "src/v2/paths"

# Ensure directories exist
os.makedirs(f"{COMPONENTS_DIR}/schemas", exist_ok=True)
os.makedirs(f"{COMPONENTS_DIR}/parameters", exist_ok=True)
os.makedirs(f"{COMPONENTS_DIR}/responses", exist_ok=True)
os.makedirs(f"{COMPONENTS_DIR}/securitySchemes", exist_ok=True)

# First, copy the original spec file to preserve structure
shutil.copy(SPEC_FILE, OUTPUT_SPEC)

# Load the spec file
with open(OUTPUT_SPEC, 'r') as f:
    spec_content = f.read()

# Extract and save components
print("Extracting components...")

# Extract security schemes
security_schemes_match = re.search(r'  securitySchemes:\s*\n((?:    .*\n)+)', spec_content, re.MULTILINE)
if security_schemes_match:
    with open(f"{COMPONENTS_DIR}/securitySchemes/api_key.yaml", 'w') as f:
        f.write(security_schemes_match.group(1))
    print("Extracted security schemes")

# Extract parameters
parameters_match = re.search(r'  parameters:\s*\n((?:    .*\n)+)', spec_content, re.MULTILINE)
if parameters_match:
    with open(f"{COMPONENTS_DIR}/parameters/common.yaml", 'w') as f:
        f.write(parameters_match.group(1))
    print("Extracted parameters")

# Extract responses
responses_match = re.search(r'  responses:\s*\n((?:    .*\n)+)', spec_content, re.MULTILINE)
if responses_match:
    with open(f"{COMPONENTS_DIR}/responses/error.yaml", 'w') as f:
        f.write(responses_match.group(1))
    print("Extracted responses")

# Extract schemas by category
schema_categories = {
    'common': r'Address|SolAddress|Fid|ChannelId|SignerUUID|Timestamp|Ed25519PublicKey|NextCursor',
    'user': r'User|Verification|Profile|PowerBadge|Dehydrated',
    'cast': r'Cast|Conversation|Reply|Embed|Text|Parent',
    'channel': r'Channel|Member|Invite',
    'reaction': r'Reaction|Like|Recast',
    'feed': r'Feed|Trending|ForYou',
    'frame': r'Frame|Button|Action|Validate',
    'signer': r'Signer|Key|Status',
    'webhook': r'Webhook|Subscription|Event',
    'error': r'Error|Conflict|Zod',
    'notification': r'Notification|Seen',
    'storage': r'Storage|Allocation|Usage',
    'login': r'Login|Auth|Nonce',
    'follow': r'Follow|Following|Follower',
    'block': r'Block',
    'mute': r'Mute',
    'ban': r'Ban',
    'action': r'Action',
    'onchain': r'Onchain|Fungible',
    'fname': r'Fname',
    'misc': r'.*'  # Catch-all for remaining schemas
}

# Extract all schemas
schemas_section = re.search(r'  schemas:\s*\n((?:    .*\n)+)', spec_content, re.MULTILINE)
if schemas_section:
    schemas_content = schemas_section.group(1)
    
    # Extract individual schemas
    schema_pattern = r'    ([A-Za-z][A-Za-z0-9]*):\s*\n((?:      .*\n)+)'
    schemas = re.findall(schema_pattern, schemas_content, re.MULTILINE)
    
    # Group schemas by category
    categorized_schemas = {}
    for category in schema_categories:
        categorized_schemas[category] = []
    
    for schema_name, schema_content in schemas:
        assigned = False
        for category, pattern in schema_categories.items():
            if re.search(pattern, schema_name) and category != 'misc':
                categorized_schemas[category].append((schema_name, schema_content))
                assigned = True
                break
        
        if not assigned:
            categorized_schemas['misc'].append((schema_name, schema_content))
    
    # Write schemas to files
    for category, schemas in categorized_schemas.items():
        if schemas:
            with open(f"{COMPONENTS_DIR}/schemas/{category}.yaml", 'w') as f:
                for schema_name, schema_content in schemas:
                    f.write(f"{schema_name}:\n{schema_content}\n")
            print(f"Extracted {len(schemas)} schemas to {category}.yaml")

# Extract paths by resource
print("Extracting paths...")
paths_section = re.search(r'paths:\s*\n((?:  /.*\n(?:    .*\n)+)+)', spec_content, re.MULTILINE)
if paths_section:
    paths_content = paths_section.group(1)
    
    # Extract individual paths
    path_pattern = r'  (/farcaster/[a-zA-Z0-9/]*):\s*\n((?:    .*\n)+)'
    paths = re.findall(path_pattern, paths_content, re.MULTILINE)
    
    # Group paths by resource
    for path, content in paths:
        parts = path.split('/')
        if len(parts) < 3:
            continue
        
        resource = parts[2]
        
        if len(parts) > 3:
            action = '_'.join(parts[3:])
        else:
            action = "index"
        
        # Create directory for the resource
        os.makedirs(f"{PATHS_DIR}/{resource}", exist_ok=True)
        
        output_file = f"{PATHS_DIR}/{resource}/{action}.yaml"
        
        # Write path to file
        with open(output_file, 'w') as f:
            f.write(content)
        
        print(f"Extracted path {path} to {output_file}")

# Create a bundling script
print("Creating bundling script...")
bundling_script = """#!/bin/bash

# This script bundles the OpenAPI specification for validation

set -e

SPEC_FILE="src/v2/spec.yaml"
BUNDLE_FILE="src/v2/spec.bundle.yaml"

# Bundle the spec
echo "Bundling OpenAPI specification..."
swagger-cli bundle "$SPEC_FILE" -o "$BUNDLE_FILE"

echo "Bundled spec to $BUNDLE_FILE"
echo "You can validate the bundled spec with: swagger-cli validate $BUNDLE_FILE"
echo "You can lint the bundled spec with: spectral lint $BUNDLE_FILE"
"""

with open("scripts/bundle_openapi.sh", 'w') as f:
    f.write(bundling_script)

os.chmod("scripts/bundle_openapi.sh", 0o755)

# Update .gitignore to exclude bundle files
gitignore_path = ".gitignore"
bundle_ignore = "*.bundle.yaml"

if os.path.exists(gitignore_path):
    with open(gitignore_path, 'r') as f:
        gitignore_content = f.read()
    
    if bundle_ignore not in gitignore_content:
        with open(gitignore_path, 'a') as f:
            f.write(f"\n{bundle_ignore}\n")

print("Updated .gitignore to exclude bundle files")

# Create a README for the modular structure
readme_content = """# Modular OpenAPI Specification

This directory contains the modular OpenAPI specification for the Farcaster API.

## Structure

- `spec.yaml`: Main specification file that references all components
- `components/`: Contains reusable components
  - `schemas/`: Contains schema definitions categorized by domain
  - `parameters/`: Contains parameter definitions
  - `responses/`: Contains response definitions
  - `securitySchemes/`: Contains security scheme definitions
- `paths/`: Contains path definitions organized by resource

## Usage

To validate the specification:

```bash
./scripts/bundle_openapi.sh
swagger-cli validate src/v2/spec.bundle.yaml
```

To lint the specification:

```bash
spectral lint src/v2/spec.bundle.yaml
```

To generate client code:

```bash
openapi-generator generate -i src/v2/spec.bundle.yaml -g typescript-axios -o src/v2/swagger-tmp
```
"""

with open("src/v2/README.md", 'w') as f:
    f.write(readme_content)

print("Created README for modular structure")
print("Extraction completed successfully")
