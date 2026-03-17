# Supported Formats — Full Reference

All supported image formats with properties and conversion notes.

## Format Properties

| Format | Extensions | Alpha | Quality | Notes |
|--------|-----------|-------|---------|-------|
| PNG | .png | Yes | Lossless | Best for screenshots, graphics with transparency |
| JPEG | .jpg, .jpeg | No | Lossy | Best for photographs, smallest file size for photos |
| WebP | .webp | Yes | Both | Modern web format, excellent compression |
| TIFF | .tiff, .tif | Yes | Lossless | Print/archival, large file sizes |
| BMP | .bmp | No | Lossless | Uncompressed bitmap, very large files |
| GIF | .gif | Yes (1-bit) | Lossless | Limited to 256 colors, only first frame converted |
| HEIC | .heic | Yes | Lossy | Apple/iPhone photos, excellent quality-to-size ratio |
| AVIF | .avif | Yes | Both | Next-gen format, best compression ratio |

## Conversion Matrix

Shows whether converting from one format to another is truly lossless (no quality loss) or involves some quality reduction.

| From \ To | PNG | JPG | WebP | TIFF | BMP | GIF | HEIC | AVIF |
|-----------|-----|-----|------|------|-----|-----|------|------|
| **PNG** | — | lossy | lossless* | lossless | lossy** | lossy*** | lossy | lossless* |
| **JPG** | lossless | — | lossy | lossless | lossless | lossy*** | lossy | lossy |
| **WebP** | lossless | lossy | — | lossless | lossy** | lossy*** | lossy | lossy |
| **TIFF** | lossless | lossy | lossless* | — | lossy** | lossy*** | lossy | lossless* |
| **BMP** | lossless | lossy | lossless* | lossless | — | lossy*** | lossy | lossless* |
| **GIF** | lossless | lossy | lossless* | lossless | lossless | — | lossy | lossless* |
| **HEIC** | lossless | lossy | lossy | lossless | lossy** | lossy*** | — | lossy |
| **AVIF** | lossless | lossy | lossy | lossless | lossy** | lossy*** | lossy | — |

\* At quality 100 (default), true lossless mode is enabled for WebP and AVIF.

\*\* Alpha channel is removed (composited against background color) since BMP does not support transparency.

\*\*\* GIF is limited to 256 colors. Converting from a higher color depth will reduce colors.

## Dependencies

- **ImageMagick** — Required for all conversions. Supports both v6 (`convert`) and v7 (`magick`).
- **libheif** — Required delegate for HEIC and AVIF support. Install via `brew install libheif` on macOS.
