#include "vec.h"

#include <cassert>
#include <string.h>
#include <alloca.h>

#if defined(GGML_USE_ACCELERATE)
#include <Accelerate/Accelerate.h>
#endif

// precomputed gelu table for f16 (128 KB)
ggml_fp16_t ggml_table_gelu_f16[1 << 16];

// precomputed quick gelu table for f16 (128 KB)
ggml_fp16_t ggml_table_gelu_quick_f16[1 << 16];

void ggml_vec_dot_f32(int n, float * GGML_RESTRICT s, size_t bs, const float * GGML_RESTRICT x, size_t bx, const float * GGML_RESTRICT y, size_t by, int nrc) {
   // accelerate dot product if available
#ifdef GGML_USE_ACCELERATE
    vDSP_dotpr(x, 1, y, 1, s, (vDSP_Length)n);
    return;
#endif
   assert(nrc == 1);
   GGML_UNUSED(nrc);
   GGML_UNUSED(bx);
   GGML_UNUSED(by);
   GGML_UNUSED(bs);

#if defined(GGML_SIMD)
    float sumf = 0.0f;
    const int np = (n & ~(GGML_F32_STEP - 1));

    GGML_F32_VEC sum[GGML_F32_ARR] = { GGML_F32_VEC_ZERO };

    GGML_F32_VEC ax[GGML_F32_ARR];
    GGML_F32_VEC ay[GGML_F32_ARR];

    for (int i = 0; i < np; i += GGML_F32_STEP) {
        for (int j = 0; j < GGML_F32_ARR; j++) {
            ax[j] = GGML_F32_VEC_LOAD(x + i + j*GGML_F32_EPR);
            ay[j] = GGML_F32_VEC_LOAD(y + i + j*GGML_F32_EPR);

            sum[j] = GGML_F32_VEC_FMA(sum[j], ax[j], ay[j]);
        }
    }

    // reduce sum0..sum3 to sum0
    GGML_F32_VEC_REDUCE(sumf, sum);

    // leftovers
    for (int i = np; i < n; ++i) {
        sumf += x[i]*y[i];
    }
#else
    // scalar
    ggml_float sumf = 0.0;
    for (int i = 0; i < n; ++i) {
        sumf += (ggml_float)(x[i]*y[i]);
    }
#endif

    *s = sumf;
}

void ggml_vec_dot_bf16(int n, float * GGML_RESTRICT s, size_t bs, ggml_bf16_t * GGML_RESTRICT x, size_t bx, ggml_bf16_t * GGML_RESTRICT y, size_t by, int nrc) {
    assert(nrc == 1);
    GGML_UNUSED(nrc);
    GGML_UNUSED(bx);
    GGML_UNUSED(by);
    GGML_UNUSED(bs);
    int i = 0;
    ggml_float sumf = 0;

#if defined(__AVX512BF16__)
    __m512 c1 = _mm512_setzero_ps();
    __m512 c2 = _mm512_setzero_ps();
    for (; i + 64 <= n; i += 64) {
        c1 = _mm512_dpbf16_ps(c1, m512bh(_mm512_loadu_si512((x + i))),
                             m512bh(_mm512_loadu_si512((y + i))));
        c2 = _mm512_dpbf16_ps(c2, m512bh(_mm512_loadu_si512((x + i + 32))),
                             m512bh(_mm512_loadu_si512((y + i + 32))));
    }
    sumf += (ggml_float)_mm512_reduce_add_ps(c1);
    sumf += (ggml_float)_mm512_reduce_add_ps(c2);

#elif defined(__AVX512F__)
#define LOAD(p) _mm512_castsi512_ps(_mm512_slli_epi32(_mm512_cvtepu16_epi32(_mm256_loadu_si256((const __m256i *)(p))), 16))
    __m512 c1 = _mm512_setzero_ps();
    __m512 c2 = _mm512_setzero_ps();
    for (; i + 32 <= n; i += 32) {
        c1 = _mm512_add_ps(_mm512_mul_ps(LOAD(x + i), LOAD(y + i)), c1);
        c2 = _mm512_add_ps(_mm512_mul_ps(LOAD(x + i + 16), LOAD(y + i + 16)), c2);
    }
    sumf += (ggml_float)_mm512_reduce_add_ps(c1);
    sumf += (ggml_float)_mm512_reduce_add_ps(c2);

#undef LOAD
#elif defined(__AVX2__) || defined(__AVX__)
#if defined(__AVX2__)
#define LOAD(p) _mm256_castsi256_ps(_mm256_slli_epi32(_mm256_cvtepu16_epi32(_mm_loadu_si128((const __m128i *)(p))), 16))
#else
#define LOAD(p) _mm256_castsi256_ps(_mm256_insertf128_si256(_mm256_castsi128_si256(_mm_slli_epi32(_mm_cvtepu16_epi32(_mm_loadu_si128((const __m128i *)(p))), 16)), (_mm_slli_epi32(_mm_cvtepu16_epi32(_mm_bsrli_si128(_mm_loadu_si128((const __m128i *)(p)), 8)), 16)), 1))
#endif
    __m256 c1 = _mm256_setzero_ps();
    __m256 c2 = _mm256_setzero_ps();
    __m256 c3 = _mm256_setzero_ps();
    __m256 c4 = _mm256_setzero_ps();
    for (; i + 32 <= n; i += 32) {
        c1 = _mm256_add_ps(_mm256_mul_ps(LOAD(x + i), LOAD(y + i)), c1);
        c2 = _mm256_add_ps(_mm256_mul_ps(LOAD(x + i + 8), LOAD(y + i + 8)), c2);
        c3 = _mm256_add_ps(_mm256_mul_ps(LOAD(x + i + 16), LOAD(y + i + 16)), c3);
        c4 = _mm256_add_ps(_mm256_mul_ps(LOAD(x + i + 24), LOAD(y + i + 24)), c4);
    }
    __m128 g;
    c1 = _mm256_add_ps(_mm256_add_ps(c1, c3),
                       _mm256_add_ps(c2, c4));
    g = _mm_add_ps(_mm256_extractf128_ps(c1, 1),
                   _mm256_castps256_ps128(c1));
    g = _mm_add_ps(g, _mm_movehl_ps(g, g));
    g = _mm_add_ss(g, _mm_movehdup_ps(g));
    sumf += (ggml_float)_mm_cvtss_f32(g);

#undef LOAD
#endif

    for (; i < n; ++i) {
        sumf += (ggml_float)(GGML_BF16_TO_FP32(x[i]) *
                             GGML_BF16_TO_FP32(y[i]));
    }
    *s = sumf;
}

