#ifdef __aarch64__
#include <arm_neon.h>
#include <string.h>
#include <assert.h>

// Highly optimized ARM NEON functions for LLaMA inference
// Optimized for Apple Silicon M-series processors

//
// Ultra-fast 4-bit quantized dot product with ARM dot product instructions
// Optimized for M1/M2/M3 performance characteristics
//
static inline void ggml_vec_dot_q4_0_q8_0_neon_ultra(const int n, float * restrict s, 
                                                      const void * restrict vx, 
                                                      const void * restrict vy) {
    const int qk = 32;
    const int nb = n / qk;
    
    const block_q4_0 * restrict x = (const block_q4_0 *) vx;
    const block_q8_0 * restrict y = (const block_q8_0 *) vy;
    
    // Use 4-way unrolling for maximum throughput
    float32x4_t sum0 = vdupq_n_f32(0.0f);
    float32x4_t sum1 = vdupq_n_f32(0.0f);
    float32x4_t sum2 = vdupq_n_f32(0.0f);
    float32x4_t sum3 = vdupq_n_f32(0.0f);
    
    // Process 4 blocks at once for better cache utilization
    int i = 0;
    for (; i + 3 < nb; i += 4) {
        // Load 4-bit quantized weights (4 blocks)
        uint8x16_t qw0 = vld1q_u8(x[i+0].qs);
        uint8x16_t qw1 = vld1q_u8(x[i+1].qs);
        uint8x16_t qw2 = vld1q_u8(x[i+2].qs);
        uint8x16_t qw3 = vld1q_u8(x[i+3].qs);
        
        // Load 8-bit activations (4 blocks)
        int8x16_t qa0_lo = vld1q_s8(y[i+0].qs);
        int8x16_t qa0_hi = vld1q_s8(y[i+0].qs + 16);
        int8x16_t qa1_lo = vld1q_s8(y[i+1].qs);
        int8x16_t qa1_hi = vld1q_s8(y[i+1].qs + 16);
        int8x16_t qa2_lo = vld1q_s8(y[i+2].qs);
        int8x16_t qa2_hi = vld1q_s8(y[i+2].qs + 16);
        int8x16_t qa3_lo = vld1q_s8(y[i+3].qs);
        int8x16_t qa3_hi = vld1q_s8(y[i+3].qs + 16);
        
        // Extract low and high nibbles from 4-bit weights
        int8x16_t qw0_lo = vreinterpretq_s8_u8(vandq_u8(qw0, vdupq_n_u8(0x0F)));
        int8x16_t qw0_hi = vreinterpretq_s8_u8(vshrq_n_u8(qw0, 4));
        int8x16_t qw1_lo = vreinterpretq_s8_u8(vandq_u8(qw1, vdupq_n_u8(0x0F)));
        int8x16_t qw1_hi = vreinterpretq_s8_u8(vshrq_n_u8(qw1, 4));
        int8x16_t qw2_lo = vreinterpretq_s8_u8(vandq_u8(qw2, vdupq_n_u8(0x0F)));
        int8x16_t qw2_hi = vreinterpretq_s8_u8(vshrq_n_u8(qw2, 4));
        int8x16_t qw3_lo = vreinterpretq_s8_u8(vandq_u8(qw3, vdupq_n_u8(0x0F)));
        int8x16_t qw3_hi = vreinterpretq_s8_u8(vshrq_n_u8(qw3, 4));
        
        // Subtract 8 to convert from unsigned to signed 4-bit
        const int8x16_t offset = vdupq_n_s8(8);
        qw0_lo = vsubq_s8(qw0_lo, offset);
        qw0_hi = vsubq_s8(qw0_hi, offset);
        qw1_lo = vsubq_s8(qw1_lo, offset);
        qw1_hi = vsubq_s8(qw1_hi, offset);
        qw2_lo = vsubq_s8(qw2_lo, offset);
        qw2_hi = vsubq_s8(qw2_hi, offset);
        qw3_lo = vsubq_s8(qw3_lo, offset);
        qw3_hi = vsubq_s8(qw3_hi, offset);
        
        // Perform dot products using ARM dot product instructions
        int32x4_t dot0 = vdupq_n_s32(0);
        int32x4_t dot1 = vdupq_n_s32(0);
        int32x4_t dot2 = vdupq_n_s32(0);
        int32x4_t dot3 = vdupq_n_s32(0);
        
        dot0 = vdotq_s32(dot0, qw0_lo, qa0_lo);
        dot0 = vdotq_s32(dot0, qw0_hi, qa0_hi);
        dot1 = vdotq_s32(dot1, qw1_lo, qa1_lo);
        dot1 = vdotq_s32(dot1, qw1_hi, qa1_hi);
        dot2 = vdotq_s32(dot2, qw2_lo, qa2_lo);
        dot2 = vdotq_s32(dot2, qw2_hi, qa2_hi);
        dot3 = vdotq_s32(dot3, qw3_lo, qa3_lo);
        dot3 = vdotq_s32(dot3, qw3_hi, qa3_hi);
        
        // Sum the dot products horizontally
        int32_t scalar0 = vaddvq_s32(dot0);
        int32_t scalar1 = vaddvq_s32(dot1);
        int32_t scalar2 = vaddvq_s32(dot2);
        int32_t scalar3 = vaddvq_s32(dot3);
        
        // Load scales and accumulate
        float scale0 = GGML_FP16_TO_FP32(x[i+0].d) * GGML_FP16_TO_FP32(y[i+0].d);
        float scale1 = GGML_FP16_TO_FP32(x[i+1].d) * GGML_FP16_TO_FP32(y[i+1].d);
        float scale2 = GGML_FP16_TO_FP32(x[i+2].d) * GGML_FP16_TO_FP32(y[i+2].d);
        float scale3 = GGML_FP16_TO_FP32(x[i+3].d) * GGML_FP16_TO_FP32(y[i+3].d);
        
        sum0 = vaddq_f32(sum0, vmulq_n_f32(vdupq_n_f32((float)scalar0), scale0));
        sum1 = vaddq_f32(sum1, vmulq_n_f32(vdupq_n_f32((float)scalar1), scale1));
        sum2 = vaddq_f32(sum2, vmulq_n_f32(vdupq_n_f32((float)scalar2), scale2));
        sum3 = vaddq_f32(sum3, vmulq_n_f32(vdupq_n_f32((float)scalar3), scale3));
    }
    
    // Handle remaining blocks
    for (; i < nb; i++) {
        uint8x16_t qw = vld1q_u8(x[i].qs);
        int8x16_t qa_lo = vld1q_s8(y[i].qs);
        int8x16_t qa_hi = vld1q_s8(y[i].qs + 16);
        
        int8x16_t qw_lo = vreinterpretq_s8_u8(vandq_u8(qw, vdupq_n_u8(0x0F)));
        int8x16_t qw_hi = vreinterpretq_s8_u8(vshrq_n_u8(qw, 4));
        
        qw_lo = vsubq_s8(qw_lo, vdupq_n_s8(8));
        qw_hi = vsubq_s8(qw_hi, vdupq_n_s8(8));
        
        int32x4_t dot = vdupq_n_s32(0);
        dot = vdotq_s32(dot, qw_lo, qa_lo);
        dot = vdotq_s32(dot, qw_hi, qa_hi);
        
        int32_t scalar = vaddvq_s32(dot);
        float scale = GGML_FP16_TO_FP32(x[i].d) * GGML_FP16_TO_FP32(y[i].d);
        
        sum0 = vaddq_f32(sum0, vmulq_n_f32(vdupq_n_f32((float)scalar), scale));
    }
    
    // Final reduction
    float32x4_t total = vaddq_f32(vaddq_f32(sum0, sum1), vaddq_f32(sum2, sum3));
    *s = vaddvq_f32(total);
}

