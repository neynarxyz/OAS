#!/bin/bash

# This script splits the OpenAPI specification into modular files
# It extracts components and paths into separate files

set -e

SPEC_FILE="src/v2/spec.yaml"
COMPONENTS_DIR="src/v2/components"
PATHS_DIR="src/v2/paths"

# Create directories if they don't exist
mkdir -p "$COMPONENTS_DIR/schemas"
mkdir -p "$COMPONENTS_DIR/parameters"
mkdir -p "$COMPONENTS_DIR/responses"
mkdir -p "$COMPONENTS_DIR/securitySchemes"
mkdir -p "$PATHS_DIR"

# Function to extract a schema to a file
extract_schema() {
  local schema_name=$1
  local output_file="$COMPONENTS_DIR/schemas/${schema_name,,}.yaml"
  
  # Extract the schema definition
  yq ".components.schemas.$schema_name" "$SPEC_FILE" > "$output_file"
  
  echo "Extracted schema $schema_name to $output_file"
}

# Function to extract a path to a file
extract_path() {
  local path=$1
  local resource=$(echo "$path" | cut -d'/' -f2)
  local action=$(echo "$path" | cut -d'/' -f3)
  
  # Create directory for the resource if it doesn't exist
  mkdir -p "$PATHS_DIR/$resource"
  
  local output_file="$PATHS_DIR/$resource/$action.yaml"
  
  # Extract the path definition
  yq ".paths[\"$path\"]" "$SPEC_FILE" > "$output_file"
  
  echo "Extracted path $path to $output_file"
}

# Extract security schemes
yq '.components.securitySchemes.ApiKeyAuth' "$SPEC_FILE" > "$COMPONENTS_DIR/securitySchemes/api_key.yaml"
echo "Extracted security scheme ApiKeyAuth"

# Extract parameters
yq '.components.parameters.NeynarExperimentalHeader' "$SPEC_FILE" > "$COMPONENTS_DIR/parameters/common.yaml"
echo "Extracted parameter NeynarExperimentalHeader"

# Extract responses
yq '.components.responses' "$SPEC_FILE" > "$COMPONENTS_DIR/responses/error.yaml"
echo "Extracted responses"

# Extract common schemas
extract_schema "Address"
extract_schema "SolAddress"
extract_schema "Fid"
extract_schema "ChannelId"
extract_schema "SignerUUID"
extract_schema "Timestamp"
extract_schema "Ed25519PublicKey"
extract_schema "NextCursor"
extract_schema "ErrorRes"
extract_schema "ConflictErrorRes"
extract_schema "ZodError"

# Extract user schemas
extract_schema "User"
extract_schema "UserFIDResponse"

# Extract signer schemas
extract_schema "Signer"

# Extract cast schemas
extract_schema "Cast"
extract_schema "CastParamType"
extract_schema "ReplyDepth"
extract_schema "CastConversationSortType"
extract_schema "CastConversationResponse"

# Extract feed schemas
extract_schema "FeedResponse"
extract_schema "FeedTrendingProvider"

# Extract reaction schemas
extract_schema "Reaction"
extract_schema "ReactionType"
extract_schema "ReactionsType"
extract_schema "ReactionsResponse"

# Extract channel schemas
extract_schema "Channel"
extract_schema "ChannelResponse"

# Extract frame schemas
extract_schema "Frame"
extract_schema "FrameButton"
extract_schema "ValidateFrameReqBody"
extract_schema "ValidateFrameResponse"

# Extract paths
extract_path "/farcaster/user/fid"
extract_path "/farcaster/signer/status"
extract_path "/farcaster/cast/conversation"
extract_path "/farcaster/feed/trending"
extract_path "/farcaster/reactions"
extract_path "/farcaster/channel"
extract_path "/farcaster/frame/validate"

