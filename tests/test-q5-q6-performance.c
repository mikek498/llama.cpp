#include "ggml.h"
#include "ggml-alloc.h"
#include "ggml-backend.h"
#include "ggml-quants.h"
#include "ggml-common.h"

#if defined(_MSC_VER)
#pragma warning(disable: 4244 4267) // possible loss of data
#endif

#include <assert.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <time.h>
#include <stdint.h>
#include <inttypes.h>
#include <math.h>

#if defined(_WIN32)
#include <windows.h>
#else
#include <sys/time.h>
#endif

// Define the missing macros
#define UNUSED(x) (void)(x)

// From ggml-impl.h (need to recreate here to avoid dependency issues)
#define GGML_FP16_TO_FP32(x) (ggml_fp16_to_fp32(x))

// Simple quantization functions for testing
static size_t quantize_q5_K_test(const float * src, void * dst, int64_t n, int64_t k, const float * scale) {
    UNUSED(src);
    UNUSED(k);
    UNUSED(scale);
    
    // Create some simple test data - this is just for testing the dot product functions, 
    // not for actual quantization quality
    const size_t nb = (n + QK_K - 1) / QK_K;
    block_q5_K * restrict y = dst;
    
    for (size_t i = 0; i < nb; i++) {
        // Set scales
        for (int j = 0; j < 12; j++) {
            y[i].scales[j] = 1 + (j % 4); // Some varied scales
        }
        
        // Set d and dmin
        y[i].d = ggml_fp32_to_fp16(1.0f);
        y[i].dmin = ggml_fp32_to_fp16(0.5f);
        
        // Set quantized values
        for (int j = 0; j < QK_K / 2; j++) {
            // Create a pattern that will generate non-zero dot products
            y[i].qs[j] = (j % 3 == 0) ? 0x93 : 0x39; // 1001 0011 or 0011 1001 pattern
        }
        
        // Set qh values - higher bits
        for (int j = 0; j < QK_K / 8; j++) {
            y[i].qh[j] = 0x55; // 0101 0101 pattern
        }
    }
    
    return nb * sizeof(block_q5_K);
}

static size_t quantize_q6_K_test(const float * src, void * dst, int64_t n, int64_t k, const float * scale) {
    UNUSED(src);
    UNUSED(k);
    UNUSED(scale);
    
    // Create some simple test data - this is just for testing the dot product functions, 
    // not for actual quantization quality
    const size_t nb = (n + QK_K - 1) / QK_K;
    block_q6_K * restrict y = dst;
    
    for (size_t i = 0; i < nb; i++) {
        // Set scales
        for (int j = 0; j < QK_K / 16; j++) {
            y[i].scales[j] = 1 + (j % 4); // Some varied scales
        }
        
        // Set d 
        y[i].d = ggml_fp32_to_fp16(1.0f);
        
        // Set ql values - lower 4 bits
        for (int j = 0; j < 3 * QK_K / 4; j++) {
            y[i].ql[j] = 0x5A; // 0101 1010 pattern - different values
        }
        
        // Set qh values - higher 2 bits
        for (int j = 0; j < QK_K / 4; j++) {
            y[i].qh[j] = 0x55; // 0101 0101 pattern
        }
    }
    
    return nb * sizeof(block_q6_K);
}

static size_t quantize_q8_K_test(const float * src, void * dst, int64_t n, int64_t k, const float * scale) {
    UNUSED(src);
    UNUSED(k);
    UNUSED(scale);
    
    // Create some simple test data - this is just for testing the dot product functions, 
    // not for actual quantization quality
    const size_t nb = (n + QK_K - 1) / QK_K;
    block_q8_K * restrict y = dst;
    
    for (size_t i = 0; i < nb; i++) {
        // Set scale
        y[i].d = 1.0f;
        
        // Set quantized values - all Q8_K values are 8-bit signed integers (-128 to 127)
        for (int j = 0; j < QK_K; j++) {
            // Create a more varied pattern to generate non-zero dot products
            y[i].qs[j] = j % 4 == 0 ? 4 : 
                        j % 4 == 1 ? -3 : 
                        j % 4 == 2 ? 2 : -1;
        }
    }
    
    return nb * sizeof(block_q8_K);
}

