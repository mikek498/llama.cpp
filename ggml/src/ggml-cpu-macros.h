// This file was previously named ggml-cpu.h and only contains macro definitions for optimized scalar kernels.
// It has been renamed to avoid conflicts with the main ggml-cpu.h header in ggml/include/.

#ifndef GGML_USE_OPTIMIZED_SCALAR_Q5_Q8
#define GGML_USE_OPTIMIZED_SCALAR_Q5_Q8 1 // Revert to 1 to use the q5_K_optimized path
#endif

#ifndef GGML_USE_OPTIMIZED_SCALAR_Q6_Q8
#define GGML_USE_OPTIMIZED_SCALAR_Q6_Q8 1
#endif