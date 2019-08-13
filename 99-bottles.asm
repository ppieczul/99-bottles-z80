width       EQU     31
height      EQU     21
chars_num   EQU     58

            ORG     30000
            CALL    copy_fonts
            LD      a,2
            CALL    5633
            LD      hl,text
repeat_frame:
            LD      bc,0
            LD      de,0
draw_frame_inside:
            CALL    loop_1
            INC     b
            INC     c
            INC     d
            INC     e
            LD      a,c
            CP      height/2+1
            JR      nz,draw_frame_inside
            LD      a,(end_story)
            CP      1
            JR      nz,repeat_frame
            RET

loop_1:
            CALL    print_char
            INC     d
            LD      a,width
            SUB     b
            CP      d
            JR      nz,loop_1
            CALL    rotate
loop_2:
            CALL    print_char
            INC     e
            LD      a,height
            SUB     c
            CP      e
            JR      nz,loop_2
            CALL    rotate
loop_3:
            CALL    print_char
            DEC     d
            LD      a,b
            CP      d
            JR      nz,loop_3
            CALL    rotate
loop_4:
            CALL    print_char
            DEC     e
            LD      a,c
            CP      e
            JR      nz,loop_4
            CALL    rotate
            RET

print_char:
            LD      a,22
            RST     16
            LD      a,e
            RST     16
            LD      a,d
            RST     16
print_another_char:
            LD      a,(end_story)
            CP      1
            JR      nz,no_end_of_story
            LD      a,' '
            JR      do_print_char
no_end_of_story:
            LD      a,(hl)
            CP      '#'
            JR      nz,no_10_digit
            LD      a,(bottles)
            CP      '0'
            JR      nz,do_print_char
            INC     hl
            JR      print_another_char
no_10_digit:
            CP      '@'
            JR      nz,no_1_digit
            LD      a,(bottles+1)
            JR      do_print_char
no_1_digit:
            CP      '&'
            JR      nz,no_number_decrease
            LD      a,(bottles+1)
            DEC     a
            LD      (bottles+1),a
            CP      '0'
            JR      nz,non_zero
            LD      a,(bottles)
            CP      '0'
            JR      nz,move_to_next_char
            LD      hl,no_more_bottles
            JR      print_another_char
non_zero:
            CP      '0'-1
            JR      nz,move_to_next_char
            LD      a,'9'
            LD      (bottles+1),a
            LD      a,(bottles)
            DEC     a
            LD      (bottles),a
move_to_next_char:
            INC     hl
            JR      print_another_char
no_number_decrease:
            CP      '*'
            JR      nz,no_end_story
            LD      a,1
            LD      (end_story),a
            JR      print_another_char
no_end_story:
            CP      '$'
            JR      nz,do_print_char
            LD      a,17
            RST     16
            LD      a,(paper_color)
            INC     a
            CP      8
            JR      nz,no_paper_reset
            LD      a,1
no_paper_reset:
            LD      (paper_color),a
            RST     16
            LD      hl,text
            JR      print_another_char
do_print_char:
            RST     16
            INC     hl
            RET

rotate:
            PUSH    hl
            PUSH    iy
            PUSH    bc
            PUSH    de

            LD      hl,font_mem
            LD      b,chars_num
next_char:
            PUSH    bc
            LD      b,128
            LD      iy,temp_font
next_row:
            LD      c,1
            LD      (iy+0),0
next_bit_row:
            LD      a,b
            AND     (hl)
            JR      z,zero_bit
            LD      a,c
            OR      (iy+0)
            LD      (iy+0),a
zero_bit:
            INC     hl
            RLC     c
            JR      nc,next_bit_row
            INC     iy
            CCF
            LD      de,8
            SBC     hl,de
            RRC     b
            JR      nc,next_row
            LD      de,temp_font
            EX      de,hl
            LD      bc,8
            LDIR
            EX      de,hl
            POP     bc
            DEC     b
            JR      nz,next_char
            POP     de
            POP     bc
            POP     iy
            POP     hl
            RET

copy_fonts:
            LD      hl,15616
            LD      de,font_mem
            LD      bc,chars_num * 8
            LDIR
            LD      hl,font_mem-256
            LD      (23606),hl
            RET

paper_color:
            DB      0
bottles:
            DB      '9','9'
end_story:
            DB      0
text:
            DB      "#@ BOTTLES OF BEER ON THE WALL,"
            DB      "#@ BOTTLES OF BEER."
            DB      "TAKE ONE DOWN,PASS IT AROUND,&"
            DB      "#@ BOTTLES OF BEER ON THE WALL.$"
no_more_bottles:
            DB      "NO MORE BOTTLES OF BEER ON THE WALL.*"
font_mem:
            DS      chars_num*8
temp_font:
            DS      8

