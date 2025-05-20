#include "../ggml/include/ggml.h"
#include "../ggml/src/ggml-quants.h"
#include "../ggml/src/ggml-common.h"
#include "../ggml/src/ggml-impl.h"

#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <string.h>

// Function declaration (existing in the ggml-cpu-quants.h file but needs to be declared here)
void ggml_vec_dot_q4_K_q8_K(int n, float * GGML_RESTRICT s, size_t bs, const void * GGML_RESTRICT vx, size_t bx, const void * GGML_RESTRICT vy, size_t by, int nrc);

// Simple function to initialize test data
static void init_test_data(block_q4_K *x, block_q8_K *y, int n) {
    srand(42);  // Fixed seed for reproducibility
    
    for (int i = 0; i < n; i++) {
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
}

int main(void) {
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
    
    init_test_data(x, y, nb);
    
    // Timer variables
    struct timespec start, end;
    float result = 0;
    
    // Warm-up run
    ggml_vec_dot_q4_K_q8_K(n, &result, 0, x, 0, y, 0, 1);
    
    // Timed runs
    const int num_runs = 100;
    double total_time = 0.0;
    
    for (int i = 0; i < num_runs; i++) {
        clock_gettime(CLOCK_MONOTONIC, &start);
        
        ggml_vec_dot_q4_K_q8_K(n, &result, 0, x, 0, y, 0, 1);
        
        clock_gettime(CLOCK_MONOTONIC, &end);
        
        double time_taken = (end.tv_sec - start.tv_sec) * 1e9 + (end.tv_nsec - start.tv_nsec);
        total_time += time_taken;
    }
    
    double avg_time = total_time / num_runs;
    
    printf("Q4_K_Q8_K Performance Test\n");
    printf("Total blocks processed: %d (%d elements)\n", nb, n);
    printf("Average time per call: %.2f ns\n", avg_time);
    printf("Result: %f\n", result);
    
    free(x);
    free(y);
    
    return 0;
} 