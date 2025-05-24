#include <chrono>
#include <iostream>
#include <vector>
#include <random>
#include <iomanip>
#include <arm_neon.h>
#include <algorithm>

const int VECTOR_SIZE = 1024 * 1024; // 1M floats
const int NUM_ITERATIONS = 1000; // More iterations for better accuracy
const int NUM_WARMUP = 10;

// Scalar implementation for baseline
void dot_product_scalar(int n, float* result, const float* x, const float* y) {
    float sum = 0.0f;
    for (int i = 0; i < n; ++i) {
        sum += x[i] * y[i];
    }
    *result = sum;
}

// Basic NEON implementation (4-element)
void dot_product_neon_basic(int n, float* result, const float* x, const float* y) {
    float32x4_t sum = vdupq_n_f32(0.0f);
    
    int i = 0;
    for (; i + 3 < n; i += 4) {
        float32x4_t x_vec = vld1q_f32(x + i);
        float32x4_t y_vec = vld1q_f32(y + i);
        sum = vfmaq_f32(sum, x_vec, y_vec);
    }
    
    float sumf = vaddvq_f32(sum);
    for (; i < n; ++i) {
        sumf += x[i] * y[i];
    }
    
    *result = sumf;
}

// Standard ARM NEON implementation (32-element unrolling)
void dot_product_neon_standard(int n, float* result, const float* x, const float* y) {
    float32x4_t sum0 = vdupq_n_f32(0.0f);
    float32x4_t sum1 = vdupq_n_f32(0.0f);
    float32x4_t sum2 = vdupq_n_f32(0.0f);
    float32x4_t sum3 = vdupq_n_f32(0.0f);
    float32x4_t sum4 = vdupq_n_f32(0.0f);
    float32x4_t sum5 = vdupq_n_f32(0.0f);
    float32x4_t sum6 = vdupq_n_f32(0.0f);
    float32x4_t sum7 = vdupq_n_f32(0.0f);
    
    int i = 0;
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

// M1 Max optimized implementation with even more aggressive unrolling
void dot_product_m1_ultra(int n, float* result, const float* x, const float* y) {
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
    float32x4_t sum16 = vdupq_n_f32(0.0f);
    float32x4_t sum17 = vdupq_n_f32(0.0f);
    float32x4_t sum18 = vdupq_n_f32(0.0f);
    float32x4_t sum19 = vdupq_n_f32(0.0f);
    float32x4_t sum20 = vdupq_n_f32(0.0f);
    float32x4_t sum21 = vdupq_n_f32(0.0f);
    float32x4_t sum22 = vdupq_n_f32(0.0f);
    float32x4_t sum23 = vdupq_n_f32(0.0f);
    float32x4_t sum24 = vdupq_n_f32(0.0f);
    float32x4_t sum25 = vdupq_n_f32(0.0f);
    float32x4_t sum26 = vdupq_n_f32(0.0f);
    float32x4_t sum27 = vdupq_n_f32(0.0f);
    float32x4_t sum28 = vdupq_n_f32(0.0f);
    float32x4_t sum29 = vdupq_n_f32(0.0f);
    float32x4_t sum30 = vdupq_n_f32(0.0f);
    float32x4_t sum31 = vdupq_n_f32(0.0f);
    
    int i = 0;
    // Process 128 elements per iteration (maximum register utilization)
    for (; i + 127 < n; i += 128) {
        // Aggressive prefetching
        __builtin_prefetch(x + i + 128, 0, 3);
        __builtin_prefetch(y + i + 128, 0, 3);
        __builtin_prefetch(x + i + 192, 0, 2);
        __builtin_prefetch(y + i + 192, 0, 2);
        
        // Load 32 NEON registers worth of data (128 floats)
        float32x4_t x0 = vld1q_f32(x + i); float32x4_t y0 = vld1q_f32(y + i);
        float32x4_t x1 = vld1q_f32(x + i + 4); float32x4_t y1 = vld1q_f32(y + i + 4);
        float32x4_t x2 = vld1q_f32(x + i + 8); float32x4_t y2 = vld1q_f32(y + i + 8);
        float32x4_t x3 = vld1q_f32(x + i + 12); float32x4_t y3 = vld1q_f32(y + i + 12);
        float32x4_t x4 = vld1q_f32(x + i + 16); float32x4_t y4 = vld1q_f32(y + i + 16);
        float32x4_t x5 = vld1q_f32(x + i + 20); float32x4_t y5 = vld1q_f32(y + i + 20);
        float32x4_t x6 = vld1q_f32(x + i + 24); float32x4_t y6 = vld1q_f32(y + i + 24);
        float32x4_t x7 = vld1q_f32(x + i + 28); float32x4_t y7 = vld1q_f32(y + i + 28);
        float32x4_t x8 = vld1q_f32(x + i + 32); float32x4_t y8 = vld1q_f32(y + i + 32);
        float32x4_t x9 = vld1q_f32(x + i + 36); float32x4_t y9 = vld1q_f32(y + i + 36);
        float32x4_t x10 = vld1q_f32(x + i + 40); float32x4_t y10 = vld1q_f32(y + i + 40);
        float32x4_t x11 = vld1q_f32(x + i + 44); float32x4_t y11 = vld1q_f32(y + i + 44);
        float32x4_t x12 = vld1q_f32(x + i + 48); float32x4_t y12 = vld1q_f32(y + i + 48);
        float32x4_t x13 = vld1q_f32(x + i + 52); float32x4_t y13 = vld1q_f32(y + i + 52);
        float32x4_t x14 = vld1q_f32(x + i + 56); float32x4_t y14 = vld1q_f32(y + i + 56);
        float32x4_t x15 = vld1q_f32(x + i + 60); float32x4_t y15 = vld1q_f32(y + i + 60);
        float32x4_t x16 = vld1q_f32(x + i + 64); float32x4_t y16 = vld1q_f32(y + i + 64);
        float32x4_t x17 = vld1q_f32(x + i + 68); float32x4_t y17 = vld1q_f32(y + i + 68);
        float32x4_t x18 = vld1q_f32(x + i + 72); float32x4_t y18 = vld1q_f32(y + i + 72);
        float32x4_t x19 = vld1q_f32(x + i + 76); float32x4_t y19 = vld1q_f32(y + i + 76);
        float32x4_t x20 = vld1q_f32(x + i + 80); float32x4_t y20 = vld1q_f32(y + i + 80);
        float32x4_t x21 = vld1q_f32(x + i + 84); float32x4_t y21 = vld1q_f32(y + i + 84);
        float32x4_t x22 = vld1q_f32(x + i + 88); float32x4_t y22 = vld1q_f32(y + i + 88);
        float32x4_t x23 = vld1q_f32(x + i + 92); float32x4_t y23 = vld1q_f32(y + i + 92);
        float32x4_t x24 = vld1q_f32(x + i + 96); float32x4_t y24 = vld1q_f32(y + i + 96);
        float32x4_t x25 = vld1q_f32(x + i + 100); float32x4_t y25 = vld1q_f32(y + i + 100);
        float32x4_t x26 = vld1q_f32(x + i + 104); float32x4_t y26 = vld1q_f32(y + i + 104);
        float32x4_t x27 = vld1q_f32(x + i + 108); float32x4_t y27 = vld1q_f32(y + i + 108);
        float32x4_t x28 = vld1q_f32(x + i + 112); float32x4_t y28 = vld1q_f32(y + i + 112);
        float32x4_t x29 = vld1q_f32(x + i + 116); float32x4_t y29 = vld1q_f32(y + i + 116);
        float32x4_t x30 = vld1q_f32(x + i + 120); float32x4_t y30 = vld1q_f32(y + i + 120);
        float32x4_t x31 = vld1q_f32(x + i + 124); float32x4_t y31 = vld1q_f32(y + i + 124);
        
        // Interleave FMA operations for maximum pipeline utilization
        sum0 = vfmaq_f32(sum0, x0, y0); sum1 = vfmaq_f32(sum1, x1, y1);
        sum2 = vfmaq_f32(sum2, x2, y2); sum3 = vfmaq_f32(sum3, x3, y3);
        sum4 = vfmaq_f32(sum4, x4, y4); sum5 = vfmaq_f32(sum5, x5, y5);
        sum6 = vfmaq_f32(sum6, x6, y6); sum7 = vfmaq_f32(sum7, x7, y7);
        sum8 = vfmaq_f32(sum8, x8, y8); sum9 = vfmaq_f32(sum9, x9, y9);
        sum10 = vfmaq_f32(sum10, x10, y10); sum11 = vfmaq_f32(sum11, x11, y11);
        sum12 = vfmaq_f32(sum12, x12, y12); sum13 = vfmaq_f32(sum13, x13, y13);
        sum14 = vfmaq_f32(sum14, x14, y14); sum15 = vfmaq_f32(sum15, x15, y15);
        sum16 = vfmaq_f32(sum16, x16, y16); sum17 = vfmaq_f32(sum17, x17, y17);
        sum18 = vfmaq_f32(sum18, x18, y18); sum19 = vfmaq_f32(sum19, x19, y19);
        sum20 = vfmaq_f32(sum20, x20, y20); sum21 = vfmaq_f32(sum21, x21, y21);
        sum22 = vfmaq_f32(sum22, x22, y22); sum23 = vfmaq_f32(sum23, x23, y23);
        sum24 = vfmaq_f32(sum24, x24, y24); sum25 = vfmaq_f32(sum25, x25, y25);
        sum26 = vfmaq_f32(sum26, x26, y26); sum27 = vfmaq_f32(sum27, x27, y27);
        sum28 = vfmaq_f32(sum28, x28, y28); sum29 = vfmaq_f32(sum29, x29, y29);
        sum30 = vfmaq_f32(sum30, x30, y30); sum31 = vfmaq_f32(sum31, x31, y31);
    }
    
    // Combine all partial sums using tree reduction
    float32x4_t sum_l1_0 = vaddq_f32(vaddq_f32(sum0, sum1), vaddq_f32(sum2, sum3));
    float32x4_t sum_l1_1 = vaddq_f32(vaddq_f32(sum4, sum5), vaddq_f32(sum6, sum7));
    float32x4_t sum_l1_2 = vaddq_f32(vaddq_f32(sum8, sum9), vaddq_f32(sum10, sum11));
    float32x4_t sum_l1_3 = vaddq_f32(vaddq_f32(sum12, sum13), vaddq_f32(sum14, sum15));
    float32x4_t sum_l1_4 = vaddq_f32(vaddq_f32(sum16, sum17), vaddq_f32(sum18, sum19));
    float32x4_t sum_l1_5 = vaddq_f32(vaddq_f32(sum20, sum21), vaddq_f32(sum22, sum23));
    float32x4_t sum_l1_6 = vaddq_f32(vaddq_f32(sum24, sum25), vaddq_f32(sum26, sum27));
    float32x4_t sum_l1_7 = vaddq_f32(vaddq_f32(sum28, sum29), vaddq_f32(sum30, sum31));
    
    float32x4_t sum_l2_0 = vaddq_f32(sum_l1_0, sum_l1_1);
    float32x4_t sum_l2_1 = vaddq_f32(sum_l1_2, sum_l1_3);
    float32x4_t sum_l2_2 = vaddq_f32(sum_l1_4, sum_l1_5);
    float32x4_t sum_l2_3 = vaddq_f32(sum_l1_6, sum_l1_7);
    
    float32x4_t sum_l3_0 = vaddq_f32(sum_l2_0, sum_l2_1);
    float32x4_t sum_l3_1 = vaddq_f32(sum_l2_2, sum_l2_3);
    
    float32x4_t total = vaddq_f32(sum_l3_0, sum_l3_1);
    
    // Process remaining 64-element blocks
    for (; i + 63 < n; i += 64) {
        // Similar pattern but with fewer registers
        __builtin_prefetch(x + i + 64, 0, 3);
        __builtin_prefetch(y + i + 64, 0, 3);
        
        float32x4_t temp_sum = vdupq_n_f32(0.0f);
        for (int j = 0; j < 64; j += 4) {
            float32x4_t x_vec = vld1q_f32(x + i + j);
            float32x4_t y_vec = vld1q_f32(y + i + j);
            temp_sum = vfmaq_f32(temp_sum, x_vec, y_vec);
        }
        total = vaddq_f32(total, temp_sum);
    }
    
    // Handle remaining elements
    for (; i + 3 < n; i += 4) {
        float32x4_t x_vec = vld1q_f32(x + i);
        float32x4_t y_vec = vld1q_f32(y + i);
        total = vfmaq_f32(total, x_vec, y_vec);
    }
    
    float sumf = vaddvq_f32(total);
    
    // Handle final remaining elements
    for (; i < n; ++i) {
        sumf += x[i] * y[i];
    }
    
    *result = sumf;
}

// Current M1 implementation from our code
void dot_product_m1_current(int n, float* result, const float* x, const float* y) {
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
        // Prefetch next cache lines for optimal memory bandwidth
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
    
    // Combine all partial sums using tree reduction for optimal performance
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
    
    // Calculate statistics
    std::sort(times.begin(), times.end());
    double median_time = times[times.size() / 2];
    double avg_time = std::accumulate(times.begin(), times.end(), 0.0) / times.size();
    
    // Use median for more stable results
    double time_us = median_time;
    double throughput = (double)(VECTOR_SIZE) / time_us; // MFLOPS
    
    BenchmarkResult br;
    br.name = name;
    br.avg_time_us = time_us;
    br.throughput_mflops = throughput;
    br.speedup = 0.0; // Will be calculated later
    br.result = result;
    
    return br;
}

int main() {
    std::cout << "Comprehensive SIMD Dot Product Benchmark" << std::endl;
    std::cout << "=========================================" << std::endl;
    std::cout << "Vector size: " << VECTOR_SIZE << " floats" << std::endl;
    std::cout << "Iterations: " << NUM_ITERATIONS << std::endl;
    std::cout << "Warmup iterations: " << NUM_WARMUP << std::endl;
    std::cout << std::endl;
    
    // Initialize test data
    std::vector<float> x(VECTOR_SIZE);
    std::vector<float> y(VECTOR_SIZE);
    
    std::random_device rd;
    std::mt19937 gen(rd());
    std::uniform_real_distribution<float> dis(-1.0f, 1.0f);
    
    for (int i = 0; i < VECTOR_SIZE; i++) {
        x[i] = dis(gen);
        y[i] = dis(gen);
    }
    
    // Run benchmarks
    std::vector<BenchmarkResult> results;
    
    results.push_back(benchmark_function("Scalar", dot_product_scalar, x, y));
    results.push_back(benchmark_function("NEON Basic (4-elem)", dot_product_neon_basic, x, y));
    results.push_back(benchmark_function("NEON Standard (32-elem)", dot_product_neon_standard, x, y));
    results.push_back(benchmark_function("M1 Current (64-elem)", dot_product_m1_current, x, y));
    results.push_back(benchmark_function("M1 Ultra (128-elem)", dot_product_m1_ultra, x, y));
    
    // Calculate speedups relative to scalar
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
                  << std::setw(15) << std::fixed << std::setprecision(3) << result.result << std::endl;
    }
    
    // Find fastest implementation
    auto fastest = std::max_element(results.begin(), results.end(), 
        [](const BenchmarkResult& a, const BenchmarkResult& b) {
            return a.throughput_mflops < b.throughput_mflops;
        });
    
    std::cout << std::endl;
    std::cout << "🏆 Fastest Implementation: " << fastest->name << std::endl;
    std::cout << "Performance: " << std::fixed << std::setprecision(1) << fastest->throughput_mflops << " MFLOPS" << std::endl;
    
    // Verify numerical correctness
    std::cout << std::endl << "Numerical Correctness Check:" << std::endl;
    float reference = results[0].result; // Use scalar as reference
    bool all_correct = true;
    
    for (const auto& result : results) {
        float diff = std::abs(result.result - reference);
        float rel_error = diff / std::abs(reference);
        bool correct = rel_error < 1e-4f; // 0.01% tolerance
        
        std::cout << result.name << ": " << (correct ? "✓" : "✗") 
                  << " (rel_error: " << std::scientific << rel_error << ")" << std::endl;
        
        if (!correct) all_correct = false;
    }
    
    std::cout << std::endl;
    if (all_correct) {
        std::cout << "✅ All implementations produce correct results!" << std::endl;
    } else {
        std::cout << "❌ Some implementations have numerical errors!" << std::endl;
    }
    
    return 0;
}