
;==================================================================================================
;
; Get the base address for this platform
;
;==================================================================================================
memGetPlatformBase:
	move.l			#$00ff0000,a0
	rts
