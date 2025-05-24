#include <chrono>
#include <iostream>
#include <vector>
#include <random>
#include <iomanip>
#include <arm_neon.h>
#include <algorithm>

const int VECTOR_SIZE = 1024 * 1024; // 1M floats
const int NUM_ITERATIONS = 1000;
const int NUM_WARMUP = 50;

// Prevent auto-vectorization of scalar
__attribute__((noinline, optnone))
void dot_product_scalar_no_opt(int n, float* result, const float* x, const float* y) {
    float sum = 0.0f;
    for (int i = 0; i < n; ++i) {
        sum += x[i] * y[i];
    }
    *result = sum;
}

// Optimized M1 Max version with better memory access patterns
void dot_product_m1_optimized_v2(int n, float* result, const float* x, const float* y) {
    // Use fewer registers to avoid spilling and better cache utilization
    float32x4_t sum0 = vdupq_n_f32(0.0f);
    float32x4_t sum1 = vdupq_n_f32(0.0f);
    float32x4_t sum2 = vdupq_n_f32(0.0f);
    float32x4_t sum3 = vdupq_n_f32(0.0f);
    float32x4_t sum4 = vdupq_n_f32(0.0f);
    float32x4_t sum5 = vdupq_n_f32(0.0f);
    float32x4_t sum6 = vdupq_n_f32(0.0f);
    float32x4_t sum7 = vdupq_n_f32(0.0f);
    
    int i = 0;
    
    // Process 32 elements per iteration with optimal prefetching
    for (; i + 31 < n; i += 32) {
        // Strategic prefetching - not too aggressive
        if ((i & 255) == 0) {  // Prefetch every 256 elements
            __builtin_prefetch(x + i + 256, 0, 3);
            __builtin_prefetch(y + i + 256, 0, 3);
        }
        
        // Load data in optimal order
        float32x4_t x0 = vld1q_f32(x + i);
        float32x4_t y0 = vld1q_f32(y + i);
        float32x4_t x1 = vld1q_f32(x + i + 4);
        float32x4_t y1 = vld1q_f32(y + i + 4);
        float32x4_t x2 = vld1q_f32(x + i + 8);
        float32x4_t y2 = vld1q_f32(y + i + 8);
        float32x4_t x3 = vld1q_f32(x + i + 12);
        float32x4_t y3 = vld1q_f32(y + i + 12);
        float32x4_t x4 = vld1q_f32(x + i + 16);
        float32x4_t y4 = vld1q_f32(y + i + 16);
        float32x4_t x5 = vld1q_f32(x + i + 20);
        float32x4_t y5 = vld1q_f32(y + i + 20);
        float32x4_t x6 = vld1q_f32(x + i + 24);
        float32x4_t y6 = vld1q_f32(y + i + 24);
        float32x4_t x7 = vld1q_f32(x + i + 28);
        float32x4_t y7 = vld1q_f32(y + i + 28);
        
        // Interleave FMA operations for better pipeline utilization
        sum0 = vfmaq_f32(sum0, x0, y0);
        sum1 = vfmaq_f32(sum1, x1, y1);
        sum2 = vfmaq_f32(sum2, x2, y2);
        sum3 = vfmaq_f32(sum3, x3, y3);
        sum4 = vfmaq_f32(sum4, x4, y4);
        sum5 = vfmaq_f32(sum5, x5, y5);
        sum6 = vfmaq_f32(sum6, x6, y6);
        sum7 = vfmaq_f32(sum7, x7, y7);
    }
    
    // Handle remaining elements in smaller chunks
    for (; i + 15 < n; i += 16) {
        float32x4_t x0 = vld1q_f32(x + i);
        float32x4_t y0 = vld1q_f32(y + i);
        float32x4_t x1 = vld1q_f32(x + i + 4);
        float32x4_t y1 = vld1q_f32(y + i + 4);
        float32x4_t x2 = vld1q_f32(x + i + 8);
        float32x4_t y2 = vld1q_f32(y + i + 8);
        float32x4_t x3 = vld1q_f32(x + i + 12);
        float32x4_t y3 = vld1q_f32(y + i + 12);
        
        sum0 = vfmaq_f32(sum0, x0, y0);
        sum1 = vfmaq_f32(sum1, x1, y1);
        sum2 = vfmaq_f32(sum2, x2, y2);
        sum3 = vfmaq_f32(sum3, x3, y3);
    }
    
    for (; i + 3 < n; i += 4) {
        float32x4_t x0 = vld1q_f32(x + i);
        float32x4_t y0 = vld1q_f32(y + i);
        sum0 = vfmaq_f32(sum0, x0, y0);
    }
    
    // Efficient reduction
    float32x4_t sum_pairs = vaddq_f32(vaddq_f32(sum0, sum1), vaddq_f32(sum2, sum3));
    sum_pairs = vaddq_f32(sum_pairs, vaddq_f32(vaddq_f32(sum4, sum5), vaddq_f32(sum6, sum7)));
    
    float sumf = vaddvq_f32(sum_pairs);
    
    // Handle remaining scalar elements
    for (; i < n; ++i) {
        sumf += x[i] * y[i];
    }
    
    *result = sumf;
}

