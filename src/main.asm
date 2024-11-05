hirom

org $008000    
	incsrc defines.asm
	incsrc hijacks.asm

org freerom
	incsrc "room_change.asm"
	incsrc "rng_display.asm"
	incsrc "warp_menu.asm"  	;zero fills rest of bank at the end, included last

warnpc freerom|$FFFF 			