#!/bin/bash
set -euo pipefail

# ─── Platform Presets ───────────────────────────────────────────────
# Format: "preset-name:WIDTH:HEIGHT:CATEGORY"
PRESETS=(
  # Web / SEO
  "og-image:2400:1260:web"
  "blog-cover:2400:1260:web"
  "notion-cover:1500:600:web"
  # Chrome Extension
  "chrome-screenshot:1280:800:chrome"
  "chrome-small-promo:1400:560:chrome"
  "chrome-marquee-promo:440:280:chrome"
  # Ads
  "feed-ad:1200:628:ads"
  "post-ad:1200:1200:ads"
  # Play Store
  "play-icon:512:512:playstore"
  "play-feature:1024:500:playstore"
  "play-screenshot-5:1080:1920:playstore"
  "play-screenshot-6:1440:2880:playstore"
  # App Store
  "appstore-iphone-15-pro-max:1284:2778:appstore"
  "appstore-iphone-14-plus:1242:2688:appstore"
  "appstore-iphone-14-pro:1179:2556:appstore"
  "appstore-iphone-14:1170:2532:appstore"
  "appstore-ipad-pro:2048:2732:appstore"
  "appstore-mac:2880:1800:appstore"
  "appstore-watch-ultra:410:502:appstore"
  "appstore-watch-series:396:484:appstore"
  # YouTube
  "youtube-profile:800:800:youtube"
  "youtube-cover:2560:1440:youtube"
  "youtube-thumbnail:1280:720:youtube"
  # TikTok
  "tiktok-profile:720:720:tiktok"
  "tiktok-video:1080:1920:tiktok"
  "tiktok-image-ad:1200:628:tiktok"
  "tiktok-square-ad:640:640:tiktok"
  # Pinterest
  "pinterest-profile:165:165:pinterest"
  "pinterest-board-cover:800:450:pinterest"
  "pinterest-square:1000:1000:pinterest"
  "pinterest-medium:1000:1500:pinterest"
  "pinterest-long:1000:2100:pinterest"
  # Substack
  "substack-featured:1456:1048:substack"
  "substack-logo:256:256:substack"
  "substack-email-banner:1100:220:substack"
  "substack-social:1456:1048:substack"
  "substack-cover:600:600:substack"
  # Threads
  "threads-profile:320:320:threads"
  "threads-square:1080:1080:threads"
  "threads-carousel:1080:1440:threads"
  # Instagram
  "instagram-feed-square:1080:1080:instagram"
  "instagram-feed-portrait:1080:1350:instagram"
  "instagram-stories:1080:1920:instagram"
  "instagram-reels:1080:1920:instagram"
  # Twitter
  "twitter-one-image:2400:1350:twitter"
  "twitter-two-images:2800:3200:twitter"
  "twitter-cover-photo:2400:800:twitter"
  "twitter-og:2400:1260:twitter"
  # Dribbble
  "dribbble-shot:2800:2100:dribbble"
  # Bluesky
  "bluesky-post:2400:1400:bluesky"
  "bluesky-cover:2000:600:bluesky"
  "bluesky-cover-mobile:1170:450:bluesky"
  # Product Hunt
  "producthunt-gallery:2540:1520:producthunt"
  "producthunt-thumbnail:240:240:producthunt"
  # LinkedIn
  "linkedin-feed:1080:1080:linkedin"
  "linkedin-cover-business:2256:382:linkedin"
  "linkedin-cover-personal:1584:396:linkedin"
  "linkedin-stories:1080:1920:linkedin"
  # Facebook
  "facebook-news-feed:1200:1200:facebook"
  "facebook-stories:1080:1920:facebook"
  "facebook-cover-photo:1660:624:facebook"
  "facebook-og:2400:1260:facebook"
)

# ─── Dependency Check ──────────────────────────────────────────────

check_magick() {
  if command -v magick &> /dev/null; then
    MAGICK_CMD="magick"
  elif command -v convert &> /dev/null; then
    MAGICK_CMD="convert"
  else
    echo "Error: ImageMagick is not installed." >&2
    echo "Install it with: brew install imagemagick" >&2
    exit 1
  fi
}

# ─── Helpers ────────────────────────────────────────────────────────

usage() {
  cat <<'EOF'
Usage: resize.sh <input-image> [OPTIONS]
       resize.sh --list

Options:
  --platform NAME   Generate for a specific preset
  --all             Generate for all presets
  --category CAT    Generate for all presets in a category
  --output DIR      Output directory (default: ./resized/)
  --fit             Fit inside target with padding (instead of cover-crop)
  --pad-color HEX   Padding color for --fit mode (default: FFFFFF)
  --quality N       Output quality 1-100 (default: 92)
  --list            List all presets and exit

Categories: web, chrome, ads, playstore, appstore, youtube, tiktok, pinterest, substack, threads, instagram, twitter, dribbble, bluesky, producthunt, linkedin, facebook
EOF
  exit 0
}

list_presets() {
  local current_cat=""
  for entry in "${PRESETS[@]}"; do
    IFS=':' read -r name w h cat <<< "$entry"
    if [[ "$cat" != "$current_cat" ]]; then
      current_cat="$cat"
      echo ""
      echo "[$cat]"
    fi
    printf "  %-35s %s x %s px\n" "$name" "$w" "$h"
  done
  echo ""
  exit 0
}