static inline double get_time_in_ns(void) {
#if defined(_WIN32)
    static LARGE_INTEGER frequency;
    static BOOL has_frequency = FALSE;

    if (!has_frequency) {
        QueryPerformanceFrequency(&frequency);
        has_frequency = TRUE;
    }

    LARGE_INTEGER counter;
    QueryPerformanceCounter(&counter);
    return (1e9 * counter.QuadPart) / frequency.QuadPart;
#else
    struct timespec time;
    clock_gettime(CLOCK_MONOTONIC, &time);
    return time.tv_sec * 1e9 + time.tv_nsec;
#endif
}

// Reference scalar implementations for benchmarking
static void ggml_vec_dot_q5_K_q8_K_ref(int n, float * GGML_RESTRICT s, size_t bs, const void * GGML_RESTRICT vx, size_t bx, const void * GGML_RESTRICT vy, size_t by, int nrc) {
    assert(n % QK_K == 0);
    assert(nrc == 1);
    UNUSED(nrc);
    UNUSED(bx);
    UNUSED(by);
    UNUSED(bs);

    const block_q5_K * GGML_RESTRICT x = vx;
    const block_q8_K * GGML_RESTRICT y = vy;

    const int nb = n / QK_K;

    static const uint32_t kmask1 = 0x3f3f3f3f;
    static const uint32_t kmask2 = 0x0f0f0f0f;
    static const uint32_t kmask3 = 0x03030303;

    float sumf = 0.0f;

    for (int i = 0; i < nb; ++i) {
        const float d = y[i].d * GGML_FP16_TO_FP32(x[i].d);
        const float dmin = -y[i].d * GGML_FP16_TO_FP32(x[i].dmin);

        const uint8_t * GGML_RESTRICT q5 = x[i].qs;
        const uint8_t * GGML_RESTRICT qh = x[i].qh;
        const int8_t  * GGML_RESTRICT q8 = y[i].qs;

        // Extract scales from the x block
        uint32_t scales_and_mins[4];
        memcpy(scales_and_mins, x[i].scales, 12);
        uint32_t scales_tmp = scales_and_mins[2];
        scales_and_mins[2] = ((scales_tmp >> 4) & kmask2) | (((scales_and_mins[1] >> 6) & kmask3) << 4);
        UNUSED(kmask1); // Avoid unused variable warning
        scales_and_mins[1] = (scales_tmp & kmask2) | (((scales_and_mins[0] >> 6) & kmask3) << 4);
        scales_and_mins[0] &= kmask1;
        
        const uint8_t * scales = (const uint8_t *)scales_and_mins;
        const uint8_t * mins = scales + 8;

        // q8 block has 16 pairs of consecutive values with same scale
        // process each pair of sub-blocks with same scale
        int32_t sumi = 0;

        for (int j = 0; j < QK_K/16; ++j) {
            const uint8_t sc = scales[j];

            const uint8_t vh0 = qh[j] & 0xF; // higher bits for values 0-7
            const uint8_t vh1 = qh[j] >> 4;  // higher bits for values 8-15

            const int8_t sm = mins[j/2]; // minimum value for the sub-block of 16 values

            // Process 16 values, 8 at a time
            for (int k = 0; k < 8; ++k) {
                // Extract higher bits and lower bits for q5
                const uint8_t v0 = (q5[j/2*8 + k] & 0xF) | ((vh0 & (1 << k)) << (4-k));
                
                // Subtract 16 to get the actual value in the range [-16,15]
                const int8_t q5_0 = v0 - 16;
                
                // Multiply q5 with q8 and scale
                sumi += q5_0 * q8[j*16 + k] * sc;
            }

            for (int k = 0; k < 8; ++k) {
                // Extract higher bits and lower bits for q5
                const uint8_t v1 = (q5[j/2*8 + k] >> 4) | ((vh1 & (1 << k)) << (4-k));
                
                // Subtract 16 to get the actual value in the range [-16,15]
                const int8_t q5_1 = v1 - 16;
                
                // Multiply q5 with q8 and scale
                sumi += q5_1 * q8[j*16 + 8 + k] * sc;
            }

            // Subtract sum(mins[k/2] * q8[j*16 + k]) * scale
            sumi -= sm * sc * (
                q8[j*16 + 0] + q8[j*16 + 1] + q8[j*16 + 2] + q8[j*16 + 3] + 
                q8[j*16 + 4] + q8[j*16 + 5] + q8[j*16 + 6] + q8[j*16 + 7] + 
                q8[j*16 + 8] + q8[j*16 + 9] + q8[j*16 + 10] + q8[j*16 + 11] + 
                q8[j*16 + 12] + q8[j*16 + 13] + q8[j*16 + 14] + q8[j*16 + 15]
            );
        }

        sumf += sumi * d;

        // Calculate the sum of products of q8 sums and mins
        int32_t sumi_mins = 0;
        for (int j = 0; j < QK_K/16; ++j) {
            const int8_t min_j = mins[j/2];
            const int16_t q8sum_j = 
                q8[j*16 + 0] + q8[j*16 + 1] + q8[j*16 + 2] + q8[j*16 + 3] + 
                q8[j*16 + 4] + q8[j*16 + 5] + q8[j*16 + 6] + q8[j*16 + 7] + 
                q8[j*16 + 8] + q8[j*16 + 9] + q8[j*16 + 10] + q8[j*16 + 11] + 
                q8[j*16 + 12] + q8[j*16 + 13] + q8[j*16 + 14] + q8[j*16 + 15];
            sumi_mins += min_j * q8sum_j * scales[j];
        }

        sumf += dmin * sumi_mins;
    }

    *s = sumf;
}

