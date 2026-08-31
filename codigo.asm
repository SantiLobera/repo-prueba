; ====================================================================
; CÓDIGO CORREGIDO Y OPTIMIZADO PARA PLACA REAL PIC16F887
; ====================================================================

        LIST p=16F887
        #INCLUDE <P16F887.INC>

        ; Configuración de fusibles
        __CONFIG _CONFIG1, _FOSC_XT & _WDTE_OFF & _PWRTE_ON & _MCLRE_ON
        __CONFIG _CONFIG2, _LVP_OFF     

; --- MAPA DE MEMORIA ---
CONT_BLK1   EQU 0x20    
CONT_BLK2   EQU 0x21
CONT_LOOP   EQU 0x22    
CONTADOR    EQU 0x23    
REG_RET1    EQU 0x24    
REG_RET2    EQU 0x25

        ORG 0x00
        GOTO INICIO

        ORG 0x05 
INICIO   
        ; --- 1. Desactivar Periféricos Analógicos (CRÍTICO EN CHIP REAL) ---
        BSF     STATUS, RP0     ; Banco 3
        BSF     STATUS, RP1
        CLRF    ANSEL           ; Entradas digitales en Puerto A/E
        CLRF    ANSELH          ; Entradas digitales en Puerto B

        ; --- 2. Configuración de Dirección de Puertos ---
        BCF     STATUS, RP1     ; Banco 1 (RP0=1, RP1=0)
        CLRF    TRISD           ; Puerto D como SALIDAS (LEDs)
        MOVLW   B'11000001'     ; RC0 como entrada (Botón), RC6 y RC7 como entradas (UART safe)
        MOVWF   TRISC
        
        ; --- 3. Retorno a Banco 0 e Inicialización ---
        BCF     STATUS, RP0     ; Banco 0 (RP0=0, RP1=0)
        CLRF    PORTD           ; Limpia puerto D
        CLRF    CONTADOR        ; Inicializa el contador binario en 0

        ; ============================================================
        ; ETAPA 1: BLINKING LED INICIAL (5 ciclos)
        ; ============================================================
        MOVLW   .5              
        MOVWF   CONT_LOOP

BLK_LOOP
        BSF     PORTD, RD0      ; Prende RD0
        CALL    RETARDO_BLINK
        BCF     PORTD, RD0      ; Apaga RD0
        CALL    RETARDO_BLINK
        DECFSZ  CONT_LOOP, F    
        GOTO    BLK_LOOP
        
        CLRF    PORTD           

        ; ============================================================
        ; ETAPA MAIN: EVALUACIÓN DEL BOTÓN EN RC0
        ; ============================================================
EVALUAR
        BTFSC   PORTC, RC0      ; ¿El botón está presionado (0V)?
        GOTO    MODO_CONTADOR   ; Si está en 1 (No presionado) -> Va a Contador
        GOTO    MODO_BARRIDO    ; Si está en 0 (Presionado) -> Va a Barrido

        ; ============================================================
        ; ETAPA 2: CONTADOR BINARIO
        ; ============================================================
MODO_CONTADOR
        MOVF    CONTADOR, W     
        MOVWF   PORTD
        CALL    RETARDO_GEN     
        INCF    CONTADOR, F     
        GOTO    EVALUAR         

        ; ============================================================
        ; ETAPA 3: BARRIDO UNIDIRECCIONAL
        ; ============================================================
MODO_BARRIDO
        MOVLW   B'00000001'     
        MOVWF   PORTD
        CALL    RETARDO_GEN
        BTFSC   PORTC, RC0      
        GOTO    EVALUAR

        MOVLW   B'00000010'     
        MOVWF   PORTD
        CALL    RETARDO_GEN
        BTFSC   PORTC, RC0
        GOTO    EVALUAR

        MOVLW   B'00000100'     
        MOVWF   PORTD
        CALL    RETARDO_GEN
        BTFSC   PORTC, RC0
        GOTO    EVALUAR

        MOVLW   B'00001000'     
        MOVWF   PORTD
        CALL    RETARDO_GEN
        BTFSC   PORTC, RC0
        GOTO    EVALUAR

        MOVLW   B'00010000'     
        MOVWF   PORTD
        CALL    RETARDO_GEN
        BTFSC   PORTC, RC0
        GOTO    EVALUAR

        MOVLW   B'00100000'     
        MOVWF   PORTD
        CALL    RETARDO_GEN
        BTFSC   PORTC, RC0
        GOTO    EVALUAR

        MOVLW   B'01000000'     
        MOVWF   PORTD
        CALL    RETARDO_GEN
        BTFSC   PORTC, RC0
        GOTO    EVALUAR

        MOVLW   B'10000000'     
        MOVWF   PORTD
        CALL    RETARDO_GEN
        
        GOTO    EVALUAR         

        ; ============================================================
        ; SUBRUTINAS DE RETARDO
        ; ============================================================

RETARDO_BLINK
        MOVLW   .255
        MOVWF   CONT_BLK1
L_BLK1  MOVLW   .255
        MOVWF   CONT_BLK2
L_BLK2  DECFSZ  CONT_BLK2, F
        GOTO    L_BLK2
        DECFSZ  CONT_BLK1, F
        GOTO    L_BLK1
        RETURN

RETARDO_GEN
        MOVLW   .150            
        MOVWF   REG_RET1
L_GEN1  MOVLW   .255
        MOVWF   REG_RET2
L_GEN2  DECFSZ  REG_RET2, F
        GOTO    L_GEN2
        DECFSZ  REG_RET1, F
        GOTO    L_GEN1
        RETURN

        END