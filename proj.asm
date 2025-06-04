org 100h

.data
    ; Messages
    prompt      db 'Enter input: $'
    msg_num     db 0Dh,0Ah,'Result: NUMBER - $'
    msg_pos     db 'POSITIVE$'
    msg_neg     db 'NEGATIVE$' 
    msg_zero    db 'ZERO$'
    msg_txt     db 0Dh,0Ah,'Result: TEXT - Length: $'
    msg_chars   db ' characters$'
    
    ; Input buffer
    buffer      db 100, 0, 100 dup(0)

.code
main proc
    mov ax, @data
    mov ds, ax
    
    ; Get input
    lea dx, prompt
    mov ah, 09h
    int 21h
    
    lea dx, buffer
    mov ah, 0Ah
    int 21h
    
    ; Analyze input
    call analyze
    
    ; Exit
    mov ah, 4ch
    int 21h
main endp

analyze proc
    mov cl, buffer[1]        ; Length
    lea si, buffer[2]        ; First char
    
    ; Check if number
    call is_number
    cmp al, 1
    je handle_number
    
    ; Handle text
    lea dx, msg_txt
    mov ah, 09h
    int 21h
    
    mov al, cl
    call print_digit
    
    lea dx, msg_chars
    mov ah, 09h
    int 21h
    ret
    
handle_number:
    lea dx, msg_num
    mov ah, 09h
    int 21h
    
    ; Check sign
    mov al, [si]
    cmp al, '-'
    je print_negative
    
    ; Check if zero
    call is_zero
    cmp al, 1
    je print_zero
    
    lea dx, msg_pos
    mov ah, 09h
    int 21h
    ret
    
print_negative:
    lea dx, msg_neg
    mov ah, 09h
    int 21h
    ret
    
print_zero:
    lea dx, msg_zero
    mov ah, 09h
    int 21h
    ret
analyze endp

; Check if input is number
is_number proc
    push si
    push cx
    
    mov al, [si]
    cmp al, '-'
    je skip_minus
    cmp al, '+'
    je skip_plus
    jmp check_digits
    
skip_minus:
skip_plus:
    inc si
    dec cl
    
check_digits:
    cmp cl, 0
    je not_number
    
digit_loop:
    mov al, [si]
    cmp al, '0'
    jb not_number
    cmp al, '9'
    ja not_number
    inc si
    dec cl
    jnz digit_loop
    
    pop cx
    pop si
    mov al, 1                ; Is number
    ret
    
not_number:
    pop cx
    pop si
    mov al, 0                ; Not number
    ret
is_number endp

; Check if number is zero
is_zero proc
    push si
    push cx
    
    ; Skip sign
    mov al, [si]
    cmp al, '-'
    je skip_sign
    cmp al, '+'
    je skip_sign
    jmp check_zero_digits
    
skip_sign:
    inc si
    dec cl
    
check_zero_digits:
zero_loop:
    mov al, [si]
    cmp al, '0'
    jne not_zero
    inc si
    dec cl
    jnz zero_loop
    
    pop cx
    pop si
    mov al, 1                ; Is zero
    ret
    
not_zero:
    pop cx
    pop si
    mov al, 0                ; Not zero
    ret
is_zero endp

; Print single digit (0-255)
print_digit proc
    push ax
    push dx
    
    mov ah, 0
    mov dl, 10
    div dl
    
    cmp al, 0
    je print_ones
    
    add al, '0'
    mov dl, al
    mov ah, 02h
    int 21h
    
print_ones:
    mov al, ah
    add al, '0'
    mov dl, al
    mov ah, 02h
    int 21h
    
    pop dx
    pop ax
    ret
print_digit endp

end main
