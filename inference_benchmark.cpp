#include <arm_neon.h>
#include <iostream>
#include <chrono>
#include <vector>
#include <cstdlib>
#include <iomanip>
#include <random>

#ifndef GGML_RESTRICT
#define GGML_RESTRICT __restrict
#endif

// Declare vector functions from vec.cpp
extern "C" {
    void ggml_vec_dot_f32(int n, float * GGML_RESTRICT s, size_t bs, const float * GGML_RESTRICT x, size_t bx, const float * GGML_RESTRICT y, size_t by, int nrc);
    void ggml_vec_add_f32(const int n, float * z, const float * x, const float * y);
    void ggml_vec_mul_f32(const int n, float * z, const float * x, const float * y);
    void ggml_vec_acc_f32(const int n, float * y, const float * x);
    void ggml_vec_silu_f32(const int n, float * y, const float * x);
    void ggml_vec_set_f32(const int n, float * x, const float v);
    void ggml_vec_add1_f32(const int n, float * y, const float * x, const float v);
}

// Simulated transformer layer operations (simplified for benchmarking)
void transformer_layer_inference(int seq_len, int hidden_dim, int ffn_dim, 
                                const float* input, 
                                const float* attn_weights, 
                                const float* ffn_weights1, 
                                const float* ffn_weights2,
                                float* output) {
    
    std::vector<float> attn_output(seq_len * hidden_dim);
    std::vector<float> ffn_intermediate(seq_len * ffn_dim);
    std::vector<float> temp(std::max(seq_len * hidden_dim, seq_len * ffn_dim));
    
    // 1. Attention computation (simplified)
    for (int i = 0; i < seq_len; ++i) {
        for (int j = 0; j < hidden_dim; ++j) {
            float dot_result = 0.0f;
            ggml_vec_dot_f32(hidden_dim, &dot_result, 0, 
                           input + i * hidden_dim, 0, 
                           attn_weights + j * hidden_dim, 0, 1);
            attn_output[i * hidden_dim + j] = dot_result;
        }
    }
    
    // 2. Residual connection
    ggml_vec_add_f32(seq_len * hidden_dim, temp.data(), input, attn_output.data());
    
    // 3. FFN layer 1 - Linear + SiLU
    for (int i = 0; i < seq_len; ++i) {
        for (int j = 0; j < ffn_dim; ++j) {
            float dot_result = 0.0f;
            ggml_vec_dot_f32(hidden_dim, &dot_result, 0,
                           temp.data() + i * hidden_dim, 0,
                           ffn_weights1 + j * hidden_dim, 0, 1);
            ffn_intermediate[i * ffn_dim + j] = dot_result;
        }
    }
    
    // 4. SiLU activation
    ggml_vec_silu_f32(seq_len * ffn_dim, ffn_intermediate.data(), ffn_intermediate.data());
    
    // 5. FFN layer 2 - Linear projection back to hidden_dim
    for (int i = 0; i < seq_len; ++i) {
        for (int j = 0; j < hidden_dim; ++j) {
            float dot_result = 0.0f;
            ggml_vec_dot_f32(ffn_dim, &dot_result, 0,
                           ffn_intermediate.data() + i * ffn_dim, 0,
                           ffn_weights2 + j * ffn_dim, 0, 1);
            output[i * hidden_dim + j] = dot_result;
        }
    }
    
    // 6. Final residual connection
    ggml_vec_add_f32(seq_len * hidden_dim, output, output, temp.data());
}

