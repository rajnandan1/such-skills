#!/usr/bin/env sh
# Statusline segment: prints a [NO SLOP] badge while always-on mode is active.
# Active = the opt-out file does not exist (mirrors hooks/always-on.sh).
# Call this from the statusLine command in settings.json, e.g.:
#   noslop=$(sh "/path/to/no-slop/hooks/no-slop-statusline.sh" 2>/dev/null)
# Prints nothing (exit 0) when opted out, so composing scripts can test -n.

claude_dir="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
[ -f "$claude_dir/.no-slop-off" ] && exit 0

# 179 = warm amber, matching the plugin's accent color.
printf '\033[38;5;179m[NO SLOP]\033[0m'