static void ggml_vec_dot_q6_K_q8_K_ref(int n, float * GGML_RESTRICT s, size_t bs, const void * GGML_RESTRICT vx, size_t bx, const void * GGML_RESTRICT vy, size_t by, int nrc) {
    assert(n % QK_K == 0);
    assert(nrc == 1);
    UNUSED(nrc);
    UNUSED(bx);
    UNUSED(by);
    UNUSED(bs);

    const block_q6_K * GGML_RESTRICT x = vx;
    const block_q8_K * GGML_RESTRICT y = vy;

    const int nb = n / QK_K;

    float sumf = 0.0f;

    for (int i = 0; i < nb; ++i) {
        const float d = y[i].d * GGML_FP16_TO_FP32(x[i].d);

        const uint8_t * GGML_RESTRICT ql = x[i].ql;
        const uint8_t * GGML_RESTRICT qh = x[i].qh;
        const int8_t  * GGML_RESTRICT q8 = y[i].qs;

        // Process 16 blocks, each with 16 values
        int32_t sumi = 0;

        for (int j = 0; j < QK_K/16; ++j) {
            // q6 has 6 bits per value for each weight
            // Extract scale for this block of 16 values
            const int8_t sc = x[i].scales[j];

            for (int k = 0; k < 16; ++k) {
                // Get combined 6-bit value using the lower 4 bits and higher 2 bits
                int kbq = k/8;
                int kqh = (k%8)*2;
                
                // Extract the lower 4 bits from ql
                int ql_shifted = j*32 + (k/4) * 8 + (k % 4) * 2;
                const uint8_t vl = (ql[ql_shifted/8] >> (ql_shifted%8)) & 0xF;
                
                // Extract the higher 2 bits from qh
                int qh_shifted = j*32 + kbq * 16 + kqh;
                const uint8_t vh = (qh[qh_shifted/8] >> (qh_shifted%8)) & 0x3;
                
                // Combine into 6-bit value in range [0, 63]
                const int8_t vi = vl | (vh << 4);
                
                // Adjust to get value in range [-32, 31]
                const int8_t q6 = vi - 32;
                
                // Multiply q6 with q8
                sumi += q6 * q8[j*16 + k] * sc;
            }
        }

        sumf += sumi * d;
    }

    *s = sumf;
}