//
// Ultra-optimized matrix vector multiplication for Q4_0 x Q8_0
// Uses interleaved NEON operations for maximum throughput
//
static inline void ggml_gemv_q4_0_q8_0_neon_ultra(int n, float * restrict s, 
                                                   const void * restrict vx, 
                                                   const void * restrict vy, 
                                                   int nr, int nc) {
    const int qk = 32;
    const int nb = n / qk;
    
    const block_q4_0 * restrict x = (const block_q4_0 *) vx;
    const block_q8_0 * restrict y = (const block_q8_0 *) vy;
    
    // Process 8 output elements at once for better cache usage
    for (int i = 0; i < nr; i += 8) {
        int rows_to_process = (nr - i) >= 8 ? 8 : (nr - i);
        
        // Initialize accumulators
        float32x4_t acc0 = vdupq_n_f32(0.0f);
        float32x4_t acc1 = vdupq_n_f32(0.0f);
        float32x4_t acc2 = vdupq_n_f32(0.0f);
        float32x4_t acc3 = vdupq_n_f32(0.0f);
        float32x4_t acc4 = vdupq_n_f32(0.0f);
        float32x4_t acc5 = vdupq_n_f32(0.0f);
        float32x4_t acc6 = vdupq_n_f32(0.0f);
        float32x4_t acc7 = vdupq_n_f32(0.0f);
        
        for (int j = 0; j < nb; j++) {
            // Load input vector block
            uint8x16_t qw = vld1q_u8(y[j].qs);
            int8x16_t qa_lo = vld1q_s8(y[j].qs);
            int8x16_t qa_hi = vld1q_s8(y[j].qs + 16);
            
            // Extract nibbles
            int8x16_t qw_lo = vreinterpretq_s8_u8(vandq_u8(qw, vdupq_n_u8(0x0F)));
            int8x16_t qw_hi = vreinterpretq_s8_u8(vshrq_n_u8(qw, 4));
            qw_lo = vsubq_s8(qw_lo, vdupq_n_s8(8));
            qw_hi = vsubq_s8(qw_hi, vdupq_n_s8(8));
            
            float y_scale = GGML_FP16_TO_FP32(y[j].d);
            
            // Process up to 8 rows simultaneously
            for (int r = 0; r < rows_to_process; r++) {
                const block_q4_0 * x_row = x + (i + r) * nb + j;
                
                uint8x16_t xw = vld1q_u8(x_row->qs);
                int8x16_t xw_lo = vreinterpretq_s8_u8(vandq_u8(xw, vdupq_n_u8(0x0F)));
                int8x16_t xw_hi = vreinterpretq_s8_u8(vshrq_n_u8(xw, 4));
                xw_lo = vsubq_s8(xw_lo, vdupq_n_s8(8));
                xw_hi = vsubq_s8(xw_hi, vdupq_n_s8(8));
                
                // Dot products
                int32x4_t dot = vdupq_n_s32(0);
                dot = vdotq_s32(dot, xw_lo, qa_lo);
                dot = vdotq_s32(dot, xw_hi, qa_hi);
                
                int32_t scalar = vaddvq_s32(dot);
                float scale = GGML_FP16_TO_FP32(x_row->d) * y_scale;
                float result = (float)scalar * scale;
                
                // Accumulate to appropriate register
                switch(r) {
                    case 0: acc0 = vaddq_f32(acc0, vdupq_n_f32(result)); break;
                    case 1: acc1 = vaddq_f32(acc1, vdupq_n_f32(result)); break;
                    case 2: acc2 = vaddq_f32(acc2, vdupq_n_f32(result)); break;
                    case 3: acc3 = vaddq_f32(acc3, vdupq_n_f32(result)); break;
                    case 4: acc4 = vaddq_f32(acc4, vdupq_n_f32(result)); break;
                    case 5: acc5 = vaddq_f32(acc5, vdupq_n_f32(result)); break;
                    case 6: acc6 = vaddq_f32(acc6, vdupq_n_f32(result)); break;
                    case 7: acc7 = vaddq_f32(acc7, vdupq_n_f32(result)); break;
                }
            }
        }
        
        // Store results
        if (rows_to_process >= 1) s[i + 0] = vaddvq_f32(acc0);
        if (rows_to_process >= 2) s[i + 1] = vaddvq_f32(acc1);
        if (rows_to_process >= 3) s[i + 2] = vaddvq_f32(acc2);
        if (rows_to_process >= 4) s[i + 3] = vaddvq_f32(acc3);
        if (rows_to_process >= 5) s[i + 4] = vaddvq_f32(acc4);
        if (rows_to_process >= 6) s[i + 5] = vaddvq_f32(acc5);
        if (rows_to_process >= 7) s[i + 6] = vaddvq_f32(acc6);
        if (rows_to_process >= 8) s[i + 7] = vaddvq_f32(acc7);
    }
}

