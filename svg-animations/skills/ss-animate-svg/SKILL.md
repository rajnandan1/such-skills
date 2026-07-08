---
name: ss-animate-svg
description: >
  Create hand-crafted, dependency-free animated SVGs: self-drawing paths and signatures, loading
  spinners, morphing shapes, motion along a path, animated gradients, waves, pulses, and animated
  logos, icons, and badges — up to complex layered scenes with choreographed build-ins, particle
  fields, and parallax — choosing the right technique (CSS vs SMIL) for how the SVG is delivered
  (inline HTML, <img>, CSS background, GitHub README, favicon). Use when the user wants any animated
  SVG, asks to animate an existing SVG, icon, logo, or favicon, wants an animated scene, illustration,
  hero background, or banner, or mentions SMIL, stroke drawing, dashoffset, path or shape morphing,
  motion path, loader, spinner, animated checkmark, particles, parallax, or a "draws itself" effect.
---

# Animate SVG

Hand-craft SVG animations with nothing but markup — no JS libraries, no build step. Every SVG element is a DOM node you can animate with CSS or native SMIL.

## Workflow

1. **Pick the technique for the delivery context** (table below). This decides everything else.
2. **Build the static artwork first** and confirm it renders. Need path/shape/gradient/filter syntax? Read [references/paths-and-shapes.md](references/paths-and-shapes.md).
3. **Add animation.** For SMIL (`<animate>`, timing chains, easing, morphing) read [references/smil.md](references/smil.md). For ready-made patterns (spinner, checkmark, morphing menu icon, waves, shimmer, orbits) read [references/recipes.md](references/recipes.md) and adapt. For complex multi-element pieces — layered scenes, hero art, particles, parallax, choreographed build-ins — read [references/complex-scenes.md](references/complex-scenes.md) and follow its storyboard-first method.
4. **Accessibility pass** (below) — every deliverable.
5. **Verify** (below) — open it, watch it, check reduced motion.

## Choose the technique

| Where the SVG will live | What runs there | Use |
|---|---|---|
| Inline in HTML / JSX | Everything: page CSS, JS, SMIL, `:hover`, `click` | CSS keyframes; JS only if it needs state |
| `<img>`, CSS `background-image`, favicon, GitHub README | `<style>` **inside** the file and SMIL. No JS, no external CSS/fonts/images, no pointer events | CSS-in-SVG for simple loops; SMIL for chained, timed sequences |
| Needs interaction (hover, click-to-toggle) | Only inline SVG (or `<object>`) receives events | CSS `:hover` or SMIL `begin="click"` |

The most portable form is a single `.svg` file animating itself via an internal `<style>` block or SMIL — it works everywhere except where JS is required.

## Non-negotiables

1. **`pathLength="100"` on anything you stroke-animate.** It normalizes the geometric length so `stroke-dasharray`/`stroke-dashoffset` work in 0–100 units. Never guess lengths, never reach for `getTotalLength()`. Works on `<path>`, `<circle>`, `<rect>`, `<line>`, `<polyline>`, `<polygon>` in every evergreen browser — do not hand-compute circumferences "for legacy Safari". On **closed** shapes, make the dash slightly longer than the path (`stroke-dasharray: 101`) — an exact-length dash leaves a visible seam at the path start.
2. **Author the resting state as the FINAL state; keyframes supply the start.** Base styles show the finished artwork; the animation's `from`/`0%` moves it back to the beginning. Then disabling animation (reduced motion, ancient renderer) shows the art — not a blank.
3. **CSS transforms on SVG children need `transform-box: fill-box; transform-origin: center;`** — otherwise `center` means the viewBox origin/center and your "spin in place" orbits the whole canvas. SMIL rotation takes the center inline instead: `from="0 25 25" to="360 25 25"`.
4. **Hold the end state:** CSS `animation-fill-mode: both` (or `forwards`); SMIL `fill="freeze"`. Staggered starts need `both`/`backwards` so delayed elements sit at their `from` state during the delay.
5. **`viewBox` always;** add `width`/`height` attributes only to give an intrinsic size for `<img>`/favicon use.
6. **Stay on the compositor:** animate `transform` and `opacity` freely; animating `d`, geometry attributes, gradients, or filters repaints every frame — keep those elements small and few.
7. **Morphing `d` interpolates only between paths with the same command sequence** (same count, types, order).
8. **Seamless loops:** first value equals last value (`values="A;B;A"`), and easing splits symmetrically across the segments.
9. **Stagger, don't dogpile:** chain with `animation-delay` / `begin="id.end"` so the eye follows one motion at a time.
10. **`stroke-linecap="round"`** makes drawing effects look finished.

## Accessibility

- Meaningful graphic: `role="img"` on the `<svg>` plus a first-child `<title>` (add `<desc>` for detail). Decorative: `aria-hidden="true"`.
- Delivered via `<img>`, the internal `<title>` is not announced — tell the user to also set `alt="…"` on the `<img>`/Markdown embed.
- Ship reduced-motion handling **inside the file** so it travels with it. Because base styles are the final state (rule 2), this is just:

```css
@media (prefers-reduced-motion: reduce) {
  * { animation: none !important; transition: none !important; }
}
```

- SMIL cannot be media-queried. When reduced-motion support matters and the target is `<img>`-like, prefer CSS-in-SVG; if SMIL is unavoidable, keep the motion gentle (opacity fades, slow drifts — no spinning or flashing).

## Canonical example — house style in one file

Self-drawing "success" badge for a README (`<img>`-safe, reduced-motion-safe, accessible):

```xml
<svg viewBox="0 0 52 52" width="52" height="52" role="img" xmlns="http://www.w3.org/2000/svg">
  <title>Success</title>
  <style>
    .draw {
      stroke-dasharray: 101;              /* 101, not 100: exact-length dash seams on closed shapes */
      stroke-dashoffset: 0;               /* resting state = fully drawn */
      animation: draw 0.6s ease-out both;
    }
    .check { animation-delay: 0.55s; }
    @keyframes draw { from { stroke-dashoffset: 101; } }
    @media (prefers-reduced-motion: reduce) {
      .draw { animation: none; }          /* still shows the finished badge */
    }
  </style>
  <circle class="draw" cx="26" cy="26" r="23" pathLength="100"
          fill="none" stroke="#22c55e" stroke-width="3"/>
  <path class="draw check" d="M15 27l7 7 15-15" pathLength="100"
        fill="none" stroke="#22c55e" stroke-width="4"
        stroke-linecap="round" stroke-linejoin="round"/>
</svg>
```

Note the pattern: `pathLength="100"` (no measured lengths), dash `101` (no seam on the closed circle), base state = finished, `from` keyframe = start, `both` makes the delayed check invisible until its turn, reduced-motion shows the final art.

## Verify before delivering

1. Save the file and open it in a real browser: `open out.svg` (macOS) / `xdg-open out.svg` (Linux).
2. Watch a full cycle: end state holds (no snap-back), loops have no visible seam, nothing orbits off-center.
3. Reduced motion: DevTools → Rendering → emulate `prefers-reduced-motion: reduce` → the finished artwork must be visible, not a blank canvas.
4. For `<img>`/README targets, confirm the file is self-contained: no `<script>`, no external `href`/`url()` references, and interactivity-dependent triggers (`begin="click"`, `:hover`) aren't load-bearing.
