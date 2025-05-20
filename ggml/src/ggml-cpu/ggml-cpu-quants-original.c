#include "../ggml-common.h"
#include "../ggml-quants.h"
#include "../ggml-impl.h"
#include "ggml-cpu-impl.h"

#include <stdint.h>
#include <stdlib.h>
#include <stdio.h>
#include <time.h>

// Forward declaration for the optimized function
void ggml_vec_dot_q4_K_q8_K(int n, float * GGML_RESTRICT s, size_t bs, const void * GGML_RESTRICT vx, size_t bx, const void * GGML_RESTRICT vy, size_t by, int nrc);

// Original implementation (unoptimized) for benchmarking
void ggml_vec_dot_q4_K_q8_K_original(int n, float * GGML_RESTRICT s, size_t bs, const void * GGML_RESTRICT vx, size_t bx, const void * GGML_RESTRICT vy, size_t by, int nrc) {
    const block_q4_K * GGML_RESTRICT x = vx;
    const block_q8_K * GGML_RESTRICT y = vy;
    
    const int nb = n / QK_K;
    
    static const uint32_t kmask1 = 0x3f3f3f3f;
    static const uint32_t kmask2 = 0x0f0f0f0f;
    static const uint32_t kmask3 = 0x03030303;
    
    uint32_t utmp[4];
    
    const uint8_t * scales = (const uint8_t*)&utmp[0];
    const uint8_t * mins   = (const uint8_t*)&utmp[2];
    
    int8_t  aux8[QK_K];
    int16_t aux16[8];
    float   sums [8];
    int32_t aux32[8];
    memset(sums, 0, 8*sizeof(float));
    
    float sumf = 0;
    for (int i = 0; i < nb; ++i) {
        const uint8_t * GGML_RESTRICT q4 = x[i].qs;
        const  int8_t * GGML_RESTRICT q8 = y[i].qs;
        memset(aux32, 0, 8*sizeof(int32_t));
        int8_t * GGML_RESTRICT a = aux8;
        for (int j = 0; j < QK_K/64; ++j) {
            for (int l = 0; l < 32; ++l) a[l] = (int8_t)(q4[l] & 0xF);
            a += 32;
            for (int l = 0; l < 32; ++l) a[l] = (int8_t)(q4[l]  >> 4);
            a += 32; q4 += 32;
        }
        memcpy(utmp, x[i].scales, 12);
        utmp[3] = ((utmp[2] >> 4) & kmask2) | (((utmp[1] >> 6) & kmask3) << 4);
        const uint32_t uaux = utmp[1] & kmask1;
        utmp[1] = (utmp[2] & kmask2) | (((utmp[0] >> 6) & kmask3) << 4);
        utmp[2] = uaux;
        utmp[0] &= kmask1;
        
        int sumi = 0;
        for (int j = 0; j < QK_K/16; ++j) sumi += y[i].bsums[j] * mins[j/2];
        a = aux8;
        int is = 0;
        for (int j = 0; j < QK_K/32; ++j) {
            int32_t scale = scales[is++];
            for (int l = 0; l < 8; ++l) aux16[l] = q8[l] * a[l];
            for (int l = 0; l < 8; ++l) aux32[l] += scale * aux16[l];
            q8 += 8; a += 8;
            for (int l = 0; l < 8; ++l) aux16[l] = q8[l] * a[l];
            for (int l = 0; l < 8; ++l) aux32[l] += scale * aux16[l];
            q8 += 8; a += 8;
            for (int l = 0; l < 8; ++l) aux16[l] = q8[l] * a[l];
            for (int l = 0; l < 8; ++l) aux32[l] += scale * aux16[l];
            q8 += 8; a += 8;
            for (int l = 0; l < 8; ++l) aux16[l] = q8[l] * a[l];
            for (int l = 0; l < 8; ++l) aux32[l] += scale * aux16[l];
            q8 += 8; a += 8;
        }
        const float d = GGML_FP16_TO_FP32(x[i].d) * y[i].d;
        for (int l = 0; l < 8; ++l) sums[l] += d * aux32[l];
        const float dmin = GGML_FP16_TO_FP32(x[i].dmin) * y[i].d;
        sumf -= dmin * sumi;
    }
    for (int l = 0; l < 8; ++l) sumf += sums[l];
    *s = sumf;
}