//
// Ultra-fast GELU activation with polynomial approximation
// Optimized for ARM NEON with vectorized operations
//
static inline void ggml_vec_gelu_f32_neon_ultra(const int n, float * y, const float * x) {
    const float sqrt_2_over_pi = 0.79788456080286535587989211986876f;
    const float coeff = 0.044715f;
    
    int i = 0;
    
    // Process 16 elements at once (4 NEON registers)
    for (; i + 15 < n; i += 16) {
        float32x4_t x0 = vld1q_f32(x + i);
        float32x4_t x1 = vld1q_f32(x + i + 4);
        float32x4_t x2 = vld1q_f32(x + i + 8);
        float32x4_t x3 = vld1q_f32(x + i + 12);
        
        // Compute x^3 for polynomial approximation
        float32x4_t x0_sq = vmulq_f32(x0, x0);
        float32x4_t x1_sq = vmulq_f32(x1, x1);
        float32x4_t x2_sq = vmulq_f32(x2, x2);
        float32x4_t x3_sq = vmulq_f32(x3, x3);
        
        float32x4_t x0_cu = vmulq_f32(x0_sq, x0);
        float32x4_t x1_cu = vmulq_f32(x1_sq, x1);
        float32x4_t x2_cu = vmulq_f32(x2_sq, x2);
        float32x4_t x3_cu = vmulq_f32(x3_sq, x3);
        
        // Polynomial: x * (1 + coeff * x^2)
        float32x4_t poly0 = vfmaq_n_f32(x0, x0_cu, coeff);
        float32x4_t poly1 = vfmaq_n_f32(x1, x1_cu, coeff);
        float32x4_t poly2 = vfmaq_n_f32(x2, x2_cu, coeff);
        float32x4_t poly3 = vfmaq_n_f32(x3, x3_cu, coeff);
        
        // Multiply by sqrt(2/π)
        poly0 = vmulq_n_f32(poly0, sqrt_2_over_pi);
        poly1 = vmulq_n_f32(poly1, sqrt_2_over_pi);
        poly2 = vmulq_n_f32(poly2, sqrt_2_over_pi);
        poly3 = vmulq_n_f32(poly3, sqrt_2_over_pi);
        
        // Fast tanh approximation using rational function
        // tanh(x) ≈ x * (27 + x^2) / (27 + 9*x^2)
        float32x4_t tanh0, tanh1, tanh2, tanh3;
        {
            float32x4_t poly0_sq = vmulq_f32(poly0, poly0);
            float32x4_t poly1_sq = vmulq_f32(poly1, poly1);
            float32x4_t poly2_sq = vmulq_f32(poly2, poly2);
            float32x4_t poly3_sq = vmulq_f32(poly3, poly3);
            
            float32x4_t num0 = vfmaq_n_f32(vdupq_n_f32(27.0f), poly0_sq, 1.0f);
            float32x4_t num1 = vfmaq_n_f32(vdupq_n_f32(27.0f), poly1_sq, 1.0f);
            float32x4_t num2 = vfmaq_n_f32(vdupq_n_f32(27.0f), poly2_sq, 1.0f);
            float32x4_t num3 = vfmaq_n_f32(vdupq_n_f32(27.0f), poly3_sq, 1.0f);
            
            float32x4_t den0 = vfmaq_n_f32(vdupq_n_f32(27.0f), poly0_sq, 9.0f);
            float32x4_t den1 = vfmaq_n_f32(vdupq_n_f32(27.0f), poly1_sq, 9.0f);
            float32x4_t den2 = vfmaq_n_f32(vdupq_n_f32(27.0f), poly2_sq, 9.0f);
            float32x4_t den3 = vfmaq_n_f32(vdupq_n_f32(27.0f), poly3_sq, 9.0f);
            
            tanh0 = vmulq_f32(poly0, vdivq_f32(num0, den0));
            tanh1 = vmulq_f32(poly1, vdivq_f32(num1, den1));
            tanh2 = vmulq_f32(poly2, vdivq_f32(num2, den2));
            tanh3 = vmulq_f32(poly3, vdivq_f32(num3, den3));
        }
        
        // GELU = 0.5 * x * (1 + tanh(...))
        float32x4_t one = vdupq_n_f32(1.0f);
        float32x4_t half = vdupq_n_f32(0.5f);
        
        float32x4_t gelu0 = vmulq_f32(vmulq_f32(x0, half), vaddq_f32(one, tanh0));
        float32x4_t gelu1 = vmulq_f32(vmulq_f32(x1, half), vaddq_f32(one, tanh1));
        float32x4_t gelu2 = vmulq_f32(vmulq_f32(x2, half), vaddq_f32(one, tanh2));
        float32x4_t gelu3 = vmulq_f32(vmulq_f32(x3, half), vaddq_f32(one, tanh3));
        
        vst1q_f32(y + i, gelu0);
        vst1q_f32(y + i + 4, gelu1);
        vst1q_f32(y + i + 8, gelu2);
        vst1q_f32(y + i + 12, gelu3);
    }
    
    // Handle remaining elements
    for (; i < n; i++) {
        float val = x[i];
        float poly = val * (1.0f + coeff * val * val);
        poly *= sqrt_2_over_pi;
        
        // Fast tanh approximation
        float poly_sq = poly * poly;
        float tanh_val = poly * (27.0f + poly_sq) / (27.0f + 9.0f * poly_sq);
        
        y[i] = 0.5f * val * (1.0f + tanh_val);
    }
}

