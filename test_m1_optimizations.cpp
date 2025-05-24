#include <chrono>
#include <iostream>
#include <vector>
#include <random>
#include <iomanip>

// Include the vec.h header
#include "ggml/src/ggml-cpu/vec.h"

const int VECTOR_SIZE = 1024 * 1024; // 1M floats
const int NUM_ITERATIONS = 100;

void benchmark_dot_product() {
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
        ggml_vec_dot_f32(VECTOR_SIZE, &result, 0, x.data(), 0, y.data(), 0, 1);
    }
    
    auto end = std::chrono::high_resolution_clock::now();
    auto duration = std::chrono::duration_cast<std::chrono::microseconds>(end - start);
    
    std::cout << "Dot Product Performance:" << std::endl;
    std::cout << "  Vector size: " << VECTOR_SIZE << " floats" << std::endl;
    std::cout << "  Iterations: " << NUM_ITERATIONS << std::endl;
    std::cout << "  Total time: " << duration.count() << " μs" << std::endl;
    std::cout << "  Average time per iteration: " << duration.count() / NUM_ITERATIONS << " μs" << std::endl;
    std::cout << "  Throughput: " << std::fixed << std::setprecision(2) 
              << (double)(VECTOR_SIZE * NUM_ITERATIONS) / duration.count() << " MFLOPS" << std::endl;
    std::cout << "  Result: " << result << std::endl << std::endl;
}

void benchmark_vector_add() {
    std::vector<float> x(VECTOR_SIZE);
    std::vector<float> y(VECTOR_SIZE);
    std::vector<float> z(VECTOR_SIZE);
    
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
        ggml_vec_add_f32(VECTOR_SIZE, z.data(), x.data(), y.data());
    }
    
    auto end = std::chrono::high_resolution_clock::now();
    auto duration = std::chrono::duration_cast<std::chrono::microseconds>(end - start);
    
    std::cout << "Vector Add Performance:" << std::endl;
    std::cout << "  Vector size: " << VECTOR_SIZE << " floats" << std::endl;
    std::cout << "  Iterations: " << NUM_ITERATIONS << std::endl;
    std::cout << "  Total time: " << duration.count() << " μs" << std::endl;
    std::cout << "  Average time per iteration: " << duration.count() / NUM_ITERATIONS << " μs" << std::endl;
    std::cout << "  Throughput: " << std::fixed << std::setprecision(2) 
              << (double)(VECTOR_SIZE * NUM_ITERATIONS) / duration.count() << " MFLOPS" << std::endl << std::endl;
}

void benchmark_vector_mul() {
    std::vector<float> x(VECTOR_SIZE);
    std::vector<float> y(VECTOR_SIZE);
    std::vector<float> z(VECTOR_SIZE);
    
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
        ggml_vec_mul_f32(VECTOR_SIZE, z.data(), x.data(), y.data());
    }
    
    auto end = std::chrono::high_resolution_clock::now();
    auto duration = std::chrono::duration_cast<std::chrono::microseconds>(end - start);
    
    std::cout << "Vector Multiply Performance:" << std::endl;
    std::cout << "  Vector size: " << VECTOR_SIZE << " floats" << std::endl;
    std::cout << "  Iterations: " << NUM_ITERATIONS << std::endl;
    std::cout << "  Total time: " << duration.count() << " μs" << std::endl;
    std::cout << "  Average time per iteration: " << duration.count() / NUM_ITERATIONS << " μs" << std::endl;
    std::cout << "  Throughput: " << std::fixed << std::setprecision(2) 
              << (double)(VECTOR_SIZE * NUM_ITERATIONS) / duration.count() << " MFLOPS" << std::endl << std::endl;
}

void benchmark_vector_acc() {
    std::vector<float> x(VECTOR_SIZE);
    std::vector<float> y(VECTOR_SIZE);
    
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
        ggml_vec_acc_f32(VECTOR_SIZE, y.data(), x.data());
    }
    
    auto end = std::chrono::high_resolution_clock::now();
    auto duration = std::chrono::duration_cast<std::chrono::microseconds>(end - start);
    
    std::cout << "Vector Accumulate Performance:" << std::endl;
    std::cout << "  Vector size: " << VECTOR_SIZE << " floats" << std::endl;
    std::cout << "  Iterations: " << NUM_ITERATIONS << std::endl;
    std::cout << "  Total time: " << duration.count() << " μs" << std::endl;
    std::cout << "  Average time per iteration: " << duration.count() / NUM_ITERATIONS << " μs" << std::endl;
    std::cout << "  Throughput: " << std::fixed << std::setprecision(2) 
              << (double)(VECTOR_SIZE * NUM_ITERATIONS) / duration.count() << " MFLOPS" << std::endl << std::endl;
}

int main() {
    std::cout << "SIMD Vector Operations Benchmark" << std::endl;
    std::cout << "=================================" << std::endl;
    
#ifdef ARM_M1
    std::cout << "Running with ARM_M1 optimizations enabled" << std::endl;
#else
    std::cout << "Running with standard ARM NEON implementation" << std::endl;
#endif
    
    std::cout << std::endl;
    
    benchmark_dot_product();
    benchmark_vector_add();
    benchmark_vector_mul();
    benchmark_vector_acc();
    
    return 0;
}