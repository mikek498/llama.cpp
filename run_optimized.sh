#!/bin/bash
#
# Auto-detecting M1/M2 variant and running llama.cpp with optimized settings
# This script automatically detects your Apple Silicon variant and applies
# the best settings for optimal performance.

# Function to detect Apple Silicon type
detect_apple_silicon() {
    # Check if we're on Apple Silicon at all
    if [[ $(uname -m) != "arm64" ]]; then
        echo "ERROR: This script is only for Apple Silicon Macs (M1/M2/M3)"
        exit 1
    fi
    
    # Get CPU information
    CPU_INFO=$(sysctl -n machdep.cpu.brand_string)
    
    # Get performance core count
    PERF_CORES=$(sysctl -n hw.perflevel0.logicalcpu 2>/dev/null || echo 4)
    
    # Get total memory
    TOTAL_MEM_GB=$(( $(sysctl -n hw.memsize) / 1024 / 1024 / 1024 ))
    
    # Detect GPU info using system_profiler
    # Note: This requires admin privileges on some systems
    GPU_INFO=$(system_profiler SPDisplaysDataType 2>/dev/null | grep "Chipset Model:" | awk -F': ' '{print $2}' || echo "Apple M1")
    
    # Try to estimate GPU core count from model name
    # This is an approximation as system_profiler doesn't directly show GPU core count
    if [[ $GPU_INFO == *"M1 Ultra"* ]]; then
        GPU_CORES=48
        SILICON_TYPE="M1 Ultra"
    elif [[ $GPU_INFO == *"M1 Max"* ]]; then
        GPU_CORES=32
        SILICON_TYPE="M1 Max"
    elif [[ $GPU_INFO == *"M1 Pro"* ]]; then
        GPU_CORES=16
        SILICON_TYPE="M1 Pro"
    elif [[ $GPU_INFO == *"M2 Ultra"* ]]; then
        GPU_CORES=76
        SILICON_TYPE="M2 Ultra"
    elif [[ $GPU_INFO == *"M2 Max"* ]]; then
        GPU_CORES=38
        SILICON_TYPE="M2 Max"
    elif [[ $GPU_INFO == *"M2 Pro"* ]]; then
        GPU_CORES=19
        SILICON_TYPE="M2 Pro"
    elif [[ $GPU_INFO == *"M2"* ]]; then
        GPU_CORES=10
        SILICON_TYPE="M2"
    elif [[ $GPU_INFO == *"M3 Ultra"* ]]; then
        GPU_CORES=76
        SILICON_TYPE="M3 Ultra"
    elif [[ $GPU_INFO == *"M3 Max"* ]]; then
        GPU_CORES=40
        SILICON_TYPE="M3 Max"
    elif [[ $GPU_INFO == *"M3 Pro"* ]]; then
        GPU_CORES=18
        SILICON_TYPE="M3 Pro"
    elif [[ $GPU_INFO == *"M3"* ]]; then
        GPU_CORES=10
        SILICON_TYPE="M3"
    else
        GPU_CORES=8
        SILICON_TYPE="M1"
    fi
    
    echo "Detected $SILICON_TYPE with approximately $GPU_CORES GPU cores and $TOTAL_MEM_GB GB RAM"
    echo "Performance CPU cores: $PERF_CORES"
}

# Function to determine optimal parameters based on detected hardware
get_optimal_params() {
    # Default parameters
    THREADS=$PERF_CORES
    BATCH_SIZE=512
    CONTEXT_SIZE=2048
    
    # Adjust based on GPU cores (more GPU cores = larger batch size)
    if [[ $GPU_CORES -ge 32 ]]; then
        BATCH_SIZE=2048
        CONTEXT_SIZE=4096
    elif [[ $GPU_CORES -ge 16 ]]; then
        BATCH_SIZE=1024
        CONTEXT_SIZE=2048
    elif [[ $GPU_CORES -ge 10 ]]; then
        BATCH_SIZE=768
        CONTEXT_SIZE=2048
    else
        BATCH_SIZE=512
        CONTEXT_SIZE=2048
    fi
    
    # Adjust batch size based on available memory to avoid OOM
    if [[ $TOTAL_MEM_GB -le 8 ]]; then
        BATCH_SIZE=$(( BATCH_SIZE / 2 ))
        CONTEXT_SIZE=1024
    elif [[ $TOTAL_MEM_GB -ge 32 ]]; then
        CONTEXT_SIZE=4096
    fi
    
    # For larger models, further adjust batch size
    if [[ $MODEL_SIZE == "13B" ]]; then
        BATCH_SIZE=$(( BATCH_SIZE * 2 / 3 ))
    elif [[ $MODEL_SIZE == "33B" || $MODEL_SIZE == "34B" || $MODEL_SIZE == "30B" ]]; then
        BATCH_SIZE=$(( BATCH_SIZE / 2 ))
        CONTEXT_SIZE=$(( CONTEXT_SIZE * 2 / 3 ))
    elif [[ $MODEL_SIZE == "70B" || $MODEL_SIZE == "65B" ]]; then
        BATCH_SIZE=$(( BATCH_SIZE / 3 ))
        CONTEXT_SIZE=$(( CONTEXT_SIZE / 2 ))
    fi
    
    echo "Optimal parameters for $SILICON_TYPE with $MODEL_SIZE model:"
    echo "  - Threads: $THREADS"
    echo "  - Batch size: $BATCH_SIZE"
    echo "  - Context size: $CONTEXT_SIZE"
}

