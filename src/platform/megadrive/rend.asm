VarVsync equ	$00FF0000	; long
VarHsync equ	$00FF0004	; long


rendInit:
	jsr			InitVDP
	;move.l		#$11213141,$fffff4		; Write some magic values so we know we've reached this far

	jsr			LoadPalettes
	;move.l		#$12223242,$fffff8		; Write some magic values so we know we've reached this far

	;jsr			LoadPatterns
	jsr			FillPlaneA
	jsr			FillPlaneB

	jsr			LoadSprites
	;move.l		#$12223344,$fffffc		; Write some magic values so we know we've reached this far

	rts

;==============================================================================
;
; WaitVsync
;
;==============================================================================
rendWaitVSync:
	; Push
	;move.l		d0,-(sp)
	;move.l		d1,-(sp)

	; Read initial value
	move.l		(VarVsync),d0			; Read value from VarVsync into D0

.loop:
	; Read current value and see if it has changed
	move.l		(VarVsync),d1			; Read value from VarVsync into D1
	cmp.l		d0,d1					; Compare D0 and D1

	; No change means jump. Change means fall through.
	beq			.loop					; If result is 0 the value has not been changed
										; so jump back to 1

   	; Pop
	;move.l		(sp)+,d1
	;move.l		(sp)+,d0

	rts									; Return to caller


;==============================================================================
;
; Set scroll position for both horizontal scroll (X) and vertical scroll (Y)
;
; d0=X scroll
; d1=Y scroll
;
;==============================================================================
rendSetScrollXY:
	; Push
	;move.l		a4,-(sp)
	;move.l		a5,-(sp)

	; Setup CPU registers and VDP auto increment register
	move.l		#$00C00000,a0		; Throughout all my code I'll use A4
	move.l		#$00C00004,a1		; for the VDP data port and A5 for the
	move.w		#$8F00,(a1)			; Disable autoincrement

	; Set horizontal scroll
	move.l		#$50000003,(a1)		; Point the VDP data port to the horizontal scroll table
	move.w		d0,(a0)

	; Set vertical scroll
	move.l		#$40000010,(a1)		; Point the VDP data port to the vertical scroll table
	move.w		d1,(a0)

	; Pop
	;move.l		(sp)+,a5
	;move.l		(sp)+,a4

	rts


;==============================================================================
;
; Load a tile bank into VRAM
;
; d0=file ID of tile bank file to load into VRAM
; d1=offset into VRAM where the tile bank should be loaded
;
;==============================================================================
rendLoadTileBank:
	; Push the VRAM offset onto the stack
	move.l		d1,-(sp)

	; fileLoad accept the file ID as d0, so no need to do any tricks here
	jsr			fileLoad
	; a0 is the return address from fileLoad, so it is set to the source address now

	; d0 is set to the size of the file but rendCopyToVRAM expect it to be in d1
	move.l		d0,d1

	; Now fetch the VRAM offset argument
	move.l		(sp)+,d0

	; d0=destination offset
	; d1=size to copy
	; a0=source address
	jsr			rendCopyToVRAM

	rts


;==============================================================================
;
; General copy from CPU to VRAM subroutine
;
; a0=source addres
; d0=destination offset
; d1=size to copy
;
;==============================================================================
rendCopyToVRAM:
	move.l		#$00C00004,a1

    move.w  	#$8F02,(a1)				; Set autoincrement (register 15) to 2
    move.l  	#$40000000,(a1)			; Point data port to start of VRAM

	move.l		#$00C00000,a1

	;move.l		d1,d0
    move.l 	  	#109*8,d0				; We'll load 4 patterns, each 8 longs wide
    ;lea     	TestPatterns,a0			; Load address of Patterns into A0

.1:
	move.l  	(a0)+,(a1)				; Move long word from patterns into VDP
										; port and increment A0 by 4
	dbra    	d0,.1					; If D0 is not zero decrement and jump
										; back to 1
    
    rts									; Return to caller




;==============================================================================
;
; Helper routines
;
;==============================================================================
InitVDP:
	moveq		#18,d0						; 24 registers, but we set only 18
	lea			VDPRegs,a0					; start address of register values
	move.l		#$00C00004,a4				; The VDP control register
	clr.l		d5

.loop:
	move.w		(a0)+,d5					; load lower byte (register value)
	move.w		d5,(a4)						; write register
	dbra		d0,.loop					; loop

	rts										; Jump back to caller

