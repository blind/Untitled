;==============================================================================
;
; Get the address to a file
;
; Input:
;	d0=file ID
;
; Output
;	a0=address to file data
;	d0=file size
;
;==============================================================================
fileLoad:
	movea.w		#0,a0
	moveq		#0,d0
	rts
