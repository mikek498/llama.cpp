#!/usr/bin/env bash
# apply_m1_max_optimizations.sh
# In-place Metal optimizations for Phi on Mac M1 Max.
set -euo pipefail

echo "🔧 Patching ggml-metal-impl.h..."
perl -0777 -i.bak -pe '
  s{#define N_R0_Q4_0 4\n#define N_SG_Q4_0 2}{#if defined(__APPLE__) && defined(__arm64__)\n#define DEFAULT_N_R0 8\n#define DEFAULT_N_SG 4\n#else\n#define DEFAULT_N_R0 4\n#define DEFAULT_N_SG 2\n#endif\n#define N_R0_Q4_0 DEFAULT_N_R0\n#define N_SG_Q4_0 DEFAULT_N_SG}g;
  s{#define N_R0_Q4_1 4\n#define N_SG_Q4_1 2}{#if defined(__APPLE__) && defined(__arm64__)\n#define DEFAULT_N_R0 8\n#define DEFAULT_N_SG 4\n#else\n#define DEFAULT_N_R0 4\n#define DEFAULT_N_SG 2\n#endif\n#define N_R0_Q4_1 DEFAULT_N_R0\n#define N_SG_Q4_1 DEFAULT_N_SG}g;
  s{#define N_R0_Q5_0 4\n#define N_SG_Q5_0 2}{#if defined(__APPLE__) && defined(__arm64__)\n#define DEFAULT_N_R0 8\n#define DEFAULT_N_SG 4\n#else\n#define DEFAULT_N_R0 4\n#define DEFAULT_N_SG 2\n#endif\n#define N_R0_Q5_0 DEFAULT_N_R0\n#define N_SG_Q5_0 DEFAULT_N_SG}g;
  s{#define N_R0_Q5_1 4\n#define N_SG_Q5_1 2}{#if defined(__APPLE__) && defined(__arm64__)\n#define DEFAULT_N_R0 8\n#define DEFAULT_N_SG 4\n#else\n#define DEFAULT_N_R0 4\n#define DEFAULT_N_SG 2\n#endif\n#define N_R0_Q5_1 DEFAULT_N_R0\n#define N_SG_Q5_1 DEFAULT_N_SG}g;
  s{#define N_R0_Q8_0 4\n#define N_SG_Q8_0 2}{#if defined(__APPLE__) && defined(__arm64__)\n#define DEFAULT_N_R0 8\n#define DEFAULT_N_SG 4\n#else\n#define DEFAULT_N_R0 4\n#define DEFAULT_N_SG 2\n#endif\n#define N_R0_Q8_0 DEFAULT_N_R0\n#define N_SG_Q8_0 DEFAULT_N_SG}g;
' ggml-metal-impl.h && echo "  → ggml-metal-impl.h patched."

echo "🔧 Patching ggml-metal.m..."
perl -0777 -i.bak -pe '
  s/newBufferWithLength:size_aligned options:MTLResourceStorageModePrivate offset:heap->offs/newBufferWithLength:size_aligned options:MTLResourceStorageModeShared offset:heap->offs/g;
  s/options\.fastMathEnabled = false/options.fastMathEnabled = true/g;
  s{\[encoder setThreadgroupMemoryLength:8192 atIndex:0\];}{{
      size_t maxSM = device.maxThreadgroupMemoryLength;
      size_t smem  = MIN((size_t)32768, maxSM);
      [encoder setThreadgroupMemoryLength:smem atIndex:0];
  }}g;
' ggml-metal.m && echo "  → ggml-metal.m patched."

echo "🔧 Patching ggml-metal.metal..."
perl -0777 -i.bak -pe '
  # Inject specialization constants right after namespace metal;
  s{(using namespace metal;\s*)}{$1#pragma clang specialized_constant DEFAULT_TG_X = 32;\n#pragma clang specialized_constant DEFAULT_TG_Y = 4;\n}m;

  # Add threadgroup_size attribute to every kernel
  s{(kernel void [^(]+\([^)]*\))\s*\{}{$1 [[threadgroup_size(DEFAULT_TG_X, DEFAULT_TG_Y, 1)]] {} }gm;
' ggml-metal.metal && echo "  → ggml-metal.metal patched."

echo "✅ All patches applied. Backups saved with .bak extensions."