// Optimized scalar implementation for Q5_K
static void ggml_vec_dot_q5_K_q8_K_optimized(int n, float * GGML_RESTRICT s, size_t bs, const void * GGML_RESTRICT vx, size_t bx, const void * GGML_RESTRICT vy, size_t by, int nrc) {
    assert(n % QK_K == 0);
    assert(nrc == 1);
    UNUSED(nrc);
    UNUSED(bx);
    UNUSED(by);
    UNUSED(bs);

    const block_q5_K * GGML_RESTRICT x = vx;
    const block_q8_K * GGML_RESTRICT y = vy;

    const int nb = n / QK_K;

    // Debug first block
    if (0) {
        printf("Q5_K first block:\n");
        printf("d: %f, dmin: %f\n", GGML_FP16_TO_FP32(x[0].d), GGML_FP16_TO_FP32(x[0].dmin));
        printf("scales (first few): ");
        for (int i = 0; i < 4; i++) {
            printf("%02x ", x[0].scales[i]);
        }
        printf("\n");
        
        printf("First 8 q5 values: ");
        // Extract and display actual q5 values
        const uint8_t * q5 = x[0].qs;
        const uint8_t * qh = x[0].qh;
        const uint8_t vh0 = qh[0] & 0xF; // higher bits for values 0-7
        for (int k = 0; k < 8; ++k) {
            const uint8_t vi = (q5[k] & 0xF) | ((vh0 & (1 << k)) << (4-k));
            const int8_t q5val = vi - 16;
            printf("%d ", q5val);
        }
        printf("\n");
        
        printf("First 8 q8 values: ");
        const int8_t * q8 = y[0].qs;
        for (int k = 0; k < 8; ++k) {
            printf("%d ", q8[k]);
        }
        printf("\n");
    }

    static const uint32_t kmask1 = 0x3f3f3f3f;
    static const uint32_t kmask2 = 0x0f0f0f0f;
    static const uint32_t kmask3 = 0x03030303;

    float sumf = 0.0f;

    // Loop over blocks
    for (int i = 0; i < nb; ++i) {
        // Extract block scale and min
        const float d = y[i].d * GGML_FP16_TO_FP32(x[i].d);
        const float dmin = y[i].d * GGML_FP16_TO_FP32(x[i].dmin); // No negation to match current impl
        
        // Process scales from the x block
        uint32_t scales_and_mins[4];
        memcpy(scales_and_mins, x[i].scales, 12);
        uint32_t scales_tmp = scales_and_mins[2];
        scales_and_mins[2] = ((scales_tmp >> 4) & kmask2) | (((scales_and_mins[1] >> 6) & kmask3) << 4);
        scales_and_mins[1] = (scales_tmp & kmask2) | (((scales_and_mins[0] >> 6) & kmask3) << 4);
        scales_and_mins[0] &= kmask1;
        
        const uint8_t * scales = (const uint8_t *)scales_and_mins;
        const uint8_t * mins = scales + 8; // mins are stored after scales

        const uint8_t * GGML_RESTRICT q5 = x[i].qs;
        const uint8_t * GGML_RESTRICT qh = x[i].qh;
        const int8_t  * GGML_RESTRICT q8 = y[i].qs;
        
        // This implementation is designed to exactly match the current implementation for dot product
        int32_t sumi = 0;
        
        // Process groups of 16 values (matching current implementation)
        for (int j = 0; j < QK_K/16; ++j) {
            const uint8_t sc = scales[j];
            const uint8_t m  = mins[j/2];
            
            const uint8_t vh0 = qh[j] & 0xF;
            const uint8_t vh1 = qh[j] >> 4;

            int sum_x = 0;
            
            // First 8 values
            for (int k = 0; k < 8; ++k) {
                const uint8_t v0 = (q5[j/2*8 + k] & 0xF) | ((vh0 & (1 << k)) << (4-k));
                sum_x += q8[j*16 + k] * (v0 - 16);
            }
            
            // Second 8 values
            for (int k = 0; k < 8; ++k) {
                const uint8_t v1 = (q5[j/2*8 + k] >> 4) | ((vh1 & (1 << k)) << (4-k));
                sum_x += q8[j*16 + 8 + k] * (v1 - 16);
            }
            
            // Calculate sum of q8 values
            int16_t q8sum = 0;
            for (int k = 0; k < 16; k++) {
                q8sum += q8[j*16 + k];
            }
            
            sumi += sum_x * sc - m * sc * q8sum;
        }
        
        sumf += d * sumi;
    }
    
    *s = sumf;
}

