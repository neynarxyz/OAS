# OAS

The OpenAPI specification for the Neynar APIs

### Installation
Prerequisite
- JAVA must be installed

replace \<generator\> with a [desired generator](https://openapi-generator.tech/docs/generators).

```
brew install openapi-generator

// v1
openapi-generator generate -i src/v1/spec.yaml -g <generator> -o src/v1/swagger-tmp --config openapi-generator-config.json
```

```
// v2
openapi-generator generate -i src/v2/spec.yaml -g typescript-axios -o src/v2/swagger-tmp --config openapi-generator-config.json
```

### API Documentation
[docs.neynar.com](https://docs.neynar.com/)

### Clients library that use this specs
[farcaster-js](https://github.com/standard-crypto/farcaster-js/)

### How to get an API key?
Get more information at [neynar.com](https://neynar.com/)
