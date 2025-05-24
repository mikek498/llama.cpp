#include <chrono>
#include <iostream>
#include <vector>
#include <random>
#include <iomanip>
#include <arm_neon.h>

const int VECTOR_SIZE = 1024 * 1024; // 1M floats
const int NUM_ITERATIONS = 100;

// Standard ARM NEON dot product implementation
void dot_product_standard(int n, float* result, const float* x, const float* y) {
    float32x4_t sum0 = vdupq_n_f32(0.0f);
    float32x4_t sum1 = vdupq_n_f32(0.0f);
    float32x4_t sum2 = vdupq_n_f32(0.0f);
    float32x4_t sum3 = vdupq_n_f32(0.0f);
    float32x4_t sum4 = vdupq_n_f32(0.0f);
    float32x4_t sum5 = vdupq_n_f32(0.0f);
    float32x4_t sum6 = vdupq_n_f32(0.0f);
    float32x4_t sum7 = vdupq_n_f32(0.0f);
    
    int i = 0;
    // Process 32 elements per iteration
    for (; i + 31 < n; i += 32) {
        float32x4_t x0 = vld1q_f32(x + i);
        float32x4_t x1 = vld1q_f32(x + i + 4);
        float32x4_t x2 = vld1q_f32(x + i + 8);
        float32x4_t x3 = vld1q_f32(x + i + 12);
        float32x4_t x4 = vld1q_f32(x + i + 16);
        float32x4_t x5 = vld1q_f32(x + i + 20);
        float32x4_t x6 = vld1q_f32(x + i + 24);
        float32x4_t x7 = vld1q_f32(x + i + 28);
        
        float32x4_t y0 = vld1q_f32(y + i);
        float32x4_t y1 = vld1q_f32(y + i + 4);
        float32x4_t y2 = vld1q_f32(y + i + 8);
        float32x4_t y3 = vld1q_f32(y + i + 12);
        float32x4_t y4 = vld1q_f32(y + i + 16);
        float32x4_t y5 = vld1q_f32(y + i + 20);
        float32x4_t y6 = vld1q_f32(y + i + 24);
        float32x4_t y7 = vld1q_f32(y + i + 28);
        
        sum0 = vfmaq_f32(sum0, x0, y0);
        sum1 = vfmaq_f32(sum1, x1, y1);
        sum2 = vfmaq_f32(sum2, x2, y2);
        sum3 = vfmaq_f32(sum3, x3, y3);
        sum4 = vfmaq_f32(sum4, x4, y4);
        sum5 = vfmaq_f32(sum5, x5, y5);
        sum6 = vfmaq_f32(sum6, x6, y6);
        sum7 = vfmaq_f32(sum7, x7, y7);
    }
    
    // Handle remaining elements
    for (; i + 15 < n; i += 16) {
        float32x4_t x0 = vld1q_f32(x + i);
        float32x4_t x1 = vld1q_f32(x + i + 4);
        float32x4_t x2 = vld1q_f32(x + i + 8);
        float32x4_t x3 = vld1q_f32(x + i + 12);
        
        float32x4_t y0 = vld1q_f32(y + i);
        float32x4_t y1 = vld1q_f32(y + i + 4);
        float32x4_t y2 = vld1q_f32(y + i + 8);
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
    
    // Combine all partial sums
    float32x4_t total = vaddq_f32(vaddq_f32(sum0, sum1), vaddq_f32(sum2, sum3));
    total = vaddq_f32(total, vaddq_f32(vaddq_f32(sum4, sum5), vaddq_f32(sum6, sum7)));
    
    float sumf = vaddvq_f32(total);
    
    // Handle remaining elements
    for (; i < n; ++i) {
        sumf += x[i] * y[i];
    }
    
    *result = sumf;
}

#ifdef ARM_M1
// M1 Max optimized dot product implementation
void dot_product_m1_optimized(int n, float* result, const float* x, const float* y) {
    float32x4_t sum0 = vdupq_n_f32(0.0f);
    float32x4_t sum1 = vdupq_n_f32(0.0f);
    float32x4_t sum2 = vdupq_n_f32(0.0f);
    float32x4_t sum3 = vdupq_n_f32(0.0f);
    float32x4_t sum4 = vdupq_n_f32(0.0f);
    float32x4_t sum5 = vdupq_n_f32(0.0f);
    float32x4_t sum6 = vdupq_n_f32(0.0f);
    float32x4_t sum7 = vdupq_n_f32(0.0f);
    float32x4_t sum8 = vdupq_n_f32(0.0f);
    float32x4_t sum9 = vdupq_n_f32(0.0f);
    float32x4_t sum10 = vdupq_n_f32(0.0f);
    float32x4_t sum11 = vdupq_n_f32(0.0f);
    float32x4_t sum12 = vdupq_n_f32(0.0f);
    float32x4_t sum13 = vdupq_n_f32(0.0f);
    float32x4_t sum14 = vdupq_n_f32(0.0f);
    float32x4_t sum15 = vdupq_n_f32(0.0f);
    
    int i = 0;
    // Process 64 elements per iteration for M1's wide execution units
    for (; i + 63 < n; i += 64) {
        // Prefetch next cache lines
        __builtin_prefetch(x + i + 64, 0, 3);
        __builtin_prefetch(y + i + 64, 0, 3);
        
        // Load 16 NEON registers worth of data
        float32x4_t x0 = vld1q_f32(x + i);
        float32x4_t x1 = vld1q_f32(x + i + 4);
        float32x4_t x2 = vld1q_f32(x + i + 8);
        float32x4_t x3 = vld1q_f32(x + i + 12);
        float32x4_t x4 = vld1q_f32(x + i + 16);
        float32x4_t x5 = vld1q_f32(x + i + 20);
        float32x4_t x6 = vld1q_f32(x + i + 24);
        float32x4_t x7 = vld1q_f32(x + i + 28);
        float32x4_t x8 = vld1q_f32(x + i + 32);
        float32x4_t x9 = vld1q_f32(x + i + 36);
        float32x4_t x10 = vld1q_f32(x + i + 40);
        float32x4_t x11 = vld1q_f32(x + i + 44);
        float32x4_t x12 = vld1q_f32(x + i + 48);
        float32x4_t x13 = vld1q_f32(x + i + 52);
        float32x4_t x14 = vld1q_f32(x + i + 56);
        float32x4_t x15 = vld1q_f32(x + i + 60);
        
        float32x4_t y0 = vld1q_f32(y + i);
        float32x4_t y1 = vld1q_f32(y + i + 4);
        float32x4_t y2 = vld1q_f32(y + i + 8);
        float32x4_t y3 = vld1q_f32(y + i + 12);
        float32x4_t y4 = vld1q_f32(y + i + 16);
        float32x4_t y5 = vld1q_f32(y + i + 20);
        float32x4_t y6 = vld1q_f32(y + i + 24);
        float32x4_t y7 = vld1q_f32(y + i + 28);
        float32x4_t y8 = vld1q_f32(y + i + 32);
        float32x4_t y9 = vld1q_f32(y + i + 36);
        float32x4_t y10 = vld1q_f32(y + i + 40);
        float32x4_t y11 = vld1q_f32(y + i + 44);
        float32x4_t y12 = vld1q_f32(y + i + 48);
        float32x4_t y13 = vld1q_f32(y + i + 52);
        float32x4_t y14 = vld1q_f32(y + i + 56);
        float32x4_t y15 = vld1q_f32(y + i + 60);
        
        // Interleave FMA operations for maximum pipeline utilization
        sum0 = vfmaq_f32(sum0, x0, y0);
        sum1 = vfmaq_f32(sum1, x1, y1);
        sum2 = vfmaq_f32(sum2, x2, y2);
        sum3 = vfmaq_f32(sum3, x3, y3);
        sum4 = vfmaq_f32(sum4, x4, y4);
        sum5 = vfmaq_f32(sum5, x5, y5);
        sum6 = vfmaq_f32(sum6, x6, y6);
        sum7 = vfmaq_f32(sum7, x7, y7);
        sum8 = vfmaq_f32(sum8, x8, y8);
        sum9 = vfmaq_f32(sum9, x9, y9);
        sum10 = vfmaq_f32(sum10, x10, y10);
        sum11 = vfmaq_f32(sum11, x11, y11);
        sum12 = vfmaq_f32(sum12, x12, y12);
        sum13 = vfmaq_f32(sum13, x13, y13);
        sum14 = vfmaq_f32(sum14, x14, y14);
        sum15 = vfmaq_f32(sum15, x15, y15);
    }
    
    // Combine all partial sums using tree reduction
    float32x4_t sum_low = vaddq_f32(vaddq_f32(vaddq_f32(sum0, sum1), vaddq_f32(sum2, sum3)), vaddq_f32(vaddq_f32(sum4, sum5), vaddq_f32(sum6, sum7)));
    float32x4_t sum_high = vaddq_f32(vaddq_f32(vaddq_f32(sum8, sum9), vaddq_f32(sum10, sum11)), vaddq_f32(vaddq_f32(sum12, sum13), vaddq_f32(sum14, sum15)));
    float32x4_t total = vaddq_f32(sum_low, sum_high);
    
    // Process remaining 32-element blocks
    for (; i + 31 < n; i += 32) {
        float32x4_t x0 = vld1q_f32(x + i);
        float32x4_t x1 = vld1q_f32(x + i + 4);
        float32x4_t x2 = vld1q_f32(x + i + 8);
        float32x4_t x3 = vld1q_f32(x + i + 12);
        float32x4_t x4 = vld1q_f32(x + i + 16);
        float32x4_t x5 = vld1q_f32(x + i + 20);
        float32x4_t x6 = vld1q_f32(x + i + 24);
        float32x4_t x7 = vld1q_f32(x + i + 28);
        
        float32x4_t y0 = vld1q_f32(y + i);
        float32x4_t y1 = vld1q_f32(y + i + 4);
        float32x4_t y2 = vld1q_f32(y + i + 8);
        float32x4_t y3 = vld1q_f32(y + i + 12);
        float32x4_t y4 = vld1q_f32(y + i + 16);
        float32x4_t y5 = vld1q_f32(y + i + 20);
        float32x4_t y6 = vld1q_f32(y + i + 24);
        float32x4_t y7 = vld1q_f32(y + i + 28);
        
        float32x4_t tmp0 = vfmaq_f32(vdupq_n_f32(0.0f), x0, y0);
        float32x4_t tmp1 = vfmaq_f32(tmp0, x1, y1);
        float32x4_t tmp2 = vfmaq_f32(tmp1, x2, y2);
        float32x4_t tmp3 = vfmaq_f32(tmp2, x3, y3);
        float32x4_t tmp4 = vfmaq_f32(tmp3, x4, y4);
        float32x4_t tmp5 = vfmaq_f32(tmp4, x5, y5);
        float32x4_t tmp6 = vfmaq_f32(tmp5, x6, y6);
        float32x4_t tmp7 = vfmaq_f32(tmp6, x7, y7);
        total = vaddq_f32(total, tmp7);
    }
    
    // Handle remaining elements
    for (; i + 15 < n; i += 16) {
        float32x4_t x0 = vld1q_f32(x + i);
        float32x4_t x1 = vld1q_f32(x + i + 4);
        float32x4_t x2 = vld1q_f32(x + i + 8);
        float32x4_t x3 = vld1q_f32(x + i + 12);
        
        float32x4_t y0 = vld1q_f32(y + i);
        float32x4_t y1 = vld1q_f32(y + i + 4);
        float32x4_t y2 = vld1q_f32(y + i + 8);
        float32x4_t y3 = vld1q_f32(y + i + 12);
        
        float32x4_t tmp0 = vfmaq_f32(vdupq_n_f32(0.0f), x0, y0);
        float32x4_t tmp1 = vfmaq_f32(tmp0, x1, y1);
        float32x4_t tmp2 = vfmaq_f32(tmp1, x2, y2);
        float32x4_t tmp3 = vfmaq_f32(tmp2, x3, y3);
        total = vaddq_f32(total, tmp3);
    }
    
    for (; i + 3 < n; i += 4) {
        float32x4_t x0 = vld1q_f32(x + i);
        float32x4_t y0 = vld1q_f32(y + i);
        total = vfmaq_f32(total, x0, y0);
    }
    
    float sumf = vaddvq_f32(total);
    
    // Handle remaining elements
    for (; i < n; ++i) {
        sumf += x[i] * y[i];
    }
    
    *result = sumf;
}
#endif

void benchmark_function(const char* name, void (*func)(int, float*, const float*, const float*)) {
    std::vector<float> x(VECTOR_SIZE);
    std::vector<float> y(VECTOR_SIZE);
    float result;
    
    // Initialize with random data
    std::random_device rd;
    std::mt19937 gen(rd());
    std::uniform_real_distribution<float> dis(-1.0f, 1.0f);
    
    for (int i = 0; i < VECTOR_SIZE; i++) {
        x[i] = dis(gen);
        y[i] = dis(gen);
    }
    
    auto start = std::chrono::high_resolution_clock::now();
    
    for (int iter = 0; iter < NUM_ITERATIONS; iter++) {
        func(VECTOR_SIZE, &result, x.data(), y.data());
    }
    
    auto end = std::chrono::high_resolution_clock::now();
    auto duration = std::chrono::duration_cast<std::chrono::microseconds>(end - start);
    
    std::cout << name << " Performance:" << std::endl;
    std::cout << "  Vector size: " << VECTOR_SIZE << " floats" << std::endl;
    std::cout << "  Iterations: " << NUM_ITERATIONS << std::endl;
    std::cout << "  Total time: " << duration.count() << " μs" << std::endl;
    std::cout << "  Average time per iteration: " << duration.count() / NUM_ITERATIONS << " μs" << std::endl;
    std::cout << "  Throughput: " << std::fixed << std::setprecision(2) 
              << (double)(VECTOR_SIZE * NUM_ITERATIONS) / duration.count() << " MFLOPS" << std::endl;
    std::cout << "  Result: " << result << std::endl << std::endl;
}

int main() {
    std::cout << "SIMD Dot Product Benchmark" << std::endl;
    std::cout << "==========================" << std::endl;
    
#ifdef ARM_M1
    std::cout << "Running with ARM_M1 optimizations enabled" << std::endl;
#else
    std::cout << "Running with standard ARM NEON implementation" << std::endl;
#endif
    
    std::cout << std::endl;
    
    benchmark_function("Standard ARM NEON", dot_product_standard);
    
#ifdef ARM_M1
    benchmark_function("M1 Max Optimized", dot_product_m1_optimized);
#endif
    
    return 0;
}