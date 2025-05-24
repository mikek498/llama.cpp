#include <iostream>
#include <chrono>
#include <vector>
#include <random>
#include <cstring>

// Include the vector functions
extern "C" {
    void ggml_vec_dot_f32(int n, float * s, size_t bs, const float * x, size_t bx, const float * y, size_t by, int nrc);
    void ggml_vec_add_f32(const int n, float * z, const float * x, const float * y);
    void ggml_vec_mul_f32(const int n, float * z, const float * x, const float * y);
    void ggml_vec_acc_f32(const int n, float * y, const float * x);
}

class PerformanceTimer {
public:
    void start() {
        start_time = std::chrono::high_resolution_clock::now();
    }
    
    double stop() {
        auto end_time = std::chrono::high_resolution_clock::now();
        auto duration = std::chrono::duration_cast<std::chrono::nanoseconds>(end_time - start_time);
        return duration.count() / 1000000.0; // Convert to milliseconds
    }
    
private:
    std::chrono::high_resolution_clock::time_point start_time;
};

void benchmark_dot_product() {
    std::cout << "\n=== ARM NEON Dot Product Benchmark ===" << std::endl;
    
    // Test different vector sizes
    std::vector<int> sizes = {1024, 4096, 16384, 65536, 262144};
    
    std::random_device rd;
    std::mt19937 gen(rd());
    std::uniform_real_distribution<float> dis(-1.0f, 1.0f);
    
    for (int size : sizes) {
        std::vector<float> x(size), y(size);
        
        // Fill with random data
        for (int i = 0; i < size; i++) {
            x[i] = dis(gen);
            y[i] = dis(gen);
        }
        
        float result = 0.0f;
        PerformanceTimer timer;
        
        // Warm up
        for (int i = 0; i < 10; i++) {
            ggml_vec_dot_f32(size, &result, 0, x.data(), 0, y.data(), 0, 1);
        }
        
        // Benchmark
        timer.start();
        const int iterations = 1000;
        for (int i = 0; i < iterations; i++) {
            ggml_vec_dot_f32(size, &result, 0, x.data(), 0, y.data(), 0, 1);
        }
        double elapsed = timer.stop();
        
        double ops_per_sec = (static_cast<double>(size) * iterations) / (elapsed / 1000.0);
        double gbps = (ops_per_sec * sizeof(float) * 2) / (1024.0 * 1024.0 * 1024.0);
        
        std::cout << "Size: " << size 
                  << ", Time: " << elapsed / iterations << " ms"
                  << ", GFLOPS: " << ops_per_sec / 1e9
                  << ", Bandwidth: " << gbps << " GB/s"
                  << ", Result: " << result << std::endl;
    }
}

void benchmark_vector_add() {
    std::cout << "\n=== ARM NEON Vector Add Benchmark ===" << std::endl;
    
    std::vector<int> sizes = {1024, 4096, 16384, 65536, 262144};
    
    std::random_device rd;
    std::mt19937 gen(rd());
    std::uniform_real_distribution<float> dis(-1.0f, 1.0f);
    
    for (int size : sizes) {
        std::vector<float> x(size), y(size), z(size);
        
        for (int i = 0; i < size; i++) {
            x[i] = dis(gen);
            y[i] = dis(gen);
        }
        
        PerformanceTimer timer;
        
        // Warm up
        for (int i = 0; i < 10; i++) {
            ggml_vec_add_f32(size, z.data(), x.data(), y.data());
        }
        
        timer.start();
        const int iterations = 1000;
        for (int i = 0; i < iterations; i++) {
            ggml_vec_add_f32(size, z.data(), x.data(), y.data());
        }
        double elapsed = timer.stop();
        
        double ops_per_sec = (static_cast<double>(size) * iterations) / (elapsed / 1000.0);
        double gbps = (ops_per_sec * sizeof(float) * 3) / (1024.0 * 1024.0 * 1024.0); // 3 arrays
        
        std::cout << "Size: " << size 
                  << ", Time: " << elapsed / iterations << " ms"
                  << ", GOPS: " << ops_per_sec / 1e9
                  << ", Bandwidth: " << gbps << " GB/s" << std::endl;
    }
}