//
// Ultra-optimized SiLU (Swish) activation
// Uses ARM NEON with fast exponential approximation
//
static inline void ggml_vec_silu_f32_neon_ultra(const int n, float * y, const float * x) {
    int i = 0;
    
    // Process 16 elements at once
    for (; i + 15 < n; i += 16) {
        float32x4_t x0 = vld1q_f32(x + i);
        float32x4_t x1 = vld1q_f32(x + i + 4);
        float32x4_t x2 = vld1q_f32(x + i + 8);
        float32x4_t x3 = vld1q_f32(x + i + 12);
        
        // Fast sigmoid approximation: 1 / (1 + exp(-x))
        // Using polynomial approximation for exp(-x)
        float32x4_t neg_x0 = vnegq_f32(x0);
        float32x4_t neg_x1 = vnegq_f32(x1);
        float32x4_t neg_x2 = vnegq_f32(x2);
        float32x4_t neg_x3 = vnegq_f32(x3);
        
        // Fast exp approximation using ARM-optimized method
        // exp(x) ≈ (1 + x/2^n)^(2^n) with n=10
        const float scale = 1.0f / 1024.0f; // 1/2^10
        
        float32x4_t scaled0 = vfmaq_n_f32(vdupq_n_f32(1.0f), neg_x0, scale);
        float32x4_t scaled1 = vfmaq_n_f32(vdupq_n_f32(1.0f), neg_x1, scale);
        float32x4_t scaled2 = vfmaq_n_f32(vdupq_n_f32(1.0f), neg_x2, scale);
        float32x4_t scaled3 = vfmaq_n_f32(vdupq_n_f32(1.0f), neg_x3, scale);
        
        // Repeated squaring (10 times for 2^10)
        for (int j = 0; j < 10; j++) {
            scaled0 = vmulq_f32(scaled0, scaled0);
            scaled1 = vmulq_f32(scaled1, scaled1);
            scaled2 = vmulq_f32(scaled2, scaled2);
            scaled3 = vmulq_f32(scaled3, scaled3);
        }
        
        // sigmoid = 1 / (1 + exp(-x))
        float32x4_t one = vdupq_n_f32(1.0f);
        float32x4_t sigmoid0 = vdivq_f32(one, vaddq_f32(one, scaled0));
        float32x4_t sigmoid1 = vdivq_f32(one, vaddq_f32(one, scaled1));
        float32x4_t sigmoid2 = vdivq_f32(one, vaddq_f32(one, scaled2));
        float32x4_t sigmoid3 = vdivq_f32(one, vaddq_f32(one, scaled3));
        
        // SiLU = x * sigmoid(x)
        float32x4_t silu0 = vmulq_f32(x0, sigmoid0);
        float32x4_t silu1 = vmulq_f32(x1, sigmoid1);
        float32x4_t silu2 = vmulq_f32(x2, sigmoid2);
        float32x4_t silu3 = vmulq_f32(x3, sigmoid3);
        
        vst1q_f32(y + i, silu0);
        vst1q_f32(y + i + 4, silu1);
        vst1q_f32(y + i + 8, silu2);
        vst1q_f32(y + i + 12, silu3);
    }
    
    // Handle remaining elements
    for (; i < n; i++) {
        float val = x[i];
        // Fast sigmoid using lookup table or polynomial
        float sigmoid_val = 1.0f / (1.0f + expf(-val));
        y[i] = val * sigmoid_val;
    }
}

