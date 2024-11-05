include


change_room:
        LDA !pause_flag 		;check if game is paused
        BNE .done 			;if yes, return
        REP #$20 			;else 16-bit A
        LDA !player1_hold
	BIT #$0020 			;check if player pressed SELECT
	BNE start_transition  		;if yes reload current room
        BIT #$4000 			;else check if holding X
        BNE .holding_x 			;if yes, go check for dpad input
.done:
        SEP #$20  			;else 8-bit A and return
        LDA $48                         ;hijacked instruction
        BIT #$10                        ;hijacked instruction
	RTL


.holding_x:
        LDX !level_number 		;store level number in X to be used as index later
        BIT #$0003 			;check if pressing left or right
        BEQ .done 			;if not, return
        BIT #$0001 			;else check if pressing right
        BNE .next_room 			;if yes, warp to next room
        BIT #$0002 			;else check if pressing left
        BNE .previous_room 		;if yes, warp to previous room
        BRA .done 			;return

.previous_room:
        SEP #$20 			;8-bit A
        LDA !next_room 			;get number of room we should go to
        DEC  				;decrease it
        BPL + 				;if positive, update it and start the transition
        LDA room_cap_table,x 		;else get whats the last room in the stage +1 from table in ROM
	DEC 				;decrease it to get actual last room
+:
        STA !next_room 			;update room we're going to
        BRA start_transition 		;and start the transition


.next_room
        SEP #$20 			;8-bit A
        LDA !next_room 			;get number of room we should go to
        INC 				;increase it
        CMP room_cap_table,x 		;check if its more than the max number of rooms in the level
        BNE ++ 				;if positive, update it and start the transition
	LDA #$00 			;else set new room to first room (not an STZ because we need an STA right below this)
++:	
        STA !next_room 			;update room we're going to
start_transition:
	STZ !rng_text_dma_done  	;clear this flag so "RNG:" text shows up for next room too
        STZ $A1  			;trigger the room/level transition
	LDA !difficulty 		
	BEQ .easy  			;dont setup room if on normal or hard
	BRL room_setup_done


;Use our level number to index a table with each room in that level
.easy:
	LDA !level_number
        ASL
        TAX
        JMP (level_table,x)


level_table:
	dw level_1
	dw level_2
	dw level_3
	dw level_4
	dw level_5
	dw level_6


;use room number to setup our stuff properly
;addresses that are right next to each other are set in 16-bit A
level_1:
	LDA !next_room
	ASL
	TAX
	JMP (.level_1_room_setup,x)

.level_1_room_setup:
	dw ..room_0
	dw ..room_1
	dw ..room_2

..room_0:
	STZ !available_costumes
	REP #$20
	LDA #$01C3
	STA !rng
-:
	STZ !active_costume 
--:	
	LDA #$0505
	STA !current_hearts
	LDA #$1C1C
	STA !ammo	
	BRL room_setup_done

..room_1:
	LDA #$02
	STA !available_costumes
	REP #$20
	LDA #$0202
	STA !active_costume
	LDA #$394F
	STA !rng
	BRA --

..room_2:
	LDA #$02
	STA !available_costumes
	REP #$20
	LDA #$0202
	STA !active_costume
	LDA #$6683
	STA !rng
	BRA --


level_2:
	LDA !next_room
	ASL
	TAX
	JMP (.level_2_room_setup,x)		

.level_2_room_setup:
	dw ..room_0
	dw ..room_1
	dw ..room_2
	dw ..room_3

..room_0:
	LDA #$04
	STA !available_costumes	
	REP #$20
	LDA #$0FE1
	STA !rng	
	LDA #$0404
	STA !active_costume
-:
	LDA #$0505
	STA !current_hearts
--:
	LDA #$1C1C
	STA !ammo
	BRL room_setup_done

..room_1:
	LDA #$04
	STA !available_costumes
	REP #$20
	LDA #$0404
	STA !active_costume
---:
	LDA #$2769
	STA !rng
	BRA --	

..room_2:
	LDA #$04
	STA !available_costumes
	REP #$20
	LDA #$0404
	STA !current_hearts
	STA !active_costume
	LDA #$1C1C
	STA !ammo
	BRA ---

..room_3:
	LDA #$04
	STA !available_costumes
	REP #$20
	LDA #$0202
	STA !current_hearts
	LDA #$9F13
	STA !rng
	LDA #$0404
	STA !active_costume
	BRA --


level_3:
	LDA !next_room
	ASL
	TAX
	JMP (.level_3_room_setup,x)		

.level_3_room_setup:
	dw ..room_0
	dw ..room_1
	dw ..room_2
	dw ..room_3
	dw ..room_4
	dw ..room_5	