VDPRegs:
	dc.w		$8004						; Reg.  0: Enable Hint, HV counter stop
	dc.w		$8174						; Reg.  1: Enable display, enable Vint, enable DMA, V28 mode (PAL & NTSC)
	;dc.w		$8240						; Reg.  2: Plane A is at $10000 (disable)
	dc.w		$8230						; Reg.  2: Plane A is at $C000
	dc.w		$8340						; Reg.  3: Window is at $10000 (disable)
	;dc.w		$8440						; Reg.  4: Plane B is at $10000 (disable?)
	dc.w		$8407						; Reg.  4: Plane B is at $E000
	;dc.w		$8430						; Reg.  4: Plane B is at $C000
	dc.w		$8570						; Reg.  5: Sprite attribute table is at $E000
	dc.w		$8600						; Reg.  6: always zero
	dc.w		$8700						; Reg.  7: Background color: palette 0, color 0
	dc.w		$8800						; Reg.  8: always zero
	dc.w		$8900						; Reg.  9: always zero
	dc.w		$8a00						; Reg. 10: Hint timing
	dc.w		$8b08						; Reg. 11: Enable Eint, full scroll
	dc.w		$8c81						; Reg. 12: Disable Shadow/Highlight, no interlace, 40 cell mode
	dc.w		$8d34						; Reg. 13: Hscroll is at $D000
	dc.w		$8e00						; Reg. 14: always zero
	dc.w		$8f00						; Reg. 15: no autoincrement
	dc.w		$9001						; Reg. 16: Scroll 32V and 32H
	dc.w		$9100						; Reg. 17: Set window X position/size to 0
	dc.w		$9200						; Reg. 18: Set window Y position/size to 0
	dc.w		$9300						; Reg. 19: DMA counter low
	dc.w		$9400						; Reg. 20: DMA counter high
	dc.w		$9500						; Reg. 21: DMA source address low
	dc.w		$9600						; Reg. 22: DMA source address mid
	dc.w		$9700						; Reg. 23: DMA source address high, DMA mode ?



LoadPalettes:
	move.l		#$00C00000,a4
	move.l		#$00C00004,a5

	move.w  	#$8F02,(a5)          			; Set autoincrement (register 15) to 2
	move.l  	#$C0000000,(a5)      			; Point data port to CRAM

	moveq   	#31,d0                			; We'll load 32 colors (2 palettes)
	lea     	_data_untitled_splash_palette,a0         			; Load address of Palettes into A0

 .1:
	move.w  	(a0)+,(a4)           			; Move word from palette into VDP data
                                    			; port and increment A0 by 2
	dbra    	d0,.1                 			; If D0 is not zero decrement and jump
                                    			; back to 1
	rts                             			; Return to caller


LoadPatterns:
	move.l		#$00C00000,a4
	move.l		#$00C00004,a5

    move.w  	#$8F02,(a5)				; Set autoincrement (register 15) to 2
    move.l  	#$40000000,(a5)			; Point data port to start of VRAM

    move.l 	  	#109*8,d0				; We'll load 4 patterns, each 8 longs wide
    lea     	_data_untitled_splash_bank,a0			; Load address of Patterns into A0

.1:
	move.l  	(a0)+,(a4)				; Move long word from patterns into VDP
										; port and increment A0 by 4
	dbra    	d0,.1					; If D0 is not zero decrement and jump
										; back to 1
    
    rts									; Return to caller


;==============================================================================
; FillPlaneA
;==============================================================================
FillPlaneA:
	move.l		#$00C00000,a4
	move.l		#$00C00004,a5

	move.w		#$8F02,(a5)			; Set autoincrement (register 15) to 2
	move.l		#$40000003,(a5)		; Point data port to $C000 in VRAM,
									; which is the start address of plane A
	move.l		#64*32,d0			; Loop this many cells
	lea			_data_untitled_splash_map,a0	; 

.loop:
	move.w		(a0)+,(a4)
	dbra		d0,.loop
	rts

;==============================================================================
; FillPlaneB
;==============================================================================
FillPlaneB:
	move.w		#$8F02,(a5)			; Set autoincrement (register 15) to 2
	move.l		#$60000003,(a5)		; Point data port to $E000 in VRAM,
									; which is the start address of plane B

	move.l		#1024,d0			; Loop 32x32 cells
	lea			PlaneCData,a0		; 

.loop:
	move.w		(a0)+,(a4)
	dbra		d0,.loop
	rts


; vram adress = $d400
; that is a15:1101:a12 a11:0100:a8 a7:0000:a4 a3:0000:a0
; cd0:1 cd1:0 cd2:0 cd3:0 cd4:0 cd5:0
; register 1st: 0101 0100 0000 0000 = $5400
; register 2nd: 0000 0000 0000 0011 = $0003

	nop
	nop
	nop

	dc.b	$00
	dc.b	$ff
	dc.b	$00
	dc.b	$ff
	dc.b	$00
	dc.b	$ff

LoadSprites:
	move.l		#$00C00000,a4
	move.l		#$00C00004,a5

	move.w		#$8F02,(a5)			; Set autoincrement (register 15) to 2
	move.l		#$60000003,(a5)
	lea			SpriteSetting,a0

