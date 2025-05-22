#!/usr/bin/env bash
# apply_m1_max_ultra2_optimizations.sh
# Ultra‐aggressive Metal optimizations for Phi on Mac M1 Max, with
# explicit casts & simdgroup load/store fixes.
set -euo pipefail

echo "🔧 Patching ggml-metal-impl.h..."
perl -0777 -i.bak -pe '
  # Quant blocks → DEFAULT_N, Apple/arm64 = 8/4
  s{#define N_R0_Q(\d+)_(\d+)\s+4\n#define N_SG_Q\1_\2\s+2}{
#if defined(__APPLE__) && defined(__arm64__)
#define DEFAULT_N_R0 8
#define DEFAULT_N_SG 4
#else
#define DEFAULT_N_R0 4
#define DEFAULT_N_SG 2
#endif
#define N_R0_Q\1_\2 DEFAULT_N_R0
#define N_SG_Q\1_\2 DEFAULT_N_SG
}mg;
' ggml-metal-impl.h && echo "  → ggml-metal-impl.h patched."

echo "🔧 Patching ggml-metal.m..."
perl -0777 -i.bak -pe '
  # Heap/storage private
  s/newBufferWithLength:size_aligned options:MTLResourceStorageModeShared offset:heap->offs/newBufferWithLength:size_aligned options:MTLResourceStorageModePrivate offset:heap->offs/g;
  # Fast math
  s/options\.fastMathEnabled\s*=\s*false/options.fastMathEnabled = true/g;
  # Dynamic threadgroup‐memory up to 32 KB
  s{\[encoder setThreadgroupMemoryLength:\s*\d+\s*atIndex:0\];}{\
size_t maxSM = device.maxThreadgroupMemoryLength;\
size_t smem  = MIN((size_t)32768, maxSM);\
[encoder setThreadgroupMemoryLength:smem atIndex:0];\
}g;
' ggml-metal.m && echo "  → ggml-metal.m patched."

echo "🔧 Patching ggml-metal.metal for half‐casts & simdgroup fixes..."
perl -0777 -i.bak -pe '
  # 1) Cast the -__FLT_MAX__/2 to half
  s/(-__FLT_MAX__\/2)/static_cast<half>(-__FLT_MAX__\/2)/g;

  # 2) Fix make_filled_simdgroup_matrix<half,8>(0.f)
  s/make_filled_simdgroup_matrix<half,\s*8>\(0\.f\)/make_filled_simdgroup_matrix<half,8>(half(0))/g;

  # 3) Force half‐overload on simdgroup_load/store
  s/\bsimdgroup_load\(/simdgroup_load<half>(/g;
  s/\bsimdgroup_store\(/simdgroup_store<half>(/g;

  # 4) Remove duplicate explicit instantiations of kernel_cpy<half,half>
  s{template\s*\[\[host_name\("kernel_cpy_[^"]+"\)\]\]\s*kernel[^\n]*kernel_cpy<half,\s*half>;\n}{}g;

  # (keep your previous specialized_constants & threadgroup_size insertions here)
  s{(using namespace metal;\s*)}{$1#pragma clang specialized_constant BLOCK_M = 256;\n#pragma clang specialized_constant BLOCK_N = 32;\n#pragma clang specialized_constant VEC_W   = 4;\n}m;
  s{^(\s*kernel void\s+\w+\s*\([^)]*\))\s*\{}{$1 [[threadgroup_size(BLOCK_M, BLOCK_N, 1)]] \{}gm;
' ggml-metal.metal && echo "  → ggml-metal.metal patched."

echo "✅ All patches applied—backups saved alongside with `.bak` extensions."
