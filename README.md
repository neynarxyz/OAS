# oas

The OpenAPI specification for the Neynar APIs

### Installation

Prerequisite

JAVA must be installed

replace [\<generator\>](https://openapi-generator.tech/docs/generators) with desired generator.

```
    brew install openapi-generator

    // v1
    openapi-generator generate -i src/v1/spec.yaml -g <generator> -o src/v1/swagger-tmp --config openapi-generator-config.json

    //v2
    openapi-generator generate -i src/v2/spec.yaml -g <generator> -o src/v1/swagger-tmp --config openapi-generator-config.json
```
