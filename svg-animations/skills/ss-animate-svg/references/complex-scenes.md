# Complex scenes — layered, choreographed compositions

For multi-element pieces: animated hero art, layered illustrations, particle fields, parallax
backgrounds, scenes with a build-in sequence. The failure mode this prevents: flat spaghetti markup
with uncoordinated timings that reads as noise. Everything in SKILL.md still applies; this adds the
composition method.

## Method — in this order

1. **Storyboard before markup.** Write the timing plan as a table first (see the example's below).
   Two phases: a **build-in** (each layer enters once, total under ~2.5s, `animation-fill-mode: both`)
   and an **ambient loop** (infinite, subtle). Nothing animates without a row in the table.
2. **Scaffold the layers.** One named `<g>` per depth layer, back to front — document order is
   z-order. Anything that should emerge "from behind" (a horizon, a doorway) is simply drawn
   *before* its occluder.
3. **Build the static scene fully and render it.** Composition problems are cheap to fix before
   any animation exists.
4. **Animate one layer at a time**, re-rendering as you go — never all layers in one pass.
5. **Verify motion with two screenshots a few seconds apart** — loops actually running, parallax
   layers moving at different rates, no element orbiting off-center.

## Composition techniques

**Animate groups, not leaves.** Nest `<g>` elements to compose independent motions — each group
carries exactly one transform animation, so they never fight: outer group = entry (runs once),
middle group = ambient bob/sway (slow loop), innermost element = fast detail (flicker, blink).

**Repetition via `<defs>` + `<use>`,** varied per instance with a custom property:

```xml
<use class="star" style="--i:3" href="#star" x="132" y="38"/>
```
```css
.star { animation: twinkle 3s ease-in-out calc(var(--i) * -0.4s) infinite; }
```

Negative delays start each copy mid-cycle: one keyframe rule, every instance desynchronized.

**Seamless parallax drift.** Place copies every `P` units (one more copy than fits the viewBox),
animate `translateX(0 → -P)` linear infinite; the wrap lands exactly on the next copy's position.
Depth = speed + opacity: far layers drift slower and fainter.

**Organic desync.** Give concurrent ambient loops durations that don't share a small common
multiple (3s, 4s, 7s — not 2s, 4s, 8s) so the scene never visibly "resets".

**Performance budget.** Every infinite loop should animate only `transform`/`opacity`
(compositor-friendly). Allow at most one or two repaint-class animations (gradient stops, `d`
morphs, filter-adjacent) per scene, and reuse a single `<filter>` definition if any.

## Worked example — verified in Chromium

Night-launch scene, ~25 elements, 9 concurrent animations: staged build-in (stars → clouds →
rocket rises from behind the horizon), then ambient loops. Exercises every technique above.

Storyboard:

| Element | Animation | Start | Duration | Loop |
|---|---|---|---|---|
| stars group | fade in | 0s | 1s | once |
| each star | twinkle | −i×0.4s | 3s | ∞ |
| clouds group | fade in | 0.3s | 1s | once |
| cloud layers | parallax drift | 0s | 60s / 35s | ∞ |
| rocket | rise from horizon | 0.8s | 1.4s | once |
| rocket | bob | 2.2s | 4s | ∞ |
| flame | flicker | 0s | 0.16s | ∞ alternate |

```xml
<svg viewBox="0 0 240 160" width="480" height="320" role="img" xmlns="http://www.w3.org/2000/svg">
  <title>Rocket launching into a starry night sky</title>
  <style>
    /* Build-in phase: groups fade/rise into place, then ambient loops take over. */
    .fade-in { opacity: 1; animation: fade 1s ease-out both; }
    .clouds  { animation-delay: 0.3s; }
    @keyframes fade { from { opacity: 0; } }

    .star {
      animation: twinkle 3s ease-in-out calc(var(--i) * -0.4s) infinite;
    }
    @keyframes twinkle { 0%,100% { opacity: 1; } 50% { opacity: 0.25; } }

    .drift-far  { animation: drift 60s linear infinite; }
    .drift-near { animation: drift 35s linear infinite; }
    @keyframes drift { to { transform: translateX(-120px); } }

    .rocket-entry {
      animation: rise 1.4s cubic-bezier(0, 0, 0.3, 1) 0.8s both;
    }
    @keyframes rise { from { transform: translateY(34px); } }

    .rocket-bob { animation: bob 4s ease-in-out 2.2s infinite; }
    @keyframes bob { 0%,100% { transform: translateY(0); } 50% { transform: translateY(-2px); } }

    .flame {
      transform-box: fill-box;
      transform-origin: top center;
      animation: flicker 0.16s ease-in-out infinite alternate;
    }
    @keyframes flicker { from { transform: scaleY(1); opacity: 0.9; } to { transform: scaleY(1.35); opacity: 1; } }

    @media (prefers-reduced-motion: reduce) {
      * { animation: none !important; }
    }
  </style>

  <defs>
    <linearGradient id="sky" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0" stop-color="#0b1026"/>
      <stop offset="1" stop-color="#233a6b"/>
    </linearGradient>
    <radialGradient id="moonglow">
      <stop offset="0.4" stop-color="#f5f0d8" stop-opacity="0.35"/>
      <stop offset="1" stop-color="#f5f0d8" stop-opacity="0"/>
    </radialGradient>
    <circle id="star" r="1.3" fill="#e8ecff"/>
    <g id="cloud" fill="#31437a">
      <ellipse rx="16" ry="5.5"/>
      <ellipse cx="11" cy="-4" rx="10" ry="4.5"/>
      <ellipse cx="-11" cy="-3" rx="9" ry="4"/>
    </g>
  </defs>

  <!-- Layer 1: sky -->
  <rect width="240" height="160" fill="url(#sky)"/>

  <!-- Layer 2: stars (staggered twinkle via per-instance custom property) -->
  <g class="fade-in">
    <use class="star" style="--i:0" href="#star" x="28"  y="22"/>
    <use class="star" style="--i:1" href="#star" x="64"  y="46"/>
    <use class="star" style="--i:2" href="#star" x="96"  y="18"/>
    <use class="star" style="--i:3" href="#star" x="132" y="38"/>
    <use class="star" style="--i:4" href="#star" x="158" y="14"/>
    <use class="star" style="--i:5" href="#star" x="44"  y="70"/>
    <use class="star" style="--i:6" href="#star" x="210" y="64"/>
    <use class="star" style="--i:7" href="#star" x="182" y="88"/>
  </g>

  <!-- Layer 3: moon + glow -->
  <g class="fade-in">
    <circle cx="196" cy="30" r="26" fill="url(#moonglow)"/>
    <circle cx="196" cy="30" r="11" fill="#f5f0d8"/>
  </g>

  <!-- Layer 4: parallax clouds. Copies every 120 units; drift period = 120 -> seamless wrap. -->
  <g class="fade-in clouds">
    <g class="drift-far" opacity="0.45" transform="translate(0 0)">
      <use href="#cloud" x="20"  y="58"/>
      <use href="#cloud" x="140" y="58"/>
      <use href="#cloud" x="260" y="58"/>
    </g>
    <g class="drift-near" opacity="0.8">
      <use href="#cloud" x="80"  y="96"/>
      <use href="#cloud" x="200" y="96"/>
      <use href="#cloud" x="320" y="96"/>
    </g>
  </g>

  <!-- Layer 5: rocket (drawn BEFORE ground so it rises from behind the horizon).
       Nested groups compose animations: entry (once) > bob (loop) > flame flicker (fast loop). -->
  <g class="rocket-entry">
    <g class="rocket-bob">
      <path class="flame" d="M114 128 L120 148 L126 128 Q120 133 114 128 Z" fill="#fb923c"/>
      <path d="M120 78 C126 86 128 100 128 116 L112 116 C112 100 114 86 120 78 Z" fill="#d8dce8"/>
      <path d="M112 108 L103 124 L112 121 Z" fill="#94a3b8"/>
      <path d="M128 108 L137 124 L128 121 Z" fill="#94a3b8"/>
      <path d="M114 116 L112 128 L128 128 L126 116 Z" fill="#b6bdcc"/>
      <circle cx="120" cy="96" r="4.2" fill="#7dd3fc" stroke="#475569" stroke-width="1.2"/>
    </g>
  </g>

  <!-- Layer 6: ground silhouette + pad (topmost = nearest) -->
  <path d="M0 144 L84 144 L90 138 L150 138 L156 144 L240 144 L240 160 L0 160 Z" fill="#080d1c"/>
  <rect x="104" y="134" width="32" height="4" rx="1" fill="#0f172a"/>
</svg>
```