//
// Ultra-optimized RMS normalization
// Uses ARM NEON with efficient reduction and rsqrt
//
static inline void ggml_vec_norm_f32_neon_ultra(const int n, float * s, const float * x) {
    float32x4_t sum = vdupq_n_f32(0.0f);
    
    int i = 0;
    // Vectorized sum of squares
    for (; i + 15 < n; i += 16) {
        float32x4_t x0 = vld1q_f32(x + i);
        float32x4_t x1 = vld1q_f32(x + i + 4);
        float32x4_t x2 = vld1q_f32(x + i + 8);
        float32x4_t x3 = vld1q_f32(x + i + 12);
        
        sum = vfmaq_f32(sum, x0, x0);
        sum = vfmaq_f32(sum, x1, x1);
        sum = vfmaq_f32(sum, x2, x2);
        sum = vfmaq_f32(sum, x3, x3);
    }
    
    // Handle remaining elements
    for (; i < n; i++) {
        sum = vfmaq_n_f32(sum, vdupq_n_f32(x[i]), x[i]);
    }
    
    // Horizontal sum
    float total = vaddvq_f32(sum);
    
    // Fast inverse square root
    float mean = total / n;
    float rsqrt_val = vrsqrteq_f32(vdupq_n_f32(mean))[0];
    
    // Newton-Raphson iteration for higher precision
    float x_half = mean * 0.5f;
    rsqrt_val = rsqrt_val * (1.5f - x_half * rsqrt_val * rsqrt_val);
    
    *s = 1.0f / sqrtf(mean);
}