// Optimized scalar implementation for Q6_K
static void ggml_vec_dot_q6_K_q8_K_optimized(int n, float * GGML_RESTRICT s, size_t bs, const void * GGML_RESTRICT vx, size_t bx, const void * GGML_RESTRICT vy, size_t by, int nrc) {
    assert(n % QK_K == 0);
    assert(nrc == 1);
    UNUSED(nrc);
    UNUSED(bx);
    UNUSED(by);
    UNUSED(bs);

    const block_q6_K * GGML_RESTRICT x = vx;
    const block_q8_K * GGML_RESTRICT y = vy;

    const int nb = n / QK_K;

    float sumf = 0.0f;

    // For debugging 
    if (0) {
        const uint8_t * ql = x[0].ql;
        const uint8_t * qh = x[0].qh;
        printf("Q6_K Block 0 data: ql[0]=%02x, qh[0]=%02x, d=%f\n", 
               ql[0], qh[0], GGML_FP16_TO_FP32(x[0].d));
    }

    // Loop over blocks
    for (int i = 0; i < nb; ++i) {
        // Calculate scale factor
        const float d = y[i].d * GGML_FP16_TO_FP32(x[i].d);

        // Access the quantized values
        const uint8_t * GGML_RESTRICT ql = x[i].ql;
        const uint8_t * GGML_RESTRICT qh = x[i].qh;
        const int8_t  * GGML_RESTRICT q8 = y[i].qs;
        const int8_t  * GGML_RESTRICT sc = x[i].scales;

        int32_t sumi = 0;

        // Process each block of 16 values - we follow the exact pattern of the current implementation
        for (int j = 0; j < QK_K/16; ++j) {
            const int8_t scale = sc[j];
            
            // Calculate offset in byte arrays
            const int bit_offset_ql = j * 96; // 6 bits * 16 values = 96 bits
            const int bit_offset_qh = j * 32; // 2 bits * 16 values = 32 bits
            
            // Process all 16 values in this block
            int shift_ql = 0;
            int shift_qh = 0;
            int iql = 0;
            int iqh = 0;
            
            int sum_x = 0;
            
            for (int l = 0; l < 16; ++l) {
                // Calculate byte offsets and bit shifts for both ql and qh
                const int ql_byte_off = (bit_offset_ql + l*6) / 8;
                shift_ql = (bit_offset_ql + l*6) % 8;
                iql = ql_byte_off;
                
                const int qh_byte_off = (bit_offset_qh + l*2) / 8;
                shift_qh = (bit_offset_qh + l*2) % 8;
                iqh = qh_byte_off;
                
                // Extract the 6 lower bits - handle byte boundary crossing
                uint8_t ql_val;
                if (shift_ql <= 2) {
                    // All bits within the same byte
                    ql_val = (ql[iql] >> shift_ql) & 0x3F;
                } else {
                    // Bits cross a byte boundary
                    ql_val = (ql[iql] >> shift_ql) | ((ql[iql + 1] & ((1 << (shift_ql - 2)) - 1)) << (8 - shift_ql));
                    ql_val &= 0x3F; // Ensure we only have 6 bits
                }
                
                // Extract the 2 higher bits
                const uint8_t qh_val = (qh[iqh] >> shift_qh) & 0x3;
                
                // Combine and convert to a signed value
                const int8_t v = ((qh_val << 6) | ql_val) - 32;
                
                // Accumulate the product with q8
                sum_x += v * q8[j*16 + l];
            }
            
            sumi += sum_x * scale;
        }

        sumf += sumi * d;
    }

    *s = sumf;
}

