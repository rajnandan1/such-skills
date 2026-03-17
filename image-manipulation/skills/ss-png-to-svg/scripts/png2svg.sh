#!/usr/bin/env bash
# png2svg.sh — Convert a PNG to a smooth, multi-color SVG using potrace
# Usage: png2svg.sh <input.png> [output.svg] [--single-color] [--color "#hex"]
#
# Multi-color mode (default): extracts dominant colors from the PNG, traces each
# color layer separately, and composites them into a single SVG.
# Single-color mode: samples the dominant non-transparent color and traces once.

set -euo pipefail

INPUT=""
OUTPUT=""
SINGLE_COLOR=false
OVERRIDE_COLOR=""
THRESHOLD=50
SMOOTHNESS=1.334  # potrace alphamax — higher = smoother curves
OPTIMIZE=0.5      # potrace opttolerance
TURDSIZE=2        # potrace turdsize — suppress speckles smaller than this

usage() {
  echo "Usage: $0 <input.png> [output.svg] [OPTIONS]"
  echo ""
  echo "Options:"
  echo "  --single-color       Trace as single color (default: multi-color)"
  echo "  --color \"#hex\"       Override fill color"
  echo "  --threshold N        Grayscale threshold 0-100 (default: 50)"
  echo "  --smoothness N       Curve smoothness 0-1.334 (default: 1.334)"
  exit 1
}

# Parse arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    --single-color) SINGLE_COLOR=true; shift ;;
    --color) OVERRIDE_COLOR="$2"; shift 2 ;;
    --threshold) THRESHOLD="$2"; shift 2 ;;
    --smoothness) SMOOTHNESS="$2"; shift 2 ;;
    --help|-h) usage ;;
    -*)
      echo "Unknown option: $1"; usage ;;
    *)
      if [[ -z "$INPUT" ]]; then
        INPUT="$1"
      elif [[ -z "$OUTPUT" ]]; then
        OUTPUT="$1"
      fi
      shift ;;
  esac
done

[[ -z "$INPUT" ]] && { echo "Error: No input file specified"; usage; }
[[ ! -f "$INPUT" ]] && { echo "Error: File not found: $INPUT"; exit 1; }

# Default output name
if [[ -z "$OUTPUT" ]]; then
  OUTPUT="${INPUT%.png}.svg"
fi

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

# Check dependencies
for cmd in magick potrace; do
  if ! command -v "$cmd" &>/dev/null; then
    echo "Error: '$cmd' is not installed."
    [[ "$cmd" == "magick" ]] && echo "Install with: brew install imagemagick"
    [[ "$cmd" == "potrace" ]] && echo "Install with: brew install potrace"
    exit 1
  fi
done

