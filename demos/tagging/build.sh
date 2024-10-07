#!/bin/bash

# Default values for all labels
DEFAULT_TITLE="My Image"
DEFAULT_DESCRIPTION="This is my application image"
DEFAULT_AUTHORS="$(git config user.name) <$(git config user.email)>"
DEFAULT_URL="http://example.com"
DEFAULT_DOCUMENTATION="http://example.com/docs"
DEFAULT_SOURCE=$(git config --get remote.origin.url || echo "http://example.com/repo")
DEFAULT_VERSION="1.0.0"
DEFAULT_VENDOR="My Company"
DEFAULT_LICENSES=$(grep -qi "mit license" LICENSE && echo "MIT" || echo "Unknown")
DEFAULT_REF_NAME=""  # Empty ref.name by default, to be handled later
DEFAULT_REVISION=$(git rev-parse HEAD 2>/dev/null || echo "unknown")
DEFAULT_CREATED=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
DEFAULT_IMAGE="my-image"  # Docker image name
DRY_RUN=false  # Default is to run the build, not a dry run
SHOW_DOCKERFILE_LABELS=false  # Default is to NOT show Dockerfile labels unless specified

# Display usage information
usage() {
  echo "Usage: $0 [options]"
  echo
  echo "Options:"
  echo "  --title               Set the image title (default: '$DEFAULT_TITLE')"
  echo "  --description         Set the image description (default: '$DEFAULT_DESCRIPTION')"
  echo "  --authors             Set the image authors (default: '$DEFAULT_AUTHORS')"
  echo "  --url                 Set the image URL (default: '$DEFAULT_URL')"
  echo "  --documentation       Set the image documentation URL (default: '$DEFAULT_DOCUMENTATION')"
  echo "  --source              Set the image source repository URL (default: '$DEFAULT_SOURCE')"
  echo "  --version             Set the image version (default: '$DEFAULT_VERSION')"
  echo "  --vendor              Set the image vendor (default: '$DEFAULT_VENDOR')"
  echo "  --licenses            Set the image licenses (default: auto-detected from LICENSE file or '$DEFAULT_LICENSES')"
  echo "  --ref-name            Set the image reference name (tag) (default: uses version)"
  echo "  --revision            Set the image revision (default: auto-detected from Git or '$DEFAULT_REVISION')"
  echo "  --created             Set the image creation time (default: current UTC time '$DEFAULT_CREATED')"
  echo "  --image               Set the Docker image name (default: '$DEFAULT_IMAGE')"
  echo "  --dry-run             Display the Docker build command without executing it"
  echo "  --show-dockerfile-labels  Show the Dockerfile-style labels in the output"
  echo "  --help                Show this usage information"
  echo
  echo "Example:"
  echo "  $0 --image myapp --version 1.2.0 --dry-run"
  echo "  $0 --image myapp --version 1.2.0 --show-dockerfile-labels"
}

# Allow CLI arguments to overwrite defaults
while [[ "$#" -gt 0 ]]; do
  case $1 in
    --help) usage; exit 0 ;;  # Show usage information and exit
    --title) TITLE="$2"; shift ;;
    --description) DESCRIPTION="$2"; shift ;;
    --authors) AUTHORS="$2"; shift ;;
    --url) URL="$2"; shift ;;
    --documentation) DOCUMENTATION="$2"; shift ;;
    --source) SOURCE="$2"; shift ;;
    --version) VERSION="$2"; shift ;;
    --vendor) VENDOR="$2"; shift ;;
    --licenses) LICENSES="$2"; shift ;;
    --ref-name) REF_NAME="$2"; shift ;;
    --revision) REVISION="$2"; shift ;;
    --created) CREATED="$2"; shift ;;
    --image) IMAGE="$2"; shift ;;  # Allow image name as a parameter
    --dry-run) DRY_RUN=true ;;  # Dry run flag
    --show-dockerfile-labels) SHOW_DOCKERFILE_LABELS=true ;;  # Flag to show Dockerfile labels
    *) echo "Unknown parameter passed: $1"; usage; exit 1 ;;
  esac
  shift
done