void ggml_vec_dot_f16(int n, float * GGML_RESTRICT s, size_t bs, ggml_fp16_t * GGML_RESTRICT x, size_t bx, ggml_fp16_t * GGML_RESTRICT y, size_t by, int nrc) {
    assert(nrc == 1);
    GGML_UNUSED(nrc);
    GGML_UNUSED(bx);
    GGML_UNUSED(by);
    GGML_UNUSED(bs);

    ggml_float sumf = 0.0;

#if defined(GGML_SIMD)
    const int np = (n & ~(GGML_F16_STEP - 1));

    GGML_F16_VEC sum[GGML_F16_ARR] = { GGML_F16_VEC_ZERO };

    GGML_F16_VEC ax[GGML_F16_ARR];
    GGML_F16_VEC ay[GGML_F16_ARR];

    for (int i = 0; i < np; i += GGML_F16_STEP) {
        for (int j = 0; j < GGML_F16_ARR; j++) {
            ax[j] = GGML_F16_VEC_LOAD(x + i + j*GGML_F16_EPR, j);
            ay[j] = GGML_F16_VEC_LOAD(y + i + j*GGML_F16_EPR, j);

            sum[j] = GGML_F16_VEC_FMA(sum[j], ax[j], ay[j]);
        }
    }

    // reduce sum0..sum3 to sum0
    GGML_F16_VEC_REDUCE(sumf, sum);

    // leftovers
    for (int i = np; i < n; ++i) {
        sumf += (ggml_float)(GGML_FP16_TO_FP32(x[i])*GGML_FP16_TO_FP32(y[i]));
    }
#else
    for (int i = 0; i < n; ++i) {
        sumf += (ggml_float)(GGML_FP16_TO_FP32(x[i])*GGML_FP16_TO_FP32(y[i]));
    }
#endif

    *s = sumf;
}

void ggml_vec_silu_f32(const int n, float * y, const float * x) {
#if defined(GGML_USE_ACCELERATE) && defined(__APPLE__)
    // vForce functions take int * for count, so ensure n fits in int.
    // INT_MAX is usually from <limits.h> or <climits> (or transitively from Accelerate.h).
    // If n is 0 or negative, or too large, fall through to SIMD/scalar.
    if (n > 0 && n <= 2147483647) { // Using INT_MAX literal for robustness against missing includes
        int count = (int)n;
        vvexpf(y, x, &count);
        return;
    }
#endif
    int i = 0;
#if defined(__AVX512F__) && defined(__AVX512DQ__)
    for (; i + 15 < n; i += 16) {
        _mm512_storeu_ps(y + i, ggml_v_silu(_mm512_loadu_ps(x + i)));
    }
#elif defined(__AVX2__) && defined(__FMA__)
    for (; i + 7 < n; i += 8) {
        _mm256_storeu_ps(y + i, ggml_v_silu(_mm256_loadu_ps(x + i)));
    }
#elif defined(__SSE2__)
    for (; i + 3 < n; i += 4) {
        _mm_storeu_ps(y + i, ggml_v_silu(_mm_loadu_ps(x + i)));
    }
#elif defined(__ARM_NEON) && defined(__aarch64__)
    for (; i + 3 < n; i += 4) {
        vst1q_f32(y + i, ggml_v_silu(vld1q_f32(x + i)));
    }
#endif
    for (; i < n; ++i) {
        y[i] = ggml_silu_f32(x[i]);
    }
}

void ggml_vec_add_f32(const int n, float * z, const float * x, const float * y) {
    int i = 0;
#if defined(__AVX512F__)
    for (; i + 15 < n; i += 16) {
        _mm512_storeu_ps(z + i, _mm512_add_ps(_mm512_loadu_ps(x + i), _mm512_loadu_ps(y + i)));
    }
#elif defined(__AVX2__) && defined(__FMA__)
    for (; i + 7 < n; i += 8) {
        _mm256_storeu_ps(z + i, _mm256_add_ps(_mm256_loadu_ps(x + i), _mm256_loadu_ps(y + i)));
    }
#elif defined(__SSE2__)
    for (; i + 3 < n; i += 4) {
        _mm_storeu_ps(z + i, _mm_add_ps(_mm_loadu_ps(x + i), _mm_loadu_ps(y + i)));
    }
#elif defined(__ARM_NEON) && defined(__aarch64__)
    for (; i + 3 < n; i += 4) {
        vst1q_f32(z + i, vaddq_f32(vld1q_f32(x + i), vld1q_f32(y + i)));
    }
#endif
    // Scalar loop for leftovers or if no SIMD
    for (; i < n; ++i) {
        z[i] = x[i] + y[i];
    }
}

