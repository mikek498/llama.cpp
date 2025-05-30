rm -rf build
cmake -B build \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_C_FLAGS="-O3 -mcpu=apple-m1" \
  -DCMAKE_CXX_FLAGS="-O3 -mcpu=apple-m1" \
  -DGGML_USE_METAL=ON \
  -DGGML_USE_ACCELERATE=ON \

cmake --build build -t llama-cli -t llama-bench -j 20
