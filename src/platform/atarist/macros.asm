

perf_start		MACRO
	move.w		#$0646,$ffff8240.w
	ENDM

;==============================================================================
;
; Will set the border color to index 1 in the palette. Might get modified so 
; the color index is a parameter.
;
;==============================================================================
perf_stop		MACRO
	move.w		#$0000,$ffff8240.w
	ENDM


_chunk_size             equ             128

INPUT_ACTION		equ	0
INPUT_ACTION2		equ	0
INPUT_UP			equ	0
INPUT_DOWN			equ	0
INPUT_LEFT			equ	0
INPUT_RIGHT			equ	0

