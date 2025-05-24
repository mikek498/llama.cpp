#include <iostream>
#include <chrono>
#include <vector>
#include <cstdlib>

int main() {
    std::cout << "Testing M1 Max optimizations for inference...\n";
    
    // Test basic vector operations that are heavily used in inference
    constexpr int n = 1024 * 1024;
    constexpr int iterations = 1000;
    
    std::vector<float> a(n), b(n), c(n);
    
    // Initialize with random data
    srand(42);
    for (int i = 0; i < n; ++i) {
        a[i] = static_cast<float>(rand()) / RAND_MAX;
        b[i] = static_cast<float>(rand()) / RAND_MAX;
    }
    
    auto start = std::chrono::high_resolution_clock::now();
    
    // Simulate typical inference operations
    for (int iter = 0; iter < iterations; ++iter) {
        // Vector addition (residual connections)
        for (int i = 0; i < n; ++i) {
            c[i] = a[i] + b[i];
        }
        
        // Vector multiplication (element-wise)
        for (int i = 0; i < n; ++i) {
            c[i] = a[i] * b[i];
        }
        
        // Dot product (attention weights)
        float dot = 0.0f;
        for (int i = 0; i < n; ++i) {
            dot += a[i] * b[i];
        }
        
        // Prevent optimization out
        if (iter == iterations - 1) {
            std::cout << "Final dot product: " << dot << "\n";
        }
    }
    
    auto end = std::chrono::high_resolution_clock::now();
    auto duration = std::chrono::duration_cast<std::chrono::milliseconds>(end - start);
    
    double ops = static_cast<double>(n) * iterations * 4; // 4 ops per iteration
    double gflops = (ops / 1e9) / (duration.count() / 1000.0);
    
    std::cout << "Performance: " << gflops << " GFLOPS\n";
    std::cout << "Time: " << duration.count() << " ms\n";
    
    return 0;
}