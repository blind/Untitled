

; testtiles_bank.bin

	cnop		0,_chunk_size
_data_testtiles_bank:
	incbin	"../src/incbin/testtiles_bank.bin"
_data_testtiles_bank_pos                equ _data_testtiles_bank/_chunk_size
_data_testtiles_bank_length             equ ((_data_testtiles_bank_end-_data_testtiles_bank)+(_chunk_size-1))/_chunk_size
_data_testtiles_bank_end:


; testtiles_map.bin

	cnop		0,_chunk_size
_data_testtiles_map:
	incbin	"../src/incbin/testtiles_map.bin"
_data_testtiles_map_pos                 equ _data_testtiles_map/_chunk_size
_data_testtiles_map_length              equ ((_data_testtiles_map_end-_data_testtiles_map)+(_chunk_size-1))/_chunk_size
_data_testtiles_map_end:


; testtiles_palette.bin

	cnop		0,_chunk_size
_data_testtiles_palette:
	incbin	"../src/incbin/testtiles_palette.bin"
_data_testtiles_palette_pos             equ _data_testtiles_palette/_chunk_size
_data_testtiles_palette_length          equ ((_data_testtiles_palette_end-_data_testtiles_palette)+(_chunk_size-1))/_chunk_size
_data_testtiles_palette_end:


; testtiles_planar.bin

	cnop		0,_chunk_size
_data_testtiles_planar:
	incbin	"../src/incbin/testtiles_planar.bin"
_data_testtiles_planar_pos              equ _data_testtiles_planar/_chunk_size
_data_testtiles_planar_length           equ ((_data_testtiles_planar_end-_data_testtiles_planar)+(_chunk_size-1))/_chunk_size
_data_testtiles_planar_end:


; untitled_splash_bank.bin

	cnop		0,_chunk_size
_data_untitled_splash_bank:
	incbin	"../src/incbin/untitled_splash_bank.bin"
_data_untitled_splash_bank_pos          equ _data_untitled_splash_bank/_chunk_size
_data_untitled_splash_bank_length       equ ((_data_untitled_splash_bank_end-_data_untitled_splash_bank)+(_chunk_size-1))/_chunk_size
_data_untitled_splash_bank_end:


; untitled_splash_map.bin

	cnop		0,_chunk_size
_data_untitled_splash_map:
	incbin	"../src/incbin/untitled_splash_map.bin"
_data_untitled_splash_map_pos           equ _data_untitled_splash_map/_chunk_size
_data_untitled_splash_map_length        equ ((_data_untitled_splash_map_end-_data_untitled_splash_map)+(_chunk_size-1))/_chunk_size
_data_untitled_splash_map_end:


; untitled_splash_palette.bin

	cnop		0,_chunk_size
_data_untitled_splash_palette:
	incbin	"../src/incbin/untitled_splash_palette.bin"
_data_untitled_splash_palette_pos       equ _data_untitled_splash_palette/_chunk_size
_data_untitled_splash_palette_length    equ ((_data_untitled_splash_palette_end-_data_untitled_splash_palette)+(_chunk_size-1))/_chunk_size
_data_untitled_splash_palette_end:


; untitled_splash_planar.bin

	cnop		0,_chunk_size
_data_untitled_splash_planar:
	incbin	"../src/incbin/untitled_splash_planar.bin"
_data_untitled_splash_planar_pos        equ _data_untitled_splash_planar/_chunk_size
_data_untitled_splash_planar_length     equ ((_data_untitled_splash_planar_end-_data_untitled_splash_planar)+(_chunk_size-1))/_chunk_size
_data_untitled_splash_planar_end:
