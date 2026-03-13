#!/bin/bash
# PostToolUse hook: validates that convert.sh output files exist, are valid images,
# and have preserved their original dimensions.
# Reads the Bash tool output from stdin JSON, checks if convert.sh was run,
# then verifies each converted file with `magick identify`.

set -euo pipefail

INPUT=$(cat)

# Extract the command that was run
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // ""')

# Only validate convert.sh runs
if ! echo "$COMMAND" | grep -q 'convert\.sh'; then
  exit 0
fi

# Extract stdout from the tool output
TOOL_OUTPUT=$(echo "$INPUT" | jq -r '.tool_output.stdout // ""')

# Parse "Converted: <path> (src -> dst, WIDTHxHEIGHT)" lines from the output
ERRORS=""
CHECKED=0

while IFS= read -r line; do
  # Match lines like: "  Converted: ./converted/file.jpg (png -> jpg, 1920x1080)"
  if echo "$line" | grep -qE 'Converted:.*\([a-z]+ -> [a-z]+, [0-9]+x[0-9]+\)'; then
    FILE_PATH=$(echo "$line" | sed -E 's/.*Converted: ([^ ]+) .*/\1/')
    EXPECTED_DIMS=$(echo "$line" | sed -E 's/.*,\s*([0-9]+x[0-9]+)\).*/\1/')

    if [[ ! -f "$FILE_PATH" ]]; then
      ERRORS="${ERRORS}MISSING: ${FILE_PATH}\n"
      continue
    fi

    # Get actual dimensions via magick identify
    ACTUAL=$(magick identify -format "%wx%h" "$FILE_PATH" 2>/dev/null || echo "unknown")

    if [[ "$ACTUAL" == "unknown" ]]; then
      ERRORS="${ERRORS}UNREADABLE: ${FILE_PATH} — could not identify image format\n"
    elif [[ "$ACTUAL" != "$EXPECTED_DIMS" ]]; then
      ERRORS="${ERRORS}DIMENSION_CHANGE: ${FILE_PATH} — expected ${EXPECTED_DIMS}, got ${ACTUAL}\n"
    fi

    CHECKED=$((CHECKED + 1))
  fi
done <<< "$TOOL_OUTPUT"

# If no Converted lines were found, nothing to validate
if [[ $CHECKED -eq 0 ]]; then
  exit 0
fi

# Report results
if [[ -n "$ERRORS" ]]; then
  printf "Conversion validation failed (%d files checked):\n%b" "$CHECKED" "$ERRORS" >&2
  exit 2
fi

# All good — report success as context for Claude
jq -n --arg msg "Conversion validation passed: all $CHECKED file(s) are valid with correct dimensions." \
  '{decision: "allow", reason: $msg}'
