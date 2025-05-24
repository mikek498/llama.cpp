/*
 * ggml-cpu-optimized.s
 * Optimized Apple M1 micro-kernel for setting f32 tensors.
 */

.section __TEXT,__text,regular,pure_instructions
.build_version macos, 15, 0   sdk_version 15,4

// --------------------------------------------------------------------
// f32 fill micro-kernel: _mlk_f32_fill
// Arguments:
//   x0 = destination pointer (64-byte aligned)
//   x1 = element count (# of floats)
//   x2 = bitwise float constant
// Returns: none
// --------------------------------------------------------------------
.globl  __mlk_f32_fill
.p2align 2
__mlk_f32_fill:
    // prepare NEON register
    dup     v0.4s, w2

    // bytes to write = x1 * 4
    lsl     x1, x1, #2

    // unrolled store: 64 bytes per loop via st1
L1:
    prfm    pldl1keep, [x0, #256]
    st1     {v0.4s}, [x0], #16
    st1     {v0.4s}, [x0], #16
    st1     {v0.4s}, [x0], #16
    st1     {v0.4s}, [x0], #16
    subs    x1, x1, #64
    b.hs    L1

    // remainder
    cbz     x1, L3
L2:
    cmp     x1, #16
    blt     L2b_small
    st1     {v0.4s}, [x0], #16
    subs    x1, x1, #16
    b       L2
L2b_small:
    cbz     x1, L3
    cmp     x1, #4
    blt     L3
    str     w2, [x0], #4
    subs    x1, x1, #4
    b       L2b_small
L3:
    ret
