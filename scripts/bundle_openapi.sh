#!/bin/bash

# This script bundles the modular OpenAPI files into a single file for validation

set -e

SPEC_FILE="src/v2/spec.yaml"
BUNDLE_FILE="src/v2/spec.bundle.yaml"

# Bundle the spec
swagger-cli bundle "$SPEC_FILE" -o "$BUNDLE_FILE"

echo "Bundled spec to $BUNDLE_FILE"
