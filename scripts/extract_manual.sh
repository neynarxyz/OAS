#!/bin/bash

# This script manually extracts components from the OpenAPI spec

set -e

SPEC_FILE="src/v2/spec.yaml.original"
COMPONENTS_DIR="src/v2/components"
PATHS_DIR="src/v2/paths"

# Create directories
mkdir -p "$COMPONENTS_DIR/schemas"
mkdir -p "$COMPONENTS_DIR/parameters"
mkdir -p "$COMPONENTS_DIR/responses"
mkdir -p "$COMPONENTS_DIR/securitySchemes"

# Extract security schemes
echo "Extracting security schemes..."
yq '.components.securitySchemes' "$SPEC_FILE" > "$COMPONENTS_DIR/securitySchemes/api_key.yaml"

# Extract parameters
echo "Extracting parameters..."
yq '.components.parameters' "$SPEC_FILE" > "$COMPONENTS_DIR/parameters/common.yaml"

# Extract responses
echo "Extracting responses..."
yq '.components.responses' "$SPEC_FILE" > "$COMPONENTS_DIR/responses/error.yaml"

# Create schema category files
echo "Creating schema category files..."
touch "$COMPONENTS_DIR/schemas/common.yaml"
touch "$COMPONENTS_DIR/schemas/user.yaml"
touch "$COMPONENTS_DIR/schemas/cast.yaml"
touch "$COMPONENTS_DIR/schemas/channel.yaml"
touch "$COMPONENTS_DIR/schemas/reaction.yaml"
touch "$COMPONENTS_DIR/schemas/feed.yaml"
touch "$COMPONENTS_DIR/schemas/frame.yaml"
touch "$COMPONENTS_DIR/schemas/signer.yaml"
touch "$COMPONENTS_DIR/schemas/webhook.yaml"
touch "$COMPONENTS_DIR/schemas/error.yaml"
touch "$COMPONENTS_DIR/schemas/ban.yaml"
touch "$COMPONENTS_DIR/schemas/notification.yaml"
touch "$COMPONENTS_DIR/schemas/storage.yaml"
touch "$COMPONENTS_DIR/schemas/subscription.yaml"
touch "$COMPONENTS_DIR/schemas/action.yaml"
touch "$COMPONENTS_DIR/schemas/mute.yaml"
touch "$COMPONENTS_DIR/schemas/follow.yaml"
touch "$COMPONENTS_DIR/schemas/login.yaml"
touch "$COMPONENTS_DIR/schemas/onchain.yaml"
touch "$COMPONENTS_DIR/schemas/metric.yaml"
touch "$COMPONENTS_DIR/schemas/agent.yaml"
touch "$COMPONENTS_DIR/schemas/fname.yaml"
touch "$COMPONENTS_DIR/schemas/block.yaml"
touch "$COMPONENTS_DIR/schemas/misc.yaml"

# Extract paths
echo "Extracting paths..."
mkdir -p "$PATHS_DIR/user"
mkdir -p "$PATHS_DIR/signer"
mkdir -p "$PATHS_DIR/cast"
mkdir -p "$PATHS_DIR/feed"
mkdir -p "$PATHS_DIR/reaction"
mkdir -p "$PATHS_DIR/channel"
mkdir -p "$PATHS_DIR/frame"
mkdir -p "$PATHS_DIR/webhook"
mkdir -p "$PATHS_DIR/notification"
mkdir -p "$PATHS_DIR/action"
mkdir -p "$PATHS_DIR/follow"
mkdir -p "$PATHS_DIR/block"
mkdir -p "$PATHS_DIR/mute"
mkdir -p "$PATHS_DIR/ban"
mkdir -p "$PATHS_DIR/storage"
mkdir -p "$PATHS_DIR/metric"
mkdir -p "$PATHS_DIR/login"
mkdir -p "$PATHS_DIR/onchain"
mkdir -p "$PATHS_DIR/subscriber"
mkdir -p "$PATHS_DIR/agent"
mkdir -p "$PATHS_DIR/fname"

