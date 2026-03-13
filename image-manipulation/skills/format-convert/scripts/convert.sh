#!/bin/bash
set -euo pipefail

# ─── Supported Formats ────────────────────────────────────────────
SUPPORTED_FORMATS=("png" "jpg" "jpeg" "webp" "tiff" "tif" "bmp" "gif" "heic" "avif")
LOSSY_FORMATS=("jpg" "jpeg" "webp" "heic" "avif")
NO_ALPHA_FORMATS=("jpg" "jpeg" "bmp")

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
Usage: convert.sh <input> --to FORMAT [OPTIONS]
       convert.sh --batch DIR --to FORMAT [OPTIONS]
       convert.sh --formats

Options:
  --to FORMAT       Target format (png, jpg, webp, tiff, bmp, gif, heic, avif)
  --output DIR      Output directory (default: ./converted/)
  --quality N       Quality for lossy formats 1-100 (default: 100)
  --bg-color HEX    Background color when removing alpha (default: FFFFFF)
  --batch DIR       Convert all supported images in DIR
  --recursive       Include subdirectories in batch mode
  --formats         List supported formats and exit
  --help, -h        Show this help message
EOF
  exit 0
}

list_formats() {
  echo ""
  echo "Supported formats:"
  echo ""
  printf "  %-10s %-12s %-15s\n" "Format" "Quality" "Alpha"
  printf "  %-10s %-12s %-15s\n" "------" "-------" "-----"
  printf "  %-10s %-12s %-15s\n" "PNG"    "lossless"   "yes"
  printf "  %-10s %-12s %-15s\n" "JPG"    "lossy"      "no"
  printf "  %-10s %-12s %-15s\n" "WebP"   "both"       "yes"
  printf "  %-10s %-12s %-15s\n" "TIFF"   "lossless"   "yes"
  printf "  %-10s %-12s %-15s\n" "BMP"    "lossless"   "no"
  printf "  %-10s %-12s %-15s\n" "GIF"    "lossless"   "yes (1-bit)"
  printf "  %-10s %-12s %-15s\n" "HEIC"   "lossy"      "yes"
  printf "  %-10s %-12s %-15s\n" "AVIF"   "both"       "yes"
  echo ""
  exit 0
}

normalize_format() {
  local fmt="$1"
  fmt=$(echo "$fmt" | tr '[:upper:]' '[:lower:]')
  case "$fmt" in
    jpeg) echo "jpg" ;;
    tif)  echo "tiff" ;;
    *)    echo "$fmt" ;;
  esac
}

is_supported_format() {
  local fmt="$1"
  for f in "${SUPPORTED_FORMATS[@]}"; do
    if [[ "$f" == "$fmt" ]]; then
      return 0
    fi
  done
  return 1
}

is_lossy_format() {
  local fmt="$1"
  for f in "${LOSSY_FORMATS[@]}"; do
    if [[ "$f" == "$fmt" ]]; then
      return 0
    fi
  done
  return 1
}

is_no_alpha_format() {
  local fmt="$1"
  for f in "${NO_ALPHA_FORMATS[@]}"; do
    if [[ "$f" == "$fmt" ]]; then
      return 0
    fi
  done
  return 1
}

has_alpha() {
  local input="$1"
  local alpha_flag
  if [[ "$MAGICK_CMD" == "magick" ]]; then
    alpha_flag=$(magick identify -format "%A" "$input" 2>/dev/null || echo "Undefined")
  else
    alpha_flag=$(identify -format "%A" "$input" 2>/dev/null || echo "Undefined")
  fi
  # ImageMagick returns "True", "False", "Undefined", or "Blend"
  if [[ "$alpha_flag" == "True" || "$alpha_flag" == "Blend" ]]; then
    echo "True"
  else
    echo "False"
  fi
}

# ─── Core Conversion ───────────────────────────────────────────────

convert_image() {
  local input="$1"
  local target_format="$2"
  local outdir="$3"
  local quality="$4"
  local bg_color="$5"

  local basename_no_ext
  basename_no_ext=$(basename "${input%.*}")
  local src_ext="${input##*.}"
  src_ext=$(echo "$src_ext" | tr '[:upper:]' '[:lower:]')
  local src_norm
  src_norm=$(normalize_format "$src_ext")
  local target_ext
  target_ext=$(normalize_format "$target_format")

  # Skip if source is already the target format
  if [[ "$src_norm" == "$target_ext" ]]; then
    echo "  Skipped: $(basename "$input") (already $target_ext)"
    return 0
  fi

  local output="${outdir}/${basename_no_ext}.${target_ext}"

  # Build ImageMagick command arguments
  local -a cmd_args=("$input")

  # Handle alpha → no-alpha conversion
  local src_has_alpha
  src_has_alpha=$(has_alpha "$input")
  if [[ "$src_has_alpha" == "True" ]] && is_no_alpha_format "$target_ext"; then
    cmd_args+=(-background "#${bg_color}" -alpha remove -alpha off)
  fi

  # Apply quality settings based on target format
  if [[ "$target_ext" == "png" ]]; then
    # PNG is always lossless; quality 00 = compression level 0, filter 0
    cmd_args+=(-quality 00)
  elif [[ "$target_ext" == "webp" ]]; then
    if [[ "$quality" -eq 100 ]]; then
      cmd_args+=(-define webp:lossless=true)
    else
      cmd_args+=(-quality "$quality")
    fi
  elif [[ "$target_ext" == "avif" ]]; then
    if [[ "$quality" -eq 100 ]]; then
      cmd_args+=(-define heif:lossless=true)
    else
      cmd_args+=(-quality "$quality")
    fi
  elif [[ "$target_ext" == "tiff" ]]; then
    cmd_args+=(-compress None)
  elif is_lossy_format "$target_ext"; then
    cmd_args+=(-quality "$quality")
  fi

  cmd_args+=("$output")

  $MAGICK_CMD "${cmd_args[@]}"

  # Report with dimensions for hook validation
  local dims
  if [[ "$MAGICK_CMD" == "magick" ]]; then
    dims=$(magick identify -format "%wx%h" "$output" 2>/dev/null || echo "unknown")
  else
    dims=$(identify -format "%wx%h" "$output" 2>/dev/null || echo "unknown")
  fi
  echo "  Converted: $output ($src_norm -> $target_ext, ${dims})"
}