..room_0:
	LDA #$06
	STA !available_costumes
	REP #$20
	LDA #$0606
	STA !active_costume
-:
	LDA #$C415
	STA !rng
--:
	LDA #$0505
	STA !current_hearts
	LDA #$1C1C
	STA !ammo
	BRL room_setup_done

..room_1
	REP #$20
	LDA #$0606
	STA !active_costume
	BRA -

..room_2:
	REP #$20
	LDA #$A0C2
	STA !rng
	BRA --

..room_3:
	REP #$20
	LDA #$0404
	STA !active_costume
	LDA #$1A1C
	STA !ammo
---:
	LDA #$8E1F
	STA !rng
	LDA #$0505
	STA !current_hearts
	BRL room_setup_done


..room_4:
	REP #$20
	LDA #$191C
	STA !ammo
	LDA #$0606
	STA !active_costume
	BRA ---

..room_5:
	REP #$20
	LDA #$00C9
	STA !rng
	LDA #$0606
	STA !active_costume
	LDA #$0505
	STA !current_hearts
	LDA #$191C
	STA !ammo
	BRL room_setup_done


level_4:
	LDA !next_room
	ASL
	TAX
	JMP (.level_4_room_setup,x)		

.level_4_room_setup:
	dw ..room_0
	dw ..room_1
	dw ..room_2


..room_0:
	LDA #$06
	STA !available_costumes
	REP #$20
	LDA #$D500
	STA !rng
-:
	LDA #$0505
	STA !current_hearts
	LDA #$0404
	STA !active_costume
	LDA #$1C1C
	STA !ammo
	BRL room_setup_done

..room_1:
	REP #$20
	LDA #$E58C
	STA !rng
	BRA -

..room_2:
	LDA #$06
	STA !active_costume
	LDA #$04
	STA !selected_costume
	REP #$20
	LDA #$0303
	STA !current_hearts
	LDA #$191C
	STA !ammo
	LDA #$5306
	STA !rng
	BRL room_setup_done


level_5:
	LDA !next_room
	ASL
	TAX
	JMP (.level_5_room_setup,x)	

.level_5_room_setup:
	dw ..room_0
	dw ..room_1
	dw ..room_2

..room_0:
	LDA #$06
	STA !available_costumes
	REP #$20
	LDA #$1C1C
	STA !ammo
	LDA #$FFA0
	STA !rng
-:
	LDA #$0505
	STA !current_hearts
	LDA #$0606
	STA !active_costume
	BRL room_setup_done

..room_1:
	REP #$20
	LDA #$0404
	STA !current_hearts
	LDA #$0606
	STA !active_costume
	LDA #$161C
	STA !ammo
	LDA #$262F
	STA !rng
	BRL room_setup_done

..room_2:
	REP #$20
	LDA #$131C
	STA !ammo
	LDA #$A1B1
	STA !rng
	BRA -

level_6:
	LDA !next_room
	ASL
	TAX
	JMP (.level_6_room_setup,x)	

.level_6_room_setup:
	dw ..room_0
	dw ..room_1
	dw ..room_2
	dw ..room_3
	dw ..room_4
	dw ..room_5	

..room_0:
	LDA #$06
	STA !available_costumes
	REP #$20
	LDA #$1C1C
	STA !ammo
	LDA #$B0F2
	STA !rng
	LDA #$0505
	STA !current_hearts
	LDA #$0404
	STA !active_costume
	BRL room_setup_done

..room_1:
	STZ $CC
	REP #$20
	LDA #$B0F2
	STA !rng
	LDA #$1C1C
	STA !ammo
-:
	LDA #$0404
	STA !current_hearts
	LDA #$0606
	STA !active_costume
	BRA room_setup_done

..room_2:
	STZ $CC
	REP #$20
	LDA #$1B1C
	STA !ammo
	LDA #$1204
	STA !rng
	BRA -

..room_3:
	LDA #$02
	STA $CC
	REP #$20
	LDA #$1A1C
	STA !ammo
	LDA #$34F5
	STA !rng
	BRA -

..room_4:
	LDA #$03
	STA $CC
	REP #$20
	LDA #$181C
	STA !ammo
	LDA #$490C
	STA !rng
	BRA -

..room_5:
	SEP #$20
	LDA #$03
	STA $CC
	LDA #$04
	STA !active_costume
	LDA #$06
	STA !selected_costume
	REP #$20
	LDA #$171C
	STA !ammo
	LDA #$6D3C
	STA !rng
	LDA #$0404
	STA !current_hearts


room_setup_done:
        SEP #$20 			;8-bit A
	INC !rng_changed_flag  		;set flag so rng display updates as soon as the new room loads
        LDA $48                         ;hijacked instruction
        BIT #$10                        ;hijacked instruction
        RTL


