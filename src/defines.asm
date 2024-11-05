include

freerom = $D80000               ;start of expanded rom


;hijacks
hijack_difficulty_set_on_boot = $C0029B
hijack_active_frame_counter = $C00628
hijack_every_frame_nmi = $C01A5F
hijack_level_load = $C01C23
hijack_rng_update = $C0217B
hijack_game_start = $C1B913
hijack_lives_decrease = $C11068
hijack_title_screen_text_pointer = $80DB1B
hijack_title_screen_text = $80F1D0


;rom tables
room_cap_table = $81E7          ;bank 80, uses level # as index for whats the max # of rooms in the level
enemy_score_table = $8368       ;bank 80, unclear-ish

;routines
queue_sound_effect = $C04E32 


;ram
!player1_hold = $44
!player1_release = $46
!player1_press = $48
!screen_brightness = $70
!global_frame_counter = $9C
!active_frame_counter = $9F
!game_state = $A0               ;unclear, take with grain of salt
!pause_flag = $AC
!level_number = $B7
!next_room = $B8
!current_room = $B9
!number_of_players = $C2        ;$01 = 1 player, $03 = 2 players
!current_hearts = $0220
!active_costume = $0280
!selected_costume = $0281
!current_hearts_2 = $0221
!max_hearts = $027F
!ammo = $0292                         
!score = $0299                  ;3 bytes
!coins = $029C
!rng = $1BE8
!rng1 = $1BE8
!rng2 = $1BE9
!available_costumes = $1BBF
!difficulty = $1BF8
!sfx_upload_ring_buffer = $1E80



;custom ram
!menu_dma_done = $1FC0
!vram_destination = $1FC2
!data_address = $1FC4
!bytes_to_transfer = $1FC6
!cursor_pos = $1FC8
!cursor_offset = $1FCA
!rng_text_dma_done = $1FCC
!temp = $1FCE
!rng_changed_flag = $1FD0