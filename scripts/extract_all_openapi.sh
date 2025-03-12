#!/bin/bash

# This script extracts all components and paths from the OpenAPI specification

set -e

SPEC_FILE="src/v2/spec.yaml"
COMPONENTS_DIR="src/v2/components"
PATHS_DIR="src/v2/paths"

# Create directories if they don't exist
mkdir -p "$COMPONENTS_DIR/schemas"
mkdir -p "$COMPONENTS_DIR/parameters"
mkdir -p "$COMPONENTS_DIR/responses"
mkdir -p "$COMPONENTS_DIR/securitySchemes"

# Extract all paths
echo "Extracting paths..."
grep -o "^  /farcaster/[a-zA-Z0-9/]*" "$SPEC_FILE" | sort | uniq | while read -r path; do
  # Extract resource and action from path
  resource=$(echo "$path" | cut -d'/' -f3)
  action=$(echo "$path" | cut -d'/' -f4)
  
  # Handle paths with more segments
  if [[ -z "$action" ]]; then
    action="index"
  elif [[ $(echo "$path" | grep -o "/" | wc -l) -gt 3 ]]; then
    # For paths with more than 4 segments, use the remaining path as the action
    action=$(echo "$path" | cut -d'/' -f4-)
    action=${action//\//_}
  fi
  
  # Create directory for the resource if it doesn't exist
  mkdir -p "$PATHS_DIR/$resource"
  
  output_file="$PATHS_DIR/$resource/$action.yaml"
  
  # Extract the path definition
  yq ".paths[\"$path\"]" "$SPEC_FILE" > "$output_file"
  
  echo "Extracted path $path to $output_file"
done

# Extract all schemas
echo "Extracting schemas..."
grep -o "^    [A-Za-z][A-Za-z0-9]*:" "$SPEC_FILE" | sed 's/://' | sort | uniq | while read -r schema; do
  # Determine the category based on schema name
  category="common"
  if [[ "$schema" == *"User"* || "$schema" == *"Fid"* ]]; then
    category="user"
  elif [[ "$schema" == *"Cast"* || "$schema" == *"Reply"* ]]; then
    category="cast"
  elif [[ "$schema" == *"Channel"* ]]; then
    category="channel"
  elif [[ "$schema" == *"Reaction"* ]]; then
    category="reaction"
  elif [[ "$schema" == *"Feed"* ]]; then
    category="feed"
  elif [[ "$schema" == *"Frame"* ]]; then
    category="frame"
  elif [[ "$schema" == *"Signer"* ]]; then
    category="signer"
  elif [[ "$schema" == *"Webhook"* ]]; then
    category="webhook"
  elif [[ "$schema" == *"Error"* || "$schema" == *"Conflict"* || "$schema" == *"Zod"* ]]; then
    category="error"
  elif [[ "$schema" == *"Address"* || "$schema" == *"Timestamp"* || "$schema" == *"Cursor"* ]]; then
    category="common"
  fi
  
  # Create the category file if it doesn't exist
  category_file="$COMPONENTS_DIR/schemas/$category.yaml"
  if [[ ! -f "$category_file" ]]; then
    touch "$category_file"
  fi
  
  # Extract the schema definition and append to the category file
  echo "# $schema" >> "$category_file"
  yq ".components.schemas.$schema" "$SPEC_FILE" >> "$category_file"
  echo "" >> "$category_file"
  
  echo "Extracted schema $schema to $category_file"
done

# Extract security schemes
echo "Extracting security schemes..."
yq '.components.securitySchemes' "$SPEC_FILE" > "$COMPONENTS_DIR/securitySchemes/api_key.yaml"

# Extract parameters
echo "Extracting parameters..."
yq '.components.parameters' "$SPEC_FILE" > "$COMPONENTS_DIR/parameters/common.yaml"

# Extract responses
echo "Extracting responses..."
yq '.components.responses' "$SPEC_FILE" > "$COMPONENTS_DIR/responses/error.yaml"

echo "Extraction completed successfully"