// Version with specific M1 Max cache line optimizations
void dot_product_m1_cache_optimized(int n, float* result, const float* x, const float* y) {
    // M1 Max has 64-byte cache lines (16 floats)
    const int CACHE_LINE_FLOATS = 16;
    
    float32x4_t sum0 = vdupq_n_f32(0.0f);
    float32x4_t sum1 = vdupq_n_f32(0.0f);
    float32x4_t sum2 = vdupq_n_f32(0.0f);
    float32x4_t sum3 = vdupq_n_f32(0.0f);
    
    int i = 0;
    
    // Process exactly one cache line at a time
    for (; i + CACHE_LINE_FLOATS - 1 < n; i += CACHE_LINE_FLOATS) {
        // Prefetch next cache line
        __builtin_prefetch(x + i + CACHE_LINE_FLOATS, 0, 3);
        __builtin_prefetch(y + i + CACHE_LINE_FLOATS, 0, 3);
        
        // Process entire cache line
        float32x4_t x0 = vld1q_f32(x + i);
        float32x4_t y0 = vld1q_f32(y + i);
        float32x4_t x1 = vld1q_f32(x + i + 4);
        float32x4_t y1 = vld1q_f32(y + i + 4);
        float32x4_t x2 = vld1q_f32(x + i + 8);
        float32x4_t y2 = vld1q_f32(y + i + 8);
        float32x4_t x3 = vld1q_f32(x + i + 12);
        float32x4_t y3 = vld1q_f32(y + i + 12);
        
        sum0 = vfmaq_f32(sum0, x0, y0);
        sum1 = vfmaq_f32(sum1, x1, y1);
        sum2 = vfmaq_f32(sum2, x2, y2);
        sum3 = vfmaq_f32(sum3, x3, y3);
    }
    
    // Handle remaining elements
    for (; i + 3 < n; i += 4) {
        float32x4_t x0 = vld1q_f32(x + i);
        float32x4_t y0 = vld1q_f32(y + i);
        sum0 = vfmaq_f32(sum0, x0, y0);
    }
    
    float32x4_t total = vaddq_f32(vaddq_f32(sum0, sum1), vaddq_f32(sum2, sum3));
    float sumf = vaddvq_f32(total);
    
    // Handle remaining scalar elements
    for (; i < n; ++i) {
        sumf += x[i] * y[i];
    }
    
    *result = sumf;
}

// Compiler auto-vectorized version 
void dot_product_auto_vectorized(int n, float* result, const float* x, const float* y) {
    float sum = 0.0f;
    #pragma clang loop vectorize(enable) interleave(enable)
    for (int i = 0; i < n; ++i) {
        sum += x[i] * y[i];
    }
    *result = sum;
}

struct BenchmarkResult {
    std::string name;
    double avg_time_us;
    double throughput_mflops;
    double speedup;
    float result;
};

BenchmarkResult benchmark_function(const char* name, void (*func)(int, float*, const float*, const float*), const std::vector<float>& x, const std::vector<float>& y) {
    float result;
    std::vector<double> times;
    
    // Warmup
    for (int i = 0; i < NUM_WARMUP; i++) {
        func(VECTOR_SIZE, &result, x.data(), y.data());
    }
    
    // Actual benchmarking
    for (int iter = 0; iter < NUM_ITERATIONS; iter++) {
        auto start = std::chrono::high_resolution_clock::now();
        func(VECTOR_SIZE, &result, x.data(), y.data());
        auto end = std::chrono::high_resolution_clock::now();
        
        auto duration = std::chrono::duration_cast<std::chrono::nanoseconds>(end - start);
        times.push_back(duration.count() / 1000.0); // Convert to microseconds
    }
    
    // Calculate statistics using median for stability
    std::sort(times.begin(), times.end());
    double median_time = times[times.size() / 2];
    double throughput = (double)(VECTOR_SIZE) / median_time; // MFLOPS
    
    BenchmarkResult br;
    br.name = name;
    br.avg_time_us = median_time;
    br.throughput_mflops = throughput;
    br.speedup = 0.0;
    br.result = result;
    
    return br;
}

