#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
UPSTREAM_REMOTE="upstream"
UPSTREAM_URL="https://github.com/anthropics/claude-plugins-official.git"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CUSTOM_FILE="${SCRIPT_DIR}/custom-plugins.json"
EXCLUDE_FILE="${SCRIPT_DIR}/exclude-plugins.txt"
MARKETPLACE_FILE="${REPO_ROOT}/.claude-plugin/marketplace.json"

cd "$REPO_ROOT"

# Ensure upstream remote exists
if ! git remote get-url "$UPSTREAM_REMOTE" &>/dev/null; then
  git remote add "$UPSTREAM_REMOTE" "$UPSTREAM_URL"
fi

# Fetch latest upstream
echo "Fetching upstream..."
git fetch "$UPSTREAM_REMOTE"

# Get upstream's marketplace.json into a temp file
echo "Reading upstream marketplace.json..."
git show "${UPSTREAM_REMOTE}/main:.claude-plugin/marketplace.json" > /tmp/upstream-marketplace.json

# Build exclude list from file (skip comments and blank lines)
EXCLUDE_JSON="[]"
if [[ -f "$EXCLUDE_FILE" ]]; then
  names=$(grep -v '^#' "$EXCLUDE_FILE" | grep -v '^\s*$' || true)
  if [[ -n "$names" ]]; then
    EXCLUDE_JSON=$(echo "$names" | jq -R . | jq -s .)
  fi
fi

# Apply customizations with jq:
# 1. Override name and owner from custom-plugins.json metadata
# 2. Remove excluded plugins
# 3. Append custom plugins (deduplicating by name)
echo "Applying customizations..."
jq -s --argjson excluded "$EXCLUDE_JSON" '
  .[0] as $upstream |
  .[1] as $custom |
  ($custom.plugins | map(.name)) as $custom_names |
  $upstream
  | .name = $custom.metadata.name
  | .owner = $custom.metadata.owner
  | .plugins = (
      $upstream.plugins
      | map(select(
          (.name as $n | $custom_names | index($n) | not) and
          (.name as $n | $excluded | index($n) | not)
        ))
    ) + $custom.plugins
' /tmp/upstream-marketplace.json "$CUSTOM_FILE" > /tmp/merged-marketplace.json

# Replace marketplace.json
cp /tmp/merged-marketplace.json "$MARKETPLACE_FILE"

# Clean up
rm -f /tmp/upstream-marketplace.json /tmp/merged-marketplace.json

echo "Sync complete. Changes:"
git diff --stat