# Use defaults if CLI arguments not provided
TITLE="${TITLE:-$DEFAULT_TITLE}"
DESCRIPTION="${DESCRIPTION:-$DEFAULT_DESCRIPTION}"
AUTHORS="${AUTHORS:-$DEFAULT_AUTHORS}"
URL="${URL:-$DEFAULT_URL}"
DOCUMENTATION="${DOCUMENTATION:-$DEFAULT_DOCUMENTATION}"
SOURCE="${SOURCE:-$DEFAULT_SOURCE}"
VERSION="${VERSION:-$DEFAULT_VERSION}"
VENDOR="${VENDOR:-$DEFAULT_VENDOR}"
LICENSES="${LICENSES:-$DEFAULT_LICENSES}"
REVISION="${REVISION:-$DEFAULT_REVISION}"
CREATED="${CREATED:-$DEFAULT_CREATED}"
IMAGE="${IMAGE:-$DEFAULT_IMAGE}"

# Function to prompt for input with current value as default
prompt() {
  local var_name=$1
  local prompt_text=$2
  local current_value=$3
  read -p "$prompt_text [$current_value]: " input
  if [ -n "$input" ]; then
    eval "$var_name='$input'"
  fi
}

# Prompt user to overwrite values (optional)
prompt TITLE "Enter the image title" "$TITLE"
prompt DESCRIPTION "Enter the image description" "$DESCRIPTION"
prompt AUTHORS "Enter the image authors" "$AUTHORS"
prompt URL "Enter the image URL" "$URL"
prompt DOCUMENTATION "Enter the image documentation URL" "$DOCUMENTATION"
prompt SOURCE "Enter the image source repository URL" "$SOURCE"
prompt VERSION "Enter the image version" "$VERSION"
prompt VENDOR "Enter the image vendor" "$VENDOR"
prompt LICENSES "Enter the image licenses" "$LICENSES"
prompt REF_NAME "Enter the image reference name" "$REF_NAME"

# If ref.name (tag) is not specified, fall back to version for ref.name
if [ -z "$REF_NAME" ]; then
  REF_NAME="$VERSION"
fi

# Conditionally show Dockerfile labels if the flag is provided
if [ "$SHOW_DOCKERFILE_LABELS" = true ]; then
  cat <<EOF

# Dockerfile labels
LABEL org.opencontainers.image.created="$CREATED" \\
      org.opencontainers.image.authors="$AUTHORS" \\
      org.opencontainers.image.url="$URL" \\
      org.opencontainers.image.documentation="$DOCUMENTATION" \\
      org.opencontainers.image.source="$SOURCE" \\
      org.opencontainers.image.version="$VERSION" \\
      org.opencontainers.image.revision="$REVISION" \\
      org.opencontainers.image.vendor="$VENDOR" \\
      org.opencontainers.image.licenses="$LICENSES" \\
      org.opencontainers.image.ref.name="$REF_NAME" \\
      org.opencontainers.image.title="$TITLE" \\
      org.opencontainers.image.description="$DESCRIPTION"

EOF
fi

# Build the Docker build command
DOCKER_CMD="docker build -t $IMAGE:$REF_NAME . --label org.opencontainers.image.created=\"$CREATED\" \\"
DOCKER_CMD="$DOCKER_CMD --label org.opencontainers.image.authors=\"$AUTHORS\" \\"
DOCKER_CMD="$DOCKER_CMD --label org.opencontainers.image.url=\"$URL\" \\"
DOCKER_CMD="$DOCKER_CMD --label org.opencontainers.image.documentation=\"$DOCUMENTATION\" \\"
DOCKER_CMD="$DOCKER_CMD --label org.opencontainers.image.source=\"$SOURCE\" \\"
DOCKER_CMD="$DOCKER_CMD --label org.opencontainers.image.version=\"$VERSION\" \\"
DOCKER_CMD="$DOCKER_CMD --label org.opencontainers.image.revision=\"$REVISION\" \\"
DOCKER_CMD="$DOCKER_CMD --label org.opencontainers.image.vendor=\"$VENDOR\" \\"
DOCKER_CMD="$DOCKER_CMD --label org.opencontainers.image.licenses=\"$LICENSES\" \\"
DOCKER_CMD="$DOCKER_CMD --label org.opencontainers.image.ref.name=\"$REF_NAME\" \\"
DOCKER_CMD="$DOCKER_CMD --label org.opencontainers.image.title=\"$TITLE\" \\"
DOCKER_CMD="$DOCKER_CMD --label org.opencontainers.image.description=\"$DESCRIPTION\" \\"
DOCKER_CMD="$DOCKER_CMD --attest type=sbom,generator=docker/scout-sbom-indexer:latest --push"

# Check if dry run flag is set
if [ "$DRY_RUN" = true ]; then
  echo "Dry run: Docker build command would be:"
  echo "$DOCKER_CMD"
else
  echo "Running Docker build command..."
  eval "$DOCKER_CMD"
fi
