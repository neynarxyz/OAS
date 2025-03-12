#!/usr/bin/env python3

import os
import re
import sys
from pathlib import Path

# Configuration
SPEC_FILE = "src/v2/spec.yaml"
COMPONENTS_DIR = "src/v2/components"
PATHS_DIR = "src/v2/paths"

# Create a new spec file with proper YAML formatting
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

# Get all schema files
schema_files = {}
for root, dirs, files in os.walk(f"{COMPONENTS_DIR}/schemas"):
    for file in files:
        if file.endswith('.yaml'):
            category = file.replace('.yaml', '')
            schema_files[category] = os.path.join(root, file)

# Read each schema file and extract schema names
for category, file_path in sorted(schema_files.items()):
    with open(file_path, 'r') as f:
        content = f.read()
    
    # Extract schema names using regex
    schema_names = re.findall(r'^([A-Za-z][A-Za-z0-9]*):', content, re.MULTILINE)
    
    for schema_name in sorted(schema_names):
        new_spec += f"    {schema_name}:\n      $ref: \"./components/schemas/{category}.yaml#{schema_name}\"\n"

# Add tags
new_spec += """
tags:
  - name: User
    description: Operations related to user
    externalDocs:
      description: More info about user
      url: https://docs.neynar.com/reference/user-operations
  - name: Signer
    description: Operations related to signer
    externalDocs:
      description: More info about signer
      url: https://docs.neynar.com/reference/signer-operations
  - name: Cast
    description: Operations related to cast
    externalDocs:
      description: More info about cast
      url: https://docs.neynar.com/reference/cast-operations
  - name: Feed
    description: Operations related to feed
    externalDocs:
      description: More info about feed
      url: https://docs.neynar.com/reference/feed-operations
  - name: Reaction
    description: Operations related to reaction
    externalDocs:
      description: More info about reaction
      url: https://docs.neynar.com/reference/reaction-operations
  - name: Channel
    description: Operations related to channels
    externalDocs:
      description: More info about channels
      url: https://docs.neynar.com/reference/channel-operations
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

# Get all path files
path_files = []
for root, dirs, files in os.walk(PATHS_DIR):
    for file in files:
        if file.endswith('.yaml'):
            rel_path = os.path.relpath(os.path.join(root, file), PATHS_DIR)
            path_files.append(rel_path)

# Group paths by resource
path_resources = {}
for path_file in path_files:
    parts = path_file.split('/')
    if len(parts) < 2:
        continue
    
    resource = parts[0]
    action = parts[1].replace('.yaml', '')
    
    if resource not in path_resources:
        path_resources[resource] = []
    
    path_resources[resource].append((action, path_file))

# Add paths to spec file
for resource, actions in sorted(path_resources.items()):
    for action, path_file in sorted(actions):
        # Determine the API path
        if action == 'index':
            api_path = f"/farcaster/{resource}"
        else:
            # Convert underscores back to slashes for nested paths
            action_path = action.replace('_', '/')
            api_path = f"/farcaster/{resource}/{action_path}"
        
        new_spec += f"  {api_path}:\n    $ref: \"./paths/{path_file}\"\n"

with open(SPEC_FILE, 'w') as f:
    f.write(new_spec)

print(f"Created new spec file at {SPEC_FILE}")

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
