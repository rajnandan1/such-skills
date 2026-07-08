# SVG building blocks — coordinates, paths, transforms, paint

Reference for constructing the static artwork before animating it.

## Coordinate system

`viewBox="minX minY width height"` defines the canvas; all coordinates are in those units and the whole graphic scales to any rendered size.

```xml
<svg viewBox="0 0 200 200" xmlns="http://www.w3.org/2000/svg">
  <!-- a 200×200-unit canvas -->
</svg>
```

Round numbers (0 0 24 24, 0 0 100 100) keep hand-written coordinates sane.

## Shape primitives

```xml
<rect x="10" y="10" width="80" height="40" rx="4" fill="#1a1a1a"/>
<circle cx="50" cy="50" r="30" fill="#e63946"/>
<ellipse cx="50" cy="50" rx="40" ry="20" fill="#457b9d"/>
<line x1="10" y1="10" x2="90" y2="90" stroke="#2a9d8f" stroke-width="2"/>
<polygon points="50,5 95,90 5,90" fill="#e9c46a"/>
<polyline points="10,80 40,20 70,60 100,10" fill="none" stroke="#264653" stroke-width="2"/>
```

All of these accept `pathLength`, so the stroke-drawing technique works on them, not just on `<path>`.

## `<path>` commands

Uppercase = absolute coordinates, lowercase = relative to the current point.

| Command | Purpose | Syntax |
|---------|---------|--------|
| M/m | Move to | `M x y` |
| L/l | Line to | `L x y` |
| H/h, V/v | Horizontal / vertical line | `H x` / `V y` |
| C/c | Cubic bézier | `C x1 y1, x2 y2, x y` |
| S/s | Smooth cubic (reflects previous control point) | `S x2 y2, x y` |
| Q/q | Quadratic bézier | `Q x1 y1, x y` |
| T/t | Smooth quadratic | `T x y` |
| A/a | Elliptical arc | `A rx ry rot large-arc sweep x y` |
| Z/z | Close path | `Z` |

**Cubic bézier (`C`)**: first control point sets the departure angle, second sets the arrival angle.

```xml
<path d="M 10 80 C 40 10, 65 10, 95 80" stroke="#000" fill="none" stroke-width="2"/>
```

**Smooth cubic (`S`)** chains fluid S-curves by mirroring the previous control point:

```xml
<path d="M 10 80 C 40 10, 65 10, 95 80 S 150 150, 180 80" stroke="#000" fill="none"/>
```

**Arc (`A`)**: `rx ry x-rotation large-arc-flag sweep-flag x y` — `large-arc-flag` 1 takes the >180° route; `sweep-flag` 1 goes clockwise.

```xml
<!-- Heart from two arcs + two quadratics -->
<path d="M 10,30 A 20,20 0,0,1 50,30 A 20,20 0,0,1 90,30 Q 90,60 50,90 Q 10,60 10,30 Z" fill="#e63946"/>
```

## Groups and transforms

```xml
<g transform="translate(50 50) rotate(45)" opacity="0.8">
  <rect x="-20" y="-20" width="40" height="40" fill="#264653"/>
</g>
```

- Transform lists apply **right to left** (`translate(...) rotate(...)` rotates first, then translates).
- The attribute forms take an explicit center — `rotate(45 50 50)` rotates around (50,50) with no CSS needed. Use this for static placement; use CSS/SMIL for animation.
- Group with `<g>` to move/animate a whole sub-drawing as one unit, and to layer choreography: animate the group's transform separately from each child's properties.

## Reuse: `<defs>`, `<use>`, `<symbol>`

Anything referenced rather than drawn directly (gradients, filters, masks, clip paths, template shapes) lives in `<defs>`. Stamp repeated artwork with `<use>`:

```xml
<defs><circle id="dot" r="4" fill="#e63946"/></defs>
<use href="#dot" x="20" y="50"/>
<use href="#dot" x="40" y="50"/>
<use href="#dot" x="60" y="50"/>
```

## Gradients

```xml
<defs>
  <linearGradient id="grad" x1="0%" y1="0%" x2="100%" y2="100%">
    <stop offset="0%"  stop-color="#e63946"/>
    <stop offset="100%" stop-color="#457b9d"/>
  </linearGradient>
  <radialGradient id="glow" cx="50%" cy="50%" r="50%">
    <stop offset="0%"  stop-color="#fff" stop-opacity="0.8"/>
    <stop offset="100%" stop-color="#fff" stop-opacity="0"/>
  </radialGradient>
</defs>
<rect width="200" height="100" fill="url(#grad)" rx="8"/>
```

Gradient stops (`stop-color`, `stop-offset`) and the gradient's `gradientTransform` are all animatable — see the shimmer and color-shift recipes.

## Mask vs clip-path

- `<clipPath>`: hard-edged cookie cutter — inside is visible, outside is gone.
- `<mask>`: luminance map — white reveals, black hides, gray is partial; can be soft (gradients, blurred shapes).

```xml
<defs>
  <mask id="reveal">
    <rect width="100%" height="100%" fill="black"/>
    <circle cx="100" cy="100" r="50" fill="white"/>
  </mask>
</defs>
<rect width="200" height="200" fill="url(#grad)" mask="url(#reveal)"/>
```

Animating the white shape inside a mask is the standard "spotlight/reveal" technique.

## Filters

```xml
<defs>
  <filter id="soft"><feGaussianBlur in="SourceGraphic" stdDeviation="3"/></filter>
  <filter id="glow" x="-50%" y="-50%" width="200%" height="200%">
    <feDropShadow dx="0" dy="0" stdDeviation="4" flood-color="#e63946"/>
  </filter>
</defs>
<circle cx="50" cy="50" r="20" fill="#e63946" filter="url(#glow)"/>
```

- `feDropShadow` with `dx/dy = 0` is the cheap glow.
- Give glow/blur filters an expanded filter region (`x="-50%" ...` as above) or the effect clips at the element's bounding box.
- `feTurbulence` + `feDisplacementMap` produces hand-drawn wobble and liquid distortion.
- Filters are the most expensive thing you can animate — animate the element under a static filter rather than the filter's parameters, and keep filtered elements small.

## Text

```xml
<text x="100" y="50" text-anchor="middle" font-size="14" fill="#111">Label</text>
<path id="curve" d="M 20,80 C 60,20 140,20 180,80" fill="none"/>
<text font-size="12"><textPath href="#curve" startOffset="50%" text-anchor="middle">along a path</textPath></text>
```

Text in `<img>`-delivered SVGs renders with the viewer's fonts only — don't rely on webfonts there; convert decisive lettering to paths.
