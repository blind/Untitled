_start:
	move.l	4(sp),a5		;address to basepage
	move.l	$0c(a5),d0	;length of text segment
	add.l	$14(a5),d0	;length of data segment
	add.l	$1c(a5),d0	;length of bss segment
	add.l	#$100,d0		;length of basepage
	add.l	#$2000,d0		;length of stackpointer
	move.l	a5,d1		;address to basepage
	add.l	d0,d1		;end of program
	and.l	#-2,d1		;make address even
	move.l	d1,sp		;new stackspace

	move.l	d0,-(sp)		;mshrink()
	move.l	a5,-(sp)		;
	move.w	d0,-(sp)		;
	move.w	#$4a,-(sp)	;
	trap	#1		;
	lea	12(sp),sp		;


	clr.l	-(sp)		; Enter supervisor mode
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp

	move.l	#_vblHandler,$70.w


