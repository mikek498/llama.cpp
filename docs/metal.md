# Optimizing Performance on Apple Silicon with Metal

This document provides guidance on optimizing `llama.cpp` performance using the Metal backend on Apple Silicon (M-series chips) and compatible AMD GPUs.

## Standard Metal Backend

By default, `llama.cpp` built with Metal support (`-DLLAMA_METAL=ON` in CMake) uses custom-written Metal compute kernels for its operations. These kernels are optimized for Apple Silicon GPUs and provide good performance across a range of models and tasks.

## Optimizing Performance on Apple Silicon with Accelerate/BNNS

`llama.cpp` can leverage Apple's Accelerate framework, specifically the Basic Neural Network Subroutines (BNNS), to potentially improve performance for certain operations on Apple Silicon GPUs. This is an alternative to some of the default custom Metal kernels.

### A. Introduction

BNNS provides highly optimized, low-level routines for common neural network tasks, tuned by Apple for their hardware. By integrating BNNS, `llama.cpp` can delegate specific computations, such as matrix multiplication and layer normalization, to these specialized routines. This can lead to performance improvements in some scenarios.

### B. How it Works (Briefly)

When BNNS acceleration is enabled (both at compile-time and runtime), the Metal backend will attempt to use BNNS functions for supported operations. If an operation is not supported by the BNNS integration (e.g., a specific data type or a complex operation like FlashAttention) or if BNNS is disabled, the system falls back to the standard custom Metal kernels.

The primary operations currently accelerated by BNNS are:
- FP32 Matrix-Vector Multiplication
- FP16 Matrix-Vector Multiplication (inputs FP16, accumulation/output FP32)
- FP32 Matrix-Matrix Multiplication
- FP16 Matrix-Matrix Multiplication (inputs FP16, accumulation/output FP32)
- FP32 Layer Normalization

### C. Prerequisites

-   **macOS/iOS Version:** BNNS is part of the Accelerate framework, which is available on all modern macOS and iOS versions. Specific BNNS features might require newer OS versions (typically macOS 11.0+ or iOS 14.0+ for the APIs used).
-   **Xcode Version:** A recent version of Xcode (typically 12.0 or newer) that includes the Accelerate framework headers is required for compilation.
-   **Compilation Flag:**
    The BNNS integration code is compiled into `llama.cpp` only if the `GGML_METAL_USE_BNNS=ON` CMake option is set during compilation, in addition to `LLAMA_METAL=ON`.
    Example CMake command:
    ```bash
    cmake .. -DLLAMA_METAL=ON -DGGML_METAL_USE_BNNS=ON
    ```
    If you are manually compiling `ggml-metal.m`, ensure the `GGML_METAL_USE_BNNS` preprocessor directive is set to `1`.

### D. How to Enable at Runtime

Even if compiled in, BNNS acceleration must be explicitly enabled at runtime via the `use_bnns` parameter in `llama_context_params`.

-   Set `params.use_bnns = true;` when creating a `llama_context`.

C++ code snippet example:
```cpp
#include "llama.h"

// ...

llama_context_params ctx_params = llama_context_default_params();
ctx_params.use_bnns = true; // Enable BNNS optimizations at runtime

// If you are managing Metal devices explicitly, ensure the Metal backend is used.
// For example, if you have model_params:
// model_params.main_gpu = 0; // Or specific GPU index for Metal device
// model_params.split_mode = LLAMA_SPLIT_MODE_LAYER; // If offloading layers

llama_model * model = llama_load_model_from_file("path/to/your/model.gguf", model_params);
if (!model) {
    // Handle error
    return 1;
}

llama_context * ctx = llama_new_context_with_model(model, ctx_params);
if (!ctx) {
    // Handle error
    llama_free_model(model);
    return 1;
}

// ... your llama_decode() and other logic ...

llama_free(ctx);
llama_free_model(model);
```

### E. Operations Accelerated

The current BNNS integration primarily accelerates the following operations:
-   **Matrix Multiplication:**
    -   FP32 (float x float -> float)
    -   FP16 input with FP32 accumulation/output (half x half -> float)
    -   Both Matrix-Vector and Matrix-Matrix variants.
-   **Layer Normalization:**
    -   FP32

Operations not listed (e.g., RMS Normalization, quantized matrix multiplications, attention mechanisms like FlashAttention) will still use the default custom Metal kernels even if `use_bnns` is enabled.

### F. Potential Benefits

-   **Performance:** Potential for improved tokens/second or reduced latency for the models and operations that heavily utilize the accelerated routines.
-   **Efficiency:** BNNS kernels are highly optimized by Apple for their hardware, which can sometimes lead to better power efficiency for those specific operations.

Performance gains can vary depending on the specific Apple Silicon chip (M1, M2, M3 series, Pro/Max/Ultra variants), the model architecture, sequence length, batch size, and overall workload.

### G. Known Limitations/Considerations

-   **Numerical Precision:** While BNNS routines are highly accurate, there might be minor differences in floating-point arithmetic results compared to the custom Metal kernels. These differences are generally within acceptable tolerances for neural network computations.
-   **Overhead:** For very small tensors or operations where the overhead of calling a BNNS routine might be comparable to the computation itself, performance benefits might be negligible or slightly negative. The current implementation tries to target operations where BNNS is likely beneficial.
-   **Initial Focus:** The current integration is focused on common FP32 and FP16 dense matrix multiplications and standard FP32 layer normalization. Support for other operations (e.g., quantized types, different normalization variants like RMSNorm directly via BNNS) may be limited or fall back to Metal kernels.
-   **Memory Usage:** Memory usage should generally be comparable to the standard Metal backend. BNNS operations are performed on the existing Metal buffers where possible.
-   **Ongoing Development:** This feature is under active development. Performance characteristics, supported operations, and behavior may change in future updates.

### H. Troubleshooting/Feedback

-   If you encounter unexpected behavior or performance issues when `use_bnns` is enabled, try running the same workload with `use_bnns = false` to compare.
-   Report any significant discrepancies, crashes, or performance regressions related to the BNNS backend through the `llama.cpp` GitHub issues page. Please include details about your Apple Silicon device, OS version, Xcode version, model used, and steps to reproduce the issue.

---

This documentation aims to provide a clear overview of the BNNS optimization within the Metal backend. Users are encouraged to experiment with this option to see if it provides benefits for their specific use cases.
