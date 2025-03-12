#!/bin/bash

# This script updates the CI workflow to bundle and validate the spec

set -e

# Update the validate-oas.yml workflow
cat > .github/workflows/validate-oas.yml << 'EOL'
name: Validate OpenAPI Specifications

on:
  push:
    branches: [ main ]
    paths:
      - 'src/**/*.yaml'
      - 'src/**/*.yml'
      - 'src/**/*.json'
  pull_request:
    branches: [ main ]
    paths:
      - 'src/**/*.yaml'
      - 'src/**/*.yml'
      - 'src/**/*.json'

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Install Dependencies
        run: |
          npm install -g @stoplight/spectral@latest @apidevtools/swagger-cli@latest

      - name: Find Main OpenAPI Spec Files
        run: |
          echo "##[group]Searching for main OpenAPI spec files"
          find src -type f -name "spec.yaml" > spec_files.txt
          echo "Found the following spec files:"
          cat spec_files.txt
          echo "##[endgroup]"
        shell: bash

      - name: Bundle and Validate OpenAPI Spec Files
        run: |
          while IFS= read -r file; do
            echo "Bundling and validating $file"
            bundle_file="${file%.yaml}.bundle.yaml"
            swagger-cli bundle "$file" -o "$bundle_file"
            swagger-cli validate "$bundle_file"
          done < spec_files.txt
        shell: bash

      - name: Lint OpenAPI Spec Files
        run: |
          while IFS= read -r file; do
            echo "Linting $file"
            spectral lint "$file"
          done < spec_files.txt
        shell: bash
EOL

echo "Updated CI workflow"

# Update .gitignore to exclude bundle files
if ! grep -q "*.bundle.yaml" .gitignore; then
  echo "*.bundle.yaml" >> .gitignore
  echo "Updated .gitignore"
fi

echo "CI update completed successfully"
