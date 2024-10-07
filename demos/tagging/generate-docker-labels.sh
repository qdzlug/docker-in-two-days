#!/bin/bash

# Default values for all labels
DEFAULT_TITLE="My Image"
DEFAULT_DESCRIPTION="This is my application image"
DEFAULT_AUTHORS="$(git config user.name) <$(git config user.email)>"
DEFAULT_SOURCE=$(git config --get remote.origin.url || echo "http://example.com/repo")
DEFAULT_VERSION="1.0.0"
DEFAULT_REF_NAME=""  # Empty ref.name by default, to be handled later
DEFAULT_REVISION=$(git rev-parse HEAD 2>/dev/null || echo "unknown")
DEFAULT_CREATED=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
DEFAULT_IMAGE="my-image"  # Docker image name
DEFAULT_NAMESPACE="my-namespace"  # Default namespace for the image
DRY_RUN=false  # Default is to run the build, not a dry run
SHOW_LABELS=false  # Default is to NOT show Dockerfile labels unless specified
LABEL_FILE=""  # Default: no label file

# Display usage information
usage() {
  echo "Usage: $0 [options]"
  echo
  echo "Options:"
  echo "  --title               Set the image title (default: '$DEFAULT_TITLE')"
  echo "  --description         Set the image description (default: '$DEFAULT_DESCRIPTION')"
  echo "  --authors             Set the image authors (default: '$DEFAULT_AUTHORS')"
  echo "  --source              Set the image source repository URL (default: '$DEFAULT_SOURCE')"
  echo "  --version             Set the image version (default: '$DEFAULT_VERSION')"
  echo "  --ref-name            Set the image reference name (tag) (default: uses version)"
  echo "  --revision            Set the image revision (default: auto-detected from Git or '$DEFAULT_REVISION')"
  echo "  --created             Set the image creation time (default: current UTC time '$DEFAULT_CREATED')"
  echo "  --image               Set the Docker image name (default: '$DEFAULT_IMAGE')"
  echo "  --namespace           Set the Docker image namespace (default: '$DEFAULT_NAMESPACE')"
  echo "  --dry-run             Display the Docker build command without executing it"
  echo "  --show-labels         Show the Dockerfile-style labels in the output"
  echo "  --labels-file         Provide a file with labels (e.g., 'labels.txt')"
  echo "  --help                Show this usage information"
  echo
  echo "Example:"
  echo "  $0 --image myapp --namespace myorg --version 1.2.0 --dry-run"
  echo "  $0 --image myapp --namespace myorg --version 1.2.0 --show-labels"
}

# Function to read labels from a file and set them as default values
read_labels_file() {
  local file="$1"
  if [ ! -f "$file" ]; then
    echo "Labels file '$file' not found."
    exit 1
  fi

  while IFS='=' read -r key value; do
    key=$(echo "$key" | tr -d '[:space:]')  # Strip whitespace
    value=$(echo "$value" | tr -d '[:space:]')
    case "$key" in
      title) DEFAULT_TITLE="$value" ;;
      description) DEFAULT_DESCRIPTION="$value" ;;
      authors) DEFAULT_AUTHORS="$value" ;;
      source) DEFAULT_SOURCE="$value" ;;
      version) DEFAULT_VERSION="$value" ;;
      ref-name) DEFAULT_REF_NAME="$value" ;;
      revision) DEFAULT_REVISION="$value" ;;
      created) DEFAULT_CREATED="$value" ;;
      image) DEFAULT_IMAGE="$value" ;;
      namespace) DEFAULT_NAMESPACE="$value" ;;
    esac
  done < "$file"
}

