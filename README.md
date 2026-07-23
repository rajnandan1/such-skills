# Such Skills

> A [Claude Code plugin marketplace](https://code.claude.com/docs/en/plugin-marketplaces) with plugins for image manipulation, Svelte development, slop-free writing, and more.

## Installation

### Quick install (npx)

```bash
npx skills add rajnandan1/such-skills/ss-image-manipulation
npx skills add rajnandan1/such-skills/ss-svelte-coding
npx skills add rajnandan1/such-skills/ss-svg-animations
npx skills add rajnandan1/such-skills/ss-no-slop
```

### Claude Code (CLI)

```bash
# Step 1: Add the marketplace
claude plugin marketplace add rajnandan1/such-skills

# Step 2: Install plugins
claude plugin install ss-image-manipulation@such-skills
claude plugin install ss-svelte-coding@such-skills
claude plugin install ss-svg-animations@such-skills
claude plugin install ss-no-slop@such-skills
```

## Update to latest version

```bash
claude plugin marketplace update such-skills
claude plugin update ss-image-manipulation@such-skills
claude plugin update ss-svelte-coding@such-skills
claude plugin update ss-svg-animations@such-skills
claude plugin update ss-no-slop@such-skills
```

## Plugins

| Plugin                                        | Skills | Description                                                                                   |
| --------------------------------------------- | ------ | --------------------------------------------------------------------------------------------- |
| [**ss-image-manipulation**](image-manipulation/) | `ss-png-to-svg`, `ss-image-resize`, `ss-format-convert` | PNG-to-SVG conversion, platform-aware image resizing (60+ presets), lossless format conversion (PNG, JPG, WebP, TIFF, BMP, GIF, HEIC, AVIF), plus PostToolUse hooks that validate every resize and conversion |
| [**ss-svelte-coding**](svelte-coding/) | `ss-shadcn-svelte` | shadcn-svelte component detection and documentation for building accessible UIs in SvelteKit projects |
| [**ss-svg-animations**](svg-animations/) | `ss-animate-svg` | Hand-crafted, dependency-free SVG animation — self-drawing paths, spinners, morphing, motion paths, complex layered scenes with particles and parallax — with the right technique (CSS vs SMIL) for where the SVG will live |
| [**ss-no-slop**](no-slop/) | `ss-remove-slop` | Remove AI slop from prose — voice-preserving draft editing, detect-without-rewriting audits, and zero-tolerance fresh drafting, catching 30+ patterns from binary contrasts and colon reveals to false agency and fake-profound kickers — plus an always-on SessionStart hook that applies the rules to every session automatically |

Once installed, Claude invokes the skills automatically when relevant, or you can call one directly, e.g. `/ss-image-manipulation:ss-image-resize`. Each plugin's README documents its skills, options, and example prompts; changes are tracked in each plugin's `CHANGELOG.md`.

## Repository structure

```text
such-skills/
├── .claude-plugin/
│   └── marketplace.json        # Marketplace catalog
├── image-manipulation/         # ss-image-manipulation plugin
│   ├── .claude-plugin/plugin.json
│   ├── skills/                 # ss-png-to-svg, ss-image-resize, ss-format-convert
│   └── hooks/                  # Output-validation hooks
├── svelte-coding/              # ss-svelte-coding plugin
│   ├── .claude-plugin/plugin.json
│   └── skills/                 # ss-shadcn-svelte
├── svg-animations/             # ss-svg-animations plugin
│   ├── .claude-plugin/plugin.json
│   └── skills/                 # ss-animate-svg (+ bundled references)
└── no-slop/                    # ss-no-slop plugin
    ├── .claude-plugin/plugin.json
    ├── skills/                 # ss-remove-slop (+ bundled references)
    └── hooks/                  # Always-on SessionStart injection
```

## Development

Test a plugin locally without installing it:

```bash
claude --plugin-dir ./image-manipulation
```

Validate the marketplace and plugins before pushing:

```bash
claude plugin validate . --strict
claude plugin validate ./image-manipulation --strict
claude plugin validate ./svelte-coding --strict
claude plugin validate ./svg-animations --strict
claude plugin validate ./no-slop --strict
```

Plugins use explicit semantic versions, so bump `version` in the plugin's `.claude-plugin/plugin.json` (and note the change in its `CHANGELOG.md`) whenever you want installed users to receive an update.

## About

Built by [Raj Nandan Sharma](https://rajnandan.com).

## License

MIT