;	move.l		#$54000003,(a5)		; Point data port to $D400 in VRAM,
									; which is the start address of sprite table

	move.l		(a0)+,(a4)			; Sprite setting should be 0 (1x1 sprite, tile index 4, no more sprites)
	move.l		(a0)+,(a4)			; Sprite setting should be 0 (1x1 sprite, tile index 4, no more sprites)

;	move.l		#0,(a4)				; Sprite setting should be 0 (1x1 sprite, tile index 0, no more sprites)
;	move.l		#1024,d0			; 
;	lea			PlaneAData,a0		; 

;.loop:
;	move.w		(a0)+,(a4)
;	dbra		d0,.loop

	rts
	
SpriteSetting:
	dc.w		$0080
	dc.w		$0f00
	dc.w		$0000
	dc.w		$0080



;==============================================================================
Palettes:
   dc.w			$0000  ; Color 0 is always transparent
   dc.w			$0fff
   dc.w			$0eee
   dc.w			$0ddd
   dc.w			$0ccc
   dc.w			$0bbb
   dc.w			$0aaa
   dc.w			$0999
   dc.w			$0888
   dc.w			$0777
   dc.w			$0666
   dc.w			$0555
   dc.w			$0444
   dc.w			$0333
   dc.w			$0222
   dc.w			$0111

   dc.w			$0000  ; Color 0 is always transparent
   dc.w			$0000
   dc.w			$0eee
   dc.w			$000e
   dc.w			$000e
   dc.w			$000e
   dc.w			$000e
   dc.w			$000e
   dc.w			$000e
   dc.w			$000e
   dc.w			$000e
   dc.w			$000e
   dc.w			$000e
   dc.w			$000e
   dc.w			$000e
   dc.w			$000e


Patterns:
	dc.l		$00000000
	dc.l		$00000000
	dc.l		$00000000
	dc.l		$00000000
	dc.l		$00000000
	dc.l		$00000000
	dc.l		$00000000
	dc.l		$00000000

;	dc.l		$fedcba98
;	dc.l		$fedcba98
;	dc.l		$fedcba98
;	dc.l		$fedcba98
;	dc.l		$76543210
;	dc.l		$76543210
;	dc.l		$76543210
;	dc.l		$76543210

;	dc.l		$ffffffff
;	dc.l		$ffffffff
;	dc.l		$ffffffff
;	dc.l		$ffffffff
;	dc.l		$ffffffff
;	dc.l		$ffffffff
;	dc.l		$ffffffff
;	dc.l		$ffffffff

	dc.l		$00000000
	dc.l		$00000000
	dc.l		$00000000
	dc.l		$00011100
	dc.l		$00011100
	dc.l		$00111000
	dc.l		$00000000
	dc.l		$00000000

