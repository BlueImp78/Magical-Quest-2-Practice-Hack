include


warp_menu:
	SEP #$20
	LDA !pause_flag  		;check if game is paused
	BEQ .clear_vram  		;if not, check if we should clear our text from vram
	LDA !menu_dma_done 		;else check if we already DMA'd the menu text
	BNE .check_input_trampoline 	;if yes, check for inputs
	REP #$20  			
	STZ !cursor_pos 		;else initialize cursor position...
	LDA #$4D2A
	STA !cursor_offset 		;and its vram address offset

;setup warp text DMA
	LDA #$4CAC 			;load inital vram address
	PHA  				;preserve it for later
	STA !vram_destination 		;set vram address
	LDA #warp_text 			
	PHA  				;and also preserve it
	STA !data_address 		;set adress of text
	LDA #$0010
	STA !bytes_to_transfer 		;and how many bytes to transfer
	JSR DMA_to_VRAM_ch2  		;DMA top half of text
	REP #$20
	PLA 				;restore inital address of text
	CLC 
	ADC #$0010 			;and offset it to get to bottom half tile
	STA !data_address
	PLA 				;restore initial vram address
	CLC
	ADC #$0020 			;and offset it to place the next bottom half tile
	STA !vram_destination
	JSR DMA_to_VRAM_ch2  		


;setup stages text DMA
	REP #$30 			;16-bit A/X/Y
	LDA #$4D2C
	STA !vram_destination
	LDA #stages_text
	STA !data_address
	LDA #$000E
	STA !bytes_to_transfer
	LDX #$0005  			;start a loop counter (6 stages, upload text 6 times)
--:
	JSR DMA_to_VRAM_ch2  		;DMA the text
	REP #$20 			;16-bit A
	LDA !vram_destination
	CLC
	ADC #$0040
	STA !vram_destination 		;offset vram destination address
	LDA !data_address
	CLC
	ADC #$000E 			;then do the same for the text data address
	STA !data_address
	DEX  				;decrease loop counter
	BPL -- 				;if still positive, loop again
	INC !menu_dma_done 		;set a flag telling we're done DMA'ing all the menu the text
.done:
	SEP #$30 			;8-bit A/X/Y
	RTS 

.check_input_trampoline:
	BRA .check_input 		;needed because above BNE doesn't reach where we want to go

.clear_vram:
	LDA !game_state
	CMP #$0C 			;if we're not in a level, return
	BNE .done
	REP #$20 			;16-bit A
	LDA !menu_dma_done 		;check if we've already DMA'd the text
	BEQ .done 			;if not, return
	LDA #$4CAC
	STA !vram_destination 		;else set vram address to clear
	LDA #zero_fill 			
	STA !data_address 		;load address with nothing but 00's
	LDA #$0398
	STA !bytes_to_transfer 		;number of bytes to clear all menu text
	JSR DMA_to_VRAM_ch2 		;DMA the 00's to clear it
	SEP #$20   			;8-bit A
	STZ !menu_dma_done  		;clear the flag
	RTS

.check_input:
	JSR update_cursor  		
	REP #$20 			;16-bit A
	LDA !player1_press
	BIT #$D0C0  			;check if player is pressing any face buttons (ABXY)
	BNE ..warp_to_stage 		;if yes, warp to selected stage
	SEP #$20 			;else 8-bit A
	LDA !player1_press 	
	BIT #$04  			;check if pressing down
	BEQ ..check_up 			;if not, check if pressing up
	LDA !cursor_pos 		;else get our current cursor position
	INC 				;increase it
	CMP #$06  			;check if it goes past max amount of options
	BCS .done 			;if yes, return
	STA !cursor_pos 		;else update its position
	REP #$20 			;16-bit A
	LDA !cursor_offset 		;get our current cursor vram address offset
	PHA 				;preserve it
	CLC 				
	ADC #$0040  			;offset it to get to next position
	STA !cursor_offset
	PLA 				;restore our previous cursor position
	BRA ..clear_previous_pos 	;and clear the vram from where it was

