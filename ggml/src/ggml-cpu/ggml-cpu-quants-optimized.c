#include "ggml-common.h"
#include "ggml-quants.h"
#include "ggml-cpu.h"
#include "ggml-cpu-quants.h"

#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <math.h>
#include <assert.h>

// Define UNUSED macro if not defined
#ifndef UNUSED
#define UNUSED(x) (void)(x)
#endif

// Define GGML_FP16_TO_FP32 if not defined
#ifndef GGML_FP16_TO_FP32
#define GGML_FP16_TO_FP32(x) ggml_fp16_to_fp32(x)
#endif

// Optimized scalar implementation for Q5_K, attempting to exactly match ggml_vec_dot_q5_K_q8_K_ref logic
void ggml_vec_dot_q5_K_q8_K_optimized(int n, float * GGML_RESTRICT s, size_t bs, const void * GGML_RESTRICT vx, size_t bx, const void * GGML_RESTRICT vy, size_t by, int nrc) {
    assert(n % QK_K == 0);
    assert(nrc == 1);
    UNUSED(nrc); UNUSED(bx); UNUSED(by); UNUSED(bs);

    const block_q5_K * GGML_RESTRICT x_blocks = vx;
    const block_q8_K * GGML_RESTRICT y_blocks = vy;
    const int num_blocks = n / QK_K;
    float total_sum_f = 0.0f;

    static const uint32_t kmask1 = 0x3f3f3f3f;
    static const uint32_t kmask2 = 0x0f0f0f0f;
    static const uint32_t kmask3 = 0x03030303;

    for (int i = 0; i < num_blocks; ++i) {
        const block_q5_K * x_block = &x_blocks[i];
        const block_q8_K * y_block = &y_blocks[i];

        const float d_x_global    = GGML_FP16_TO_FP32(x_block->d);
        const float dmin_x_global = GGML_FP16_TO_FP32(x_block->dmin);
        const float d_y_global    = y_block->d;

        const uint8_t * GGML_RESTRICT ref_x_qs = x_block->qs;
        const uint8_t * GGML_RESTRICT ref_x_qh = x_block->qh;
        const int8_t  * GGML_RESTRICT ref_y_q8 = y_block->qs;

        uint32_t scales_and_mins_packed_u32[4];
        memset(scales_and_mins_packed_u32, 0, sizeof(scales_and_mins_packed_u32)); // Initialize to zero
        memcpy(scales_and_mins_packed_u32, x_block->scales, 12);

        uint32_t scales_tmp = scales_and_mins_packed_u32[2];
        scales_and_mins_packed_u32[2] = ((scales_tmp >> 4) & kmask2) | (((scales_and_mins_packed_u32[1] >> 6) & kmask3) << 4);
        scales_and_mins_packed_u32[1] = (scales_tmp & kmask2) | (((scales_and_mins_packed_u32[0] >> 6) & kmask3) << 4);
        scales_and_mins_packed_u32[0] &= kmask1;

        const uint8_t * unpacked_scales = (const uint8_t *)scales_and_mins_packed_u32;
        const uint8_t * unpacked_mins   = unpacked_scales + 8;

        int32_t sumi_block_ref_style = 0;
        int32_t sumi_mins_block_ref_style = 0;

        for (int j = 0; j < QK_K/16; ++j) {
            const uint8_t sc_group = unpacked_scales[j];
            const int8_t  sm_group = unpacked_mins[j/2];

            const uint8_t vh0_nibble_ref = ref_x_qh[j] & 0xF;
            const uint8_t vh1_nibble_ref = ref_x_qh[j] >> 4;
            
            int32_t sum_16_y_for_min_term = 0;

            for (int k = 0; k < 8; ++k) {
                const uint8_t q5_low_nibble = (ref_x_qs[(j/2)*8 + k] & 0x0F);
                const uint8_t x_q5_reconstructed_val0 = (q5_low_nibble | ((vh0_nibble_ref & (1 << k)) << (4-k)));
                const int8_t  x_q5_final_val0         = x_q5_reconstructed_val0 - 16;
                const int el_idx0 = j*16 + k;
                sumi_block_ref_style += (int32_t)x_q5_final_val0 * ref_y_q8[el_idx0] * sc_group;
                sum_16_y_for_min_term += ref_y_q8[el_idx0];
            }

            for (int k = 0; k < 8; ++k) {
                const uint8_t q5_high_nibble = (ref_x_qs[(j/2)*8 + k] >> 4);
                const uint8_t x_q5_reconstructed_val1 = (q5_high_nibble | ((vh1_nibble_ref & (1 << k)) << (4-k)));
                const int8_t  x_q5_final_val1         = x_q5_reconstructed_val1 - 16;
                const int el_idx1 = j*16 + 8 + k;
                sumi_block_ref_style += (int32_t)x_q5_final_val1 * ref_y_q8[el_idx1] * sc_group;
                sum_16_y_for_min_term += ref_y_q8[el_idx1];
            }
            sumi_block_ref_style -= (int32_t)sm_group * sc_group * sum_16_y_for_min_term;
            sumi_mins_block_ref_style += (int32_t)sm_group * sc_group * sum_16_y_for_min_term;
        }

        total_sum_f += sumi_block_ref_style * d_x_global * d_y_global;
        total_sum_f += (-d_y_global * dmin_x_global) * sumi_mins_block_ref_style;
    }
    *s = total_sum_f;
}

