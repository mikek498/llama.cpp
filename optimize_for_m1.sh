#!/bin/bash

# Script to optimize llama.cpp for Apple M1 processors
# This script must be run on a Mac with Apple Silicon (M1/M2/M3)

# Exit on error
set -e

# Display optimization banner
echo "======================================================"
echo "     llama.cpp Optimizer for Apple M1 Processors      "
echo "======================================================"

# Check if running on Apple Silicon
if [[ $(uname -m) != "arm64" ]]; then
    echo "Error: This script must be run on Apple Silicon (M1/M2/M3) Mac"
    exit 1
fi

# Get number of performance cores
PERFORMANCE_CORES=$(sysctl -n hw.perflevel0.physicalcpu)
EFFICIENCY_CORES=$(sysctl -n hw.perflevel1.physicalcpu)
TOTAL_CORES=$((PERFORMANCE_CORES + EFFICIENCY_CORES))

echo "Detected Apple Silicon with:"
echo "- $PERFORMANCE_CORES performance cores"
echo "- $EFFICIENCY_CORES efficiency cores"
echo "- $TOTAL_CORES total CPU cores"

# Get GPU core count (this is approximate as there's no direct way)
# This script uses system_profiler which requires admin privileges
GPU_INFO=$(system_profiler SPDisplaysDataType 2>/dev/null | grep "Total Number of Cores" || echo "Unknown")
echo "- GPU: $GPU_INFO"

# Apply the patch for M1 optimizations
echo "Applying M1-specific optimizations..."
cd /app/llama.cpp
patch -p1 < /app/m1_optimized_metal.patch

# Configure and build with optimal settings for M1
echo "Configuring build with M1-optimized settings..."
mkdir -p build_m1
cd build_m1

cmake .. \
    -DCMAKE_BUILD_TYPE=Release \
    -DGGML_METAL=ON \
    -DGGML_METAL_NDEBUG=ON \
    -DGGML_METAL_EMBED_LIBRARY=ON \
    -DGGML_ACCELERATE=ON \
    -DGGML_NATIVE=ON \
    -DGGML_LTO=ON \
    -DGGML_METAL_USE_BF16=ON

# Build with all available cores
echo "Building with $TOTAL_CORES cores..."
make -j$TOTAL_CORES

echo ""
echo "Build complete!"
echo ""
echo "Recommended command for optimal M1 performance:"
echo "./main -m your_model.gguf -ngl 100 -t $PERFORMANCE_CORES -b 512 -c 2048"
echo ""
echo "For larger models, try reducing batch size:"
echo "./main -m your_model.gguf -ngl 100 -t $PERFORMANCE_CORES -b 256 -c 2048"
echo ""
echo "For maximum throughput (may impact latency):"
echo "./main -m your_model.gguf -ngl 100 -t $TOTAL_CORES -b 1024 -c 2048"
echo ""
