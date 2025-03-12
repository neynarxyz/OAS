#!/bin/bash

# This script extracts all components and paths from the OpenAPI specification

set -e

SPEC_FILE="src/v2/spec.yaml.original"
COMPONENTS_DIR="src/v2/components"
PATHS_DIR="src/v2/paths"

# Create directories if they don't exist
mkdir -p "$COMPONENTS_DIR/schemas"
mkdir -p "$COMPONENTS_DIR/parameters"
mkdir -p "$COMPONENTS_DIR/responses"
mkdir -p "$COMPONENTS_DIR/securitySchemes"

# Extract all paths
echo "Extracting paths..."
yq '.paths | keys' "$SPEC_FILE" | grep -v "^-" | sed 's/^- //' | while read -r path; do
  # Extract resource and action from path
  resource=$(echo "$path" | cut -d'/' -f3)
  action=$(echo "$path" | cut -d'/' -f4-)
  
  # Handle paths with more segments
  if [[ -z "$action" ]]; then
    action="index"
  else
    # Replace slashes with underscores for paths with multiple segments
    action=${action//\//_}
  fi
  
  # Create directory for the resource if it doesn't exist
  mkdir -p "$PATHS_DIR/$resource"
  
  output_file="$PATHS_DIR/$resource/$action.yaml"
  
  # Extract the path definition
  yq ".paths[\"$path\"]" "$SPEC_FILE" > "$output_file"
  
  echo "Extracted path $path to $output_file"
done

# Extract all schemas
echo "Extracting schemas..."
yq '.components.schemas | keys' "$SPEC_FILE" | grep -v "^-" | sed 's/^- //' | while read -r schema; do
  # Determine the category based on schema name
  category="common"
  if [[ "$schema" == *"User"* || "$schema" == *"Fid"* ]]; then
    category="user"
  elif [[ "$schema" == *"Cast"* || "$schema" == *"Reply"* || "$schema" == *"Conversation"* ]]; then
    category="cast"
  elif [[ "$schema" == *"Channel"* ]]; then
    category="channel"
  elif [[ "$schema" == *"Reaction"* ]]; then
    category="reaction"
  elif [[ "$schema" == *"Feed"* ]]; then
    category="feed"
  elif [[ "$schema" == *"Frame"* ]]; then
    category="frame"
  elif [[ "$schema" == *"Signer"* ]]; then
    category="signer"
  elif [[ "$schema" == *"Webhook"* ]]; then
    category="webhook"
  elif [[ "$schema" == *"Error"* || "$schema" == *"Conflict"* || "$schema" == *"Zod"* ]]; then
    category="error"
  elif [[ "$schema" == *"Address"* || "$schema" == *"Timestamp"* || "$schema" == *"Cursor"* ]]; then
    category="common"
  elif [[ "$schema" == *"Ban"* ]]; then
    category="ban"
  elif [[ "$schema" == *"Notification"* ]]; then
    category="notification"
  elif [[ "$schema" == *"Storage"* ]]; then
    category="storage"
  elif [[ "$schema" == *"Subscription"* ]]; then
    category="subscription"
  elif [[ "$schema" == *"Action"* ]]; then
    category="action"
  elif [[ "$schema" == *"Mute"* ]]; then
    category="mute"
  elif [[ "$schema" == *"Follow"* ]]; then
    category="follow"
  elif [[ "$schema" == *"Login"* ]]; then
    category="login"
  elif [[ "$schema" == *"Onchain"* || "$schema" == *"Fungible"* ]]; then
    category="onchain"
  elif [[ "$schema" == *"Metric"* ]]; then
    category="metric"
  elif [[ "$schema" == *"Agent"* ]]; then
    category="agent"
  elif [[ "$schema" == *"Fname"* ]]; then
    category="fname"
  else
    category="misc"
  fi
  
  # Create the category file if it doesn't exist
  category_file="$COMPONENTS_DIR/schemas/$category.yaml"
  if [[ ! -f "$category_file" ]]; then
    touch "$category_file"
  fi
  
  # Extract the schema definition and append to the category file
  echo "$schema:" >> "$category_file"
  yq ".components.schemas.$schema" "$SPEC_FILE" >> "$category_file"
  echo "" >> "$category_file"
  
  echo "Extracted schema $schema to $category_file"
done

# Extract security schemes
echo "Extracting security schemes..."
yq '.components.securitySchemes' "$SPEC_FILE" > "$COMPONENTS_DIR/securitySchemes/api_key.yaml"

# Extract parameters
echo "Extracting parameters..."
yq '.components.parameters' "$SPEC_FILE" > "$COMPONENTS_DIR/parameters/common.yaml"

# Extract responses
echo "Extracting responses..."
yq '.components.responses' "$SPEC_FILE" > "$COMPONENTS_DIR/responses/error.yaml"

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
