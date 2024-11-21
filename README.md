# OAS

### Overview

The OpenAPI specification for the [Neynar](https://neynar.com) [APIs](https://docs.neynar.com). 
Sign up for an API key on [neynar.com](https://neynar.com).

###  Installing client code generator

```
brew install openapi-generator
```
Prerequisite - [Java](https://www.java.com/) must be installed

### Generating typescript client code using the OAS definitions

#### v1

```
openapi-generator generate -i src/v1/spec.yaml -g typescript-axios -o src/v1/swagger-tmp
```

#### v2

```
openapi-generator generate -i src/v2/spec.yaml -g typescript-axios -o src/v2/swagger-tmp
```

#### hub-rest-api

```
openapi-generator generate -i src/hub-rest-api/spec.yaml -g typescript-axios -o src/hub-rest-api/swagger-tmp
```

For other languages, replace \<generator\> with a [desired generator](https://openapi-generator.tech/docs/generators)