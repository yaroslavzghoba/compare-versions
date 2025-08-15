#!/bin/bash

# A script to compare versions between different Git references (e.g., a pull request and its base branch).

# --- Configuration Variables ---
# Unique directory names to avoid conflicts.
CURRENT_VERSION_REPO_DIR=".current-version-repo"
PREVIOUS_VERSION_REPO_DIR=".previous-version-repo"

# Unique temporary file names for version strings.
CURRENT_VERSION_FILE=".current-version.txt"
PREVIOUS_VERSION_FILE=".previous-version.txt"

# --- Functions ---

# Check if the provided event name corresponds to a pull request.
# Returns:
#   0 if the event is a pull request.
#   1 if the event is not a pull request.
#   2 if the function is called without an argument.
is_pr() {
  # Check if exactly one argument was provided to the function.
  if [ "$#" -ne 1 ]; then
      echo "Error: The function '$0' requires exactly one argument." >&2
      return 2
  fi

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

# Compare two version strings.
# Returns:
#   0 if the current version is greater than the previous version.
#   1 if the versions are equal or the current version is not greater than the previous version.
#   2 if the function is called with an incorrect number of arguments.
compare_versions() {
    # Check if exactly two arguments were provided to the function.
    if [ "$#" -ne 2 ]; then
        echo "Error: The function '$0' requires exactly two arguments." >&2
        return 2  # Return a unique status for argument error.
    fi

    local current_version="$1"
    local previous_version="$2"

    # Use sort -V for robust version comparison.
    # The 'head -n 1' command gets the first line (the lower version).
    if [ "$current_version" = "$previous_version" ]; then
        echo "Error: The current version ($current_version) is equal to the previous version ($previous_version)." >&2
        return 1  # Failure
    elif [ "$current_version" = "$(echo -e "$current_version\n$previous_version" | sort -V | head -n 1)" ]; then
        echo "Error: The current version ($current_version) is not greater than the previous version ($previous_version)." >&2
        return 1  # Failure
    else
        echo "Success: The current version ($current_version) is greater than the previous version ($previous_version)."
        return 0  # Success
    fi
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
echo "Cloning the Git repository..."
chmod u+x "$version_extractor"
git clone --quiet "$repo_clone_url" "$CURRENT_VERSION_REPO_DIR" || exit 1
echo "Copying version extractor..."
cp "$version_extractor" "$CURRENT_VERSION_REPO_DIR"

# Create a temporary directory for the previous version.
cp -r "$CURRENT_VERSION_REPO_DIR" "$PREVIOUS_VERSION_REPO_DIR"
cp "$version_extractor" "$PREVIOUS_VERSION_REPO_DIR"

# Get the version for the current branch/ref.
(
  echo "Setting up current version repository..."
  cd "$CURRENT_VERSION_REPO_DIR" || exit 1
  echo "Current working directory: $(pwd)"

  if is_pr "$event_name"; then
    echo "  Event is a pull request. Switching to the source branch: $head_ref."
    git checkout "$head_ref" || exit 1
  else
    echo "  Event is not a pull request. Switching to the source branch: $ref_name."
    git checkout "$ref_name" || exit 1
  fi

  # Execute the version extractor and save the output.
  "./$(basename "$version_extractor")" > "../$CURRENT_VERSION_FILE" || exit 1
  echo "  Current version extracted: $(cat "../$CURRENT_VERSION_FILE").\n"
)

# Extract the previous version
(
  echo "Setting up previous version repository..."
  cd "$PREVIOUS_VERSION_REPO_DIR" || exit 1
  echo "Current working directory: $(pwd)"

  if is_pr "$event_name"; then
    echo "  Event is a pull request. Switching to the target branch: $base_ref."
    git checkout "$base_ref" || exit 1
  else
    echo "  Event is not a pull request. Switching to the source branch: $ref_name."
    git checkout "$ref_name" || exit 1
    # Reset to the previous commit to simulate a previous state, as per the original logic.
    echo "  Current commit: $(git log -1 --oneline)"
    echo "  Resetting to the previous commit..."
    git reset -q --hard HEAD~1 || exit 1
    echo "  Current commit: $(git log -1 --oneline)"
  fi

  # Execute the version extractor and save the output.
  "./$(basename "$version_extractor")" > "../$PREVIOUS_VERSION_FILE" || exit 1
  echo "  Previous version extracted: $(cat "../$PREVIOUS_VERSION_FILE").\n"

  cd ../scripts || exit 1
  compare_versions "$(cat "../$CURRENT_VERSION_FILE")" "$(cat "../$PREVIOUS_VERSION_FILE")" || exit 1
)