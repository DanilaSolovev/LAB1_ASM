STACK_TOP EQU 0x20000100
NULL EQU 0x00
ONE EQU 0x01
    PRESERVE8
    THUMB
    AREA CONSTANT_FLASH, DATA, READONLY
mas         DCB 0x2, 0x6, -0x4, 0x3, -0x8, 0x6, 0x1, -0x9, 0x4, 0x5, 0x3, -0x7
mas_size    DCB mas_size-mas
mas1         DCB 0x2, 0x6, -0x4, 0x3, -0x8, 0x6, 0x1, -0x9, 0x4, 0x5, 0x3, -0x7
mas_size1    DCB mas_size-mas

    AREA VERIABLE_RAM, DATA, READWRITE
MAX_SIZEpar SPACE 1
MAX_SIZEpos SPACE 1
mas_parity SPACE 12
mas_positive SPACE 12
avgres SPACE 1
avgres1 SPACE 1
    AREA RESET, CODE, READONLY
    DCD STACK_TOP
    DCD Start
    ENTRY



;ОСНОВНАЯ ПРОГРАММА
Start PROC
    LDR R0, =mas
    LDR R1, =mas_size
    LDRB R1, [R1, #0]
    BL Allprog
    LDR R1, =avgres
    STRB R0, [R1, #0x00]
    
    LDR R0, =mas1
    LDR R1, =mas_size1
    LDRB R1, [R1, #0]
    BL Allprog
    LDR R1, =avgres1
    STRB R0, [R1, #0x00]
    
    B .
    ENDP


Allprog PROC
    MOV R7, R1
    PUSH {LR}
    SUB SP,R7
    MOV R2,SP ;=mas_parity
    BL parity_prog
    SUB SP, #0x04
    MOV R1, SP ;=MAX_SIZEpar
    STRB R0, [R1, #0]
    
    
    
    MOV R1, SP ;=MAX_SIZEpar
    LDRB R1, [R1, #0]
    ADD SP, #0x04
    MOV R0, SP ;=mas_parity
    SUB SP, #0x04
    SUB SP, R7
    MOV R2, SP ;=mas_positive
    BL positive_prog
    SUB SP, #0x04
    MOV R1, SP ;=MAX_SIZEpos
    STRB R0, [R1, #0x00]


    MOV R1, SP ;=MAX_SIZEpos
    LDRB R1, [R1, #0x00]
    ADD SP, #0x04
    MOV R0, SP ;=mas_positive
    BL avg_prog
    
    ;Возврат
    ADD SP, R7
    LDRB R1, [SP, #0x00]
    ADD SP, #0x04
    ADD SP, R7
    POP {LR}
    BX LR
    ENDP

parity_prog PROC
; Функция (процедура) определяет элементы массива с четным индексом
; Функция принимает указатель на массив через регистр R0,
; размер массива через регистр R1,
; указатель на пустой массив через регистр R2
; R0 = *array
; R1 = size(array)
; R2 = *new_array
    
srav
    CMP R3, R1
    BEQ exit
    MOV R6, #0x02
    UDIV R5, R3, R6
    MUL R5, R5, R6
    CMP R5, R3
    BNE iplus
    LDRB R5, [R0, R3]
    STRB R5, [R2, R4]
    ADD R4, #0x01
iplus    
    ADD R3, #0x01
    B srav
exit
    MOV R3, #0x00
    MOV R0, R4
    MOV R4, #0x00
    BX LR
    ENDP ; Конец программы


positive_prog PROC
; Функция (процедура) определяет положительные элементы массива
; Функция принимает указатель на массив через регистр R0,
; размер массива через регистр R1,
; указатель на пустой массив через регистр R2
; R0 = *array
; R1 = size(array)
; R2 = *new_array
    
    MOV R5, R0
srav1
    CMP R3, R1
    BEQ exit1
    LDRB R0, [R5, R3]
    CMP R0, #0xF0
    BGT iplus1
    STRB R0, [R2, R4]
    ADD R4, #0x01
iplus1    
    ADD R3, #0x01
    B srav1
exit1   
    MOV R3, #0x00
    MOV R0, R4
    MOV R4, #0x00
    BX LR
    ENDP
    
avg_prog PROC
; Функция (процедура) находит среднее значение массива
; Функция принимает указатель на массив через регистр R0
; размер массива через регистр R1.
; Результат работы функции возвращается через регистр R0
; R0 = *array
; R1 = size(array)
; return R0= avg_array
    MOV R5, #0x00
    MOV R2, R0
srav2
    CMP R3, R1
    BEQ exit2
    LDRB R0, [R2, R3]
    ADD R5, R0
    ADD R3, #0x01
    B srav2
exit2
    UDIV R0, R5, R3
    BX LR
    
    
    ENDP
    
    END
