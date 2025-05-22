#!/usr/bin/env bash
# fix_metal_half_casts.sh
# Undo the forced simdgroup<half> overload and insert the two explicit casts.
set -euo pipefail

echo "🔄 Reverting forced <half> overloads in ggml-metal.metal…"
perl -0777 -i.bak -pe '
  # 1) Remove any simdgroup_load<half>(  → simdgroup_load(
  s/simdgroup_load<half>\(/simdgroup_load\(/g;

  # 2) Remove any simdgroup_store<half>( → simdgroup_store(
  s/simdgroup_store<half>\(/simdgroup_store\(/g;

  # 3) Cast -__FLT_MAX__/2 to half everywhere
  s/(-__FLT_MAX__\/2)/static_cast<half>(-__FLT_MAX__\/2)/g;

  # 4) Fix the make_filled_simdgroup_matrix zero initializer
  s/make_filled_simdgroup_matrix<half,\s*8>\(0\.f\)/make_filled_simdgroup_matrix<half,8>(half(0))/g;
' ggml-metal.metal && echo "  → ggml-metal.metal updated (backup: ggml-metal.metal.bak)."

echo "✅ Done. Please rebuild and test again."
