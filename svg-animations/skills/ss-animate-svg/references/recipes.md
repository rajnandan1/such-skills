# Recipes — complete, adaptable animated SVGs

Every recipe is a self-contained `.svg` file: copy it, swap the palette and `viewBox`, keep the technique. All follow the house rules — `pathLength="100"`, resting state = final state, explicit rotation centers, `fill="freeze"`/`both` where the end state must hold.

## Loading spinner (rotating arc) — SMIL, `<img>`-safe

```xml
<svg viewBox="0 0 50 50" width="50" height="50" role="img" xmlns="http://www.w3.org/2000/svg">
  <title>Loading</title>
  <circle cx="25" cy="25" r="20" fill="none" stroke="#1a1a1a" stroke-width="4"
          stroke-linecap="round" pathLength="100" stroke-dasharray="75 25">
    <animateTransform attributeName="transform" type="rotate"
                      from="0 25 25" to="360 25 25" dur="0.8s" repeatCount="indefinite"/>
  </circle>
</svg>
```

The arc is just a dash covering 75 of the circle's 100 normalized units. For a "comet" that grows and shrinks while spinning, additionally animate `stroke-dashoffset` over `values="0;-100"` with a longer `dur` than the rotation.

> Closed-shape seam: a fully-drawn closed shape with an exact-length dash (`stroke-dasharray: 100` at offset 0) renders a visible gap at the path start (verified in Chromium). Always over-length the dash on closed shapes: `stroke-dasharray="101"`.

## Orbiting-dots loader — negative `begin` spaces the dots

```xml
<svg viewBox="0 0 50 50" width="50" height="50" role="img" xmlns="http://www.w3.org/2000/svg">
  <title>Loading</title>
  <path id="orbit" d="M 25,7 a 18,18 0 1,1 -0.01,0 z" fill="none"/>
  <circle r="4" fill="#e63946">
    <animateMotion dur="1.2s" begin="0s" repeatCount="indefinite"><mpath href="#orbit"/></animateMotion>
  </circle>
  <circle r="4" fill="#e63946" opacity="0.6">
    <animateMotion dur="1.2s" begin="-0.4s" repeatCount="indefinite"><mpath href="#orbit"/></animateMotion>
  </circle>
  <circle r="4" fill="#e63946" opacity="0.3">
    <animateMotion dur="1.2s" begin="-0.8s" repeatCount="indefinite"><mpath href="#orbit"/></animateMotion>
  </circle>
</svg>
```

Negative `begin` starts an animation mid-flight, so identical loops distribute evenly from the first frame — no per-element keyframes.

## Self-drawing icon / signature — CSS, staggered

The canonical pattern is in SKILL.md (checkmark badge). Generalize by giving every stroke `class="draw" pathLength="100"` and stepping `animation-delay` (`0s, .4s, .8s…`) with `animation-fill-mode: both`. Order the paths in drawing order — the eye follows the pen.

## Hamburger → X — interactive, inline-only

```xml
<svg viewBox="0 0 24 24" width="24" height="24" id="menu" xmlns="http://www.w3.org/2000/svg">
  <path d="M 3,6 L 21,6" stroke="#1a1a1a" stroke-width="2" stroke-linecap="round">
    <animate attributeName="d" to="M 5,5 L 19,19" dur="0.3s" begin="menu.click"
             fill="freeze" restart="whenNotActive"/>
  </path>
  <path d="M 3,12 L 21,12" stroke="#1a1a1a" stroke-width="2" stroke-linecap="round">
    <animate attributeName="opacity" to="0" dur="0.1s" begin="menu.click"
             fill="freeze" restart="whenNotActive"/>
  </path>
  <path d="M 3,18 L 21,18" stroke="#1a1a1a" stroke-width="2" stroke-linecap="round">
    <animate attributeName="d" to="M 5,19 L 19,5" dur="0.3s" begin="menu.click"
             fill="freeze" restart="whenNotActive"/>
  </path>
</svg>
```

`begin="click"` needs a live DOM (inline SVG), and this version is one-way. A real open/close toggle wants a CSS class flipped by the page's JS, animating the same `d` values via `transition: d 0.3s`.

