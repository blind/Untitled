
;==================================================================================================
;
; Get the base address for this platform
;
;==================================================================================================
memGetPlatformBase:
	move.l	d0,-(sp)
	move.l	#_atariMem,d0
	add.l	#255,d0
	clr.b	d0
	move.l	d0,a0

	move.l	(sp)+,d0
	rts
	
	section bss
_atariMem:
	ds.b	$10000+256

	section CODE