get_preset() {
  local target="$1"
  for entry in "${PRESETS[@]}"; do
    IFS=':' read -r name w h cat <<< "$entry"
    if [[ "$name" == "$target" ]]; then
      echo "$w:$h"
      return 0
    fi
  done
  echo "Error: unknown preset '$target'" >&2
  echo "Run with --list to see available presets." >&2
  exit 1
}

get_presets_by_category() {
  local target_cat="$1"
  local found=0
  for entry in "${PRESETS[@]}"; do
    IFS=':' read -r name w h cat <<< "$entry"
    if [[ "$cat" == "$target_cat" ]]; then
      echo "$name"
      found=1
    fi
  done
  if [[ $found -eq 0 ]]; then
    echo "Error: unknown category '$target_cat'" >&2
    echo "Valid categories: web, chrome, ads, playstore, appstore, youtube, tiktok, pinterest, substack, threads, instagram, twitter, dribbble, bluesky, producthunt, linkedin, facebook" >&2
    exit 1
  fi
}

resize_image() {
  local input="$1"
  local preset_name="$2"
  local target_w="$3"
  local target_h="$4"
  local outdir="$5"
  local fit_mode="$6"
  local pad_color="$7"
  local quality="$8"

  local ext="${input##*.}"
  ext=$(echo "$ext" | tr '[:upper:]' '[:lower:]')
  local output="${outdir}/${preset_name}.${ext}"

  if [[ "$fit_mode" == "true" ]]; then
    # ── Fit mode: scale to fit inside target, pad with solid color ──
    # -resize WxH: scales to fit within box, maintaining aspect ratio
    # -gravity center: centers the image on the padded canvas
    # -extent WxH: pads to exact target dimensions
    $MAGICK_CMD "$input" \
      -resize "${target_w}x${target_h}" \
      -gravity center \
      -background "#${pad_color}" \
      -extent "${target_w}x${target_h}" \
      -quality "$quality" \
      "$output"
  else
    # ── Cover-crop mode: scale to cover target, center-crop ──
    # -resize WxH^: scales so smallest dimension matches (covers the box)
    # -gravity center -extent WxH: center-crops to exact dimensions
    $MAGICK_CMD "$input" \
      -resize "${target_w}x${target_h}^" \
      -gravity center \
      -extent "${target_w}x${target_h}" \
      -quality "$quality" \
      "$output"
  fi

  echo "  Created: $output (${target_w}x${target_h})"
}

# ─── Parse Arguments ────────────────────────────────────────────────

INPUT=""
PLATFORM=""
CATEGORY=""
ALL=false
OUTPUT="./resized"
FIT=false
PAD_COLOR="FFFFFF"
QUALITY=92

# Handle --list with no input
if [[ "${1:-}" == "--list" ]]; then
  list_presets
fi

if [[ $# -lt 1 ]]; then
  usage
fi

INPUT="$1"
shift

while [[ $# -gt 0 ]]; do
  case "$1" in
    --platform)   PLATFORM="$2"; shift 2 ;;
    --all)        ALL=true; shift ;;
    --category)   CATEGORY="$2"; shift 2 ;;
    --output)     OUTPUT="$2"; shift 2 ;;
    --fit)        FIT=true; shift ;;
    --pad-color)  PAD_COLOR="$2"; shift 2 ;;
    --quality)    QUALITY="$2"; shift 2 ;;
    --list)       list_presets ;;
    --help|-h)    usage ;;
    *)            echo "Unknown option: $1" >&2; usage ;;
  esac
done

# Validate input
if [[ ! -f "$INPUT" ]]; then
  echo "Error: input file '$INPUT' not found." >&2
  exit 1
fi

if [[ "$ALL" == "false" && -z "$PLATFORM" && -z "$CATEGORY" ]]; then
  echo "Error: specify --platform, --category, or --all." >&2
  echo "Run with --list to see available presets." >&2
  exit 1
fi

# Check for ImageMagick
check_magick

# Create output directory
mkdir -p "$OUTPUT"

# ─── Execute ────────────────────────────────────────────────────────

targets=()

if [[ "$ALL" == "true" ]]; then
  for entry in "${PRESETS[@]}"; do
    IFS=':' read -r name _ _ _ <<< "$entry"
    targets+=("$name")
  done
elif [[ -n "$CATEGORY" ]]; then
  while IFS= read -r name; do
    targets+=("$name")
  done < <(get_presets_by_category "$CATEGORY")
else
  targets+=("$PLATFORM")
fi

echo "Resizing $(basename "$INPUT") → ${#targets[@]} preset(s)..."
echo ""

for preset_name in "${targets[@]}"; do
  dims=$(get_preset "$preset_name")
  IFS=':' read -r tw th <<< "$dims"
  resize_image "$INPUT" "$preset_name" "$tw" "$th" "$OUTPUT" "$FIT" "$PAD_COLOR" "$QUALITY"
done

echo ""
echo "Done! ${#targets[@]} image(s) saved to $OUTPUT/"
