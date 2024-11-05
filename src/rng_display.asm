include 

print_rng_text:
	SEP #$20
	PHX 			;preserve X from routine we hijacked
	LDA !game_state 	;check if we're in a level
	CMP #$0C 		
	BNE .done 		;if not, we're done
	LDA !pause_flag 	;else check if game is paused
	BNE .done 		;if yes, we're done
	REP #$20 		;else DMA "RNG:" text
	LDA !level_number
	CMP #$0302  		;check if we're in stage 3 dark room
	BNE +  			;if not, DMA text to normal position
	LDA #$4F2F 		;else put it in the bottom
	BRA ++

+:
	LDA #$4CA2
++:
	STA !vram_destination
	LDA #rng_text
	STA !data_address
	LDA #$0008
	STA !bytes_to_transfer
	JSR DMA_to_VRAM
	INC !rng_text_dma_done  ;set flag telling we're done dma'ing the "RNG:" text
.done: 
	PLX 			;restore X 
	SEP #$21
	TXA  			;hijacked instruction
	ADC #$07 		;hijacked instruction
	TAX  			;hijacked instruction
	RTL 


rng_text:
	dw $2052, $204E, $2047, $203A


update_rng_value:
	JSR warp_menu 		;call warp menu text from here to make use of v-blank
	REP #$20
	LDA !game_state 	;check if we're in a screen transition
	CMP #$020C
	BEQ .in_transition 	;if yes, always update rng display
	LDA !rng_changed_flag
	BEQ .done   		;if rng hasn't changed yet, return
.in_transition:
	NOP #10 		;else stall for v-blank (not ideal but it works, ps: fuck the snes PPU dev)
	LDA !level_number
	CMP #$0302 		;check if we're in stage 3 dark room
	BNE + 			;if not, DMA text to normal position
	LDA #$4F33 		;else put it in the bottom
	BRA ++

+:
	LDA #$4CA6
++:
	STA !vram_destination
	LDA #$0002
	STA !bytes_to_transfer


;print first byte
	LDA #rng_characters 	
	STA !data_address 	;set base address of rng characters data
	SEP #$20 		;8-bit A
	LDA !rng2 		;get first (cuz little endian) byte of RNG value
	STA !temp 		;put it in a temporary address
	LDY #$01 		;start a loop counter (2 bytes to DMA)
-:
	LDX #$01 		;and another (2 digits from each byte)
	AND #$F0 		
	LSR 
	LSR  			;math stuff to isolate first digit from the loaded byte
	LSR 
	LSR   
.loop:
	ASL
	CLC
	ADC !data_address  	;offset base data address
	STA !data_address 	;and update it
	PHY 			;preserve our Y loop counter (DMA routine uses Y)
	JSR DMA_to_VRAM 	;DMA the character
	PLY 			;restore Y loop counter
	REP #$20 		;16-bit A
	LDA #rng_characters 	;set base address again
	STA !data_address
	SEP #$20 		;8-bit A
	LDA !temp
	AND #$0F
	INC !vram_destination	;increase vram address by 1 to get to next tile position
	DEX 			;decrease the loop counter
	BPL .loop 		;if still positive, loop again

;print second byte
	LDA !rng1 		;else get second byte of RNG
	STA !temp 		;put it in the temporary address
	DEY 			;decrease the counter in Y
	BPL - 			;if still positive loop again
	SEP #$20 		;else 8-bit A
	STZ !rng_changed_flag 	;and clear the "rng changed" flag
.done:
	SEP #$20
	LDA $4212 		;hijacked instruction
	AND #$01	 	;hijacked instruction
	RTL


;first byte: tile properties
;second byte: tile index (ASCII)
rng_characters:
	dw $2030    		;0
	dw $2031    		;1
	dw $2032    		;2
	dw $2033    		;3
	dw $2034    		;4
	dw $2035    		;5
	dw $2036    		;6
	dw $2037    		;7
	dw $2038    		;8
	dw $2039    		;9
	dw $2041		;A
	dw $2042		;B
	dw $2043		;C
	dw $2044		;D
	dw $2045		;E
	dw $2046		;F


;when the game's RNG changes, turn on the flag so our routine above updates the display
store_previous_rng:
	LDA $0001  		;hijacked instruction
	STA $1BE9  		;hijacked instruction
	STA !rng_changed_flag
	RTL 