# Create a new spec file that references all components
cat > "src/v2/spec.yaml.new" << EOL
openapi: 3.1.0
info:
  title: Farcaster API V2
  version: "2.20.0"
  description: >
    The Farcaster API allows you to interact with the Farcaster protocol.
    See the [Neynar docs](https://docs.neynar.com/reference) for more details.
  contact:
    name: Neynar
    url: https://neynar.com/
    email: team@neynar.com
servers:
  - url: https://api.neynar.com/v2

security:
  - ApiKeyAuth: []

components:
  securitySchemes:
    \$ref: "./components/securitySchemes/api_key.yaml"
  parameters:
    \$ref: "./components/parameters/common.yaml"
  responses:
    \$ref: "./components/responses/error.yaml"
  schemas:
    # Common schemas
    \$ref: "./components/schemas/common.yaml"
    # User schemas
    \$ref: "./components/schemas/user.yaml"
    # Cast schemas
    \$ref: "./components/schemas/cast.yaml"
    # Channel schemas
    \$ref: "./components/schemas/channel.yaml"
    # Reaction schemas
    \$ref: "./components/schemas/reaction.yaml"
    # Feed schemas
    \$ref: "./components/schemas/feed.yaml"
    # Frame schemas
    \$ref: "./components/schemas/frame.yaml"
    # Signer schemas
    \$ref: "./components/schemas/signer.yaml"
    # Webhook schemas
    \$ref: "./components/schemas/webhook.yaml"
    # Error schemas
    \$ref: "./components/schemas/error.yaml"
    # Ban schemas
    \$ref: "./components/schemas/ban.yaml"
    # Notification schemas
    \$ref: "./components/schemas/notification.yaml"
    # Storage schemas
    \$ref: "./components/schemas/storage.yaml"
    # Subscription schemas
    \$ref: "./components/schemas/subscription.yaml"
    # Action schemas
    \$ref: "./components/schemas/action.yaml"
    # Mute schemas
    \$ref: "./components/schemas/mute.yaml"
    # Follow schemas
    \$ref: "./components/schemas/follow.yaml"
    # Login schemas
    \$ref: "./components/schemas/login.yaml"
    # Onchain schemas
    \$ref: "./components/schemas/onchain.yaml"
    # Metric schemas
    \$ref: "./components/schemas/metric.yaml"
    # Agent schemas
    \$ref: "./components/schemas/agent.yaml"
    # Fname schemas
    \$ref: "./components/schemas/fname.yaml"
    # Block schemas
    \$ref: "./components/schemas/block.yaml"
    # Misc schemas
    \$ref: "./components/schemas/misc.yaml"

tags:
  - name: User
    description: Operations related to user
    externalDocs:
      description: More info about user
      url: https://docs.neynar.com/reference/user-operations
  - name: Signer
    description: Operations related to signer
    externalDocs:
      description: More info about signer
      url: https://docs.neynar.com/reference/signer-operations
  - name: Cast
    description: Operations related to cast
    externalDocs:
      description: More info about cast
      url: https://docs.neynar.com/reference/cast-operations
  - name: Feed
    description: Operations related to feed
    externalDocs:
      description: More info about feed
      url: https://docs.neynar.com/reference/feed-operations
  - name: Reaction
    description: Operations related to reaction
    externalDocs:
      description: More info about reaction
      url: https://docs.neynar.com/reference/reaction-operations
  - name: Channel
    description: Operations related to channels
    externalDocs:
      description: More info about channels
      url: https://docs.neynar.com/reference/channel-operations
  - name: Frame
    description: Operations related to frames
  - name: Webhook
    description: Operations related to webhooks
  - name: Notification
    description: Operations related to notifications
  - name: Action
    description: Operations related to actions
  - name: Follows
    description: Operations related to follows
  - name: Block
    description: Operations related to blocks
  - name: Mute
    description: Operations related to mutes
  - name: Ban
    description: Operations related to bans
  - name: Storage
    description: Operations related to storage
  - name: Metrics
    description: Operations related to metrics
  - name: Login
    description: Operations related to login
  - name: Onchain
    description: Operations related to onchain events
  - name: Subscribers
    description: Operations related to subscribers
  - name: Agents
    description: Operations related to agents
  - name: fname
    description: Operations related to fnames

paths:
  # Dynamically include all path files
  \$ref: "./paths/**/*.yaml"
EOL

echo "Created new spec file at src/v2/spec.yaml.new"

# Create a bundling script
cat > "scripts/bundle_openapi.sh" << 'EOL'
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
EOL

# Make the bundling script executable
chmod +x "scripts/bundle_openapi.sh"

# Update .gitignore to exclude bundle files
if ! grep -q "*.bundle.yaml" .gitignore; then
  echo "*.bundle.yaml" >> .gitignore
fi

echo "Extraction completed successfully"
