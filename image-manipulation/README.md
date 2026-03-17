# Image Manipulation Plugin for Claude Code

> PNG-to-SVG vector conversion, platform-aware image resizing with 60+ presets, and lossless image format conversion. Resize, crop, and convert images without leaving your terminal.

## Installation

### Quick install (npx)

```bash
npx skills add rajnandan1/such-skills/ss-image-manipulation
```

### Claude Code (CLI)

```bash
claude plugin marketplace add rajnandan1/such-skills
claude plugin install ss-image-manipulation@such-skills
```

## Skills

### ss-image-resize

Resize and crop images to exact platform dimensions using ImageMagick's Lanczos resampling. Supports **cover-crop** (fill) and **fit** (letterbox with padding) modes.

**Usage:**

```bash
# Single platform
bash <skill-path>/scripts/resize.sh hero.png --platform og-image

# All YouTube sizes
bash <skill-path>/scripts/resize.sh channel-art.png --category youtube

# Every platform at once
bash <skill-path>/scripts/resize.sh brand.png --all --output ./all-sizes/

# Fit mode with black padding (ideal for screenshots)
bash <skill-path>/scripts/resize.sh screenshot.png --platform appstore-iphone-15-pro-max --fit --pad-color 000000

# List all presets
bash <skill-path>/scripts/resize.sh --list
```

**Options:**

| Flag | Description | Default |
|------|-------------|---------|
| `--platform NAME` | Generate for a specific preset | (required unless `--all`) |
| `--all` | Generate for all 40 presets | off |
| `--category CAT` | Generate for a category | — |
| `--output DIR` | Output directory | `./resized/` |
| `--fit` | Fit inside target with padding | off (cover-crop) |
| `--pad-color HEX` | Padding color for fit mode (no #) | `FFFFFF` |
| `--quality N` | Output quality 1-100 | `92` |

**40 Platform Presets:**

| Category | Presets |
|----------|---------|
| **Web / SEO** | og-image (2400x1260), blog-cover (2400x1260), notion-cover (1500x600) |
| **Chrome Extension** | chrome-screenshot (1280x800), chrome-small-promo (1400x560), chrome-marquee-promo (440x280) |
| **Ads** | feed-ad (1200x628), post-ad (1200x1200) |
| **Play Store** | play-icon (512x512), play-feature (1024x500), play-screenshot-5 (1080x1920), play-screenshot-6 (1440x2880) |
| **App Store** | appstore-iphone-15-pro-max (1284x2778), appstore-iphone-14-plus (1242x2688), appstore-iphone-14-pro (1179x2556), appstore-iphone-14 (1170x2532), appstore-ipad-pro (2048x2732), appstore-mac (2880x1800), appstore-watch-ultra (410x502), appstore-watch-series (396x484) |
| **YouTube** | youtube-profile (800x800), youtube-cover (2560x1440), youtube-thumbnail (1280x720) |
| **TikTok** | tiktok-profile (720x720), tiktok-video (1080x1920), tiktok-image-ad (1200x628), tiktok-square-ad (640x640) |
| **Pinterest** | pinterest-profile (165x165), pinterest-board-cover (800x450), pinterest-square (1000x1000), pinterest-medium (1000x1500), pinterest-long (1000x2100) |
| **Substack** | substack-featured (1456x1048), substack-logo (256x256), substack-email-banner (1100x220), substack-social (1456x1048), substack-cover (600x600) |
| **Threads** | threads-profile (320x320), threads-square (1080x1080), threads-carousel (1080x1440) |

### ss-png-to-svg

Convert raster PNG images into smooth, clean SVG vector files. Traces bitmap images using potrace's bezier curves with multi-color support.

**Usage:**

```bash
# Multi-color logo (default)
bash <skill-path>/scripts/png2svg.sh logo.png logo.svg

# Single-color icon
bash <skill-path>/scripts/png2svg.sh icon.png icon.svg --single-color

# Custom color override
bash <skill-path>/scripts/png2svg.sh icon.png icon.svg --color "#FF5733"

# Adjust tracing detail
bash <skill-path>/scripts/png2svg.sh detailed.png --threshold 60 --smoothness 1.0
```

**Options:**

| Flag | Description | Default |
|------|-------------|---------|
| `--single-color` | Force single-color trace | off (multi-color) |
| `--color "#hex"` | Override fill color | auto-detected |
| `--threshold N` | Grayscale threshold 0-100 | 50 |
| `--smoothness N` | Curve smoothness 0-1.334 | 1.334 |

### ss-format-convert

Convert images between PNG, JPG, WebP, TIFF, BMP, GIF, HEIC, and AVIF. Lossless by default — quality 100 with true lossless modes for WebP and AVIF. Handles alpha-to-no-alpha conversion automatically.

**Usage:**

```bash
# PNG to JPG
bash <skill-path>/scripts/convert.sh screenshot.png --to jpg

# HEIC to PNG (iPhone photos)
bash <skill-path>/scripts/convert.sh photo.heic --to png

# PNG to WebP with custom quality
bash <skill-path>/scripts/convert.sh banner.png --to webp --quality 90

# Batch convert all images in a folder
bash <skill-path>/scripts/convert.sh --batch ./images/ --to webp --output ./web-images/

# Batch convert recursively
bash <skill-path>/scripts/convert.sh --batch ./photos/ --to jpg --recursive

# Transparent PNG to JPG with black background
bash <skill-path>/scripts/convert.sh logo.png --to jpg --bg-color 000000

# List supported formats
bash <skill-path>/scripts/convert.sh --formats
```

**Options:**

| Flag | Description | Default |
|------|-------------|---------|
| `--to FORMAT` | Target format (png, jpg, webp, tiff, bmp, gif, heic, avif) | (required) |
| `--output DIR` | Output directory | `./converted/` |
| `--quality N` | Quality for lossy formats 1-100 | `100` |
| `--bg-color HEX` | Background color when removing alpha (no #) | `FFFFFF` |
| `--batch DIR` | Convert all supported images in DIR | — |
| `--recursive` | Include subdirectories in batch mode | off |
| `--formats` | List supported formats and exit | — |

## Hooks

### validate-resize

A PostToolUse hook that automatically validates image dimensions after every resize operation. No configuration needed — activates when the plugin is installed.

**What it checks:**
- Output files exist
- Each file has the correct pixel dimensions (via `magick identify`)
- Reports mismatches back to Claude so it can retry or alert you

**Example output on failure:**
```
Resize validation failed (3 files checked):
MISMATCH: youtube-profile.png — expected 800x800, got 500x300
```

### validate-conversion

A PostToolUse hook that automatically validates converted images after every format conversion. Activates when the plugin is installed.

**What it checks:**
- Output files exist and are valid images
- Dimensions are preserved (format conversion should not alter size)
- Reports errors back to Claude so it can retry or alert you

**Example output on failure:**
```
Conversion validation failed (2 files checked):
MISSING: ./converted/photo.jpg
DIMENSION_CHANGE: ./converted/banner.webp — expected 1920x1080, got 960x540
```

## Examples

Ask Claude naturally:

```
resize my hero.png for og-image
```
```
I need YouTube assets — profile, cover, and thumbnail from this channel-art.png
```
```
resize screenshot.png for all App Store iPhone sizes, use fit mode with black padding
```
```
generate all 60 platform sizes from brand-logo.png
```
```
convert my company logo.png to a scalable SVG
```
```
vectorize this icon.png — it's a single dark color on white
```
```
convert my screenshot.png to jpg
```
```
batch convert all HEIC photos in ~/Photos to PNG
```
```
save this image as webp
```

## License

MIT