..check_up:
	BIT #$08  			;check if pressing up
	BEQ .done 			;if not, return
	LDA !cursor_pos 		;else do the same as above but for moving the cursor up instead
	DEC
	BMI .done
	STA !cursor_pos
	REP #$20
	LDA !cursor_offset
	PHA
	SEC
	SBC #$0040
	STA !cursor_offset
	PLA
..clear_previous_pos:
	STA !vram_destination 		;update vram address with where the cursor previously was before moving
	LDA #zero_fill
	STA !data_address 		;load data with nothing but 00's
	JSR DMA_to_VRAM_ch2 		;and clear vram in that address
	LDA #$3A
	JSL queue_sound_effect 		;play menu move sfx
	BRL .done


..warp_to_stage:
	SEP #$20 			;8-bit A
	LDA !cursor_pos 		;get our cursor position (0 through 5)
	STA !level_number 		;and store it in the level number
	STZ !next_room 			;set next room to room 0
	STZ !pause_flag 		;clear the pause flag
	LDA #$3B  		 	
	JSL queue_sound_effect  	;play menu confirm sfx
	LDA #$F4
	JSL queue_sound_effect 		;fixes music not restarting (somehow lol)
	PLA 				;pop last call from stack
	PLB
	JMP start_transition 		;and jump to start transition to the level

	
update_cursor:
	REP #$20 			;16-bit A
	LDA !cursor_offset 		;get our cursor offset
	STA !vram_destination 		;and set it as the vram address
	LDA #cursor
	STA !data_address 		;set address of cursor text
	LDA #$0002
	STA !bytes_to_transfer 		;transfer 2 bytes
	JSR DMA_to_VRAM
	SEP #$20			;8-bit A 
	RTS


DMA_to_VRAM:
	REP #$20
	LDA #$0080
	STA $2115
	LDA !vram_destination
	STA $2116           		;vram address
	LDA #$1801          		;two registers, write once
	STA $4300
	LDA.w !data_address  		;text address
	STA $4302
	LDY.b #$D8          		;text bank byte
	STY $4304
	LDA !bytes_to_transfer         
	STA $4305
	SEP #$20
	LDA.b #$01  			;channel 0
	STA $420B           		;enable DMA and pray it works
	RTS   				;get me tf outta here


;warp menu needs to be channel 2 to not corrupt boss graphics
DMA_to_VRAM_ch2:
	REP #$20 			;16-bit A
	LDA #$0080
	STA $2115
	LDA !vram_destination
	STA $2116           		;vram address
	LDA #$1801          		;two registers, write once
	STA $4320
	LDA.w !data_address  		;text address
	STA $4322
	LDY.b #$D8          		;text bank byte
	STY $4324
	LDA !bytes_to_transfer         
	STA $4325 
	SEP #$20 			;8-bit A
	LDA.b #$04 			;channel 2
	STA $420B           		;enable DMA and pray it works
	RTS   				;get me tf outta here

;$50 bytes
warp_text:
	dw $20C6, $20C7, $2080, $2081, $20AC, $20AD, $20AA, $20AB
	dw $20D6, $20D7, $2090, $2091, $20BC, $20BD, $20BA, $20BB


;$0E bytes each
stages_text:
	dw $2053, $2054, $2041, $2047, $2045, $0000, $2031
	dw $2053, $2054, $2041, $2047, $2045, $0000, $2032	
	dw $2053, $2054, $2041, $2047, $2045, $0000, $2033
	dw $2053, $2054, $2041, $2047, $2045, $0000, $2034
	dw $2053, $2054, $2041, $2047, $2045, $0000, $2035
	dw $2053, $2054, $2041, $2047, $2045, $0000, $2036
	

cursor:
	dw $203E


;pad 00's until end of bank
zero_fill:
	padbyte $00 : pad $D8FFFF