// Main function to compare performance
int main(int argc, char **argv) {
    // Number of blocks to process
    const int nb = 1000;
    const int n = nb * QK_K;
    
    // Allocate and initialize test data
    block_q4_K *x = (block_q4_K *)malloc(nb * sizeof(block_q4_K));
    block_q8_K *y = (block_q8_K *)malloc(nb * sizeof(block_q8_K));
    
    if (!x || !y) {
        fprintf(stderr, "Memory allocation failed\n");
        return 1;
    }
    
    // Initialize test data
    srand(42);  // Fixed seed for reproducibility
    
    for (int i = 0; i < nb; i++) {
        // Initialize q4_K blocks
        x[i].d = GGML_FP32_TO_FP16(1.0f);
        x[i].dmin = GGML_FP32_TO_FP16(0.1f);
        
        for (int j = 0; j < 12; j++) {
            x[i].scales[j] = rand() % 16;
        }
        
        for (int j = 0; j < QK_K/2; j++) {
            x[i].qs[j] = rand() % 256;
        }
        
        // Initialize q8_K blocks
        y[i].d = 1.0f;
        
        for (int j = 0; j < QK_K; j++) {
            y[i].qs[j] = rand() % 256 - 128;
        }
        
        for (int j = 0; j < QK_K/16; j++) {
            y[i].bsums[j] = 0;
            for (int k = 0; k < 16; k++) {
                y[i].bsums[j] += y[i].qs[j*16 + k];
            }
        }
    }
    
    // Compare both implementations - original vs optimized
    struct timespec start, end;
    float result_original = 0;
    float result_optimized = 0;
    
    // Warm-up runs
    ggml_vec_dot_q4_K_q8_K_original(n, &result_original, 0, x, 0, y, 0, 1);
    ggml_vec_dot_q4_K_q8_K(n, &result_optimized, 0, x, 0, y, 0, 1);
    
    // Timed runs
    const int num_runs = 100;
    double total_time_original = 0.0;
    double total_time_optimized = 0.0;
    
    // Test original implementation
    for (int i = 0; i < num_runs; i++) {
        clock_gettime(CLOCK_MONOTONIC, &start);
        ggml_vec_dot_q4_K_q8_K_original(n, &result_original, 0, x, 0, y, 0, 1);
        clock_gettime(CLOCK_MONOTONIC, &end);
        double time_taken = (end.tv_sec - start.tv_sec) * 1e9 + (end.tv_nsec - start.tv_nsec);
        total_time_original += time_taken;
    }
    
    // Test optimized implementation
    for (int i = 0; i < num_runs; i++) {
        clock_gettime(CLOCK_MONOTONIC, &start);
        ggml_vec_dot_q4_K_q8_K(n, &result_optimized, 0, x, 0, y, 0, 1);
        clock_gettime(CLOCK_MONOTONIC, &end);
        double time_taken = (end.tv_sec - start.tv_sec) * 1e9 + (end.tv_nsec - start.tv_nsec);
        total_time_optimized += time_taken;
    }
    
    double avg_time_original = total_time_original / num_runs;
    double avg_time_optimized = total_time_optimized / num_runs;
    double speedup = avg_time_original / avg_time_optimized;
    
    printf("Performance Comparison: Q4_K_Q8_K\n");
    printf("Total blocks processed: %d (%d elements)\n", nb, n);
    printf("Original implementation: %.2f ns\n", avg_time_original);
    printf("Optimized implementation: %.2f ns\n", avg_time_optimized);
    printf("Speedup: %.2fx\n", speedup);
    printf("Results - Original: %f, Optimized: %f\n", result_original, result_optimized);
    printf("Results match: %s\n", (fabs(result_original - result_optimized) < 1e-4) ? "YES" : "NO");
    
    free(x);
    free(y);
    
    return 0;
} 