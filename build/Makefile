
VASM68K=../bin/osx/vasmm68k_mot

all: megadrive amiga atarist


megadrive:
	$(VASM68K) -Fbin -o out/untitled_megadrive.bin megadrive.asm -Dis_mega_drive -m68000 -L megadrive_listfile.txt
	../bin/osx/buildcomments megadrive_listfile.txt mess/comments/megadriv.cmt megadriv


amiga:
	$(VASM68K) -Fbin -o out/untitled.adf amigaadf.asm -Dis_amiga -m68000 -I"/Users/magnusrunesson/Projects/Amiga/NDK_3.9/Include/include_i" -I"../src/platform/amiga/amiga_lib"
	../bin/osx/makeimage out/untitled.adf

atarist:
	$(VASM68K) -Ftos -o out/untitled.tos atarist.asm -Dis_atari_st -m68000


.PHONY: megadrive amiga atarist
