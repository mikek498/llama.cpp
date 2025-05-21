	.section	__TEXT,__text,regular,pure_instructions
	.build_version macos, 15, 0	sdk_version 15, 4
	.globl	_ggml_get_type_traits_cpu       ; -- Begin function ggml_get_type_traits_cpu
	.p2align	2
_ggml_get_type_traits_cpu:              ; @ggml_get_type_traits_cpu
	.cfi_startproc
; %bb.0:
	mov	w8, w0
Lloh0:
	adrp	x9, _type_traits_cpu@PAGE
Lloh1:
	add	x9, x9, _type_traits_cpu@PAGEOFF
	add	x0, x9, x8, lsl #5
	ret
	.loh AdrpAdd	Lloh0, Lloh1
	.cfi_endproc
                                        ; -- End function
	.globl	_ggml_barrier                   ; -- Begin function ggml_barrier
	.p2align	2
_ggml_barrier:                          ; @ggml_barrier
	.cfi_startproc
; %bb.0:
	ldr	w8, [x0, #348]
	subs	w10, w8, #1
	b.eq	LBB1_6
; %bb.1:
	ldr	w8, [x0, #256]
	add	x11, x0, #192
	mov	w9, #1                          ; =0x1
	ldaddal	w9, w11, [x11]
	cmp	w11, w10
	b.ne	LBB1_3
; %bb.2:
	str	wzr, [x0, #192]
	add	x8, x0, #256
	ldaddal	w9, w8, [x8]
	ret
LBB1_3:                                 ; =>This Inner Loop Header: Depth=1
	ldr	w9, [x0, #256]
	cmp	w9, w8
	b.ne	LBB1_5
; %bb.4:                                ;   in Loop: Header=BB1_3 Depth=1
	; InlineAsm Start
	yield
	; InlineAsm End
	b	LBB1_3
LBB1_5:
	dmb	ish
LBB1_6:
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_ggml_numa_init                 ; -- Begin function ggml_numa_init
	.p2align	2
_ggml_numa_init:                        ; @ggml_numa_init
	.cfi_startproc
; %bb.0:
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_ggml_is_numa                   ; -- Begin function ggml_is_numa
	.p2align	2
_ggml_is_numa:                          ; @ggml_is_numa
	.cfi_startproc
; %bb.0:
	mov	w0, #0                          ; =0x0
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_ggml_new_i32                   ; -- Begin function ggml_new_i32
	.p2align	2
_ggml_new_i32:                          ; @ggml_new_i32
	.cfi_startproc
; %bb.0:
	sub	sp, sp, #48
	stp	x20, x19, [sp, #16]             ; 16-byte Folded Spill
	stp	x29, x30, [sp, #32]             ; 16-byte Folded Spill
	add	x29, sp, #32
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	mov	x19, x1
	mov	x20, x0
	bl	_ggml_get_no_alloc
	cbnz	w0, LBB4_2
; %bb.1:
	mov	x0, x20
	mov	w1, #26                         ; =0x1a
	mov	w2, #1                          ; =0x1
	bl	_ggml_new_tensor_1d
	mov	x1, x19
	ldp	x29, x30, [sp, #32]             ; 16-byte Folded Reload
	ldp	x20, x19, [sp, #16]             ; 16-byte Folded Reload
	add	sp, sp, #48
	b	_ggml_set_i32
LBB4_2:
Lloh2:
	adrp	x8, l_.str.3@PAGE
Lloh3:
	add	x8, x8, l_.str.3@PAGEOFF
Lloh4:
	adrp	x0, l_.str.1@PAGE
Lloh5:
	add	x0, x0, l_.str.1@PAGEOFF
	str	x8, [sp]
Lloh6:
	adrp	x2, l_.str.2@PAGE
Lloh7:
	add	x2, x2, l_.str.2@PAGEOFF
	mov	w1, #756                        ; =0x2f4
	bl	_ggml_abort
	.loh AdrpAdd	Lloh6, Lloh7
	.loh AdrpAdd	Lloh4, Lloh5
	.loh AdrpAdd	Lloh2, Lloh3
	.cfi_endproc
                                        ; -- End function
	.globl	_ggml_set_i32                   ; -- Begin function ggml_set_i32
	.p2align	2
_ggml_set_i32:                          ; @ggml_set_i32
	.cfi_startproc
; %bb.0:
	stp	d9, d8, [sp, #-80]!             ; 16-byte Folded Spill
	stp	x24, x23, [sp, #16]             ; 16-byte Folded Spill
	stp	x22, x21, [sp, #32]             ; 16-byte Folded Spill
	stp	x20, x19, [sp, #48]             ; 16-byte Folded Spill
	stp	x29, x30, [sp, #64]             ; 16-byte Folded Spill
	add	x29, sp, #64
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	.cfi_offset w23, -56
	.cfi_offset w24, -64
	.cfi_offset b8, -72
	.cfi_offset b9, -80
	mov	x22, x1
	mov	x19, x0
	bl	_ggml_nrows
	ldr	x20, [x19, #16]
	ldr	x23, [x19, #56]
	ldr	x21, [x19, #248]
	ldr	w8, [x19]
	cmp	w8, #24
	b.gt	LBB5_9
; %bb.1:
	cbz	w8, LBB5_45
; %bb.2:
	cmp	w8, #1
	b.eq	LBB5_23
; %bb.3:
	cmp	w8, #24
	b.ne	LBB5_60
; %bb.4:
	cmp	w0, #1
	b.lt	LBB5_59
; %bb.5:
	and	x24, x0, #0x7fffffff
	b	LBB5_7
LBB5_6:                                 ;   in Loop: Header=BB5_7 Depth=1
	add	x21, x21, x23
	subs	x24, x24, #1
	b.eq	LBB5_59
LBB5_7:                                 ; =>This Inner Loop Header: Depth=1
	cmp	w20, #1
	b.lt	LBB5_6
; %bb.8:                                ;   in Loop: Header=BB5_7 Depth=1
	and	x2, x20, #0x7fffffff
	mov	x0, x21
	mov	x1, x22
	bl	_memset
	b	LBB5_6
LBB5_9:
	cmp	w8, #25
	b.eq	LBB5_48
; %bb.10:
	cmp	w8, #26
	b.eq	LBB5_34
; %bb.11:
	cmp	w8, #30
	b.ne	LBB5_60
; %bb.12:
	cmp	w0, #1
	b.lt	LBB5_59
; %bb.13:
	mov	x8, #0                          ; =0x0
	scvtf	s0, w22
	fmov	w9, s0
	and	w11, w9, #0x7fffffff
	lsr	w10, w9, #16
	ubfx	w12, w9, #16, #1
	mov	w13, #32767                     ; =0x7fff
	add	w9, w9, w12
	add	w9, w9, w13
	lsr	w12, w9, #16
	orr	w13, w10, #0x40
	and	x9, x20, #0x7fffffff
	and	x10, x0, #0x7fffffff
	mov	w14, #2139095040                ; =0x7f800000
	cmp	w11, w14
	csel	w11, w13, w12, hi
	and	x12, x20, #0x1f
	sub	x13, x9, x12
	dup.8h	v0, w11
	add	x14, x21, #32
	b	LBB5_15
LBB5_14:                                ;   in Loop: Header=BB5_15 Depth=1
	add	x8, x8, #1
	add	x14, x14, x23
	add	x21, x21, x23
	cmp	x8, x10
	b.eq	LBB5_59
LBB5_15:                                ; =>This Loop Header: Depth=1
                                        ;     Child Loop BB5_19 Depth 2
                                        ;     Child Loop BB5_22 Depth 2
	cmp	w20, #1
	b.lt	LBB5_14
; %bb.16:                               ;   in Loop: Header=BB5_15 Depth=1
	cmp	x9, #32
	b.hs	LBB5_18
; %bb.17:                               ;   in Loop: Header=BB5_15 Depth=1
	mov	x16, #0                         ; =0x0
	b	LBB5_21
LBB5_18:                                ;   in Loop: Header=BB5_15 Depth=1
	mov	x15, x13
	mov	x16, x14
LBB5_19:                                ;   Parent Loop BB5_15 Depth=1
                                        ; =>  This Inner Loop Header: Depth=2
	stp	q0, q0, [x16, #-32]
	stp	q0, q0, [x16], #64
	subs	x15, x15, #32
	b.ne	LBB5_19
; %bb.20:                               ;   in Loop: Header=BB5_15 Depth=1
	mov	x16, x13
	cbz	x12, LBB5_14
LBB5_21:                                ;   in Loop: Header=BB5_15 Depth=1
	sub	x15, x9, x16
	add	x16, x21, x16, lsl #1
LBB5_22:                                ;   Parent Loop BB5_15 Depth=1
                                        ; =>  This Inner Loop Header: Depth=2
	strh	w11, [x16], #2
	subs	x15, x15, #1
	b.ne	LBB5_22
	b	LBB5_14
LBB5_23:
	cmp	w0, #1
	b.lt	LBB5_59
; %bb.24:
	mov	x8, #0                          ; =0x0
	scvtf	s0, w22
	fcvt	h0, s0
	and	x9, x20, #0x7fffffff
	and	x10, x0, #0x7fffffff
	and	x11, x20, #0x1f
	sub	x12, x9, x11
	dup.8h	v1, v0[0]
	add	x13, x21, #32
	b	LBB5_26
LBB5_25:                                ;   in Loop: Header=BB5_26 Depth=1
	add	x8, x8, #1
	add	x13, x13, x23
	add	x21, x21, x23
	cmp	x8, x10
	b.eq	LBB5_59
LBB5_26:                                ; =>This Loop Header: Depth=1
                                        ;     Child Loop BB5_30 Depth 2
                                        ;     Child Loop BB5_33 Depth 2
	cmp	w20, #1
	b.lt	LBB5_25
; %bb.27:                               ;   in Loop: Header=BB5_26 Depth=1
	cmp	x9, #32
	b.hs	LBB5_29
; %bb.28:                               ;   in Loop: Header=BB5_26 Depth=1
	mov	x15, #0                         ; =0x0
	b	LBB5_32
LBB5_29:                                ;   in Loop: Header=BB5_26 Depth=1
	mov	x14, x12
	mov	x15, x13
LBB5_30:                                ;   Parent Loop BB5_26 Depth=1
                                        ; =>  This Inner Loop Header: Depth=2
	stp	q1, q1, [x15, #-32]
	stp	q1, q1, [x15], #64
	subs	x14, x14, #32
	b.ne	LBB5_30
; %bb.31:                               ;   in Loop: Header=BB5_26 Depth=1
	mov	x15, x12
	cbz	x11, LBB5_25
LBB5_32:                                ;   in Loop: Header=BB5_26 Depth=1
	sub	x14, x9, x15
	add	x15, x21, x15, lsl #1
LBB5_33:                                ;   Parent Loop BB5_26 Depth=1
                                        ; =>  This Inner Loop Header: Depth=2
	str	h0, [x15], #2
	subs	x14, x14, #1
	b.ne	LBB5_33
	b	LBB5_25
LBB5_34:
	cmp	w0, #1
	b.lt	LBB5_59
; %bb.35:
	mov	x8, #0                          ; =0x0
	and	x9, x20, #0x7fffffff
	and	x10, x0, #0x7fffffff
	and	x11, x20, #0xf
	sub	x12, x9, x11
	dup.4s	v0, w22
	add	x13, x21, #32
	b	LBB5_37
LBB5_36:                                ;   in Loop: Header=BB5_37 Depth=1
	add	x8, x8, #1
	add	x13, x13, x23
	add	x21, x21, x23
	cmp	x8, x10
	b.eq	LBB5_59
LBB5_37:                                ; =>This Loop Header: Depth=1
                                        ;     Child Loop BB5_41 Depth 2
                                        ;     Child Loop BB5_44 Depth 2
	cmp	w20, #1
	b.lt	LBB5_36
; %bb.38:                               ;   in Loop: Header=BB5_37 Depth=1
	cmp	x9, #16
	b.hs	LBB5_40
; %bb.39:                               ;   in Loop: Header=BB5_37 Depth=1
	mov	x15, #0                         ; =0x0
	b	LBB5_43
LBB5_40:                                ;   in Loop: Header=BB5_37 Depth=1
	mov	x14, x12
	mov	x15, x13
LBB5_41:                                ;   Parent Loop BB5_37 Depth=1
                                        ; =>  This Inner Loop Header: Depth=2
	stp	q0, q0, [x15, #-32]
	stp	q0, q0, [x15], #64
	subs	x14, x14, #16
	b.ne	LBB5_41
; %bb.42:                               ;   in Loop: Header=BB5_37 Depth=1
	mov	x15, x12
	cbz	x11, LBB5_36
LBB5_43:                                ;   in Loop: Header=BB5_37 Depth=1
	sub	x14, x9, x15
	add	x15, x21, x15, lsl #2
LBB5_44:                                ;   Parent Loop BB5_37 Depth=1
                                        ; =>  This Inner Loop Header: Depth=2
	str	w22, [x15], #4
	subs	x14, x14, #1
	b.ne	LBB5_44
	b	LBB5_36
LBB5_45:
	cmp	w0, #1
	b.lt	LBB5_59
; %bb.46:
	scvtf	s8, w22
	and	x22, x0, #0x7fffffff
LBB5_47:                                ; =>This Inner Loop Header: Depth=1
	mov	x0, x20
	mov	x1, x21
	fmov	s0, s8
	bl	_ggml_vec_set_f32
	add	x21, x21, x23
	subs	x22, x22, #1
	b.ne	LBB5_47
	b	LBB5_59
LBB5_48:
	cmp	w0, #1
	b.lt	LBB5_59
; %bb.49:
	mov	x8, #0                          ; =0x0
	and	x9, x20, #0x7fffffff
	and	x10, x0, #0x7fffffff
	and	x11, x20, #0x1f
	sub	x12, x9, x11
	dup.8h	v0, w22
	add	x13, x21, #32
	b	LBB5_51
LBB5_50:                                ;   in Loop: Header=BB5_51 Depth=1
	add	x8, x8, #1
	add	x13, x13, x23
	add	x21, x21, x23
	cmp	x8, x10
	b.eq	LBB5_59
LBB5_51:                                ; =>This Loop Header: Depth=1
                                        ;     Child Loop BB5_55 Depth 2
                                        ;     Child Loop BB5_58 Depth 2
	cmp	w20, #1
	b.lt	LBB5_50
; %bb.52:                               ;   in Loop: Header=BB5_51 Depth=1
	cmp	x9, #32
	b.hs	LBB5_54
; %bb.53:                               ;   in Loop: Header=BB5_51 Depth=1
	mov	x15, #0                         ; =0x0
	b	LBB5_57
LBB5_54:                                ;   in Loop: Header=BB5_51 Depth=1
	mov	x14, x12
	mov	x15, x13
LBB5_55:                                ;   Parent Loop BB5_51 Depth=1
                                        ; =>  This Inner Loop Header: Depth=2
	stp	q0, q0, [x15, #-32]
	stp	q0, q0, [x15], #64
	subs	x14, x14, #32
	b.ne	LBB5_55
; %bb.56:                               ;   in Loop: Header=BB5_51 Depth=1
	mov	x15, x12
	cbz	x11, LBB5_50
LBB5_57:                                ;   in Loop: Header=BB5_51 Depth=1
	sub	x14, x9, x15
	add	x15, x21, x15, lsl #1
LBB5_58:                                ;   Parent Loop BB5_51 Depth=1
                                        ; =>  This Inner Loop Header: Depth=2
	strh	w22, [x15], #2
	subs	x14, x14, #1
	b.ne	LBB5_58
	b	LBB5_50
LBB5_59:
	mov	x0, x19
	ldp	x29, x30, [sp, #64]             ; 16-byte Folded Reload
	ldp	x20, x19, [sp, #48]             ; 16-byte Folded Reload
	ldp	x22, x21, [sp, #32]             ; 16-byte Folded Reload
	ldp	x24, x23, [sp, #16]             ; 16-byte Folded Reload
	ldp	d9, d8, [sp], #80               ; 16-byte Folded Reload
	ret
LBB5_60:
Lloh8:
	adrp	x0, l_.str.1@PAGE
Lloh9:
	add	x0, x0, l_.str.1@PAGEOFF
Lloh10:
	adrp	x2, l_.str.4@PAGE
Lloh11:
	add	x2, x2, l_.str.4@PAGEOFF
	mov	w1, #827                        ; =0x33b
	bl	_ggml_abort
	.loh AdrpAdd	Lloh10, Lloh11
	.loh AdrpAdd	Lloh8, Lloh9
	.cfi_endproc
                                        ; -- End function
	.globl	_ggml_new_f32                   ; -- Begin function ggml_new_f32
	.p2align	2
_ggml_new_f32:                          ; @ggml_new_f32
	.cfi_startproc
; %bb.0:
	sub	sp, sp, #64
	stp	d9, d8, [sp, #16]               ; 16-byte Folded Spill
	stp	x20, x19, [sp, #32]             ; 16-byte Folded Spill
	stp	x29, x30, [sp, #48]             ; 16-byte Folded Spill
	add	x29, sp, #48
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset b8, -40
	.cfi_offset b9, -48
	fmov	s8, s0
	mov	x19, x0
	bl	_ggml_get_no_alloc
	cbnz	w0, LBB6_2
; %bb.1:
	mov	x0, x19
	mov	w1, #0                          ; =0x0
	mov	w2, #1                          ; =0x1
	bl	_ggml_new_tensor_1d
	fmov	s0, s8
	ldp	x29, x30, [sp, #48]             ; 16-byte Folded Reload
	ldp	x20, x19, [sp, #32]             ; 16-byte Folded Reload
	ldp	d9, d8, [sp, #16]               ; 16-byte Folded Reload
	add	sp, sp, #64
	b	_ggml_set_f32
LBB6_2:
Lloh12:
	adrp	x8, l_.str.3@PAGE
Lloh13:
	add	x8, x8, l_.str.3@PAGEOFF
Lloh14:
	adrp	x0, l_.str.1@PAGE
Lloh15:
	add	x0, x0, l_.str.1@PAGEOFF
	str	x8, [sp]
Lloh16:
	adrp	x2, l_.str.2@PAGE
Lloh17:
	add	x2, x2, l_.str.2@PAGEOFF
	mov	w1, #766                        ; =0x2fe
	bl	_ggml_abort
	.loh AdrpAdd	Lloh16, Lloh17
	.loh AdrpAdd	Lloh14, Lloh15
	.loh AdrpAdd	Lloh12, Lloh13
	.cfi_endproc
                                        ; -- End function
	.globl	_ggml_set_f32                   ; -- Begin function ggml_set_f32
	.p2align	2
_ggml_set_f32:                          ; @ggml_set_f32
	.cfi_startproc
; %bb.0:
	stp	d9, d8, [sp, #-80]!             ; 16-byte Folded Spill
	stp	x24, x23, [sp, #16]             ; 16-byte Folded Spill
	stp	x22, x21, [sp, #32]             ; 16-byte Folded Spill
	stp	x20, x19, [sp, #48]             ; 16-byte Folded Spill
	stp	x29, x30, [sp, #64]             ; 16-byte Folded Spill
	add	x29, sp, #64
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	.cfi_offset w23, -56
	.cfi_offset w24, -64
	.cfi_offset b8, -72
	.cfi_offset b9, -80
	fmov	s8, s0
	mov	x19, x0
	bl	_ggml_nrows
	ldr	x20, [x19, #16]
	ldr	x23, [x19, #56]
	ldr	x21, [x19, #248]
	ldr	w8, [x19]
	cmp	w8, #24
	b.gt	LBB7_9
; %bb.1:
	cbz	w8, LBB7_45
; %bb.2:
	cmp	w8, #1
	b.eq	LBB7_23
; %bb.3:
	cmp	w8, #24
	b.ne	LBB7_60
; %bb.4:
	cmp	w0, #1
	b.lt	LBB7_59
; %bb.5:
	fcvtzs	w22, s8
	and	x24, x0, #0x7fffffff
	b	LBB7_7
LBB7_6:                                 ;   in Loop: Header=BB7_7 Depth=1
	add	x21, x21, x23
	subs	x24, x24, #1
	b.eq	LBB7_59
LBB7_7:                                 ; =>This Inner Loop Header: Depth=1
	cmp	w20, #1
	b.lt	LBB7_6
; %bb.8:                                ;   in Loop: Header=BB7_7 Depth=1
	and	x2, x20, #0x7fffffff
	mov	x0, x21
	mov	x1, x22
	bl	_memset
	b	LBB7_6
LBB7_9:
	cmp	w8, #25
	b.eq	LBB7_48
; %bb.10:
	cmp	w8, #26
	b.eq	LBB7_34
; %bb.11:
	cmp	w8, #30
	b.ne	LBB7_60
; %bb.12:
	cmp	w0, #1
	b.lt	LBB7_59
; %bb.13:
	mov	x8, #0                          ; =0x0
	fmov	w9, s8
	and	w11, w9, #0x7fffffff
	lsr	w10, w9, #16
	ubfx	w12, w9, #16, #1
	mov	w13, #32767                     ; =0x7fff
	add	w9, w9, w12
	add	w9, w9, w13
	lsr	w12, w9, #16
	orr	w13, w10, #0x40
	and	x9, x20, #0x7fffffff
	and	x10, x0, #0x7fffffff
	mov	w14, #2139095040                ; =0x7f800000
	cmp	w11, w14
	csel	w11, w13, w12, hi
	and	x12, x20, #0x1f
	sub	x13, x9, x12
	dup.8h	v0, w11
	add	x14, x21, #32
	b	LBB7_15
LBB7_14:                                ;   in Loop: Header=BB7_15 Depth=1
	add	x8, x8, #1
	add	x14, x14, x23
	add	x21, x21, x23
	cmp	x8, x10
	b.eq	LBB7_59
LBB7_15:                                ; =>This Loop Header: Depth=1
                                        ;     Child Loop BB7_19 Depth 2
                                        ;     Child Loop BB7_22 Depth 2
	cmp	w20, #1
	b.lt	LBB7_14
; %bb.16:                               ;   in Loop: Header=BB7_15 Depth=1
	cmp	x9, #32
	b.hs	LBB7_18
; %bb.17:                               ;   in Loop: Header=BB7_15 Depth=1
	mov	x16, #0                         ; =0x0
	b	LBB7_21
LBB7_18:                                ;   in Loop: Header=BB7_15 Depth=1
	mov	x15, x13
	mov	x16, x14
LBB7_19:                                ;   Parent Loop BB7_15 Depth=1
                                        ; =>  This Inner Loop Header: Depth=2
	stp	q0, q0, [x16, #-32]
	stp	q0, q0, [x16], #64
	subs	x15, x15, #32
	b.ne	LBB7_19
; %bb.20:                               ;   in Loop: Header=BB7_15 Depth=1
	mov	x16, x13
	cbz	x12, LBB7_14
LBB7_21:                                ;   in Loop: Header=BB7_15 Depth=1
	sub	x15, x9, x16
	add	x16, x21, x16, lsl #1
LBB7_22:                                ;   Parent Loop BB7_15 Depth=1
                                        ; =>  This Inner Loop Header: Depth=2
	strh	w11, [x16], #2
	subs	x15, x15, #1
	b.ne	LBB7_22
	b	LBB7_14
LBB7_23:
	cmp	w0, #1
	b.lt	LBB7_59
; %bb.24:
	mov	x8, #0                          ; =0x0
	fcvt	h0, s8
	and	x9, x20, #0x7fffffff
	and	x10, x0, #0x7fffffff
	and	x11, x20, #0x1f
	sub	x12, x9, x11
	dup.8h	v1, v0[0]
	add	x13, x21, #32
	b	LBB7_26
LBB7_25:                                ;   in Loop: Header=BB7_26 Depth=1
	add	x8, x8, #1
	add	x13, x13, x23
	add	x21, x21, x23
	cmp	x8, x10
	b.eq	LBB7_59
LBB7_26:                                ; =>This Loop Header: Depth=1
                                        ;     Child Loop BB7_30 Depth 2
                                        ;     Child Loop BB7_33 Depth 2
	cmp	w20, #1
	b.lt	LBB7_25
; %bb.27:                               ;   in Loop: Header=BB7_26 Depth=1
	cmp	x9, #32
	b.hs	LBB7_29
; %bb.28:                               ;   in Loop: Header=BB7_26 Depth=1
	mov	x15, #0                         ; =0x0
	b	LBB7_32
LBB7_29:                                ;   in Loop: Header=BB7_26 Depth=1
	mov	x14, x12
	mov	x15, x13
LBB7_30:                                ;   Parent Loop BB7_26 Depth=1
                                        ; =>  This Inner Loop Header: Depth=2
	stp	q1, q1, [x15, #-32]
	stp	q1, q1, [x15], #64
	subs	x14, x14, #32
	b.ne	LBB7_30
; %bb.31:                               ;   in Loop: Header=BB7_26 Depth=1
	mov	x15, x12
	cbz	x11, LBB7_25
LBB7_32:                                ;   in Loop: Header=BB7_26 Depth=1
	sub	x14, x9, x15
	add	x15, x21, x15, lsl #1
LBB7_33:                                ;   Parent Loop BB7_26 Depth=1
                                        ; =>  This Inner Loop Header: Depth=2
	str	h0, [x15], #2
	subs	x14, x14, #1
	b.ne	LBB7_33
	b	LBB7_25
LBB7_34:
	cmp	w0, #1
	b.lt	LBB7_59
; %bb.35:
	mov	x8, #0                          ; =0x0
	fcvtzs	w9, s8
	and	x10, x20, #0x7fffffff
	and	x11, x0, #0x7fffffff
	and	x12, x20, #0xf
	sub	x13, x10, x12
	dup.4s	v0, w9
	add	x14, x21, #32
	b	LBB7_37
LBB7_36:                                ;   in Loop: Header=BB7_37 Depth=1
	add	x8, x8, #1
	add	x14, x14, x23
	add	x21, x21, x23
	cmp	x8, x11
	b.eq	LBB7_59
LBB7_37:                                ; =>This Loop Header: Depth=1
                                        ;     Child Loop BB7_41 Depth 2
                                        ;     Child Loop BB7_44 Depth 2
	cmp	w20, #1
	b.lt	LBB7_36
; %bb.38:                               ;   in Loop: Header=BB7_37 Depth=1
	cmp	x10, #16
	b.hs	LBB7_40
; %bb.39:                               ;   in Loop: Header=BB7_37 Depth=1
	mov	x16, #0                         ; =0x0
	b	LBB7_43
LBB7_40:                                ;   in Loop: Header=BB7_37 Depth=1
	mov	x15, x13
	mov	x16, x14
LBB7_41:                                ;   Parent Loop BB7_37 Depth=1
                                        ; =>  This Inner Loop Header: Depth=2
	stp	q0, q0, [x16, #-32]
	stp	q0, q0, [x16], #64
	subs	x15, x15, #16
	b.ne	LBB7_41
; %bb.42:                               ;   in Loop: Header=BB7_37 Depth=1
	mov	x16, x13
	cbz	x12, LBB7_36
LBB7_43:                                ;   in Loop: Header=BB7_37 Depth=1
	sub	x15, x10, x16
	add	x16, x21, x16, lsl #2
LBB7_44:                                ;   Parent Loop BB7_37 Depth=1
                                        ; =>  This Inner Loop Header: Depth=2
	str	w9, [x16], #4
	subs	x15, x15, #1
	b.ne	LBB7_44
	b	LBB7_36
LBB7_45:
	cmp	w0, #1
	b.lt	LBB7_59
; %bb.46:
	and	x22, x0, #0x7fffffff
LBB7_47:                                ; =>This Inner Loop Header: Depth=1
	mov	x0, x20
	mov	x1, x21
	fmov	s0, s8
	bl	_ggml_vec_set_f32
	add	x21, x21, x23
	subs	x22, x22, #1
	b.ne	LBB7_47
	b	LBB7_59
LBB7_48:
	cmp	w0, #1
	b.lt	LBB7_59
; %bb.49:
	mov	x8, #0                          ; =0x0
	fcvtzs	w9, s8
	and	x10, x20, #0x7fffffff
	and	x11, x0, #0x7fffffff
	and	x12, x20, #0x1f
	sub	x13, x10, x12
	dup.8h	v0, w9
	add	x14, x21, #32
	b	LBB7_51
LBB7_50:                                ;   in Loop: Header=BB7_51 Depth=1
	add	x8, x8, #1
	add	x14, x14, x23
	add	x21, x21, x23
	cmp	x8, x11
	b.eq	LBB7_59
LBB7_51:                                ; =>This Loop Header: Depth=1
                                        ;     Child Loop BB7_55 Depth 2
                                        ;     Child Loop BB7_58 Depth 2
	cmp	w20, #1
	b.lt	LBB7_50
; %bb.52:                               ;   in Loop: Header=BB7_51 Depth=1
	cmp	x10, #32
	b.hs	LBB7_54
; %bb.53:                               ;   in Loop: Header=BB7_51 Depth=1
	mov	x16, #0                         ; =0x0
	b	LBB7_57
LBB7_54:                                ;   in Loop: Header=BB7_51 Depth=1
	mov	x15, x13
	mov	x16, x14
LBB7_55:                                ;   Parent Loop BB7_51 Depth=1
                                        ; =>  This Inner Loop Header: Depth=2
	stp	q0, q0, [x16, #-32]
	stp	q0, q0, [x16], #64
	subs	x15, x15, #32
	b.ne	LBB7_55
; %bb.56:                               ;   in Loop: Header=BB7_51 Depth=1
	mov	x16, x13
	cbz	x12, LBB7_50
LBB7_57:                                ;   in Loop: Header=BB7_51 Depth=1
	sub	x15, x10, x16
	add	x16, x21, x16, lsl #1
LBB7_58:                                ;   Parent Loop BB7_51 Depth=1
                                        ; =>  This Inner Loop Header: Depth=2
	strh	w9, [x16], #2
	subs	x15, x15, #1
	b.ne	LBB7_58
	b	LBB7_50
LBB7_59:
	mov	x0, x19
	ldp	x29, x30, [sp, #64]             ; 16-byte Folded Reload
	ldp	x20, x19, [sp, #48]             ; 16-byte Folded Reload
	ldp	x22, x21, [sp, #32]             ; 16-byte Folded Reload
	ldp	x24, x23, [sp, #16]             ; 16-byte Folded Reload
	ldp	d9, d8, [sp], #80               ; 16-byte Folded Reload
	ret
LBB7_60:
Lloh18:
	adrp	x0, l_.str.1@PAGE
Lloh19:
	add	x0, x0, l_.str.1@PAGEOFF
Lloh20:
	adrp	x2, l_.str.4@PAGE
Lloh21:
	add	x2, x2, l_.str.4@PAGEOFF
	mov	w1, #886                        ; =0x376
	bl	_ggml_abort
	.loh AdrpAdd	Lloh20, Lloh21
	.loh AdrpAdd	Lloh18, Lloh19
	.cfi_endproc
                                        ; -- End function
	.globl	_ggml_get_i32_1d                ; -- Begin function ggml_get_i32_1d
	.p2align	2
_ggml_get_i32_1d:                       ; @ggml_get_i32_1d
	.cfi_startproc
; %bb.0:
	sub	sp, sp, #96
	stp	x20, x19, [sp, #64]             ; 16-byte Folded Spill
	stp	x29, x30, [sp, #80]             ; 16-byte Folded Spill
	add	x29, sp, #80
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	mov	x20, x1
	mov	x19, x0
Lloh22:
	adrp	x8, ___stack_chk_guard@GOTPAGE
Lloh23:
	ldr	x8, [x8, ___stack_chk_guard@GOTPAGEOFF]
Lloh24:
	ldr	x8, [x8]
	stur	x8, [x29, #-24]
	bl	_ggml_is_contiguous
	tbz	w0, #0, LBB8_7
; %bb.1:
	ldr	w8, [x19]
	cmp	w8, #24
	b.gt	LBB8_12
; %bb.2:
	cbz	w8, LBB8_28
; %bb.3:
	cmp	w8, #1
	b.eq	LBB8_22
; %bb.4:
	cmp	w8, #24
	b.ne	LBB8_43
; %bb.5:
	ldr	x8, [x19, #48]
	cmp	x8, #1
	b.ne	LBB8_37
; %bb.6:
	ldr	x8, [x19, #248]
	ldrsb	w0, [x8, w20, sxtw]
	b	LBB8_34
LBB8_7:
	movi.2d	v0, #0000000000000000
	stp	q0, q0, [sp, #16]
	add	x8, sp, #16
	sxtw	x1, w20
	add	x2, sp, #16
	orr	x3, x8, #0x8
	add	x4, x8, #16
	add	x5, x8, #24
	mov	x0, x19
	bl	_ggml_unravel_index
	ldrsw	x8, [sp, #16]
	ldrsw	x9, [sp, #24]
	ldr	x10, [x19, #248]
	ldp	x11, x12, [x19, #48]
	madd	x8, x11, x8, x10
	ldrsw	x10, [sp, #32]
	ldrsw	x11, [sp, #40]
	madd	x8, x12, x9, x8
	ldp	x9, x12, [x19, #64]
	madd	x8, x9, x10, x8
	mul	x9, x12, x11
	ldr	w10, [x19]
	cmp	w10, #24
	b.gt	LBB8_17
; %bb.8:
	cbz	w10, LBB8_30
; %bb.9:
	cmp	w10, #1
	b.eq	LBB8_24
; %bb.10:
	cmp	w10, #24
	b.ne	LBB8_44
; %bb.11:
	ldrsb	w0, [x8, x9]
	b	LBB8_34
LBB8_12:
	cmp	w8, #25
	b.eq	LBB8_31
; %bb.13:
	cmp	w8, #26
	b.eq	LBB8_25
; %bb.14:
	cmp	w8, #30
	b.ne	LBB8_43
; %bb.15:
	ldr	x8, [x19, #48]
	cmp	x8, #2
	b.ne	LBB8_38
; %bb.16:
	ldr	x8, [x19, #248]
	ldrh	w8, [x8, w20, sxtw #1]
	b	LBB8_21
LBB8_17:
	cmp	w10, #25
	b.eq	LBB8_33
; %bb.18:
	cmp	w10, #26
	b.eq	LBB8_27
; %bb.19:
	cmp	w10, #30
	b.ne	LBB8_44
; %bb.20:
	ldrh	w8, [x8, x9]
LBB8_21:
	lsl	w8, w8, #16
	fmov	s0, w8
	fcvtzs	w0, s0
	b	LBB8_34
LBB8_22:
	ldr	x8, [x19, #48]
	cmp	x8, #2
	b.ne	LBB8_39
; %bb.23:
	ldr	x8, [x19, #248]
	ldr	h0, [x8, w20, sxtw #1]
	fcvtzs	w0, h0
	b	LBB8_34
LBB8_24:
	ldr	h0, [x8, x9]
	fcvtzs	w0, h0
	b	LBB8_34
LBB8_25:
	ldr	x8, [x19, #48]
	cmp	x8, #4
	b.ne	LBB8_40
; %bb.26:
	ldr	x8, [x19, #248]
	ldr	w0, [x8, w20, sxtw #2]
	b	LBB8_34
LBB8_27:
	ldr	w0, [x8, x9]
	b	LBB8_34
LBB8_28:
	ldr	x8, [x19, #48]
	cmp	x8, #4
	b.ne	LBB8_41
; %bb.29:
	ldr	x8, [x19, #248]
	ldr	s0, [x8, w20, sxtw #2]
	fcvtzs	w0, s0
	b	LBB8_34
LBB8_30:
	ldr	s0, [x8, x9]
	fcvtzs	w0, s0
	b	LBB8_34
LBB8_31:
	ldr	x8, [x19, #48]
	cmp	x8, #2
	b.ne	LBB8_42
; %bb.32:
	ldr	x8, [x19, #248]
	ldrsh	w0, [x8, w20, sxtw #1]
	b	LBB8_34
LBB8_33:
	ldrsh	w0, [x8, x9]
LBB8_34:
	ldur	x8, [x29, #-24]
Lloh25:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh26:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh27:
	ldr	x9, [x9]
	cmp	x9, x8
	b.ne	LBB8_36
; %bb.35:
	ldp	x29, x30, [sp, #80]             ; 16-byte Folded Reload
	ldp	x20, x19, [sp, #64]             ; 16-byte Folded Reload
	add	sp, sp, #96
	ret
LBB8_36:
	bl	___stack_chk_fail
LBB8_37:
Lloh28:
	adrp	x8, l_.str.5@PAGE
Lloh29:
	add	x8, x8, l_.str.5@PAGEOFF
Lloh30:
	adrp	x0, l_.str.1@PAGE
Lloh31:
	add	x0, x0, l_.str.1@PAGEOFF
	str	x8, [sp]
Lloh32:
	adrp	x2, l_.str.2@PAGE
Lloh33:
	add	x2, x2, l_.str.2@PAGEOFF
	mov	w1, #902                        ; =0x386
	bl	_ggml_abort
LBB8_38:
Lloh34:
	adrp	x8, l_.str.9@PAGE
Lloh35:
	add	x8, x8, l_.str.9@PAGEOFF
Lloh36:
	adrp	x0, l_.str.1@PAGE
Lloh37:
	add	x0, x0, l_.str.1@PAGEOFF
	str	x8, [sp]
Lloh38:
	adrp	x2, l_.str.2@PAGE
Lloh39:
	add	x2, x2, l_.str.2@PAGEOFF
	mov	w1, #922                        ; =0x39a
	bl	_ggml_abort
LBB8_39:
Lloh40:
	adrp	x8, l_.str.8@PAGE
Lloh41:
	add	x8, x8, l_.str.8@PAGEOFF
Lloh42:
	adrp	x0, l_.str.1@PAGE
Lloh43:
	add	x0, x0, l_.str.1@PAGEOFF
	str	x8, [sp]
Lloh44:
	adrp	x2, l_.str.2@PAGE
Lloh45:
	add	x2, x2, l_.str.2@PAGEOFF
	mov	w1, #917                        ; =0x395
	bl	_ggml_abort
LBB8_40:
Lloh46:
	adrp	x8, l_.str.7@PAGE
Lloh47:
	add	x8, x8, l_.str.7@PAGEOFF
Lloh48:
	adrp	x0, l_.str.1@PAGE
Lloh49:
	add	x0, x0, l_.str.1@PAGEOFF
	str	x8, [sp]
Lloh50:
	adrp	x2, l_.str.2@PAGE
Lloh51:
	add	x2, x2, l_.str.2@PAGEOFF
	mov	w1, #912                        ; =0x390
	bl	_ggml_abort
LBB8_41:
Lloh52:
	adrp	x8, l_.str.10@PAGE
Lloh53:
	add	x8, x8, l_.str.10@PAGEOFF
Lloh54:
	adrp	x0, l_.str.1@PAGE
Lloh55:
	add	x0, x0, l_.str.1@PAGEOFF
	str	x8, [sp]
Lloh56:
	adrp	x2, l_.str.2@PAGE
Lloh57:
	add	x2, x2, l_.str.2@PAGEOFF
	mov	w1, #927                        ; =0x39f
	bl	_ggml_abort
LBB8_42:
Lloh58:
	adrp	x8, l_.str.6@PAGE
Lloh59:
	add	x8, x8, l_.str.6@PAGEOFF
Lloh60:
	adrp	x0, l_.str.1@PAGE
Lloh61:
	add	x0, x0, l_.str.1@PAGEOFF
	str	x8, [sp]
Lloh62:
	adrp	x2, l_.str.2@PAGE
Lloh63:
	add	x2, x2, l_.str.2@PAGEOFF
	mov	w1, #907                        ; =0x38b
	bl	_ggml_abort
LBB8_43:
Lloh64:
	adrp	x0, l_.str.1@PAGE
Lloh65:
	add	x0, x0, l_.str.1@PAGEOFF
Lloh66:
	adrp	x2, l_.str.4@PAGE
Lloh67:
	add	x2, x2, l_.str.4@PAGEOFF
	mov	w1, #932                        ; =0x3a4
	bl	_ggml_abort
LBB8_44:
Lloh68:
	adrp	x0, l_.str.1@PAGE
Lloh69:
	add	x0, x0, l_.str.1@PAGEOFF
Lloh70:
	adrp	x2, l_.str.4@PAGE
Lloh71:
	add	x2, x2, l_.str.4@PAGEOFF
	mov	w1, #998                        ; =0x3e6
	bl	_ggml_abort
	.loh AdrpLdrGotLdr	Lloh22, Lloh23, Lloh24
	.loh AdrpLdrGotLdr	Lloh25, Lloh26, Lloh27
	.loh AdrpAdd	Lloh32, Lloh33
	.loh AdrpAdd	Lloh30, Lloh31
	.loh AdrpAdd	Lloh28, Lloh29
	.loh AdrpAdd	Lloh38, Lloh39
	.loh AdrpAdd	Lloh36, Lloh37
	.loh AdrpAdd	Lloh34, Lloh35
	.loh AdrpAdd	Lloh44, Lloh45
	.loh AdrpAdd	Lloh42, Lloh43
	.loh AdrpAdd	Lloh40, Lloh41
	.loh AdrpAdd	Lloh50, Lloh51
	.loh AdrpAdd	Lloh48, Lloh49
	.loh AdrpAdd	Lloh46, Lloh47
	.loh AdrpAdd	Lloh56, Lloh57
	.loh AdrpAdd	Lloh54, Lloh55
	.loh AdrpAdd	Lloh52, Lloh53
	.loh AdrpAdd	Lloh62, Lloh63
	.loh AdrpAdd	Lloh60, Lloh61
	.loh AdrpAdd	Lloh58, Lloh59
	.loh AdrpAdd	Lloh66, Lloh67
	.loh AdrpAdd	Lloh64, Lloh65
	.loh AdrpAdd	Lloh70, Lloh71
	.loh AdrpAdd	Lloh68, Lloh69
	.cfi_endproc
                                        ; -- End function
	.globl	_ggml_get_i32_nd                ; -- Begin function ggml_get_i32_nd
	.p2align	2
_ggml_get_i32_nd:                       ; @ggml_get_i32_nd
	.cfi_startproc
; %bb.0:
                                        ; kill: def $w4 killed $w4 def $x4
                                        ; kill: def $w3 killed $w3 def $x3
                                        ; kill: def $w2 killed $w2 def $x2
                                        ; kill: def $w1 killed $w1 def $x1
	ldr	x8, [x0, #248]
	sxtw	x9, w1
	ldp	x10, x11, [x0, #48]
	madd	x8, x10, x9, x8
	sxtw	x9, w2
	madd	x8, x11, x9, x8
	sxtw	x9, w3
	ldp	x10, x11, [x0, #64]
	madd	x8, x10, x9, x8
	sxtw	x9, w4
	mul	x9, x11, x9
	ldr	w10, [x0]
	cmp	w10, #24
	b.gt	LBB9_5
; %bb.1:
	cbz	w10, LBB9_11
; %bb.2:
	cmp	w10, #1
	b.eq	LBB9_9
; %bb.3:
	cmp	w10, #24
	b.ne	LBB9_13
; %bb.4:
	ldrsb	w0, [x8, x9]
	ret
LBB9_5:
	cmp	w10, #25
	b.eq	LBB9_12
; %bb.6:
	cmp	w10, #26
	b.eq	LBB9_10
; %bb.7:
	cmp	w10, #30
	b.ne	LBB9_13
; %bb.8:
	ldrh	w8, [x8, x9]
	lsl	w8, w8, #16
	fmov	s0, w8
	fcvtzs	w0, s0
	ret
LBB9_9:
	ldr	h0, [x8, x9]
	fcvtzs	w0, h0
	ret
LBB9_10:
	ldr	w0, [x8, x9]
	ret
LBB9_11:
	ldr	s0, [x8, x9]
	fcvtzs	w0, s0
	ret
LBB9_12:
	ldrsh	w0, [x8, x9]
	ret
LBB9_13:
	stp	x29, x30, [sp, #-16]!           ; 16-byte Folded Spill
	mov	x29, sp
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
Lloh72:
	adrp	x0, l_.str.1@PAGE
Lloh73:
	add	x0, x0, l_.str.1@PAGEOFF
Lloh74:
	adrp	x2, l_.str.4@PAGE
Lloh75:
	add	x2, x2, l_.str.4@PAGEOFF
	mov	w1, #998                        ; =0x3e6
	bl	_ggml_abort
	.loh AdrpAdd	Lloh74, Lloh75
	.loh AdrpAdd	Lloh72, Lloh73
	.cfi_endproc
                                        ; -- End function
	.globl	_ggml_set_i32_1d                ; -- Begin function ggml_set_i32_1d
	.p2align	2
_ggml_set_i32_1d:                       ; @ggml_set_i32_1d
	.cfi_startproc
; %bb.0:
	sub	sp, sp, #112
	stp	x22, x21, [sp, #64]             ; 16-byte Folded Spill
	stp	x20, x19, [sp, #80]             ; 16-byte Folded Spill
	stp	x29, x30, [sp, #96]             ; 16-byte Folded Spill
	add	x29, sp, #96
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	mov	x20, x2
	mov	x19, x1
	mov	x21, x0
Lloh76:
	adrp	x8, ___stack_chk_guard@GOTPAGE
Lloh77:
	ldr	x8, [x8, ___stack_chk_guard@GOTPAGEOFF]
Lloh78:
	ldr	x8, [x8]
	stur	x8, [x29, #-40]
	bl	_ggml_is_contiguous
	tbz	w0, #0, LBB10_7
; %bb.1:
	ldr	w8, [x21]
	cmp	w8, #24
	b.gt	LBB10_10
; %bb.2:
	cbz	w8, LBB10_20
; %bb.3:
	cmp	w8, #1
	b.eq	LBB10_16
; %bb.4:
	cmp	w8, #24
	b.ne	LBB10_32
; %bb.5:
	ldr	x8, [x21, #48]
	cmp	x8, #1
	b.ne	LBB10_26
; %bb.6:
	ldr	x8, [x21, #248]
	strb	w20, [x8, w19, sxtw]
	b	LBB10_8
LBB10_7:
	movi.2d	v0, #0000000000000000
	stp	q0, q0, [sp, #16]
	add	x8, sp, #16
                                        ; kill: def $w19 killed $w19 killed $x19 def $x19
	sxtw	x1, w19
	add	x2, sp, #16
	orr	x3, x8, #0x8
	add	x4, x8, #16
	add	x5, x8, #24
	mov	x0, x21
	bl	_ggml_unravel_index
	ldr	w1, [sp, #16]
	ldr	w2, [sp, #24]
	ldr	w3, [sp, #32]
	ldr	w4, [sp, #40]
	mov	x0, x21
	mov	x5, x20
	bl	_ggml_set_i32_nd
LBB10_8:
	ldur	x8, [x29, #-40]
Lloh79:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh80:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh81:
	ldr	x9, [x9]
	cmp	x9, x8
	b.ne	LBB10_25
; %bb.9:
	ldp	x29, x30, [sp, #96]             ; 16-byte Folded Reload
	ldp	x20, x19, [sp, #80]             ; 16-byte Folded Reload
	ldp	x22, x21, [sp, #64]             ; 16-byte Folded Reload
	add	sp, sp, #112
	ret
LBB10_10:
	cmp	w8, #25
	b.eq	LBB10_22
; %bb.11:
	cmp	w8, #26
	b.eq	LBB10_18
; %bb.12:
	cmp	w8, #30
	b.ne	LBB10_32
; %bb.13:
	ldr	x8, [x21, #48]
	cmp	x8, #2
	b.ne	LBB10_27
; %bb.14:
	ldr	x8, [x21, #248]
	scvtf	s0, w20
	fmov	w9, s0
	and	w10, w9, #0x7fffffff
	mov	w11, #1                         ; =0x1
	movk	w11, #32640, lsl #16
	cmp	w10, w11
	b.lo	LBB10_24
; %bb.15:
	lsr	w9, w9, #16
	orr	w9, w9, #0x40
	strh	w9, [x8, w19, sxtw #1]
	b	LBB10_8
LBB10_16:
	ldr	x8, [x21, #48]
	cmp	x8, #2
	b.ne	LBB10_28
; %bb.17:
	scvtf	s0, w20
	fcvt	h0, s0
	ldr	x8, [x21, #248]
	str	h0, [x8, w19, sxtw #1]
	b	LBB10_8
LBB10_18:
	ldr	x8, [x21, #48]
	cmp	x8, #4
	b.ne	LBB10_29
; %bb.19:
	ldr	x8, [x21, #248]
	str	w20, [x8, w19, sxtw #2]
	b	LBB10_8
LBB10_20:
	ldr	x8, [x21, #48]
	cmp	x8, #4
	b.ne	LBB10_30
; %bb.21:
	scvtf	s0, w20
	ldr	x8, [x21, #248]
	str	s0, [x8, w19, sxtw #2]
	b	LBB10_8
LBB10_22:
	ldr	x8, [x21, #48]
	cmp	x8, #2
	b.ne	LBB10_31
; %bb.23:
	ldr	x8, [x21, #248]
	strh	w20, [x8, w19, sxtw #1]
	b	LBB10_8
LBB10_24:
	ubfx	w10, w9, #16, #1
	mov	w11, #32767                     ; =0x7fff
	add	w9, w9, w11
	add	w9, w9, w10
	lsr	w9, w9, #16
	strh	w9, [x8, w19, sxtw #1]
	b	LBB10_8
LBB10_25:
	bl	___stack_chk_fail
LBB10_26:
Lloh82:
	adrp	x8, l_.str.5@PAGE
Lloh83:
	add	x8, x8, l_.str.5@PAGEOFF
Lloh84:
	adrp	x0, l_.str.1@PAGE
Lloh85:
	add	x0, x0, l_.str.1@PAGEOFF
	str	x8, [sp]
Lloh86:
	adrp	x2, l_.str.2@PAGE
Lloh87:
	add	x2, x2, l_.str.2@PAGEOFF
	mov	w1, #947                        ; =0x3b3
	bl	_ggml_abort
LBB10_27:
Lloh88:
	adrp	x8, l_.str.9@PAGE
Lloh89:
	add	x8, x8, l_.str.9@PAGEOFF
Lloh90:
	adrp	x0, l_.str.1@PAGE
Lloh91:
	add	x0, x0, l_.str.1@PAGEOFF
	str	x8, [sp]
Lloh92:
	adrp	x2, l_.str.2@PAGE
Lloh93:
	add	x2, x2, l_.str.2@PAGEOFF
	mov	w1, #967                        ; =0x3c7
	bl	_ggml_abort
LBB10_28:
Lloh94:
	adrp	x8, l_.str.8@PAGE
Lloh95:
	add	x8, x8, l_.str.8@PAGEOFF
Lloh96:
	adrp	x0, l_.str.1@PAGE
Lloh97:
	add	x0, x0, l_.str.1@PAGEOFF
	str	x8, [sp]
Lloh98:
	adrp	x2, l_.str.2@PAGE
Lloh99:
	add	x2, x2, l_.str.2@PAGEOFF
	mov	w1, #962                        ; =0x3c2
	bl	_ggml_abort
LBB10_29:
Lloh100:
	adrp	x8, l_.str.7@PAGE
Lloh101:
	add	x8, x8, l_.str.7@PAGEOFF
Lloh102:
	adrp	x0, l_.str.1@PAGE
Lloh103:
	add	x0, x0, l_.str.1@PAGEOFF
	str	x8, [sp]
Lloh104:
	adrp	x2, l_.str.2@PAGE
Lloh105:
	add	x2, x2, l_.str.2@PAGEOFF
	mov	w1, #957                        ; =0x3bd
	bl	_ggml_abort
LBB10_30:
Lloh106:
	adrp	x8, l_.str.10@PAGE
Lloh107:
	add	x8, x8, l_.str.10@PAGEOFF
Lloh108:
	adrp	x0, l_.str.1@PAGE
Lloh109:
	add	x0, x0, l_.str.1@PAGEOFF
	str	x8, [sp]
Lloh110:
	adrp	x2, l_.str.2@PAGE
Lloh111:
	add	x2, x2, l_.str.2@PAGEOFF
	mov	w1, #972                        ; =0x3cc
	bl	_ggml_abort
LBB10_31:
Lloh112:
	adrp	x8, l_.str.6@PAGE
Lloh113:
	add	x8, x8, l_.str.6@PAGEOFF
Lloh114:
	adrp	x0, l_.str.1@PAGE
Lloh115:
	add	x0, x0, l_.str.1@PAGEOFF
	str	x8, [sp]
Lloh116:
	adrp	x2, l_.str.2@PAGE
Lloh117:
	add	x2, x2, l_.str.2@PAGEOFF
	mov	w1, #952                        ; =0x3b8
	bl	_ggml_abort
LBB10_32:
Lloh118:
	adrp	x0, l_.str.1@PAGE
Lloh119:
	add	x0, x0, l_.str.1@PAGEOFF
Lloh120:
	adrp	x2, l_.str.4@PAGE
Lloh121:
	add	x2, x2, l_.str.4@PAGEOFF
	mov	w1, #977                        ; =0x3d1
	bl	_ggml_abort
	.loh AdrpLdrGotLdr	Lloh76, Lloh77, Lloh78
	.loh AdrpLdrGotLdr	Lloh79, Lloh80, Lloh81
	.loh AdrpAdd	Lloh86, Lloh87
	.loh AdrpAdd	Lloh84, Lloh85
	.loh AdrpAdd	Lloh82, Lloh83
	.loh AdrpAdd	Lloh92, Lloh93
	.loh AdrpAdd	Lloh90, Lloh91
	.loh AdrpAdd	Lloh88, Lloh89
	.loh AdrpAdd	Lloh98, Lloh99
	.loh AdrpAdd	Lloh96, Lloh97
	.loh AdrpAdd	Lloh94, Lloh95
	.loh AdrpAdd	Lloh104, Lloh105
	.loh AdrpAdd	Lloh102, Lloh103
	.loh AdrpAdd	Lloh100, Lloh101
	.loh AdrpAdd	Lloh110, Lloh111
	.loh AdrpAdd	Lloh108, Lloh109
	.loh AdrpAdd	Lloh106, Lloh107
	.loh AdrpAdd	Lloh116, Lloh117
	.loh AdrpAdd	Lloh114, Lloh115
	.loh AdrpAdd	Lloh112, Lloh113
	.loh AdrpAdd	Lloh120, Lloh121
	.loh AdrpAdd	Lloh118, Lloh119
	.cfi_endproc
                                        ; -- End function
	.globl	_ggml_set_i32_nd                ; -- Begin function ggml_set_i32_nd
	.p2align	2
_ggml_set_i32_nd:                       ; @ggml_set_i32_nd
	.cfi_startproc
; %bb.0:
                                        ; kill: def $w4 killed $w4 def $x4
                                        ; kill: def $w3 killed $w3 def $x3
                                        ; kill: def $w2 killed $w2 def $x2
                                        ; kill: def $w1 killed $w1 def $x1
	ldr	x8, [x0, #248]
	sxtw	x9, w1
	ldp	x10, x11, [x0, #48]
	madd	x8, x10, x9, x8
	sxtw	x9, w2
	madd	x8, x11, x9, x8
	sxtw	x9, w3
	ldp	x10, x11, [x0, #64]
	madd	x8, x10, x9, x8
	sxtw	x9, w4
	mul	x9, x11, x9
	ldr	w10, [x0]
	cmp	w10, #24
	b.gt	LBB11_5
; %bb.1:
	cbz	w10, LBB11_12
; %bb.2:
	cmp	w10, #1
	b.eq	LBB11_10
; %bb.3:
	cmp	w10, #24
	b.ne	LBB11_15
; %bb.4:
	strb	w5, [x8, x9]
	ret
LBB11_5:
	cmp	w10, #25
	b.eq	LBB11_13
; %bb.6:
	cmp	w10, #26
	b.eq	LBB11_11
; %bb.7:
	cmp	w10, #30
	b.ne	LBB11_15
; %bb.8:
	scvtf	s0, w5
	fmov	w10, s0
	and	w11, w10, #0x7fffffff
	mov	w12, #1                         ; =0x1
	movk	w12, #32640, lsl #16
	cmp	w11, w12
	b.lo	LBB11_14
; %bb.9:
	lsr	w10, w10, #16
	orr	w10, w10, #0x40
	strh	w10, [x8, x9]
	ret
LBB11_10:
	scvtf	s0, w5
	fcvt	h0, s0
	str	h0, [x8, x9]
	ret
LBB11_11:
	str	w5, [x8, x9]
	ret
LBB11_12:
	scvtf	s0, w5
	str	s0, [x8, x9]
	ret
LBB11_13:
	strh	w5, [x8, x9]
	ret
LBB11_14:
	ubfx	w11, w10, #16, #1
	mov	w12, #32767                     ; =0x7fff
	add	w10, w10, w12
	add	w10, w10, w11
	lsr	w10, w10, #16
	strh	w10, [x8, x9]
	ret
LBB11_15:
	stp	x29, x30, [sp, #-16]!           ; 16-byte Folded Spill
	mov	x29, sp
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
Lloh122:
	adrp	x0, l_.str.1@PAGE
Lloh123:
	add	x0, x0, l_.str.1@PAGEOFF
Lloh124:
	adrp	x2, l_.str.4@PAGE
Lloh125:
	add	x2, x2, l_.str.4@PAGEOFF
	mov	w1, #1031                       ; =0x407
	bl	_ggml_abort
	.loh AdrpAdd	Lloh124, Lloh125
	.loh AdrpAdd	Lloh122, Lloh123
	.cfi_endproc
                                        ; -- End function
	.globl	_ggml_get_f32_1d                ; -- Begin function ggml_get_f32_1d
	.p2align	2
_ggml_get_f32_1d:                       ; @ggml_get_f32_1d
	.cfi_startproc
; %bb.0:
	sub	sp, sp, #80
	stp	x20, x19, [sp, #48]             ; 16-byte Folded Spill
	stp	x29, x30, [sp, #64]             ; 16-byte Folded Spill
	add	x29, sp, #64
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	mov	x20, x1
	mov	x19, x0
Lloh126:
	adrp	x8, ___stack_chk_guard@GOTPAGE
Lloh127:
	ldr	x8, [x8, ___stack_chk_guard@GOTPAGEOFF]
Lloh128:
	ldr	x8, [x8]
	stur	x8, [x29, #-24]
	bl	_ggml_is_contiguous
	tbz	w0, #0, LBB12_6
; %bb.1:
	ldr	w8, [x19]
	cmp	w8, #24
	b.gt	LBB12_12
; %bb.2:
	cbz	w8, LBB12_26
; %bb.3:
	cmp	w8, #1
	b.eq	LBB12_21
; %bb.4:
	cmp	w8, #24
	b.ne	LBB12_35
; %bb.5:
	ldr	x8, [x19, #248]
	ldr	b0, [x8, w20, sxtw]
	b	LBB12_11
LBB12_6:
	movi.2d	v0, #0000000000000000
	stp	q0, q0, [sp]
	mov	x8, sp
	sxtw	x1, w20
	mov	x2, sp
	orr	x3, x8, #0x8
	add	x4, x8, #16
	add	x5, x8, #24
	mov	x0, x19
	bl	_ggml_unravel_index
	ldrsw	x8, [sp]
	ldrsw	x9, [sp, #8]
	ldr	x10, [x19, #248]
	ldp	x11, x12, [x19, #48]
	madd	x8, x11, x8, x10
	ldrsw	x10, [sp, #16]
	ldrsw	x11, [sp, #24]
	madd	x8, x12, x9, x8
	ldp	x9, x12, [x19, #64]
	madd	x8, x9, x10, x8
	mul	x9, x12, x11
	ldr	w10, [x19]
	cmp	w10, #24
	b.gt	LBB12_16
; %bb.7:
	cbz	w10, LBB12_27
; %bb.8:
	cmp	w10, #1
	b.eq	LBB12_22
; %bb.9:
	cmp	w10, #24
	b.ne	LBB12_36
; %bb.10:
	ldr	b0, [x8, x9]
LBB12_11:
	sshll.8h	v0, v0, #0
	sshll.4s	v0, v0, #0
	b	LBB12_31
LBB12_12:
	cmp	w8, #25
	b.eq	LBB12_28
; %bb.13:
	cmp	w8, #26
	b.eq	LBB12_23
; %bb.14:
	cmp	w8, #30
	b.ne	LBB12_35
; %bb.15:
	ldr	x8, [x19, #248]
	ldrh	w8, [x8, w20, sxtw #1]
	b	LBB12_20
LBB12_16:
	cmp	w10, #25
	b.eq	LBB12_29
; %bb.17:
	cmp	w10, #26
	b.eq	LBB12_24
; %bb.18:
	cmp	w10, #30
	b.ne	LBB12_36
; %bb.19:
	ldrh	w8, [x8, x9]
LBB12_20:
	lsl	w8, w8, #16
	fmov	s0, w8
	b	LBB12_32
LBB12_21:
	ldr	x8, [x19, #248]
	ldr	h0, [x8, w20, sxtw #1]
	fcvt	s0, h0
	b	LBB12_32
LBB12_22:
	ldr	h0, [x8, x9]
	fcvt	s0, h0
	b	LBB12_32
LBB12_23:
	ldr	x8, [x19, #248]
	ldr	s0, [x8, w20, sxtw #2]
	b	LBB12_25
LBB12_24:
	ldr	s0, [x8, x9]
LBB12_25:
	scvtf	s0, s0
	b	LBB12_32
LBB12_26:
	ldr	x8, [x19, #248]
	ldr	s0, [x8, w20, sxtw #2]
	b	LBB12_32
LBB12_27:
	ldr	s0, [x8, x9]
	b	LBB12_32
LBB12_28:
	ldr	x8, [x19, #248]
	ldr	h0, [x8, w20, sxtw #1]
	b	LBB12_30
LBB12_29:
	ldr	h0, [x8, x9]
LBB12_30:
	sshll.4s	v0, v0, #0
LBB12_31:
	scvtf	s0, s0
LBB12_32:
	ldur	x8, [x29, #-24]
Lloh129:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh130:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh131:
	ldr	x9, [x9]
	cmp	x9, x8
	b.ne	LBB12_34
; %bb.33:
	ldp	x29, x30, [sp, #64]             ; 16-byte Folded Reload
	ldp	x20, x19, [sp, #48]             ; 16-byte Folded Reload
	add	sp, sp, #80
	ret
LBB12_34:
	bl	___stack_chk_fail
LBB12_35:
Lloh132:
	adrp	x0, l_.str.1@PAGE
Lloh133:
	add	x0, x0, l_.str.1@PAGEOFF
Lloh134:
	adrp	x2, l_.str.4@PAGE
Lloh135:
	add	x2, x2, l_.str.4@PAGEOFF
	mov	w1, #1069                       ; =0x42d
	bl	_ggml_abort
LBB12_36:
Lloh136:
	adrp	x0, l_.str.1@PAGE
Lloh137:
	add	x0, x0, l_.str.1@PAGEOFF
Lloh138:
	adrp	x2, l_.str.4@PAGE
Lloh139:
	add	x2, x2, l_.str.4@PAGEOFF
	mov	w1, #1129                       ; =0x469
	bl	_ggml_abort
	.loh AdrpLdrGotLdr	Lloh126, Lloh127, Lloh128
	.loh AdrpLdrGotLdr	Lloh129, Lloh130, Lloh131
	.loh AdrpAdd	Lloh134, Lloh135
	.loh AdrpAdd	Lloh132, Lloh133
	.loh AdrpAdd	Lloh138, Lloh139
	.loh AdrpAdd	Lloh136, Lloh137
	.cfi_endproc
                                        ; -- End function
	.globl	_ggml_get_f32_nd                ; -- Begin function ggml_get_f32_nd
	.p2align	2
_ggml_get_f32_nd:                       ; @ggml_get_f32_nd
	.cfi_startproc
; %bb.0:
                                        ; kill: def $w4 killed $w4 def $x4
                                        ; kill: def $w3 killed $w3 def $x3
                                        ; kill: def $w2 killed $w2 def $x2
                                        ; kill: def $w1 killed $w1 def $x1
	ldr	x8, [x0, #248]
	sxtw	x9, w1
	ldp	x10, x11, [x0, #48]
	madd	x8, x10, x9, x8
	sxtw	x9, w2
	madd	x8, x11, x9, x8
	sxtw	x9, w3
	ldp	x10, x11, [x0, #64]
	madd	x8, x10, x9, x8
	sxtw	x9, w4
	mul	x9, x11, x9
	ldr	w10, [x0]
	cmp	w10, #24
	b.gt	LBB13_5
; %bb.1:
	cbz	w10, LBB13_11
; %bb.2:
	cmp	w10, #1
	b.eq	LBB13_9
; %bb.3:
	cmp	w10, #24
	b.ne	LBB13_13
; %bb.4:
	ldr	b0, [x8, x9]
	sshll.8h	v0, v0, #0
	sshll.4s	v0, v0, #0
	scvtf	s0, s0
	ret
LBB13_5:
	cmp	w10, #25
	b.eq	LBB13_12
; %bb.6:
	cmp	w10, #26
	b.eq	LBB13_10
; %bb.7:
	cmp	w10, #30
	b.ne	LBB13_13
; %bb.8:
	ldrh	w8, [x8, x9]
	lsl	w8, w8, #16
	fmov	s0, w8
	ret
LBB13_9:
	ldr	h0, [x8, x9]
	fcvt	s0, h0
	ret
LBB13_10:
	ldr	s0, [x8, x9]
	scvtf	s0, s0
	ret
LBB13_11:
	ldr	s0, [x8, x9]
	ret
LBB13_12:
	ldr	h0, [x8, x9]
	sshll.4s	v0, v0, #0
	scvtf	s0, s0
	ret
LBB13_13:
	stp	x29, x30, [sp, #-16]!           ; 16-byte Folded Spill
	mov	x29, sp
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
Lloh140:
	adrp	x0, l_.str.1@PAGE
Lloh141:
	add	x0, x0, l_.str.1@PAGEOFF
Lloh142:
	adrp	x2, l_.str.4@PAGE
Lloh143:
	add	x2, x2, l_.str.4@PAGEOFF
	mov	w1, #1129                       ; =0x469
	bl	_ggml_abort
	.loh AdrpAdd	Lloh142, Lloh143
	.loh AdrpAdd	Lloh140, Lloh141
	.cfi_endproc
                                        ; -- End function
	.globl	_ggml_set_f32_1d                ; -- Begin function ggml_set_f32_1d
	.p2align	2
_ggml_set_f32_1d:                       ; @ggml_set_f32_1d
	.cfi_startproc
; %bb.0:
	sub	sp, sp, #96
	stp	d9, d8, [sp, #48]               ; 16-byte Folded Spill
	stp	x20, x19, [sp, #64]             ; 16-byte Folded Spill
	stp	x29, x30, [sp, #80]             ; 16-byte Folded Spill
	add	x29, sp, #80
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset b8, -40
	.cfi_offset b9, -48
	fmov	s8, s0
	mov	x19, x1
	mov	x20, x0
Lloh144:
	adrp	x8, ___stack_chk_guard@GOTPAGE
Lloh145:
	ldr	x8, [x8, ___stack_chk_guard@GOTPAGEOFF]
Lloh146:
	ldr	x8, [x8]
	str	x8, [sp, #40]
	bl	_ggml_is_contiguous
	tbz	w0, #0, LBB14_6
; %bb.1:
	ldr	w8, [x20]
	cmp	w8, #24
	b.gt	LBB14_9
; %bb.2:
	cbz	w8, LBB14_16
; %bb.3:
	cmp	w8, #1
	b.eq	LBB14_14
; %bb.4:
	cmp	w8, #24
	b.ne	LBB14_20
; %bb.5:
	fcvtzs	w8, s8
	ldr	x9, [x20, #248]
	strb	w8, [x9, w19, sxtw]
	b	LBB14_7
LBB14_6:
	movi.2d	v0, #0000000000000000
	stp	q0, q0, [sp]
	mov	x8, sp
                                        ; kill: def $w19 killed $w19 killed $x19 def $x19
	sxtw	x1, w19
	mov	x2, sp
	orr	x3, x8, #0x8
	add	x4, x8, #16
	add	x5, x8, #24
	mov	x0, x20
	bl	_ggml_unravel_index
	ldr	w1, [sp]
	ldr	w2, [sp, #8]
	ldr	w3, [sp, #16]
	ldr	w4, [sp, #24]
	mov	x0, x20
	fmov	s0, s8
	bl	_ggml_set_f32_nd
LBB14_7:
	ldr	x8, [sp, #40]
Lloh147:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh148:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh149:
	ldr	x9, [x9]
	cmp	x9, x8
	b.ne	LBB14_19
; %bb.8:
	ldp	x29, x30, [sp, #80]             ; 16-byte Folded Reload
	ldp	x20, x19, [sp, #64]             ; 16-byte Folded Reload
	ldp	d9, d8, [sp, #48]               ; 16-byte Folded Reload
	add	sp, sp, #96
	ret
LBB14_9:
	cmp	w8, #25
	b.eq	LBB14_17
; %bb.10:
	cmp	w8, #26
	b.eq	LBB14_15
; %bb.11:
	cmp	w8, #30
	b.ne	LBB14_20
; %bb.12:
	ldr	x8, [x20, #248]
	fmov	w9, s8
	and	w10, w9, #0x7fffffff
	mov	w11, #1                         ; =0x1
	movk	w11, #32640, lsl #16
	cmp	w10, w11
	b.lo	LBB14_18
; %bb.13:
	lsr	w9, w9, #16
	orr	w9, w9, #0x40
	strh	w9, [x8, w19, sxtw #1]
	b	LBB14_7
LBB14_14:
	fcvt	h0, s8
	ldr	x8, [x20, #248]
	str	h0, [x8, w19, sxtw #1]
	b	LBB14_7
LBB14_15:
	fcvtzs	w8, s8
	ldr	x9, [x20, #248]
	str	w8, [x9, w19, sxtw #2]
	b	LBB14_7
LBB14_16:
	ldr	x8, [x20, #248]
	str	s8, [x8, w19, sxtw #2]
	b	LBB14_7
LBB14_17:
	fcvtzs	w8, s8
	ldr	x9, [x20, #248]
	strh	w8, [x9, w19, sxtw #1]
	b	LBB14_7
LBB14_18:
	ubfx	w10, w9, #16, #1
	mov	w11, #32767                     ; =0x7fff
	add	w9, w9, w10
	add	w9, w9, w11
	lsr	w9, w9, #16
	strh	w9, [x8, w19, sxtw #1]
	b	LBB14_7
LBB14_19:
	bl	___stack_chk_fail
LBB14_20:
Lloh150:
	adrp	x0, l_.str.1@PAGE
Lloh151:
	add	x0, x0, l_.str.1@PAGEOFF
Lloh152:
	adrp	x2, l_.str.4@PAGE
Lloh153:
	add	x2, x2, l_.str.4@PAGEOFF
	mov	w1, #1108                       ; =0x454
	bl	_ggml_abort
	.loh AdrpLdrGotLdr	Lloh144, Lloh145, Lloh146
	.loh AdrpLdrGotLdr	Lloh147, Lloh148, Lloh149
	.loh AdrpAdd	Lloh152, Lloh153
	.loh AdrpAdd	Lloh150, Lloh151
	.cfi_endproc
                                        ; -- End function
	.globl	_ggml_set_f32_nd                ; -- Begin function ggml_set_f32_nd
	.p2align	2
_ggml_set_f32_nd:                       ; @ggml_set_f32_nd
	.cfi_startproc
; %bb.0:
                                        ; kill: def $w4 killed $w4 def $x4
                                        ; kill: def $w3 killed $w3 def $x3
                                        ; kill: def $w2 killed $w2 def $x2
                                        ; kill: def $w1 killed $w1 def $x1
	ldr	x8, [x0, #248]
	sxtw	x9, w1
	ldp	x10, x11, [x0, #48]
	madd	x8, x10, x9, x8
	sxtw	x9, w2
	madd	x8, x11, x9, x8
	sxtw	x9, w3
	ldp	x10, x11, [x0, #64]
	madd	x8, x10, x9, x8
	sxtw	x9, w4
	mul	x9, x11, x9
	ldr	w10, [x0]
	cmp	w10, #24
	b.gt	LBB15_5
; %bb.1:
	cbz	w10, LBB15_12
; %bb.2:
	cmp	w10, #1
	b.eq	LBB15_10
; %bb.3:
	cmp	w10, #24
	b.ne	LBB15_15
; %bb.4:
	fcvtzs	w10, s0
	strb	w10, [x8, x9]
	ret
LBB15_5:
	cmp	w10, #25
	b.eq	LBB15_13
; %bb.6:
	cmp	w10, #26
	b.eq	LBB15_11
; %bb.7:
	cmp	w10, #30
	b.ne	LBB15_15
; %bb.8:
	fmov	w10, s0
	and	w11, w10, #0x7fffffff
	mov	w12, #1                         ; =0x1
	movk	w12, #32640, lsl #16
	cmp	w11, w12
	b.lo	LBB15_14
; %bb.9:
	lsr	w10, w10, #16
	orr	w10, w10, #0x40
	strh	w10, [x8, x9]
	ret
LBB15_10:
	fcvt	h0, s0
	str	h0, [x8, x9]
	ret
LBB15_11:
	fcvtzs	w10, s0
	str	w10, [x8, x9]
	ret
LBB15_12:
	str	s0, [x8, x9]
	ret
LBB15_13:
	fcvtzs	w10, s0
	strh	w10, [x8, x9]
	ret
LBB15_14:
	ubfx	w11, w10, #16, #1
	mov	w12, #32767                     ; =0x7fff
	add	w10, w10, w11
	add	w10, w10, w12
	lsr	w10, w10, #16
	strh	w10, [x8, x9]
	ret
LBB15_15:
	stp	x29, x30, [sp, #-16]!           ; 16-byte Folded Spill
	mov	x29, sp
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
Lloh154:
	adrp	x0, l_.str.1@PAGE
Lloh155:
	add	x0, x0, l_.str.1@PAGEOFF
Lloh156:
	adrp	x2, l_.str.4@PAGE
Lloh157:
	add	x2, x2, l_.str.4@PAGEOFF
	mov	w1, #1162                       ; =0x48a
	bl	_ggml_abort
	.loh AdrpAdd	Lloh156, Lloh157
	.loh AdrpAdd	Lloh154, Lloh155
	.cfi_endproc
                                        ; -- End function
	.globl	_ggml_threadpool_free           ; -- Begin function ggml_threadpool_free
	.p2align	2
_ggml_threadpool_free:                  ; @ggml_threadpool_free
	.cfi_startproc
; %bb.0:
	sub	sp, sp, #64
	stp	x22, x21, [sp, #16]             ; 16-byte Folded Spill
	stp	x20, x19, [sp, #32]             ; 16-byte Folded Spill
	stp	x29, x30, [sp, #48]             ; 16-byte Folded Spill
	add	x29, sp, #48
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	cbz	x0, LBB16_6
; %bb.1:
	mov	x19, x0
	ldr	w20, [x0, #344]
	ldr	x21, [x0, #336]
	bl	_pthread_mutex_lock
	add	x8, x19, #324
	mov	w9, #1                          ; =0x1
	stlrb	w9, [x8]
	add	x8, x19, #325
	stlrb	wzr, [x8]
	add	x0, x19, #64
	bl	_pthread_cond_broadcast
	mov	x0, x19
	bl	_pthread_mutex_unlock
	cmp	w20, #2
	b.lt	LBB16_5
; %bb.2:
	add	x21, x21, #544
	sub	x22, x20, #1
LBB16_3:                                ; =>This Inner Loop Header: Depth=1
	ldr	x0, [x21]
	mov	x1, #0                          ; =0x0
	bl	_pthread_join
	cmp	w0, #2
	b.hs	LBB16_7
; %bb.4:                                ;   in Loop: Header=BB16_3 Depth=1
	add	x21, x21, #544
	subs	x22, x22, #1
	b.ne	LBB16_3
LBB16_5:
	mov	x0, x19
	bl	_pthread_mutex_destroy
	add	x0, x19, #64
	bl	_pthread_cond_destroy
	sxtw	x8, w20
	add	x8, x8, w20, sxtw #4
	lsl	x1, x8, #5
	ldr	x0, [x19, #336]
	bl	_ggml_aligned_free
	mov	x0, x19
	mov	w1, #384                        ; =0x180
	ldp	x29, x30, [sp, #48]             ; 16-byte Folded Reload
	ldp	x20, x19, [sp, #32]             ; 16-byte Folded Reload
	ldp	x22, x21, [sp, #16]             ; 16-byte Folded Reload
	add	sp, sp, #64
	b	_ggml_aligned_free
LBB16_6:
	ldp	x29, x30, [sp, #48]             ; 16-byte Folded Reload
	ldp	x20, x19, [sp, #32]             ; 16-byte Folded Reload
	ldp	x22, x21, [sp, #16]             ; 16-byte Folded Reload
	add	sp, sp, #64
	ret
LBB16_7:
Lloh158:
	adrp	x8, l_.str.11@PAGE
Lloh159:
	add	x8, x8, l_.str.11@PAGEOFF
Lloh160:
	adrp	x0, l_.str.1@PAGE
Lloh161:
	add	x0, x0, l_.str.1@PAGEOFF
	str	x8, [sp]
Lloh162:
	adrp	x2, l_.str.2@PAGE
Lloh163:
	add	x2, x2, l_.str.2@PAGEOFF
	mov	w1, #2590                       ; =0xa1e
	bl	_ggml_abort
	.loh AdrpAdd	Lloh162, Lloh163
	.loh AdrpAdd	Lloh160, Lloh161
	.loh AdrpAdd	Lloh158, Lloh159
	.cfi_endproc
                                        ; -- End function
	.globl	_ggml_threadpool_pause          ; -- Begin function ggml_threadpool_pause
	.p2align	2
_ggml_threadpool_pause:                 ; @ggml_threadpool_pause
	.cfi_startproc
; %bb.0:
	stp	x20, x19, [sp, #-32]!           ; 16-byte Folded Spill
	stp	x29, x30, [sp, #16]             ; 16-byte Folded Spill
	add	x29, sp, #16
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	mov	x19, x0
	bl	_pthread_mutex_lock
	add	x8, x19, #325
	ldarb	w9, [x8]
	tbnz	w9, #0, LBB17_2
; %bb.1:
	mov	w9, #1                          ; =0x1
	stlrb	w9, [x8]
	add	x0, x19, #64
	bl	_pthread_cond_broadcast
LBB17_2:
	mov	x0, x19
	ldp	x29, x30, [sp, #16]             ; 16-byte Folded Reload
	ldp	x20, x19, [sp], #32             ; 16-byte Folded Reload
	b	_pthread_mutex_unlock
	.cfi_endproc
                                        ; -- End function
	.globl	_ggml_threadpool_resume         ; -- Begin function ggml_threadpool_resume
	.p2align	2
_ggml_threadpool_resume:                ; @ggml_threadpool_resume
	.cfi_startproc
; %bb.0:
	stp	x20, x19, [sp, #-32]!           ; 16-byte Folded Spill
	stp	x29, x30, [sp, #16]             ; 16-byte Folded Spill
	add	x29, sp, #16
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	mov	x19, x0
	bl	_pthread_mutex_lock
	add	x8, x19, #325
	ldarb	w9, [x8]
	tbz	w9, #0, LBB18_2
; %bb.1:
	stlrb	wzr, [x8]
	add	x0, x19, #64
	bl	_pthread_cond_broadcast
LBB18_2:
	mov	x0, x19
	ldp	x29, x30, [sp, #16]             ; 16-byte Folded Reload
	ldp	x20, x19, [sp], #32             ; 16-byte Folded Reload
	b	_pthread_mutex_unlock
	.cfi_endproc
                                        ; -- End function
	.globl	_ggml_graph_plan                ; -- Begin function ggml_graph_plan
	.p2align	2
_ggml_graph_plan:                       ; @ggml_graph_plan
	.cfi_startproc
; %bb.0:
	sub	sp, sp, #128
	stp	x28, x27, [sp, #32]             ; 16-byte Folded Spill
	stp	x26, x25, [sp, #48]             ; 16-byte Folded Spill
	stp	x24, x23, [sp, #64]             ; 16-byte Folded Spill
	stp	x22, x21, [sp, #80]             ; 16-byte Folded Spill
	stp	x20, x19, [sp, #96]             ; 16-byte Folded Spill
	stp	x29, x30, [sp, #112]            ; 16-byte Folded Spill
	add	x29, sp, #112
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	.cfi_offset w23, -56
	.cfi_offset w24, -64
	.cfi_offset w25, -72
	.cfi_offset w26, -80
	.cfi_offset w27, -88
	.cfi_offset w28, -96
	mov	x25, x2
	mov	x20, x1
	mov	x22, x0
	mov	x19, x8
	cmp	w1, #0
	b.gt	LBB19_4
; %bb.1:
	cbz	x25, LBB19_3
; %bb.2:
	ldr	w20, [x25, #344]
	b	LBB19_4
LBB19_3:
	mov	w20, #4                         ; =0x4
LBB19_4:
	movi.2d	v0, #0000000000000000
	stp	q0, q0, [x19, #16]
	str	q0, [x19]
	ldr	w8, [x22, #4]
	cmp	w8, #1
	b.lt	LBB19_62
; %bb.5:
	mov	x27, #0                         ; =0x0
	mov	x26, #0                         ; =0x0
	sxtw	x8, w20
	str	x8, [sp, #8]                    ; 8-byte Folded Spill
Lloh164:
	adrp	x28, lJTI19_1@PAGE
Lloh165:
	add	x28, x28, lJTI19_1@PAGEOFF
	mov	w24, #1                         ; =0x1
	b	LBB19_11
LBB19_6:                                ;   in Loop: Header=BB19_11 Depth=1
	mov	w0, #0                          ; =0x0
	bl	_ggml_type_size
	ldr	x8, [x23, #16]
LBB19_7:                                ;   in Loop: Header=BB19_11 Depth=1
                                        ; kill: def $w21 killed $w21 killed $x21 def $x21
LBB19_8:                                ;   in Loop: Header=BB19_11 Depth=1
	sxtw	x9, w21
	mul	x9, x0, x9
	mul	x8, x9, x8
LBB19_9:                                ;   in Loop: Header=BB19_11 Depth=1
	str	x8, [sp, #24]
LBB19_10:                               ;   in Loop: Header=BB19_11 Depth=1
	ldr	x8, [sp, #24]
	cmp	x26, x8
	csel	x26, x26, x8, hi
	add	x27, x27, #1
	ldrsw	x8, [x22, #4]
	cmp	x27, x8
	b.ge	LBB19_60
LBB19_11:                               ; =>This Inner Loop Header: Depth=1
	ldr	x8, [x22, #16]
	ldr	x23, [x8, x27, lsl #3]
	mov	x0, x23
	bl	_ggml_is_empty
	tbnz	w0, #0, LBB19_14
; %bb.12:                               ;   in Loop: Header=BB19_11 Depth=1
	ldr	w8, [x23, #80]
	cmp	w8, #82
	b.hi	LBB19_71
; %bb.13:                               ;   in Loop: Header=BB19_11 Depth=1
Lloh166:
	adrp	x11, lJTI19_0@PAGE
Lloh167:
	add	x11, x11, lJTI19_0@PAGEOFF
	adr	x9, LBB19_14
	ldrh	w10, [x11, x8, lsl #1]
	add	x9, x9, x10, lsl #2
	mov	x21, x20
	br	x9
LBB19_14:                               ;   in Loop: Header=BB19_11 Depth=1
	mov	w21, #1                         ; =0x1
LBB19_15:                               ;   in Loop: Header=BB19_11 Depth=1
	cmp	w24, w21
	csel	w24, w24, w21, gt
	str	xzr, [sp, #24]
	add	x2, sp, #24
	mov	x0, x20
	mov	x1, x23
	bl	_ggml_cpu_extra_work_size
	tbnz	w0, #0, LBB19_10
; %bb.16:                               ;   in Loop: Header=BB19_11 Depth=1
	ldr	w8, [x23, #80]
	sub	w8, w8, #1
	cmp	w8, #81
	b.hi	LBB19_10
; %bb.17:                               ;   in Loop: Header=BB19_11 Depth=1
	adr	x9, LBB19_6
	ldrh	w10, [x28, x8, lsl #1]
	add	x9, x9, x10, lsl #2
	br	x9
LBB19_18:                               ;   in Loop: Header=BB19_11 Depth=1
	ldr	x8, [x23, #152]
	ldr	w0, [x8]
	bl	_ggml_is_quantized
	cbz	w0, LBB19_10
; %bb.19:                               ;   in Loop: Header=BB19_11 Depth=1
	mov	w0, #0                          ; =0x0
	bl	_ggml_type_size
	ldr	x8, [x23, #152]
	b	LBB19_30
LBB19_20:                               ;   in Loop: Header=BB19_11 Depth=1
	ldr	w0, [x23]
	bl	_ggml_is_quantized
	tbz	w0, #0, LBB19_45
LBB19_21:                               ;   in Loop: Header=BB19_11 Depth=1
	mov	w0, #0                          ; =0x0
	bl	_ggml_type_size
	ldr	x8, [x23, #16]
	b	LBB19_8
LBB19_22:                               ;   in Loop: Header=BB19_11 Depth=1
	ldr	w0, [x23]
	bl	_ggml_type_size
                                        ; kill: def $w21 killed $w21 killed $x21 def $x21
	sxtw	x8, w21
	ldr	x9, [x23, #152]
	ldr	x9, [x9, #16]
	mul	x8, x0, x8
	madd	x8, x8, x9, x8
	b	LBB19_9
LBB19_23:                               ;   in Loop: Header=BB19_11 Depth=1
	ldp	x8, x0, [x23, #152]
	ldr	w8, [x8]
Lloh168:
	adrp	x9, _type_traits_cpu@PAGE
Lloh169:
	add	x9, x9, _type_traits_cpu@PAGEOFF
	add	x8, x9, x8, lsl #5
	ldr	w23, [x8, #16]
	ldr	w8, [x0]
	cmp	w8, w23
	b.eq	LBB19_10
; %bb.24:                               ;   in Loop: Header=BB19_11 Depth=1
	bl	_ggml_nelements
	mov	x1, x0
	mov	x0, x23
	bl	_ggml_row_size
	str	x0, [sp, #24]
	b	LBB19_10
LBB19_25:                               ;   in Loop: Header=BB19_11 Depth=1
	stp	x19, xzr, [sp, #16]             ; 8-byte Folded Spill
	mov	x19, x28
	mov	x28, x25
	mov	x8, #0                          ; =0x0
	ldp	x9, x0, [x23, #152]
	ldr	x21, [x23, #168]
	ldr	w10, [x9]
Lloh170:
	adrp	x11, _type_traits_cpu@PAGE
Lloh171:
	add	x11, x11, _type_traits_cpu@PAGEOFF
	add	x10, x11, x10, lsl #5
	ldr	w23, [x10, #16]
	ldr	x25, [x9, #32]
	ldr	w9, [x0]
	cmp	w9, w23
	b.eq	LBB19_27
; %bb.26:                               ;   in Loop: Header=BB19_11 Depth=1
	bl	_ggml_nelements
	mov	x1, x0
	mov	x0, x23
	bl	_ggml_row_size
	ldr	x8, [sp, #24]
	add	x8, x0, x8
	add	x8, x8, #8
LBB19_27:                               ;   in Loop: Header=BB19_11 Depth=1
	sbfiz	x9, x25, #3, #32
	ldp	x10, x11, [x21, #16]
	mul	x10, x9, x10
	lsl	w12, w25, #6
	add	x8, x8, x9
	madd	x8, x10, x11, x8
	add	x8, x8, w12, sxtw
	add	x8, x8, #80
	str	x8, [sp, #24]
	mov	x25, x28
	mov	x28, x19
	ldr	x19, [sp, #16]                  ; 8-byte Folded Reload
	b	LBB19_10
LBB19_28:                               ;   in Loop: Header=BB19_11 Depth=1
	ldr	x8, [x23, #152]
	ldr	w0, [x8]
	bl	_ggml_is_quantized
	cbz	w0, LBB19_10
; %bb.29:                               ;   in Loop: Header=BB19_11 Depth=1
	mov	w0, #0                          ; =0x0
	bl	_ggml_type_size
	ldr	x8, [x23, #160]
LBB19_30:                               ;   in Loop: Header=BB19_11 Depth=1
	ldr	x8, [x8, #16]
	b	LBB19_7
LBB19_31:                               ;   in Loop: Header=BB19_11 Depth=1
	ldp	x8, x9, [x23, #152]
	ldp	x10, x11, [x8, #16]
	ldp	x12, x8, [x8, #32]
	ldp	x13, x14, [x9, #16]
	ldr	x9, [x9, #32]
	mul	x10, x11, x10
	mul	x10, x10, x12
	mul	x8, x10, x8
	ldr	x10, [sp, #24]
	mul	x11, x14, x13
	madd	x8, x11, x9, x8
	add	x8, x10, x8, lsl #1
	b	LBB19_9
LBB19_32:                               ;   in Loop: Header=BB19_11 Depth=1
	ldr	w0, [x23]
	bl	_ggml_type_size
                                        ; kill: def $w21 killed $w21 killed $x21 def $x21
	sxtw	x8, w21
	mul	x8, x0, x8
	b	LBB19_9
LBB19_33:                               ;   in Loop: Header=BB19_11 Depth=1
	ldr	x14, [x23, #152]
	ldr	x8, [x14, #40]
	cmp	x8, #1
	b.ne	LBB19_67
; %bb.34:                               ;   in Loop: Header=BB19_11 Depth=1
	ldr	x11, [x23, #160]
	ldr	x8, [x11, #32]
	cmp	x8, #1
	b.ne	LBB19_68
; %bb.35:                               ;   in Loop: Header=BB19_11 Depth=1
	ldr	x8, [x11, #40]
	cmp	x8, #1
	b.ne	LBB19_69
; %bb.36:                               ;   in Loop: Header=BB19_11 Depth=1
	ldp	x8, x9, [x14, #16]
	ldr	x12, [x14, #32]
	ldp	x10, x13, [x11, #16]
	ldr	w14, [x14]
	cbz	w14, LBB19_52
; %bb.37:                               ;   in Loop: Header=BB19_11 Depth=1
	cmp	w14, #30
	ccmp	w14, #1, #4, ne
	b.ne	LBB19_65
; %bb.38:                               ;   in Loop: Header=BB19_11 Depth=1
	ldr	w11, [x11]
	cbnz	w11, LBB19_65
; %bb.39:                               ;   in Loop: Header=BB19_11 Depth=1
	mov	w11, #1                         ; =0x1
	b	LBB19_54
LBB19_40:                               ;   in Loop: Header=BB19_11 Depth=1
	ldp	x8, x9, [x23, #160]
	ldr	x8, [x8, #16]
	ldr	x9, [x9, #16]
	lsl	x9, x9, #3
	add	x8, x9, x8, lsl #2
                                        ; kill: def $w21 killed $w21 killed $x21 def $x21
	sxtw	x9, w21
	mul	x8, x8, x9
	b	LBB19_9
LBB19_41:                               ;   in Loop: Header=BB19_11 Depth=1
	ldp	x8, x9, [x23, #152]
	ldr	x8, [x8, #16]
	ldr	w10, [x9, #24]
	add	w10, w10, #3
	sxtw	x10, w10
	and	x10, x10, #0xfffffffffffffffc
	cmp	x8, x10
	csel	x8, x8, x10, gt
	ldr	w9, [x9]
	cmp	w9, #30
	b.eq	LBB19_44
; %bb.42:                               ;   in Loop: Header=BB19_11 Depth=1
	cmp	w9, #1
	b.eq	LBB19_44
; %bb.43:                               ;   in Loop: Header=BB19_11 Depth=1
	cbnz	w9, LBB19_10
LBB19_44:                               ;   in Loop: Header=BB19_11 Depth=1
                                        ; kill: def $w21 killed $w21 killed $x21 def $x21
	sxtw	x9, w21
	mul	x8, x9, x8
	lsl	x8, x8, #4
	b	LBB19_9
LBB19_45:                               ;   in Loop: Header=BB19_11 Depth=1
	ldr	x8, [x23, #152]
	ldr	w8, [x8]
	cmp	w8, #30
	b.eq	LBB19_50
; %bb.46:                               ;   in Loop: Header=BB19_11 Depth=1
	cmp	w8, #1
	b.ne	LBB19_10
; %bb.47:                               ;   in Loop: Header=BB19_11 Depth=1
	ldr	x8, [x23, #160]
	cbz	x8, LBB19_10
; %bb.48:                               ;   in Loop: Header=BB19_11 Depth=1
	ldr	w8, [x8]
	cmp	w8, #30
	b.ne	LBB19_10
	b	LBB19_21
LBB19_49:                               ;   in Loop: Header=BB19_11 Depth=1
	ldr	w8, [x23, #92]
	cmp	w8, w20
	csel	w9, w8, w20, lt
	cmn	w8, #1
	csel	w21, w20, w9, eq
	b	LBB19_15
LBB19_50:                               ;   in Loop: Header=BB19_11 Depth=1
	ldr	x8, [x23, #160]
	cbz	x8, LBB19_10
; %bb.51:                               ;   in Loop: Header=BB19_11 Depth=1
	ldr	w8, [x8]
	cmp	w8, #1
	b.ne	LBB19_10
	b	LBB19_21
LBB19_52:                               ;   in Loop: Header=BB19_11 Depth=1
	ldr	w11, [x11]
	cbnz	w11, LBB19_65
; %bb.53:                               ;   in Loop: Header=BB19_11 Depth=1
	mov	w11, #2                         ; =0x2
LBB19_54:                               ;   in Loop: Header=BB19_11 Depth=1
	ldr	x14, [sp, #24]
	mul	x9, x12, x9
	mul	x8, x9, x8
	madd	x8, x13, x10, x8
	lsl	x8, x8, x11
	add	x8, x14, x8
	b	LBB19_9
LBB19_55:                               ;   in Loop: Header=BB19_11 Depth=1
	mov	x0, x23
	bl	_ggml_get_unary_op
	cmp	w0, #13
	b.hi	LBB19_75
; %bb.56:                               ;   in Loop: Header=BB19_11 Depth=1
	mov	w8, #1                          ; =0x1
	lsl	w8, w8, w0
	mov	w9, #14591                      ; =0x38ff
	tst	w8, w9
	b.ne	LBB19_14
; %bb.57:                               ;   in Loop: Header=BB19_11 Depth=1
	mov	x21, x20
	b	LBB19_15
LBB19_58:                               ;   in Loop: Header=BB19_11 Depth=1
	ldr	x0, [x23, #152]
	bl	_ggml_nrows
	mov	x21, x20
	ldr	x8, [sp, #8]                    ; 8-byte Folded Reload
	cmp	x0, x8
	b.gt	LBB19_15
; %bb.59:                               ;   in Loop: Header=BB19_11 Depth=1
	ldr	x0, [x23, #152]
	bl	_ggml_nrows
	mov	x21, x0
	b	LBB19_15
LBB19_60:
	cbz	x26, LBB19_63
; %bb.61:
	lsl	w8, w20, #6
	add	x8, x26, w8, sxtw
	b	LBB19_64
LBB19_62:
	mov	w24, #1                         ; =0x1
LBB19_63:
	mov	x8, #0                          ; =0x0
LBB19_64:
	str	x25, [x19, #24]
	cmp	w24, w20
	csel	w9, w24, w20, lt
	str	w9, [x19, #16]
	stp	x8, xzr, [x19]
	ldp	x29, x30, [sp, #112]            ; 16-byte Folded Reload
	ldp	x20, x19, [sp, #96]             ; 16-byte Folded Reload
	ldp	x22, x21, [sp, #80]             ; 16-byte Folded Reload
	ldp	x24, x23, [sp, #64]             ; 16-byte Folded Reload
	ldp	x26, x25, [sp, #48]             ; 16-byte Folded Reload
	ldp	x28, x27, [sp, #32]             ; 16-byte Folded Reload
	add	sp, sp, #128
	ret
LBB19_65:
Lloh172:
	adrp	x0, l_.str.1@PAGE
Lloh173:
	add	x0, x0, l_.str.1@PAGEOFF
Lloh174:
	adrp	x2, l_.str.4@PAGE
Lloh175:
	add	x2, x2, l_.str.4@PAGEOFF
	mov	w1, #2761                       ; =0xac9
	bl	_ggml_abort
LBB19_66:
Lloh176:
	adrp	x0, l_.str.1@PAGE
Lloh177:
	add	x0, x0, l_.str.1@PAGEOFF
Lloh178:
	adrp	x2, l_.str.4@PAGE
Lloh179:
	add	x2, x2, l_.str.4@PAGEOFF
	mov	w1, #2808                       ; =0xaf8
	bl	_ggml_abort
LBB19_67:
Lloh180:
	adrp	x8, l_.str.12@PAGE
Lloh181:
	add	x8, x8, l_.str.12@PAGEOFF
Lloh182:
	adrp	x0, l_.str.1@PAGE
Lloh183:
	add	x0, x0, l_.str.1@PAGEOFF
	str	x8, [sp]
Lloh184:
	adrp	x2, l_.str.2@PAGE
Lloh185:
	add	x2, x2, l_.str.2@PAGEOFF
	mov	w1, #2741                       ; =0xab5
	bl	_ggml_abort
LBB19_68:
Lloh186:
	adrp	x8, l_.str.13@PAGE
Lloh187:
	add	x8, x8, l_.str.13@PAGEOFF
Lloh188:
	adrp	x0, l_.str.1@PAGE
Lloh189:
	add	x0, x0, l_.str.1@PAGEOFF
	str	x8, [sp]
Lloh190:
	adrp	x2, l_.str.2@PAGE
Lloh191:
	add	x2, x2, l_.str.2@PAGEOFF
	mov	w1, #2742                       ; =0xab6
	bl	_ggml_abort
LBB19_69:
Lloh192:
	adrp	x8, l_.str.14@PAGE
Lloh193:
	add	x8, x8, l_.str.14@PAGEOFF
Lloh194:
	adrp	x0, l_.str.1@PAGE
Lloh195:
	add	x0, x0, l_.str.1@PAGEOFF
	str	x8, [sp]
Lloh196:
	adrp	x2, l_.str.2@PAGE
Lloh197:
	add	x2, x2, l_.str.2@PAGEOFF
	mov	w1, #2743                       ; =0xab7
	bl	_ggml_abort
LBB19_70:
Lloh198:
	adrp	x0, l_.str.1@PAGE
Lloh199:
	add	x0, x0, l_.str.1@PAGEOFF
Lloh200:
	adrp	x2, l_.str.4@PAGE
Lloh201:
	add	x2, x2, l_.str.4@PAGEOFF
	mov	w1, #2356                       ; =0x934
	bl	_ggml_abort
LBB19_71:
Lloh202:
	adrp	x19, ___stderrp@GOTPAGE
Lloh203:
	ldr	x19, [x19, ___stderrp@GOTPAGEOFF]
	ldr	x0, [x19]
Lloh204:
	adrp	x8, l___func__.ggml_get_n_tasks@PAGE
Lloh205:
	add	x8, x8, l___func__.ggml_get_n_tasks@PAGEOFF
	str	x8, [sp]
Lloh206:
	adrp	x1, l_.str.19@PAGE
Lloh207:
	add	x1, x1, l_.str.19@PAGEOFF
	bl	_fprintf
	ldr	w0, [x23, #80]
	ldr	x19, [x19]
	cmp	w0, #81
	b.hi	LBB19_73
; %bb.72:
                                        ; kill: def $w0 killed $w0 killed $x0
	bl	_ggml_op_name
	str	x0, [sp]
Lloh208:
	adrp	x1, l_.str.20@PAGE
Lloh209:
	add	x1, x1, l_.str.20@PAGEOFF
	b	LBB19_74
LBB19_73:
	str	x0, [sp]
Lloh210:
	adrp	x1, l_.str.21@PAGE
Lloh211:
	add	x1, x1, l_.str.21@PAGEOFF
LBB19_74:
	mov	x0, x19
	bl	_fprintf
Lloh212:
	adrp	x0, l_.str.1@PAGE
Lloh213:
	add	x0, x0, l_.str.1@PAGEOFF
Lloh214:
	adrp	x2, l_.str.4@PAGE
Lloh215:
	add	x2, x2, l_.str.4@PAGEOFF
	mov	w1, #2366                       ; =0x93e
	bl	_ggml_abort
LBB19_75:
Lloh216:
	adrp	x0, l_.str.1@PAGE
Lloh217:
	add	x0, x0, l_.str.1@PAGEOFF
Lloh218:
	adrp	x2, l_.str.4@PAGE
Lloh219:
	add	x2, x2, l_.str.4@PAGEOFF
	mov	w1, #2215                       ; =0x8a7
	bl	_ggml_abort
	.loh AdrpAdd	Lloh164, Lloh165
	.loh AdrpAdd	Lloh166, Lloh167
	.loh AdrpAdd	Lloh168, Lloh169
	.loh AdrpAdd	Lloh170, Lloh171
	.loh AdrpAdd	Lloh174, Lloh175
	.loh AdrpAdd	Lloh172, Lloh173
	.loh AdrpAdd	Lloh178, Lloh179
	.loh AdrpAdd	Lloh176, Lloh177
	.loh AdrpAdd	Lloh184, Lloh185
	.loh AdrpAdd	Lloh182, Lloh183
	.loh AdrpAdd	Lloh180, Lloh181
	.loh AdrpAdd	Lloh190, Lloh191
	.loh AdrpAdd	Lloh188, Lloh189
	.loh AdrpAdd	Lloh186, Lloh187
	.loh AdrpAdd	Lloh196, Lloh197
	.loh AdrpAdd	Lloh194, Lloh195
	.loh AdrpAdd	Lloh192, Lloh193
	.loh AdrpAdd	Lloh200, Lloh201
	.loh AdrpAdd	Lloh198, Lloh199
	.loh AdrpAdd	Lloh206, Lloh207
	.loh AdrpAdd	Lloh204, Lloh205
	.loh AdrpLdrGot	Lloh202, Lloh203
	.loh AdrpAdd	Lloh208, Lloh209
	.loh AdrpAdd	Lloh210, Lloh211
	.loh AdrpAdd	Lloh214, Lloh215
	.loh AdrpAdd	Lloh212, Lloh213
	.loh AdrpAdd	Lloh218, Lloh219
	.loh AdrpAdd	Lloh216, Lloh217
	.cfi_endproc
	.section	__TEXT,__const
	.p2align	1, 0x0
lJTI19_0:
	.short	(LBB19_14-LBB19_14)>>2
	.short	(LBB19_15-LBB19_14)>>2
	.short	(LBB19_15-LBB19_14)>>2
	.short	(LBB19_15-LBB19_14)>>2
	.short	(LBB19_15-LBB19_14)>>2
	.short	(LBB19_14-LBB19_14)>>2
	.short	(LBB19_15-LBB19_14)>>2
	.short	(LBB19_15-LBB19_14)>>2
	.short	(LBB19_14-LBB19_14)>>2
	.short	(LBB19_14-LBB19_14)>>2
	.short	(LBB19_14-LBB19_14)>>2
	.short	(LBB19_14-LBB19_14)>>2
	.short	(LBB19_14-LBB19_14)>>2
	.short	(LBB19_14-LBB19_14)>>2
	.short	(LBB19_14-LBB19_14)>>2
	.short	(LBB19_14-LBB19_14)>>2
	.short	(LBB19_14-LBB19_14)>>2
	.short	(LBB19_15-LBB19_14)>>2
	.short	(LBB19_14-LBB19_14)>>2
	.short	(LBB19_14-LBB19_14)>>2
	.short	(LBB19_15-LBB19_14)>>2
	.short	(LBB19_15-LBB19_14)>>2
	.short	(LBB19_15-LBB19_14)>>2
	.short	(LBB19_15-LBB19_14)>>2
	.short	(LBB19_15-LBB19_14)>>2
	.short	(LBB19_15-LBB19_14)>>2
	.short	(LBB19_15-LBB19_14)>>2
	.short	(LBB19_15-LBB19_14)>>2
	.short	(LBB19_15-LBB19_14)>>2
	.short	(LBB19_15-LBB19_14)>>2
	.short	(LBB19_14-LBB19_14)>>2
	.short	(LBB19_14-LBB19_14)>>2
	.short	(LBB19_15-LBB19_14)>>2
	.short	(LBB19_15-LBB19_14)>>2
	.short	(LBB19_14-LBB19_14)>>2
	.short	(LBB19_14-LBB19_14)>>2
	.short	(LBB19_14-LBB19_14)>>2
	.short	(LBB19_14-LBB19_14)>>2
	.short	(LBB19_14-LBB19_14)>>2
	.short	(LBB19_14-LBB19_14)>>2
	.short	(LBB19_14-LBB19_14)>>2
	.short	(LBB19_15-LBB19_14)>>2
	.short	(LBB19_15-LBB19_14)>>2
	.short	(LBB19_58-LBB19_14)>>2
	.short	(LBB19_15-LBB19_14)>>2
	.short	(LBB19_15-LBB19_14)>>2
	.short	(LBB19_15-LBB19_14)>>2
	.short	(LBB19_14-LBB19_14)>>2
	.short	(LBB19_15-LBB19_14)>>2
	.short	(LBB19_15-LBB19_14)>>2
	.short	(LBB19_15-LBB19_14)>>2
	.short	(LBB19_15-LBB19_14)>>2
	.short	(LBB19_15-LBB19_14)>>2
	.short	(LBB19_14-LBB19_14)>>2
	.short	(LBB19_14-LBB19_14)>>2
	.short	(LBB19_14-LBB19_14)>>2
	.short	(LBB19_15-LBB19_14)>>2
	.short	(LBB19_15-LBB19_14)>>2
	.short	(LBB19_15-LBB19_14)>>2
	.short	(LBB19_15-LBB19_14)>>2
	.short	(LBB19_15-LBB19_14)>>2
	.short	(LBB19_15-LBB19_14)>>2
	.short	(LBB19_14-LBB19_14)>>2
	.short	(LBB19_15-LBB19_14)>>2
	.short	(LBB19_15-LBB19_14)>>2
	.short	(LBB19_15-LBB19_14)>>2
	.short	(LBB19_15-LBB19_14)>>2
	.short	(LBB19_14-LBB19_14)>>2
	.short	(LBB19_14-LBB19_14)>>2
	.short	(LBB19_14-LBB19_14)>>2
	.short	(LBB19_15-LBB19_14)>>2
	.short	(LBB19_15-LBB19_14)>>2
	.short	(LBB19_15-LBB19_14)>>2
	.short	(LBB19_15-LBB19_14)>>2
	.short	(LBB19_55-LBB19_14)>>2
	.short	(LBB19_49-LBB19_14)>>2
	.short	(LBB19_49-LBB19_14)>>2
	.short	(LBB19_49-LBB19_14)>>2
	.short	(LBB19_49-LBB19_14)>>2
	.short	(LBB19_15-LBB19_14)>>2
	.short	(LBB19_15-LBB19_14)>>2
	.short	(LBB19_15-LBB19_14)>>2
	.short	(LBB19_70-LBB19_14)>>2
	.p2align	1, 0x0
lJTI19_1:
	.short	(LBB19_20-LBB19_6)>>2
	.short	(LBB19_18-LBB19_6)>>2
	.short	(LBB19_18-LBB19_6)>>2
	.short	(LBB19_28-LBB19_6)>>2
	.short	(LBB19_10-LBB19_6)>>2
	.short	(LBB19_10-LBB19_6)>>2
	.short	(LBB19_10-LBB19_6)>>2
	.short	(LBB19_10-LBB19_6)>>2
	.short	(LBB19_10-LBB19_6)>>2
	.short	(LBB19_10-LBB19_6)>>2
	.short	(LBB19_10-LBB19_6)>>2
	.short	(LBB19_10-LBB19_6)>>2
	.short	(LBB19_10-LBB19_6)>>2
	.short	(LBB19_10-LBB19_6)>>2
	.short	(LBB19_10-LBB19_6)>>2
	.short	(LBB19_10-LBB19_6)>>2
	.short	(LBB19_32-LBB19_6)>>2
	.short	(LBB19_10-LBB19_6)>>2
	.short	(LBB19_10-LBB19_6)>>2
	.short	(LBB19_10-LBB19_6)>>2
	.short	(LBB19_10-LBB19_6)>>2
	.short	(LBB19_10-LBB19_6)>>2
	.short	(LBB19_10-LBB19_6)>>2
	.short	(LBB19_10-LBB19_6)>>2
	.short	(LBB19_10-LBB19_6)>>2
	.short	(LBB19_10-LBB19_6)>>2
	.short	(LBB19_23-LBB19_6)>>2
	.short	(LBB19_25-LBB19_6)>>2
	.short	(LBB19_18-LBB19_6)>>2
	.short	(LBB19_10-LBB19_6)>>2
	.short	(LBB19_10-LBB19_6)>>2
	.short	(LBB19_20-LBB19_6)>>2
	.short	(LBB19_10-LBB19_6)>>2
	.short	(LBB19_10-LBB19_6)>>2
	.short	(LBB19_10-LBB19_6)>>2
	.short	(LBB19_10-LBB19_6)>>2
	.short	(LBB19_10-LBB19_6)>>2
	.short	(LBB19_10-LBB19_6)>>2
	.short	(LBB19_10-LBB19_6)>>2
	.short	(LBB19_10-LBB19_6)>>2
	.short	(LBB19_10-LBB19_6)>>2
	.short	(LBB19_10-LBB19_6)>>2
	.short	(LBB19_6-LBB19_6)>>2
	.short	(LBB19_10-LBB19_6)>>2
	.short	(LBB19_6-LBB19_6)>>2
	.short	(LBB19_6-LBB19_6)>>2
	.short	(LBB19_10-LBB19_6)>>2
	.short	(LBB19_33-LBB19_6)>>2
	.short	(LBB19_10-LBB19_6)>>2
	.short	(LBB19_10-LBB19_6)>>2
	.short	(LBB19_10-LBB19_6)>>2
	.short	(LBB19_31-LBB19_6)>>2
	.short	(LBB19_10-LBB19_6)>>2
	.short	(LBB19_10-LBB19_6)>>2
	.short	(LBB19_10-LBB19_6)>>2
	.short	(LBB19_10-LBB19_6)>>2
	.short	(LBB19_10-LBB19_6)>>2
	.short	(LBB19_10-LBB19_6)>>2
	.short	(LBB19_10-LBB19_6)>>2
	.short	(LBB19_10-LBB19_6)>>2
	.short	(LBB19_10-LBB19_6)>>2
	.short	(LBB19_10-LBB19_6)>>2
	.short	(LBB19_40-LBB19_6)>>2
	.short	(LBB19_41-LBB19_6)>>2
	.short	(LBB19_10-LBB19_6)>>2
	.short	(LBB19_10-LBB19_6)>>2
	.short	(LBB19_10-LBB19_6)>>2
	.short	(LBB19_10-LBB19_6)>>2
	.short	(LBB19_10-LBB19_6)>>2
	.short	(LBB19_10-LBB19_6)>>2
	.short	(LBB19_10-LBB19_6)>>2
	.short	(LBB19_10-LBB19_6)>>2
	.short	(LBB19_10-LBB19_6)>>2
	.short	(LBB19_10-LBB19_6)>>2
	.short	(LBB19_10-LBB19_6)>>2
	.short	(LBB19_10-LBB19_6)>>2
	.short	(LBB19_10-LBB19_6)>>2
	.short	(LBB19_10-LBB19_6)>>2
	.short	(LBB19_22-LBB19_6)>>2
	.short	(LBB19_10-LBB19_6)>>2
	.short	(LBB19_10-LBB19_6)>>2
	.short	(LBB19_66-LBB19_6)>>2
                                        ; -- End function
	.section	__TEXT,__text,regular,pure_instructions
	.globl	_ggml_threadpool_new            ; -- Begin function ggml_threadpool_new
	.p2align	2
_ggml_threadpool_new:                   ; @ggml_threadpool_new
	.cfi_startproc
; %bb.0:
	mov	x1, #0                          ; =0x0
	mov	x2, #0                          ; =0x0
	b	_ggml_threadpool_new_impl
	.cfi_endproc
                                        ; -- End function
	.p2align	2                               ; -- Begin function ggml_threadpool_new_impl
_ggml_threadpool_new_impl:              ; @ggml_threadpool_new_impl
	.cfi_startproc
; %bb.0:
	sub	sp, sp, #128
	stp	x28, x27, [sp, #32]             ; 16-byte Folded Spill
	stp	x26, x25, [sp, #48]             ; 16-byte Folded Spill
	stp	x24, x23, [sp, #64]             ; 16-byte Folded Spill
	stp	x22, x21, [sp, #80]             ; 16-byte Folded Spill
	stp	x20, x19, [sp, #96]             ; 16-byte Folded Spill
	stp	x29, x30, [sp, #112]            ; 16-byte Folded Spill
	add	x29, sp, #112
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	.cfi_offset w23, -56
	.cfi_offset w24, -64
	.cfi_offset w25, -72
	.cfi_offset w26, -80
	.cfi_offset w27, -88
	.cfi_offset w28, -96
	mov	x21, x2
	mov	x22, x1
	mov	x20, x0
	mov	w0, #384                        ; =0x180
	bl	_ggml_aligned_malloc
	mov	x19, x0
	stp	x22, x21, [x0, #112]
	add	x8, x0, #128
	stlr	wzr, [x8]
	add	x8, x0, #192
	stlr	wzr, [x8]
	add	x8, x0, #256
	stlr	wzr, [x8]
	add	x8, x0, #320
	stlr	wzr, [x8]
	add	x8, x0, #324
	stlrb	wzr, [x8]
	ldrb	w8, [x20, #525]
	add	x9, x0, #325
	stlrb	w8, [x9]
	add	x8, x0, #328
	mov	w9, #-1                         ; =0xffffffff
	stlr	w9, [x8]
	str	xzr, [x0, #336]
	ldrsw	x8, [x20, #512]
	str	w8, [x0, #344]
	add	x9, x0, #348
	stlr	w8, [x9]
	add	x9, x20, #516
	ldr	d0, [x9]
	str	d0, [x0, #352]
	str	wzr, [x0, #360]
	add	x8, x8, x8, lsl #4
	lsl	x22, x8, #5
	mov	x0, x22
	bl	_ggml_aligned_malloc
	mov	x21, x0
	mov	x1, x22
	bl	_bzero
	ldr	w8, [x20, #512]
	cmp	w8, #1
	b.lt	LBB21_8
; %bb.1:
	cmp	w8, #3
	b.hi	LBB21_3
; %bb.2:
	mov	x9, #0                          ; =0x0
	b	LBB21_6
LBB21_3:
	mov	w10, #0                         ; =0x0
	mov	x11, #0                         ; =0x0
	and	x9, x8, #0x7ffffffc
	ubfx	x12, x8, #2, #29
	add	x12, x12, x12, lsl #4
	lsl	x12, x12, #7
LBB21_4:                                ; =>This Inner Loop Header: Depth=1
	add	x13, x21, x11
	str	x19, [x13, #528]
	add	w14, w10, #1
	add	w15, w10, #2
	str	x19, [x13, #1072]
	add	w16, w10, #3
	str	x19, [x13, #1616]
	str	x19, [x13, #2160]
	str	w10, [x13, #536]
	str	w14, [x13, #1080]
	str	w15, [x13, #1624]
	add	x11, x11, #2176
	add	w10, w10, #4
	str	w16, [x13, #2168]
	cmp	x12, x11
	b.ne	LBB21_4
; %bb.5:
	cmp	x9, x8
	b.eq	LBB21_8
LBB21_6:
	mov	w10, #544                       ; =0x220
	umaddl	x10, w9, w10, x21
	add	x10, x10, #536
LBB21_7:                                ; =>This Inner Loop Header: Depth=1
	stur	x19, [x10, #-8]
	str	w9, [x10]
	add	x9, x9, #1
	add	x10, x10, #544
	cmp	x8, x9
	b.ne	LBB21_7
LBB21_8:
	str	x21, [x19, #336]
	mov	x0, x19
	mov	x1, #0                          ; =0x0
	bl	_pthread_mutex_init
	add	x0, x19, #64
	mov	x1, #0                          ; =0x0
	bl	_pthread_cond_init
	ldr	w8, [x20, #512]
	cmp	w8, #1
	b.le	LBB21_18
; %bb.9:
	mov	w24, #0                         ; =0x0
	mov	w25, #1                         ; =0x1
	mov	w26, #544                       ; =0x220
	mov	w27, #1                         ; =0x1
Lloh220:
	adrp	x22, _ggml_graph_compute_secondary_thread@PAGE
Lloh221:
	add	x22, x22, _ggml_graph_compute_secondary_thread@PAGEOFF
LBB21_10:                               ; =>This Loop Header: Depth=1
                                        ;     Child Loop BB21_12 Depth 2
	madd	x23, x27, x26, x21
	add	x0, x23, #8
	ldrb	w8, [x20, #524]
	tbz	w8, #0, LBB21_14
; %bb.11:                               ;   in Loop: Header=BB21_10 Depth=1
	movi.2d	v0, #0000000000000000
	stp	q0, q0, [x0, #480]
	stp	q0, q0, [x0, #448]
	stp	q0, q0, [x0, #416]
	stp	q0, q0, [x0, #384]
	stp	q0, q0, [x0, #352]
	stp	q0, q0, [x0, #320]
	stp	q0, q0, [x0, #288]
	stp	q0, q0, [x0, #256]
	stp	q0, q0, [x0, #224]
	stp	q0, q0, [x0, #192]
	stp	q0, q0, [x0, #160]
	stp	q0, q0, [x0, #128]
	stp	q0, q0, [x0, #96]
	stp	q0, q0, [x0, #64]
	stp	q0, q0, [x0, #32]
	mov	w8, #512                        ; =0x200
	mov	x9, x24
	stp	q0, q0, [x0]
LBB21_12:                               ;   Parent Loop BB21_10 Depth=1
                                        ; =>  This Inner Loop Header: Depth=2
	sub	w10, w9, #512
	cmp	w9, #511
	csel	w10, w10, w9, gt
	sxtw	x10, w10
	ldrb	w11, [x20, x10]
	cmp	w11, #1
	b.eq	LBB21_15
; %bb.13:                               ;   in Loop: Header=BB21_12 Depth=2
	add	w9, w9, #1
	subs	w8, w8, #1
	b.ne	LBB21_12
	b	LBB21_16
LBB21_14:                               ;   in Loop: Header=BB21_10 Depth=1
	mov	x1, x20
	mov	w2, #512                        ; =0x200
	bl	_memcpy
	b	LBB21_16
LBB21_15:                               ;   in Loop: Header=BB21_10 Depth=1
	strb	w25, [x0, x10]
	add	w24, w10, #1
LBB21_16:                               ;   in Loop: Header=BB21_10 Depth=1
	mov	x0, x23
	mov	x1, #0                          ; =0x0
	mov	x2, x22
	mov	x3, x23
	bl	_pthread_create
	cbnz	w0, LBB21_38
; %bb.17:                               ;   in Loop: Header=BB21_10 Depth=1
	add	x27, x27, #1
	ldrsw	x8, [x20, #512]
	cmp	x27, x8
	b.lt	LBB21_10
	b	LBB21_19
LBB21_18:
	mov	w24, #0                         ; =0x0
LBB21_19:
	add	x0, x21, #8
	ldrb	w8, [x20, #524]
	tbz	w8, #0, LBB21_23
; %bb.20:
	movi.2d	v0, #0000000000000000
	stp	q0, q0, [x0, #480]
	stp	q0, q0, [x0, #448]
	stp	q0, q0, [x0, #416]
	stp	q0, q0, [x0, #384]
	stp	q0, q0, [x0, #352]
	stp	q0, q0, [x0, #320]
	stp	q0, q0, [x0, #288]
	stp	q0, q0, [x0, #256]
	stp	q0, q0, [x0, #224]
	stp	q0, q0, [x0, #192]
	stp	q0, q0, [x0, #160]
	stp	q0, q0, [x0, #128]
	stp	q0, q0, [x0, #96]
	stp	q0, q0, [x0, #64]
	stp	q0, q0, [x0, #32]
	mov	w8, #512                        ; =0x200
	stp	q0, q0, [x0]
LBB21_21:                               ; =>This Inner Loop Header: Depth=1
	sub	w9, w24, #512
	cmp	w24, #511
	csel	w9, w9, w24, gt
	ldrb	w10, [x20, w9, sxtw]
	cmp	w10, #1
	b.eq	LBB21_24
; %bb.22:                               ;   in Loop: Header=BB21_21 Depth=1
	add	w24, w24, #1
	subs	w8, w8, #1
	b.ne	LBB21_21
	b	LBB21_25
LBB21_23:
	mov	x1, x20
	mov	w2, #512                        ; =0x200
	bl	_memcpy
	b	LBB21_25
LBB21_24:
	mov	w8, #1                          ; =0x1
	strb	w8, [x0, w9, sxtw]
LBB21_25:
	add	x8, x19, #325
	ldarb	w8, [x8]
	tbnz	w8, #0, LBB21_37
; %bb.26:
	ldr	w22, [x19, #352]
	mov	w20, #1                         ; =0x1
	cmp	w22, #1
	b.gt	LBB21_30
; %bb.27:
	cbz	w22, LBB21_37
; %bb.28:
	cmp	w22, #1
	b.ne	LBB21_35
; %bb.29:
	mov	w8, #40                         ; =0x28
	b	LBB21_34
LBB21_30:
	cmp	w22, #2
	b.eq	LBB21_33
; %bb.31:
	cmp	w22, #3
	b.ne	LBB21_35
; %bb.32:
	mov	w8, #90                         ; =0x5a
	b	LBB21_34
LBB21_33:
	mov	w8, #80                         ; =0x50
LBB21_34:
	str	w8, [sp, #24]
	mov	w20, #4                         ; =0x4
LBB21_35:
	bl	_pthread_self
	add	x2, sp, #24
	mov	x1, x20
	bl	_pthread_setschedparam
	cbz	w0, LBB21_37
; %bb.36:
	mov	x20, x0
Lloh222:
	adrp	x8, ___stderrp@GOTPAGE
Lloh223:
	ldr	x8, [x8, ___stderrp@GOTPAGEOFF]
Lloh224:
	ldr	x21, [x8]
	bl	_strerror
	stp	x0, x20, [sp, #8]
	str	x22, [sp]
Lloh225:
	adrp	x1, l_.str.25@PAGE
Lloh226:
	add	x1, x1, l_.str.25@PAGEOFF
	mov	x0, x21
	bl	_fprintf
LBB21_37:
	mov	x0, x19
	ldp	x29, x30, [sp, #112]            ; 16-byte Folded Reload
	ldp	x20, x19, [sp, #96]             ; 16-byte Folded Reload
	ldp	x22, x21, [sp, #80]             ; 16-byte Folded Reload
	ldp	x24, x23, [sp, #64]             ; 16-byte Folded Reload
	ldp	x26, x25, [sp, #48]             ; 16-byte Folded Reload
	ldp	x28, x27, [sp, #32]             ; 16-byte Folded Reload
	add	sp, sp, #128
	ret
LBB21_38:
Lloh227:
	adrp	x8, l_.str.24@PAGE
Lloh228:
	add	x8, x8, l_.str.24@PAGEOFF
Lloh229:
	adrp	x0, l_.str.1@PAGE
Lloh230:
	add	x0, x0, l_.str.1@PAGEOFF
	str	x8, [sp]
Lloh231:
	adrp	x2, l_.str.2@PAGE
Lloh232:
	add	x2, x2, l_.str.2@PAGEOFF
	mov	w1, #3078                       ; =0xc06
	bl	_ggml_abort
	.loh AdrpAdd	Lloh220, Lloh221
	.loh AdrpAdd	Lloh225, Lloh226
	.loh AdrpLdrGotLdr	Lloh222, Lloh223, Lloh224
	.loh AdrpAdd	Lloh231, Lloh232
	.loh AdrpAdd	Lloh229, Lloh230
	.loh AdrpAdd	Lloh227, Lloh228
	.cfi_endproc
                                        ; -- End function
	.globl	_ggml_graph_compute             ; -- Begin function ggml_graph_compute
	.p2align	2
_ggml_graph_compute:                    ; @ggml_graph_compute
	.cfi_startproc
; %bb.0:
	stp	x24, x23, [sp, #-64]!           ; 16-byte Folded Spill
	stp	x22, x21, [sp, #16]             ; 16-byte Folded Spill
	stp	x20, x19, [sp, #32]             ; 16-byte Folded Spill
	stp	x29, x30, [sp, #48]             ; 16-byte Folded Spill
	add	x29, sp, #48
	sub	sp, sp, #560
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	.cfi_offset w23, -56
	.cfi_offset w24, -64
	mov	x19, x1
	mov	x21, x0
Lloh233:
	adrp	x8, ___stack_chk_guard@GOTPAGE
Lloh234:
	ldr	x8, [x8, ___stack_chk_guard@GOTPAGEOFF]
Lloh235:
	ldr	x8, [x8]
	stur	x8, [x29, #-56]
	bl	_ggml_cpu_init
	cbz	x19, LBB22_26
; %bb.1:
	ldr	w20, [x19, #16]
	cmp	w20, #0
	b.le	LBB22_27
; %bb.2:
	ldr	x8, [x19]
	cbz	x8, LBB22_4
; %bb.3:
	ldr	x8, [x19, #8]
	cbz	x8, LBB22_29
LBB22_4:
	ldr	x22, [x19, #24]
	cbz	x22, LBB22_6
; %bb.5:
	stp	x21, x19, [x22, #112]
	add	x8, x22, #320
	stlr	wzr, [x8]
	add	x8, x22, #328
	mov	w9, #-1                         ; =0xffffffff
	stlr	w9, [x8]
	mov	x19, x22
	str	wzr, [x22, #360]
	b	LBB22_7
LBB22_6:
	add	x8, sp, #24
	mov	x0, x20
	bl	_ggml_threadpool_params_default
	add	x0, sp, #24
	mov	x1, x21
	mov	x2, x19
	bl	_ggml_threadpool_new_impl
	mov	x19, x0
LBB22_7:
	ldr	w8, [x19, #344]
	cmp	w20, w8
	b.le	LBB22_9
; %bb.8:
	stp	x20, x8, [sp]
Lloh236:
	adrp	x1, l_.str.18@PAGE
Lloh237:
	add	x1, x1, l_.str.18@PAGEOFF
	mov	w0, #3                          ; =0x3
	bl	_ggml_log_internal
	ldr	w20, [x19, #344]
LBB22_9:
	mov	x0, x19
	bl	_pthread_mutex_lock
	str	w20, [x19, #348]
	add	x8, x19, #128
	mov	w9, #1                          ; =0x1
	ldaddal	w9, w8, [x8]
	add	x8, x19, #325
	ldarb	w8, [x8]
	tbz	w8, #0, LBB22_22
; %bb.10:
	ldr	w23, [x19, #352]
	mov	w20, #1                         ; =0x1
	cmp	w23, #1
	b.gt	LBB22_14
; %bb.11:
	cbz	w23, LBB22_21
; %bb.12:
	cmp	w23, #1
	b.ne	LBB22_19
; %bb.13:
	mov	w8, #40                         ; =0x28
	b	LBB22_18
LBB22_14:
	cmp	w23, #2
	b.eq	LBB22_17
; %bb.15:
	cmp	w23, #3
	b.ne	LBB22_19
; %bb.16:
	mov	w8, #90                         ; =0x5a
	b	LBB22_18
LBB22_17:
	mov	w8, #80                         ; =0x50
LBB22_18:
	str	w8, [sp, #24]
	mov	w20, #4                         ; =0x4
LBB22_19:
	bl	_pthread_self
	add	x2, sp, #24
	mov	x1, x20
	bl	_pthread_setschedparam
	cbz	w0, LBB22_21
; %bb.20:
	mov	x20, x0
Lloh238:
	adrp	x8, ___stderrp@GOTPAGE
Lloh239:
	ldr	x8, [x8, ___stderrp@GOTPAGEOFF]
Lloh240:
	ldr	x21, [x8]
	bl	_strerror
	stp	x0, x20, [sp, #8]
	str	x23, [sp]
Lloh241:
	adrp	x1, l_.str.25@PAGE
Lloh242:
	add	x1, x1, l_.str.25@PAGEOFF
	mov	x0, x21
	bl	_fprintf
LBB22_21:
	add	x8, x19, #325
	stlrb	wzr, [x8]
LBB22_22:
	add	x0, x19, #64
	bl	_pthread_cond_broadcast
	mov	x0, x19
	bl	_pthread_mutex_unlock
	ldr	x0, [x19, #336]
	bl	_ggml_graph_compute_thread
	ldr	w20, [x19, #360]
	cbnz	x22, LBB22_24
; %bb.23:
	mov	x0, x19
	bl	_ggml_threadpool_free
LBB22_24:
	ldur	x8, [x29, #-56]
Lloh243:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh244:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh245:
	ldr	x9, [x9]
	cmp	x9, x8
	b.ne	LBB22_28
; %bb.25:
	mov	x0, x20
	add	sp, sp, #560
	ldp	x29, x30, [sp, #48]             ; 16-byte Folded Reload
	ldp	x20, x19, [sp, #32]             ; 16-byte Folded Reload
	ldp	x22, x21, [sp, #16]             ; 16-byte Folded Reload
	ldp	x24, x23, [sp], #64             ; 16-byte Folded Reload
	ret
LBB22_26:
Lloh246:
	adrp	x8, l_.str.15@PAGE
Lloh247:
	add	x8, x8, l_.str.15@PAGEOFF
Lloh248:
	adrp	x0, l_.str.1@PAGE
Lloh249:
	add	x0, x0, l_.str.1@PAGEOFF
	str	x8, [sp]
Lloh250:
	adrp	x2, l_.str.2@PAGE
Lloh251:
	add	x2, x2, l_.str.2@PAGEOFF
	mov	w1, #3102                       ; =0xc1e
	bl	_ggml_abort
LBB22_27:
Lloh252:
	adrp	x8, l_.str.16@PAGE
Lloh253:
	add	x8, x8, l_.str.16@PAGEOFF
Lloh254:
	adrp	x0, l_.str.1@PAGE
Lloh255:
	add	x0, x0, l_.str.1@PAGEOFF
	str	x8, [sp]
Lloh256:
	adrp	x2, l_.str.2@PAGE
Lloh257:
	add	x2, x2, l_.str.2@PAGEOFF
	mov	w1, #3103                       ; =0xc1f
	bl	_ggml_abort
LBB22_28:
	bl	___stack_chk_fail
LBB22_29:
Lloh258:
	adrp	x8, l_.str.17@PAGE
Lloh259:
	add	x8, x8, l_.str.17@PAGEOFF
Lloh260:
	adrp	x0, l_.str.1@PAGE
Lloh261:
	add	x0, x0, l_.str.1@PAGEOFF
	str	x8, [sp]
Lloh262:
	adrp	x2, l_.str.2@PAGE
Lloh263:
	add	x2, x2, l_.str.2@PAGEOFF
	mov	w1, #3104                       ; =0xc20
	bl	_ggml_abort
	.loh AdrpLdrGotLdr	Lloh233, Lloh234, Lloh235
	.loh AdrpAdd	Lloh236, Lloh237
	.loh AdrpAdd	Lloh241, Lloh242
	.loh AdrpLdrGotLdr	Lloh238, Lloh239, Lloh240
	.loh AdrpLdrGotLdr	Lloh243, Lloh244, Lloh245
	.loh AdrpAdd	Lloh250, Lloh251
	.loh AdrpAdd	Lloh248, Lloh249
	.loh AdrpAdd	Lloh246, Lloh247
	.loh AdrpAdd	Lloh256, Lloh257
	.loh AdrpAdd	Lloh254, Lloh255
	.loh AdrpAdd	Lloh252, Lloh253
	.loh AdrpAdd	Lloh262, Lloh263
	.loh AdrpAdd	Lloh260, Lloh261
	.loh AdrpAdd	Lloh258, Lloh259
	.cfi_endproc
                                        ; -- End function
	.globl	_ggml_cpu_init                  ; -- Begin function ggml_cpu_init
	.p2align	2
_ggml_cpu_init:                         ; @ggml_cpu_init
	.cfi_startproc
; %bb.0:
	sub	sp, sp, #144
	stp	d15, d14, [sp, #32]             ; 16-byte Folded Spill
	stp	d13, d12, [sp, #48]             ; 16-byte Folded Spill
	stp	d11, d10, [sp, #64]             ; 16-byte Folded Spill
	stp	d9, d8, [sp, #80]               ; 16-byte Folded Spill
	stp	x22, x21, [sp, #96]             ; 16-byte Folded Spill
	stp	x20, x19, [sp, #112]            ; 16-byte Folded Spill
	stp	x29, x30, [sp, #128]            ; 16-byte Folded Spill
	add	x29, sp, #128
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	.cfi_offset b8, -56
	.cfi_offset b9, -64
	.cfi_offset b10, -72
	.cfi_offset b11, -80
	.cfi_offset b12, -88
	.cfi_offset b13, -96
	.cfi_offset b14, -104
	.cfi_offset b15, -112
	stp	xzr, xzr, [sp]
	str	xzr, [sp, #16]
	mov	x0, sp
	bl	_ggml_init
	bl	_ggml_free
	bl	_ggml_critical_section_start
	adrp	x19, _ggml_cpu_init.is_first_call@PAGE
	ldrb	w8, [x19, _ggml_cpu_init.is_first_call@PAGEOFF]
	tbnz	w8, #0, LBB23_13
; %bb.1:
	bl	_ggml_time_us
	mov	x20, #0                         ; =0x0
	fmov	s8, #0.50000000
	mov	w8, #16938                      ; =0x422a
	movk	w8, #16204, lsl #16
	fmov	s9, w8
	mov	w8, #10003                      ; =0x2713
	movk	w8, #15671, lsl #16
	fmov	s10, w8
	fmov	s11, #1.00000000
Lloh264:
	adrp	x21, _ggml_table_gelu_f16@GOTPAGE
Lloh265:
	ldr	x21, [x21, _ggml_table_gelu_f16@GOTPAGEOFF]
	mov	w8, #56099                      ; =0xdb23
	movk	w8, #49113, lsl #16
	fmov	s12, w8
Lloh266:
	adrp	x22, _ggml_table_gelu_quick_f16@GOTPAGE
Lloh267:
	ldr	x22, [x22, _ggml_table_gelu_quick_f16@GOTPAGEOFF]
LBB23_2:                                ; =>This Inner Loop Header: Depth=1
	fmov	s0, w20
	fcvt	s13, h0
	fmul	s14, s13, s8
	fmul	s0, s13, s9
	fmul	s1, s13, s10
	fmadd	s1, s1, s13, s11
	fmul	s0, s0, s1
	bl	_tanhf
	fadd	s0, s0, s11
	fmul	s0, s14, s0
	fcvt	h0, s0
	str	h0, [x21, x20, lsl #1]
	fmul	s0, s13, s12
	bl	_expf
	fadd	s0, s0, s11
	fdiv	s0, s11, s0
	fmul	s0, s0, s13
	fcvt	h0, s0
	str	h0, [x22, x20, lsl #1]
	add	x20, x20, #1
	cmp	x20, #16, lsl #12               ; =65536
	b.ne	LBB23_2
; %bb.3:
	bl	_ggml_time_us
	str	wzr, [sp, #28]
	mov	w8, #4                          ; =0x4
	str	x8, [sp]
Lloh268:
	adrp	x0, l_.str.42@PAGE
Lloh269:
	add	x0, x0, l_.str.42@PAGEOFF
	add	x1, sp, #28
	mov	x2, sp
	mov	x3, #0                          ; =0x0
	mov	x4, #0                          ; =0x0
	bl	_sysctlbyname
	cbz	w0, LBB23_5
; %bb.4:
	mov	w8, #0                          ; =0x0
	str	wzr, [sp, #28]
	b	LBB23_6
LBB23_5:
	ldr	w8, [sp, #28]
LBB23_6:
	adrp	x9, _ggml_arm_arch_features@PAGE
	str	w8, [x9, _ggml_arm_arch_features@PAGEOFF]
Lloh270:
	adrp	x0, l_.str.43@PAGE
Lloh271:
	add	x0, x0, l_.str.43@PAGEOFF
	add	x1, sp, #28
	mov	x2, sp
	mov	x3, #0                          ; =0x0
	mov	x4, #0                          ; =0x0
	bl	_sysctlbyname
	cbz	w0, LBB23_8
; %bb.7:
	mov	w8, #0                          ; =0x0
	str	wzr, [sp, #28]
	b	LBB23_9
LBB23_8:
	ldr	w8, [sp, #28]
LBB23_9:
	adrp	x9, _ggml_arm_arch_features@PAGE+4
	str	w8, [x9, _ggml_arm_arch_features@PAGEOFF+4]
Lloh272:
	adrp	x0, l_.str.44@PAGE
Lloh273:
	add	x0, x0, l_.str.44@PAGEOFF
	add	x1, sp, #28
	mov	x2, sp
	mov	x3, #0                          ; =0x0
	mov	x4, #0                          ; =0x0
	bl	_sysctlbyname
	cbz	w0, LBB23_11
; %bb.10:
	mov	w8, #0                          ; =0x0
	str	wzr, [sp, #28]
	b	LBB23_12
LBB23_11:
	ldr	w8, [sp, #28]
LBB23_12:
Lloh274:
	adrp	x20, _ggml_arm_arch_features@PAGE+8
Lloh275:
	add	x20, x20, _ggml_arm_arch_features@PAGEOFF+8
	str	w8, [x20]
Lloh276:
	adrp	x0, l_.str.45@PAGE
Lloh277:
	add	x0, x0, l_.str.45@PAGEOFF
	add	x1, sp, #28
	mov	x2, sp
	mov	x3, #0                          ; =0x0
	mov	x4, #0                          ; =0x0
	bl	_sysctlbyname
	ldr	w8, [sp, #28]
	cmp	w0, #0
	csel	w8, w8, wzr, eq
	stp	wzr, w8, [x20, #8]
	str	wzr, [x20, #4]
	mov	w8, #1                          ; =0x1
	strb	w8, [x19, _ggml_cpu_init.is_first_call@PAGEOFF]
LBB23_13:
	bl	_ggml_critical_section_end
	ldp	x29, x30, [sp, #128]            ; 16-byte Folded Reload
	ldp	x20, x19, [sp, #112]            ; 16-byte Folded Reload
	ldp	x22, x21, [sp, #96]             ; 16-byte Folded Reload
	ldp	d9, d8, [sp, #80]               ; 16-byte Folded Reload
	ldp	d11, d10, [sp, #64]             ; 16-byte Folded Reload
	ldp	d13, d12, [sp, #48]             ; 16-byte Folded Reload
	ldp	d15, d14, [sp, #32]             ; 16-byte Folded Reload
	add	sp, sp, #144
	ret
	.loh AdrpLdrGot	Lloh266, Lloh267
	.loh AdrpLdrGot	Lloh264, Lloh265
	.loh AdrpAdd	Lloh268, Lloh269
	.loh AdrpAdd	Lloh270, Lloh271
	.loh AdrpAdd	Lloh272, Lloh273
	.loh AdrpAdd	Lloh276, Lloh277
	.loh AdrpAdd	Lloh274, Lloh275
	.cfi_endproc
                                        ; -- End function
	.p2align	2                               ; -- Begin function ggml_graph_compute_thread
_ggml_graph_compute_thread:             ; @ggml_graph_compute_thread
	.cfi_startproc
; %bb.0:
	stp	x28, x27, [sp, #-96]!           ; 16-byte Folded Spill
	stp	x26, x25, [sp, #16]             ; 16-byte Folded Spill
	stp	x24, x23, [sp, #32]             ; 16-byte Folded Spill
	stp	x22, x21, [sp, #48]             ; 16-byte Folded Spill
	stp	x20, x19, [sp, #64]             ; 16-byte Folded Spill
	stp	x29, x30, [sp, #80]             ; 16-byte Folded Spill
	add	x29, sp, #80
	sub	sp, sp, #688
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	.cfi_offset w23, -56
	.cfi_offset w24, -64
	.cfi_offset w25, -72
	.cfi_offset w26, -80
	.cfi_offset w27, -88
	.cfi_offset w28, -96
	mov	x25, x0
Lloh278:
	adrp	x8, ___stack_chk_guard@GOTPAGE
Lloh279:
	ldr	x8, [x8, ___stack_chk_guard@GOTPAGEOFF]
Lloh280:
	ldr	x8, [x8]
	stur	x8, [x29, #-96]
	ldr	x26, [x0, #528]
	ldr	w8, [x26, #352]
	cmp	w8, #1
	b.lt	LBB24_3
; %bb.1:
	mov	w0, #25                         ; =0x19
	mov	w1, #0                          ; =0x0
	bl	_pthread_set_qos_class_self_np
	cbz	w0, LBB24_3
; %bb.2:
	mov	x19, x0
Lloh281:
	adrp	x8, ___stderrp@GOTPAGE
Lloh282:
	ldr	x8, [x8, ___stderrp@GOTPAGEOFF]
Lloh283:
	ldr	x20, [x8]
	bl	_strerror
	stp	x0, x19, [sp]
Lloh284:
	adrp	x1, l_.str.26@PAGE
Lloh285:
	add	x1, x1, l_.str.26@PAGEOFF
	mov	x0, x20
	bl	_fprintf
LBB24_3:
	ldp	x22, x23, [x26, #112]
	ldr	w9, [x25, #536]
	ldr	w8, [x26, #348]
	stp	w9, w8, [x29, #-256]
	ldr	x8, [x23]
	stur	x8, [x29, #-248]
	ldr	x8, [x23, #8]
	stp	x8, x26, [x29, #-240]
	ldr	w8, [x22, #4]
	cmp	w8, #1
	b.lt	LBB24_218
; %bb.4:
	mov	x24, #0                         ; =0x0
	sub	x8, x29, #256
	add	x8, x8, #16
	str	x8, [sp, #128]                  ; 8-byte Folded Spill
	mov	w19, #1                         ; =0x1
Lloh286:
	adrp	x20, lJTI24_0@PAGE
Lloh287:
	add	x20, x20, lJTI24_0@PAGEOFF
	b	LBB24_7
LBB24_5:                                ;   in Loop: Header=BB24_7 Depth=1
	dmb	ish
LBB24_6:                                ;   in Loop: Header=BB24_7 Depth=1
	ldrsw	x8, [x22, #4]
	cmp	x24, x8
	b.ge	LBB24_218
LBB24_7:                                ; =>This Loop Header: Depth=1
                                        ;     Child Loop BB24_146 Depth 2
                                        ;       Child Loop BB24_149 Depth 3
                                        ;         Child Loop BB24_151 Depth 4
                                        ;     Child Loop BB24_164 Depth 2
                                        ;       Child Loop BB24_166 Depth 3
                                        ;     Child Loop BB24_155 Depth 2
                                        ;     Child Loop BB24_159 Depth 2
                                        ;     Child Loop BB24_173 Depth 2
                                        ;       Child Loop BB24_178 Depth 3
                                        ;         Child Loop BB24_180 Depth 4
                                        ;           Child Loop BB24_181 Depth 5
                                        ;             Child Loop BB24_186 Depth 6
                                        ;     Child Loop BB24_116 Depth 2
                                        ;       Child Loop BB24_119 Depth 3
                                        ;         Child Loop BB24_121 Depth 4
                                        ;     Child Loop BB24_137 Depth 2
                                        ;     Child Loop BB24_192 Depth 2
                                        ;       Child Loop BB24_202 Depth 3
                                        ;         Child Loop BB24_204 Depth 4
                                        ;           Child Loop BB24_206 Depth 5
                                        ;             Child Loop BB24_211 Depth 6
                                        ;             Child Loop BB24_214 Depth 6
                                        ;     Child Loop BB24_16 Depth 2
	ldr	w8, [x26, #328]
	cmp	x24, x8
	b.eq	LBB24_218
; %bb.8:                                ;   in Loop: Header=BB24_7 Depth=1
	ldr	x8, [x22, #16]
	ldr	x27, [x8, x24, lsl #3]
	ldr	w8, [x27, #80]
	cbz	w8, LBB24_11
; %bb.9:                                ;   in Loop: Header=BB24_7 Depth=1
	mov	x0, x27
	bl	_ggml_is_empty
	tbnz	w0, #0, LBB24_11
; %bb.10:                               ;   in Loop: Header=BB24_7 Depth=1
	sub	x0, x29, #256
	mov	x1, x27
	bl	_ggml_cpu_extra_compute_forward
	tbz	w0, #0, LBB24_21
LBB24_11:                               ;   in Loop: Header=BB24_7 Depth=1
	ldr	w8, [x25, #536]
	cbz	w8, LBB24_18
LBB24_12:                               ;   in Loop: Header=BB24_7 Depth=1
	add	x24, x24, #1
	ldrsw	x8, [x22, #4]
	cmp	x24, x8
	b.ge	LBB24_6
; %bb.13:                               ;   in Loop: Header=BB24_7 Depth=1
	ldr	x8, [x25, #528]
	ldr	w9, [x8, #348]
	subs	w10, w9, #1
	b.eq	LBB24_6
; %bb.14:                               ;   in Loop: Header=BB24_7 Depth=1
	ldr	w9, [x8, #256]
	add	x11, x8, #192
	ldaddal	w19, w11, [x11]
	cmp	w11, w10
	b.ne	LBB24_16
; %bb.15:                               ;   in Loop: Header=BB24_7 Depth=1
	str	wzr, [x8, #192]
	add	x8, x8, #256
	ldaddal	w19, w8, [x8]
	b	LBB24_6
LBB24_16:                               ;   Parent Loop BB24_7 Depth=1
                                        ; =>  This Inner Loop Header: Depth=2
	ldr	w10, [x8, #256]
	cmp	w10, w9
	b.ne	LBB24_5
; %bb.17:                               ;   in Loop: Header=BB24_16 Depth=2
	; InlineAsm Start
	yield
	; InlineAsm End
	b	LBB24_16
LBB24_18:                               ;   in Loop: Header=BB24_7 Depth=1
	ldr	x8, [x23, #32]
	cbz	x8, LBB24_12
; %bb.19:                               ;   in Loop: Header=BB24_7 Depth=1
	ldr	x0, [x23, #40]
	blr	x8
	cbz	w0, LBB24_12
; %bb.20:                               ;   in Loop: Header=BB24_7 Depth=1
	add	w8, w24, #1
	str	w8, [x26, #328]
	str	w19, [x26, #360]
	b	LBB24_12
LBB24_21:                               ;   in Loop: Header=BB24_7 Depth=1
	ldr	w8, [x27, #80]
	sub	w8, w8, #1
	cmp	w8, #81
	b.hi	LBB24_11
; %bb.22:                               ;   in Loop: Header=BB24_7 Depth=1
Ltmp0:
	adr	x9, Ltmp0
	ldrsw	x10, [x20, x8, lsl #2]
	add	x9, x9, x10
	str	x27, [sp, #424]                 ; 8-byte Folded Spill
	br	x9
LBB24_23:                               ;   in Loop: Header=BB24_7 Depth=1
	sub	x0, x29, #256
	mov	x1, x27
	bl	_ggml_compute_forward_dup
	b	LBB24_11
LBB24_24:                               ;   in Loop: Header=BB24_7 Depth=1
	sub	x0, x29, #256
	mov	x1, x27
	bl	_ggml_compute_forward_cross_entropy_loss_back
	b	LBB24_11
LBB24_25:                               ;   in Loop: Header=BB24_7 Depth=1
	sub	x0, x29, #256
	mov	x1, x27
	bl	_ggml_compute_forward_rwkv_wkv6
	b	LBB24_11
LBB24_26:                               ;   in Loop: Header=BB24_7 Depth=1
	sub	x0, x29, #256
	mov	x1, x27
	bl	_ggml_compute_forward_custom
	b	LBB24_11
LBB24_27:                               ;   in Loop: Header=BB24_7 Depth=1
	sub	x0, x29, #256
	mov	x1, x27
	bl	_ggml_compute_forward_conv_2d_dw
	b	LBB24_11
LBB24_28:                               ;   in Loop: Header=BB24_7 Depth=1
	sub	x0, x29, #256
	mov	x1, x27
	bl	_ggml_compute_forward_soft_max_ext_back
	b	LBB24_11
LBB24_29:                               ;   in Loop: Header=BB24_7 Depth=1
	sub	x0, x29, #256
	mov	x1, x27
	bl	_ggml_compute_forward_win_part
	b	LBB24_11
LBB24_30:                               ;   in Loop: Header=BB24_7 Depth=1
	sub	x0, x29, #256
	mov	x1, x27
	bl	_ggml_compute_forward_get_rows
	b	LBB24_11
LBB24_31:                               ;   in Loop: Header=BB24_7 Depth=1
	sub	x0, x29, #256
	mov	x1, x27
	bl	_ggml_compute_forward_conv_transpose_1d
	b	LBB24_11
LBB24_32:                               ;   in Loop: Header=BB24_7 Depth=1
	sub	x0, x29, #256
	mov	x1, x27
	bl	_ggml_compute_forward_pool_2d
	b	LBB24_11
LBB24_33:                               ;   in Loop: Header=BB24_7 Depth=1
	sub	x0, x29, #256
	mov	x1, x27
	bl	_ggml_compute_forward_gla
	b	LBB24_11
LBB24_34:                               ;   in Loop: Header=BB24_7 Depth=1
	sub	x0, x29, #256
	mov	x1, x27
	bl	_ggml_compute_forward_opt_step_adamw
	b	LBB24_11
LBB24_35:                               ;   in Loop: Header=BB24_7 Depth=1
	sub	x0, x29, #256
	mov	x1, x27
	bl	_ggml_compute_forward_pad
	b	LBB24_11
LBB24_36:                               ;   in Loop: Header=BB24_7 Depth=1
	sub	x0, x29, #256
	mov	x1, x27
	bl	_ggml_compute_forward_map_custom2
	b	LBB24_11
LBB24_37:                               ;   in Loop: Header=BB24_7 Depth=1
	sub	x0, x29, #256
	mov	x1, x27
	bl	_ggml_compute_forward_permute
	b	LBB24_11
LBB24_38:                               ;   in Loop: Header=BB24_7 Depth=1
	sub	x0, x29, #256
	mov	x1, x27
	bl	_ggml_compute_forward_transpose
	b	LBB24_11
LBB24_39:                               ;   in Loop: Header=BB24_7 Depth=1
	sub	x0, x29, #256
	mov	x1, x27
	bl	_ggml_compute_forward_add_rel_pos
	b	LBB24_11
LBB24_40:                               ;   in Loop: Header=BB24_7 Depth=1
	stp	x24, x23, [sp, #104]            ; 16-byte Folded Spill
	str	x22, [sp, #120]                 ; 8-byte Folded Spill
	ldp	x8, x9, [x27, #152]
	ldr	x28, [x27, #168]
	ldp	x11, x10, [x8, #24]
	str	x11, [sp, #192]                 ; 8-byte Folded Spill
	str	x10, [sp, #288]                 ; 8-byte Folded Spill
	ldr	x10, [x8, #48]
	str	x10, [sp, #504]                 ; 8-byte Folded Spill
	ldr	x10, [x8, #64]
	str	x10, [sp, #240]                 ; 8-byte Folded Spill
	ldp	x11, x10, [x9, #16]
	str	x11, [sp, #208]                 ; 8-byte Folded Spill
	str	x10, [sp, #464]                 ; 8-byte Folded Spill
	ldp	x11, x10, [x9, #32]
	str	x11, [sp, #456]                 ; 8-byte Folded Spill
	str	x10, [sp, #336]                 ; 8-byte Folded Spill
	ldp	x24, x10, [x9, #48]
	str	x10, [sp, #488]                 ; 8-byte Folded Spill
	ldp	x11, x10, [x9, #64]
	str	x11, [sp, #360]                 ; 8-byte Folded Spill
	str	x10, [sp, #328]                 ; 8-byte Folded Spill
	ldp	x19, x23, [x27, #48]
	ldp	x21, x22, [x27, #64]
	mov	x27, x9
	ldp	w10, w9, [x29, #-256]
                                        ; kill: def $w10 killed $w10 def $x10
	sxtw	x10, w10
	str	x10, [sp, #256]                 ; 8-byte Folded Spill
	stp	x9, x8, [sp, #216]              ; 16-byte Folded Spill
	ldr	w20, [x8]
	mov	x0, x27
	bl	_ggml_is_contiguous
	str	w0, [sp, #392]                  ; 4-byte Folded Spill
Lloh288:
	adrp	x9, _type_traits_cpu@PAGE
Lloh289:
	add	x9, x9, _type_traits_cpu@PAGEOFF
	add	x8, x9, x20, lsl #5
	ldr	w8, [x8, #16]
	str	x8, [sp, #304]                  ; 8-byte Folded Spill
	lsl	x8, x8, #5
	ldr	x8, [x9, x8]
	str	x8, [sp, #480]                  ; 8-byte Folded Spill
	mov	x0, x20
	bl	_ggml_type_size
	ldr	x8, [sp, #504]                  ; 8-byte Folded Reload
	cmp	x8, x0
	b.ne	LBB24_228
; %bb.41:                               ;   in Loop: Header=BB24_7 Depth=1
	ldr	w0, [x27]
	bl	_ggml_type_size
	cmp	x24, x0
	b.ne	LBB24_229
; %bb.42:                               ;   in Loop: Header=BB24_7 Depth=1
	cmp	x19, #4
	b.ne	LBB24_230
; %bb.43:                               ;   in Loop: Header=BB24_7 Depth=1
	cmp	x23, #3
	b.ls	LBB24_231
; %bb.44:                               ;   in Loop: Header=BB24_7 Depth=1
	cmp	x23, x21
	b.hi	LBB24_232
; %bb.45:                               ;   in Loop: Header=BB24_7 Depth=1
	cmp	x21, x22
	b.hi	LBB24_233
; %bb.46:                               ;   in Loop: Header=BB24_7 Depth=1
	ldr	x9, [x28, #16]
	ldur	x21, [x29, #-240]
	ldr	w8, [x27]
	ldr	x20, [sp, #304]                 ; 8-byte Folded Reload
	cmp	w8, w20
	ldr	x19, [sp, #216]                 ; 8-byte Folded Reload
	str	x24, [sp, #496]                 ; 8-byte Folded Spill
	stp	x26, x25, [sp, #88]             ; 16-byte Folded Spill
	str	x9, [sp, #272]                  ; 8-byte Folded Spill
	b.ne	LBB24_139
; %bb.47:                               ;   in Loop: Header=BB24_7 Depth=1
	mov	x8, x9
	mov	x9, x21
	b	LBB24_140
LBB24_48:                               ;   in Loop: Header=BB24_7 Depth=1
	sub	x0, x29, #256
	mov	x1, x27
	bl	_ggml_compute_forward_view
	b	LBB24_11
LBB24_49:                               ;   in Loop: Header=BB24_7 Depth=1
	sub	x0, x29, #256
	mov	x1, x27
	bl	_ggml_compute_forward_count_equal
	b	LBB24_11
LBB24_50:                               ;   in Loop: Header=BB24_7 Depth=1
	sub	x0, x29, #256
	mov	x1, x27
	bl	_ggml_compute_forward_win_unpart
	b	LBB24_11
LBB24_51:                               ;   in Loop: Header=BB24_7 Depth=1
	sub	x0, x29, #256
	mov	x1, x27
	bl	_ggml_compute_forward_mean
	b	LBB24_11
LBB24_52:                               ;   in Loop: Header=BB24_7 Depth=1
	sub	x0, x29, #256
	mov	x1, x27
	bl	_ggml_compute_forward_rope
	b	LBB24_11
LBB24_53:                               ;   in Loop: Header=BB24_7 Depth=1
	sub	x0, x29, #256
	mov	x1, x27
	bl	_ggml_compute_forward_reshape
	b	LBB24_11
LBB24_54:                               ;   in Loop: Header=BB24_7 Depth=1
	sub	x0, x29, #256
	mov	x1, x27
	bl	_ggml_compute_forward_im2col
	b	LBB24_11
LBB24_55:                               ;   in Loop: Header=BB24_7 Depth=1
	sub	x0, x29, #256
	mov	x1, x27
	bl	_ggml_compute_forward_cos
	b	LBB24_11
LBB24_56:                               ;   in Loop: Header=BB24_7 Depth=1
	sub	x0, x29, #256
	mov	x1, x27
	bl	_ggml_compute_forward_arange
	b	LBB24_11
LBB24_57:                               ;   in Loop: Header=BB24_7 Depth=1
	sub	x0, x29, #256
	mov	x1, x27
	bl	_ggml_compute_forward_sub
	b	LBB24_11
LBB24_58:                               ;   in Loop: Header=BB24_7 Depth=1
	sub	x0, x29, #256
	mov	x1, x27
	bl	_ggml_compute_forward_diag_mask_inf
	b	LBB24_11
LBB24_59:                               ;   in Loop: Header=BB24_7 Depth=1
	sub	x0, x29, #256
	mov	x1, x27
	bl	_ggml_compute_forward_im2col_back_f32
	b	LBB24_11
LBB24_60:                               ;   in Loop: Header=BB24_7 Depth=1
	sub	x0, x29, #256
	mov	x1, x27
	bl	_ggml_compute_forward_log
	b	LBB24_11
LBB24_61:                               ;   in Loop: Header=BB24_7 Depth=1
	sub	x0, x29, #256
	mov	x1, x27
	bl	_ggml_compute_forward_sum
	b	LBB24_11
LBB24_62:                               ;   in Loop: Header=BB24_7 Depth=1
	sub	x0, x29, #256
	mov	x1, x27
	bl	_ggml_compute_forward_argsort
	b	LBB24_11
LBB24_63:                               ;   in Loop: Header=BB24_7 Depth=1
	sub	x0, x29, #256
	mov	x1, x27
	bl	_ggml_compute_forward_ssm_conv
	b	LBB24_11
LBB24_64:                               ;   in Loop: Header=BB24_7 Depth=1
	sub	x0, x29, #256
	mov	x1, x27
	bl	_ggml_compute_forward_group_norm
	b	LBB24_11
LBB24_65:                               ;   in Loop: Header=BB24_7 Depth=1
	sub	x0, x29, #256
	mov	x1, x27
	bl	_ggml_compute_forward_l2_norm
	b	LBB24_11
LBB24_66:                               ;   in Loop: Header=BB24_7 Depth=1
	sub	x0, x29, #256
	mov	x1, x27
	bl	_ggml_compute_forward_add1
	b	LBB24_11
LBB24_67:                               ;   in Loop: Header=BB24_7 Depth=1
	sub	x0, x29, #256
	mov	x1, x27
	bl	_ggml_compute_forward_argmax
	b	LBB24_11
LBB24_68:                               ;   in Loop: Header=BB24_7 Depth=1
	sub	x0, x29, #256
	mov	x1, x27
	bl	_ggml_compute_forward_acc
	b	LBB24_11
LBB24_69:                               ;   in Loop: Header=BB24_7 Depth=1
	sub	x0, x29, #256
	mov	x1, x27
	bl	_ggml_compute_forward_sqr
	b	LBB24_11
LBB24_70:                               ;   in Loop: Header=BB24_7 Depth=1
	ldr	w8, [x27, #84]
	cmp	w8, #2
	b.hs	LBB24_234
; %bb.71:                               ;   in Loop: Header=BB24_7 Depth=1
	cmp	w8, #0
	cset	w1, ne
	sub	x0, x29, #256
	mov	x2, x27
	bl	_ggml_compute_forward_flash_attn_back
	b	LBB24_11
LBB24_72:                               ;   in Loop: Header=BB24_7 Depth=1
	sub	x0, x29, #256
	mov	x1, x27
	bl	_ggml_compute_forward_add
	b	LBB24_11
LBB24_73:                               ;   in Loop: Header=BB24_7 Depth=1
	sub	x0, x29, #256
	mov	x1, x27
	bl	_ggml_compute_forward_repeat
	b	LBB24_11
LBB24_74:                               ;   in Loop: Header=BB24_7 Depth=1
	sub	x0, x29, #256
	mov	x1, x27
	bl	_ggml_compute_forward_cpy
	b	LBB24_11
LBB24_75:                               ;   in Loop: Header=BB24_7 Depth=1
	sub	x0, x29, #256
	mov	x1, x27
	bl	_ggml_compute_forward_diag_mask_zero
	b	LBB24_11
LBB24_76:                               ;   in Loop: Header=BB24_7 Depth=1
	sub	x0, x29, #256
	mov	x1, x27
	bl	_ggml_compute_forward_map_custom3
	b	LBB24_11
LBB24_77:                               ;   in Loop: Header=BB24_7 Depth=1
	sub	x0, x29, #256
	mov	x1, x27
	bl	_ggml_compute_forward_mul
	b	LBB24_11
LBB24_78:                               ;   in Loop: Header=BB24_7 Depth=1
	sub	x0, x29, #256
	mov	x1, x27
	bl	_ggml_compute_forward_div
	b	LBB24_11
LBB24_79:                               ;   in Loop: Header=BB24_7 Depth=1
	sub	x0, x29, #256
	mov	x1, x27
	bl	_ggml_compute_forward_sum_rows
	b	LBB24_11
LBB24_80:                               ;   in Loop: Header=BB24_7 Depth=1
	sub	x0, x29, #256
	mov	x1, x27
	bl	_ggml_compute_forward_silu_back
	b	LBB24_11
LBB24_81:                               ;   in Loop: Header=BB24_7 Depth=1
	sub	x0, x29, #256
	mov	x1, x27
	bl	_ggml_compute_forward_norm
	b	LBB24_11
LBB24_82:                               ;   in Loop: Header=BB24_7 Depth=1
	sub	x0, x29, #256
	mov	x1, x27
	bl	_ggml_compute_forward_leaky_relu
	b	LBB24_11
LBB24_83:                               ;   in Loop: Header=BB24_7 Depth=1
	ldp	x1, x2, [x27, #152]
	ldp	x3, x4, [x27, #168]
	sub	x0, x29, #256
	mov	x5, x27
	bl	_ggml_compute_forward_flash_attn_ext
	b	LBB24_11
LBB24_84:                               ;   in Loop: Header=BB24_7 Depth=1
	sub	x0, x29, #256
	mov	x1, x27
	bl	_ggml_compute_forward_ssm_scan
	b	LBB24_11
LBB24_85:                               ;   in Loop: Header=BB24_7 Depth=1
	sub	x0, x29, #256
	mov	x1, x27
	bl	_ggml_compute_forward_sqrt
	b	LBB24_11
LBB24_86:                               ;   in Loop: Header=BB24_7 Depth=1
	sub	x0, x29, #256
	mov	x1, x27
	bl	_ggml_compute_forward_sin
	b	LBB24_11
LBB24_87:                               ;   in Loop: Header=BB24_7 Depth=1
	sub	x0, x29, #256
	mov	x1, x27
	bl	_ggml_compute_forward_repeat_back
	b	LBB24_11
LBB24_88:                               ;   in Loop: Header=BB24_7 Depth=1
	sub	x0, x29, #256
	mov	x1, x27
	bl	_ggml_compute_forward_set
	b	LBB24_11
LBB24_89:                               ;   in Loop: Header=BB24_7 Depth=1
	sub	x0, x29, #256
	mov	x1, x27
	bl	_ggml_compute_forward_cont
	b	LBB24_11
LBB24_90:                               ;   in Loop: Header=BB24_7 Depth=1
	sub	x0, x29, #256
	mov	x1, x27
	bl	_ggml_compute_forward_rope_back
	b	LBB24_11
LBB24_91:                               ;   in Loop: Header=BB24_7 Depth=1
	sub	x0, x29, #256
	mov	x1, x27
	bl	_ggml_compute_forward_rms_norm
	b	LBB24_11
LBB24_92:                               ;   in Loop: Header=BB24_7 Depth=1
	sub	x0, x29, #256
	mov	x1, x27
	bl	_ggml_compute_forward_concat
	b	LBB24_11
LBB24_93:                               ;   in Loop: Header=BB24_7 Depth=1
	sub	x0, x29, #256
	mov	x1, x27
	bl	_ggml_compute_forward_diag
	b	LBB24_11
LBB24_94:                               ;   in Loop: Header=BB24_7 Depth=1
	sub	x0, x29, #256
	mov	x1, x27
	bl	_ggml_compute_forward_soft_max
	b	LBB24_11
LBB24_95:                               ;   in Loop: Header=BB24_7 Depth=1
	sub	x0, x29, #256
	mov	x1, x27
	bl	_ggml_compute_forward_pad_reflect_1d
	b	LBB24_11
LBB24_96:                               ;   in Loop: Header=BB24_7 Depth=1
	sub	x0, x29, #256
	mov	x1, x27
	bl	_ggml_compute_forward_timestep_embedding
	b	LBB24_11
LBB24_97:                               ;   in Loop: Header=BB24_7 Depth=1
	sub	x0, x29, #256
	mov	x1, x27
	bl	_ggml_compute_forward_rms_norm_back
	b	LBB24_11
LBB24_98:                               ;   in Loop: Header=BB24_7 Depth=1
	sub	x0, x29, #256
	mov	x1, x27
	bl	_ggml_compute_forward_out_prod
	b	LBB24_11
LBB24_99:                               ;   in Loop: Header=BB24_7 Depth=1
	sub	x0, x29, #256
	mov	x1, x27
	bl	_ggml_compute_forward_scale
	b	LBB24_11
LBB24_100:                              ;   in Loop: Header=BB24_7 Depth=1
	sub	x0, x29, #256
	mov	x1, x27
	bl	_ggml_compute_forward_get_rows_back
	b	LBB24_11
LBB24_101:                              ;   in Loop: Header=BB24_7 Depth=1
	ldr	x28, [x27, #152]
	ldr	x9, [x28, #24]
	ldr	x8, [x27, #16]
	str	x9, [sp, #72]                   ; 8-byte Folded Spill
	cmp	x8, x9
	b.ne	LBB24_235
; %bb.102:                              ;   in Loop: Header=BB24_7 Depth=1
	ldr	x11, [x27, #160]
	ldr	x9, [x11, #24]
	ldr	x8, [x27, #24]
	cmp	x8, x9
	b.ne	LBB24_236
; %bb.103:                              ;   in Loop: Header=BB24_7 Depth=1
	ldr	x10, [x11, #32]
	ldr	x8, [x27, #32]
	str	x10, [sp, #448]                 ; 8-byte Folded Spill
	cmp	x8, x10
	b.ne	LBB24_237
; %bb.104:                              ;   in Loop: Header=BB24_7 Depth=1
	str	x9, [sp, #456]                  ; 8-byte Folded Spill
	stp	x24, x23, [sp, #104]            ; 16-byte Folded Spill
	str	x22, [sp, #120]                 ; 8-byte Folded Spill
	ldr	x9, [x11, #40]
	ldr	x8, [x27, #40]
	str	x9, [sp, #360]                  ; 8-byte Folded Spill
	cmp	x8, x9
	b.ne	LBB24_238
; %bb.105:                              ;   in Loop: Header=BB24_7 Depth=1
	ldr	x8, [x28, #48]
	str	x8, [sp, #504]                  ; 8-byte Folded Spill
	ldr	x8, [x11, #16]
	str	x8, [sp, #464]                  ; 8-byte Folded Spill
	ldp	x22, x8, [x11, #48]
	str	x8, [sp, #480]                  ; 8-byte Folded Spill
	ldp	x9, x8, [x11, #64]
	str	x9, [sp, #384]                  ; 8-byte Folded Spill
	str	x8, [sp, #352]                  ; 8-byte Folded Spill
	ldp	x19, x23, [x27, #48]
	mov	x24, x11
	ldp	x20, x21, [x27, #64]
	ldp	w8, w27, [x29, #-256]
                                        ; kill: def $w8 killed $w8 def $x8
	sxtw	x8, w8
	str	x8, [sp, #328]                  ; 8-byte Folded Spill
	ldr	w0, [x28]
Lloh290:
	adrp	x10, _type_traits_cpu@PAGE
Lloh291:
	add	x10, x10, _type_traits_cpu@PAGEOFF
	add	x8, x10, x0, lsl #5
	ldr	w9, [x8, #16]
	str	x9, [sp, #496]                  ; 8-byte Folded Spill
	lsl	x9, x9, #5
	ldr	x9, [x10, x9]
	str	x9, [sp, #472]                  ; 8-byte Folded Spill
	ldr	x8, [x8, #24]
	str	x8, [sp, #16]                   ; 8-byte Folded Spill
                                        ; kill: def $w0 killed $w0 killed $x0
	bl	_ggml_type_size
	ldr	x8, [sp, #504]                  ; 8-byte Folded Reload
	cmp	x8, x0
	b.ne	LBB24_239
; %bb.106:                              ;   in Loop: Header=BB24_7 Depth=1
	str	x24, [sp, #504]                 ; 8-byte Folded Spill
	ldr	w0, [x24]
	bl	_ggml_type_size
	cmp	x22, x0
	b.ne	LBB24_240
; %bb.107:                              ;   in Loop: Header=BB24_7 Depth=1
	cmp	x19, #4
	ldr	x19, [sp, #496]                 ; 8-byte Folded Reload
	b.ne	LBB24_241
; %bb.108:                              ;   in Loop: Header=BB24_7 Depth=1
	cmp	x23, #3
	b.ls	LBB24_242
; %bb.109:                              ;   in Loop: Header=BB24_7 Depth=1
	cmp	x23, x20
	b.hi	LBB24_243
; %bb.110:                              ;   in Loop: Header=BB24_7 Depth=1
	str	x22, [sp, #488]                 ; 8-byte Folded Spill
	str	x28, [sp, #24]                  ; 8-byte Folded Spill
	stp	x26, x25, [sp, #88]             ; 16-byte Folded Spill
	cmp	x20, x21
	b.hi	LBB24_244
; %bb.111:                              ;   in Loop: Header=BB24_7 Depth=1
	str	x27, [sp, #320]                 ; 8-byte Folded Spill
	sxtw	x8, w27
	str	x8, [sp, #160]                  ; 8-byte Folded Spill
	ldr	x8, [sp, #504]                  ; 8-byte Folded Reload
	ldr	w8, [x8]
	cmp	w8, w19
	b.eq	LBB24_132
; %bb.112:                              ;   in Loop: Header=BB24_7 Depth=1
	ldur	x8, [x29, #-240]
	str	x8, [sp, #344]                  ; 8-byte Folded Spill
	mov	x0, x19
	bl	_ggml_type_size
	str	x0, [sp, #416]                  ; 8-byte Folded Spill
	mov	x0, x19
	ldr	x1, [sp, #464]                  ; 8-byte Folded Reload
	bl	_ggml_row_size
	str	x0, [sp, #432]                  ; 8-byte Folded Spill
	ldr	x8, [sp, #504]                  ; 8-byte Folded Reload
	ldr	w8, [x8]
	cbnz	w8, LBB24_246
; %bb.113:                              ;   in Loop: Header=BB24_7 Depth=1
	ldr	x8, [sp, #360]                  ; 8-byte Folded Reload
	cmp	x8, #1
	b.lt	LBB24_132
; %bb.114:                              ;   in Loop: Header=BB24_7 Depth=1
	ldp	x8, x10, [sp, #448]             ; 16-byte Folded Reload
	ldr	x9, [sp, #432]                  ; 8-byte Folded Reload
	mul	x9, x9, x10
	stp	xzr, x9, [sp, #368]             ; 16-byte Folded Spill
	mul	x8, x9, x8
	str	x8, [sp, #336]                  ; 8-byte Folded Spill
	ldr	x8, [sp, #328]                  ; 8-byte Folded Reload
	ldr	x9, [sp, #464]                  ; 8-byte Folded Reload
	mul	x10, x9, x8
	add	w8, w8, #1
	sxtw	x8, w8
	mul	x8, x9, x8
	stp	x8, x10, [sp, #400]             ; 16-byte Folded Spill
	b	LBB24_116
LBB24_115:                              ;   in Loop: Header=BB24_116 Depth=2
	ldp	x8, x9, [sp, #360]              ; 16-byte Folded Reload
	add	x9, x9, #1
	str	x9, [sp, #368]                  ; 8-byte Folded Spill
	cmp	x9, x8
	b.eq	LBB24_132
LBB24_116:                              ;   Parent Loop BB24_7 Depth=1
                                        ; =>  This Loop Header: Depth=2
                                        ;       Child Loop BB24_119 Depth 3
                                        ;         Child Loop BB24_121 Depth 4
	ldr	x8, [sp, #448]                  ; 8-byte Folded Reload
	cmp	x8, #1
	b.lt	LBB24_115
; %bb.117:                              ;   in Loop: Header=BB24_116 Depth=2
	str	xzr, [sp, #464]                 ; 8-byte Folded Spill
	ldr	x8, [sp, #352]                  ; 8-byte Folded Reload
	ldr	x9, [sp, #368]                  ; 8-byte Folded Reload
	mul	x8, x9, x8
	str	x8, [sp, #440]                  ; 8-byte Folded Spill
	ldp	x10, x8, [sp, #336]             ; 16-byte Folded Reload
	madd	x8, x10, x9, x8
	str	x8, [sp, #392]                  ; 8-byte Folded Spill
	b	LBB24_119
LBB24_118:                              ;   in Loop: Header=BB24_119 Depth=3
	ldr	x9, [sp, #464]                  ; 8-byte Folded Reload
	add	x9, x9, #1
	ldr	x8, [sp, #448]                  ; 8-byte Folded Reload
	str	x9, [sp, #464]                  ; 8-byte Folded Spill
	cmp	x9, x8
	b.eq	LBB24_115
LBB24_119:                              ;   Parent Loop BB24_7 Depth=1
                                        ;     Parent Loop BB24_116 Depth=2
                                        ; =>    This Loop Header: Depth=3
                                        ;         Child Loop BB24_121 Depth 4
	ldr	x8, [sp, #456]                  ; 8-byte Folded Reload
	cmp	x8, #1
	ldr	x24, [sp, #160]                 ; 8-byte Folded Reload
	ldp	x21, x27, [sp, #408]            ; 16-byte Folded Reload
	ldp	x20, x26, [sp, #432]            ; 16-byte Folded Reload
	ldr	x25, [sp, #400]                 ; 8-byte Folded Reload
	b.lt	LBB24_118
; %bb.120:                              ;   in Loop: Header=BB24_119 Depth=3
	mov	x23, #0                         ; =0x0
	ldp	x8, x10, [sp, #376]             ; 16-byte Folded Reload
	ldp	x22, x9, [sp, #456]             ; 16-byte Folded Reload
	mul	x28, x9, x10
	ldr	x10, [sp, #392]                 ; 8-byte Folded Reload
	madd	x19, x9, x8, x10
LBB24_121:                              ;   Parent Loop BB24_7 Depth=1
                                        ;     Parent Loop BB24_116 Depth=2
                                        ;       Parent Loop BB24_119 Depth=3
                                        ; =>      This Inner Loop Header: Depth=4
	ldr	x0, [sp, #496]                  ; 8-byte Folded Reload
                                        ; kill: def $w0 killed $w0 killed $x0
	bl	_ggml_blck_size
	udiv	x8, x21, x0
	udiv	x9, x8, x24
	udiv	x10, x25, x0
	ldr	x8, [sp, #504]                  ; 8-byte Folded Reload
	ldr	x8, [x8, #248]
	add	x11, x26, x28
	add	x8, x8, x11
	ldr	x11, [sp, #480]                 ; 8-byte Folded Reload
	madd	x8, x23, x11, x8
	ldr	x11, [sp, #488]                 ; 8-byte Folded Reload
	mul	x11, x0, x11
	madd	x8, x11, x9, x8
	madd	x11, x23, x20, x19
	madd	x1, x9, x27, x11
	udiv	x10, x10, x24
	sub	x9, x10, x9
	mul	x2, x9, x0
	mov	x0, x8
	ldr	x8, [sp, #472]                  ; 8-byte Folded Reload
	blr	x8
	add	x23, x23, #1
	subs	x22, x22, #1
	b.ne	LBB24_121
	b	LBB24_118
LBB24_122:                              ;   in Loop: Header=BB24_7 Depth=1
	sub	x0, x29, #256
	mov	x1, x27
	bl	_ggml_compute_forward_pool_2d_back
	b	LBB24_11
LBB24_123:                              ;   in Loop: Header=BB24_7 Depth=1
	sub	x0, x29, #256
	mov	x1, x27
	bl	_ggml_compute_forward_rwkv_wkv7
	b	LBB24_11
LBB24_124:                              ;   in Loop: Header=BB24_7 Depth=1
	sub	x0, x29, #256
	mov	x1, x27
	bl	_ggml_compute_forward_upscale
	b	LBB24_11
LBB24_125:                              ;   in Loop: Header=BB24_7 Depth=1
	sub	x0, x29, #256
	mov	x1, x27
	bl	_ggml_compute_forward_clamp
	b	LBB24_11
LBB24_126:                              ;   in Loop: Header=BB24_7 Depth=1
	sub	x0, x29, #256
	mov	x1, x27
	bl	_ggml_compute_forward_pool_1d
	b	LBB24_11
LBB24_127:                              ;   in Loop: Header=BB24_7 Depth=1
	sub	x0, x29, #256
	mov	x1, x27
	bl	_ggml_compute_forward_unary
	b	LBB24_11
LBB24_128:                              ;   in Loop: Header=BB24_7 Depth=1
	sub	x0, x29, #256
	mov	x1, x27
	bl	_ggml_compute_forward_map_custom1
	b	LBB24_11
LBB24_129:                              ;   in Loop: Header=BB24_7 Depth=1
	sub	x0, x29, #256
	mov	x1, x27
	bl	_ggml_compute_forward_conv_transpose_2d
	b	LBB24_11
LBB24_130:                              ;   in Loop: Header=BB24_7 Depth=1
	sub	x0, x29, #256
	mov	x1, x27
	bl	_ggml_compute_forward_cross_entropy_loss
	b	LBB24_11
LBB24_131:                              ;   in Loop: Header=BB24_7 Depth=1
	sub	x0, x29, #256
	mov	x1, x27
	bl	_ggml_compute_forward_get_rel_pos
	b	LBB24_11
LBB24_132:                              ;   in Loop: Header=BB24_7 Depth=1
	ldur	x8, [x29, #-232]
	ldr	x17, [sp, #328]                 ; 8-byte Folded Reload
	cbnz	w17, LBB24_134
; %bb.133:                              ;   in Loop: Header=BB24_7 Depth=1
	ldr	x9, [sp, #320]                  ; 8-byte Folded Reload
	str	w9, [x8, #320]
LBB24_134:                              ;   in Loop: Header=BB24_7 Depth=1
	ldr	w9, [x8, #348]
	subs	w11, w9, #1
	ldp	x26, x25, [sp, #88]             ; 16-byte Folded Reload
	ldp	x23, x22, [sp, #112]            ; 16-byte Folded Reload
	ldr	x24, [sp, #104]                 ; 8-byte Folded Reload
	mov	w19, #1                         ; =0x1
Lloh292:
	adrp	x20, lJTI24_0@PAGE
Lloh293:
	add	x20, x20, lJTI24_0@PAGEOFF
	ldr	x27, [sp, #424]                 ; 8-byte Folded Reload
	ldr	x28, [sp, #24]                  ; 8-byte Folded Reload
	ldr	x15, [sp, #160]                 ; 8-byte Folded Reload
	ldr	x16, [sp, #456]                 ; 8-byte Folded Reload
	b.eq	LBB24_190
; %bb.135:                              ;   in Loop: Header=BB24_7 Depth=1
	ldr	w9, [x8, #256]
	add	x12, x8, #192
	mov	w10, #1                         ; =0x1
	ldaddal	w10, w12, [x12]
	cmp	w12, w11
	b.ne	LBB24_137
; %bb.136:                              ;   in Loop: Header=BB24_7 Depth=1
	str	wzr, [x8, #192]
	add	x8, x8, #256
	ldaddal	w10, w8, [x8]
	b	LBB24_190
LBB24_137:                              ;   Parent Loop BB24_7 Depth=1
                                        ; =>  This Inner Loop Header: Depth=2
	ldr	w10, [x8, #256]
	cmp	w10, w9
	b.ne	LBB24_189
; %bb.138:                              ;   in Loop: Header=BB24_137 Depth=2
	; InlineAsm Start
	yield
	; InlineAsm End
	b	LBB24_137
LBB24_139:                              ;   in Loop: Header=BB24_7 Depth=1
	mov	x0, x27
	bl	_ggml_nelements
	mov	x1, x0
	mov	x0, x20
	bl	_ggml_row_size
	add	x8, x21, #7
	and	x8, x8, #0xfffffffffffffff8
	add	x9, x8, x0
	ldr	x8, [x28, #16]
	ldur	x21, [x29, #-240]
LBB24_140:                              ;   in Loop: Header=BB24_7 Depth=1
	ldr	x11, [sp, #288]                 ; 8-byte Folded Reload
	sbfiz	x12, x11, #3, #32
	add	x9, x9, #7
	and	x9, x9, #0xfffffffffffffff8
	str	x9, [sp, #248]                  ; 8-byte Folded Spill
	add	x10, x9, x12
	str	x28, [sp, #400]                 ; 8-byte Folded Spill
	ldr	x9, [x28, #24]
	mul	x8, x8, x12
	str	x10, [sp, #432]                 ; 8-byte Folded Spill
	madd	x8, x8, x9, x10
	lsl	w9, w11, #6
	add	x8, x8, #63
	and	x8, x8, #0xffffffffffffffc0
	str	x8, [sp, #280]                  ; 8-byte Folded Spill
	add	x8, x8, w9, sxtw
	ldur	x9, [x29, #-248]
	str	x21, [sp, #320]                 ; 8-byte Folded Spill
	sub	x8, x8, x21
	cmp	x9, x8
	b.lo	LBB24_245
; %bb.141:                              ;   in Loop: Header=BB24_7 Depth=1
	str	x12, [sp, #264]                 ; 8-byte Folded Spill
	sxtw	x8, w19
	str	x8, [sp, #296]                  ; 8-byte Folded Spill
	str	x27, [sp, #376]                 ; 8-byte Folded Spill
	ldr	w8, [x27]
	cmp	w8, w20
	b.eq	LBB24_152
; %bb.142:                              ;   in Loop: Header=BB24_7 Depth=1
	ldr	x19, [sp, #304]                 ; 8-byte Folded Reload
	mov	x0, x19
	bl	_ggml_type_size
	str	x0, [sp, #416]                  ; 8-byte Folded Spill
	mov	x0, x19
	ldr	x1, [sp, #208]                  ; 8-byte Folded Reload
	bl	_ggml_row_size
	str	x0, [sp, #440]                  ; 8-byte Folded Spill
	ldr	x8, [sp, #376]                  ; 8-byte Folded Reload
	ldr	w8, [x8]
	cbnz	w8, LBB24_247
; %bb.143:                              ;   in Loop: Header=BB24_7 Depth=1
	ldr	x8, [sp, #336]                  ; 8-byte Folded Reload
	cmp	x8, #1
	b.lt	LBB24_152
; %bb.144:                              ;   in Loop: Header=BB24_7 Depth=1
	ldp	x8, x10, [sp, #456]             ; 16-byte Folded Reload
	ldr	x9, [sp, #440]                  ; 8-byte Folded Reload
	mul	x9, x9, x10
	stp	xzr, x9, [sp, #344]             ; 16-byte Folded Spill
	mul	x8, x9, x8
	str	x8, [sp, #312]                  ; 8-byte Folded Spill
	ldr	x9, [sp, #208]                  ; 8-byte Folded Reload
	ldr	x8, [sp, #256]                  ; 8-byte Folded Reload
	mul	x10, x9, x8
	str	x10, [sp, #408]                 ; 8-byte Folded Spill
	add	w8, w8, #1
	sxtw	x8, w8
	mul	x8, x9, x8
	str	x8, [sp, #384]                  ; 8-byte Folded Spill
	b	LBB24_146
LBB24_145:                              ;   in Loop: Header=BB24_146 Depth=2
	ldp	x8, x9, [sp, #336]              ; 16-byte Folded Reload
	add	x9, x9, #1
	str	x9, [sp, #344]                  ; 8-byte Folded Spill
	cmp	x9, x8
	b.eq	LBB24_152
LBB24_146:                              ;   Parent Loop BB24_7 Depth=1
                                        ; =>  This Loop Header: Depth=2
                                        ;       Child Loop BB24_149 Depth 3
                                        ;         Child Loop BB24_151 Depth 4
	ldr	x8, [sp, #456]                  ; 8-byte Folded Reload
	cmp	x8, #1
	b.lt	LBB24_145
; %bb.147:                              ;   in Loop: Header=BB24_146 Depth=2
	str	xzr, [sp, #472]                 ; 8-byte Folded Spill
	ldr	x8, [sp, #328]                  ; 8-byte Folded Reload
	ldr	x9, [sp, #344]                  ; 8-byte Folded Reload
	mul	x8, x9, x8
	str	x8, [sp, #448]                  ; 8-byte Folded Spill
	ldp	x10, x8, [sp, #312]             ; 16-byte Folded Reload
	madd	x8, x10, x9, x8
	str	x8, [sp, #368]                  ; 8-byte Folded Spill
	b	LBB24_149
LBB24_148:                              ;   in Loop: Header=BB24_149 Depth=3
	ldr	x9, [sp, #472]                  ; 8-byte Folded Reload
	add	x9, x9, #1
	ldr	x8, [sp, #456]                  ; 8-byte Folded Reload
	str	x9, [sp, #472]                  ; 8-byte Folded Spill
	cmp	x9, x8
	b.eq	LBB24_145
LBB24_149:                              ;   Parent Loop BB24_7 Depth=1
                                        ;     Parent Loop BB24_146 Depth=2
                                        ; =>    This Loop Header: Depth=3
                                        ;         Child Loop BB24_151 Depth 4
	ldr	x8, [sp, #464]                  ; 8-byte Folded Reload
	cmp	x8, #1
	ldp	x26, x22, [sp, #296]            ; 16-byte Folded Reload
	ldp	x19, x20, [sp, #408]            ; 16-byte Folded Reload
	ldp	x21, x23, [sp, #440]            ; 16-byte Folded Reload
	ldr	x25, [sp, #384]                 ; 8-byte Folded Reload
	b.lt	LBB24_148
; %bb.150:                              ;   in Loop: Header=BB24_149 Depth=3
	mov	x27, #0                         ; =0x0
	ldp	x8, x10, [sp, #360]             ; 16-byte Folded Reload
	ldp	x28, x9, [sp, #464]             ; 16-byte Folded Reload
	mul	x8, x9, x8
	str	x8, [sp, #504]                  ; 8-byte Folded Spill
	ldr	x8, [sp, #352]                  ; 8-byte Folded Reload
	madd	x24, x9, x8, x10
LBB24_151:                              ;   Parent Loop BB24_7 Depth=1
                                        ;     Parent Loop BB24_146 Depth=2
                                        ;       Parent Loop BB24_149 Depth=3
                                        ; =>      This Inner Loop Header: Depth=4
	mov	x0, x22
	bl	_ggml_blck_size
	udiv	x8, x19, x0
	udiv	x9, x8, x26
	udiv	x10, x25, x0
	ldr	x8, [sp, #376]                  ; 8-byte Folded Reload
	ldr	x8, [x8, #248]
	ldr	x11, [sp, #504]                 ; 8-byte Folded Reload
	add	x11, x23, x11
	add	x8, x8, x11
	ldr	x11, [sp, #488]                 ; 8-byte Folded Reload
	madd	x8, x27, x11, x8
	ldr	x11, [sp, #496]                 ; 8-byte Folded Reload
	mul	x11, x0, x11
	madd	x8, x11, x9, x8
	madd	x11, x27, x21, x24
	madd	x1, x9, x20, x11
	udiv	x10, x10, x26
	sub	x9, x10, x9
	mul	x2, x9, x0
	mov	x0, x8
	ldr	x8, [sp, #480]                  ; 8-byte Folded Reload
	blr	x8
	add	x27, x27, #1
	subs	x28, x28, #1
	b.ne	LBB24_151
	b	LBB24_148
LBB24_152:                              ;   in Loop: Header=BB24_7 Depth=1
	ldp	x26, x25, [sp, #88]             ; 16-byte Folded Reload
	ldp	x23, x22, [sp, #112]            ; 16-byte Folded Reload
	ldr	x24, [sp, #104]                 ; 8-byte Folded Reload
	mov	w19, #1                         ; =0x1
Lloh294:
	adrp	x20, lJTI24_0@PAGE
Lloh295:
	add	x20, x20, lJTI24_0@PAGEOFF
	ldr	x27, [sp, #424]                 ; 8-byte Folded Reload
	ldr	x28, [sp, #400]                 ; 8-byte Folded Reload
	ldp	x21, x8, [sp, #248]             ; 16-byte Folded Reload
	ldr	x13, [sp, #296]                 ; 8-byte Folded Reload
	cbz	w8, LBB24_161
LBB24_153:                              ;   in Loop: Header=BB24_7 Depth=1
	ldr	x8, [sp, #256]                  ; 8-byte Folded Reload
	ldr	x14, [sp, #288]                 ; 8-byte Folded Reload
	cmp	w8, w14
	ldr	x12, [sp, #216]                 ; 8-byte Folded Reload
	b.ge	LBB24_156
; %bb.154:                              ;   in Loop: Header=BB24_7 Depth=1
	lsl	x8, x14, #32
	asr	x8, x8, #32
	lsl	x9, x13, #6
	ldr	x11, [sp, #256]                 ; 8-byte Folded Reload
	mov	x10, x11
	ldr	x15, [sp, #280]                 ; 8-byte Folded Reload
	add	x11, x15, x11, lsl #6
LBB24_155:                              ;   Parent Loop BB24_7 Depth=1
                                        ; =>  This Inner Loop Header: Depth=2
	stlr	w12, [x11]
	add	x11, x11, x9
	add	x10, x10, x13
	cmp	x10, x8
	b.lt	LBB24_155
LBB24_156:                              ;   in Loop: Header=BB24_7 Depth=1
	ldur	x8, [x29, #-232]
	ldr	w9, [x8, #348]
	subs	w10, w9, #1
	b.eq	LBB24_169
; %bb.157:                              ;   in Loop: Header=BB24_7 Depth=1
	ldr	w9, [x8, #256]
	add	x12, x8, #192
	mov	w11, #1                         ; =0x1
	ldaddal	w11, w12, [x12]
	cmp	w12, w10
	b.ne	LBB24_159
; %bb.158:                              ;   in Loop: Header=BB24_7 Depth=1
	str	wzr, [x8, #192]
	add	x8, x8, #256
	ldaddal	w11, w8, [x8]
	b	LBB24_169
LBB24_159:                              ;   Parent Loop BB24_7 Depth=1
                                        ; =>  This Inner Loop Header: Depth=2
	ldr	w10, [x8, #256]
	cmp	w10, w9
	b.ne	LBB24_168
; %bb.160:                              ;   in Loop: Header=BB24_159 Depth=2
	; InlineAsm Start
	yield
	; InlineAsm End
	b	LBB24_159
LBB24_161:                              ;   in Loop: Header=BB24_7 Depth=1
	mov	x0, x21
	ldr	x1, [sp, #264]                  ; 8-byte Folded Reload
	bl	_bzero
	ldr	x17, [sp, #272]                 ; 8-byte Folded Reload
	ldr	x13, [sp, #296]                 ; 8-byte Folded Reload
	ldr	x16, [sp, #432]                 ; 8-byte Folded Reload
	ldr	x10, [x28, #24]
	cmp	x10, #1
	b.lt	LBB24_153
; %bb.162:                              ;   in Loop: Header=BB24_7 Depth=1
	mov	x8, #0                          ; =0x0
	and	x9, x17, #0x7fffffff
	b	LBB24_164
LBB24_163:                              ;   in Loop: Header=BB24_164 Depth=2
	add	x8, x8, #1
	cmp	x8, x10
	b.ge	LBB24_153
LBB24_164:                              ;   Parent Loop BB24_7 Depth=1
                                        ; =>  This Loop Header: Depth=2
                                        ;       Child Loop BB24_166 Depth 3
	cmp	w17, #1
	b.lt	LBB24_163
; %bb.165:                              ;   in Loop: Header=BB24_164 Depth=2
	mov	x10, #0                         ; =0x0
	ldr	x12, [x28, #248]
	ldp	x11, x13, [x28, #48]
	madd	x12, x13, x8, x12
LBB24_166:                              ;   Parent Loop BB24_7 Depth=1
                                        ;     Parent Loop BB24_164 Depth=2
                                        ; =>    This Inner Loop Header: Depth=3
	ldrsw	x13, [x12]
	ldp	x14, x15, [x28, #16]
	mul	x14, x14, x13
	mul	x14, x14, x15
	ldr	x15, [x21, x13, lsl #3]
	add	x14, x16, x14, lsl #3
	add	x14, x14, x15, lsl #3
	stp	w10, w8, [x14]
	add	x14, x15, #1
	str	x14, [x21, x13, lsl #3]
	add	x10, x10, #1
	add	x12, x12, x11
	cmp	x9, x10
	b.ne	LBB24_166
; %bb.167:                              ;   in Loop: Header=BB24_164 Depth=2
	ldr	x10, [x28, #24]
	ldr	x13, [sp, #296]                 ; 8-byte Folded Reload
	b	LBB24_163
LBB24_168:                              ;   in Loop: Header=BB24_7 Depth=1
	dmb	ish
LBB24_169:                              ;   in Loop: Header=BB24_7 Depth=1
	cmp	w14, #1
	b.lt	LBB24_11
; %bb.170:                              ;   in Loop: Header=BB24_7 Depth=1
	mov	x9, #0                          ; =0x0
	mov	x16, #0                         ; =0x0
	ldr	x8, [sp, #376]                  ; 8-byte Folded Reload
	add	x8, x8, #248
	str	x8, [sp, #200]                  ; 8-byte Folded Spill
	ldr	x8, [sp, #192]                  ; 8-byte Folded Reload
	sub	x8, x8, #1
	str	x8, [sp, #184]                  ; 8-byte Folded Spill
	and	x8, x14, #0x7fffffff
	str	x8, [sp, #232]                  ; 8-byte Folded Spill
	b	LBB24_173
LBB24_171:                              ;   in Loop: Header=BB24_173 Depth=2
	ldp	x26, x25, [sp, #88]             ; 16-byte Folded Reload
	ldp	x23, x22, [sp, #112]            ; 16-byte Folded Reload
	ldr	x24, [sp, #104]                 ; 8-byte Folded Reload
	ldr	x9, [sp, #264]                  ; 8-byte Folded Reload
LBB24_172:                              ;   in Loop: Header=BB24_173 Depth=2
	add	x16, x16, #1
	ldp	x8, x10, [sp, #232]             ; 16-byte Folded Reload
	add	x9, x9, x10
	cmp	x16, x8
	mov	w19, #1                         ; =0x1
Lloh296:
	adrp	x20, lJTI24_0@PAGE
Lloh297:
	add	x20, x20, lJTI24_0@PAGEOFF
	ldr	x21, [sp, #248]                 ; 8-byte Folded Reload
	b.eq	LBB24_11
LBB24_173:                              ;   Parent Loop BB24_7 Depth=1
                                        ; =>  This Loop Header: Depth=2
                                        ;       Child Loop BB24_178 Depth 3
                                        ;         Child Loop BB24_180 Depth 4
                                        ;           Child Loop BB24_181 Depth 5
                                        ;             Child Loop BB24_186 Depth 6
	ldr	x19, [x21, x16, lsl #3]
	cbz	x19, LBB24_172
; %bb.174:                              ;   in Loop: Header=BB24_173 Depth=2
	ldr	x8, [sp, #224]                  ; 8-byte Folded Reload
	ldr	x20, [x8, #248]
	ldr	x8, [sp, #376]                  ; 8-byte Folded Reload
	ldr	w8, [x8]
	ldr	x0, [sp, #304]                  ; 8-byte Folded Reload
	cmp	w8, w0
	ldr	x8, [sp, #128]                  ; 8-byte Folded Reload
	ldp	x10, x1, [sp, #200]             ; 16-byte Folded Reload
	csel	x8, x10, x8, eq
	ldr	x21, [x8]
                                        ; kill: def $w0 killed $w0 killed $x0
	str	x9, [sp, #264]                  ; 8-byte Folded Spill
	str	x16, [sp, #440]                 ; 8-byte Folded Spill
	bl	_ggml_row_size
	ldp	x15, x16, [sp, #432]            ; 16-byte Folded Reload
	str	x0, [sp, #384]                  ; 8-byte Folded Spill
	ldr	x8, [sp, #256]                  ; 8-byte Folded Reload
	ldr	x9, [sp, #216]                  ; 8-byte Folded Reload
	cmp	w9, w8
	ldr	x9, [sp, #264]                  ; 8-byte Folded Reload
	b.le	LBB24_172
; %bb.175:                              ;   in Loop: Header=BB24_173 Depth=2
	ldr	x13, [sp, #192]                 ; 8-byte Folded Reload
	cmp	x13, x19
	ldr	x9, [sp, #296]                  ; 8-byte Folded Reload
	csinc	x10, x9, xzr, le
	add	x8, x19, x10
	csinc	x9, x9, xzr, gt
	sub	x11, x8, #1
	ldr	x8, [sp, #184]                  ; 8-byte Folded Reload
	add	x8, x8, x9
	sdiv	x8, x8, x9
	ldr	x14, [sp, #256]                 ; 8-byte Folded Reload
	sdiv	x12, x14, x9
	msub	x9, x12, x9, x14
	mul	x14, x9, x8
	sdiv	x10, x11, x10
	add	x11, x14, x8
	cmp	x11, x13
	csel	x13, x11, x13, lt
	mul	x12, x12, x10
	add	x10, x12, x10
	cmp	x10, x19
	csel	x10, x10, x19, lt
	stp	x14, x10, [sp, #280]            ; 16-byte Folded Spill
	cmp	x12, x10
	b.ge	LBB24_171
; %bb.176:                              ;   in Loop: Header=BB24_173 Depth=2
	ldr	x10, [sp, #224]                 ; 8-byte Folded Reload
	ldr	x19, [x10, #16]
	ldr	x23, [x10, #56]
	ldr	x11, [sp, #376]                 ; 8-byte Folded Reload
	ldr	x14, [x11, #24]
	str	x14, [sp, #480]                 ; 8-byte Folded Spill
	ldp	x14, x11, [x11, #56]
	stp	x11, x14, [sp, #352]            ; 16-byte Folded Spill
	ldr	x11, [x27, #56]
	str	x11, [sp, #416]                 ; 8-byte Folded Spill
	ldr	x11, [x27, #64]
	str	x11, [sp, #408]                 ; 8-byte Folded Spill
	ldr	w10, [x10]
Lloh298:
	adrp	x11, _type_traits_cpu@PAGE
Lloh299:
	add	x11, x11, _type_traits_cpu@PAGEOFF
	add	x10, x11, x10, lsl #5
	ldr	x24, [x10, #8]
	ldr	w10, [x10, #16]
	str	w10, [sp, #368]                 ; 4-byte Folded Spill
	mul	x8, x23, x8
	ldr	x10, [sp, #264]                 ; 8-byte Folded Reload
	madd	x8, x8, x9, x10
	add	x8, x20, x8
	str	x8, [sp, #272]                  ; 8-byte Folded Spill
	lsl	x8, x23, #4
	stp	x8, x13, [sp, #320]             ; 16-byte Folded Spill
	b	LBB24_178
LBB24_177:                              ;   in Loop: Header=BB24_178 Depth=3
	ldr	x9, [sp, #312]                  ; 8-byte Folded Reload
	mov	x12, x9
	ldr	x8, [sp, #288]                  ; 8-byte Folded Reload
	cmp	x9, x8
	b.ge	LBB24_171
LBB24_178:                              ;   Parent Loop BB24_7 Depth=1
                                        ;     Parent Loop BB24_173 Depth=2
                                        ; =>    This Loop Header: Depth=3
                                        ;         Child Loop BB24_180 Depth 4
                                        ;           Child Loop BB24_181 Depth 5
                                        ;             Child Loop BB24_186 Depth 6
	add	x8, x12, #16
	str	x8, [sp, #312]                  ; 8-byte Folded Spill
	ldr	x8, [sp, #280]                  ; 8-byte Folded Reload
	cmp	x8, x13
	b.ge	LBB24_177
; %bb.179:                              ;   in Loop: Header=BB24_178 Depth=3
	ldp	x25, x8, [sp, #280]             ; 16-byte Folded Reload
	ldr	x9, [sp, #312]                  ; 8-byte Folded Reload
	cmp	x9, x8
	csel	x8, x9, x8, lt
	str	x8, [sp, #448]                  ; 8-byte Folded Spill
	ldr	x8, [sp, #272]                  ; 8-byte Folded Reload
	str	x8, [sp, #472]                  ; 8-byte Folded Spill
	str	x12, [sp, #336]                 ; 8-byte Folded Spill
LBB24_180:                              ;   Parent Loop BB24_7 Depth=1
                                        ;     Parent Loop BB24_173 Depth=2
                                        ;       Parent Loop BB24_178 Depth=3
                                        ; =>      This Loop Header: Depth=4
                                        ;           Child Loop BB24_181 Depth 5
                                        ;             Child Loop BB24_186 Depth 6
	add	x8, x25, #16
	cmp	x8, x13
	str	x8, [sp, #344]                  ; 8-byte Folded Spill
	csel	x26, x8, x13, lt
	sub	x8, x26, x25
	lsl	x8, x8, #2
	stp	x8, x25, [sp, #456]             ; 16-byte Folded Spill
	mov	x20, x12
LBB24_181:                              ;   Parent Loop BB24_7 Depth=1
                                        ;     Parent Loop BB24_173 Depth=2
                                        ;       Parent Loop BB24_178 Depth=3
                                        ;         Parent Loop BB24_180 Depth=4
                                        ; =>        This Loop Header: Depth=5
                                        ;             Child Loop BB24_186 Depth 6
	ldp	x8, x9, [x28, #16]
	mul	x8, x8, x16
	mul	x8, x8, x9
	add	x8, x15, x8, lsl #3
	add	x9, x8, x20, lsl #3
	ldpsw	x8, x12, [x9]
	ldr	x10, [sp, #480]                 ; 8-byte Folded Reload
	sdiv	x9, x8, x10
	msub	x9, x9, x10, x8
	ldr	w10, [sp, #392]                 ; 4-byte Folded Reload
	str	x12, [sp, #504]                 ; 8-byte Folded Spill
	tbnz	w10, #0, LBB24_184
; %bb.182:                              ;   in Loop: Header=BB24_181 Depth=5
	ldr	x10, [sp, #376]                 ; 8-byte Folded Reload
	ldr	w10, [x10]
	ldr	w11, [sp, #368]                 ; 4-byte Folded Reload
	cmp	w10, w11
	b.ne	LBB24_184
; %bb.183:                              ;   in Loop: Header=BB24_181 Depth=5
	ldp	x10, x11, [sp, #352]            ; 16-byte Folded Reload
	mul	x10, x10, x12
	madd	x22, x9, x11, x10
	b	LBB24_185
LBB24_184:                              ;   in Loop: Header=BB24_181 Depth=5
	ldr	x10, [sp, #480]                 ; 8-byte Folded Reload
	madd	x9, x10, x12, x9
	ldr	x10, [sp, #384]                 ; 8-byte Folded Reload
	mul	x22, x9, x10
LBB24_185:                              ;   in Loop: Header=BB24_181 Depth=5
	ldr	x10, [x27, #248]
	ldr	x9, [sp, #416]                  ; 8-byte Folded Reload
	mul	x8, x9, x8
	stp	x8, x10, [sp, #488]             ; 16-byte Folded Spill
	sub	x27, x29, #224
	ldr	x28, [sp, #472]                 ; 8-byte Folded Reload
LBB24_186:                              ;   Parent Loop BB24_7 Depth=1
                                        ;     Parent Loop BB24_173 Depth=2
                                        ;       Parent Loop BB24_178 Depth=3
                                        ;         Parent Loop BB24_180 Depth=4
                                        ;           Parent Loop BB24_181 Depth=5
                                        ; =>          This Inner Loop Header: Depth=6
	add	x5, x21, x22
	mov	x0, x19
	mov	x1, x27
	mov	x2, #0                          ; =0x0
	mov	x3, x28
	mov	x4, #0                          ; =0x0
	mov	x6, #0                          ; =0x0
	mov	w7, #1                          ; =0x1
	blr	x24
	add	x25, x25, #1
	add	x28, x28, x23
	add	x27, x27, #4
	cmp	x25, x26
	b.lt	LBB24_186
; %bb.187:                              ;   in Loop: Header=BB24_181 Depth=5
	ldr	x8, [sp, #408]                  ; 8-byte Folded Reload
	ldp	x9, x10, [sp, #496]             ; 16-byte Folded Reload
	mul	x8, x8, x10
	ldr	x10, [sp, #488]                 ; 8-byte Folded Reload
	add	x9, x9, x10
	add	x8, x9, x8
	ldp	x2, x25, [sp, #456]             ; 16-byte Folded Reload
	add	x0, x8, x25, lsl #2
	sub	x1, x29, #224
	bl	_memcpy
	add	x20, x20, #1
	ldp	x16, x8, [sp, #440]             ; 16-byte Folded Reload
	cmp	x20, x8
	ldp	x27, x15, [sp, #424]            ; 16-byte Folded Reload
	ldr	x28, [sp, #400]                 ; 8-byte Folded Reload
	b.lt	LBB24_181
; %bb.188:                              ;   in Loop: Header=BB24_180 Depth=4
	ldp	x8, x13, [sp, #320]             ; 16-byte Folded Reload
	ldr	x9, [sp, #472]                  ; 8-byte Folded Reload
	add	x9, x9, x8
	str	x9, [sp, #472]                  ; 8-byte Folded Spill
	ldp	x12, x8, [sp, #336]             ; 16-byte Folded Reload
	mov	x25, x8
	cmp	x8, x13
	b.lt	LBB24_180
	b	LBB24_177
LBB24_189:                              ;   in Loop: Header=BB24_7 Depth=1
	dmb	ish
LBB24_190:                              ;   in Loop: Header=BB24_7 Depth=1
	ldr	x8, [sp, #448]                  ; 8-byte Folded Reload
	mul	x8, x8, x16
	ldr	x9, [sp, #360]                  ; 8-byte Folded Reload
	mul	x14, x8, x9
	subs	x8, x14, #1
	ldr	x13, [sp, #72]                  ; 8-byte Folded Reload
	ccmp	x13, #1, #4, ne
	mov	w9, #16                         ; =0x10
	mov	w10, #64                        ; =0x40
	csel	x10, x10, x9, eq
	sub	x9, x13, #1
	add	x11, x10, x9
	sdiv	x11, x11, x10
	add	x12, x10, x8
	sdiv	x10, x12, x10
	mul	x12, x10, x11
	str	x14, [sp, #56]                  ; 8-byte Folded Spill
	cmp	x13, x14
	csinc	x13, x15, xzr, gt
	csinc	x14, x15, xzr, le
	cmp	x12, x15, lsl #2
	csel	x10, x14, x10, lt
	csel	x11, x13, x11, lt
	str	x11, [sp, #64]                  ; 8-byte Folded Spill
	mul	x12, x11, x10
	cmp	x12, x17
	b.le	LBB24_11
; %bb.191:                              ;   in Loop: Header=BB24_7 Depth=1
	ldr	x11, [sp, #64]                  ; 8-byte Folded Reload
	add	x9, x11, x9
	sdiv	x9, x9, x11
	str	x9, [sp, #80]                   ; 8-byte Folded Spill
	add	x8, x10, x8
	ldr	x9, [sp, #72]                   ; 8-byte Folded Reload
	orr	w9, w9, w16
	tst	x9, #0x1
	cset	w9, eq
	str	w9, [sp, #44]                   ; 4-byte Folded Spill
	sdiv	x8, x8, x10
	str	x8, [sp, #32]                   ; 8-byte Folded Spill
	str	x12, [sp, #48]                  ; 8-byte Folded Spill
LBB24_192:                              ;   Parent Loop BB24_7 Depth=1
                                        ; =>  This Loop Header: Depth=2
                                        ;       Child Loop BB24_202 Depth 3
                                        ;         Child Loop BB24_204 Depth 4
                                        ;           Child Loop BB24_206 Depth 5
                                        ;             Child Loop BB24_211 Depth 6
                                        ;             Child Loop BB24_214 Depth 6
	ldr	x9, [sp, #64]                   ; 8-byte Folded Reload
	sdiv	x8, x17, x9
	msub	x20, x8, x9, x17
	ldr	x9, [sp, #80]                   ; 8-byte Folded Reload
	mul	x10, x20, x9
	str	x10, [sp, #152]                 ; 8-byte Folded Spill
	add	x9, x10, x9
	ldr	x10, [sp, #72]                  ; 8-byte Folded Reload
	cmp	x9, x10
	csel	x10, x9, x10, lt
	ldr	x9, [sp, #32]                   ; 8-byte Folded Reload
	mul	x22, x8, x9
	add	x8, x22, x9
	ldr	x9, [sp, #56]                   ; 8-byte Folded Reload
	cmp	x8, x9
	csel	x9, x8, x9, lt
	ldr	w8, [sp, #44]                   ; 4-byte Folded Reload
	cbz	w8, LBB24_195
; %bb.193:                              ;   in Loop: Header=BB24_192 Depth=2
	ldr	x8, [sp, #152]                  ; 8-byte Folded Reload
	sub	w8, w10, w8
	tbnz	w8, #0, LBB24_195
; %bb.194:                              ;   in Loop: Header=BB24_192 Depth=2
	sub	w8, w9, w22
	ldr	x11, [sp, #16]                  ; 8-byte Folded Reload
	tbz	w8, #0, LBB24_196
LBB24_195:                              ;   in Loop: Header=BB24_192 Depth=2
	mov	w11, #1                         ; =0x1
LBB24_196:                              ;   in Loop: Header=BB24_192 Depth=2
	str	x9, [sp, #144]                  ; 8-byte Folded Spill
	ldr	w26, [x28]
	ldp	x8, x0, [x27, #152]
	ldr	x9, [x8, #16]
	str	x9, [sp, #496]                  ; 8-byte Folded Spill
	ldp	x25, x21, [x8, #32]
	ldp	x23, x9, [x8, #56]
	stp	x8, x11, [sp, #360]             ; 16-byte Folded Spill
	ldr	x8, [x8, #72]
	stp	x8, x9, [sp, #344]              ; 16-byte Folded Spill
	ldp	x19, x8, [x0, #16]
	str	x8, [sp, #272]                  ; 8-byte Folded Spill
	ldp	x9, x24, [x0, #32]
	ldp	x11, x8, [x0, #56]
	stp	x8, x11, [sp, #216]             ; 16-byte Folded Spill
	ldr	x8, [x0, #72]
	str	x8, [sp, #208]                  ; 8-byte Folded Spill
	ldr	x8, [x27, #24]
	stp	x8, x9, [sp, #384]              ; 16-byte Folded Spill
	ldp	x9, x8, [x27, #48]
	str	x9, [sp, #336]                  ; 8-byte Folded Spill
	str	x8, [sp, #472]                  ; 8-byte Folded Spill
	ldp	x9, x8, [x27, #64]
	stp	x8, x9, [sp, #248]              ; 16-byte Folded Spill
	str	x0, [sp, #240]                  ; 8-byte Folded Spill
	str	x10, [sp, #184]                 ; 8-byte Folded Spill
	bl	_ggml_is_contiguous
	str	w0, [sp, #376]                  ; 4-byte Folded Spill
	ldr	x8, [sp, #152]                  ; 8-byte Folded Reload
	ldr	x9, [sp, #184]                  ; 8-byte Folded Reload
	cmp	x9, x8
	b.le	LBB24_216
; %bb.197:                              ;   in Loop: Header=BB24_192 Depth=2
	ldr	x8, [sp, #144]                  ; 8-byte Folded Reload
	cmp	x8, x22
	b.le	LBB24_216
; %bb.198:                              ;   in Loop: Header=BB24_192 Depth=2
	mov	x28, x21
Lloh300:
	adrp	x8, _type_traits_cpu@PAGE
Lloh301:
	add	x8, x8, _type_traits_cpu@PAGEOFF
	add	x8, x8, x26, lsl #5
	ldr	x9, [x8, #8]
	str	x9, [sp, #328]                  ; 8-byte Folded Spill
	ldr	w0, [x8, #16]
	ldr	x8, [sp, #240]                  ; 8-byte Folded Reload
	ldr	w9, [x8], #248
	cmp	w9, w0
	ldr	x9, [sp, #128]                  ; 8-byte Folded Reload
	csel	x8, x8, x9, eq
	ldr	x26, [x8]
	str	w0, [sp, #232]                  ; 4-byte Folded Spill
	mov	x1, x19
	bl	_ggml_row_size
	str	x0, [sp, #264]                  ; 8-byte Folded Spill
	mov	x8, x0
	ldr	w9, [sp, #376]                  ; 4-byte Folded Reload
	tbnz	w9, #0, LBB24_200
; %bb.199:                              ;   in Loop: Header=BB24_192 Depth=2
	ldr	x8, [sp, #240]                  ; 8-byte Folded Reload
	ldr	w8, [x8]
	ldr	w9, [sp, #232]                  ; 4-byte Folded Reload
	cmp	w8, w9
	ldr	x8, [sp, #224]                  ; 8-byte Folded Reload
	ldr	x9, [sp, #264]                  ; 8-byte Folded Reload
	csel	x8, x8, x9, eq
LBB24_200:                              ;   in Loop: Header=BB24_192 Depth=2
	ldr	x9, [sp, #392]                  ; 8-byte Folded Reload
	sdiv	x11, x9, x25
	ldr	x10, [sp, #384]                 ; 8-byte Folded Reload
	mul	x9, x10, x9
	stp	x9, x11, [sp, #312]             ; 16-byte Folded Spill
	ldr	x10, [sp, #368]                 ; 8-byte Folded Reload
	cmp	x10, #1
	csel	x14, x23, xzr, gt
	cset	w9, gt
	ubfiz	x15, x9, #4, #32
	csel	x21, x8, xzr, gt
	ldr	x8, [sp, #80]                   ; 8-byte Folded Reload
	mul	x8, x8, x23
	mul	x8, x8, x20
	str	x8, [sp, #136]                  ; 8-byte Folded Spill
	lsl	x8, x23, #4
	str	x8, [sp, #176]                  ; 8-byte Folded Spill
	mul	x16, x10, x23
	lsl	x17, x10, #2
	sdiv	x8, x24, x28
	stp	x8, x17, [sp, #288]             ; 16-byte Folded Spill
	ldr	x8, [sp, #184]                  ; 8-byte Folded Reload
	ldr	x9, [sp, #144]                  ; 8-byte Folded Reload
	stp	x21, x26, [sp, #480]            ; 16-byte Folded Spill
	str	x16, [sp, #304]                 ; 8-byte Folded Spill
	str	x14, [sp, #280]                 ; 8-byte Folded Spill
	b	LBB24_202
LBB24_201:                              ;   in Loop: Header=BB24_202 Depth=3
	ldr	x10, [sp, #168]                 ; 8-byte Folded Reload
	mov	x22, x10
	ldr	x9, [sp, #144]                  ; 8-byte Folded Reload
	cmp	x10, x9
	b.ge	LBB24_215
LBB24_202:                              ;   Parent Loop BB24_7 Depth=1
                                        ;     Parent Loop BB24_192 Depth=2
                                        ; =>    This Loop Header: Depth=3
                                        ;         Child Loop BB24_204 Depth 4
                                        ;           Child Loop BB24_206 Depth 5
                                        ;             Child Loop BB24_211 Depth 6
                                        ;             Child Loop BB24_214 Depth 6
	add	x10, x22, #16
	cmp	x10, x9
	str	x10, [sp, #168]                 ; 8-byte Folded Spill
	csel	x9, x10, x9, lt
	str	x9, [sp, #400]                  ; 8-byte Folded Spill
	ldr	x9, [sp, #136]                  ; 8-byte Folded Reload
	str	x9, [sp, #416]                  ; 8-byte Folded Spill
	ldr	x0, [sp, #152]                  ; 8-byte Folded Reload
	str	x22, [sp, #192]                 ; 8-byte Folded Spill
	b	LBB24_204
LBB24_203:                              ;   in Loop: Header=BB24_204 Depth=4
	ldp	x10, x8, [sp, #176]             ; 16-byte Folded Reload
	ldr	x9, [sp, #416]                  ; 8-byte Folded Reload
	add	x9, x9, x10
	str	x9, [sp, #416]                  ; 8-byte Folded Spill
	ldp	x22, x9, [sp, #192]             ; 16-byte Folded Reload
	mov	x0, x9
	cmp	x9, x8
	b.ge	LBB24_201
LBB24_204:                              ;   Parent Loop BB24_7 Depth=1
                                        ;     Parent Loop BB24_192 Depth=2
                                        ;       Parent Loop BB24_202 Depth=3
                                        ; =>      This Loop Header: Depth=4
                                        ;           Child Loop BB24_206 Depth 5
                                        ;             Child Loop BB24_211 Depth 6
                                        ;             Child Loop BB24_214 Depth 6
	add	x9, x0, #16
	cmp	x9, x8
	str	x9, [sp, #200]                  ; 8-byte Folded Spill
	csel	x1, x9, x8, lt
	sub	x8, x1, x0
	lsl	x8, x8, #2
	str	x8, [sp, #408]                  ; 8-byte Folded Spill
	str	x0, [sp, #456]                  ; 8-byte Folded Spill
	str	x1, [sp, #504]                  ; 8-byte Folded Spill
	b	LBB24_206
LBB24_205:                              ;   in Loop: Header=BB24_206 Depth=5
	ldp	x0, x22, [sp, #456]             ; 16-byte Folded Reload
	add	x22, x22, x19
	ldr	x8, [sp, #400]                  ; 8-byte Folded Reload
	cmp	x22, x8
	ldr	x27, [sp, #424]                 ; 8-byte Folded Reload
	ldr	x14, [sp, #280]                 ; 8-byte Folded Reload
	mov	x15, x24
	ldp	x17, x16, [sp, #296]            ; 16-byte Folded Reload
	b.ge	LBB24_203
LBB24_206:                              ;   Parent Loop BB24_7 Depth=1
                                        ;     Parent Loop BB24_192 Depth=2
                                        ;       Parent Loop BB24_202 Depth=3
                                        ;         Parent Loop BB24_204 Depth=4
                                        ; =>        This Loop Header: Depth=5
                                        ;             Child Loop BB24_211 Depth 6
                                        ;             Child Loop BB24_214 Depth 6
	ldr	x8, [sp, #312]                  ; 8-byte Folded Reload
	sdiv	x2, x22, x8
	ldp	x9, x8, [sp, #384]              ; 16-byte Folded Reload
	mul	x10, x2, x8
	str	x22, [sp, #464]                 ; 8-byte Folded Spill
	msub	x8, x10, x9, x22
	sdiv	x3, x8, x9
	msub	x8, x3, x9, x8
	ldr	x9, [sp, #360]                  ; 8-byte Folded Reload
	ldr	x9, [x9, #248]
	ldr	x13, [sp, #472]                 ; 8-byte Folded Reload
	ldr	w11, [sp, #376]                 ; 4-byte Folded Reload
	ldr	x30, [sp, #328]                 ; 8-byte Folded Reload
	tbnz	w11, #0, LBB24_209
; %bb.207:                              ;   in Loop: Header=BB24_206 Depth=5
	ldr	x11, [sp, #240]                 ; 8-byte Folded Reload
	ldr	w11, [x11]
	ldr	w12, [sp, #232]                 ; 4-byte Folded Reload
	cmp	w11, w12
	b.ne	LBB24_209
; %bb.208:                              ;   in Loop: Header=BB24_206 Depth=5
	ldp	x10, x11, [sp, #208]            ; 16-byte Folded Reload
	mul	x10, x2, x10
	madd	x10, x3, x11, x10
	ldr	x11, [sp, #224]                 ; 8-byte Folded Reload
	madd	x23, x8, x11, x10
	b	LBB24_210
LBB24_209:                              ;   in Loop: Header=BB24_206 Depth=5
	add	x10, x10, x3
	ldr	x11, [sp, #272]                 ; 8-byte Folded Reload
	madd	x10, x10, x11, x8
	ldr	x11, [sp, #264]                 ; 8-byte Folded Reload
	mul	x23, x10, x11
LBB24_210:                              ;   in Loop: Header=BB24_206 Depth=5
	ldr	x10, [sp, #320]                 ; 8-byte Folded Reload
	stp	x3, x2, [sp, #440]              ; 16-byte Folded Spill
	sdiv	x10, x3, x10
	ldp	x12, x11, [sp, #344]            ; 16-byte Folded Reload
	mul	x10, x10, x11
	ldr	x11, [sp, #288]                 ; 8-byte Folded Reload
	sdiv	x11, x2, x11
	mul	x11, x11, x12
	ldr	x12, [x27, #248]
	madd	x8, x8, x13, x12
	str	x8, [sp, #432]                  ; 8-byte Folded Spill
	ldr	x8, [sp, #416]                  ; 8-byte Folded Reload
	add	x8, x9, x8
	add	x9, x11, x10
	add	x22, x8, x9
	sub	x25, x29, #224
	mov	x27, x0
	mov	x20, x14
	mov	x24, x15
	ldr	x19, [sp, #368]                 ; 8-byte Folded Reload
	mov	x26, x16
	mov	x28, x17
LBB24_211:                              ;   Parent Loop BB24_7 Depth=1
                                        ;     Parent Loop BB24_192 Depth=2
                                        ;       Parent Loop BB24_202 Depth=3
                                        ;         Parent Loop BB24_204 Depth=4
                                        ;           Parent Loop BB24_206 Depth=5
                                        ; =>          This Inner Loop Header: Depth=6
	ldp	x8, x0, [sp, #488]              ; 16-byte Folded Reload
	add	x5, x8, x23
                                        ; kill: def $w0 killed $w0 killed $x0
	mov	x1, x25
	mov	x2, x24
	mov	x3, x22
	mov	x4, x20
	ldr	x6, [sp, #480]                  ; 8-byte Folded Reload
	mov	x7, x19
	mov	x21, x30
	blr	x30
	mov	x30, x21
	add	x22, x22, x26
	add	x25, x25, x28
	add	x27, x27, x19
	ldr	x8, [sp, #504]                  ; 8-byte Folded Reload
	cmp	x27, x8
	b.lt	LBB24_211
; %bb.212:                              ;   in Loop: Header=BB24_206 Depth=5
	cmp	x19, #1
	ldr	x28, [sp, #336]                 ; 8-byte Folded Reload
	ldr	x23, [sp, #472]                 ; 8-byte Folded Reload
	ldr	x20, [sp, #408]                 ; 8-byte Folded Reload
	b.lt	LBB24_205
; %bb.213:                              ;   in Loop: Header=BB24_206 Depth=5
	mov	x25, #0                         ; =0x0
	ldr	x8, [sp, #256]                  ; 8-byte Folded Reload
	ldp	x9, x10, [sp, #440]             ; 16-byte Folded Reload
	mul	x8, x9, x8
	ldr	x9, [sp, #248]                  ; 8-byte Folded Reload
	mul	x9, x10, x9
	ldr	x10, [sp, #432]                 ; 8-byte Folded Reload
	add	x8, x10, x8
	add	x8, x8, x9
	ldr	x9, [sp, #456]                  ; 8-byte Folded Reload
	add	x26, x8, x9, lsl #2
	sub	x22, x29, #224
	mov	x27, x19
LBB24_214:                              ;   Parent Loop BB24_7 Depth=1
                                        ;     Parent Loop BB24_192 Depth=2
                                        ;       Parent Loop BB24_202 Depth=3
                                        ;         Parent Loop BB24_204 Depth=4
                                        ;           Parent Loop BB24_206 Depth=5
                                        ; =>          This Inner Loop Header: Depth=6
	udiv	x8, x25, x28
	add	x0, x26, x8, lsl #2
	mov	x1, x22
	mov	x2, x20
	bl	_memcpy
	add	x22, x22, #64
	add	x25, x25, x23
	subs	x27, x27, #1
	b.ne	LBB24_214
	b	LBB24_205
LBB24_215:                              ;   in Loop: Header=BB24_192 Depth=2
	ldr	x28, [sp, #24]                  ; 8-byte Folded Reload
LBB24_216:                              ;   in Loop: Header=BB24_192 Depth=2
	ldr	x8, [sp, #160]                  ; 8-byte Folded Reload
	ldr	x12, [sp, #48]                  ; 8-byte Folded Reload
	cmp	x12, x8
	ldp	x26, x25, [sp, #88]             ; 16-byte Folded Reload
	ldp	x23, x22, [sp, #112]            ; 16-byte Folded Reload
	ldr	x24, [sp, #104]                 ; 8-byte Folded Reload
	mov	w19, #1                         ; =0x1
Lloh302:
	adrp	x20, lJTI24_0@PAGE
Lloh303:
	add	x20, x20, lJTI24_0@PAGEOFF
	b.le	LBB24_11
; %bb.217:                              ;   in Loop: Header=BB24_192 Depth=2
	ldur	x8, [x29, #-232]
	add	x8, x8, #320
	mov	w9, #1                          ; =0x1
	ldadd	w9, w8, [x8]
	sxtw	x17, w8
	cmp	x12, x17
	b.gt	LBB24_192
	b	LBB24_11
LBB24_218:
	ldr	x8, [x25, #528]
	ldr	w9, [x8, #348]
	subs	w10, w9, #1
	b.eq	LBB24_224
; %bb.219:
	ldr	w9, [x8, #256]
	add	x12, x8, #192
	mov	w11, #1                         ; =0x1
	ldaddal	w11, w12, [x12]
	cmp	w12, w10
	b.ne	LBB24_221
; %bb.220:
	str	wzr, [x8, #192]
	add	x8, x8, #256
	ldaddal	w11, w8, [x8]
	b	LBB24_224
LBB24_221:                              ; =>This Inner Loop Header: Depth=1
	ldr	w10, [x8, #256]
	cmp	w10, w9
	b.ne	LBB24_223
; %bb.222:                              ;   in Loop: Header=BB24_221 Depth=1
	; InlineAsm Start
	yield
	; InlineAsm End
	b	LBB24_221
LBB24_223:
	dmb	ish
LBB24_224:
	ldur	x8, [x29, #-96]
Lloh304:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh305:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh306:
	ldr	x9, [x9]
	cmp	x9, x8
	b.ne	LBB24_226
; %bb.225:
	add	sp, sp, #688
	ldp	x29, x30, [sp, #80]             ; 16-byte Folded Reload
	ldp	x20, x19, [sp, #64]             ; 16-byte Folded Reload
	ldp	x22, x21, [sp, #48]             ; 16-byte Folded Reload
	ldp	x24, x23, [sp, #32]             ; 16-byte Folded Reload
	ldp	x26, x25, [sp, #16]             ; 16-byte Folded Reload
	ldp	x28, x27, [sp], #96             ; 16-byte Folded Reload
	ret
LBB24_226:
	bl	___stack_chk_fail
LBB24_227:
Lloh307:
	adrp	x0, l_.str.1@PAGE
Lloh308:
	add	x0, x0, l_.str.1@PAGEOFF
Lloh309:
	adrp	x2, l_.str.4@PAGE
Lloh310:
	add	x2, x2, l_.str.4@PAGEOFF
	mov	w1, #2070                       ; =0x816
	bl	_ggml_abort
LBB24_228:
Lloh311:
	adrp	x8, l_.str.40@PAGE
Lloh312:
	add	x8, x8, l_.str.40@PAGEOFF
Lloh313:
	adrp	x0, l_.str.1@PAGE
Lloh314:
	add	x0, x0, l_.str.1@PAGEOFF
	str	x8, [sp]
Lloh315:
	adrp	x2, l_.str.2@PAGE
Lloh316:
	add	x2, x2, l_.str.2@PAGEOFF
	mov	w1, #1556                       ; =0x614
	bl	_ggml_abort
LBB24_229:
Lloh317:
	adrp	x8, l_.str.34@PAGE
Lloh318:
	add	x8, x8, l_.str.34@PAGEOFF
Lloh319:
	adrp	x0, l_.str.1@PAGE
Lloh320:
	add	x0, x0, l_.str.1@PAGEOFF
	str	x8, [sp]
Lloh321:
	adrp	x2, l_.str.2@PAGE
Lloh322:
	add	x2, x2, l_.str.2@PAGEOFF
	mov	w1, #1557                       ; =0x615
	bl	_ggml_abort
LBB24_230:
Lloh323:
	adrp	x8, l_.str.35@PAGE
Lloh324:
	add	x8, x8, l_.str.35@PAGEOFF
Lloh325:
	adrp	x0, l_.str.1@PAGE
Lloh326:
	add	x0, x0, l_.str.1@PAGEOFF
	str	x8, [sp]
Lloh327:
	adrp	x2, l_.str.2@PAGE
Lloh328:
	add	x2, x2, l_.str.2@PAGEOFF
	mov	w1, #1560                       ; =0x618
	bl	_ggml_abort
LBB24_231:
Lloh329:
	adrp	x8, l_.str.36@PAGE
Lloh330:
	add	x8, x8, l_.str.36@PAGEOFF
Lloh331:
	adrp	x0, l_.str.1@PAGE
Lloh332:
	add	x0, x0, l_.str.1@PAGEOFF
	str	x8, [sp]
Lloh333:
	adrp	x2, l_.str.2@PAGE
Lloh334:
	add	x2, x2, l_.str.2@PAGEOFF
	mov	w1, #1561                       ; =0x619
	bl	_ggml_abort
LBB24_232:
Lloh335:
	adrp	x8, l_.str.37@PAGE
Lloh336:
	add	x8, x8, l_.str.37@PAGEOFF
Lloh337:
	adrp	x0, l_.str.1@PAGE
Lloh338:
	add	x0, x0, l_.str.1@PAGEOFF
	str	x8, [sp]
Lloh339:
	adrp	x2, l_.str.2@PAGE
Lloh340:
	add	x2, x2, l_.str.2@PAGEOFF
	mov	w1, #1562                       ; =0x61a
	bl	_ggml_abort
LBB24_233:
Lloh341:
	adrp	x8, l_.str.38@PAGE
Lloh342:
	add	x8, x8, l_.str.38@PAGEOFF
Lloh343:
	adrp	x0, l_.str.1@PAGE
Lloh344:
	add	x0, x0, l_.str.1@PAGEOFF
	str	x8, [sp]
Lloh345:
	adrp	x2, l_.str.2@PAGE
Lloh346:
	add	x2, x2, l_.str.2@PAGEOFF
	mov	w1, #1563                       ; =0x61b
	bl	_ggml_abort
LBB24_234:
Lloh347:
	adrp	x8, l_.str.28@PAGE
Lloh348:
	add	x8, x8, l_.str.28@PAGEOFF
Lloh349:
	adrp	x0, l_.str.1@PAGE
Lloh350:
	add	x0, x0, l_.str.1@PAGEOFF
	str	x8, [sp]
Lloh351:
	adrp	x2, l_.str.2@PAGE
Lloh352:
	add	x2, x2, l_.str.2@PAGEOFF
	mov	w1, #1985                       ; =0x7c1
	bl	_ggml_abort
LBB24_235:
Lloh353:
	adrp	x8, l_.str.29@PAGE
Lloh354:
	add	x8, x8, l_.str.29@PAGEOFF
Lloh355:
	adrp	x0, l_.str.1@PAGE
Lloh356:
	add	x0, x0, l_.str.1@PAGEOFF
	str	x8, [sp]
Lloh357:
	adrp	x2, l_.str.2@PAGE
Lloh358:
	add	x2, x2, l_.str.2@PAGEOFF
	mov	w1, #1277                       ; =0x4fd
	bl	_ggml_abort
LBB24_236:
Lloh359:
	adrp	x8, l_.str.30@PAGE
Lloh360:
	add	x8, x8, l_.str.30@PAGEOFF
Lloh361:
	adrp	x0, l_.str.1@PAGE
Lloh362:
	add	x0, x0, l_.str.1@PAGEOFF
	str	x8, [sp]
Lloh363:
	adrp	x2, l_.str.2@PAGE
Lloh364:
	add	x2, x2, l_.str.2@PAGEOFF
	mov	w1, #1278                       ; =0x4fe
	bl	_ggml_abort
LBB24_237:
Lloh365:
	adrp	x8, l_.str.31@PAGE
Lloh366:
	add	x8, x8, l_.str.31@PAGEOFF
Lloh367:
	adrp	x0, l_.str.1@PAGE
Lloh368:
	add	x0, x0, l_.str.1@PAGEOFF
	str	x8, [sp]
Lloh369:
	adrp	x2, l_.str.2@PAGE
Lloh370:
	add	x2, x2, l_.str.2@PAGEOFF
	mov	w1, #1279                       ; =0x4ff
	bl	_ggml_abort
LBB24_238:
Lloh371:
	adrp	x8, l_.str.32@PAGE
Lloh372:
	add	x8, x8, l_.str.32@PAGEOFF
Lloh373:
	adrp	x0, l_.str.1@PAGE
Lloh374:
	add	x0, x0, l_.str.1@PAGEOFF
	str	x8, [sp]
Lloh375:
	adrp	x2, l_.str.2@PAGE
Lloh376:
	add	x2, x2, l_.str.2@PAGEOFF
	mov	w1, #1280                       ; =0x500
	bl	_ggml_abort
LBB24_239:
Lloh377:
	adrp	x8, l_.str.33@PAGE
Lloh378:
	add	x8, x8, l_.str.33@PAGEOFF
Lloh379:
	adrp	x0, l_.str.1@PAGE
Lloh380:
	add	x0, x0, l_.str.1@PAGEOFF
	str	x8, [sp]
Lloh381:
	adrp	x2, l_.str.2@PAGE
Lloh382:
	add	x2, x2, l_.str.2@PAGEOFF
	mov	w1, #1283                       ; =0x503
	bl	_ggml_abort
LBB24_240:
Lloh383:
	adrp	x8, l_.str.34@PAGE
Lloh384:
	add	x8, x8, l_.str.34@PAGEOFF
Lloh385:
	adrp	x0, l_.str.1@PAGE
Lloh386:
	add	x0, x0, l_.str.1@PAGEOFF
	str	x8, [sp]
Lloh387:
	adrp	x2, l_.str.2@PAGE
Lloh388:
	add	x2, x2, l_.str.2@PAGEOFF
	mov	w1, #1284                       ; =0x504
	bl	_ggml_abort
LBB24_241:
Lloh389:
	adrp	x8, l_.str.35@PAGE
Lloh390:
	add	x8, x8, l_.str.35@PAGEOFF
Lloh391:
	adrp	x0, l_.str.1@PAGE
Lloh392:
	add	x0, x0, l_.str.1@PAGEOFF
	str	x8, [sp]
Lloh393:
	adrp	x2, l_.str.2@PAGE
Lloh394:
	add	x2, x2, l_.str.2@PAGEOFF
	mov	w1, #1287                       ; =0x507
	bl	_ggml_abort
LBB24_242:
Lloh395:
	adrp	x8, l_.str.36@PAGE
Lloh396:
	add	x8, x8, l_.str.36@PAGEOFF
Lloh397:
	adrp	x0, l_.str.1@PAGE
Lloh398:
	add	x0, x0, l_.str.1@PAGEOFF
	str	x8, [sp]
Lloh399:
	adrp	x2, l_.str.2@PAGE
Lloh400:
	add	x2, x2, l_.str.2@PAGEOFF
	mov	w1, #1288                       ; =0x508
	bl	_ggml_abort
LBB24_243:
Lloh401:
	adrp	x8, l_.str.37@PAGE
Lloh402:
	add	x8, x8, l_.str.37@PAGEOFF
Lloh403:
	adrp	x0, l_.str.1@PAGE
Lloh404:
	add	x0, x0, l_.str.1@PAGEOFF
	str	x8, [sp]
Lloh405:
	adrp	x2, l_.str.2@PAGE
Lloh406:
	add	x2, x2, l_.str.2@PAGEOFF
	mov	w1, #1289                       ; =0x509
	bl	_ggml_abort
LBB24_244:
Lloh407:
	adrp	x8, l_.str.38@PAGE
Lloh408:
	add	x8, x8, l_.str.38@PAGEOFF
Lloh409:
	adrp	x0, l_.str.1@PAGE
Lloh410:
	add	x0, x0, l_.str.1@PAGEOFF
	str	x8, [sp]
Lloh411:
	adrp	x2, l_.str.2@PAGE
Lloh412:
	add	x2, x2, l_.str.2@PAGEOFF
	mov	w1, #1290                       ; =0x50a
	bl	_ggml_abort
LBB24_245:
Lloh413:
	adrp	x8, l_.str.41@PAGE
Lloh414:
	add	x8, x8, l_.str.41@PAGEOFF
Lloh415:
	adrp	x0, l_.str.1@PAGE
Lloh416:
	add	x0, x0, l_.str.1@PAGEOFF
	str	x8, [sp]
Lloh417:
	adrp	x2, l_.str.2@PAGE
Lloh418:
	add	x2, x2, l_.str.2@PAGEOFF
	mov	w1, #1584                       ; =0x630
	bl	_ggml_abort
LBB24_246:
Lloh419:
	adrp	x8, l_.str.39@PAGE
Lloh420:
	add	x8, x8, l_.str.39@PAGEOFF
Lloh421:
	adrp	x0, l_.str.1@PAGE
Lloh422:
	add	x0, x0, l_.str.1@PAGEOFF
	str	x8, [sp]
Lloh423:
	adrp	x2, l_.str.2@PAGE
Lloh424:
	add	x2, x2, l_.str.2@PAGEOFF
	mov	w1, #1332                       ; =0x534
	bl	_ggml_abort
LBB24_247:
Lloh425:
	adrp	x8, l_.str.39@PAGE
Lloh426:
	add	x8, x8, l_.str.39@PAGEOFF
Lloh427:
	adrp	x0, l_.str.1@PAGE
Lloh428:
	add	x0, x0, l_.str.1@PAGEOFF
	str	x8, [sp]
Lloh429:
	adrp	x2, l_.str.2@PAGE
Lloh430:
	add	x2, x2, l_.str.2@PAGEOFF
	mov	w1, #1595                       ; =0x63b
	bl	_ggml_abort
	.loh AdrpLdrGotLdr	Lloh278, Lloh279, Lloh280
	.loh AdrpAdd	Lloh284, Lloh285
	.loh AdrpLdrGotLdr	Lloh281, Lloh282, Lloh283
	.loh AdrpAdd	Lloh286, Lloh287
	.loh AdrpAdd	Lloh288, Lloh289
	.loh AdrpAdd	Lloh290, Lloh291
	.loh AdrpAdd	Lloh292, Lloh293
	.loh AdrpAdd	Lloh294, Lloh295
	.loh AdrpAdd	Lloh296, Lloh297
	.loh AdrpAdd	Lloh298, Lloh299
	.loh AdrpAdd	Lloh300, Lloh301
	.loh AdrpAdd	Lloh302, Lloh303
	.loh AdrpLdrGotLdr	Lloh304, Lloh305, Lloh306
	.loh AdrpAdd	Lloh309, Lloh310
	.loh AdrpAdd	Lloh307, Lloh308
	.loh AdrpAdd	Lloh315, Lloh316
	.loh AdrpAdd	Lloh313, Lloh314
	.loh AdrpAdd	Lloh311, Lloh312
	.loh AdrpAdd	Lloh321, Lloh322
	.loh AdrpAdd	Lloh319, Lloh320
	.loh AdrpAdd	Lloh317, Lloh318
	.loh AdrpAdd	Lloh327, Lloh328
	.loh AdrpAdd	Lloh325, Lloh326
	.loh AdrpAdd	Lloh323, Lloh324
	.loh AdrpAdd	Lloh333, Lloh334
	.loh AdrpAdd	Lloh331, Lloh332
	.loh AdrpAdd	Lloh329, Lloh330
	.loh AdrpAdd	Lloh339, Lloh340
	.loh AdrpAdd	Lloh337, Lloh338
	.loh AdrpAdd	Lloh335, Lloh336
	.loh AdrpAdd	Lloh345, Lloh346
	.loh AdrpAdd	Lloh343, Lloh344
	.loh AdrpAdd	Lloh341, Lloh342
	.loh AdrpAdd	Lloh351, Lloh352
	.loh AdrpAdd	Lloh349, Lloh350
	.loh AdrpAdd	Lloh347, Lloh348
	.loh AdrpAdd	Lloh357, Lloh358
	.loh AdrpAdd	Lloh355, Lloh356
	.loh AdrpAdd	Lloh353, Lloh354
	.loh AdrpAdd	Lloh363, Lloh364
	.loh AdrpAdd	Lloh361, Lloh362
	.loh AdrpAdd	Lloh359, Lloh360
	.loh AdrpAdd	Lloh369, Lloh370
	.loh AdrpAdd	Lloh367, Lloh368
	.loh AdrpAdd	Lloh365, Lloh366
	.loh AdrpAdd	Lloh375, Lloh376
	.loh AdrpAdd	Lloh373, Lloh374
	.loh AdrpAdd	Lloh371, Lloh372
	.loh AdrpAdd	Lloh381, Lloh382
	.loh AdrpAdd	Lloh379, Lloh380
	.loh AdrpAdd	Lloh377, Lloh378
	.loh AdrpAdd	Lloh387, Lloh388
	.loh AdrpAdd	Lloh385, Lloh386
	.loh AdrpAdd	Lloh383, Lloh384
	.loh AdrpAdd	Lloh393, Lloh394
	.loh AdrpAdd	Lloh391, Lloh392
	.loh AdrpAdd	Lloh389, Lloh390
	.loh AdrpAdd	Lloh399, Lloh400
	.loh AdrpAdd	Lloh397, Lloh398
	.loh AdrpAdd	Lloh395, Lloh396
	.loh AdrpAdd	Lloh405, Lloh406
	.loh AdrpAdd	Lloh403, Lloh404
	.loh AdrpAdd	Lloh401, Lloh402
	.loh AdrpAdd	Lloh411, Lloh412
	.loh AdrpAdd	Lloh409, Lloh410
	.loh AdrpAdd	Lloh407, Lloh408
	.loh AdrpAdd	Lloh417, Lloh418
	.loh AdrpAdd	Lloh415, Lloh416
	.loh AdrpAdd	Lloh413, Lloh414
	.loh AdrpAdd	Lloh423, Lloh424
	.loh AdrpAdd	Lloh421, Lloh422
	.loh AdrpAdd	Lloh419, Lloh420
	.loh AdrpAdd	Lloh429, Lloh430
	.loh AdrpAdd	Lloh427, Lloh428
	.loh AdrpAdd	Lloh425, Lloh426
	.cfi_endproc
	.p2align	2
lJTI24_0:
	.long	LBB24_23-Ltmp0
	.long	LBB24_72-Ltmp0
	.long	LBB24_66-Ltmp0
	.long	LBB24_68-Ltmp0
	.long	LBB24_57-Ltmp0
	.long	LBB24_77-Ltmp0
	.long	LBB24_78-Ltmp0
	.long	LBB24_69-Ltmp0
	.long	LBB24_85-Ltmp0
	.long	LBB24_60-Ltmp0
	.long	LBB24_86-Ltmp0
	.long	LBB24_55-Ltmp0
	.long	LBB24_61-Ltmp0
	.long	LBB24_79-Ltmp0
	.long	LBB24_51-Ltmp0
	.long	LBB24_67-Ltmp0
	.long	LBB24_49-Ltmp0
	.long	LBB24_73-Ltmp0
	.long	LBB24_87-Ltmp0
	.long	LBB24_92-Ltmp0
	.long	LBB24_80-Ltmp0
	.long	LBB24_81-Ltmp0
	.long	LBB24_91-Ltmp0
	.long	LBB24_97-Ltmp0
	.long	LBB24_64-Ltmp0
	.long	LBB24_65-Ltmp0
	.long	LBB24_101-Ltmp0
	.long	LBB24_40-Ltmp0
	.long	LBB24_98-Ltmp0
	.long	LBB24_99-Ltmp0
	.long	LBB24_88-Ltmp0
	.long	LBB24_74-Ltmp0
	.long	LBB24_89-Ltmp0
	.long	LBB24_53-Ltmp0
	.long	LBB24_48-Ltmp0
	.long	LBB24_37-Ltmp0
	.long	LBB24_38-Ltmp0
	.long	LBB24_30-Ltmp0
	.long	LBB24_100-Ltmp0
	.long	LBB24_93-Ltmp0
	.long	LBB24_58-Ltmp0
	.long	LBB24_75-Ltmp0
	.long	LBB24_94-Ltmp0
	.long	LBB24_28-Ltmp0
	.long	LBB24_52-Ltmp0
	.long	LBB24_90-Ltmp0
	.long	LBB24_125-Ltmp0
	.long	LBB24_31-Ltmp0
	.long	LBB24_54-Ltmp0
	.long	LBB24_59-Ltmp0
	.long	LBB24_27-Ltmp0
	.long	LBB24_129-Ltmp0
	.long	LBB24_126-Ltmp0
	.long	LBB24_32-Ltmp0
	.long	LBB24_122-Ltmp0
	.long	LBB24_124-Ltmp0
	.long	LBB24_35-Ltmp0
	.long	LBB24_95-Ltmp0
	.long	LBB24_56-Ltmp0
	.long	LBB24_96-Ltmp0
	.long	LBB24_62-Ltmp0
	.long	LBB24_82-Ltmp0
	.long	LBB24_83-Ltmp0
	.long	LBB24_70-Ltmp0
	.long	LBB24_63-Ltmp0
	.long	LBB24_84-Ltmp0
	.long	LBB24_29-Ltmp0
	.long	LBB24_50-Ltmp0
	.long	LBB24_131-Ltmp0
	.long	LBB24_39-Ltmp0
	.long	LBB24_25-Ltmp0
	.long	LBB24_33-Ltmp0
	.long	LBB24_123-Ltmp0
	.long	LBB24_127-Ltmp0
	.long	LBB24_128-Ltmp0
	.long	LBB24_36-Ltmp0
	.long	LBB24_76-Ltmp0
	.long	LBB24_26-Ltmp0
	.long	LBB24_130-Ltmp0
	.long	LBB24_24-Ltmp0
	.long	LBB24_34-Ltmp0
	.long	LBB24_227-Ltmp0
                                        ; -- End function
	.globl	_ggml_graph_compute_with_ctx    ; -- Begin function ggml_graph_compute_with_ctx
	.p2align	2
_ggml_graph_compute_with_ctx:           ; @ggml_graph_compute_with_ctx
	.cfi_startproc
; %bb.0:
	sub	sp, sp, #80
	stp	x20, x19, [sp, #48]             ; 16-byte Folded Spill
	stp	x29, x30, [sp, #64]             ; 16-byte Folded Spill
	add	x29, sp, #64
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	mov	x19, x1
	mov	x20, x0
	mov	x8, sp
	mov	x0, x1
	mov	x1, x2
	mov	x2, #0                          ; =0x0
	bl	_ggml_graph_plan
	ldr	x1, [sp]
	mov	x0, x20
	bl	_ggml_new_buffer
	str	x0, [sp, #8]
	mov	x1, sp
	mov	x0, x19
	bl	_ggml_graph_compute
	ldp	x29, x30, [sp, #64]             ; 16-byte Folded Reload
	ldp	x20, x19, [sp, #48]             ; 16-byte Folded Reload
	add	sp, sp, #80
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_ggml_cpu_fp32_to_fp16          ; -- Begin function ggml_cpu_fp32_to_fp16
	.p2align	2
_ggml_cpu_fp32_to_fp16:                 ; @ggml_cpu_fp32_to_fp16
	.cfi_startproc
; %bb.0:
	cmp	x2, #1
	b.lt	LBB26_8
; %bb.1:
	cmp	x2, #32
	b.hs	LBB26_3
; %bb.2:
	mov	x8, #0                          ; =0x0
	b	LBB26_6
LBB26_3:
	and	x8, x2, #0x7fffffffffffffe0
	add	x9, x1, #32
	add	x10, x0, #64
	mov	x11, x8
LBB26_4:                                ; =>This Inner Loop Header: Depth=1
	ldp	q1, q0, [x10, #-64]
	ldp	q3, q2, [x10, #-32]
	ldp	q5, q4, [x10]
	ldp	q7, q6, [x10, #32]
	fcvtn	v1.4h, v1.4s
	fcvtn2	v1.8h, v0.4s
	fcvtn	v0.4h, v3.4s
	fcvtn2	v0.8h, v2.4s
	fcvtn	v2.4h, v5.4s
	fcvtn2	v2.8h, v4.4s
	fcvtn	v3.4h, v7.4s
	fcvtn2	v3.8h, v6.4s
	stp	q1, q0, [x9, #-32]
	stp	q2, q3, [x9], #64
	add	x10, x10, #128
	subs	x11, x11, #32
	b.ne	LBB26_4
; %bb.5:
	cmp	x8, x2
	b.eq	LBB26_8
LBB26_6:
	sub	x9, x2, x8
	add	x10, x1, x8, lsl #1
	add	x8, x0, x8, lsl #2
LBB26_7:                                ; =>This Inner Loop Header: Depth=1
	ldr	s0, [x8], #4
	fcvt	h0, s0
	str	h0, [x10], #2
	subs	x9, x9, #1
	b.ne	LBB26_7
LBB26_8:
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_ggml_cpu_fp16_to_fp32          ; -- Begin function ggml_cpu_fp16_to_fp32
	.p2align	2
_ggml_cpu_fp16_to_fp32:                 ; @ggml_cpu_fp16_to_fp32
	.cfi_startproc
; %bb.0:
	cmp	x2, #1
	b.lt	LBB27_8
; %bb.1:
	cmp	x2, #32
	b.hs	LBB27_3
; %bb.2:
	mov	x8, #0                          ; =0x0
	b	LBB27_6
LBB27_3:
	and	x8, x2, #0x7fffffffffffffe0
	add	x9, x1, #64
	add	x10, x0, #32
	mov	x11, x8
LBB27_4:                                ; =>This Inner Loop Header: Depth=1
	ldp	q0, q1, [x10, #-32]
	ldp	q2, q3, [x10], #64
	fcvtl	v4.4s, v0.4h
	fcvtl2	v0.4s, v0.8h
	fcvtl	v5.4s, v1.4h
	fcvtl2	v1.4s, v1.8h
	fcvtl	v6.4s, v2.4h
	fcvtl2	v2.4s, v2.8h
	fcvtl	v7.4s, v3.4h
	fcvtl2	v3.4s, v3.8h
	stp	q4, q0, [x9, #-64]
	stp	q5, q1, [x9, #-32]
	stp	q6, q2, [x9]
	stp	q7, q3, [x9, #32]
	add	x9, x9, #128
	subs	x11, x11, #32
	b.ne	LBB27_4
; %bb.5:
	cmp	x8, x2
	b.eq	LBB27_8
LBB27_6:
	sub	x9, x2, x8
	add	x10, x1, x8, lsl #2
	add	x8, x0, x8, lsl #1
LBB27_7:                                ; =>This Inner Loop Header: Depth=1
	ldr	h0, [x8], #2
	fcvt	s0, h0
	str	s0, [x10], #4
	subs	x9, x9, #1
	b.ne	LBB27_7
LBB27_8:
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_ggml_cpu_fp32_to_bf16          ; -- Begin function ggml_cpu_fp32_to_bf16
	.p2align	2
_ggml_cpu_fp32_to_bf16:                 ; @ggml_cpu_fp32_to_bf16
	.cfi_startproc
; %bb.0:
	cmp	x2, #1
	b.lt	LBB28_8
; %bb.1:
	cmp	x2, #8
	b.hs	LBB28_3
; %bb.2:
	mov	x8, #0                          ; =0x0
	b	LBB28_6
LBB28_3:
	mov	w8, #1                          ; =0x1
	movk	w8, #32640, lsl #16
	dup.4s	v0, w8
	and	x8, x2, #0x7ffffffffffffff8
	movi.4s	v1, #1
	movi.4s	v2, #127, msl #8
	mov	x9, x8
	mov	x10, x0
	mov	x11, x1
LBB28_4:                                ; =>This Inner Loop Header: Depth=1
	ldp	q4, q3, [x10], #32
	fabs.4s	v5, v4
	fabs.4s	v6, v3
	cmhi.4s	v6, v0, v6
	cmhi.4s	v5, v0, v5
	uzp1.8h	v5, v5, v6
	ushr.4s	v6, v3, #16
	ushr.4s	v7, v4, #16
	and.16b	v7, v7, v1
	and.16b	v6, v6, v1
	add.4s	v6, v3, v6
	add.4s	v7, v4, v7
	addhn.4h	v7, v7, v2
	addhn2.8h	v7, v6, v2
	uzp2.8h	v3, v4, v3
	orr.8h	v3, #64
	bit.16b	v3, v7, v5
	str	q3, [x11], #16
	subs	x9, x9, #8
	b.ne	LBB28_4
; %bb.5:
	cmp	x8, x2
	b.eq	LBB28_8
LBB28_6:
	sub	x9, x2, x8
	mov	w10, #1                         ; =0x1
	movk	w10, #32640, lsl #16
	mov	w11, #32767                     ; =0x7fff
	add	x12, x0, x8, lsl #2
	add	x8, x1, x8, lsl #1
LBB28_7:                                ; =>This Inner Loop Header: Depth=1
	ldr	w13, [x12], #4
	and	w14, w13, #0x7fffffff
	ubfx	w15, w13, #16, #1
	add	w16, w13, w11
	add	w15, w16, w15
	lsr	w15, w15, #16
	lsr	w13, w13, #16
	orr	w13, w13, #0x40
	cmp	w14, w10
	csel	w13, w15, w13, lo
	strh	w13, [x8], #2
	subs	x9, x9, #1
	b.ne	LBB28_7
LBB28_8:
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_ggml_cpu_bf16_to_fp32          ; -- Begin function ggml_cpu_bf16_to_fp32
	.p2align	2
_ggml_cpu_bf16_to_fp32:                 ; @ggml_cpu_bf16_to_fp32
	.cfi_startproc
; %bb.0:
	cmp	x2, #1
	b.lt	LBB29_7
; %bb.1:
	cmp	x2, #32
	b.lo	LBB29_4
; %bb.2:
	add	x8, x0, x2, lsl #1
	cmp	x8, x1
	b.ls	LBB29_8
; %bb.3:
	add	x8, x1, x2, lsl #2
	cmp	x8, x0
	b.ls	LBB29_8
LBB29_4:
	mov	x8, #0                          ; =0x0
LBB29_5:
	sub	x9, x2, x8
	add	x10, x1, x8, lsl #2
	add	x8, x0, x8, lsl #1
LBB29_6:                                ; =>This Inner Loop Header: Depth=1
	ldrh	w11, [x8], #2
	lsl	w11, w11, #16
	str	w11, [x10], #4
	subs	x9, x9, #1
	b.ne	LBB29_6
LBB29_7:
	ret
LBB29_8:
	and	x8, x2, #0x7fffffffffffffe0
	add	x9, x1, #64
	add	x10, x0, #32
	mov	x11, x8
LBB29_9:                                ; =>This Inner Loop Header: Depth=1
	ldp	q0, q1, [x10, #-32]
	ldp	q2, q3, [x10], #64
	shll.4s	v4, v0, #16
	shll2.4s	v0, v0, #16
	shll.4s	v5, v1, #16
	shll2.4s	v1, v1, #16
	shll.4s	v6, v2, #16
	shll2.4s	v2, v2, #16
	shll.4s	v7, v3, #16
	shll2.4s	v3, v3, #16
	stp	q4, q0, [x9, #-64]
	stp	q5, q1, [x9, #-32]
	stp	q6, q2, [x9]
	stp	q7, q3, [x9, #32]
	add	x9, x9, #128
	subs	x11, x11, #32
	b.ne	LBB29_9
; %bb.10:
	cmp	x8, x2
	b.eq	LBB29_7
	b	LBB29_5
	.cfi_endproc
                                        ; -- End function
	.globl	_ggml_cpu_has_avx               ; -- Begin function ggml_cpu_has_avx
	.p2align	2
_ggml_cpu_has_avx:                      ; @ggml_cpu_has_avx
	.cfi_startproc
; %bb.0:
	mov	w0, #0                          ; =0x0
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_ggml_cpu_has_avx_vnni          ; -- Begin function ggml_cpu_has_avx_vnni
	.p2align	2
_ggml_cpu_has_avx_vnni:                 ; @ggml_cpu_has_avx_vnni
	.cfi_startproc
; %bb.0:
	mov	w0, #0                          ; =0x0
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_ggml_cpu_has_avx2              ; -- Begin function ggml_cpu_has_avx2
	.p2align	2
_ggml_cpu_has_avx2:                     ; @ggml_cpu_has_avx2
	.cfi_startproc
; %bb.0:
	mov	w0, #0                          ; =0x0
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_ggml_cpu_has_avx512            ; -- Begin function ggml_cpu_has_avx512
	.p2align	2
_ggml_cpu_has_avx512:                   ; @ggml_cpu_has_avx512
	.cfi_startproc
; %bb.0:
	mov	w0, #0                          ; =0x0
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_ggml_cpu_has_avx512_vbmi       ; -- Begin function ggml_cpu_has_avx512_vbmi
	.p2align	2
_ggml_cpu_has_avx512_vbmi:              ; @ggml_cpu_has_avx512_vbmi
	.cfi_startproc
; %bb.0:
	mov	w0, #0                          ; =0x0
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_ggml_cpu_has_avx512_vnni       ; -- Begin function ggml_cpu_has_avx512_vnni
	.p2align	2
_ggml_cpu_has_avx512_vnni:              ; @ggml_cpu_has_avx512_vnni
	.cfi_startproc
; %bb.0:
	mov	w0, #0                          ; =0x0
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_ggml_cpu_has_avx512_bf16       ; -- Begin function ggml_cpu_has_avx512_bf16
	.p2align	2
_ggml_cpu_has_avx512_bf16:              ; @ggml_cpu_has_avx512_bf16
	.cfi_startproc
; %bb.0:
	mov	w0, #0                          ; =0x0
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_ggml_cpu_has_amx_int8          ; -- Begin function ggml_cpu_has_amx_int8
	.p2align	2
_ggml_cpu_has_amx_int8:                 ; @ggml_cpu_has_amx_int8
	.cfi_startproc
; %bb.0:
	mov	w0, #0                          ; =0x0
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_ggml_cpu_has_bmi2              ; -- Begin function ggml_cpu_has_bmi2
	.p2align	2
_ggml_cpu_has_bmi2:                     ; @ggml_cpu_has_bmi2
	.cfi_startproc
; %bb.0:
	mov	w0, #0                          ; =0x0
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_ggml_cpu_has_fma               ; -- Begin function ggml_cpu_has_fma
	.p2align	2
_ggml_cpu_has_fma:                      ; @ggml_cpu_has_fma
	.cfi_startproc
; %bb.0:
	mov	w0, #0                          ; =0x0
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_ggml_cpu_has_arm_fma           ; -- Begin function ggml_cpu_has_arm_fma
	.p2align	2
_ggml_cpu_has_arm_fma:                  ; @ggml_cpu_has_arm_fma
	.cfi_startproc
; %bb.0:
	mov	w0, #1                          ; =0x1
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_ggml_cpu_has_riscv_v           ; -- Begin function ggml_cpu_has_riscv_v
	.p2align	2
_ggml_cpu_has_riscv_v:                  ; @ggml_cpu_has_riscv_v
	.cfi_startproc
; %bb.0:
	mov	w0, #0                          ; =0x0
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_ggml_cpu_has_f16c              ; -- Begin function ggml_cpu_has_f16c
	.p2align	2
_ggml_cpu_has_f16c:                     ; @ggml_cpu_has_f16c
	.cfi_startproc
; %bb.0:
	mov	w0, #0                          ; =0x0
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_ggml_cpu_has_fp16_va           ; -- Begin function ggml_cpu_has_fp16_va
	.p2align	2
_ggml_cpu_has_fp16_va:                  ; @ggml_cpu_has_fp16_va
	.cfi_startproc
; %bb.0:
	mov	w0, #1                          ; =0x1
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_ggml_cpu_has_wasm_simd         ; -- Begin function ggml_cpu_has_wasm_simd
	.p2align	2
_ggml_cpu_has_wasm_simd:                ; @ggml_cpu_has_wasm_simd
	.cfi_startproc
; %bb.0:
	mov	w0, #0                          ; =0x0
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_ggml_cpu_has_llamafile         ; -- Begin function ggml_cpu_has_llamafile
	.p2align	2
_ggml_cpu_has_llamafile:                ; @ggml_cpu_has_llamafile
	.cfi_startproc
; %bb.0:
	mov	w0, #0                          ; =0x0
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_ggml_cpu_has_sse3              ; -- Begin function ggml_cpu_has_sse3
	.p2align	2
_ggml_cpu_has_sse3:                     ; @ggml_cpu_has_sse3
	.cfi_startproc
; %bb.0:
	mov	w0, #0                          ; =0x0
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_ggml_cpu_has_ssse3             ; -- Begin function ggml_cpu_has_ssse3
	.p2align	2
_ggml_cpu_has_ssse3:                    ; @ggml_cpu_has_ssse3
	.cfi_startproc
; %bb.0:
	mov	w0, #0                          ; =0x0
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_ggml_cpu_has_vsx               ; -- Begin function ggml_cpu_has_vsx
	.p2align	2
_ggml_cpu_has_vsx:                      ; @ggml_cpu_has_vsx
	.cfi_startproc
; %bb.0:
	mov	w0, #0                          ; =0x0
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_ggml_cpu_has_vxe               ; -- Begin function ggml_cpu_has_vxe
	.p2align	2
_ggml_cpu_has_vxe:                      ; @ggml_cpu_has_vxe
	.cfi_startproc
; %bb.0:
	mov	w0, #0                          ; =0x0
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_ggml_cpu_has_neon              ; -- Begin function ggml_cpu_has_neon
	.p2align	2
_ggml_cpu_has_neon:                     ; @ggml_cpu_has_neon
	.cfi_startproc
; %bb.0:
Lloh431:
	adrp	x8, _ggml_arm_arch_features@PAGE
Lloh432:
	ldr	w0, [x8, _ggml_arm_arch_features@PAGEOFF]
	ret
	.loh AdrpLdr	Lloh431, Lloh432
	.cfi_endproc
                                        ; -- End function
	.globl	_ggml_cpu_has_dotprod           ; -- Begin function ggml_cpu_has_dotprod
	.p2align	2
_ggml_cpu_has_dotprod:                  ; @ggml_cpu_has_dotprod
	.cfi_startproc
; %bb.0:
Lloh433:
	adrp	x8, _ggml_arm_arch_features@PAGE+4
Lloh434:
	ldr	w0, [x8, _ggml_arm_arch_features@PAGEOFF+4]
	ret
	.loh AdrpLdr	Lloh433, Lloh434
	.cfi_endproc
                                        ; -- End function
	.globl	_ggml_cpu_has_sve               ; -- Begin function ggml_cpu_has_sve
	.p2align	2
_ggml_cpu_has_sve:                      ; @ggml_cpu_has_sve
	.cfi_startproc
; %bb.0:
	mov	w0, #0                          ; =0x0
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_ggml_cpu_has_matmul_int8       ; -- Begin function ggml_cpu_has_matmul_int8
	.p2align	2
_ggml_cpu_has_matmul_int8:              ; @ggml_cpu_has_matmul_int8
	.cfi_startproc
; %bb.0:
	mov	w0, #0                          ; =0x0
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_ggml_cpu_get_sve_cnt           ; -- Begin function ggml_cpu_get_sve_cnt
	.p2align	2
_ggml_cpu_get_sve_cnt:                  ; @ggml_cpu_get_sve_cnt
	.cfi_startproc
; %bb.0:
	mov	w0, #0                          ; =0x0
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_ggml_cpu_has_sme               ; -- Begin function ggml_cpu_has_sme
	.p2align	2
_ggml_cpu_has_sme:                      ; @ggml_cpu_has_sme
	.cfi_startproc
; %bb.0:
	mov	w0, #0                          ; =0x0
	ret
	.cfi_endproc
                                        ; -- End function
	.p2align	2                               ; -- Begin function ggml_graph_compute_secondary_thread
_ggml_graph_compute_secondary_thread:   ; @ggml_graph_compute_secondary_thread
	.cfi_startproc
; %bb.0:
	sub	sp, sp, #96
	stp	x24, x23, [sp, #32]             ; 16-byte Folded Spill
	stp	x22, x21, [sp, #48]             ; 16-byte Folded Spill
	stp	x20, x19, [sp, #64]             ; 16-byte Folded Spill
	stp	x29, x30, [sp, #80]             ; 16-byte Folded Spill
	add	x29, sp, #80
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	.cfi_offset w23, -56
	.cfi_offset w24, -64
	mov	x19, x0
	ldr	x20, [x0, #528]
	ldr	w23, [x20, #352]
	mov	w21, #1                         ; =0x1
	cmp	w23, #1
	b.gt	LBB56_4
; %bb.1:
	cbz	w23, LBB56_11
; %bb.2:
	cmp	w23, #1
	b.ne	LBB56_9
; %bb.3:
	mov	w8, #40                         ; =0x28
	b	LBB56_8
LBB56_4:
	cmp	w23, #2
	b.eq	LBB56_7
; %bb.5:
	cmp	w23, #3
	b.ne	LBB56_9
; %bb.6:
	mov	w8, #90                         ; =0x5a
	b	LBB56_8
LBB56_7:
	mov	w8, #80                         ; =0x50
LBB56_8:
	str	w8, [sp, #24]
	mov	w21, #4                         ; =0x4
LBB56_9:
	bl	_pthread_self
	add	x2, sp, #24
	mov	x1, x21
	bl	_pthread_setschedparam
	cbz	w0, LBB56_11
; %bb.10:
	mov	x21, x0
Lloh435:
	adrp	x8, ___stderrp@GOTPAGE
Lloh436:
	ldr	x8, [x8, ___stderrp@GOTPAGEOFF]
Lloh437:
	ldr	x22, [x8]
	bl	_strerror
	stp	x0, x21, [sp, #8]
	str	x23, [sp]
Lloh438:
	adrp	x1, l_.str.25@PAGE
Lloh439:
	add	x1, x1, l_.str.25@PAGEOFF
	mov	x0, x22
	bl	_fprintf
LBB56_11:                               ; =>This Loop Header: Depth=1
                                        ;     Child Loop BB56_27 Depth 2
                                        ;     Child Loop BB56_16 Depth 2
                                        ;     Child Loop BB56_35 Depth 2
	add	x8, x20, #325
	ldarb	w8, [x8]
	tbnz	w8, #0, LBB56_27
LBB56_12:                               ;   in Loop: Header=BB56_11 Depth=1
	add	x8, x20, #324
	ldarb	w8, [x8]
	tbnz	w8, #0, LBB56_39
; %bb.13:                               ;   in Loop: Header=BB56_11 Depth=1
	ldr	x21, [x19, #528]
	ldr	w9, [x21, #348]
	ldr	w10, [x19, #536]
	ldrb	w8, [x19, #524]
	cmp	w10, w9
	b.ge	LBB56_24
; %bb.14:                               ;   in Loop: Header=BB56_11 Depth=1
	tbnz	w8, #0, LBB56_25
; %bb.15:                               ;   in Loop: Header=BB56_11 Depth=1
	mov	x8, #0                          ; =0x0
	ldr	w9, [x21, #356]
	lsl	x9, x9, #17
LBB56_16:                               ;   Parent Loop BB56_11 Depth=1
                                        ; =>  This Inner Loop Header: Depth=2
	ldr	x10, [x19, #528]
	add	x11, x10, #324
	ldarb	w11, [x11]
	tbnz	w11, #0, LBB56_23
; %bb.17:                               ;   in Loop: Header=BB56_16 Depth=2
	add	x11, x10, #325
	ldarb	w11, [x11]
	tbnz	w11, #0, LBB56_23
; %bb.18:                               ;   in Loop: Header=BB56_16 Depth=2
	ldr	w10, [x10, #128]
	ldr	w11, [x19, #520]
	cmp	w10, w11
	b.ne	LBB56_20
; %bb.19:                               ;   in Loop: Header=BB56_16 Depth=2
	ldrb	w11, [x19, #524]
	tbz	w11, #0, LBB56_21
	b	LBB56_23
LBB56_20:                               ;   in Loop: Header=BB56_16 Depth=2
	ldr	x11, [x19, #528]
	ldr	w11, [x11, #348]
	ldr	w12, [x19, #536]
	cmp	w12, w11
	cset	w11, lt
	strb	w11, [x19, #524]
	str	w10, [x19, #520]
	tbnz	w11, #0, LBB56_23
LBB56_21:                               ;   in Loop: Header=BB56_16 Depth=2
	cmp	x8, x9
	b.hs	LBB56_23
; %bb.22:                               ;   in Loop: Header=BB56_16 Depth=2
	; InlineAsm Start
	yield
	; InlineAsm End
	add	x8, x8, #1
	ldrb	w10, [x19, #524]
	cmp	w10, #1
	b.ne	LBB56_16
LBB56_23:                               ;   in Loop: Header=BB56_11 Depth=1
	ldrb	w8, [x19, #524]
LBB56_24:                               ;   in Loop: Header=BB56_11 Depth=1
	tbz	w8, #0, LBB56_29
LBB56_25:                               ;   in Loop: Header=BB56_11 Depth=1
	dmb	ish
	b	LBB56_31
LBB56_26:                               ;   in Loop: Header=BB56_27 Depth=2
	mov	x0, x20
	bl	_pthread_mutex_unlock
	ldarb	w8, [x21]
	tbz	w8, #0, LBB56_12
LBB56_27:                               ;   Parent Loop BB56_11 Depth=1
                                        ; =>  This Inner Loop Header: Depth=2
	mov	x0, x20
	bl	_pthread_mutex_lock
	add	x21, x20, #325
	ldarb	w8, [x21]
	tbz	w8, #0, LBB56_26
; %bb.28:                               ;   in Loop: Header=BB56_27 Depth=2
	add	x0, x20, #64
	mov	x1, x20
	bl	_pthread_cond_wait
	b	LBB56_26
LBB56_29:                               ;   in Loop: Header=BB56_11 Depth=1
	mov	x0, x21
	bl	_pthread_mutex_lock
	ldrb	w8, [x19, #524]
	tbz	w8, #0, LBB56_35
LBB56_30:                               ;   in Loop: Header=BB56_11 Depth=1
	mov	x0, x21
	bl	_pthread_mutex_unlock
LBB56_31:                               ;   in Loop: Header=BB56_11 Depth=1
	ldrb	w8, [x19, #524]
	cmp	w8, #1
	b.ne	LBB56_11
; %bb.32:                               ;   in Loop: Header=BB56_11 Depth=1
	strb	wzr, [x19, #524]
	mov	x0, x19
	bl	_ggml_graph_compute_thread
	b	LBB56_11
LBB56_33:                               ;   in Loop: Header=BB56_35 Depth=2
	ldr	x9, [x19, #528]
	ldr	w9, [x9, #348]
	ldr	w10, [x19, #536]
	str	w8, [x19, #520]
	cmp	w10, w9
	cset	w8, lt
	strb	w8, [x19, #524]
	b.lt	LBB56_30
LBB56_34:                               ;   in Loop: Header=BB56_35 Depth=2
	add	x0, x21, #64
	mov	x1, x21
	bl	_pthread_cond_wait
	ldrb	w8, [x19, #524]
	cmp	w8, #1
	b.eq	LBB56_30
LBB56_35:                               ;   Parent Loop BB56_11 Depth=1
                                        ; =>  This Inner Loop Header: Depth=2
	ldr	x8, [x19, #528]
	add	x9, x8, #324
	ldarb	w9, [x9]
	tbnz	w9, #0, LBB56_30
; %bb.36:                               ;   in Loop: Header=BB56_35 Depth=2
	add	x9, x8, #325
	ldarb	w9, [x9]
	tbnz	w9, #0, LBB56_30
; %bb.37:                               ;   in Loop: Header=BB56_35 Depth=2
	ldr	w8, [x8, #128]
	ldr	w9, [x19, #520]
	cmp	w8, w9
	b.ne	LBB56_33
; %bb.38:                               ;   in Loop: Header=BB56_35 Depth=2
	ldrb	w8, [x19, #524]
	tbz	w8, #0, LBB56_34
	b	LBB56_30
LBB56_39:
	mov	x0, #0                          ; =0x0
	ldp	x29, x30, [sp, #80]             ; 16-byte Folded Reload
	ldp	x20, x19, [sp, #64]             ; 16-byte Folded Reload
	ldp	x22, x21, [sp, #48]             ; 16-byte Folded Reload
	ldp	x24, x23, [sp, #32]             ; 16-byte Folded Reload
	add	sp, sp, #96
	ret
	.loh AdrpAdd	Lloh438, Lloh439
	.loh AdrpLdrGotLdr	Lloh435, Lloh436, Lloh437
	.cfi_endproc
                                        ; -- End function
	.section	__DATA,__data
	.globl	_ggml_arm_arch_features         ; @ggml_arm_arch_features
	.p2align	2, 0x0
_ggml_arm_arch_features:
	.long	4294967295                      ; 0xffffffff
	.long	4294967295                      ; 0xffffffff
	.long	4294967295                      ; 0xffffffff
	.long	4294967295                      ; 0xffffffff
	.long	0                               ; 0x0
	.long	4294967295                      ; 0xffffffff

	.section	__DATA,__const
	.p2align	3, 0x0                          ; @type_traits_cpu
_type_traits_cpu:
	.quad	0
	.quad	_ggml_vec_dot_f32
	.long	0                               ; 0x0
	.space	4
	.quad	1                               ; 0x1
	.quad	_ggml_cpu_fp32_to_fp16
	.quad	_ggml_vec_dot_f16
	.long	1                               ; 0x1
	.space	4
	.quad	1                               ; 0x1
	.quad	_quantize_row_q4_0
	.quad	_ggml_vec_dot_q4_0_q8_0
	.long	8                               ; 0x8
	.space	4
	.quad	1                               ; 0x1
	.quad	_quantize_row_q4_1
	.quad	_ggml_vec_dot_q4_1_q8_1
	.long	9                               ; 0x9
	.space	4
	.quad	1                               ; 0x1
	.space	32
	.space	32
	.quad	_quantize_row_q5_0
	.quad	_ggml_vec_dot_q5_0_q8_0
	.long	8                               ; 0x8
	.space	4
	.quad	1                               ; 0x1
	.quad	_quantize_row_q5_1
	.quad	_ggml_vec_dot_q5_1_q8_1
	.long	9                               ; 0x9
	.space	4
	.quad	1                               ; 0x1
	.quad	_quantize_row_q8_0
	.quad	_ggml_vec_dot_q8_0_q8_0
	.long	8                               ; 0x8
	.space	4
	.quad	1                               ; 0x1
	.quad	_quantize_row_q8_1
	.quad	0
	.long	9                               ; 0x9
	.space	4
	.quad	1                               ; 0x1
	.quad	_quantize_row_q2_K
	.quad	_ggml_vec_dot_q2_K_q8_K
	.long	15                              ; 0xf
	.space	4
	.quad	1                               ; 0x1
	.quad	_quantize_row_q3_K
	.quad	_ggml_vec_dot_q3_K_q8_K
	.long	15                              ; 0xf
	.space	4
	.quad	1                               ; 0x1
	.quad	_quantize_row_q4_K
	.quad	_ggml_vec_dot_q4_K_q8_K
	.long	15                              ; 0xf
	.space	4
	.quad	1                               ; 0x1
	.quad	_quantize_row_q5_K
	.quad	_ggml_vec_dot_q5_K_q8_K
	.long	15                              ; 0xf
	.space	4
	.quad	1                               ; 0x1
	.quad	_quantize_row_q6_K
	.quad	_ggml_vec_dot_q6_K_q8_K
	.long	15                              ; 0xf
	.space	4
	.quad	1                               ; 0x1
	.quad	_quantize_row_q8_K
	.quad	0
	.long	0                               ; 0x0
	.space	4
	.quad	0                               ; 0x0
	.quad	0
	.quad	_ggml_vec_dot_iq2_xxs_q8_K
	.long	15                              ; 0xf
	.space	4
	.quad	1                               ; 0x1
	.quad	0
	.quad	_ggml_vec_dot_iq2_xs_q8_K
	.long	15                              ; 0xf
	.space	4
	.quad	1                               ; 0x1
	.quad	0
	.quad	_ggml_vec_dot_iq3_xxs_q8_K
	.long	15                              ; 0xf
	.space	4
	.quad	1                               ; 0x1
	.quad	0
	.quad	_ggml_vec_dot_iq1_s_q8_K
	.long	15                              ; 0xf
	.space	4
	.quad	1                               ; 0x1
	.quad	_quantize_row_iq4_nl
	.quad	_ggml_vec_dot_iq4_nl_q8_0
	.long	8                               ; 0x8
	.space	4
	.quad	1                               ; 0x1
	.quad	0
	.quad	_ggml_vec_dot_iq3_s_q8_K
	.long	15                              ; 0xf
	.space	4
	.quad	1                               ; 0x1
	.quad	0
	.quad	_ggml_vec_dot_iq2_s_q8_K
	.long	15                              ; 0xf
	.space	4
	.quad	1                               ; 0x1
	.quad	_quantize_row_iq4_xs
	.quad	_ggml_vec_dot_iq4_xs_q8_K
	.long	15                              ; 0xf
	.space	4
	.quad	1                               ; 0x1
	.space	32
	.space	32
	.space	32
	.space	32
	.space	32
	.quad	0
	.quad	_ggml_vec_dot_iq1_m_q8_K
	.long	15                              ; 0xf
	.space	4
	.quad	1                               ; 0x1
	.quad	_ggml_cpu_fp32_to_bf16
	.quad	_ggml_vec_dot_bf16
	.long	30                              ; 0x1e
	.space	4
	.quad	1                               ; 0x1
	.space	32
	.space	32
	.space	32
	.quad	_quantize_row_tq1_0
	.quad	_ggml_vec_dot_tq1_0_q8_K
	.long	15                              ; 0xf
	.space	4
	.quad	1                               ; 0x1
	.quad	_quantize_row_tq2_0
	.quad	_ggml_vec_dot_tq2_0_q8_K
	.long	15                              ; 0xf
	.space	4
	.quad	1                               ; 0x1
	.space	32
	.space	32
	.space	32

	.section	__TEXT,__cstring,cstring_literals
l_.str.1:                               ; @.str.1
	.asciz	"ggml/src/ggml-cpu/ggml-cpu.c"

l_.str.2:                               ; @.str.2
	.asciz	"GGML_ASSERT(%s) failed"

l_.str.3:                               ; @.str.3
	.asciz	"!ggml_get_no_alloc(ctx)"

l_.str.4:                               ; @.str.4
	.asciz	"fatal error"

l_.str.5:                               ; @.str.5
	.asciz	"tensor->nb[0] == sizeof(int8_t)"

l_.str.6:                               ; @.str.6
	.asciz	"tensor->nb[0] == sizeof(int16_t)"

l_.str.7:                               ; @.str.7
	.asciz	"tensor->nb[0] == sizeof(int32_t)"

l_.str.8:                               ; @.str.8
	.asciz	"tensor->nb[0] == sizeof(ggml_fp16_t)"

l_.str.9:                               ; @.str.9
	.asciz	"tensor->nb[0] == sizeof(ggml_bf16_t)"

l_.str.10:                              ; @.str.10
	.asciz	"tensor->nb[0] == sizeof(float)"

l_.str.11:                              ; @.str.11
	.asciz	"rc == GGML_EXIT_SUCCESS || rc == GGML_EXIT_ABORTED"

l_.str.12:                              ; @.str.12
	.asciz	"node->src[0]->ne[3] == 1"

l_.str.13:                              ; @.str.13
	.asciz	"node->src[1]->ne[2] == 1"

l_.str.14:                              ; @.str.14
	.asciz	"node->src[1]->ne[3] == 1"

l_.str.15:                              ; @.str.15
	.asciz	"cplan"

l_.str.16:                              ; @.str.16
	.asciz	"cplan->n_threads > 0"

l_.str.17:                              ; @.str.17
	.asciz	"cplan->work_size == 0 || cplan->work_data != NULL"

l_.str.18:                              ; @.str.18
	.asciz	"cplan requested more threads (%d) than available (%d)\n"

.zerofill __DATA,__bss,_ggml_cpu_init.is_first_call,1,0 ; @ggml_cpu_init.is_first_call
l_.str.19:                              ; @.str.19
	.asciz	"%s: op not implemented: "

l___func__.ggml_get_n_tasks:            ; @__func__.ggml_get_n_tasks
	.asciz	"ggml_get_n_tasks"

l_.str.20:                              ; @.str.20
	.asciz	"%s\n"

l_.str.21:                              ; @.str.21
	.asciz	"%d\n"

l_.str.24:                              ; @.str.24
	.asciz	"rc == 0"

l_.str.25:                              ; @.str.25
	.asciz	"warn: failed to set thread priority %d : %s (%d)\n"

l_.str.26:                              ; @.str.26
	.asciz	"warn: ggml_graph_compute_thread: failed to set QoS class %s (%d)\n"

l_.str.28:                              ; @.str.28
	.asciz	"t == 0 || t == 1"

l_.str.29:                              ; @.str.29
	.asciz	"ne0 == ne01"

l_.str.30:                              ; @.str.30
	.asciz	"ne1 == ne11"

l_.str.31:                              ; @.str.31
	.asciz	"ne2 == ne12"

l_.str.32:                              ; @.str.32
	.asciz	"ne3 == ne13"

l_.str.33:                              ; @.str.33
	.asciz	"nb00 == ggml_type_size(src0->type)"

l_.str.34:                              ; @.str.34
	.asciz	"nb10 == ggml_type_size(src1->type)"

l_.str.35:                              ; @.str.35
	.asciz	"nb0 == sizeof(float)"

l_.str.36:                              ; @.str.36
	.asciz	"nb0 <= nb1"

l_.str.37:                              ; @.str.37
	.asciz	"nb1 <= nb2"

l_.str.38:                              ; @.str.38
	.asciz	"nb2 <= nb3"

l_.str.39:                              ; @.str.39
	.asciz	"src1->type == GGML_TYPE_F32"

l_.str.40:                              ; @.str.40
	.asciz	"nb00 == ggml_type_size(type)"

l_.str.41:                              ; @.str.41
	.asciz	"params->wsize >= (size_t)((char *) wdata_cur - (char *) params->wdata)"

l_.str.42:                              ; @.str.42
	.asciz	"hw.optional.AdvSIMD"

l_.str.43:                              ; @.str.43
	.asciz	"hw.optional.arm.FEAT_DotProd"

l_.str.44:                              ; @.str.44
	.asciz	"hw.optional.arm.FEAT_I8MM"

l_.str.45:                              ; @.str.45
	.asciz	"hw.optional.arm.FEAT_SME"

.subsections_via_symbols
