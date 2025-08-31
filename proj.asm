.DATA       

input_buffer DB 80, 0, 81 DUP(?)
prompt_msg DB 'Enter input (max 80 chars): $'
number_pos_msg DB 0DH, 0AH, 'Result: Positive number$'
number_neg_msg DB 0DH, 0AH, 'Result: Negative number$'
number_zero_msg DB 0DH, 0AH, 'Result: ZERO$'
string_part1_msg DB 0DH, 0AH, 'Result: String with $'
string_part2_msg DB ' word(s)$'
empty_msg DB 0DH, 0AH, 'Error: Empty input$'
num_buffer DB 6 DUP('$')
word_count DW 0
is_number DB 1
is_negative DB 0

.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX
    
    LEA DX, prompt_msg
    MOV AH, 09H
    INT 21H
    
    LEA DX, input_buffer
    MOV AH, 0AH
    INT 21H
    
    LEA SI, input_buffer[2]
    MOV CL, input_buffer[1]
    MOV CH, 0
    
    CMP CX, 0
    JE show_empty
    
    MOV BH, 0
    
    MOV AL, [SI]
    CMP AL, '-'
    JNE check_for_plus
    
    MOV is_negative, 1
    INC SI
    DEC CX
    CMP CX, 0
    JE not_a_number
    JMP analysis_loop                                                   

check_for_plus:
    CMP AL, '+'
    JNE analysis_loop
    
    MOV is_negative, 0
    INC SI
    DEC CX
    CMP CX, 0
    JE not_a_number
    
analysis_loop:
    CMP CX, 0
    JE end_analysis

    MOV AL, [SI]

    CMP AL, ' '
    JNE not_a_space
    MOV BH, 0
    JMP check_if_digit
not_a_space:
    CMP BH, 0
    JNE check_if_digit
    MOV BH, 1
    INC word_count

check_if_digit:
    CMP AL, '0'
    JB not_a_number
    CMP AL, '9'
    JA not_a_number
    
continue_loop:
    INC SI
    DEC CX
    JMP analysis_loop

not_a_number:
    MOV is_number, 0
    JMP continue_loop

end_analysis:
    
    CMP is_number, 1
    JE process_as_number
    
    LEA DX, string_part1_msg
    MOV AH, 09H
    INT 21H
    
    CALL display_word_count
    
    LEA DX, string_part2_msg
    MOV AH, 09H
    INT 21H
    JMP exit_program

process_as_number:
    CMP is_negative, 1
    JE show_negative  
    CMP input_buffer[2], 30H
    JE show_zero
    LEA DX, number_pos_msg
    JMP show_result
show_negative:
    LEA DX, number_neg_msg
    JMP show_result
    
show_zero:
    LEA DX, number_zero_msg
    JMP show_result

show_empty:
    LEA DX, empty_msg

show_result:
    MOV AH, 09H
    INT 21H

exit_program:
    MOV AH, 4CH
    INT 21H

MAIN ENDP

display_word_count PROC
    MOV AX, word_count
    LEA DI, num_buffer + 4
    MOV BX, 10
    
    CMP AX, 0
    JNE conversion_loop
    MOV BYTE PTR [DI], '0'
    JMP print_number_buffer
    
conversion_loop:
    MOV DX, 0
    DIV BX
    ADD DL, '0'
    MOV [DI], DL
    DEC DI
    CMP AX, 0
    JNE conversion_loop
    
print_number_buffer:
    INC DI
    LEA DX, DI
    MOV AH, 09H
    INT 21H
    RET
display_word_count ENDP

END MAIN
