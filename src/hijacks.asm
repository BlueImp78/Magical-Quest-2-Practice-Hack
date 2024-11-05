include

;default to easy difficulty
org hijack_difficulty_set_on_boot
        STZ !difficulty


org hijack_active_frame_counter
        JSL change_room


org hijack_every_frame_nmi
        JSL update_rng_value
        NOP


org hijack_rng_update
        JSL store_previous_rng
        WDM


org hijack_level_load
        JSL print_rng_text


;dont decrease lives on death
org hijack_lives_decrease
        WDM 
        BRA $14


;change pointer to point to new text below
org hijack_title_screen_text_pointer
        dw $F1D0


; first byte of header: string length
; second byte: tile properties
; word: vram destination address
org hijack_title_screen_text
ego_text:
        db $18, $28 : dw $4F04               
        db "@ DISNEY, BY CAPCOM 1994"
        db $1E, $28 : dw $4F41
        db "PRAC HACK V1.0 BY BLUEIMP 2024"
        db $00     