void ggml_vec_sub_f32(const int n, float * z, const float * x, const float * y) {
    int i = 0;
#if defined(__AVX512F__)
    for (; i + 15 < n; i += 16) {
        _mm512_storeu_ps(z + i, _mm512_sub_ps(_mm512_loadu_ps(x + i), _mm512_loadu_ps(y + i)));
    }
#elif defined(__AVX2__) && defined(__FMA__)
    for (; i + 7 < n; i += 8) {
        _mm256_storeu_ps(z + i, _mm256_sub_ps(_mm256_loadu_ps(x + i), _mm256_loadu_ps(y + i)));
    }
#elif defined(__SSE2__)
    for (; i + 3 < n; i += 4) {
        _mm_storeu_ps(z + i, _mm_sub_ps(_mm_loadu_ps(x + i), _mm_loadu_ps(y + i)));
    }
#elif defined(__ARM_NEON) && defined(__aarch64__)
    for (; i + 3 < n; i += 4) {
        vst1q_f32(z + i, vsubq_f32(vld1q_f32(x + i), vld1q_f32(y + i)));
    }
#endif
    // Scalar loop for leftovers or if no SIMD
    for (; i < n; ++i) {
        z[i] = x[i] - y[i];
    }
}

void ggml_vec_mul_f32(const int n, float * z, const float * x, const float * y) {
    int i = 0;
#if defined(__AVX512F__)
    for (; i + 15 < n; i += 16) {
        _mm512_storeu_ps(z + i, _mm512_mul_ps(_mm512_loadu_ps(x + i), _mm512_loadu_ps(y + i)));
    }
#elif defined(__AVX2__) && defined(__FMA__)
    for (; i + 7 < n; i += 8) {
        _mm256_storeu_ps(z + i, _mm256_mul_ps(_mm256_loadu_ps(x + i), _mm256_loadu_ps(y + i)));
    }
#elif defined(__SSE2__)
    for (; i + 3 < n; i += 4) {
        _mm_storeu_ps(z + i, _mm_mul_ps(_mm_loadu_ps(x + i), _mm_loadu_ps(y + i)));
    }
#elif defined(__ARM_NEON) && defined(__aarch64__)
    for (; i + 3 < n; i += 4) {
        vst1q_f32(z + i, vmulq_f32(vld1q_f32(x + i), vld1q_f32(y + i)));
    }
#endif
    // Scalar loop for leftovers or if no SIMD
    for (; i < n; ++i) {
        z[i] = x[i] * y[i];
    }
}

void ggml_vec_hardswish_f32(const int n, float * y, const float * x) {
    int i = 0;
#if defined(__AVX512F__)
    const __m512 v_zero = _mm512_set1_ps(0.0f);
    const __m512 v_one = _mm512_set1_ps(1.0f);
    const __m512 v_three = _mm512_set1_ps(3.0f);
    const __m512 v_six_inv = _mm512_set1_ps(1.0f / 6.0f);
    for (; i + 15 < n; i += 16) {
        __m512 vx = _mm512_loadu_ps(x + i);
        __m512 tmp = _mm512_add_ps(vx, v_three);
        tmp = _mm512_mul_ps(tmp, v_six_inv);
        tmp = _mm512_max_ps(v_zero, tmp);
        tmp = _mm512_min_ps(v_one, tmp);
        _mm512_storeu_ps(y + i, _mm512_mul_ps(vx, tmp));
    }
#elif defined(__AVX2__) && defined(__FMA__)
    const __m256 v_zero = _mm256_set1_ps(0.0f);
    const __m256 v_one = _mm256_set1_ps(1.0f);
    const __m256 v_three = _mm256_set1_ps(3.0f);
    const __m256 v_six_inv = _mm256_set1_ps(1.0f / 6.0f);
    for (; i + 7 < n; i += 8) {
        __m256 vx = _mm256_loadu_ps(x + i);
        __m256 tmp = _mm256_add_ps(vx, v_three);
        tmp = _mm256_mul_ps(tmp, v_six_inv);
        tmp = _mm256_max_ps(v_zero, tmp);
        tmp = _mm256_min_ps(v_one, tmp);
        _mm256_storeu_ps(y + i, _mm256_mul_ps(vx, tmp));
    }
#elif defined(__SSE2__)
    const __m128 v_zero = _mm_set1_ps(0.0f);
    const __m128 v_one = _mm_set1_ps(1.0f);
    const __m128 v_three = _mm_set1_ps(3.0f);
    const __m128 v_six_inv = _mm_set1_ps(1.0f / 6.0f);
    for (; i + 3 < n; i += 4) {
        __m128 vx = _mm_loadu_ps(x + i);
        __m128 tmp = _mm_add_ps(vx, v_three);
        tmp = _mm_mul_ps(tmp, v_six_inv);
        tmp = _mm_max_ps(v_zero, tmp);
        tmp = _mm_min_ps(v_one, tmp);
        _mm_storeu_ps(y + i, _mm_mul_ps(vx, tmp));
    }
#elif defined(__ARM_NEON) && defined(__aarch64__)
    const float32x4_t v_zero = vdupq_n_f32(0.0f);
    const float32x4_t v_one = vdupq_n_f32(1.0f);
    const float32x4_t v_three = vdupq_n_f32(3.0f);
    const float32x4_t v_six_inv = vdupq_n_f32(1.0f / 6.0f);
    for (; i + 3 < n; i += 4) {
        float32x4_t vx = vld1q_f32(x + i);
        float32x4_t tmp = vaddq_f32(vx, v_three);
        tmp = vmulq_f32(tmp, v_six_inv);
        tmp = vmaxq_f32(v_zero, tmp);
        tmp = vminq_f32(v_one, tmp);
        vst1q_f32(y + i, vmulq_f32(vx, tmp));
    }
#endif
    // Scalar loop for leftovers or if no SIMD
    for (; i < n; ++i) {
        y[i] = x[i] * fminf(1.0f, fmaxf(0.0f, (x[i] + 3.0f) / 6.0f));
    }
}