// Optimized scalar implementation for Q6_K
#if GGML_USE_OPTIMIZED_SCALAR_Q6_Q8
void ggml_vec_dot_q6_K_q8_K_optimized(int n, float * GGML_RESTRICT s, size_t bs, const void * GGML_RESTRICT vx, size_t bx, const void * GGML_RESTRICT vy, size_t by, int nrc) {
    UNUSED(nrc);
    UNUSED(bs);
    UNUSED(bx);
    UNUSED(by);

    const int nb = n / QK_K;

    const block_q6_K * GGML_RESTRICT x = vx;
    const block_q8_K * GGML_RESTRICT y = vy;

    float sumf = 0.0f;

    for (int i = 0; i < nb; ++i) {
        const float d = y[i].d * GGML_FP16_TO_FP32(x[i].d);

        const uint8_t * GGML_RESTRICT x_ql_superblock_ptr = x[i].ql;
        const uint8_t * GGML_RESTRICT x_qh_superblock_ptr = x[i].qh;
        const int8_t  * GGML_RESTRICT x_scales_superblock_ptr = x[i].scales;

        int32_t sumi = 0;
        for (int j = 0; j < QK_K / 16; ++j) { // j = scale_group_idx, 0..15
            const int8_t scale_for_group = x_scales_superblock_ptr[j];
            const uint8_t * current_ql_group_ptr = x_ql_superblock_ptr + j*8; // 8 bytes of ql for this scale group
            const uint8_t * current_qh_group_ptr = x_qh_superblock_ptr + j*4; // 4 bytes of qh for this scale group

            int32_t group_sum = 0;
            for (int l_pair = 0; l_pair < 8; ++l_pair) { // l_pair iterates 0..7, for 8 pairs of elements
                const uint8_t ql_byte_for_pair = current_ql_group_ptr[l_pair];

                // First element of the pair
                const int m0 = l_pair * 2;      // Element index within 16-element scale group (0, 2, ..., 14)
                const uint8_t ql_0 = (ql_byte_for_pair >> 0) & 0xF;
                const uint8_t qh_byte_0 = current_qh_group_ptr[m0/4]; // Selects 1 of 4 qh bytes for this group
                const uint8_t qh_0 = (qh_byte_0 >> ((m0%4)*2)) & 0x3; // Selects 2 bits from that qh byte
                const int q_0  = (qh_0 << 4) | ql_0;
                const int8_t v0 = q_0 - 32;
                const int idx_y0 = j*16 + m0; // Absolute index in superblock for y
                group_sum += v0 * y[i].qs[idx_y0];

                // Second element of the pair
                const int m1 = l_pair * 2 + 1;  // Element index within 16-element scale group (1, 3, ..., 15)
                const uint8_t ql_1 = (ql_byte_for_pair >> 4) & 0xF;
                const uint8_t qh_byte_1 = current_qh_group_ptr[m1/4]; // Selects 1 of 4 qh bytes for this group
                const uint8_t qh_1 = (qh_byte_1 >> ((m1%4)*2)) & 0x3; // Selects 2 bits from that qh byte
                const int q_1  = (qh_1 << 4) | ql_1;
                const int8_t v1 = q_1 - 32;
                const int idx_y1 = j*16 + m1; // Absolute index in superblock for y
                group_sum += v1 * y[i].qs[idx_y1];
            }
            sumi += group_sum * scale_for_group;
        }
        sumf += sumi * d;
    }
    *s = sumf;
}
#endif 

