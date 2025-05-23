mkdir -p build && cd build
cmake .. \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_C_FLAGS="-O3 -mcpu=apple-m1" \
  -DCMAKE_CXX_FLAGS="-O3 -mcpu=apple-m1" \
  -DGGML_USE_METAL=ON
cmake --build . -j$(sysctl -n hw.ncpu)