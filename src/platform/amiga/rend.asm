	
	include		"hardware/custom.i"
	include		"hardware/dmabits.i"
	include		"exec_lib.i"
	include		"graphics_lib.i"
	


	
;==============================================================================
;
; WaitVsync
;
;==============================================================================

rendWaitVSync:
	
	; More information: http://eab.abime.net/showthread.php?t=51928
	
.1	btst	#0,(_custom+vposr+1)
	beq		.1
.2	btst	#0,(_custom+vposr+1)
	bne		.2
	
	rts



;==============================================================================
;
; Set scroll position for both horizontal scroll (X) and vertical scroll (Y)
;
; d0=X scroll
; d1=Y scroll
;
;==============================================================================

rendSetScrollXY:
	rts


;==============================================================================
;
; Load a sprite from disk to VRAM. This function is responsible for allocating
; VRAM for the sprite and return some form of handle back to the game so the
; game have a way to modify sprite properties such as position.
;
; Men fanken vet hur. :/
;
; d0=File ID
;
;==============================================================================

rendLoadSprite:
	rts


