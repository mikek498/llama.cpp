# llama.cpp on Apple M1/M2: Setup and Usage Guide

This document provides detailed instructions for setting up and using llama.cpp with our optimizations on Apple M1/M2 processors.

## Prerequisites

- Apple Silicon Mac (M1, M2, or M3 chip)
- macOS 12.0 or later
- Xcode Command Line Tools
- CMake 3.24 or newer
- Python 3.8+ (for benchmark scripts)

## Installation

### Step 1: Install Required Tools

```bash
# Install Xcode Command Line Tools
xcode-select --install

# Install CMake (via Homebrew)
brew install cmake

# Install Python dependencies for benchmark scripts
pip3 install numpy matplotlib
```

### Step 2: Clone Repository and Apply Optimizations

```bash
# Clone llama.cpp repository
git clone https://github.com/ggml-org/llama.cpp
cd llama.cpp

# Apply M1 optimization patch
patch -p1 < /path/to/m1_optimized_metal.patch
```

### Step 3: Build with Optimized Settings

```bash
# Option 1: Use the provided optimization script
bash /path/to/optimize_for_m1.sh

# Option 2: Build manually with optimized parameters
mkdir -p build_m1 && cd build_m1
cmake .. \
    -DCMAKE_BUILD_TYPE=Release \
    -DGGML_METAL=ON \
    -DGGML_METAL_NDEBUG=ON \
    -DGGML_METAL_EMBED_LIBRARY=ON \
    -DGGML_ACCELERATE=ON \
    -DGGML_NATIVE=ON \
    -DGGML_LTO=ON \
    -DGGML_METAL_USE_BF16=ON
make -j$(sysctl -n hw.ncpu)
```

## Downloading Models

You'll need a GGUF format model to use with llama.cpp:

```bash
# Option 1: Use the llama.cpp download script for popular models
python3 scripts/convert.py --outfile models/llama-2-7b-chat.gguf --outtype q4_k

# Option 2: Download from Hugging Face
# Visit https://huggingface.co/TheBloke for GGUF models
```

## Basic Usage

### Running Inference

```bash
# Basic text generation
./main \
    -m models/your-model.gguf \
    -p "Once upon a time" \
    -n 128 \
    --metal

# Interactive chat mode
./main \
    -m models/your-model.gguf \
    -i \
    --metal \
    --color
```

### Optimized Command for M1 Macs

```bash
# Balanced performance for base M1
./main \
    -m models/your-model.gguf \
    -ngl 100 \
    -t 4 \
    -b 512 \
    -c 2048 \
    --metal

# For M1 Pro/Max (adjust thread count)
./main \
    -m models/your-model.gguf \
    -ngl 100 \
    -t 8 \
    -b 1024 \
    -c 2048 \
    --metal
```

## Parameter Explanation

- `-m PATH`: Model path
- `-p PROMPT`: Input prompt
- `-n N`: Number of tokens to predict
- `-t N`: Number of threads to use during computation
- `-b N`: Batch size for prompt processing
- `-c N`: Size of the prompt context
- `-ngl N`: Number of layers to offload to GPU (0-100%)
- `--metal`: Use Metal for GPU acceleration
- `--mlock`: Force system to keep model in RAM
- `--mtest`: Compute maximum memory usage
- `-i`: Interactive mode

## Finding Optimal Settings

### Using the Benchmark Script

```bash
# Run comprehensive benchmark
python3 /path/to/m1_inference_benchmark.py \
    --model models/your-model.gguf \
    --all \
    --plot

# Compare performance with original version
python3 /path/to/llama_m1_benchmark.py \
    --original /path/to/original/main \
    --optimized ./main \
    --model models/your-model.gguf \
    --runs 5
```

### Guidelines for Different M1 Models

#### Base M1 (8 GPU cores)

```bash
./main -m models/your-model.gguf -ngl 100 -t 4 -b 512 -c 2048 --metal
```

#### M1 Pro (14/16 GPU cores)

```bash
./main -m models/your-model.gguf -ngl 100 -t 8 -b 1024 -c 2048 --metal
```

#### M1 Max (24/32 GPU cores)

```bash
./main -m models/your-model.gguf -ngl 100 -t 10 -b 1536 -c 2048 --metal
```

#### M1 Ultra (48/64 GPU cores)

```bash
./main -m models/your-model.gguf -ngl 100 -t 16 -b 2048 -c 4096 --metal
```

## Memory Considerations

### Memory Usage by Model Size

| Model Size | Quantization | Approx. Memory Usage |
|------------|--------------|----------------------|
| 7B         | Q4_K_M       | ~4 GB                |
| 13B        | Q4_K_M       | ~8 GB                |
| 33B        | Q4_K_M       | ~20 GB               |
| 70B        | Q4_K_M       | ~42 GB               |

### Memory Optimization Tips

- For 8GB M1 Macs, stick to 7B models with Q4_K or Q2_K quantization
- For 16GB M1 Macs, 13B models work well with Q4_K quantization
- For 32GB+ M1 Macs, 33B models are feasible with proper quantization
- To run larger models on smaller memory, reduce context size (`-c` parameter)
- Use `--mtest` to check memory requirements before running a model

## Troubleshooting

### Common Issues and Solutions

#### "Error creating Metal device"

```
Check that your macOS is updated to the latest version.
If using a very old macOS, try: ./main -ngl 0
```

#### "Metal GPU Family not supported"

```
Your Mac might be using an older GPU.
Try: cmake .. -DGGML_METAL=OFF
```

#### Slow performance despite optimizations

```
Check Activity Monitor to ensure the process is actually using the GPU.
Try reducing batch size (-b parameter).
Ensure no other GPU-intensive tasks are running.
```

#### Crashes with large models

```
Reduce context size (-c parameter).
Try a more aggressive quantization (Q3_K or Q2_K).
Check if swap is being used heavily.
```

## Advanced Usage

### Server Mode

```bash
# Run as a local server
./server \
    -m models/your-model.gguf \
    --host 127.0.0.1 \
    --port 8080 \
    -t 4 \
    -c 2048 \
    --metal
```

### Quantization

```bash
# Quantize a model to Q4_K format optimized for M1
./quantize \
    models/original-model.gguf \
    models/quantized-model.q4_k.gguf \
    q4_k
```

### Embedding Generation

```bash
# Generate embeddings from text
./embedding \
    -m models/your-model.gguf \
    -p "Your text here" \
    --metal
```

## Contributing Optimizations

If you discover additional optimizations for M1/M2 processors, please consider contributing:

1. Benchmark your changes using the provided scripts
2. Document the technical reasoning behind the optimization
3. Create a pull request with clear before/after performance metrics
