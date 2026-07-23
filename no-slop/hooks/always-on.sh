#!/usr/bin/env sh
# SessionStart hook: injects the ss-remove-slop ruleset into every session so
# all prose Claude writes is slop-free without the user doing anything.
# Opt out by creating $CLAUDE_CONFIG_DIR/.no-slop-off (default ~/.claude).
# Never blocks session start: any failure exits 0.
#
# Pure POSIX sh so it runs anywhere Claude Code runs a command hook (sh on
# macOS/Linux, Git Bash on Windows) without depending on a Node install being
# on PATH.

claude_dir="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
off_path="$claude_dir/.no-slop-off"

# Always-on by default; only an explicit opt-out file silences it.
[ -f "$off_path" ] && exit 0

# $0 is the absolute script path substituted into hooks.json by Claude Code,
# so resolve SKILL.md relative to it instead of trusting an exported env var.
script_dir=$(dirname -- "$0")
skill_path="$script_dir/../skills/ss-remove-slop/SKILL.md"
[ -f "$skill_path" ] || exit 0

# Strip a leading YAML frontmatter block (--- ... --- at the very top of file).
body=$(awk '
  NR == 1 && $0 ~ /^---[[:space:]]*$/ { in_fm = 1; next }
  in_fm && $0 ~ /^---[[:space:]]*$/   { in_fm = 0; next }
  !in_fm                              { print }
' "$skill_path") || exit 0

printf 'NO SLOP MODE ACTIVE (always-on). Apply the Draft job below to all prose you write this session: explanations, summaries, docs, READMEs, commit messages, UI copy. The Edit and Detect jobs and the "What to ask for" questions apply only when the user shares a draft or asks for an audit; never ask for a draft otherwise. Reference files live next to the skill at %s. "stop slop mode" turns this off for the session; create %s to turn always-on off for good.\n\n%s\n' \
  "$skill_path" "$off_path" "$body"
