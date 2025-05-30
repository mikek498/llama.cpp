#include <iostream>
#include <vector>
#include <string>
#include <Accelerate/Accelerate.h>

// Macro to check function availability
#define CHECK_FUNCTION_AVAILABLE(func) \
    try { \
        void* ptr = (void*)&func; \
        if (ptr) { \
            std::cout << "✓ " #func " is available" << std::endl; \
            available_functions.push_back(#func); \
        } \
    } catch (...) { \
        std::cout << "✗ " #func " is NOT available" << std::endl; \
    }

int main() {
    std::vector<std::string> available_functions;
    
    std::cout << "Checking Accelerate framework functions...\n";
    std::cout << "========================================\n";
    
    // Check BLAS functions
    std::cout << "\nBLAS Functions:\n";
    CHECK_FUNCTION_AVAILABLE(cblas_sgemm);
    CHECK_FUNCTION_AVAILABLE(cblas_sgemv);
    CHECK_FUNCTION_AVAILABLE(cblas_saxpy);
    CHECK_FUNCTION_AVAILABLE(cblas_sdot);
    
    // Check vDSP functions
    std::cout << "\nvDSP Functions:\n";
    CHECK_FUNCTION_AVAILABLE(vDSP_vadd);
    CHECK_FUNCTION_AVAILABLE(vDSP_vmul);
    CHECK_FUNCTION_AVAILABLE(vDSP_vsma);
    CHECK_FUNCTION_AVAILABLE(vDSP_vsmul);
    CHECK_FUNCTION_AVAILABLE(vDSP_vsadd);
    CHECK_FUNCTION_AVAILABLE(vDSP_vdiv);
    CHECK_FUNCTION_AVAILABLE(vDSP_vasm);
    CHECK_FUNCTION_AVAILABLE(vDSP_vsbm);
    CHECK_FUNCTION_AVAILABLE(vDSP_vclip);
    CHECK_FUNCTION_AVAILABLE(vDSP_vclr);
    CHECK_FUNCTION_AVAILABLE(vDSP_vfill);
    CHECK_FUNCTION_AVAILABLE(vDSP_vsadd);
    CHECK_FUNCTION_AVAILABLE(vDSP_vsbsm);
    CHECK_FUNCTION_AVAILABLE(vDSP_vsma);
    CHECK_FUNCTION_AVAILABLE(vDSP_vsmsa);
    CHECK_FUNCTION_AVAILABLE(vDSP_vsmsb);
    CHECK_FUNCTION_AVAILABLE(vDSP_vsbm);
    CHECK_FUNCTION_AVAILABLE(vDSP_vsbsm);
    CHECK_FUNCTION_AVAILABLE(vDSP_maxmgv);
    CHECK_FUNCTION_AVAILABLE(vDSP_meamgv);
    CHECK_FUNCTION_AVAILABLE(vDSP_measqv);
    CHECK_FUNCTION_AVAILABLE(vDSP_mvessq);
    CHECK_FUNCTION_AVAILABLE(vDSP_normalize);
    CHECK_FUNCTION_AVAILABLE(vDSP_svemg);
    CHECK_FUNCTION_AVAILABLE(vDSP_svesq);
    CHECK_FUNCTION_AVAILABLE(vDSP_sve);
    CHECK_FUNCTION_AVAILABLE(vDSP_maxv);
    CHECK_FUNCTION_AVAILABLE(vDSP_minv);
    CHECK_FUNCTION_AVAILABLE(vDSP_meanv);
    CHECK_FUNCTION_AVAILABLE(vDSP_measqv);
    CHECK_FUNCTION_AVAILABLE(vDSP_sve_svesq);
    CHECK_FUNCTION_AVAILABLE(vDSP_svemg);
    
    // Check vector math functions
    std::cout << "\nVector Math Functions:\n";
    CHECK_FUNCTION_AVAILABLE(vvexpf);
    CHECK_FUNCTION_AVAILABLE(vvlogf);
    CHECK_FUNCTION_AVAILABLE(vvsqrtf);
    CHECK_FUNCTION_AVAILABLE(vvsinf);
    CHECK_FUNCTION_AVAILABLE(vvcosf);
    CHECK_FUNCTION_AVAILABLE(vvtanf);
    CHECK_FUNCTION_AVAILABLE(vvasinf);
    CHECK_FUNCTION_AVAILABLE(vvacosf);
    CHECK_FUNCTION_AVAILABLE(vvatanf);
    CHECK_FUNCTION_AVAILABLE(vvsinh);
    CHECK_FUNCTION_AVAILABLE(vvcosh);
    CHECK_FUNCTION_AVAILABLE(vvtanh);
    CHECK_FUNCTION_AVAILABLE(vvlog1pf);
    CHECK_FUNCTION_AVAILABLE(vvlog10f);
    CHECK_FUNCTION_AVAILABLE(vvlog2f);
    
    // Check matrix operations
    std::cout << "\nMatrix Operations:\n";
    CHECK_FUNCTION_AVAILABLE(vDSP_mmul);
    CHECK_FUNCTION_AVAILABLE(vDSP_mmulD);
    CHECK_FUNCTION_AVAILABLE(vDSP_mtrans);
    CHECK_FUNCTION_AVAILABLE(vDSP_mtransD);
    
    // Print summary
    std::cout << "\n========================================\n";
    std::cout << "Total available functions: " << available_functions.size() << "\n";
    
    return 0;
}