// Helper function to debug Q6_K quantization values
static void debug_q6k_values(const void * GGML_RESTRICT vx, const void * GGML_RESTRICT vy) {
    const block_q6_K * GGML_RESTRICT x = vx;
    const block_q8_K * GGML_RESTRICT y = vy;
    
    printf("\nDebug Q6_K values:\n");
    
    // Print the first few values from the first block
    printf("Q6_K Block first values:\n");
    
    const uint8_t * ql = x[0].ql;
    const uint8_t * qh = x[0].qh;
    const int8_t  * q8 = y[0].qs;
    const int8_t  * sc = x[0].scales;
    
    printf("  scales[0-3]: %d %d %d %d\n", sc[0], sc[1], sc[2], sc[3]);
    printf("  ql bytes[0-3]: %02x %02x %02x %02x\n", ql[0], ql[1], ql[2], ql[3]);
    printf("  qh bytes[0-3]: %02x %02x %02x %02x\n", qh[0], qh[1], qh[2], qh[3]);
    
    // Extract and display the first few actual values
    printf("  Extracted first 8 values:\n  ");
    for (int i = 0; i < 8; i++) {
        int ql_offset = (i * 6) / 8;
        int qh_offset = i / 8;
        
        int bits_to_shift = (i * 6) % 8;
        uint8_t ql_val = 0;
        
        // Extract bits from ql
        if (bits_to_shift <= 2) {
            ql_val = (ql[ql_offset] >> bits_to_shift) & 0x3F;
        } else {
            const int bits_from_first = 8 - bits_to_shift;
            const uint8_t mask_first = (1 << bits_from_first) - 1;
            ql_val = (ql[ql_offset] >> bits_to_shift) & mask_first;
            
            const uint8_t mask_second = (1 << (6 - bits_from_first)) - 1;
            ql_val |= (ql[ql_offset + 1] & mask_second) << bits_from_first;
        }
        
        // Extract bits from qh
        int qh_bit = (i % 8) * 2;
        uint8_t qh_val = (qh[qh_offset] >> qh_bit) & 0x3;
        
        // Combine and convert to signed value
        const int8_t q6_val = ((qh_val << 6) | ql_val) - 32;
        
        printf("%d ", q6_val);
    }
    printf("\n");
    
    // Print the matching Q8 values
    printf("  First 8 q8 values: ");
    for (int i = 0; i < 8; i++) {
        printf("%d ", q8[i]);
    }
    printf("\n");
}

// Current optimized implementations
extern void ggml_vec_dot_q5_K_q8_K(int n, float * GGML_RESTRICT s, size_t bs, const void * GGML_RESTRICT vx, size_t bx, const void * GGML_RESTRICT vy,  size_t by, int nrc);
extern void ggml_vec_dot_q6_K_q8_K(int n, float * GGML_RESTRICT s, size_t bs, const void * GGML_RESTRICT vx, size_t bx, const void * GGML_RESTRICT vy, size_t by, int nrc);

static void print_quantized_data(const void * vx, size_t nelements, enum ggml_type type) {
    printf("Quantized data (%s): ", ggml_type_name(type));
    
    if (type == GGML_TYPE_Q5_K) {
        const uint8_t * data = (const uint8_t *)vx;
        for (size_t i = 0; i < nelements && i < 32; i++) {
            printf("%02x ", data[i]);
        }
    } else if (type == GGML_TYPE_Q6_K) {
        const uint8_t * data = (const uint8_t *)vx;
        for (size_t i = 0; i < nelements && i < 32; i++) {
            printf("%02x ", data[i]);
        }
    } else if (type == GGML_TYPE_Q8_K) {
        const int8_t * data = (const int8_t *)vx;
        for (size_t i = 0; i < nelements && i < 32; i++) {
            printf("%02x ", (uint8_t)data[i]);
        }
    }
    
    printf("\n");
}