# Function to detect model size from filename
detect_model_size() {
    if [[ $MODEL_PATH == *"7b"* ]]; then
        MODEL_SIZE="7B"
    elif [[ $MODEL_PATH == *"13b"* ]]; then
        MODEL_SIZE="13B"
    elif [[ $MODEL_PATH == *"33b"* || $MODEL_PATH == *"34b"* || $MODEL_PATH == *"30b"* ]]; then
        MODEL_SIZE="33B"
    elif [[ $MODEL_PATH == *"70b"* || $MODEL_PATH == *"65b"* ]]; then
        MODEL_SIZE="70B"
    else
        # Default to 7B if we can't detect
        MODEL_SIZE="7B"
        echo "Could not detect model size from filename. Assuming 7B model."
    fi
    
    echo "Detected model size: $MODEL_SIZE"
}

# Parse command line arguments
show_help() {
    echo "Usage: $0 -m MODEL_PATH [options]"
    echo ""
    echo "Required arguments:"
    echo "  -m, --model MODEL_PATH     Path to the GGUF model file"
    echo ""
    echo "Optional arguments:"
    echo "  -p, --prompt PROMPT        Initial prompt (default: none)"
    echo "  -i, --interactive          Enable interactive mode (default: false)"
    echo "  -s, --size SIZE            Model size: 7B, 13B, 33B, 70B (auto-detected from filename if not specified)"
    echo "  -t, --threads N            Number of threads to use (default: auto-detected)"
    echo "  -b, --batch N              Batch size (default: auto-configured based on hardware)"
    echo "  -c, --context N            Context size (default: auto-configured based on hardware)"
    echo "  -h, --help                 Show this help message"
    echo ""
    echo "Example:"
    echo "  $0 -m models/llama-2-7b-chat.gguf -i"
    exit 1
}

# Default values
MODEL_PATH=""
PROMPT=""
INTERACTIVE=false
SPECIFY_SIZE=""
SPECIFY_THREADS=0
SPECIFY_BATCH=0
SPECIFY_CONTEXT=0

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -m|--model)
            MODEL_PATH="$2"
            shift 2
            ;;
        -p|--prompt)
            PROMPT="$2"
            shift 2
            ;;
        -i|--interactive)
            INTERACTIVE=true
            shift
            ;;
        -s|--size)
            SPECIFY_SIZE="$2"
            shift 2
            ;;
        -t|--threads)
            SPECIFY_THREADS="$2"
            shift 2
            ;;
        -b|--batch)
            SPECIFY_BATCH="$2"
            shift 2
            ;;
        -c|--context)
            SPECIFY_CONTEXT="$2"
            shift 2
            ;;
        -h|--help)
            show_help
            ;;
        *)
            echo "Unknown option: $1"
            show_help
            ;;
    esac
done

# Check required arguments
if [[ -z "$MODEL_PATH" ]]; then
    echo "Error: Model path is required"
    show_help
fi

# Check if model exists
if [[ ! -f "$MODEL_PATH" ]]; then
    echo "Error: Model file not found: $MODEL_PATH"
    exit 1
fi

# Detect hardware
detect_apple_silicon

# Detect model size from filename or use specified size
if [[ -n "$SPECIFY_SIZE" ]]; then
    MODEL_SIZE="$SPECIFY_SIZE"
    echo "Using specified model size: $MODEL_SIZE"
else
    detect_model_size
fi

# Get optimal parameters
get_optimal_params

# Override with user-specified values if provided
if [[ $SPECIFY_THREADS -gt 0 ]]; then
    THREADS=$SPECIFY_THREADS
    echo "Using user-specified thread count: $THREADS"
fi

if [[ $SPECIFY_BATCH -gt 0 ]]; then
    BATCH_SIZE=$SPECIFY_BATCH
    echo "Using user-specified batch size: $BATCH_SIZE"
fi

if [[ $SPECIFY_CONTEXT -gt 0 ]]; then
    CONTEXT_SIZE=$SPECIFY_CONTEXT
    echo "Using user-specified context size: $CONTEXT_SIZE"
fi

# Build command
CMD="./main -m \"$MODEL_PATH\" -t $THREADS -b $BATCH_SIZE -c $CONTEXT_SIZE -ngl 100 --metal"

if [[ -n "$PROMPT" ]]; then
    CMD="$CMD -p \"$PROMPT\""
fi

if [[ "$INTERACTIVE" = true ]]; then
    CMD="$CMD -i --color"
fi

# Print command
echo ""
echo "Running with command:"
echo "$CMD"
echo ""

# Execute command
eval $CMD