# Create a minimal main spec file with references
cat > "$SPEC_FILE.modular" << EOF
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
    ApiKeyAuth:
      \$ref: "./components/securitySchemes/api_key.yaml#/ApiKeyAuth"
  parameters:
    NeynarExperimentalHeader:
      \$ref: "./components/parameters/common.yaml#/NeynarExperimentalHeader"
  responses:
    401Response:
      \$ref: "./components/responses/error.yaml#/401Response"
    404Response:
      \$ref: "./components/responses/error.yaml#/404Response"
    400Response:
      \$ref: "./components/responses/error.yaml#/400Response"
    400ZodResponse:
      \$ref: "./components/responses/error.yaml#/400ZodResponse"
    403Response:
      \$ref: "./components/responses/error.yaml#/403Response"
    409Response:
      \$ref: "./components/responses/error.yaml#/409Response"
    500Response:
      \$ref: "./components/responses/error.yaml#/500Response"
  schemas:
    # Common schemas
    Address:
      \$ref: "./components/schemas/address.yaml#/Address"
    SolAddress:
      \$ref: "./components/schemas/soladdress.yaml#/SolAddress"
    Fid:
      \$ref: "./components/schemas/fid.yaml#/Fid"
    ChannelId:
      \$ref: "./components/schemas/channelid.yaml#/ChannelId"
    SignerUUID:
      \$ref: "./components/schemas/signeruuid.yaml#/SignerUUID"
    Timestamp:
      \$ref: "./components/schemas/timestamp.yaml#/Timestamp"
    Ed25519PublicKey:
      \$ref: "./components/schemas/ed25519publickey.yaml#/Ed25519PublicKey"
    NextCursor:
      \$ref: "./components/schemas/nextcursor.yaml#/NextCursor"
    
    # Error schemas
    ErrorRes:
      \$ref: "./components/schemas/errorres.yaml#/ErrorRes"
    ConflictErrorRes:
      \$ref: "./components/schemas/conflicterrorres.yaml#/ConflictErrorRes"
    ZodError:
      \$ref: "./components/schemas/zoderror.yaml#/ZodError"
    
    # User schemas
    UserFIDResponse:
      \$ref: "./components/schemas/userfidresponse.yaml#/UserFIDResponse"
    User:
      \$ref: "./components/schemas/user.yaml#/User"
    
    # Signer schemas
    Signer:
      \$ref: "./components/schemas/signer.yaml#/Signer"
    
    # Cast schemas
    CastParamType:
      \$ref: "./components/schemas/castparamtype.yaml#/CastParamType"
    ReplyDepth:
      \$ref: "./components/schemas/replydepth.yaml#/ReplyDepth"
    CastConversationSortType:
      \$ref: "./components/schemas/castconversationsorttype.yaml#/CastConversationSortType"
    CastConversationResponse:
      \$ref: "./components/schemas/castconversationresponse.yaml#/CastConversationResponse"
    Cast:
      \$ref: "./components/schemas/cast.yaml#/Cast"
    
    # Feed schemas
    FeedTrendingProvider:
      \$ref: "./components/schemas/feedtrendingprovider.yaml#/FeedTrendingProvider"
    FeedResponse:
      \$ref: "./components/schemas/feedresponse.yaml#/FeedResponse"
    
    # Reaction schemas
    ReactionType:
      \$ref: "./components/schemas/reactiontype.yaml#/ReactionType"
    ReactionsType:
      \$ref: "./components/schemas/reactionstype.yaml#/ReactionsType"
    ReactionsResponse:
      \$ref: "./components/schemas/reactionsresponse.yaml#/ReactionsResponse"
    Reaction:
      \$ref: "./components/schemas/reaction.yaml#/Reaction"
    
    # Channel schemas
    ChannelResponse:
      \$ref: "./components/schemas/channelresponse.yaml#/ChannelResponse"
    Channel:
      \$ref: "./components/schemas/channel.yaml#/Channel"
    
    # Frame schemas
    ValidateFrameReqBody:
      \$ref: "./components/schemas/validateframereqbody.yaml#/ValidateFrameReqBody"
    ValidateFrameResponse:
      \$ref: "./components/schemas/validateframeresponse.yaml#/ValidateFrameResponse"
    Frame:
      \$ref: "./components/schemas/frame.yaml#/Frame"
    FrameButton:
      \$ref: "./components/schemas/framebutton.yaml#/FrameButton"

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

paths:
  /farcaster/user/fid:
    \$ref: "./paths/user/fid.yaml"
  /farcaster/signer/status:
    \$ref: "./paths/signer/status.yaml"
  /farcaster/cast/conversation:
    \$ref: "./paths/cast/conversation.yaml"
  /farcaster/feed/trending:
    \$ref: "./paths/feed/trending.yaml"
  /farcaster/reactions:
    \$ref: "./paths/reaction/reactions.yaml"
  /farcaster/channel:
    \$ref: "./paths/channel/info.yaml"
  /farcaster/frame/validate:
    \$ref: "./paths/frame/validate.yaml"
EOF

echo "Created modular spec file at $SPEC_FILE.modular"
echo "You can replace the original spec file with this modular version after verification"

# Make the script executable
chmod +x "$0"

echo "Script completed successfully"
