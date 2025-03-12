#!/usr/bin/env python3

import os
import re
import sys
from pathlib import Path

# Configuration
SPEC_FILE = "src/v2/spec.yaml.original"
COMPONENTS_DIR = "src/v2/components"
PATHS_DIR = "src/v2/paths"

# Create directories
os.makedirs(f"{COMPONENTS_DIR}/schemas", exist_ok=True)
os.makedirs(f"{COMPONENTS_DIR}/parameters", exist_ok=True)
os.makedirs(f"{COMPONENTS_DIR}/responses", exist_ok=True)
os.makedirs(f"{COMPONENTS_DIR}/securitySchemes", exist_ok=True)

# Load the OpenAPI spec
with open(SPEC_FILE, 'r') as f:
    spec_content = f.read()

# Extract paths using regex
print("Extracting paths...")
path_pattern = r'(^  /farcaster/[a-zA-Z0-9/]*):\s*\n((?:    .*\n)+)'
paths = re.findall(path_pattern, spec_content, re.MULTILINE)

for path, content in paths:
    # Extract resource and action from path
    parts = path.strip().split('/')
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
    
    # Write path object to file
    with open(output_file, 'w') as f:
        f.write(content)
    
    print(f"Extracted path {path} to {output_file}")

# Extract schemas using regex
print("Extracting schemas...")
schema_pattern = r'(^    [A-Za-z][A-Za-z0-9]*):\s*\n((?:      .*\n)+)'
schemas = re.findall(schema_pattern, spec_content, re.MULTILINE)

# Schema categorization
schema_categories = {}

for schema_name, content in schemas:
    schema_name = schema_name.strip()
    
    # Determine category based on schema name
    category = "misc"
    if re.search(r'User|Fid|Verification', schema_name):
        category = "user"
    elif re.search(r'Cast|Reply|Conversation', schema_name):
        category = "cast"
    elif re.search(r'Channel', schema_name):
        category = "channel"
    elif re.search(r'Reaction', schema_name):
        category = "reaction"
    elif re.search(r'Feed', schema_name):
        category = "feed"
    elif re.search(r'Frame', schema_name):
        category = "frame"
    elif re.search(r'Signer', schema_name):
        category = "signer"
    elif re.search(r'Webhook', schema_name):
        category = "webhook"
    elif re.search(r'Error|Conflict|Zod', schema_name):
        category = "error"
    elif re.search(r'Address|Timestamp|Cursor|UUID|PublicKey', schema_name):
        category = "common"
    elif re.search(r'Ban', schema_name):
        category = "ban"
    elif re.search(r'Notification', schema_name):
        category = "notification"
    elif re.search(r'Storage|Allocation|Usage', schema_name):
        category = "storage"
    elif re.search(r'Subscription|Subscribe', schema_name):
        category = "subscription"
    elif re.search(r'Action', schema_name):
        category = "action"
    elif re.search(r'Mute', schema_name):
        category = "mute"
    elif re.search(r'Follow', schema_name):
        category = "follow"
    elif re.search(r'Login|Auth|Nonce', schema_name):
        category = "login"
    elif re.search(r'Onchain|Fungible', schema_name):
        category = "onchain"
    elif re.search(r'Metric', schema_name):
        category = "metric"
    elif re.search(r'Agent', schema_name):
        category = "agent"
    elif re.search(r'Fname', schema_name):
        category = "fname"
    elif re.search(r'Block', schema_name):
        category = "block"
    
    if category not in schema_categories:
        schema_categories[category] = {}
    
    schema_categories[category][schema_name] = f"{schema_name}:\n{content}"

# Write schemas to category files
for category, schemas in schema_categories.items():
    output_file = f"{COMPONENTS_DIR}/schemas/{category}.yaml"
    
    with open(output_file, 'w') as f:
        for schema_name, content in schemas.items():
            f.write(f"{content}\n")
    
    print(f"Extracted {len(schemas)} schemas to {output_file}")

# Extract security schemes using regex
print("Extracting security schemes...")
security_pattern = r'  securitySchemes:\s*\n((?:    .*\n)+)'
security_schemes = re.search(security_pattern, spec_content, re.MULTILINE)

if security_schemes:
    with open(f"{COMPONENTS_DIR}/securitySchemes/api_key.yaml", 'w') as f:
        f.write(security_schemes.group(1))

# Extract parameters using regex
print("Extracting parameters...")
parameters_pattern = r'  parameters:\s*\n((?:    .*\n)+)'
parameters = re.search(parameters_pattern, spec_content, re.MULTILINE)

if parameters:
    with open(f"{COMPONENTS_DIR}/parameters/common.yaml", 'w') as f:
        f.write(parameters.group(1))