# ─── Parse Arguments ────────────────────────────────────────────────

INPUT=""
TARGET_FORMAT=""
OUTPUT="./converted"
QUALITY=100
BG_COLOR="FFFFFF"
BATCH_DIR=""
RECURSIVE=false

# Handle --formats with no other args
if [[ "${1:-}" == "--formats" ]]; then
  list_formats
fi

if [[ $# -lt 1 ]]; then
  usage
fi

# If first arg doesn't start with --, treat as input file
if [[ "${1:0:2}" != "--" ]]; then
  INPUT="$1"
  shift
fi

while [[ $# -gt 0 ]]; do
  case "$1" in
    --to)         TARGET_FORMAT="$2"; shift 2 ;;
    --output)     OUTPUT="$2"; shift 2 ;;
    --quality)    QUALITY="$2"; shift 2 ;;
    --bg-color)   BG_COLOR="$2"; shift 2 ;;
    --batch)      BATCH_DIR="$2"; shift 2 ;;
    --recursive)  RECURSIVE=true; shift ;;
    --formats)    list_formats ;;
    --help|-h)    usage ;;
    *)            echo "Unknown option: $1" >&2; usage ;;
  esac
done

# ─── Validate ───────────────────────────────────────────────────────

if [[ -z "$TARGET_FORMAT" ]]; then
  echo "Error: --to FORMAT is required." >&2
  echo "Run with --formats to see supported formats." >&2
  exit 1
fi

TARGET_FORMAT=$(normalize_format "$TARGET_FORMAT")

if ! is_supported_format "$TARGET_FORMAT"; then
  echo "Error: unsupported format '$TARGET_FORMAT'" >&2
  echo "Run with --formats to see supported formats." >&2
  exit 1
fi

if [[ -n "$BATCH_DIR" && -n "$INPUT" ]]; then
  echo "Error: cannot use both input file and --batch." >&2
  exit 1
fi

if [[ -z "$BATCH_DIR" && -z "$INPUT" ]]; then
  echo "Error: specify an input file or use --batch DIR." >&2
  exit 1
fi

if [[ -n "$INPUT" && ! -f "$INPUT" ]]; then
  echo "Error: input file '$INPUT' not found." >&2
  exit 1
fi

if [[ -n "$BATCH_DIR" && ! -d "$BATCH_DIR" ]]; then
  echo "Error: batch directory '$BATCH_DIR' not found." >&2
  exit 1
fi

if [[ "$QUALITY" -lt 1 || "$QUALITY" -gt 100 ]] 2>/dev/null; then
  echo "Error: quality must be between 1 and 100." >&2
  exit 1
fi

# ─── Execute ────────────────────────────────────────────────────────

check_magick
mkdir -p "$OUTPUT"

if [[ -n "$BATCH_DIR" ]]; then
  # Batch mode
  count=0
  skipped=0

  FIND_ARGS=("$BATCH_DIR")
  if [[ "$RECURSIVE" == "false" ]]; then
    FIND_ARGS+=(-maxdepth 1)
  fi
  FIND_ARGS+=(-type f \()
  FIND_ARGS+=(-iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.webp")
  FIND_ARGS+=(-o -iname "*.tiff" -o -iname "*.tif" -o -iname "*.bmp")
  FIND_ARGS+=(-o -iname "*.gif" -o -iname "*.heic" -o -iname "*.avif")
  FIND_ARGS+=(\))

  echo "Converting images in $(basename "$BATCH_DIR")/ → $TARGET_FORMAT..."
  echo ""

  while IFS= read -r file; do
    result=$(convert_image "$file" "$TARGET_FORMAT" "$OUTPUT" "$QUALITY" "$BG_COLOR")
    echo "$result"
    if echo "$result" | grep -q "Skipped:"; then
      skipped=$((skipped + 1))
    else
      count=$((count + 1))
    fi
  done < <(find "${FIND_ARGS[@]}" 2>/dev/null | sort)

  echo ""
  echo "Done! ${count} image(s) converted, ${skipped} skipped. Output: $OUTPUT/"
else
  # Single file mode
  echo "Converting $(basename "$INPUT") → $TARGET_FORMAT..."
  echo ""

  convert_image "$INPUT" "$TARGET_FORMAT" "$OUTPUT" "$QUALITY" "$BG_COLOR"

  echo ""
  echo "Done! Output: $OUTPUT/"
fi