# Get image dimensions
DIMENSIONS=$(magick "$INPUT" -format "%wx%h" info:)
WIDTH=${DIMENSIONS%x*}
HEIGHT=${DIMENSIONS#*x}

# --- Multi-color extraction ---
extract_dominant_colors() {
  # Get up to 8 dominant colors (excluding near-transparent pixels)
  magick "$INPUT" -alpha set -channel A -threshold 50% +channel \
    -colors 8 -depth 8 -format "%c" histogram:info: 2>/dev/null | \
    grep -oE 'srgba?\([0-9]+,[0-9]+,[0-9]+' | \
    sed 's/srgba\{0,1\}(//;s/,/ /g' | \
    while read r g b; do
      # Skip near-white and near-black (likely background)
      if (( r > 240 && g > 240 && b > 240 )); then continue; fi
      if (( r < 15 && g < 15 && b < 15 )); then continue; fi
      printf "#%02x%02x%02x\n" "$r" "$g" "$b"
    done | head -8
}

sample_dominant_color() {
  # Get the single most dominant non-transparent, non-background color
  extract_dominant_colors | head -1
}

trace_single_color() {
  local color="$1"
  local out="$2"

  magick "$INPUT" -alpha remove -alpha off \
    -colorspace Gray -negate -threshold "${THRESHOLD}%" \
    "$TMPDIR/mono.pbm"

  potrace "$TMPDIR/mono.pbm" -s \
    -t "$TURDSIZE" -a "$SMOOTHNESS" -O "$OPTIMIZE" \
    --fillcolor "$color" \
    -o "$out"

  # Remove the background rectangle (M0 path that fills entire viewBox)
  # This is the first <path> that starts with d="M0 and draws a full rectangle
  python3 -c "
import re, sys
with open('$out', 'r') as f:
    content = f.read()
# Remove path elements that start with M0 and draw a full-canvas rectangle
content = re.sub(r'<path[^>]*d=\"M0\s[^\"]*\"[^/]*/>', '', content)
with open('$out', 'w') as f:
    f.write(content)
"
}

trace_color_layer() {
  local color="$1"
  local index="$2"
  local fuzz=20

  # Isolate pixels matching this color
  magick "$INPUT" \
    -alpha set \
    -fuzz "${fuzz}%" -fill white -opaque "$color" \
    -fill black +opaque white \
    -alpha off -colorspace Gray \
    "$TMPDIR/layer_${index}.pbm"

  potrace "$TMPDIR/layer_${index}.pbm" -s \
    -t "$TURDSIZE" -a "$SMOOTHNESS" -O "$OPTIMIZE" \
    --fillcolor "$color" \
    -o "$TMPDIR/layer_${index}.svg"
}

composite_svg_layers() {
  local out="$1"
  shift
  local layers=("$@")

  # Start SVG
  cat > "$out" <<EOF
<?xml version="1.0" standalone="no"?>
<svg xmlns="http://www.w3.org/2000/svg"
 width="${WIDTH}" height="${HEIGHT}" viewBox="0 0 ${WIDTH} ${HEIGHT}"
 preserveAspectRatio="xMidYMid meet">
EOF

  for layer_svg in "${layers[@]}"; do
    [[ ! -f "$layer_svg" ]] && continue
    # Extract paths from each layer SVG, skipping the background rect
    python3 -c "
import re
with open('$layer_svg', 'r') as f:
    content = f.read()
# Find all path elements
paths = re.findall(r'<path[^/]*/>', content)
for p in paths:
    # Skip background rectangle (M0 full-canvas path)
    if re.search(r'd=\"M0\s', p):
        continue
    print(p)
"
  done >> "$out"

  echo "</svg>" >> "$out"
}

# --- Main logic ---

if [[ -n "$OVERRIDE_COLOR" ]]; then
  # User specified a color — single trace with that color
  echo "Tracing with override color: $OVERRIDE_COLOR"
  trace_single_color "$OVERRIDE_COLOR" "$OUTPUT"

elif [[ "$SINGLE_COLOR" == true ]]; then
  COLOR=$(sample_dominant_color)
  if [[ -z "$COLOR" ]]; then
    COLOR="#000000"
    echo "Warning: Could not detect dominant color, using black"
  fi
  echo "Tracing with dominant color: $COLOR"
  trace_single_color "$COLOR" "$OUTPUT"

else
  # Multi-color mode
  COLORS=($(extract_dominant_colors))

  if [[ ${#COLORS[@]} -eq 0 ]]; then
    echo "Warning: No colors detected, falling back to single black trace"
    trace_single_color "#000000" "$OUTPUT"
  elif [[ ${#COLORS[@]} -eq 1 ]]; then
    echo "Single color detected: ${COLORS[0]}"
    trace_single_color "${COLORS[0]}" "$OUTPUT"
  else
    echo "Detected ${#COLORS[@]} colors: ${COLORS[*]}"
    LAYER_FILES=()
    for i in "${!COLORS[@]}"; do
      echo "Tracing layer $((i+1))/${#COLORS[@]}: ${COLORS[$i]}"
      trace_color_layer "${COLORS[$i]}" "$i"
      LAYER_FILES+=("$TMPDIR/layer_${i}.svg")
    done
    composite_svg_layers "$OUTPUT" "${LAYER_FILES[@]}"
  fi
fi

# Report
SIZE=$(ls -lh "$OUTPUT" | awk '{print $5}')
echo ""
echo "Done! SVG written to: $OUTPUT ($SIZE)"
