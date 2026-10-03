#!/usr/bin/env bash
# Regenerate the left-blurred lock-screen wallpaper from the current wallpaper.
# Left 35% is blurred, fading smoothly into the sharp right 65% (no hard edge).
set -euo pipefail

WALL="${1:-$HOME/Pictures/wallpapers/current}"
OUT="$HOME/.cache/wal/lock-background.png"
BLUR_PCT=35     # % of width blurred (the fade is centered here)
SIGMA=0x16      # blur strength (higher = more frosted)
FADE=120        # transition band width in px (larger = softer fade)

[[ -f "$WALL" ]] || { echo "wallpaper not found: $WALL" >&2; exit 1; }
command -v magick >/dev/null || { echo "magick (ImageMagick 7) is required" >&2; exit 1; }

WIDTH=$(magick "$WALL" -format "%w" info:)
HEIGHT=$(magick "$WALL" -format "%h" info:)
X=$((WIDTH * BLUR_PCT / 100))   # blur boundary (fade centered here)
S=$((FADE / 4))                 # sigmoid softness; fade spans ~4*S = FADE px
[[ $S -ge 1 ]] || S=1

# Build three layers in one pass:
#   0 = sharp original
#   1 = blurred copy
#   2 = horizontal sigmoid mask (0 = blurred, 1 = sharp), stretched to full height
#   3 = sharp original with the mask as its alpha channel
#   final = sharp-masked composited over the blurred copy
magick "$WALL" \
    \( -clone 0 -blur "$SIGMA" \) \
    \( -size "${WIDTH}x1" xc:black -fx "1/(1+exp(-(i-${X})/${S}))" -resize "${WIDTH}x${HEIGHT}!" \) \
    \( -clone 0 -clone 2 -alpha off -compose CopyOpacity -composite \) \
    -delete 0,2 \
    -compose over -composite \
    "$OUT"

echo "wrote $OUT"
