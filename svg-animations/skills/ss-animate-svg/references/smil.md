# SMIL — native SVG animation

SMIL animations are elements *inside* the SVG, so they run anywhere the SVG renders: `<img>`, CSS backgrounds, favicons, GitHub READMEs. Supported by every modern browser (the 2015 deprecation was reversed). Reach for SMIL when you need declarative timing chains or the target context strips CSS/JS; reach for CSS when a media query (reduced motion) or page-level coordination matters.

In JSX, SMIL works as-is — just camelCase the attributes React expects (`attributeName`, `repeatCount`, `keyTimes`, `keySplines`, `calcMode`).

## `<animate>` — any attribute

```xml
<circle cx="50" cy="50" r="20" fill="#e63946">
  <animate attributeName="r" from="20" to="40" dur="1s" repeatCount="indefinite"/>
</circle>
```

Keyframes via `values` (+ optional `keyTimes`, 0–1, same count as values):

```xml
<animate attributeName="cx" values="50;150;100;50" keyTimes="0;0.33;0.66;1"
         dur="3s" repeatCount="indefinite"/>
```

Essentials:

| Attribute | Meaning |
|---|---|
| `fill="freeze"` | Hold the final value after the animation ends (default `remove` snaps back) |
| `repeatCount` | Number or `indefinite` |
| `begin` | When to start — see timing below |
| `restart` | `always` (default), `whenNotActive`, `never` — guard click-triggered animations from re-trigger spam |
| `additive="sum"` | Add to the base value instead of replacing it |
| `accumulate="sum"` | Each repeat builds on the last — spirals, ratchets |

## `<animateTransform>` — translate, scale, rotate, skewX, skewY

```xml
<rect x="15" y="15" width="20" height="20" fill="#264653">
  <animateTransform attributeName="transform" type="rotate"
                    from="0 25 25" to="360 25 25" dur="4s" repeatCount="indefinite"/>
</rect>
```

- `rotate` takes the center in the value: `angle cx cy`. No `transform-origin` needed — this is SMIL's advantage over CSS here.
- To animate two transform types on one element (spin **and** grow), stack two `<animateTransform>` with `additive="sum"`; a second one without it replaces the first.

## `<animateMotion>` — move along a path

```xml
<path id="track" d="M 20,50 C 20,0 80,0 80,50 S 140,100 140,50" fill="none" stroke="#eee"/>
<circle r="5" fill="#e63946">
  <animateMotion dur="3s" repeatCount="indefinite" rotate="auto">
    <mpath href="#track"/>
  </animateMotion>
</circle>
```

`rotate="auto"` keeps the element tangent to the path (`auto-reverse` flips it). The element's own x/y should be at the origin — the motion path supplies position.

## `<set>` — discrete change, no interpolation

```xml
<set attributeName="fill" to="#e63946" begin="1s"/>
```

## Timing and chaining

The killer feature: animations reference each other by id, no JS choreography.

```xml
<animate id="a1" attributeName="cx" to="150" dur="1s" fill="freeze"/>
<animate attributeName="cy" to="150" dur="1s" begin="a1.end" fill="freeze"/>
<animate attributeName="r"  to="30" dur="0.5s" begin="a1.end+0.5s" fill="freeze"/>
```

| `begin=` | Starts |
|---|---|
| `2s` | 2s after load |
| `a1.end` / `a1.begin` | when another animation ends / starts |
| `a1.end+0.5s` | offset from another |
| `a1.repeat(2)` | on its 2nd repeat |
| `click` / `mouseover` | on event — **inline/`<object>` SVG only**, pointer events never reach `<img>` content |
| `0s;btn.click` | multiple triggers, semicolon-separated |
| `indefinite` | only via `beginElement()` from JS |

## Easing — `calcMode` and `keySplines`

`calcMode`: `linear` (default), `discrete` (stepped), `paced` (constant velocity across uneven keyframes), `spline` (bézier easing).

```xml
<animate attributeName="cy" values="20;80;20" keyTimes="0;0.5;1" dur="2s"
         calcMode="spline" keySplines="0.42 0 0.58 1; 0.42 0 0.58 1"
         repeatCount="indefinite"/>
```

Rule: n `values` → n `keyTimes` → **n−1** `keySplines` (one per segment, semicolon-separated).

| Feel | keySplines |
|---|---|
| ease-in-out | `0.42 0 0.58 1` |
| ease-out (decelerate in) | `0 0 0.58 1` |
| ease-in (accelerate out) | `0.42 0 1 1` |
| overshoot / bounce-ish | `0.34 1.56 0.64 1` |

## Morphing `d`

Every path in `values` must have the identical command sequence (count, types, order). If shapes differ, redraw the simpler one with extra collinear points until the structures match.

```xml
<path fill="#e63946">
  <animate attributeName="d" dur="2s" repeatCount="indefinite"
    calcMode="spline" keySplines="0.42 0 0.58 1; 0.42 0 0.58 1"
    values="M 50,10 L 90,90 L 10,90 Z;
            M 50,90 L 90,10 L 10,10 Z;
            M 50,10 L 90,90 L 10,90 Z"/>
</path>
```

CSS can morph too — `d: path("...")` is transition/animation-able in modern browsers under the same matching-commands rule. Same-file `<style>` keeps it portable.

## SMIL caveats

- **No media queries**: SMIL can't see `prefers-reduced-motion`. If that requirement is hard, use CSS-in-SVG instead, or keep SMIL motion gentle.
- **Event triggers need a live DOM**: `begin="click"` and friends only work inline or via `<object>`.
- **Timeline starts at document load**: in long pages a mid-page SVG's animation may have already run; loop it, or trigger via `begin` chains rather than absolute times.