//
// Ultra-fast softmax with vectorized operations
// Optimized for numerical stability and performance
//
static inline float ggml_vec_soft_max_f32_neon_ultra(const int n, float * y, const float * x, float max_val) {
    // Find maximum value for numerical stability
    float32x4_t max_vec = vdupq_n_f32(max_val);
    
    int i = 0;
    float32x4_t sum_vec = vdupq_n_f32(0.0f);
    
    // Vectorized exp computation
    for (; i + 15 < n; i += 16) {
        float32x4_t x0 = vld1q_f32(x + i);
        float32x4_t x1 = vld1q_f32(x + i + 4);
        float32x4_t x2 = vld1q_f32(x + i + 8);
        float32x4_t x3 = vld1q_f32(x + i + 12);
        
        // Subtract max for numerical stability
        x0 = vsubq_f32(x0, max_vec);
        x1 = vsubq_f32(x1, max_vec);
        x2 = vsubq_f32(x2, max_vec);
        x3 = vsubq_f32(x3, max_vec);
        
        // Fast exp using ARM optimized routine
        float32x4_t exp0 = ggml_v_expf(x0);
        float32x4_t exp1 = ggml_v_expf(x1);
        float32x4_t exp2 = ggml_v_expf(x2);
        float32x4_t exp3 = ggml_v_expf(x3);
        
        vst1q_f32(y + i, exp0);
        vst1q_f32(y + i + 4, exp1);
        vst1q_f32(y + i + 8, exp2);
        vst1q_f32(y + i + 12, exp3);
        
        sum_vec = vaddq_f32(sum_vec, exp0);
        sum_vec = vaddq_f32(sum_vec, exp1);
        sum_vec = vaddq_f32(sum_vec, exp2);
        sum_vec = vaddq_f32(sum_vec, exp3);
    }
    
    // Handle remaining elements
    for (; i < n; i++) {
        float val = expf(x[i] - max_val);
        y[i] = val;
        sum_vec = vaddq_f32(sum_vec, vdupq_n_f32(val));
    }
    
    float sum = vaddvq_f32(sum_vec);
    
    // Vectorized division by sum
    float32x4_t inv_sum = vdupq_n_f32(1.0f / sum);
    i = 0;
    for (; i + 15 < n; i += 16) {
        float32x4_t y0 = vld1q_f32(y + i);
        float32x4_t y1 = vld1q_f32(y + i + 4);
        float32x4_t y2 = vld1q_f32(y + i + 8);
        float32x4_t y3 = vld1q_f32(y + i + 12);
        
        y0 = vmulq_f32(y0, inv_sum);
        y1 = vmulq_f32(y1, inv_sum);
        y2 = vmulq_f32(y2, inv_sum);
        y3 = vmulq_f32(y3, inv_sum);
        
        vst1q_f32(y + i, y0);
        vst1q_f32(y + i + 4, y1);
        vst1q_f32(y + i + 8, y2);
        vst1q_f32(y + i + 12, y3);
    }
    
    for (; i < n; i++) {
        y[i] /= sum;
    }
    
    return sum;
}

// Helper function to include ARM-optimized exponential from vec.h
extern inline float32x4_t ggml_v_expf(float32x4_t x);

#endif // __aarch64__