# Changelog

## 1.0.0

- Initial release with the `ss-remove-slop` skill, merging Peter Yang's `no-ai-slop` and Hardik Pandya's `stop-slop` (both MIT) into one skill with three jobs: voice-preserving minimum-effective-edit, detect-without-rewriting audits, and zero-tolerance fresh drafting. Bundles merged reference catalogs (phrases, structures, before/after examples) and a self-check eval with a line-level sweep and 5-dimension scoring rubric.
- Always-on `SessionStart` hook that injects the ruleset into every session with zero setup, scoped so Draft rules govern Claude's own prose while Edit/Detect wait for a shared draft. Opt out per session with "stop slop mode" or permanently via `~/.claude/.no-slop-off`.
- Statusline script (`hooks/no-slop-statusline.sh`) that prints an amber `[NO SLOP]` badge while always-on mode is active, for composing into a user's `statusLine` command.
