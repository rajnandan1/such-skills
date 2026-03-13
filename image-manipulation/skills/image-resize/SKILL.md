---
name: image-resize
description: >
  Resize and crop images to exact platform-specific dimensions for social media, app stores, ads, and web.
  Supports 40+ platform presets including OG images, YouTube thumbnails, App Store screenshots, Play Store
  graphics, TikTok, Pinterest, Threads, Substack, Chrome Web Store, Notion covers, and more.
  Uses ImageMagick for high-quality Lanczos resampling. Works on macOS, Linux, and Windows.
  Use this skill whenever the user wants to resize an
  image for a specific platform, create social media assets, generate app store screenshots, make thumbnails,
  create OG images, prepare images for upload, or batch-resize to multiple sizes. Also trigger when the user
  mentions any platform (YouTube, TikTok, Pinterest, App Store, Play Store, Substack, Threads, Chrome Web
  Store, Notion, etc.) in the context of image sizing, resizing, cropping, or preparation — even if they
  don't explicitly say "resize".
---

# Image Resize — Platform-Aware Image Resizer

Resize and crop any image to exact dimensions for 40+ platform presets using ImageMagick's high-quality Lanczos resampling.

## Prerequisites

ImageMagick is required. If not installed:

```bash
brew install imagemagick    # macOS
sudo apt install imagemagick # Debian/Ubuntu
```

## How to use

Run the bundled script:

```bash
bash <skill-path>/scripts/resize.sh <input-image> [OPTIONS]
```

### Options

| Flag | Description | Default |
|------|-------------|---------|
| `--platform NAME` | Generate image for a specific platform preset | (required unless `--all`) |
| `--all` | Generate images for every preset | off |
| `--category CAT` | Generate all presets in a category (e.g. `youtube`, `appstore`) | — |
| `--output DIR` | Output directory | `./resized/` |
| `--list` | List all available platform presets and exit | — |
| `--fit` | Fit image inside target (letterbox with padding) instead of cover-crop | off (cover-crop) |
| `--pad-color HEX` | Padding color when using `--fit` (6-digit hex, no #) | `FFFFFF` |
| `--quality N` | Output quality 1-100 | `92` |

### Platform presets

The script knows these categories. For the full list of preset names and exact pixel dimensions, read `references/platforms.md`.

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

### Examples

**Single platform — OG image for a blog post:**
```bash
bash <skill-path>/scripts/resize.sh hero.png --platform og-image
```

**All YouTube sizes at once:**
```bash
bash <skill-path>/scripts/resize.sh channel-art.png --category youtube --output ./youtube-assets/
```

**Every platform preset from one source image:**
```bash
bash <skill-path>/scripts/resize.sh brand-logo.png --all --output ./all-sizes/
```

**Fit mode (letterbox instead of crop) with black padding:**
```bash
bash <skill-path>/scripts/resize.sh screenshot.png --platform appstore-iphone-15-pro-max --fit --pad-color 000000
```

**List available presets:**
```bash
bash <skill-path>/scripts/resize.sh --list
```

## How it works

The script uses a **cover-crop** strategy by default — the same approach image editors use for "fill" mode:

1. **Scale** the image so it fully covers the target rectangle (using ImageMagick's `resize WxH^` with Lanczos filter)
2. **Center-crop** to the exact target dimensions (using `-gravity center -extent WxH`)

This means no distortion and no empty space — the image always fills the frame, cropping from the center if the aspect ratios differ.

With `--fit`, the strategy flips: the image is scaled to fit *inside* the target, then padded to exact dimensions with a solid color. This is useful for screenshots or images where you don't want anything cropped off.

## When to pick which mode

- **Banners, covers, thumbnails, OG images** — default cover-crop is usually best. The subject should be centered in the source image for best results.
- **App Store / Play Store screenshots** — use `--fit` so UI elements at the edges aren't clipped.
- **Icons and profile photos** — cover-crop works well since these are typically square-ish crops of a centered subject.
- **Pinterest long pins** — if your source is landscape, `--fit` avoids aggressive cropping.

## Supported input formats

ImageMagick handles PNG, JPEG, TIFF, GIF, BMP, WebP, HEIC, and many more. Output format matches the input (a .png stays .png, a .jpg stays .jpg).

## Output naming

Files are saved as `<platform-name>.<ext>` in the output directory. For example:
- `resized/og-image.png`
- `resized/youtube-thumbnail.jpg`
- `resized/appstore-iphone-15-pro-max.png`