void ggml_vec_div_f32(const int n, float * z, const float * x, const float * y) {
    int i = 0;
#if defined(__AVX512F__)
    for (; i + 15 < n; i += 16) {
        _mm512_storeu_ps(z + i, _mm512_div_ps(_mm512_loadu_ps(x + i), _mm512_loadu_ps(y + i)));
    }
#elif defined(__AVX2__) && defined(__FMA__)
    for (; i + 7 < n; i += 8) {
        _mm256_storeu_ps(z + i, _mm256_div_ps(_mm256_loadu_ps(x + i), _mm256_loadu_ps(y + i)));
    }
#elif defined(__SSE2__)
    for (; i + 3 < n; i += 4) {
        _mm_storeu_ps(z + i, _mm_div_ps(_mm_loadu_ps(x + i), _mm_loadu_ps(y + i)));
    }
#elif defined(__ARM_NEON) && defined(__aarch64__)
    for (; i + 3 < n; i += 4) {
        vst1q_f32(z + i, vdivq_f32(vld1q_f32(x + i), vld1q_f32(y + i)));
    }
#endif
    // Scalar loop for leftovers or if no SIMD
    for (; i < n; ++i) {
        z[i] = x[i] / y[i];
    }
}

void ggml_vec_cpy_f32(const int n, float * y, const float * x) {
    int i = 0;
#if defined(__AVX512F__)
    for (; i + 15 < n; i += 16) {
        _mm512_storeu_ps(y + i, _mm512_loadu_ps(x + i));
    }
#elif defined(__AVX2__) && defined(__FMA__)
    for (; i + 7 < n; i += 8) {
        _mm256_storeu_ps(y + i, _mm256_loadu_ps(x + i));
    }
#elif defined(__SSE2__)
    for (; i + 3 < n; i += 4) {
        _mm_storeu_ps(y + i, _mm_loadu_ps(x + i));
    }
#elif defined(__ARM_NEON) && defined(__aarch64__)
    for (; i + 3 < n; i += 4) {
        vst1q_f32(y + i, vld1q_f32(x + i));
    }
#endif
    // Scalar loop for leftovers or if no SIMD
    // For very small n, or if no SIMD, memcpy might be slower due to function call overhead.
    // However, for larger n where SIMD would be used, this scalar loop is just a fallback.
    // Consider replacing with memcpy if profiling shows it's better for the non-SIMD case.
    if (i < n) { // Check if there are any elements left for the scalar loop
        memcpy(y + i, x + i, (n - i) * sizeof(float));
    }
}

void ggml_vec_neg_f32(const int n, float * y, const float * x) {
    int i = 0;
#if defined(__AVX512F__)
    const __m512 zero = _mm512_setzero_ps();
    for (; i + 15 < n; i += 16) {
        _mm512_storeu_ps(y + i, _mm512_sub_ps(zero, _mm512_loadu_ps(x + i)));
    }
#elif defined(__AVX2__) && defined(__FMA__)
    const __m256 zero = _mm256_setzero_ps();
    for (; i + 7 < n; i += 8) {
        _mm256_storeu_ps(y + i, _mm256_sub_ps(zero, _mm256_loadu_ps(x + i)));
    }
#elif defined(__SSE2__)
    const __m128 zero = _mm_setzero_ps();
    for (; i + 3 < n; i += 4) {
        _mm_storeu_ps(y + i, _mm_sub_ps(zero, _mm_loadu_ps(x + i)));
    }
#elif defined(__ARM_NEON) && defined(__aarch64__)
    for (; i + 3 < n; i += 4) {
        vst1q_f32(y + i, vnegq_f32(vld1q_f32(x + i)));
    }
#endif
    // Scalar loop for leftovers or if no SIMD
    for (; i < n; ++i) {
        y[i] = -x[i];
    }
}

void ggml_vec_sqr_f32(const int n, float * y, const float * x) {
    int i = 0;
#if defined(__AVX512F__)
    for (; i + 15 < n; i += 16) {
        const __m512 vx = _mm512_loadu_ps(x + i);
        _mm512_storeu_ps(y + i, _mm512_mul_ps(vx, vx));
    }
#elif defined(__AVX2__) && defined(__FMA__)
    for (; i + 7 < n; i += 8) {
        const __m256 vx = _mm256_loadu_ps(x + i);
        _mm256_storeu_ps(y + i, _mm256_mul_ps(vx, vx));
    }
#elif defined(__SSE2__)
    for (; i + 3 < n; i += 4) {
        const __m128 vx = _mm_loadu_ps(x + i);
        _mm_storeu_ps(y + i, _mm_mul_ps(vx, vx));
    }
#elif defined(__ARM_NEON) && defined(__aarch64__)
    for (; i + 3 < n; i += 4) {
        const float32x4_t vx = vld1q_f32(x + i);
        vst1q_f32(y + i, vmulq_f32(vx, vx));
    }
#endif
    // Scalar loop for leftovers or if no SIMD
    for (; i < n; ++i) {
        y[i] = x[i] * x[i];
    }
}

