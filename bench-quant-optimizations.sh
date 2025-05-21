#!/bin/bash
set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Default values
ITERATIONS=1000
VECTOR_SIZE=4096

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    -i|--iterations)
      ITERATIONS="$2"
      shift 2
      ;;
    -n|--vector-size)
      VECTOR_SIZE="$2"
      shift 2
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

echo -e "${GREEN}Building test-q5-q6-performance...${NC}"

# Build the test
mkdir -p build
cd build
cmake -DCMAKE_BUILD_TYPE=Release ..
make -j test-q5-q6-performance

echo -e "${YELLOW}Running benchmark with iterations=$ITERATIONS, vector_size=$VECTOR_SIZE...${NC}"

# Run the benchmark
./bin/test-q5-q6-performance $ITERATIONS $VECTOR_SIZE

echo -e "${GREEN}Benchmark complete!${NC}" 