## Gradient color shift

```xml
<svg viewBox="0 0 200 100" width="200" height="100" aria-hidden="true" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <linearGradient id="shift" x1="0" y1="0" x2="1" y2="0">
      <stop offset="0%">
        <animate attributeName="stop-color" values="#e63946;#457b9d;#2a9d8f;#e63946"
                 dur="6s" repeatCount="indefinite"/>
      </stop>
      <stop offset="100%">
        <animate attributeName="stop-color" values="#457b9d;#2a9d8f;#e63946;#457b9d"
                 dur="6s" repeatCount="indefinite"/>
      </stop>
    </linearGradient>
  </defs>
  <rect width="200" height="100" rx="8" fill="url(#shift)"/>
</svg>
```

First value = last value keeps the loop seamless. Gradient animation repaints — fine for one hero element, not for twenty.

## Skeleton shimmer — animate the gradient, not the shape

```xml
<svg viewBox="0 0 200 48" width="200" height="48" aria-hidden="true" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <linearGradient id="sheen" x1="0" y1="0" x2="1" y2="0">
      <stop offset="0"   stop-color="#e5e7eb"/>
      <stop offset="0.5" stop-color="#f5f6f8"/>
      <stop offset="1"   stop-color="#e5e7eb"/>
      <animateTransform attributeName="gradientTransform" type="translate"
                        from="-1 0" to="1 0" dur="1.4s" repeatCount="indefinite"/>
    </linearGradient>
  </defs>
  <rect x="0"  y="6"  width="140" height="10" rx="5" fill="url(#sheen)"/>
  <rect x="0"  y="24" width="200" height="10" rx="5" fill="url(#sheen)"/>
</svg>
```

Translating the gradient (in objectBoundingBox units, so −1→1 sweeps once across) animates every rect that uses it — one animation, n placeholders.

## Pulse / breathing glow — CSS, shows `transform-box`

```xml
<svg viewBox="0 0 100 100" width="100" height="100" aria-hidden="true" xmlns="http://www.w3.org/2000/svg">
  <style>
    .pulse {
      transform-box: fill-box;          /* without this, scale is about the viewBox origin */
      transform-origin: center;
      animation: pulse 2s cubic-bezier(0.4, 0, 0.6, 1) infinite;
    }
    @keyframes pulse {
      0%, 100% { transform: scale(1);    opacity: 1;   }
      50%      { transform: scale(1.15); opacity: 0.6; }
    }
    @media (prefers-reduced-motion: reduce) { .pulse { animation: none; } }
  </style>
  <circle class="pulse" cx="50" cy="50" r="24" fill="#e63946"/>
</svg>
```

`transform` + `opacity` only — this one composites on the GPU and costs nothing.

## Wave / liquid fill — `d` morph

```xml
<svg viewBox="0 0 100 100" width="100" height="100" aria-hidden="true" xmlns="http://www.w3.org/2000/svg">
  <path fill="#457b9d" opacity="0.7">
    <animate attributeName="d" dur="5s" repeatCount="indefinite"
      calcMode="spline" keySplines="0.4 0 0.6 1; 0.4 0 0.6 1"
      values="M 0,42 C 30,36 70,48 100,42 L 100,100 L 0,100 Z;
              M 0,42 C 30,50 70,34 100,42 L 100,100 L 0,100 Z;
              M 0,42 C 30,36 70,48 100,42 L 100,100 L 0,100 Z"/>
  </path>
</svg>
```

All three `values` share the exact command sequence (`M C L L Z`) — the interpolation requirement. Layer a second wave (different `dur`, lower opacity) for depth.

## Blinking cursor — `calcMode="discrete"`

```xml
<rect x="0" y="4" width="2" height="16" fill="#111">
  <animate attributeName="opacity" values="1;0" dur="1s"
           calcMode="discrete" repeatCount="indefinite"/>
</rect>
```

`discrete` snaps between values with no fade — the terminal-cursor blink. Pair with staggered `<text>` reveals (`<set attributeName="opacity" to="1" begin="0.3s"/>` per character group) for a typing effect.