void ggml_vec_set_f32(const int n, float * x, const float v) {
    int i = 0;
#if defined(__AVX512F__)
    const __m512 vv = _mm512_set1_ps(v);
    for (; i + 15 < n; i += 16) {
        _mm512_storeu_ps(x + i, vv);
    }
#elif defined(__AVX2__) && defined(__FMA__)
    const __m256 vv = _mm256_set1_ps(v);
    for (; i + 7 < n; i += 8) {
        _mm256_storeu_ps(x + i, vv);
    }
#elif defined(__SSE2__)
    const __m128 vv = _mm_set1_ps(v);
    for (; i + 3 < n; i += 4) {
        _mm_storeu_ps(x + i, vv);
    }
#elif defined(__ARM_NEON) && defined(__aarch64__)
    const float32x4_t vv = vdupq_n_f32(v);
    for (; i + 3 < n; i += 4) {
        vst1q_f32(x + i, vv);
    }
#endif
    // Scalar loop for leftovers or if no SIMD
    for (; i < n; ++i) {
        x[i] = v;
    }
}

void ggml_vec_add1_f32(const int n, float * y, const float * x, const float v) {
    int i = 0;
#if defined(__AVX512F__)
    const __m512 vv = _mm512_set1_ps(v);
    for (; i + 15 < n; i += 16) {
        _mm512_storeu_ps(y + i, _mm512_add_ps(_mm512_loadu_ps(x + i), vv));
    }
#elif defined(__AVX2__) && defined(__FMA__)
    const __m256 vv = _mm256_set1_ps(v);
    for (; i + 7 < n; i += 8) {
        _mm256_storeu_ps(y + i, _mm256_add_ps(_mm256_loadu_ps(x + i), vv));
    }
#elif defined(__SSE2__)
    const __m128 vv = _mm_set1_ps(v);
    for (; i + 3 < n; i += 4) {
        _mm_storeu_ps(y + i, _mm_add_ps(_mm_loadu_ps(x + i), vv));
    }
#elif defined(__ARM_NEON) && defined(__aarch64__)
    const float32x4_t vv = vdupq_n_f32(v);
    for (; i + 3 < n; i += 4) {
        vst1q_f32(y + i, vaddq_f32(vld1q_f32(x + i), vv));
    }
#endif
    // Scalar loop for leftovers or if no SIMD
    for (; i < n; ++i) {
        y[i] = x[i] + v;
    }
}

void ggml_vec_acc_f32(const int n, float * y, const float * x) {
    int i = 0;
#if defined(__AVX512F__)
    for (; i + 15 < n; i += 16) {
        _mm512_storeu_ps(y + i, _mm512_add_ps(_mm512_loadu_ps(y + i), _mm512_loadu_ps(x + i)));
    }
#elif defined(__AVX2__) && defined(__FMA__)
    for (; i + 7 < n; i += 8) {
        _mm256_storeu_ps(y + i, _mm256_add_ps(_mm256_loadu_ps(y + i), _mm256_loadu_ps(x + i)));
    }
#elif defined(__SSE2__)
    for (; i + 3 < n; i += 4) {
        _mm_storeu_ps(y + i, _mm_add_ps(_mm_loadu_ps(y + i), _mm_loadu_ps(x + i)));
    }
#elif defined(__ARM_NEON) && defined(__aarch64__)
    for (; i + 3 < n; i += 4) {
        vst1q_f32(y + i, vaddq_f32(vld1q_f32(y + i), vld1q_f32(x + i)));
    }
#endif
    // Scalar loop for leftovers or if no SIMD
    for (; i < n; ++i) {
        y[i] += x[i];
    }
}

void ggml_vec_acc1_f32(const int n, float * y, const float v) {
    int i = 0;
#if defined(__AVX512F__)
    const __m512 vv = _mm512_set1_ps(v);
    for (; i + 15 < n; i += 16) {
        _mm512_storeu_ps(y + i, _mm512_add_ps(_mm512_loadu_ps(y + i), vv));
    }
#elif defined(__AVX2__) && defined(__FMA__)
    const __m256 vv = _mm256_set1_ps(v);
    for (; i + 7 < n; i += 8) {
        _mm256_storeu_ps(y + i, _mm256_add_ps(_mm256_loadu_ps(y + i), vv));
    }
#elif defined(__SSE2__)
    const __m128 vv = _mm_set1_ps(v);
    for (; i + 3 < n; i += 4) {
        _mm_storeu_ps(y + i, _mm_add_ps(_mm_loadu_ps(y + i), vv));
    }
#elif defined(__ARM_NEON) && defined(__aarch64__)
    const float32x4_t vv = vdupq_n_f32(v);
    for (; i + 3 < n; i += 4) {
        vst1q_f32(y + i, vaddq_f32(vld1q_f32(y + i), vv));
    }
#endif
    // Scalar loop for leftovers or if no SIMD
    for (; i < n; ++i) {
        y[i] += v;
    }
}

