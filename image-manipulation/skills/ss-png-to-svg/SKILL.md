---
name: ss-png-to-svg
description: >
  Convert PNG images to smooth, scalable SVG vector files using potrace tracing.
  Supports multi-color PNGs (logos, icons, illustrations) by extracting dominant colors
  and tracing each color layer separately, then compositing into a clean SVG.
  Also handles single-color images and lets users override the fill color.
  Use this skill whenever the user wants to: convert a PNG to SVG, trace a bitmap,
  vectorize an image or logo, turn a raster image into vectors, create an SVG from
  a PNG/JPEG/bitmap, or anything involving bitmap-to-vector conversion. Also trigger
  when the user mentions "potrace", "image tracing", or asks to make an image scalable.
---

# PNG to SVG Converter

Convert raster PNG images into smooth, clean SVG vector files. The skill uses ImageMagick for image preprocessing and potrace for bezier curve tracing, producing SVGs with smooth paths that scale to any size.

## Prerequisites

Two command-line tools are needed. If either is missing, install them:

```bash
brew install imagemagick potrace
```

## How to use

There's a bundled script at `scripts/png2svg.sh` that handles the full pipeline. Run it directly:

```bash
bash <skill-path>/scripts/png2svg.sh <input.png> [output.svg] [OPTIONS]
```

### Options

| Flag | Description | Default |
|------|-------------|---------|
| `--single-color` | Force single-color trace instead of multi-color | off (multi-color) |
| `--color "#hex"` | Override the fill color | auto-detected |
| `--threshold N` | Grayscale threshold 0-100 (higher = more detail) | 50 |
| `--smoothness N` | Curve smoothness 0-1.334 (higher = smoother) | 1.334 |

### Examples

**Simple single-color logo:**
```bash
bash <skill-path>/scripts/png2svg.sh logo.png logo.svg --single-color
```

**Multi-color illustration (default):**
```bash
bash <skill-path>/scripts/png2svg.sh artwork.png artwork.svg
```

**Override color:**
```bash
bash <skill-path>/scripts/png2svg.sh icon.png icon.svg --color "#FF5733"
```

**Adjust for detailed images:**
```bash
bash <skill-path>/scripts/png2svg.sh detailed.png --threshold 60 --smoothness 1.0
```

## What the script does

1. **Color extraction** — Samples the PNG's dominant colors (up to 8) using ImageMagick's histogram, skipping near-white and near-black (background colors).

2. **Per-color tracing** — For each detected color, isolates matching pixels using fuzz matching, converts to a binary bitmap, then traces with potrace using smooth bezier curves.

3. **SVG composition** — Combines all traced color layers into a single SVG, with each layer using its original fill color.

4. **Cleanup** — Removes the background rectangle that potrace adds (the full-canvas M0 path), and deletes all temporary files.

## When things don't look right

The two most impactful parameters to tweak are:

- **Threshold** (`--threshold`): If the SVG is missing detail, increase this (try 60-70). If it's too noisy, decrease it (try 30-40).
- **Smoothness** (`--smoothness`): The default 1.334 gives very smooth curves. Lower values (0.5-1.0) preserve more sharp corners, which is better for pixel art or geometric designs.

For images with transparency (like PNGs with alpha channels), the script handles this automatically — transparent areas become empty space in the SVG.

## Limitations

- Works best with logos, icons, illustrations, and graphics with solid color areas
- Photographic images will lose detail (this is inherent to tracing — photos are better as embedded raster)
- Very fine text may not trace cleanly; consider using actual SVG text elements for text
- JPEG input: rename to .png or convert first with `magick input.jpg input.png`
