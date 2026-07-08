# Changelog

## 1.2.0

- Skills now reference bundled scripts with the documented `${CLAUDE_SKILL_DIR}` substitution instead of a `<skill-path>` placeholder, so script paths resolve reliably wherever the plugin is installed.
- Hook commands quote `${CLAUDE_PLUGIN_ROOT}` per Claude Code plugin guidelines.
- Manifest: added `$schema` and `repository` fields.

## 1.1.2 and earlier

- PNG-to-SVG conversion (`ss-png-to-svg`), platform-aware resizing with 60+ presets (`ss-image-resize`), lossless format conversion (`ss-format-convert`), and PostToolUse validation hooks.