int main(int argc, char** argv) {
    // Default number of iterations
    int num_iterations = 10000;

    // If an argument is provided, use it as the number of iterations
    if (argc > 1) {
        num_iterations = atoi(argv[1]);
    }

    // Test parameters
    const int n_elements = 4096; // must be a multiple of QK_K (256)
    
    // Initialize GGML
    struct ggml_init_params params = {
        .mem_size   = 128*1024*1024,
        .mem_buffer = NULL,
        .no_alloc   = false,
    };

    struct ggml_context * ctx = ggml_init(params);
    if (!ctx) {
        fprintf(stderr, "Failed to initialize ggml context\n");
        return 1;
    }

    // Create source tensors
    struct ggml_tensor * x_q5 = ggml_new_tensor_1d(ctx, GGML_TYPE_Q5_K, n_elements);
    struct ggml_tensor * x_q6 = ggml_new_tensor_1d(ctx, GGML_TYPE_Q6_K, n_elements);
    struct ggml_tensor * y_q8 = ggml_new_tensor_1d(ctx, GGML_TYPE_Q8_K, n_elements);
    struct ggml_tensor * f32 = ggml_new_tensor_1d(ctx, GGML_TYPE_F32, n_elements);

    // Populate the f32 tensor with random data
    for (int i = 0; i < n_elements; i++) {
        ((float *)f32->data)[i] = (float)rand() / RAND_MAX * 2.0f - 1.0f;
    }

    // Quantize f32 -> q5, q6, q8
    quantize_q5_K_test(f32->data, x_q5->data, n_elements, n_elements, NULL);
    quantize_q6_K_test(f32->data, x_q6->data, n_elements, n_elements, NULL);
    quantize_q8_K_test(f32->data, y_q8->data, n_elements, n_elements, NULL);

    // Verify the quantized data
    print_quantized_data(x_q5->data, n_elements, GGML_TYPE_Q5_K);
    print_quantized_data(x_q6->data, n_elements, GGML_TYPE_Q6_K);
    print_quantized_data(y_q8->data, n_elements, GGML_TYPE_Q8_K);
    
    // Debug Q6_K values
    debug_q6k_values(x_q6->data, y_q8->data);

    // Test variable
    float result_ref_q5 = 0.0f;
    float result_current_q5 = 0.0f;
    float result_optimized_q5 = 0.0f;
    float result_ref_q6 = 0.0f;
    float result_current_q6 = 0.0f;
    float result_optimized_q6 = 0.0f;
    
    // Quick validation of implementations - run each once to check consistency
    ggml_vec_dot_q5_K_q8_K_ref(n_elements, &result_ref_q5, 0, x_q5->data, 0, y_q8->data, 0, 1);
    ggml_vec_dot_q5_K_q8_K(n_elements, &result_current_q5, 0, x_q5->data, 0, y_q8->data, 0, 1);
    ggml_vec_dot_q5_K_q8_K_optimized(n_elements, &result_optimized_q5, 0, x_q5->data, 0, y_q8->data, 0, 1);
    
    printf("\nValidation Q5_K:\n");
    printf("  Reference:  %f\n", result_ref_q5);
    printf("  Current:    %f\n", result_current_q5);
    printf("  Optimized:  %f\n", result_optimized_q5);
    printf("  Diff Ref-Current:  %f\n", result_ref_q5 - result_current_q5);
    printf("  Diff Ref-Optimized:  %f\n", result_ref_q5 - result_optimized_q5);
    printf("  Diff Current-Optimized:  %f\n", result_current_q5 - result_optimized_q5);
    
    ggml_vec_dot_q6_K_q8_K_ref(n_elements, &result_ref_q6, 0, x_q6->data, 0, y_q8->data, 0, 1);
    ggml_vec_dot_q6_K_q8_K(n_elements, &result_current_q6, 0, x_q6->data, 0, y_q8->data, 0, 1);
    ggml_vec_dot_q6_K_q8_K_optimized(n_elements, &result_optimized_q6, 0, x_q6->data, 0, y_q8->data, 0, 1);
    
    printf("\nValidation Q6_K:\n");
    printf("  Reference:  %f\n", result_ref_q6);
    printf("  Current:    %f\n", result_current_q6);
    printf("  Optimized:  %f\n", result_optimized_q6);
    printf("  Diff Ref-Current:  %f\n", result_ref_q6 - result_current_q6);
    printf("  Diff Ref-Optimized:  %f\n", result_ref_q6 - result_optimized_q6);
    printf("  Diff Current-Optimized:  %f\n", result_current_q6 - result_optimized_q6);

    // Warmup
    for (int i = 0; i < 10; i++) {
        ggml_vec_dot_q5_K_q8_K_ref(n_elements, &result_ref_q5, 0, x_q5->data, 0, y_q8->data, 0, 1);
        ggml_vec_dot_q5_K_q8_K(n_elements, &result_current_q5, 0, x_q5->data, 0, y_q8->data, 0, 1);
        ggml_vec_dot_q5_K_q8_K_optimized(n_elements, &result_optimized_q5, 0, x_q5->data, 0, y_q8->data, 0, 1);
        ggml_vec_dot_q6_K_q8_K_ref(n_elements, &result_ref_q6, 0, x_q6->data, 0, y_q8->data, 0, 1);
        ggml_vec_dot_q6_K_q8_K(n_elements, &result_current_q6, 0, x_q6->data, 0, y_q8->data, 0, 1);
        ggml_vec_dot_q6_K_q8_K_optimized(n_elements, &result_optimized_q6, 0, x_q6->data, 0, y_q8->data, 0, 1);
    }

    // Benchmark reference Q5_K implementation
    double start_time = get_time_in_ns();
    for (int i = 0; i < num_iterations; i++) {
        ggml_vec_dot_q5_K_q8_K_ref(n_elements, &result_ref_q5, 0, x_q5->data, 0, y_q8->data, 0, 1);
    }
    double end_time = get_time_in_ns();
    double ref_q5_time = (end_time - start_time) / num_iterations;
    
    // Benchmark current Q5_K implementation
    start_time = get_time_in_ns();
    for (int i = 0; i < num_iterations; i++) {
        ggml_vec_dot_q5_K_q8_K(n_elements, &result_current_q5, 0, x_q5->data, 0, y_q8->data, 0, 1);
    }
    end_time = get_time_in_ns();
    double current_q5_time = (end_time - start_time) / num_iterations;
    
    // Benchmark optimized Q5_K implementation
    start_time = get_time_in_ns();
    for (int i = 0; i < num_iterations; i++) {
        ggml_vec_dot_q5_K_q8_K_optimized(n_elements, &result_optimized_q5, 0, x_q5->data, 0, y_q8->data, 0, 1);
    }
    end_time = get_time_in_ns();
    double optimized_q5_time = (end_time - start_time) / num_iterations;

    // Benchmark reference Q6_K implementation
    start_time = get_time_in_ns();
    for (int i = 0; i < num_iterations; i++) {
        ggml_vec_dot_q6_K_q8_K_ref(n_elements, &result_ref_q6, 0, x_q6->data, 0, y_q8->data, 0, 1);
    }
    end_time = get_time_in_ns();
    double ref_q6_time = (end_time - start_time) / num_iterations;
    
    // Benchmark current Q6_K implementation
    start_time = get_time_in_ns();
    for (int i = 0; i < num_iterations; i++) {
        ggml_vec_dot_q6_K_q8_K(n_elements, &result_current_q6, 0, x_q6->data, 0, y_q8->data, 0, 1);
    }
    end_time = get_time_in_ns();
    double current_q6_time = (end_time - start_time) / num_iterations;
    
    // Benchmark optimized Q6_K implementation
    start_time = get_time_in_ns();
    for (int i = 0; i < num_iterations; i++) {
        ggml_vec_dot_q6_K_q8_K_optimized(n_elements, &result_optimized_q6, 0, x_q6->data, 0, y_q8->data, 0, 1);
    }
    end_time = get_time_in_ns();
    double optimized_q6_time = (end_time - start_time) / num_iterations;

    // Print results
    printf("\nResults for Q5_K dot Q8_K:\n");
    printf("Reference: %f\n", result_ref_q5);
    printf("Current: %f\n", result_current_q5);
    printf("Optimized: %f\n", result_optimized_q5);
    printf("Performance for Q5_K dot Q8_K (time per call in ns):\n");
    printf("Reference: %.2f ns\n", ref_q5_time);
    printf("Current: %.2f ns\n", current_q5_time);
    printf("Optimized: %.2f ns\n", optimized_q5_time);
    printf("Current vs. Reference speedup: %.2fx\n", ref_q5_time / current_q5_time);
    printf("Optimized vs. Reference speedup: %.2fx\n", ref_q5_time / optimized_q5_time);
    printf("Optimized vs. Current speedup: %.2fx\n", current_q5_time / optimized_q5_time);

    printf("\nResults for Q6_K dot Q8_K:\n");
    printf("Reference: %f\n", result_ref_q6);
    printf("Current: %f\n", result_current_q6);
    printf("Optimized: %f\n", result_optimized_q6);
    printf("Performance for Q6_K dot Q8_K (time per call in ns):\n");
    printf("Reference: %.2f ns\n", ref_q6_time);
    printf("Current: %.2f ns\n", current_q6_time);
    printf("Optimized: %.2f ns\n", optimized_q6_time);
    printf("Current vs. Reference speedup: %.2fx\n", ref_q6_time / current_q6_time);
    printf("Optimized vs. Reference speedup: %.2fx\n", ref_q6_time / optimized_q6_time);
    printf("Optimized vs. Current speedup: %.2fx\n", current_q6_time / optimized_q6_time);

    // Cleanup
    ggml_free(ctx);

    return 0;
} 