// Define GGML_USE_OPTIMIZED_SCALAR_Q4_Q8 if not already defined to enable the Q4_K optimized function
#ifndef GGML_USE_OPTIMIZED_SCALAR_Q4_Q8
#define GGML_USE_OPTIMIZED_SCALAR_Q4_Q8 1
#endif

#if GGML_USE_OPTIMIZED_SCALAR_Q4_Q8

// Copied and renamed from ggml-quants.c get_scale_min_k4
// j_scale_idx is 0..7 for QK_K=256 (since QK_K/32 = 8 scales/mins)
static inline void get_scale_min_k4_for_optimized_dot_product(int j_scale_idx, const uint8_t * GGML_RESTRICT q_scales_mins_block_array, uint8_t * GGML_RESTRICT d_sub_scale_val, uint8_t * GGML_RESTRICT m_sub_min_val) {
    if (j_scale_idx < 4) { // First 4 scales and mins
        *d_sub_scale_val = q_scales_mins_block_array[j_scale_idx] & 0x3F;
        *m_sub_min_val   = q_scales_mins_block_array[j_scale_idx+4] & 0x3F;
    } else { // Next 4 scales and mins (j_scale_idx = 4,5,6,7)
        *d_sub_scale_val = (q_scales_mins_block_array[j_scale_idx+4] & 0x0F) | ((q_scales_mins_block_array[j_scale_idx-4] >> 6) << 4);
        *m_sub_min_val   = (q_scales_mins_block_array[j_scale_idx+4] >> 4)   | ((q_scales_mins_block_array[j_scale_idx  ] >> 6) << 4);
    }
}

