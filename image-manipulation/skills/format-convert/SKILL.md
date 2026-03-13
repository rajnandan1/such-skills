---
name: format-convert
description: >
  Convert images between formats: PNG, JPG/JPEG, WebP, TIFF, BMP, GIF, HEIC, and AVIF.
  Performs high-quality lossless conversion by default. Handles alpha channel transparency
  automatically — compositing against a configurable background color when converting to
  formats that lack alpha support (JPG, BMP). Supports single-file and batch directory
  conversion with optional recursive subdirectory scanning. Uses ImageMagick.
  Use this skill whenever the user wants to: convert an image to another format, change
  image format, save as PNG/JPG/WebP/TIFF, convert HEIC photos to JPG or PNG, batch
  convert images, make images web-compatible, convert to WebP for web optimization, or
  anything involving image format conversion. Also trigger when the user mentions format
  names in the context of converting, exporting, or saving images.
---

# Format Convert — Lossless Image Format Converter

Convert any image between PNG, JPG, WebP, TIFF, BMP, GIF, HEIC, and AVIF using ImageMagick. Lossless by default — preserves maximum quality and original dimensions.

## Prerequisites

ImageMagick is required. For HEIC/AVIF support, ensure delegates are installed.

```bash
brew install imagemagick    # macOS
sudo apt install imagemagick # Debian/Ubuntu
```

## How to use

Run the bundled script:

```bash
bash <skill-path>/scripts/convert.sh <input-image> --to FORMAT [OPTIONS]
```

### Options

| Flag | Description | Default |
|------|-------------|---------|
| `--to FORMAT` | Target format (png, jpg, webp, tiff, bmp, gif, heic, avif) | (required) |
| `--output DIR` | Output directory | `./converted/` |
| `--quality N` | Quality for lossy formats 1-100 | `100` |
| `--bg-color HEX` | Background color when removing alpha (6-digit hex, no #) | `FFFFFF` |
| `--batch DIR` | Convert all supported images in a directory | — |
| `--recursive` | Include subdirectories in batch mode | off |
| `--formats` | List supported formats and exit | — |

### Supported formats

For the full reference with alpha support, lossy/lossless details, and conversion notes, read `references/formats.md`.

| Format | Alpha | Quality |
|--------|-------|---------|
| PNG | yes | lossless |
| JPG | no | lossy |
| WebP | yes | both |
| TIFF | yes | lossless |
| BMP | no | lossless |
| GIF | yes (1-bit) | lossless |
| HEIC | yes | lossy |
| AVIF | yes | both |

### Examples

**Convert PNG to JPG:**
```bash
bash <skill-path>/scripts/convert.sh screenshot.png --to jpg
```

**Convert HEIC photos to PNG:**
```bash
bash <skill-path>/scripts/convert.sh photo.heic --to png
```

**Convert to WebP for web optimization:**
```bash
bash <skill-path>/scripts/convert.sh banner.png --to webp --quality 90
```

**Batch convert all images in a folder to WebP:**
```bash
bash <skill-path>/scripts/convert.sh --batch ./images/ --to webp --output ./web-images/
```

**Batch convert recursively:**
```bash
bash <skill-path>/scripts/convert.sh --batch ./photos/ --to jpg --recursive --output ./exported/
```

**Transparent PNG to JPG with custom background:**
```bash
bash <skill-path>/scripts/convert.sh logo.png --to jpg --bg-color 000000
```

**List supported formats:**
```bash
bash <skill-path>/scripts/convert.sh --formats
```

## How it works

The script uses ImageMagick for all conversions with a **lossless-first** strategy:

1. **Alpha detection** — Before converting to a non-alpha format (JPG, BMP), the script checks whether the source image actually has transparency using `magick identify -format "%A"`. Only images with real alpha data get flattened against the background color.

2. **Quality maximization** — The default quality is 100. For formats that support true lossless encoding:
   - **WebP** at quality 100 enables `webp:lossless=true`
   - **AVIF** at quality 100 enables `heif:lossless=true`
   - **PNG** always uses lossless encoding (quality controls compression level only)
   - **TIFF** uses uncompressed output (`-compress None`)

3. **Dimension preservation** — The script never resizes. Output dimensions always match the source.

4. **Same-format skip** — If the source is already the target format, the file is skipped rather than re-encoded.

## Format notes

- **Animated GIFs** — Only the first frame is converted. Full animation conversion is not supported.
- **HEIC/AVIF** — Require ImageMagick delegates (`libheif`). If not installed, conversion will fail with a clear error.
- **JPG/BMP from transparent sources** — Alpha is composited against `--bg-color` (default white). Opaque sources pass through unchanged.

## Output naming

Files are saved as `<original-name>.<target-ext>` in the output directory. For example:
- `converted/screenshot.jpg`
- `converted/photo.png`
- `converted/banner.webp`