;	dc.l		$0FF11771
;	dc.l		$0ee00661
;	dc.l		$0dd11551
;	dc.l		$0cc00441
;	dc.l		$0bb11331
;	dc.l		$0aa00221
;	dc.l		$09911111
;	dc.l		$08800001

	dc.l		$00000000
	dc.l		$00000000
	dc.l		$00000000
	dc.l		$00011000
	dc.l		$00011000
	dc.l		$00000000
	dc.l		$00000000
	dc.l		$00000000

	dc.l		$22222222
	dc.l		$21111112
	dc.l		$21222212
	dc.l		$21200212
	dc.l		$21200212
	dc.l		$21222212
	dc.l		$21111112
	dc.l		$22222222

	; Tile 5
	dc.l		$12345678
	dc.l		$2f0ff0f7
	dc.l		$3f9abc06
	dc.l		$40adeb05
	dc.l		$50beda04
	dc.l		$6fcba9f3
	dc.l		$7f0ff0f2
	dc.l		$87654321




	dc.l		$00000000
	dc.l		$00000000
	dc.l		$00000000
	dc.l		$00011100
	dc.l		$00011100
	dc.l		$00111000
	dc.l		$00000000
	dc.l		$00000000

	dc.l		$00000000
	dc.l		$00000000
	dc.l		$00000000
	dc.l		$00011000
	dc.l		$00011000
	dc.l		$00000000
	dc.l		$00000000
	dc.l		$00000000

	dc.l		$22222222
	dc.l		$21111112
	dc.l		$21222212
	dc.l		$21200212
	dc.l		$21200212
	dc.l		$21222212
	dc.l		$21111112
	dc.l		$22222222

	dc.l		$12345678
	dc.l		$2f0ff0f7
	dc.l		$3f9abc06
	dc.l		$40adeb05
	dc.l		$50beda04
	dc.l		$6fcba9f3
	dc.l		$7f0ff0f2
	dc.l		$87654321

	; 10
	dc.l		$00000000
	dc.l		$00000000
	dc.l		$00000000
	dc.l		$00011100
	dc.l		$00011100
	dc.l		$00111000
	dc.l		$00000000
	dc.l		$00000000

	dc.l		$00000000
	dc.l		$00000000
	dc.l		$00000000
	dc.l		$00011000
	dc.l		$00011000
	dc.l		$00000000
	dc.l		$00000000
	dc.l		$00000000

	dc.l		$22222222
	dc.l		$21111112
	dc.l		$21222212
	dc.l		$21200212
	dc.l		$21200212
	dc.l		$21222212
	dc.l		$21111112
	dc.l		$22222222

	dc.l		$12345678
	dc.l		$2f0ff0f7
	dc.l		$3f9abc06
	dc.l		$40adeb05
	dc.l		$50beda04
	dc.l		$6fcba9f3
	dc.l		$7f0ff0f2
	dc.l		$87654321

	dc.l		$00000000
	dc.l		$00000000
	dc.l		$00000000
	dc.l		$00011100
	dc.l		$00011100
	dc.l		$00111000
	dc.l		$00000000
	dc.l		$00000000

	dc.l		$00000000
	dc.l		$00000000
	dc.l		$00000000
	dc.l		$00011000
	dc.l		$00011000
	dc.l		$00000000
	dc.l		$00000000
	dc.l		$00000000

	dc.l		$22222222
	dc.l		$21111112
	dc.l		$21222212
	dc.l		$21200212
	dc.l		$21200212
	dc.l		$21222212
	dc.l		$21111112
	dc.l		$22222222

	dc.l		$12345678
	dc.l		$2f0ff0f7
	dc.l		$3f9abc06
	dc.l		$40adeb05
	dc.l		$50beda04
	dc.l		$6fcba9f3
	dc.l		$7f0ff0f2
	dc.l		$87654321

	dc.l		$00000000
	dc.l		$00000000
	dc.l		$00000000
	dc.l		$00011100
	dc.l		$00011100
	dc.l		$00111000
	dc.l		$00000000
	dc.l		$00000000

	dc.l		$00000000
	dc.l		$00000000
	dc.l		$00000000
	dc.l		$00011000
	dc.l		$00011000
	dc.l		$00000000
	dc.l		$00000000
	dc.l		$00000000

	; 20
	dc.l		$22222222
	dc.l		$21111112
	dc.l		$21222212
	dc.l		$21200212
	dc.l		$21200212
	dc.l		$21222212
	dc.l		$21111112
	dc.l		$22222222

	dc.l		$12345678
	dc.l		$2f0ff0f7
	dc.l		$3f9abc06
	dc.l		$40adeb05
	dc.l		$50beda04
	dc.l		$6fcba9f3
	dc.l		$7f0ff0f2
	dc.l		$87654321



PlaneAData:
	dc.w	$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001
	dc.w	$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001
	dc.w	$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001
	dc.w	$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001
	dc.w	$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001
	dc.w	$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001
	dc.w	$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001
	dc.w	$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001
	dc.w	$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001
	dc.w	$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001
	dc.w	$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001
	dc.w	$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001
	dc.w	$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001
	dc.w	$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001
	dc.w	$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001
	dc.w	$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001
	dc.w	$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001
	dc.w	$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001
	dc.w	$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001
	dc.w	$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001
	dc.w	$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001
	dc.w	$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001
	dc.w	$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001
	dc.w	$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001
	dc.w	$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001
	dc.w	$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001
	dc.w	$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001
	dc.w	$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001
	dc.w	$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001
	dc.w	$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001
	dc.w	$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001
	dc.w	$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001

PlaneBData:
	dc.w	$0000,$0000,$0001,$0001,$0002,$0002,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003
	dc.w	$0000,$0001,$0001,$0002,$0002,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003
	dc.w	$0001,$0001,$0002,$0002,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003
	dc.w	$0001,$0002,$0002,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003
	dc.w	$0002,$0002,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003
	dc.w	$0002,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003
	dc.w	$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003
	dc.w	$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003
	dc.w	$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003
	dc.w	$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003
	dc.w	$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003
	dc.w	$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003
	dc.w	$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003
	dc.w	$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003
	dc.w	$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003
	dc.w	$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003
	dc.w	$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003
	dc.w	$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003
	dc.w	$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003
	dc.w	$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003
	dc.w	$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003
	dc.w	$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003
	dc.w	$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003
	dc.w	$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003
	dc.w	$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003
	dc.w	$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003
	dc.w	$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003
	dc.w	$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003
	dc.w	$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003
	dc.w	$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003
	dc.w	$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003
	dc.w	$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003,$0003

PlaneCData:
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000

;TestPalette:
;	incbin	"../src/incbin/untitled_splash.bin.palette"

;TestPatterns:
;	incbin	"../src/incbin/untitled_splash.bin.bank"

;TestPlaneData:
;	incbin	"../src/incbin/untitled_splash.bin.map"