void ggml_vec_dot_q4_K_q8_K_optimized(int n, float * GGML_RESTRICT s, size_t bs, const void * GGML_RESTRICT vx, size_t bx, const void * GGML_RESTRICT vy, size_t by, int nrc) {
    assert(n % QK_K == 0);
    assert(nrc == 1);
    UNUSED(nrc); UNUSED(bx); UNUSED(by); UNUSED(bs);

    const block_q4_K * GGML_RESTRICT x_blocks_base = vx;
    const block_q8_K * GGML_RESTRICT y_blocks_base = vy;

    const int num_qk_blocks = n / QK_K;
    float total_sum_f = 0.0f;

    for (int i_block = 0; i_block < num_qk_blocks; ++i_block) {
        const block_q4_K * current_x_block = &x_blocks_base[i_block];
        const block_q8_K * current_y_block = &y_blocks_base[i_block];

        const float d_y_block    = current_y_block->d; // Is a float
        const float d_x_block    = GGML_FP16_TO_FP32(current_x_block->d);
        const float dmin_x_block = GGML_FP16_TO_FP32(current_x_block->dmin);

        const float d_overall_prod_factor    = d_x_block * d_y_block;
        const float dmin_overall_prod_factor = -dmin_x_block * d_y_block; // Negative sign included here

        int32_t sum_prod_q4_q8_scaled_for_block = 0;
        int32_t sum_prod_min_q8sums_for_block   = 0;

        const uint8_t * x_q4_bytes_ptr      = current_x_block->qs; // 1 byte contains two q4 values
        const int8_t  * y_q8_values_ptr_base = current_y_block->qs; // Base for y Q8 values for this block

        int scale_and_min_pair_idx = 0; 
        for (int j_64_elem_group = 0; j_64_elem_group < QK_K / 64; ++j_64_elem_group) {
            uint8_t sub_block_scale_val_1, sub_block_min_val_1;
            uint8_t sub_block_scale_val_2, sub_block_min_val_2;

            get_scale_min_k4_for_optimized_dot_product(scale_and_min_pair_idx + 0, current_x_block->scales, &sub_block_scale_val_1, &sub_block_min_val_1);
            get_scale_min_k4_for_optimized_dot_product(scale_and_min_pair_idx + 1, current_x_block->scales, &sub_block_scale_val_2, &sub_block_min_val_2);

            int32_t q8_sum_for_min_term_part_1 = 0;
            for (int k_q4_byte_idx = 0; k_q4_byte_idx < 16; k_q4_byte_idx += 2) { // 16 bytes = 32 Q4 values
                const uint8_t x_q4_packed_byte_0 = x_q4_bytes_ptr[k_q4_byte_idx + 0];
                const uint8_t x_q4_packed_byte_1 = x_q4_bytes_ptr[k_q4_byte_idx + 1];

                const int y_q8_base_idx_for_byte0 = j_64_elem_group*64 + (k_q4_byte_idx + 0)*2;
                const int y_q8_base_idx_for_byte1 = j_64_elem_group*64 + (k_q4_byte_idx + 1)*2;

                const int8_t y_q8_val_0 = y_q8_values_ptr_base[y_q8_base_idx_for_byte0 + 0];
                const int8_t y_q8_val_1 = y_q8_values_ptr_base[y_q8_base_idx_for_byte0 + 1];
                const int8_t y_q8_val_2 = y_q8_values_ptr_base[y_q8_base_idx_for_byte1 + 0];
                const int8_t y_q8_val_3 = y_q8_values_ptr_base[y_q8_base_idx_for_byte1 + 1];

                sum_prod_q4_q8_scaled_for_block += (int32_t)(x_q4_packed_byte_0 & 0x0F) * y_q8_val_0 * sub_block_scale_val_1;
                sum_prod_q4_q8_scaled_for_block += (int32_t)(x_q4_packed_byte_0 >> 4)   * y_q8_val_1 * sub_block_scale_val_1;
                sum_prod_q4_q8_scaled_for_block += (int32_t)(x_q4_packed_byte_1 & 0x0F) * y_q8_val_2 * sub_block_scale_val_1;
                sum_prod_q4_q8_scaled_for_block += (int32_t)(x_q4_packed_byte_1 >> 4)   * y_q8_val_3 * sub_block_scale_val_1;
                
                q8_sum_for_min_term_part_1 += y_q8_val_0 + y_q8_val_1 + y_q8_val_2 + y_q8_val_3;
            }
            sum_prod_min_q8sums_for_block += (int32_t)sub_block_min_val_1 * q8_sum_for_min_term_part_1;

            int32_t q8_sum_for_min_term_part_2 = 0;
            const uint8_t* x_q4_bytes_ptr_part2 = x_q4_bytes_ptr + 16; 
            for (int k_q4_byte_idx = 0; k_q4_byte_idx < 16; k_q4_byte_idx += 2) { 
                const uint8_t x_q4_packed_byte_0 = x_q4_bytes_ptr_part2[k_q4_byte_idx + 0];
                const uint8_t x_q4_packed_byte_1 = x_q4_bytes_ptr_part2[k_q4_byte_idx + 1];
                
                const int y_q8_base_idx_for_byte0 = j_64_elem_group*64 + 32 + (k_q4_byte_idx + 0)*2;
                const int y_q8_base_idx_for_byte1 = j_64_elem_group*64 + 32 + (k_q4_byte_idx + 1)*2;

                const int8_t y_q8_val_0 = y_q8_values_ptr_base[y_q8_base_idx_for_byte0 + 0];
                const int8_t y_q8_val_1 = y_q8_values_ptr_base[y_q8_base_idx_for_byte0 + 1];
                const int8_t y_q8_val_2 = y_q8_values_ptr_base[y_q8_base_idx_for_byte1 + 0];
                const int8_t y_q8_val_3 = y_q8_values_ptr_base[y_q8_base_idx_for_byte1 + 1];

                sum_prod_q4_q8_scaled_for_block += (int32_t)(x_q4_packed_byte_0 & 0x0F) * y_q8_val_0 * sub_block_scale_val_2;
                sum_prod_q4_q8_scaled_for_block += (int32_t)(x_q4_packed_byte_0 >> 4)   * y_q8_val_1 * sub_block_scale_val_2;
                sum_prod_q4_q8_scaled_for_block += (int32_t)(x_q4_packed_byte_1 & 0x0F) * y_q8_val_2 * sub_block_scale_val_2;
                sum_prod_q4_q8_scaled_for_block += (int32_t)(x_q4_packed_byte_1 >> 4)   * y_q8_val_3 * sub_block_scale_val_2;
                
                q8_sum_for_min_term_part_2 += y_q8_val_0 + y_q8_val_1 + y_q8_val_2 + y_q8_val_3;
            }
            sum_prod_min_q8sums_for_block += (int32_t)sub_block_min_val_2 * q8_sum_for_min_term_part_2;

            x_q4_bytes_ptr += 32; 
            scale_and_min_pair_idx += 2; 
        }
        total_sum_f += d_overall_prod_factor * sum_prod_q4_q8_scaled_for_block;
        total_sum_f += dmin_overall_prod_factor * sum_prod_min_q8sums_for_block; 
    }
    *s = total_sum_f;
}

#endif // GGML_USE_OPTIMIZED_SCALAR_Q4_Q8 