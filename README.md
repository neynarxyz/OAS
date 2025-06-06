# OAS
[![Validate and Lint OpenAPI Specs](https://github.com/neynarxyz/OAS/actions/workflows/validate-oas.yml/badge.svg)](https://github.com/neynarxyz/OAS/actions/workflows/validate-oas.yml)

### Overview

The OpenAPI specification for the [Neynar](https://neynar.com) [APIs](https://docs.neynar.com). 
Sign up for an API key on [neynar.com](https://neynar.com).

### Installing Spectral for OpenAPI Validation

We use [Spectral](https://github.com/stoplightio/spectral) to lint and validate our OpenAPI specifications. Spectral helps ensure that the OpenAPI files are compliant with the OpenAPI specification and follow best practices.

#### Install Spectral

You can install Spectral globally using Yarn:

```bash
yarn global add @stoplight/spectral-cli
```

### Validating OpenAPI Specifications

To validate an OpenAPI specification file using Spectral, run:

#### api

```bash
spectral lint src/api/spec.yaml
```

#### hub-api

```bash
spectral lint src/hub-api/spec.yaml
```

Spectral will output any errors or warnings found in the specification files.

### Validating OpenAPI Specifications with Swagger
In addition to Spectral, you can use the Swagger CLI to validate your OpenAPI specifications.

#### Install Swagger CLI
You can install Swagger CLI globally using Yarn:

```bash
yarn global add swagger-cli
```

#### Validate OpenAPI Specifications with Swagger CLI
To validate an OpenAPI specification file using Swagger CLI, run:

api
```bash
swagger-cli validate src/api/spec.yaml
```

hub-api
```bash
swagger-cli validate src/hub-api/spec.yaml
```

This will check for structural errors and report any issues.