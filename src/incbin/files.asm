fileid_testsprite_sprite_chunky         equ 0
fileid_testsprite_palette               equ 1
fileid_testsprite_sprite_planar         equ 2
fileid_testtiles_bank                   equ 3
fileid_testtiles_map                    equ 4
fileid_testtiles_palette                equ 5
fileid_testtiles_planar                 equ 6
fileid_untitled_splash_bank             equ 7
fileid_untitled_splash_map              equ 8
fileid_untitled_splash_palette          equ 9
fileid_untitled_splash_planar           equ 10

FileIDMap:
	dc.w	_data_testsprite_sprite_chunky_pos,_data_testsprite_sprite_chunky_length
	dc.w	_data_testsprite_palette_pos,_data_testsprite_palette_length
	dc.w	_data_testsprite_sprite_planar_pos,_data_testsprite_sprite_planar_length
	dc.w	_data_testtiles_bank_pos,_data_testtiles_bank_length
	dc.w	_data_testtiles_map_pos,_data_testtiles_map_length
	dc.w	_data_testtiles_palette_pos,_data_testtiles_palette_length
	dc.w	_data_testtiles_planar_pos,_data_testtiles_planar_length
	dc.w	_data_untitled_splash_bank_pos,_data_untitled_splash_bank_length
	dc.w	_data_untitled_splash_map_pos,_data_untitled_splash_map_length
	dc.w	_data_untitled_splash_palette_pos,_data_untitled_splash_palette_length
	dc.w	_data_untitled_splash_planar_pos,_data_untitled_splash_planar_length
