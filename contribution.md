# Contribution Guide for Writing OAS v3.1.0

This document outlines important guidelines and gotchas to consider when contributing to the OAS v3.1.0 for the SDK.

## Gotchas While Writing OAS v3.1.0

### 1. Bump up `version` in `src/v2/spec.yaml`

- This will be the version of the sdk that will get published.

### 2. Avoid Deprecated `example`

- In `components.schemas`, avoid using the deprecated `example` field.
- Use `examples` instead. This should be an array.

### 3. Avoid `nullable: true`

- Do not use `nullable: true` as it is completely removed.
- Instead, use:
  ```yaml
  type: [string, "null"]
  ```
  **Note:** Quotes around `"null"` are important.

### 4. Use `kebab-case` for `operationId`

- Always use `kebab-case` for `operationId`.
  - This ensures the `operationId` is SEO-friendly when appended to the API URL in the README (e.g., `user-bulk-by-address`).
  - The generator script uses `operationId` to generate method names by converting `kebab-case` to `camelCase`.

### 5. Handle Comma-Separated Values with `x-comma-separated`

- If the API expects comma-separated values, use the `x-comma-separated` vendor extension.
  ```yaml
  parameters:
    - name: fids
      description: Comma separated list of FIDs, up to 100 at a time
      in: query
      required: true
      example: 194, 191, 6131
      schema:
        type: string
        x-comma-separated: true
  ```

### 6. Use `x-accept-as` for Type Conversion

- To accept a parameter as a different type from what the API expects, use the `x-accept-as` vendor extension.
  ```yaml
  parameters:
    - name: fids
      description: Comma separated list of FIDs, up to 100 at a time
      in: query
      required: true
      example: 194, 191, 6131
      schema:
        type: string
        x-comma-separated: true
        x-accept-as: integer
  ```

### 7. Use `x-is-limit-param` for Limit Parameters

- For limit parameters, use `x-is-limit-param: true` so the SDK can pick up defaults and maximums from the OAS.
  ```yaml
  parameters:
    - name: limit
      in: query
      required: false
      description: Number of users to fetch
      example: 10
      schema:
        type: integer
        format: int32
        default: 5
        minimum: 1
        maximum: 10
      x-is-limit-param: true
  ```

### 8. Naming Request Body Schemas

- End schema names for request bodies with `ReqBody`.
- Avoid using `allOf` or `oneOf` in request body schemas.

### 9. Global Headers

- Always use `kebab-case` for global headers.
- Add `x-is-global-header`for a global header.
  ```yaml
  parameters:
    NeynarExperimentalHeader:
      name: x-neynar-experimental
      in: header
      required: false
      schema:
        type: boolean
        default: false
      description: "Enables experimental features"
      x-is-global-header: true
  ```

### 10. Use `PascalCase` for Tags

- Ensure tags are written in `PascalCase`.
  ```yaml
  tags:
    - HubEvents
  ```

### 11. Use `snake_case` for Top-Level Keys in `reqBody`

- Ensure all top-level keys in `reqBody` are in `snake_case`.

```

```