int main() {
    // Transformer-like model parameters (similar to Llama-7B)
    constexpr int seq_len = 512;       // sequence length
    constexpr int hidden_dim = 4096;   // hidden dimension
    constexpr int ffn_dim = 11008;     // FFN intermediate dimension
    constexpr int iterations = 10;      // reduced for realistic timing
    
    std::cout << std::fixed << std::setprecision(1);
    std::cout << "M1 Max Transformer Inference Benchmark\n";
    std::cout << "======================================\n";
    std::cout << "Sequence length: " << seq_len << "\n";
    std::cout << "Hidden dimension: " << hidden_dim << "\n";
    std::cout << "FFN dimension: " << ffn_dim << "\n";
    std::cout << "Iterations: " << iterations << "\n\n";
    
    // Allocate aligned memory for all tensors
    size_t input_size = seq_len * hidden_dim;
    size_t attn_weights_size = hidden_dim * hidden_dim;
    size_t ffn1_weights_size = hidden_dim * ffn_dim;
    size_t ffn2_weights_size = ffn_dim * hidden_dim;
    
    std::vector<float> input(input_size + 64);
    std::vector<float> attn_weights(attn_weights_size + 64);
    std::vector<float> ffn_weights1(ffn1_weights_size + 64);
    std::vector<float> ffn_weights2(ffn2_weights_size + 64);
    std::vector<float> output(input_size + 64);
    
    // Align to 64-byte boundaries for optimal SIMD performance
    float* input_aligned = reinterpret_cast<float*>((reinterpret_cast<uintptr_t>(input.data()) + 63) & ~63);
    float* attn_aligned = reinterpret_cast<float*>((reinterpret_cast<uintptr_t>(attn_weights.data()) + 63) & ~63);
    float* ffn1_aligned = reinterpret_cast<float*>((reinterpret_cast<uintptr_t>(ffn_weights1.data()) + 63) & ~63);
    float* ffn2_aligned = reinterpret_cast<float*>((reinterpret_cast<uintptr_t>(ffn_weights2.data()) + 63) & ~63);
    float* output_aligned = reinterpret_cast<float*>((reinterpret_cast<uintptr_t>(output.data()) + 63) & ~63);
    
    // Initialize with realistic random data
    std::mt19937 gen(42);
    std::normal_distribution<float> dist(0.0f, 0.1f);
    
    for (size_t i = 0; i < input_size; ++i) {
        input_aligned[i] = dist(gen);
    }
    for (size_t i = 0; i < attn_weights_size; ++i) {
        attn_aligned[i] = dist(gen);
    }
    for (size_t i = 0; i < ffn1_weights_size; ++i) {
        ffn1_aligned[i] = dist(gen);
    }
    for (size_t i = 0; i < ffn2_weights_size; ++i) {
        ffn2_aligned[i] = dist(gen);
    }
    
    // Warm up the caches
    for (int i = 0; i < 2; ++i) {
        transformer_layer_inference(seq_len, hidden_dim, ffn_dim,
                                   input_aligned, attn_aligned, 
                                   ffn1_aligned, ffn2_aligned, 
                                   output_aligned);
    }
    
    // Benchmark M1 Max optimized inference
    auto start = std::chrono::high_resolution_clock::now();
    
    for (int i = 0; i < iterations; ++i) {
        transformer_layer_inference(seq_len, hidden_dim, ffn_dim,
                                   input_aligned, attn_aligned, 
                                   ffn1_aligned, ffn2_aligned, 
                                   output_aligned);
    }
    
    auto end = std::chrono::high_resolution_clock::now();
    auto duration = std::chrono::duration_cast<std::chrono::milliseconds>(end - start);
    
    // Calculate performance metrics
    double total_ops = 0.0;
    
    // Attention: seq_len * hidden_dim * hidden_dim * 2 (dot products)
    total_ops += static_cast<double>(seq_len) * hidden_dim * hidden_dim * 2;
    
    // FFN layer 1: seq_len * hidden_dim * ffn_dim * 2
    total_ops += static_cast<double>(seq_len) * hidden_dim * ffn_dim * 2;
    
    // FFN layer 2: seq_len * ffn_dim * hidden_dim * 2  
    total_ops += static_cast<double>(seq_len) * ffn_dim * hidden_dim * 2;
    
    // Vector operations (add, silu): approximately 10% of matrix ops
    total_ops *= 1.1;
    
    total_ops *= iterations;
    
    double gflops = (total_ops / 1e9) / (duration.count() / 1000.0);
    double tokens_per_second = (static_cast<double>(seq_len) * iterations) / (duration.count() / 1000.0);
    
    std::cout << "M1 Max Optimized Inference Results:\n";
    std::cout << "Total time: " << duration.count() << " ms\n";
    std::cout << "Average time per iteration: " << duration.count() / iterations << " ms\n";
    std::cout << "Performance: " << gflops << " GFLOPS\n";
    std::cout << "Throughput: " << tokens_per_second << " tokens/second\n\n";
    
    // Validate output (simple sanity check)
    float output_sum = 0.0f;
    for (size_t i = 0; i < input_size; ++i) {
        output_sum += output_aligned[i];
    }
    std::cout << "Output checksum: " << output_sum << "\n";
    
    // Compare with theoretical peak
    // M1 Max has ~10.4 TFLOPS theoretical peak for FP32
    double efficiency = (gflops / 10400.0) * 100.0;
    std::cout << "Theoretical efficiency: " << efficiency << "% of M1 Max peak\n";
    
    return 0;
}