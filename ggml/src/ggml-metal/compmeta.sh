#!/usr/bin/env bash
set -euo pipefail

AIR=/tmp/ggml-metal.air
METALLIB=/tmp/ggml-metal.metallib

echo "🧹 Cleaning out old artifacts…"
rm -f "$AIR" "$METALLIB"

# adjust these -I paths so they actually point at ggml-common.h etc.
INCLUDES="-I. -I.."

echo "🔨 Compiling ggml-metal.metal → AIR"
xcrun metal -c \
  -std=metal3.0 \
  -ffast-math \
  -arch arm64 \
  -O3 \
  $INCLUDES \
  ggml-metal.metal \
  -o "$AIR"

echo "✅ AIR built; size: $(stat -f%z "$AIR") bytes"
echo "magic: $(head -c4 "$AIR" | xxd -p)  (should not be '4d544c42')"

echo "📦 Linking AIR → metallib"
xcrun metallib "$AIR" -o "$METALLIB"

echo "✅ Done! Metallib at $METALLIB (size: $(stat -f%z "$METALLIB") bytes)"