# Allow CLI arguments to overwrite defaults
while [[ "$#" -gt 0 ]]; do
  case $1 in
    --help) usage; exit 0 ;;  # Show usage information and exit
    --title) TITLE="$2"; shift ;;
    --description) DESCRIPTION="$2"; shift ;;
    --authors) AUTHORS="$2"; shift ;;
    --source) SOURCE="$2"; shift ;;
    --version) VERSION="$2"; shift ;;
    --ref-name) REF_NAME="$2"; shift ;;
    --revision) REVISION="$2"; shift ;;
    --created) CREATED="$2"; shift ;;
    --image) IMAGE="$2"; shift ;;  # Allow image name as a parameter
    --namespace) NAMESPACE="$2"; shift ;;  # Add namespace flag
    --dry-run) DRY_RUN=true ;;  # Dry run flag
    --show-labels) SHOW_LABELS=true ;;  # Flag to show Dockerfile labels
    --labels-file) LABEL_FILE="$2"; shift ;;  # Flag to specify labels file
    *) echo "Unknown parameter passed: $1"; usage; exit 1 ;;
  esac
  shift
done

# If a labels file is provided, read the values from it
if [ -n "$LABEL_FILE" ]; then
  read_labels_file "$LABEL_FILE"
fi

# Use defaults if CLI arguments not provided
TITLE="${TITLE:-$DEFAULT_TITLE}"
DESCRIPTION="${DESCRIPTION:-$DEFAULT_DESCRIPTION}"
AUTHORS="${AUTHORS:-$DEFAULT_AUTHORS}"
SOURCE="${SOURCE:-$DEFAULT_SOURCE}"
VERSION="${VERSION:-$DEFAULT_VERSION}"
REVISION="${REVISION:-$DEFAULT_REVISION}"
CREATED="${CREATED:-$DEFAULT_CREATED}"
IMAGE="${IMAGE:-$DEFAULT_IMAGE}"
NAMESPACE="${NAMESPACE:-$DEFAULT_NAMESPACE}"

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
prompt SOURCE "Enter the image source repository URL" "$SOURCE"
prompt VERSION "Enter the image version" "$VERSION"
prompt REF_NAME "Enter the image reference name" "$REF_NAME"
prompt NAMESPACE "Enter the Docker image namespace" "$NAMESPACE"

# If ref.name (tag) is not specified, fall back to version for ref.name
if [ -z "$REF_NAME" ]; then
  REF_NAME="$VERSION"
fi

# Format image name as namespace/image:ref-name
FULL_IMAGE="$NAMESPACE/$IMAGE:$REF_NAME"

# Conditionally show Dockerfile labels if the flag is provided
if [ "$SHOW_LABELS" = true ]; then
  cat <<EOF

# Dockerfile labels
LABEL org.opencontainers.image.created="$CREATED"
LABEL org.opencontainers.image.authors="$AUTHORS"
LABEL org.opencontainers.image.source="$SOURCE"
LABEL org.opencontainers.image.version="$VERSION"
LABEL org.opencontainers.image.revision="$REVISION"
LABEL org.opencontainers.image.ref.name="$REF_NAME"
LABEL org.opencontainers.image.title="$TITLE"
LABEL org.opencontainers.image.description="$DESCRIPTION"

EOF
fi

# Build the Docker build command as a single line, ensuring all values are properly quoted
DOCKER_CMD="docker build -t \"$FULL_IMAGE\" . --label \"org.opencontainers.image.created=$CREATED\" --label \"org.opencontainers.image.authors=$AUTHORS\" --label \"org.opencontainers.image.source=$SOURCE\" --label \"org.opencontainers.image.version=$VERSION\" --label \"org.opencontainers.image.revision=$REVISION\" --label \"org.opencontainers.image.ref.name=$REF_NAME\" --label \"org.opencontainers.image.title=$TITLE\" --label \"org.opencontainers.image.description=$DESCRIPTION\" --attest type=sbom,generator=docker/scout-sbom-indexer:latest --push"

# Check if dry run flag is set
if [ "$DRY_RUN" = true ]; then
  echo "Dry run: Docker build command would be:"
  echo "$DOCKER_CMD"
else
  echo "Running Docker build command..."
  eval "$DOCKER_CMD"
fi
