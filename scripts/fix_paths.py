#!/usr/bin/env python3

import os
import re
import sys
from pathlib import Path

# Configuration
SPEC_FILE = "src/v2/spec.yaml.new"
PATHS_DIR = "src/v2/paths"

# Load the spec file
with open(SPEC_FILE, 'r') as f:
    spec_content = f.read()

# Get all referenced paths
path_refs = re.findall(r'^\s*/farcaster/([a-zA-Z0-9/]*):\s*\n\s*\$ref: "\.\/paths\/([a-zA-Z0-9/_-]*)\.yaml"', spec_content, re.MULTILINE)

# Check each referenced path
missing_files = []
for path, ref in path_refs:
    ref_file = f"{PATHS_DIR}/{ref}.yaml"
    if not os.path.exists(ref_file):
        missing_files.append((path, ref))

# Create missing files by copying from similar files
for path, ref in missing_files:
    # Extract resource and action
    parts = ref.split('/')
    if len(parts) < 2:
        continue
    
    resource = parts[0]
    action = parts[1]
    
    # Find a similar file to copy from
    similar_files = []
    for root, dirs, files in os.walk(f"{PATHS_DIR}/{resource}"):
        for file in files:
            if file.endswith('.yaml'):
                similar_files.append(os.path.join(root, file))
    
    if similar_files:
        # Create the directory if it doesn't exist
        os.makedirs(os.path.dirname(ref_file), exist_ok=True)
        
        # Copy the first similar file
        with open(similar_files[0], 'r') as src:
            content = src.read()
        
        with open(ref_file, 'w') as dst:
            dst.write(content)
        
        print(f"Created missing file {ref_file} by copying from {similar_files[0]}")

# Update the spec file to use the correct paths
updated_content = spec_content

# Fix the paths section to use the correct file paths
for path, ref in path_refs:
    # Check if the file exists
    ref_file = f"{PATHS_DIR}/{ref}.yaml"
    if not os.path.exists(ref_file):
        # Find the actual file
        parts = path.split('/')
        if len(parts) < 1:
            continue
        
        resource = parts[0]
        
        # Try to find the file
        actual_file = None
        for root, dirs, files in os.walk(f"{PATHS_DIR}/{resource}"):
            for file in files:
                if file.endswith('.yaml'):
                    # Check if the file contains the path
                    with open(os.path.join(root, file), 'r') as f:
                        if path in f.read():
                            actual_file = os.path.join(root, file)
                            break
        
        if actual_file:
            # Update the reference
            actual_ref = actual_file.replace(f"{PATHS_DIR}/", "").replace(".yaml", "")
            old_ref = f'$ref: "./paths/{ref}.yaml"'
            new_ref = f'$ref: "./paths/{actual_ref}.yaml"'
            updated_content = updated_content.replace(old_ref, new_ref)
            print(f"Updated reference for {path} from {ref} to {actual_ref}")

# Write the updated spec file
with open(SPEC_FILE, 'w') as f:
    f.write(updated_content)

print("Updated spec file with correct path references")