# Extract responses using regex
print("Extracting responses...")
responses_pattern = r'  responses:\s*\n((?:    .*\n)+)'
responses = re.search(responses_pattern, spec_content, re.MULTILINE)

if responses:
    with open(f"{COMPONENTS_DIR}/responses/error.yaml", 'w') as f:
        f.write(responses.group(1))

# Create a new spec file with explicit references
print("Creating new spec file...")
new_spec = """openapi: 3.1.0
info:
  title: Farcaster API V2
  version: "2.20.0"
  description: >
    The Farcaster API allows you to interact with the Farcaster protocol.
    See the [Neynar docs](https://docs.neynar.com/reference) for more details.
  contact:
    name: Neynar
    url: https://neynar.com/
    email: team@neynar.com
servers:
  - url: https://api.neynar.com/v2

security:
  - ApiKeyAuth: []

components:
  securitySchemes:
    ApiKeyAuth:
      type: apiKey
      in: header
      name: x-api-key
      description: "API key to authorize requests"
      x-default: "NEYNAR_API_DOCS"
  parameters:
    NeynarExperimentalHeader:
      name: x-neynar-experimental
      in: header
      required: false
      schema:
        type: boolean
        default: false
      description: "Enables experimental features"
      x-is-global-header: true
  responses:
    401Response:
      description: Unauthorized
      content:
        application/json:
          schema:
            $ref: "#/components/schemas/ErrorRes"
    404Response:
      description: Not Found
      content:
        application/json:
          schema:
            $ref: "#/components/schemas/ErrorRes"
    400Response:
      description: Bad Request
      content:
        application/json:
          schema:
            $ref: "#/components/schemas/ErrorRes"
    400ZodResponse:
      description: Bad Request
      content:
        application/json:
          schema:
            $ref: "#/components/schemas/ZodError"
    403Response:
      description: Forbidden
      content:
        application/json:
          schema:
            $ref: "#/components/schemas/ErrorRes"
    409Response:
      description: Conflict
      content:
        application/json:
          schema:
            $ref: "#/components/schemas/ConflictErrorRes"
    500Response:
      description: Internal Server Error
      content:
        application/json:
          schema:
            $ref: "#/components/schemas/ErrorRes"
  schemas:
"""

# Add schema references
for category in sorted(schema_categories.keys()):
    for schema_name in sorted(schema_categories[category].keys()):
        new_spec += f"    {schema_name}:\n      $ref: \"./components/schemas/{category}.yaml#{schema_name}\"\n"

# Extract tags using regex
tags_pattern = r'tags:\s*\n((?:  - .*\n)+)'
tags = re.search(tags_pattern, spec_content, re.MULTILINE)

if tags:
    new_spec += f"\ntags:\n{tags.group(1)}"
else:
    # Add default tags
    new_spec += """
tags:
  - name: User
    description: Operations related to user
  - name: Signer
    description: Operations related to signer
  - name: Cast
    description: Operations related to cast
  - name: Feed
    description: Operations related to feed
  - name: Reaction
    description: Operations related to reaction
  - name: Channel
    description: Operations related to channels
  - name: Frame
    description: Operations related to frames
  - name: Webhook
    description: Operations related to webhooks
  - name: Notification
    description: Operations related to notifications
  - name: Action
    description: Operations related to actions
  - name: Follows
    description: Operations related to follows
  - name: Block
    description: Operations related to blocks
  - name: Mute
    description: Operations related to mutes
  - name: Ban
    description: Operations related to bans
  - name: Storage
    description: Operations related to storage
  - name: Metrics
    description: Operations related to metrics
  - name: Login
    description: Operations related to login
  - name: Onchain
    description: Operations related to onchain events
  - name: Subscribers
    description: Operations related to subscribers
  - name: Agents
    description: Operations related to agents
  - name: fname
    description: Operations related to fnames
"""

# Add paths
new_spec += "\npaths:\n"
for path, _ in paths:
    parts = path.strip().split('/')
    if len(parts) < 3:
        continue
    
    resource = parts[2]
    
    if len(parts) > 3:
        action = '_'.join(parts[3:])
    else:
        action = "index"
    
    new_spec += f"  {path}:\n    $ref: \"./paths/{resource}/{action}.yaml\"\n"

with open("src/v2/spec.yaml", 'w') as f:
    f.write(new_spec)

print("Created new spec file at src/v2/spec.yaml")

# Create a bundling script
bundling_script = """#!/bin/bash

# This script bundles the modular OpenAPI files into a single file for validation

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

# Make the bundling script executable
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

print("Extraction completed successfully")