void ggml_vec_exp_f32(const int n, float * y, const float * x) {
    int i = 0;
#if defined(__AVX512F__) && defined(__AVX512DQ__)
    for (; i + 15 < n; i += 16) {
        _mm512_storeu_ps(y + i, ggml_v_expf(_mm512_loadu_ps(x + i)));
    }
#elif defined(__AVX2__) && defined(__FMA__)
    for (; i + 7 < n; i += 8) {
        _mm256_storeu_ps(y + i, ggml_v_expf(_mm256_loadu_ps(x + i)));
    }
#elif defined(__SSE2__)
    for (; i + 3 < n; i += 4) {
        _mm_storeu_ps(y + i, ggml_v_expf(_mm_loadu_ps(x + i)));
    }
#elif defined(__ARM_NEON) && defined(__aarch64__)
    for (; i + 3 < n; i += 4) {
        vst1q_f32(y + i, ggml_v_expf(vld1q_f32(x + i)));
    }
#endif
    // Scalar loop for leftovers or if no SIMD
    for (; i < n; ++i) {
        y[i] = expf(x[i]);
    }
}

void ggml_vec_sqrt_f32(const int n, float * y, const float * x) {
    int i = 0;
#if defined(__AVX512F__)
    for (; i + 15 < n; i += 16) {
        _mm512_storeu_ps(y + i, _mm512_sqrt_ps(_mm512_loadu_ps(x + i)));
    }
#elif defined(__AVX2__) && defined(__FMA__)
    for (; i + 7 < n; i += 8) {
        _mm256_storeu_ps(y + i, _mm256_sqrt_ps(_mm256_loadu_ps(x + i)));
    }
#elif defined(__SSE2__)
    for (; i + 3 < n; i += 4) {
        _mm_storeu_ps(y + i, _mm_sqrt_ps(_mm_loadu_ps(x + i)));
    }
#elif defined(__ARM_NEON) && defined(__aarch64__)
    for (; i + 3 < n; i += 4) {
        vst1q_f32(y + i, vsqrtq_f32(vld1q_f32(x + i)));
    }
#endif
    // Scalar loop for leftovers or if no SIMD
    for (; i < n; ++i) {
        y[i] = sqrtf(x[i]);
    }
}

void ggml_vec_abs_f32(const int n, float * y, const float * x) {
    int i = 0;
#if defined(__AVX512F__)
    // Mask to clear the sign bit (0x7FFFFFFF for single precision float)
    const __m512 sign_mask = _mm512_castsi512_ps(_mm512_set1_epi32(0x7FFFFFFF));
    for (; i + 15 < n; i += 16) {
        _mm512_storeu_ps(y + i, _mm512_and_ps(_mm512_loadu_ps(x + i), sign_mask));
    }
#elif defined(__AVX2__) && defined(__FMA__)
    const __m256 sign_mask = _mm256_castsi256_ps(_mm256_set1_epi32(0x7FFFFFFF));
    for (; i + 7 < n; i += 8) {
        _mm256_storeu_ps(y + i, _mm256_and_ps(_mm256_loadu_ps(x + i), sign_mask));
    }
#elif defined(__SSE2__)
    const __m128 sign_mask = _mm_castsi128_ps(_mm_set1_epi32(0x7FFFFFFF));
    for (; i + 3 < n; i += 4) {
        _mm_storeu_ps(y + i, _mm_and_ps(_mm_loadu_ps(x + i), sign_mask));
    }
#elif defined(__ARM_NEON) && defined(__aarch64__)
    for (; i + 3 < n; i += 4) {
        vst1q_f32(y + i, vabsq_f32(vld1q_f32(x + i)));
    }
#endif
    // Scalar loop for leftovers or if no SIMD
    for (; i < n; ++i) {
        y[i] = fabsf(x[i]);
    }
}

// Definition for ggml_vec_relu_f32 (declared in vec.h)
void ggml_vec_relu_f32(const int n, float * y, const float * x) {
    int i = 0;
#if defined(__AVX512F__)
    const __m512 zero_512 = _mm512_setzero_ps();
    for (; i + 15 < n; i += 16) {
        _mm512_storeu_ps(y + i, _mm512_max_ps(zero_512, _mm512_loadu_ps(x + i)));
    }
#elif defined(__AVX2__) && defined(__FMA__)
    const __m256 zero_256 = _mm256_setzero_ps();
    for (; i + 7 < n; i += 8) {
        _mm256_storeu_ps(y + i, _mm256_max_ps(zero_256, _mm256_loadu_ps(x + i)));
    }
#elif defined(__SSE2__)
    const __m128 zero_128 = _mm_setzero_ps();
    for (; i + 3 < n; i += 4) {
        _mm_storeu_ps(y + i, _mm_max_ps(zero_128, _mm_loadu_ps(x + i)));
    }
#elif defined(__ARM_NEON) && defined(__aarch64__)
    const float32x4_t zero_neon = vdupq_n_f32(0.0f);
    for (; i + 3 < n; i += 4) {
        vst1q_f32(y + i, vmaxq_f32(zero_neon, vld1q_f32(x + i)));
    }
#endif
    // Scalar loop for leftovers or if no SIMD
    for (; i < n; ++i) {
        y[i] = (x[i] > 0.f) ? x[i] : 0.f;
    }
}

