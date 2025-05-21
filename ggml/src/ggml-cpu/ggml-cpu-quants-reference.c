#include "ggml-common.h"
#include "ggml-quants.h"
#include "ggml-cpu.h"

#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <math.h>

// Reference scalar implementations for benchmarking

void ggml_vec_dot_q5_K_q8_K_ref(int n, float * GGML_RESTRICT s, size_t bs, const void * GGML_RESTRICT vx, size_t bx, const void * GGML_RESTRICT vy, size_t by, int nrc) {
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
        uint32_t aux = scales_and_mins[1] & kmask1;
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

void ggml_vec_dot_q6_K_q8_K_ref(int n, float * GGML_RESTRICT s, size_t bs, const void * GGML_RESTRICT vx, size_t bx, const void * GGML_RESTRICT vy, size_t by, int nrc) {
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
                int kq = j*16 + k;
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