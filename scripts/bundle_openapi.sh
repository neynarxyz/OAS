#!/bin/bash

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