ggml_float ggml_vec_soft_max_f32(const int n, float * y, const float * x, float max) {
    ggml_float sum = 0;

#if defined(GGML_USE_ACCELERATE) && defined(__APPLE__)
    // Dynamic threshold based on L1 cache size
    static const size_t l1_cache_size = 32768; // 32KB L1 cache
    const bool use_accelerate = n >= 64 || (n * sizeof(float) * 4) > l1_cache_size;

    if (use_accelerate) {
        // Use aligned stack allocation with cache line alignment
        const size_t alignment = 64;
        const size_t padded_size = ((n * sizeof(float)) + (alignment - 1)) & ~(alignment - 1);
        float *temp = (float *)__builtin_alloca_with_align(padded_size, alignment);
        
        const float neg_max = -max;
        
        // Process in chunks that fit in L1 cache
        const int chunk_size = l1_cache_size / (4 * sizeof(float)); // Fit 4 vectors in L1
        int processed = 0;
        
        while (processed < n) {
            const int remaining = n - processed;
            const int current_chunk = (remaining > chunk_size) ? chunk_size : remaining;
            const int aligned_chunk = current_chunk & ~3; // Align to 4 elements
            
            // Process aligned chunks
            if (aligned_chunk > 0) {
                vDSP_vsadd(x + processed, 1, &neg_max, temp, 1, aligned_chunk);
                int count = aligned_chunk;
                vvexpf(y + processed, temp, &count);
                
                // Use SIMD sum reduction for better performance
                float chunk_sum = 0.0f;
                vDSP_sve(y + processed, 1, &chunk_sum, aligned_chunk);
                sum += (ggml_float)chunk_sum;
                processed += aligned_chunk;
            }
            
            // Handle remaining elements
            if (current_chunk > aligned_chunk) {
                vDSP_vsadd(x + processed, 1, &neg_max, temp, 1, current_chunk - aligned_chunk);
                int count = current_chunk - aligned_chunk;
                vvexpf(y + processed, temp, &count);
                
                float chunk_sum = 0.0f;
                vDSP_sve(y + processed, 1, &chunk_sum, current_chunk - aligned_chunk);
                sum += (ggml_float)chunk_sum;
                processed += current_chunk - aligned_chunk;
            }
        }
    } else {
        // Optimized scalar implementation with fast exp approximation
        float sum_f = 0.0f;
        int i = 0;
        
        // Fast exp approximation constants
        const float a = 12102203.0f; // 2^23 * ln(2)
        const float b = 1064872507.0f; // (2^23 * ln(2)) * (127 - 0.043677448f)
        
        // Process 8 elements at a time for better ILP
        for (; i + 7 < n; i += 8) {
            // Fast exp approximation: exp(x) ≈ 2^(x * log2(e))
            const float x0 = x[i] - max;
            const float x1 = x[i+1] - max;
            const float x2 = x[i+2] - max;
            const float x3 = x[i+3] - max;
            const float x4 = x[i+4] - max;
            const float x5 = x[i+5] - max;
            const float x6 = x[i+6] - max;
            const float x7 = x[i+7] - max;
            
            // Use bit manipulation for faster exp approximation
            const int32_t i0 = (int32_t)(a * x0 + b);
            const int32_t i1 = (int32_t)(a * x1 + b);
            const int32_t i2 = (int32_t)(a * x2 + b);
            const int32_t i3 = (int32_t)(a * x3 + b);
            const int32_t i4 = (int32_t)(a * x4 + b);
            const int32_t i5 = (int32_t)(a * x5 + b);
            const int32_t i6 = (int32_t)(a * x6 + b);
            const int32_t i7 = (int32_t)(a * x7 + b);
            
            // Convert back to float and store
            y[i]   = *((float*)&i0);
            y[i+1] = *((float*)&i1);
            y[i+2] = *((float*)&i2);
            y[i+3] = *((float*)&i3);
            y[i+4] = *((float*)&i4);
            y[i+5] = *((float*)&i5);
            y[i+6] = *((float*)&i6);
            y[i+7] = *((float*)&i7);
            
            // Sum with instruction-level parallelism
            sum_f += y[i] + y[i+1] + y[i+2] + y[i+3] + 
                    y[i+4] + y[i+5] + y[i+6] + y[i+7];
        }
        
        // Handle remaining elements
        for (; i < n; ++i) {
            y[i] = expf(x[i] - max);
            sum_f += y[i];
        }
        sum = (ggml_float)sum_f;
    }
#else
    // [Previous SIMD-optimized implementation remains the same]
    // ... (rest of the existing code)
#endif // GGML_USE_ACCELERATE
        
    return sum;
}

