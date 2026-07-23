# No Slop Plugin for Claude Code

> Remove AI slop from prose: edit drafts into sharper, more human writing while preserving the writer's voice, detect and name AI patterns without rewriting, or draft new prose with no AI tells.

## Installation

### Quick install (npx)

```bash
npx skills add rajnandan1/such-skills/ss-no-slop
```

### Claude Code (CLI)

```bash
claude plugin marketplace add rajnandan1/such-skills
claude plugin install ss-no-slop@such-skills
```

## Skills

### ss-remove-slop

One skill, three jobs:

1. **Edit (default).** Makes the minimum effective edit: fixes slop, errors, and unclear passages while preserving the writer's vocabulary, cadence, edge, and structure. Returns the edited draft plus a What changed section, self-checked against a pass/fail eval and a 5-dimension score.
2. **Detect.** Audits a text without rewriting it. Names each slop pattern found, quotes the line, and gives the fix in a few words. Evidence the user can check, not a guess about AI authorship.
3. **Draft.** Applies the full ruleset at zero tolerance when Claude writes fresh prose: no adverbs, no em dashes, no filler, no formulaic structures.

What it catches (30+ patterns):

| Pattern | Smells like |
|---------|-------------|
| Binary contrasts | "It's not X. It's Y." |
| Throat-clearing openers | "Here's the thing..." |
| Faux-insight setups | "What nobody tells you..." |
| Colon reveals | "The best part: it learns." |
| Superficial analysis | "...highlighting the team's commitment" |
| Importance puffery | "marks a pivotal moment" |
| Weasel attribution | "experts agree," "studies show" |
| Fake-strong verbs | "serves as a centralized hub" |
| False agency | "the decision emerges," "the culture shifts" |
| Narrator-from-a-distance | "Nobody designed this." |
| Synonym cycling | the agent, then the assistant, then the tool |
| Negative listing | "Not a X. Not a Y. A Z." |
| Dramatic fragmentation | "That's it. That's the whole thing." |
| Rhetorical setups | "What if I told you..." |
| Fake-profound kickers | the mic-drop closing metaphor |
| Summary-recap endings | "In conclusion..." |
| Vague declaratives | "The implications are significant." |
| Business jargon | "lean into," "double down," "deep dive" |
| Rhythm slop | metronomic sentences, em-dash clusters, staccato fragments |
| Formatting slop | emoji headings, decorative bold, bullets-as-prose |

It also enforces the fundamentals: active voice with human subjects, concrete specifics over abstraction, the reader in the room, varied rhythm, and trust in the reader.

Bundled references (loaded only when needed):

| File | Contents |
|------|----------|
| `references/phrases.md` | Banned words, adverbs, empty phrases, throat-clearing openers, emphasis crutches, business jargon, meta-commentary, vague declaratives |
| `references/structures.md` | Binary contrasts, negative listing, false agency, passive voice, colon reveals, puffery, kickers, endings, rhythm and formatting slop |
| `references/examples.md` | Before/after transformations for the major pattern families |
| `references/eval.md` | Pass/fail self-checks, a line-level sweep, and a 5-dimension scoring rubric the skill runs on its own output |

## Always-on mode

The plugin ships a `SessionStart` hook that injects the ruleset into every session, with zero setup. You install the plugin and every response Claude writes is slop-free: explanations, docs, commit messages, READMEs, UI copy. You'll see `Loading no-slop mode...` in the status line at session start.

The hook scopes itself: the strict Draft rules apply to prose Claude writes; the Edit and Detect jobs only run when you share a draft or ask for an audit, so it never nags you to paste text.

Turning it off:

- Session: say `stop slop mode`.
- Permanent: `touch ~/.claude/.no-slop-off` (respects `$CLAUDE_CONFIG_DIR`). Delete the file to turn it back on.

The skill still works normally when always-on is off; only the automatic per-session injection stops.

## Statusline badge

The plugin ships `hooks/no-slop-statusline.sh`, which prints an amber `[NO SLOP]` badge while always-on mode is active and nothing when you've opted out. Claude Code has a single user-owned `statusLine` setting, so wire it in yourself (or ask Claude to):

```bash
# ~/.claude/settings.json
{ "statusLine": { "type": "command", "command": "bash ~/.claude/statusline-command.sh" } }
```

```bash
# ~/.claude/statusline-command.sh
#!/bin/bash
cat >/dev/null   # drain the stdin JSON Claude Code pipes in
noslop=$(sh "$HOME/.claude/plugins/marketplaces/such-skills/no-slop/hooks/no-slop-statusline.sh" 2>/dev/null)
printf '%s' "$noslop"
```

If you already have a statusline command, append the badge to its output the same way. The badge follows the `~/.claude/.no-slop-off` flag, so it always matches what the SessionStart hook will do next session.

## Examples

Ask Claude naturally:

```
edit this draft, it sounds too AI
```
```
is this AI slop?

[the text]
```
```
make this launch post sharper without losing my voice
```
```
write the announcement, no AI tells
```
```
audit this README for slop but don't rewrite it
```

## Credits

This plugin merges two excellent MIT-licensed skills into one:

- [no-ai-slop](https://github.com/petergyang/no-ai-slop) by [Peter Yang](https://behindthecraft.com): the voice-preserving editor, minimum-effective-edit discipline, detect mode, and self-eval.
- [stop-slop](https://github.com/hvpandya/stop-slop) by [Hardik Pandya](https://hvpandya.com): the phrase and structure catalogs, false-agency and narrator-from-a-distance patterns, quick checks, and scoring rubric.

## License

MIT
