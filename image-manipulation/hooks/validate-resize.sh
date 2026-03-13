#!/bin/bash
# PostToolUse hook: validates that resize.sh output files have correct dimensions.
# Reads the Bash tool output from stdin JSON, checks if resize.sh was run,
# then verifies each created file with `magick identify`.

set -euo pipefail

INPUT=$(cat)

# Extract the command that was run
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // ""')

# Only validate resize.sh runs
if ! echo "$COMMAND" | grep -q 'resize\.sh'; then
  exit 0
fi

# Extract stdout from the tool output
TOOL_OUTPUT=$(echo "$INPUT" | jq -r '.tool_output.stdout // ""')

# Parse "Created: <path> (WIDTHxHEIGHT)" lines from the output
ERRORS=""
CHECKED=0

while IFS= read -r line; do
  # Match lines like: "  Created: /tmp/resized/og-image.png (2400x1260)"
  if echo "$line" | grep -qE 'Created:.*\([0-9]+x[0-9]+\)'; then
    FILE_PATH=$(echo "$line" | sed -E 's/.*Created: ([^ ]+) .*/\1/')
    EXPECTED=$(echo "$line" | sed -E 's/.*\(([0-9]+x[0-9]+)\).*/\1/')
    EXPECTED_W=$(echo "$EXPECTED" | cut -dx -f1)
    EXPECTED_H=$(echo "$EXPECTED" | cut -dx -f2)

    if [[ ! -f "$FILE_PATH" ]]; then
      ERRORS="${ERRORS}MISSING: ${FILE_PATH} (expected ${EXPECTED})\n"
      continue
    fi

    # Get actual dimensions via magick identify
    ACTUAL=$(magick identify -format "%wx%h" "$FILE_PATH" 2>/dev/null || echo "unknown")

    if [[ "$ACTUAL" == "unknown" ]]; then
      ERRORS="${ERRORS}UNREADABLE: ${FILE_PATH} — could not identify image format\n"
    elif [[ "$ACTUAL" != "${EXPECTED_W}x${EXPECTED_H}" ]]; then
      ERRORS="${ERRORS}MISMATCH: ${FILE_PATH} — expected ${EXPECTED_W}x${EXPECTED_H}, got ${ACTUAL}\n"
    fi

    CHECKED=$((CHECKED + 1))
  fi
done <<< "$TOOL_OUTPUT"

# If no Created lines were found, nothing to validate
if [[ $CHECKED -eq 0 ]]; then
  exit 0
fi

# Report results
if [[ -n "$ERRORS" ]]; then
  printf "Resize validation failed (%d files checked):\n%b" "$CHECKED" "$ERRORS" >&2
  exit 2
fi

# All good — report success as context for Claude
jq -n --arg msg "Resize validation passed: all $CHECKED file(s) have correct dimensions." \
  '{decision: "allow", reason: $msg}'