int main() {
    std::cout << "M1 Max SIMD Optimization Verification" << std::endl;
    std::cout << "=====================================" << std::endl;
    std::cout << "Vector size: " << VECTOR_SIZE << " floats" << std::endl;
    std::cout << "Iterations: " << NUM_ITERATIONS << std::endl;
    std::cout << "Warmup: " << NUM_WARMUP << std::endl;
    std::cout << std::endl;
    
    // Initialize aligned test data for optimal performance
    std::vector<float> x(VECTOR_SIZE + 64); // Add padding for alignment
    std::vector<float> y(VECTOR_SIZE + 64);
    
    // Align to 64-byte boundaries (M1 Max cache line size)
    float* x_aligned = (float*)((uintptr_t(x.data()) + 63) & ~63);
    float* y_aligned = (float*)((uintptr_t(y.data()) + 63) & ~63);
    
    std::random_device rd;
    std::mt19937 gen(42); // Fixed seed for reproducibility
    std::uniform_real_distribution<float> dis(-1.0f, 1.0f);
    
    for (int i = 0; i < VECTOR_SIZE; i++) {
        x_aligned[i] = dis(gen);
        y_aligned[i] = dis(gen);
    }
    
    // Convert to vectors for API compatibility
    std::vector<float> x_vec(x_aligned, x_aligned + VECTOR_SIZE);
    std::vector<float> y_vec(y_aligned, y_aligned + VECTOR_SIZE);
    
    // Run benchmarks
    std::vector<BenchmarkResult> results;
    
    results.push_back(benchmark_function("Scalar (no auto-vec)", dot_product_scalar_no_opt, x_vec, y_vec));
    results.push_back(benchmark_function("Auto-vectorized", dot_product_auto_vectorized, x_vec, y_vec));
    results.push_back(benchmark_function("M1 Optimized v2", dot_product_m1_optimized_v2, x_vec, y_vec));
    results.push_back(benchmark_function("M1 Cache-optimized", dot_product_m1_cache_optimized, x_vec, y_vec));
    
    // Calculate speedups relative to non-optimized scalar
    double scalar_time = results[0].avg_time_us;
    for (auto& result : results) {
        result.speedup = scalar_time / result.avg_time_us;
    }
    
    // Print results
    std::cout << std::left << std::setw(25) << "Implementation"
              << std::right << std::setw(12) << "Time (μs)"
              << std::setw(15) << "Throughput"
              << std::setw(10) << "Speedup"
              << std::setw(15) << "Result" << std::endl;
    std::cout << std::string(77, '-') << std::endl;
    
    for (const auto& result : results) {
        std::cout << std::left << std::setw(25) << result.name
                  << std::right << std::setw(12) << std::fixed << std::setprecision(2) << result.avg_time_us
                  << std::setw(15) << std::fixed << std::setprecision(1) << result.throughput_mflops
                  << std::setw(10) << std::fixed << std::setprecision(2) << result.speedup << "x"
                  << std::setw(15) << std::fixed << std::setprecision(6) << result.result << std::endl;
    }
    
    // Find fastest implementation
    auto fastest = std::max_element(results.begin(), results.end(), 
        [](const BenchmarkResult& a, const BenchmarkResult& b) {
            return a.throughput_mflops < b.throughput_mflops;
        });
    
    std::cout << std::endl;
    std::cout << "🏆 Fastest Implementation: " << fastest->name << std::endl;
    std::cout << "Performance: " << std::fixed << std::setprecision(1) << fastest->throughput_mflops << " MFLOPS" << std::endl;
    std::cout << "Speedup vs scalar: " << std::fixed << std::setprecision(2) << fastest->speedup << "x" << std::endl;
    
    // Check if our optimizations are actually the fastest
    if (fastest->name.find("M1") != std::string::npos) {
        std::cout << std::endl << "✅ M1 optimization is the fastest!" << std::endl;
    } else {
        std::cout << std::endl << "⚠️  M1 optimization is not the fastest. Compiler auto-vectorization may be better." << std::endl;
    }
    
    return 0;
}