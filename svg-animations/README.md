# SVG Animations Plugin for Claude Code

> Hand-crafted, dependency-free SVG animation: self-drawing paths, loading spinners, morphing shapes, motion paths, animated gradients, pulses, and waves — with the right technique (CSS vs SMIL) chosen for where the SVG will live.

## Installation

### Quick install (npx)

```bash
npx skills add rajnandan1/such-skills/ss-svg-animations
```

### Claude Code (CLI)

```bash
claude plugin marketplace add rajnandan1/such-skills
claude plugin install ss-svg-animations@such-skills
```

## Skills

### ss-animate-svg

Guides Claude through building animated SVGs that are correct by construction:

1. **Picks the technique for the delivery context** — inline HTML, `<img>`/GitHub README/favicon, or interactive — since that decides whether CSS, SMIL, or JS can even run.
2. **Uses `pathLength="100"`** for stroke-drawing effects, so dash animations never depend on guessed or measured path lengths.
3. **Authors the resting state as the final state**, so reduced-motion users (and renderers with animation off) see the finished artwork instead of a blank.
4. **Applies the fiddly platform rules**: `transform-box: fill-box` for CSS transforms, explicit SMIL rotation centers, `fill="freeze"`, seamless-loop values, compositor-friendly properties.
5. **Verifies the result** in a real browser, including a `prefers-reduced-motion` check.

Bundled references (loaded only when needed):

| File | Contents |
|------|----------|
| `references/paths-and-shapes.md` | Path command syntax, primitives, transforms, gradients, masks vs clips, filters, text-on-path |
| `references/smil.md` | `<animate>`, `<animateTransform>`, `<animateMotion>`, timing chains, easing with `keySplines`, morphing, SMIL caveats |
| `references/recipes.md` | Complete copy-adapt recipes: spinner, orbiting dots, self-drawing icons, hamburger→X, gradient shift, skeleton shimmer, pulse, wave, blinking cursor |
| `references/complex-scenes.md` | Layered, choreographed compositions: storyboard-first method, group nesting, `<use>` particle fields, seamless parallax, perf budget — with a fully verified night-launch scene as the worked example |

## Examples

Ask Claude naturally:

```
make me an animated checkmark SVG for my README
```
```
create a loading spinner as a single SVG file, no JS
```
```
animate this logo so it draws itself, then the fill fades in
```
```
I need a skeleton loader shimmer as an SVG background image
```
```
morph this triangle into a hexagon on hover
```

## License

MIT
