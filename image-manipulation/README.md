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

In a Claude Code session just ask naturally (see [Examples](#examples)) — the skill runs the bundled script for you. To run it by hand from a clone of this repo:

```bash
# Single platform
bash skills/ss-image-resize/scripts/resize.sh hero.png --platform og-image

# All YouTube sizes
bash skills/ss-image-resize/scripts/resize.sh channel-art.png --category youtube

# Every platform at once
bash skills/ss-image-resize/scripts/resize.sh brand.png --all --output ./all-sizes/

# Fit mode with black padding (ideal for screenshots)
bash skills/ss-image-resize/scripts/resize.sh screenshot.png --platform appstore-iphone-15-pro-max --fit --pad-color 000000

# List all presets
bash skills/ss-image-resize/scripts/resize.sh --list
```

**Options:**

| Flag | Description | Default |
|------|-------------|---------|
| `--platform NAME` | Generate for a specific preset | (required unless `--all`) |
| `--all` | Generate for every preset | off |
| `--category CAT` | Generate for a category | — |
| `--output DIR` | Output directory | `./resized/` |
| `--fit` | Fit inside target with padding | off (cover-crop) |
| `--pad-color HEX` | Padding color for fit mode (no #) | `FFFFFF` |
| `--quality N` | Output quality 1-100 | `92` |

**62 Platform Presets:**

| Category | Presets |
|----------|---------|
| **Web / SEO** | og-image, blog-cover, notion-cover |
| **Chrome Extension** | chrome-screenshot, chrome-small-promo, chrome-marquee-promo |
| **Ads** | feed-ad, post-ad |
| **Play Store** | play-icon, play-feature, play-screenshot-5, play-screenshot-6 |
| **App Store** | appstore-iphone-15-pro-max, appstore-iphone-14-plus, appstore-iphone-14-pro, appstore-iphone-14, appstore-ipad-pro, appstore-mac, appstore-watch-ultra, appstore-watch-series |
| **YouTube** | youtube-profile, youtube-cover, youtube-thumbnail |
| **TikTok** | tiktok-profile, tiktok-video, tiktok-image-ad, tiktok-square-ad |
| **Pinterest** | pinterest-profile, pinterest-board-cover, pinterest-square, pinterest-medium, pinterest-long |
| **Substack** | substack-featured, substack-logo, substack-email-banner, substack-social, substack-cover |
| **Threads** | threads-profile, threads-square, threads-carousel |
| **Instagram** | instagram-feed-square, instagram-feed-portrait, instagram-stories, instagram-reels |
| **Twitter** | twitter-one-image, twitter-two-images, twitter-cover-photo, twitter-og |
| **Dribbble** | dribbble-shot |
| **Bluesky** | bluesky-post, bluesky-cover, bluesky-cover-mobile |
| **Product Hunt** | producthunt-gallery, producthunt-thumbnail |
| **LinkedIn** | linkedin-feed, linkedin-cover-business, linkedin-cover-personal, linkedin-stories |
| **Facebook** | facebook-news-feed, facebook-stories, facebook-cover-photo, facebook-og |

Exact pixel dimensions for every preset are in [skills/ss-image-resize/references/platforms.md](skills/ss-image-resize/references/platforms.md), or run the script with `--list`.

### ss-png-to-svg

Convert raster PNG images into smooth, clean SVG vector files. Traces bitmap images using potrace's bezier curves with multi-color support.

**Usage:**

```bash
# Multi-color logo (default)
bash skills/ss-png-to-svg/scripts/png2svg.sh logo.png logo.svg

# Single-color icon
bash skills/ss-png-to-svg/scripts/png2svg.sh icon.png icon.svg --single-color

# Custom color override
bash skills/ss-png-to-svg/scripts/png2svg.sh icon.png icon.svg --color "#FF5733"

# Adjust tracing detail
bash skills/ss-png-to-svg/scripts/png2svg.sh detailed.png --threshold 60 --smoothness 1.0
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
bash skills/ss-format-convert/scripts/convert.sh screenshot.png --to jpg

# HEIC to PNG (iPhone photos)
bash skills/ss-format-convert/scripts/convert.sh photo.heic --to png

# PNG to WebP with custom quality
bash skills/ss-format-convert/scripts/convert.sh banner.png --to webp --quality 90

# Batch convert all images in a folder
bash skills/ss-format-convert/scripts/convert.sh --batch ./images/ --to webp --output ./web-images/

# Batch convert recursively
bash skills/ss-format-convert/scripts/convert.sh --batch ./photos/ --to jpg --recursive

# Transparent PNG to JPG with black background
bash skills/ss-format-convert/scripts/convert.sh logo.png --to jpg --bg-color 000000

# List supported formats
bash skills/ss-format-convert/scripts/convert.sh --formats
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
generate every platform size from brand-logo.png
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