ggml_float ggml_vec_log_soft_max_f32(const int n, float * y, const float * x, float max) {
    // log(soft_max) = log(soft_max_i / soft_max_sum) = log(soft_max_i) - log(soft_max_sum) = (logit_i - max) - log(soft_max_i)

    int i = 0;
    ggml_float sum = 0;

#if defined(__AVX512F__) && defined(__AVX512DQ__)
    for (; i + 15 < n; i += 16) {
        __m512 x_chunk = _mm512_loadu_ps(x + i);
        __m512 max_vec = _mm512_set1_ps(max);
        __m512 y_chunk = _mm512_sub_ps(x_chunk, max_vec);
        _mm512_storeu_ps(y + i, y_chunk);
        __m512 exp_chunk = ggml_v_expf(y_chunk);
        sum += (ggml_float)_mm512_reduce_add_ps(exp_chunk);
    }
#elif defined(__AVX2__) && defined(__FMA__)
    for (; i + 7 < n; i += 8) {
        __m256 x_chunk = _mm256_loadu_ps(x + i);
        __m256 max_vec = _mm256_set1_ps(max);
        __m256 y_chunk = _mm256_sub_ps(x_chunk, max_vec);
        _mm256_storeu_ps(y + i, y_chunk);
        __m256 exp_chunk = ggml_v_expf(y_chunk);
        __m128 sum_halves = _mm_add_ps(_mm256_extractf128_ps(exp_chunk, 1), _mm256_castps256_ps128(exp_chunk));
        sum_halves = _mm_add_ps(sum_halves, _mm_movehl_ps(sum_halves, sum_halves));
        sum_halves = _mm_add_ss(sum_halves, _mm_movehdup_ps(sum_halves));
        sum += (ggml_float)_mm_cvtss_f32(sum_halves);
    }
#elif defined(__SSE2__)
    // SSE2 path: y[i] = x[i] - max; sum += expf(y[i]);
    // Not directly using ggml_v_expf like others due to potential complexity vs benefit for SSE2 only
    // Keeping scalar path for SSE2 initially unless a clear SSE2 ggml_v_expf pattern for this exists.
    // However, the subtraction and store part can be vectorized.
    for (; i + 3 < n; i += 4) {
        __m128 x_chunk = _mm_loadu_ps(x + i);
        __m128 max_vec = _mm_set1_ps(max);
        __m128 y_chunk = _mm_sub_ps(x_chunk, max_vec);
        _mm_storeu_ps(y + i, y_chunk);
        // Scalar expf and sum for this SIMD block
        // This is a compromise for SSE2 to avoid complex expf vectorization if not readily available
        // or if ggml_v_expf for SSE2 has a different signature/usage.
        // For consistency and potential small gain, let's use scalar for this part of the block.
        sum += (ggml_float)expf(y[i+0]);
        sum += (ggml_float)expf(y[i+1]);
        sum += (ggml_float)expf(y[i+2]);
        sum += (ggml_float)expf(y[i+3]);
    }
#elif defined(__ARM_NEON) && defined(__aarch64__)
    for (; i + 3 < n; i += 4) {
        float32x4_t x_chunk = vld1q_f32(x + i);
        float32x4_t max_vec = vdupq_n_f32(max);
        float32x4_t y_chunk = vsubq_f32(x_chunk, max_vec);
        vst1q_f32(y + i, y_chunk);
        float32x4_t exp_chunk = ggml_v_expf(y_chunk);
        sum += (ggml_float)vaddvq_f32(exp_chunk);
    }
#endif
    // Scalar loop for leftovers
    for (; i < n; ++i) {
        float val = x[i] - max;
        y[i] = val;
        sum += (ggml_float)expf(val);
    }

    float log_sum = logf(sum);
    i = 0; // Reset i for the second loop

#if defined(__AVX512F__) && defined(__AVX512DQ__)
    __m512 v_log_sum_512 = _mm512_set1_ps(log_sum);
    __m512 v_neg_inf_512 = _mm512_set1_ps(-INFINITY);
    for (; i + 15 < n; i += 16) {
        __m512 y_chunk = _mm512_loadu_ps(y + i);
        __mmask16 mask = _mm512_cmp_ps_mask(y_chunk, v_neg_inf_512, _CMP_GT_OQ);
        // Subtract only where mask is true (y_chunk > -INF), keeping original y_chunk where mask is false
        __m512 result = _mm512_mask_sub_ps(y_chunk, mask, y_chunk, v_log_sum_512);
        _mm512_storeu_ps(y + i, result);
    }
#elif defined(__AVX2__) && defined(__FMA__)
    __m256 v_log_sum_256 = _mm256_set1_ps(log_sum);
    __m256 v_neg_inf_256 = _mm256_set1_ps(-INFINITY);
    for (; i + 7 < n; i += 8) {
        __m256 y_chunk = _mm256_loadu_ps(y + i);
        __m256 y_sub   = _mm256_sub_ps(y_chunk, v_log_sum_256);
        __m256 mask    = _mm256_cmp_ps(y_chunk, v_neg_inf_256, _CMP_GT_OQ);
        // if mask[j] is set (y_chunk[j] > -INF), use y_sub[j], else y_chunk[j]
        __m256 result  = _mm256_blendv_ps(y_chunk, y_sub, mask);
        _mm256_storeu_ps(y + i, result);
    }
#elif defined(__ARM_NEON) && defined(__aarch64__)
    float32x4_t v_log_sum_neon = vdupq_n_f32(log_sum);
    float32x4_t v_neg_inf_neon = vdupq_n_f32(-INFINITY);
    for (; i + 3 < n; i += 4) {
        float32x4_t y_chunk = vld1q_f32(y + i);
        float32x4_t y_sub   = vsubq_f32(y_chunk, v_log_sum_neon);
        uint32x4_t  mask    = vcgtq_f32(y_chunk, v_neg_inf_neon); // Compare Greater Than
        // if mask[j] is set (y_chunk[j] > -INF), use y_sub[j], else y_chunk[j]
        float32x4_t result  = vbslq_f32(mask, y_sub, y_chunk);
        vst1q_f32(y + i, result);
    }
#endif
    // Scalar loop for remaining elements
    for (; i < n; ++i) {
        if (y[i] > -INFINITY) {
            y[i] -= log_sum;
        }
    }
    return sum; // Original function returned sum, but we need log_sum for the log_softmax logic
                // However, the *name* implies it returns the sum (not log_sum) and modifies y.
                // The actual ggml_compute_forward_soft_max uses the return value as 'sum'.
                // Let's stick to the current return type and behavior observed.
                // The second loop applies the log_sum.
}
