
;==============================================================================
;
; WaitVsync
;
;==============================================================================

rendWaitVSync:
	move.w	#1,vblFlag

.wait_loop
	tst.w	vblFlag
	bne.s	.wait_loop

	rts


_vblHandler:
	clr.w	vblFlag
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


rendLoadPalette:
	rts

rendLoadTileBank:
	rts

rendSetSpriteFrame:
	rts

rendLoadTileMap:
	rts

rendSetSpritePosition:
	rts

rendSetSpriteDrawOrder:
	rts


	section bss
vblFlag
	ds.w	1
	section CODE