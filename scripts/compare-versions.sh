#!/bin/bash

# A script to compare versions between different Git references (e.g., a pull request and its base branch).

# --- Configuration Variables ---
# Unique directory names to avoid conflicts.
CURRENT_VERSION_REPO_DIR=".current-version-repo-7602f6c0"
PREVIOUS_VERSION_REPO_DIR=".previous-version-repo-7602f6c0"

# Unique temporary file names for version strings.
CURRENT_VERSION_FILE=".current-version-7602f6c0.txt"
PREVIOUS_VERSION_FILE=".previous-version-7602f6c0.txt"

# --- Functions ---

# is_pr checks if the provided event name corresponds to a pull request.
# Returns:
#   0 if the event is a pull request.
#   1 otherwise.
is_pr() {
  local event_name="$1"
  case "$event_name" in
    "pull_request" | "pull_request_target")
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

# --- Main Logic ---

# Check if the correct number of arguments is provided.
if [ "$#" -ne 6 ]; then
  echo "Usage: $0 <repo_clone_url> <event_name> <head_ref> <base_ref> <ref_name> <version_extractor_path>"
  exit 1
fi

# Assign arguments to meaningful variables.
repo_clone_url="$1"
event_name="$2"
head_ref="$3"
base_ref="$4"
ref_name="$5"
version_extractor="$6"

# Create a temporary directory for the current version.
echo "Setting up current version repository..."
chmod u+x "$version_extractor"
git clone --quiet "$repo_clone_url" "$CURRENT_VERSION_REPO_DIR" || exit 1
cp "$version_extractor" "$CURRENT_VERSION_REPO_DIR"

# Create a temporary directory for the previous version.
cp -r "$CURRENT_VERSION_REPO_DIR" "$PREVIOUS_VERSION_REPO_DIR"
cp "$version_extractor" "$PREVIOUS_VERSION_REPO_DIR"

# Get the version for the current branch/ref.
(
  cd "$CURRENT_VERSION_REPO_DIR" || exit 1

  if is_pr "$event_name"; then
    echo "Event is a pull request. Checking out head reference: $head_ref"
    git checkout "$head_ref" || exit 1
  else
    echo "Event is not a pull request. Checking out reference: $ref_name"
    git checkout "$ref_name" || exit 1
  fi

  # Execute the version extractor and save the output.
  "./$(basename "$version_extractor")" > "../$CURRENT_VERSION_FILE" || exit 1
  echo "Current version: $(cat "../$CURRENT_VERSION_FILE")"
)

# Get the version for the previous branch/ref.
echo "Setting up previous version repository..."
(
  cd "$PREVIOUS_VERSION_REPO_DIR" || exit 1

  if is_pr "$event_name"; then
    git checkout "$base_ref" || exit 1
    echo "Event is a pull request. Checking out base reference: $base_ref"
  else
    git checkout "$ref_name" || exit 1
    echo "Event is not a pull request. Checking out reference: $ref_name"
    # Reset to the previous commit to simulate a previous state, as per the original logic.
    echo "Current commit: $(git log -1 --oneline)"
    echo "Resetting to the previous commit..."
    git reset --hard HEAD~1 || exit 1
    echo "Current commit: $(git log -1 --oneline)"
  fi

  # Execute the version extractor and save the output.
  "./$(basename "$version_extractor")" > "../$PREVIOUS_VERSION_FILE" || exit 1
  echo "Previous version: $(cat "../$PREVIOUS_VERSION_FILE")"
)

echo "Script finished successfully."