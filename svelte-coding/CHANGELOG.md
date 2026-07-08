# Changelog

## 1.1.0

- Skill now references the bundled detection script with the documented `${CLAUDE_SKILL_DIR}` substitution instead of a `<skill-path>` placeholder, so the script path resolves reliably wherever the plugin is installed.
- Manifest: added `$schema` and `repository` fields.

## 1.0.0

- Initial release with the `ss-shadcn-svelte` skill: SvelteKit + shadcn-svelte project detection and component documentation guidance.