void benchmark_vector_mul() {
    std::cout << "\n=== ARM NEON Vector Multiply Benchmark ===" << std::endl;
    
    std::vector<int> sizes = {1024, 4096, 16384, 65536, 262144};
    
    std::random_device rd;
    std::mt19937 gen(rd());
    std::uniform_real_distribution<float> dis(-1.0f, 1.0f);
    
    for (int size : sizes) {
        std::vector<float> x(size), y(size), z(size);
        
        for (int i = 0; i < size; i++) {
            x[i] = dis(gen);
            y[i] = dis(gen);
        }
        
        PerformanceTimer timer;
        
        // Warm up
        for (int i = 0; i < 10; i++) {
            ggml_vec_mul_f32(size, z.data(), x.data(), y.data());
        }
        
        timer.start();
        const int iterations = 1000;
        for (int i = 0; i < iterations; i++) {
            ggml_vec_mul_f32(size, z.data(), x.data(), y.data());
        }
        double elapsed = timer.stop();
        
        double ops_per_sec = (static_cast<double>(size) * iterations) / (elapsed / 1000.0);
        double gbps = (ops_per_sec * sizeof(float) * 3) / (1024.0 * 1024.0 * 1024.0);
        
        std::cout << "Size: " << size 
                  << ", Time: " << elapsed / iterations << " ms"
                  << ", GOPS: " << ops_per_sec / 1e9
                  << ", Bandwidth: " << gbps << " GB/s" << std::endl;
    }
}

void benchmark_accumulation() {
    std::cout << "\n=== ARM NEON Vector Accumulate Benchmark ===" << std::endl;
    
    std::vector<int> sizes = {1024, 4096, 16384, 65536, 262144};
    
    std::random_device rd;
    std::mt19937 gen(rd());
    std::uniform_real_distribution<float> dis(-1.0f, 1.0f);
    
    for (int size : sizes) {
        std::vector<float> x(size), y(size);
        
        for (int i = 0; i < size; i++) {
            x[i] = dis(gen);
            y[i] = dis(gen);
        }
        
        PerformanceTimer timer;
        
        // Warm up
        for (int i = 0; i < 10; i++) {
            ggml_vec_acc_f32(size, y.data(), x.data());
        }
        
        // Reset y for consistent benchmark
        for (int i = 0; i < size; i++) {
            y[i] = dis(gen);
        }
        
        timer.start();
        const int iterations = 1000;
        for (int i = 0; i < iterations; i++) {
            ggml_vec_acc_f32(size, y.data(), x.data());
        }
        double elapsed = timer.stop();
        
        double ops_per_sec = (static_cast<double>(size) * iterations) / (elapsed / 1000.0);
        double gbps = (ops_per_sec * sizeof(float) * 2) / (1024.0 * 1024.0 * 1024.0);
        
        std::cout << "Size: " << size 
                  << ", Time: " << elapsed / iterations << " ms"
                  << ", GOPS: " << ops_per_sec / 1e9
                  << ", Bandwidth: " << gbps << " GB/s" << std::endl;
    }
}

int main() {
    std::cout << "ARM NEON SIMD Performance Benchmark" << std::endl;
    std::cout << "====================================" << std::endl;
    
    #ifdef __ARM_NEON
    std::cout << "ARM NEON support: ENABLED" << std::endl;
    #else
    std::cout << "ARM NEON support: DISABLED" << std::endl;
    #endif
    
    #ifdef __aarch64__
    std::cout << "AArch64 architecture: ENABLED" << std::endl;
    #else
    std::cout << "AArch64 architecture: DISABLED" << std::endl;
    #endif
    
    #ifdef __ARM_FEATURE_DOTPROD
    std::cout << "ARM Dot Product support: ENABLED" << std::endl;
    #else
    std::cout << "ARM Dot Product support: DISABLED" << std::endl;
    #endif
    
    #ifdef __ARM_FEATURE_FMA
    std::cout << "ARM FMA support: ENABLED" << std::endl;
    #else
    std::cout << "ARM FMA support: DISABLED" << std::endl;
    #endif
    
    benchmark_dot_product();
    benchmark_vector_add();
    benchmark_vector_mul();
    benchmark_accumulation();
    
    std::cout << "\nBenchmark completed!" << std::endl;
    
    return 0;
}