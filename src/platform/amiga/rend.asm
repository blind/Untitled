
	; include		"hardware/custom.i"
	; include		"hardware/dmabits.i"
	; include		"exec_lib.i"
	; include		"graphics_lib.i"
	

;==============================================================================
;
; Init
;
;==============================================================================

rendInit:
	lea			_custom,a2

	_get_workmem_ptr BitplaneMem,a0
	subq.l		#2,a0
	bsr			_setupBitplanePointers
	
	; move.w		#$2c81,diwstrt(a2)
	; move.w		#$0cc1,diwstop(a2)
	; move.w		#$0038,ddfstrt(a2)
	; move.w		#$00d0,ddfstop(a2)
	; move.w		#$0000,bpl1mod(a2)
	; move.w		#$0000,bpl2mod(a2)
	
	lea			Copper(pc),a0
	move.l		a0,cop1lc(a2)
	move.w		d0,copjmp1(a2)
	rts

;==============================================================================
;
; Setup bitplane pointers
; a0=pointers to bitplanes
;
;==============================================================================
_setupBitplanePointers
	move.l		a0,d0
	lea			Copper_bplpt(pc),a0	
	moveq		#4-1,d1
.bplconLoop
	swap.w		d0
	move.w		d0,2(a0)
	swap.w		d0
	move.w		d0,6(a0)
	add.l		#64,d0
	add.l		#8,a0	
	dbra		d1,.bplconLoop

	rts

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
	movem.l		d2-d3,-(sp)

	subq.l		#2,a0					; make up for ddfstrt

	move.l		d0,d2

	subq.l		#1,d0
	and.l		#$fffffff0,d0			; d0=x scroll high bits (bpl ptr)
	asr.l		#3,d0

	neg.w		d2
	and.l		#$0f,d2					; d2=x scroll low bits (bplcon0 bits)
	move.l		d2,d3
	rol.w		#4,d3
	or.w		d3,d2	

	lsl.l		#8,d1					; d1=y scroll (bpl ptr)

	_get_workmem_ptr BitplaneMem,a0
	add.l		d0,a0
	add.l		d1,a0
	bsr 		_setupBitplanePointers
	
	lea			Copper_bplcon1+2,a0
	move.w		(a0),d0
	and.w		#$ff00,d0
	or.w		d2,d0
	move.w		d0,(a0)

	movem.l		(sp)+,d2-d3
	rts


;==============================================================================
;
; Set the screen coordinate of a sprite given its ID
;
; Input
;	d0 = Sprite ID
;	d1 = X position. 0 is leftmost pixel on screen, negative allowed
;	d2 = Y position. 0 is topmost pixel on screen, negative allowed
;
;==============================================================================

rendSetSpritePosition:
	rts


;==============================================================================
;
; Set which frame of a sprite animation that should be shown
;
; d0=Sprite ID
; d1=Frame index
;
;==============================================================================

rendSetSpriteFrame:
	rts


;==============================================================================
;
; Load a tile bank into VRAM
;
; d0=file ID of tile bank file to load into VRAM
;
;==============================================================================

rendLoadTileBank:
	; fileLoad accept the file ID as d0, so no need to do any tricks here
	
	_get_workmem_ptr	TilebankMem,a0
	bsr					fileLoad
	
	rts


;==============================================================================
;
; Load a tile map from disk into VRAM
;
; d0=file ID of tile bank file to load into VRAM
; d1=Which slot to store the map in.
;		Slot #0 - Background layer (behind sprites)
;		Slot #1 - Foreground layer (in front of sprites)
;
;==============================================================================

rendLoadTileMap:

	; fileLoad accept the file ID as d0, so no need to do any tricks here
	movem.l			a0-a6/d0-d7,-(sp)
	
	_get_workmem_ptr	TilemapMem,a0
	bsr					fileLoad

	_get_workmem_ptr	TilemapMem,a0
	_get_workmem_ptr	TilebankMem,a1
	_get_workmem_ptr	BitplaneMem,a5

	addq.l			#2,a0		; don't care about header for now

	moveq			#64-1,d7	; d7=y dbra
.yloop
	moveq			#64-1,d6	; d6=x dbra
.xloop

	moveq			#0,d0
	move.w			(a0)+,d0

	move.l			a1,a2
	mulu			#8*4,d0
	add.l			d0,a2


	move.l			a5,a4
	moveq			#8-1,d5
.drawLoop
	move.b			(a2)+,(a4)
	move.b			(a2)+,64(a4)
	move.b			(a2)+,128(a4)
	move.b			(a2)+,192(a4)
	add.l			#256,a4
	dbf				d5,.drawLoop

	addq.l			#1,a5
	dbf				d6,.xloop

	add.l			#(7*256)+192,a5
	dbf				d7,.yloop

	movem.l			(sp)+,a0-a6/d0-d7
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


;==============================================================================
;
; Load a palette map into CRAM
;
; d0=file ID of palette file to load into CRAM
; d1=Which slot index to store the palette in
;	Allowed slot indices are 0 to 3 inclusive
;
;==============================================================================

rendLoadPalette:
	movem.l			a0-a6/d0-d7,-(sp)

	; fileLoad accept the file ID as d0, so no need to do any tricks here
	_get_workmem_ptr	TilemapMem,a0
	jsr			fileLoad

	_get_workmem_ptr	TilemapMem,a0
	lea			Copper_color+2(pc),a1
	moveq		#16-1,d0
.loop
	move.w		(a0)+,d1
	move.w		d1,d2
	move.w		d1,d3
	and.w		#$00F0,d1
	and.w		#$0F00,d2
	and.w		#$000F,d3	
	ror.w		#8,d2
	rol.w		#8,d3
	or.w		d2,d1
	or.w		d3,d1

	move.w		d1,(a1)
	addq.l		#4,a1
	dbf			d0,.loop


	movem.l			(sp)+,a0-a6/d0-d7
	rts

;==============================================================================
;
; Variables
;
;==============================================================================
	cnop	0,4
	




;==============================================================================
;
; Copper
;
;==============================================================================
Copper
Copper_bplcon0
	dc.w	bplcon0,$4200
Copper_bplcon1
	dc.w	bplcon1,$0000
	dc.w	diwstrt,$2c81
	dc.w	diwstop,$2cc1
	dc.w	ddfstrt,$0030
	dc.w	ddfstop,$00d0
	dc.w	bpl1mod,$00d6	; 3*64+24=D8, 3*64=C0, 3*40=78
	dc.w	bpl2mod,$00d6
Copper_bplpt
	dc.w	bplpt+0,$0000
	dc.w	bplpt+2,$0000
	dc.w	bplpt+4,$0000
	dc.w	bplpt+6,$0000
	dc.w	bplpt+8,$0000
	dc.w	bplpt+10,$0000
	dc.w	bplpt+12,$0000
	dc.w	bplpt+14,$0000

Copper_color
	dc.w	color+0, $0000	
	dc.w	color+2, $0000
	dc.w	color+4, $0000
	dc.w	color+6, $0000
	dc.w	color+8, $0000
	dc.w	color+10,$0000
	dc.w	color+12,$0000
	dc.w	color+14,$0000
	dc.w	color+16,$0000
	dc.w	color+18,$0000
	dc.w	color+20,$0000
	dc.w	color+22,$0000
	dc.w	color+24,$0000
	dc.w	color+26,$0000
	dc.w	color+28,$0000
	dc.w	color+30,$0000
Copper_end
	dc.w	$FFFF,$FFFE
