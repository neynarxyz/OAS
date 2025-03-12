# Modular OpenAPI Specification

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
