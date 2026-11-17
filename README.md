# Trabajo Final

**Electrónica Digital 2** — Facultad de Ciencias Exactas, Físicas y Naturales — Universidad Nacional de Córdoba

## 1. Requisitos

- Comunicación serie entre el microcontrolador y la PC.
- Interfaz de usuario.
- Protocolo de comunicación con el microcontrolador, documentado en este README.
- Un sensor, de los vistos en clase.
- Un actuador, de los vistos en clase.

## 2. Definition of Done (DoD) — Criterios de Aprobación de la Cátedra

Una historia de usuario se considera **"Done" (Finalizada y Aprobada)** cuando el Scrum Master (Ayudante) y el Product Owner (Docente) verifican los siguientes puntos:

1. **Uso de Ensamblador:** El código está escrito 100% en Ensamblador (.asm), compila sin errores ni *warnings* y genera el archivo `.hex`.
2. **Indicador de Turnos, Error, Ganador y Palo:** El sistema debe indicar al usuario mediante su interfaz su turno, quien fue el ganador, el palo de las cartas y si se genero algun error.
3. **Generacion Aleatoria:** Las cartas deben ser distribuidas y generadas de forma 100% ALEATORIA, garantizando la imparcialidad del dealer y llevando a un juego justo.
4. **Igualdad de Apuestas:** Los montos de las apuestas deben ser iguales, no se debe avanzar a la siguiente ronda con montos diferentes.
5. **Tiempo entre Turnos Aceptable:** El tiempo de juego y reparto debe ser aceptable, maneteniendo la comunicacion serie lo mas optimmizada posible, para jugar el turno nose debe esperar mas de 7 segundos.
6. **Presentacion del Hardware y funcionamiento correcto:** El prototipo montado no debe presentar obstrucciones visuales a los indicadores, debe presentar una disposicion ordenada y cables sin enriedos, no se aceptarra un hardware que deba utilizar "manias" para que funcione.

> El alcance y los detalles de cada trabajo se acuerdan con el docente de cada comisión.

## Trabajo Final Digital 2

### 1. Introducción y Objetivo del Proyecto

La mesa de poker es un sistema de seudo automatizacion de una partida tradicional de un juego de póker a travez de multi-nodo para el control de turnos, reparto de cartas y cartas mostradas en mesa de cada partida.
El objetivo del proyecto es poder interconectar los 3 nodos actuales del proyecto para poder tener una partida completa de poker con un registro virtual de todo lo que se hizo en al partida

### 2. Marco Conceptual y Principios de Funcionamiento

#### 2.1. Principio Básico

El sistema se divide en tres nodos físicos independientes basados en PIC16F887 (Dealer, Jugador 1 y Jugador 2) interconectados a una computadora central mediante conversores USB-UART (9600 bps, 8N1). La comunicación opera bajo un protocolo binario sincronizado de 2 bytes

* Byte 1 (Cabecera de Control): Contiene el bit de sincronismo (0x80), los 2 bits de turno/destino (turno_sig: 00 Dealer, 01 Jugador 1, 10 Jugador 2), los 2 bits de estado/acción (Pasar, Apostar, Bajarse, Igualar), el bit de condición (0 acción/apuesta, 1 carta) y el bit de reinicio global (0x82).

* Byte 2 (Carga Útil): Transporta el monto de la apuesta (0–127) cuando es una trama de acción, o la codificación del Palo (0–3) y el Valor de la carta (0–12: As, 2–10, J, Q, K) cuando es una carta.

Y donde toda la interfaz y gestion de la comunicacion serial queda implementada por un script de python integrado con tkinter y pyserial

Al iniciarse la partida por el boton comenzar de la interfaz, se mandar las cartas de partida a los jugadores y tambien al dealer para que pueda verificar que no se repitan las cartas. Al tener cada nodo su informacion, el dealer procede a "dar vuelta" las 3 primeras cartas de la mesa, y en cada finalizacion de partida da vuelta una nueva hasta la 5ta (Todo esto a travez del boton del dealer para tener la mayor aleatoriedad posible). Y cada ronda termina al momento de tener los valores de las apuesta de los jugadores igualadas

#### 2.2. Arquitectura de Control

El flujo de operación se resume en tres etapas:

* Inicio y Reparto Privado: Al comenzar la partida desde la interfaz en Python, se sortean y envían vía UART (9600 bps) dos cartas únicas a cada nodo jugador, quienes las almacenan en RAM y las muestran localmente en sus displays de 7 segmentos y LEDs RGB.

* Cartas Comunitarias (Nodo Dealer): Mediante interrupciones de TMR0 (multiplexado y contadores pseudoaleatorios) y un pulsador en RB0 con control anti-repetición, el Dealer genera y visualiza las 5 cartas de la mesa (3 en el Flop, 1 en el Turn y 1 en el River) en sus displays y LEDs RGB. Cada carta se envía a la PC para registrarse en pantalla, sin reenviarse a los jugadores ni de vuelta al Dealer.

* Apuestas, Turnos y Reinicio: Los jugadores envían sus decisiones (Pasar, Apostar, Bajarse o Igualar) mediante tramas de 2 bytes hacia Python. La PC actualiza el pozo, lee los bits de turno para redirigir la trama al siguiente jugador y, al cerrar la ronda, notifica al Dealer para poner la apuesta en cero y habilitar la siguiente carta. El botón de reinicio envía una trama global ([0x82, 0x00]) que limpia los tres nodos para una nueva mano.

### 3. Componentes de Hardware y Software

* Microcontroladores: 3 PIC16F887 (1 para el nodo Dealer y 2 para los nodos Jugadores).

* Visualización: 13 displays de 7 segmentos de ánodo común (5 en el Dealer para las cartas comunitarias y 4 en cada Jugador para sus cartas privadas y la apuesta).

* Señalización: 9 LEDs RGB de ánodo común (5 en el Dealer y 2 en cada Jugador) para identificar los palos, y 3 LEDs indicadores de turno (1 por nodo).

* Etapa de Potencia:13 transistores PNP para el multiplexado de dígitos (5 en el Dealer y 4 en cada Jugador).

* Reloj y Desacoplo: 3 cristales de cuarzo de 4 MHz y 6 capacitores cerámicos de 22 pF (2 por microcontrolador).

* Entradas y Resistencias: Pulsadores para reset (MCLR), sorteo y acciones de apuesta, junto con resistencias de 10 kΩ, 1 kΩ y 220 Ω (limitadoras de segmentos y LEDs).

* Actuador: Un led en el dealer que indique cuando esta activado (Manejando una oscilacion con un mosfet)

* Sensor: 1 potenciometro por cada jugador para el manejo de la apuesta 

* Comunicación: 3 módulos conversores USB-UART TTL para la conexión serial con la PC.

* Montaje: 3 protoboards, cables de interconexión y fuente de alimentación de 5 V.

* Software y Lenguajes: MPLAB X IDE (programación en Assembler), Proteus 8 (simulación circuital) y Python 3 con las librerías Tkinter y PySerial (interfaz gráfica y enrutador serial).

<details>
<summary>Dealer</summary>

asdasd

<details>
<summary>diagrama de flujo del Dealer</summary>
asdasd
</details>

<details>
<summary>codigo del dealer</summary>
asdasd
</details>

</details>


<details>
<summary>Jugadores</summary>

asdasd

<details>
<summary>diagrama de flujo de los jugadores</summary>
asdasd
</details>

<details>
<summary>codigo del jugador 1</summary>

```assembly


LIST P=16F887
    #include <p16f887.inc>

; --- Bits de configuraci�n ---
    __CONFIG _CONFIG1, _FOSC_XT & _WDTE_OFF & _PWRTE_OFF & _MCLRE_ON & _CP_OFF & _CPD_OFF & _BOREN_ON & _IESO_ON & _FCMEN_ON & _LVP_OFF
    __CONFIG _CONFIG2, _BOR4V_BOR40V & _WRT_OFF

;-----------------------------------------------------------------------------------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------------------------------------------------------------------------------                         ; 1 = J1, 2 = J2
    ID_JUGADOR  EQU  1 ; en jugador 2 cambiamos ID_JUGADOR EQU .2
    ID_TURNO    EQU  0xA0
    
CBLOCK	0x20
    APUESTA_INF	    ;CORRESPONDE AL DISP 4 RC3
    APUESTA_SUP    ;CORRESPONDEL AL DISP 3 RC2
    CARTA1	    ;CORRESPONDE AL DISP 1 RC0
    CARTA2	    ;CORRESPONDE AL DISP 2 RC1
    CONT_MULT
    APUESTA_J1
    APUESTA_J2
    TURNO
    TICK 
    CONT_REB	;incrementa solo si la comparaci�n es igual
    BTN_ACT	;lectura actual 
    BTN_ULT	;lectura anterior
    BYTE_DATO	
    BYTE_APUESTA 
    RX_ESTADO
    RX_BYTE1
    RX_BYTE2
    ADC_ALTO
    ADC_BAJO
    APUESTA_TEMP
    DECENA_APUESTA
    UNIDAD_APUESTA
    CONT_RECEPCION
    RX_LISTO
    INDICE_PALO 
    COLOR_C1
    COLOR_C2
    INDICE_CARTA
    BYTE_AUX
    POTENCIOMETRO
    APUESTA_ESTADO
ENDC
   
CBLOCK 0x70 
    W_TEMP 
    STATUS_TEMP
ENDC 

ORG 0X00
    GOTO INICIO 

ORG 0X04 
    GOTO ISR 

;-------------------------------------------------------------------------------
;				    TABLAS
;---------------------------------------------------------------------------
    
TABLA_CARTAS 
    ADDWF PCL, F
    RETLW b'10001000' ;A
    RETLW b'10100100' ;2
    RETLW b'10110000' ;3
    RETLW b'10011001' ;4
    RETLW b'10010010' ;5
    RETLW b'10000010' ;6
    RETLW b'11111000' ;7
    RETLW b'10000000' ;8
    RETLW b'10010000' ;9
    RETLW b'11111001' ;1 (10)
    RETLW b'11100001' ;J
    RETLW b'01000000' ;Q
    RETLW b'10001001' ;K
 
TABLA_PALOS
    ADDWF PCL, F
    RETLW b'11111110' ;ROJO
    RETLW b'11111101' ;VERDE
    RETLW b'11111011' ;AZUL
    RETLW b'11111100' ;AMARILLO

SELECCION_D7S 
    ADDWF PCL,F
    RETLW b'11111110' ; Display 0: 
    RETLW b'11111101' ; Display 1: 
    RETLW b'11111011' ; Display 2: 
    RETLW b'11110111' ; Display 3: 

TABLA_APUESTA 
    ADDWF PCL, F
    RETLW b'11000000' ;0
    RETLW b'11111001' ;1 
    RETLW b'10100100' ;2
    RETLW b'10110000' ;3
    RETLW b'10011001' ;4
    RETLW b'10010010' ;5
    RETLW b'10000010' ;6
    RETLW b'11111000' ;7
    RETLW b'10000000' ;8
    RETLW b'10010000' ;9  

    
    
INICIO
;===============================================================================
;   RB0-RB2 ENTRADAS BOTONES	RA2 = LED TURNO  RB4-RB6 = LED CARTAS 
;===============================================================================
; INICIALIZACI�N 
    ;deshabilitar entradas anal�gicas 
    
    BANKSEL ANSEL
    MOVLW b'00000001'
    MOVWF ANSEL 
    
    BANKSEL ANSELH
    CLRF ANSELH
;-------------------------------------------------------------------------------
;	alta velocidad a 9600	sin bit de paridad  asincronica	 
;-------------------------------------------------------------------------------
    BANKSEL ADCON0
    MOVLW b'01000001'	    ;AN0 COMO ENTRADA 
    MOVWF ADCON0	     
    
    BANKSEL ADCON1	    
    MOVLW b'10000000'	    ;justificado a la derecha, voltaje de referencai
    MOVWF ADCON1	    ; Vss y Vdd
    
    
    
    BANKSEL PIE1	    
    MOVLW b'00100000'
    MOVWF PIE1 
    
    MOVLW b'00100110'	
    MOVWF TXSTA		 
    
    BANKSEL RCSTA	    ;habilita modulo UART
    MOVLW b'10010000'
    MOVWF RCSTA 
    
    BANKSEL BAUDCTL
    MOVLW b'00001000'		
    MOVWF BAUDCTL
    
    BANKSEL SPBRG	    ; transmisios a 9600 baudios 
    MOVLW .103
    MOVWF SPBRG
    
    BANKSEL SPBRGH 
    CLRF SPBRGH  
     
;configuracion puertos
    BANKSEL TRISD
    CLRF    TRISD           ; PORTD todo salida (segmentos)
     BANKSEL TRISC
    MOVLW b'10000000'	    ;RC0-RC3 salidas (selecci�n), 
    MOVWF TRISC		    ;RC7 entrada RX
			    ;RC6 salida TX
			    
    MOVLW b'00000001'	    ; RA0 ENTRADA ANAL�GICA 
    MOVWF TRISA		    ;RA2 LED TURNO
    
    MOVLW 0x00
    MOVWF TRISE		    ;RE0-RE2 como salida para los leds 
    
    MOVLW B'00000111'	    ;PRB0-RB2 COMO ENTRADAS, EL RESTO COMO SALIDA
    MOVWF TRISB
    
    BCF OPTION_REG,7	    ;HABILITACI�N PULL_UPS 
    BANKSEL WPUB
    MOVLW b'00000111'
    MOVWF WPUB		    ;RB0-RB5 PULL UPS (SIEMPRE TIENE UN 1)

;inicializaci�n variables
;--------------------------------------------------------------
    BANKSEL PORTC
    MOVLW 0xFF 
    MOVWF PORTC		    ;Displays pagados 
    MOVWF PORTD		    ;Segmentos deshabilitados
    MOVWF PORTE
    MOVWF COLOR_C1
    MOVWF COLOR_C2
    MOVWF CARTA1
    MOVWF CARTA2
    BCF PORTA,2
    CLRF CONT_MULT
    MOVLW b'01110000'
    MOVWF PORTB 
    CLRF APUESTA_J1
    CLRF APUESTA_J2
    CLRF APUESTA_SUP
    CLRF APUESTA_INF
    CLRF TURNO
    CLRF TICK 
    CLRF CONT_REB
    CLRF BYTE_APUESTA 
    CLRF BYTE_DATO 
    MOVLW b'00000111'
    MOVWF BTN_ULT	;Iinician todos los botones en 1, tienen las pul-ups 
    CLRF RX_ESTADO 
    CLRF RX_BYTE1
    CLRF RX_BYTE2
    CLRF ADC_ALTO
    CLRF ADC_BAJO 
    CLRF APUESTA_TEMP
    CLRF DECENA_APUESTA
    CLRF UNIDAD_APUESTA
    CLRF CONT_RECEPCION 
    CLRF RX_LISTO
    CLRF INDICE_PALO
    CLRF INDICE_CARTA
    CLRF BYTE_AUX 
    CLRF POTENCIOMETRO 
    CLRF APUESTA_ESTADO
;===============================================================================   
;	    TIMER0		PRESCALER 1:16 TMER0 = 100
;	    FOSC = 4MHz --> CICLO DE INTERRUPCI�N = 1us
;	    156 INCREMENTOS * 16 = 2.5 ms 
;===============================================================================
    
  BANKSEL OPTION_REG 
  MOVLW b'00000011'
  MOVWF OPTION_REG	    ;PRESCALER 1:16	    PRESCALER ASIGNADO A TIMER0
 
  BANKSEL TMR0 
  MOVLW .100
  MOVWF TMR0
  
; Limpiamos las banderas 
  BANKSEL PORTB
  BCF INTCON, T0IF
  

; Habilitaci�n interrupciones TMR0 
  BSF INTCON, T0IE 
  BSF INTCON,PEIE
  BSF INTCON,GIE 
  
;===============================================================================
;				lazo principal
;===============================================================================
  
; transmi en serie  
LOOP 
  BTFSC RX_LISTO,0	;Llego una trama completa ? 
  GOTO SERVICIO_RX
  
  BTFSS TURNO,0 
  GOTO LOOP
  
  BTFSS APUESTA_ESTADO,0
  GOTO REVISAR_BOTONES
  CALL INICIA_CONVERSION

REVISAR_BOTONES 
 
  BTFSS TICK,0		;Solo muestreo cada 2.5 ms 
  GOTO LOOP
  BCF TICK,0
  MOVF PORTB,W
  ANDLW b'00000111'	;RB0-RB2 (activos en bajo) si se pone en cero,se apreto
  MOVWF BTN_ACT		    ;valor actual para comparar desp
  XORLW b'00000111'
  BTFSC STATUS,Z	   ;Z=1, ninguno apretado 
  GOTO REB_SUELTO
  MOVF BTN_ACT,W
  XORWF BTN_ULT,W
  BTFSS STATUS,Z	    ;Z=0 cambio el bton respecto al anterior 
  GOTO REB_CAMBIO
  
  INCF CONT_REB,F	    ;la lectura es la misma, suma 1
  MOVLW .8
  XORWF CONT_REB,W 
  BTFSS STATUS,Z	    ;Z = 0 no pasaron 20ms 
  GOTO LOOP
; se confirm� la pulsaci�n, pasa a verificar los botones
 	    
  BTFSS PORTB,0		    ;boton apretado vale 0 
  GOTO  APUESTA 
  BTFSS PORTB,1
  GOTO IGUALAR 
  BTFSS PORTB,2 
  GOTO RETIRA 
  GOTO LOOP
 
REB_SUELTO 
  
  CLRF CONT_REB		    ;fue rebote, se reinicia
  MOVLW b'00000111'
  MOVWF BTN_ULT		    ;Vuelven a estar todos sin apretar
  GOTO LOOP 

REB_CAMBIO 
  MOVF BTN_ACT,W 
  MOVWF BTN_ULT	    ;guarda la �ltima lectura como referencia para la proxima
  CLRF CONT_REB	    ;vuelve a inicar el contador
  GOTO LOOP
  
;                            Servicio RX
 ;============================================================================== 
 SERVICIO_RX 
  BTFSC RX_BYTE1,2	;Es una carta ? Co = 1
  GOTO PROCESAR_RX
  GOTO PROCESAR_APUESTA  

PROCESAR_RX	;Procesa datos carta 
  
    MOVF CONT_RECEPCION, W
    XORLW .2
    BTFSC STATUS,Z		;si contador es 2 => z = 1  
    GOTO FIN_PROCESAMIENTO	;Puede prcesar las cartas

    CALL PROCESAR_PALO
    CALL PROCESAR_NUMERO

    INCF CONT_RECEPCION, F
    
    GOTO FIN_PROCESAMIENTO  
;Subrutina para decodificar la apuesta -------------------------------------   
PROCESAR_APUESTA 
    MOVF RX_BYTE2,W	    ;Limpiamos el byte2 
    ANDLW b'01111111'
    MOVWF APUESTA_J2
    BTFSC STATUS,Z 
    CALL REINICIA_APUESTA
    
    MOVF RX_BYTE1,W 
    ANDLW b'01100000'
    XORLW (ID_JUGADOR << 5 )	; J1 = 0x20, J2 = 0x40
    BTFSS STATUS,Z
    GOTO FIN_PROCESAMIENTO 
    BSF TURNO,0	    ;habilita el poling de los botones
    BSF PORTA,2    ; Enciende LED de turno
    GOTO FIN_PROCESAMIENTO 

 REINICIA_APUESTA 
    MOVF APUESTA_J2,W
    MOVWF APUESTA_J1
    MOVWF POTENCIOMETRO 
    CALL LOOP_APUESTA
    RETURN
;--Subrutina para decodificar el palo -----------------
PROCESAR_PALO
    MOVF RX_BYTE2,W
    ANDLW b'01100000'	    ;Conservar bits 6 y 5

    MOVWF BYTE_AUX
    BCF STATUS,C  ;Se desplazan los bits 6 y 5, cinco posiciones a la derecha
    RRF BYTE_AUX,F   

    BCF STATUS,C
    RRF BYTE_AUX,F

    BCF STATUS,C
    RRF BYTE_AUX,F

    BCF STATUS,C
    RRF BYTE_AUX,F

    BCF STATUS,C
    RRF BYTE_AUX,F

    MOVF BYTE_AUX,W  
    MOVWF INDICE_PALO
    
    MOVF INDICE_PALO, W
    CALL TABLA_PALOS

    MOVWF BYTE_AUX
    
    MOVF CONT_RECEPCION,W	;incrementa una vez que termina de procesar todo
    XORLW .1
    BTFSC STATUS, Z		
    GOTO GUARDAR_COLOR2
    
GUARDAR_COLOR1 		
    MOVF BYTE_AUX,W
    MOVWF COLOR_C1
    RETURN

GUARDAR_COLOR2
    MOVF BYTE_AUX,W
    MOVWF COLOR_C2
    RETURN
    
;--Subrutina para decodificar el numero de la carta-----------------------------
PROCESAR_NUMERO 
    MOVF RX_BYTE2,W
    ANDLW b'00011110'		;limpia el byte para guardarlo en byte_aux 
    
    MOVWF BYTE_AUX

    BCF STATUS,C   ;Se desplaza una posicion a la derecha
    RRF BYTE_AUX,F

    MOVF BYTE_AUX,W
    MOVWF INDICE_CARTA
    
    MOVF INDICE_CARTA, W
    CALL TABLA_CARTAS

    MOVWF BYTE_AUX 
    MOVF CONT_RECEPCION, W
    XORLW .1
    BTFSC STATUS, Z
    GOTO GUARDAR_CARTA2

GUARDAR_CARTA1
    MOVF BYTE_AUX,W
    MOVWF CARTA1
    RETURN

GUARDAR_CARTA2
    MOVF BYTE_AUX,W
    MOVWF CARTA2
    RETURN
    
FIN_PROCESAMIENTO   
  BCF RX_LISTO,0
  GOTO LOOP
  
;				ISR
;===============================================================================
ISR 
  ; Guardado contexto 
  MOVWF W_TEMP
  SWAPF STATUS,W 
  MOVWF STATUS_TEMP
  
  BANKSEL RCSTA
  BTFSC RCSTA,OERR
  CALL RECUPERAR_OERR
  
  BANKSEL PIR1
  BTFSC PIR1,RCIF
  CALL RUTINA_UART
  
REVISAR_TMR0
  BTFSS INTCON,T0IF	;Verifica si la interrupcion fue por TMR0  
  GOTO FIN_ISR

;------------ RUTINA TMER0-----------------
RUTINA_TMR0 
  
  BCF INTCON, T0IF 
  MOVLW .100
  MOVWF TMR0
  BSF TICK,0
  
;Apagamos para evitar sombras
  MOVLW 0xFF	     
  MOVWF PORTC
  MOVLW b'00000111'
  MOVWF PORTE

;Envio valors al display segun cont_mult 
  MOVF CONT_MULT,W
  BTFSC STATUS,Z 
  GOTO DISP4	    ;CONT_MUX = 0 => RC0(APUESTA_INF)
  XORLW .1
  BTFSC STATUS,Z 
  GOTO DISP3	    ;CONT_MUX = 1 => RC1 (APUESTA_SUP)
  MOVF CONT_MULT,W
  XORLW .2	    
  BTFSC STATUS,Z    ;CON_MUX = 2 => RC2 (CARTA 2 + RGD CARTA2 )
  GOTO DISP2
DISP1		    ;CON_MUX = 3 => RC3 (CARTA 1 + RGB CARTA1)
    MOVF COLOR_C1,W
    MOVWF PORTE
    MOVF CARTA1,W
    GOTO CARGAR  
DISP2
    MOVF COLOR_C2,W
    MOVWF PORTE
    MOVF CARTA2,W
    GOTO CARGAR
DISP4 
    MOVF APUESTA_INF,W
    GOTO CARGAR   
DISP3 
    MOVF APUESTA_SUP,W 

CARGAR 
    MOVWF PORTD		    ;Carga a portD el valro que toca
    MOVF CONT_MULT,W
    CALL SELECCION_D7S	    ;Enciende el display correspondiente 
    MOVWF PORTC 
  
    INCF CONT_MULT,F
    MOVF CONT_MULT,W
    XORLW .4 
    BTFSC STATUS,Z 
    CLRF CONT_MULT	    ;Reinicia la cuenta del multiplexado.
    GOTO FIN_ISR 
 

;-------- RUTINA UART--------------------------------    
RUTINA_UART 
    BTFSC RX_ESTADO,0
    GOTO SEGUNDO_BYTE
    
PRIMER_BYTE 
  BANKSEL RCREG
  MOVF RCREG,W	    ;Leer primer byte
  MOVWF RX_BYTE1
  BSF RX_ESTADO,0
  RETURN
  
SEGUNDO_BYTE 
  BANKSEL RCREG
  MOVF RCREG, w ; Leer segundo byte
  MOVWF RX_BYTE2
  BSF RX_LISTO, 0
  BCF RX_ESTADO, 0
  RETURN 
 
FIN_ISR 
  ;RECUPERAMOS CONTEXTO 
  SWAPF STATUS_TEMP,W 
  MOVWF STATUS 
  SWAPF W_TEMP,F 
  SWAPF W_TEMP,W 
  RETFIE 

RECUPERAR_OERR
    BANKSEL RCSTA

    BCF RCSTA,CREN       ; Deshabilita recepci�n continua
    BSF RCSTA,CREN       ; Vuelve a habilitar recepci�n

    CLRF RX_ESTADO       ; Descarta una trama incompleta

    RETURN
;===============================================================================
;			    RUTINAS BOTONES 
;===============================================================================
APUESTA 

    BTFSC APUESTA_ESTADO,0 ; Es la primera pulsaci�n del boton apuesta?
    GOTO CONFIRMAR_APUESTA ; Segunda pulsaci�n

    BSF APUESTA_ESTADO,0 ; Primera pulsaci�n

    GOTO LOOP


CONFIRMAR_APUESTA
  
;Verificamos que el valor de la apuesta sea mayor a la apuesta del otro jugador
  MOVF APUESTA_J2,W
  SUBWF POTENCIOMETRO,W 
  BTFSC STATUS,Z	    ;iugal: no vale
  GOTO LOOP
  BTFSS STATUS,C	    ;menor:no vale
  GOTO LOOP 
  MOVF POTENCIOMETRO,W
  MOVWF APUESTA_J1
  MOVLW 0x08		    ;guardamos el estado de la acci�n  
  MOVWF BYTE_DATO 
  GOTO FIN_TURNO

INICIA_CONVERSION 
    BANKSEL ADCON0
    BSF ADCON0, 1 	;Inicia la conversi�n 
    
ESPERAR_ADC
    BTFSC ADCON0,1	;Sigue conviertiendo?
    GOTO ESPERAR_ADC  
    
    BANKSEL ADRESL 
    MOVF ADRESL,W
    BANKSEL ADC_BAJO	;Guarda los 8 bits bajos de la conversi�n 
    MOVWF ADC_BAJO
    
    BANKSEL ADRESH
    MOVF ADRESH, w
    ANDLW b'00000011'
    BANKSEL ADC_BAJO	;Guarda los 2 bits altos de la conversi�n
    MOVWF ADC_ALTO    
    
    CLRF POTENCIOMETRO 		

ESCALAR_ADC
    MOVF ADC_ALTO,F
    BTFSS STATUS,Z	    ;ADC_ALTO = 0 ?
    GOTO RESTAR_10 
    
    MOVLW .10		    ;adc_alto = 0, revisar adc_bajo
    SUBWF ADC_BAJO,W
    BTFSS STATUS, C	    ;adc_bajo < 10 ? Si C = 0
    GOTO FIN_ESCALADO

    MOVLW .10		    ;adc_bajo >= 10, se resta le 10
    SUBWF ADC_BAJO,F
    GOTO INCREMENTAR_APUESTA

RESTAR_10 
    MOVLW .10
    SUBWF ADC_BAJO,F

    BTFSS STATUS,C	;Ve si hay carry, "pide prestado"
    DECF ADC_ALTO,F

INCREMENTAR_APUESTA

    INCF POTENCIOMETRO,F	;Incrementamos en 1 las veces que se resta 10
    GOTO ESCALAR_ADC

FIN_ESCALADO		;Limitar la apuesta a 99

    MOVLW .100
    SUBWF POTENCIOMETRO,W

    BTFSS STATUS, C	;Si apuesta >= 100 se muestra 99 
    GOTO LOOP_APUESTA 

    MOVLW .99
    MOVWF POTENCIOMETRO
    
LOOP_APUESTA  
    MOVF POTENCIOMETRO,W
    MOVWF APUESTA_TEMP

    CLRF DECENA_APUESTA

LOOP_DECENAS
    MOVLW .10 
    SUBWF APUESTA_TEMP,W

    BTFSS STATUS, C		;apuesta_temp < 10? Si C=0
    GOTO FIN_DECENAS

    MOVLW .10 
    SUBWF APUESTA_TEMP,F 	;apuesta_temp - 10

    INCF DECENA_APUESTA,F
    GOTO LOOP_DECENAS

FIN_DECENAS

    MOVF APUESTA_TEMP ,w 
    MOVWF UNIDAD_APUESTA

MOSTRAR_APUESTA
    MOVF DECENA_APUESTA,W
    CALL TABLA_APUESTA
    movwf APUESTA_SUP
    
    MOVF UNIDAD_APUESTA,W
    CALL TABLA_APUESTA
    MOVWF APUESTA_INF
    RETURN
;---------------------------------------------------------------------------
RETIRA  
  MOVLW 0xFF		    ;Apagamos displys cartas
  MOVWF CARTA1
  MOVWF CARTA2
  MOVWF COLOR_C1
  MOVWF COLOR_C2
  MOVWF PORTE	    ;
  MOVLW 0x10		    ;Guardamos el estado de la acci�n 		    
  MOVWF BYTE_DATO
  CLRF APUESTA_J1
  CLRF CONT_RECEPCION
  GOTO FIN_TURNO
;---------------------------------------------------------------------------
IGUALAR 
  MOVF APUESTA_J2 ,W
  MOVWF APUESTA_J1
  MOVWF POTENCIOMETRO 
  CALL LOOP_APUESTA
  MOVLW 0x18		    ;Guardamos el estado de la acci�n  
  MOVWF BYTE_DATO 
  GOTO FIN_TURNO 


FIN_TURNO
  BCF TURNO,0
  BCF APUESTA_ESTADO,0
  CLRF CONT_REB
  
;Terminamos de acomodar byte 1 
  MOVLW ID_TURNO	    ;1 01 00000
  IORWF BYTE_DATO,F
  
;acomodamos byte 2 
  MOVF APUESTA_J1,W
  IORWF BYTE_APUESTA,F 
  
;Envio  
  BANKSEL PIR1
ESPERA1		    ;Verificamos si la UART est� lista para enviar el segundo byte
  BTFSS PIR1,TXIF	
  GOTO ESPERA1
  MOVF BYTE_DATO,W
  MOVWF TXREG
ESPERA2   
  BTFSS PIR1,TXIF 	
  GOTO ESPERA2
  MOVF BYTE_APUESTA,W 
  MOVWF TXREG 

  BCF PORTA,2    ; Apaga LED de turno 
  CLRF BYTE_APUESTA	;Limpiamos el byte de la apuesta
  GOTO LOOP
 
END

```

</details>

<details>
<summary>codigo del jugador 2</summary>
```assembly

LIST P=16F887
    #include <p16f887.inc>

; --- Bits de configuraci�n ---
    __CONFIG _CONFIG1, _FOSC_XT & _WDTE_OFF & _PWRTE_OFF & _MCLRE_ON & _CP_OFF & _CPD_OFF & _BOREN_ON & _IESO_ON & _FCMEN_ON & _LVP_OFF
    __CONFIG _CONFIG2, _BOR4V_BOR40V & _WRT_OFF

;-----------------------------------------------------------------------------------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------------------------------------------------------------------------------                         ; 1 = J1, 2 = J2
    ID_JUGADOR  EQU  2 ; en jugador 2 cambiamos ID_JUGADOR EQU .2
    ID_TURNO    EQU  0xC0
    
CBLOCK	0x20
    APUESTA_INF	    ;CORRESPONDE AL DISP 4 RC3
    APUESTA_SUP    ;CORRESPONDEL AL DISP 3 RC2
    CARTA1	    ;CORRESPONDE AL DISP 1 RC0
    CARTA2	    ;CORRESPONDE AL DISP 2 RC1
    CONT_MULT
    APUESTA_J1
    APUESTA_J2
    TURNO
    TICK 
    CONT_REB	;incrementa solo si la comparaci�n es igual
    BTN_ACT	;lectura actual 
    BTN_ULT	;lectura anterior
    BYTE_DATO	
    BYTE_APUESTA 
    RX_ESTADO
    RX_BYTE1
    RX_BYTE2
    ADC_ALTO
    ADC_BAJO
    APUESTA_TEMP
    DECENA_APUESTA
    UNIDAD_APUESTA
    CONT_RECEPCION
    RX_LISTO
    INDICE_PALO 
    COLOR_C1
    COLOR_C2
    INDICE_CARTA
    BYTE_AUX
    POTENCIOMETRO
    APUESTA_ESTADO
ENDC
   
CBLOCK 0x70 
    W_TEMP 
    STATUS_TEMP
ENDC 

ORG 0X00
    GOTO INICIO 

ORG 0X04 
    GOTO ISR 

;-------------------------------------------------------------------------------
;				    TABLAS
;---------------------------------------------------------------------------
    
TABLA_CARTAS 
    ADDWF PCL, F
    RETLW b'10001000' ;A
    RETLW b'10100100' ;2
    RETLW b'10110000' ;3
    RETLW b'10011001' ;4
    RETLW b'10010010' ;5
    RETLW b'10000010' ;6
    RETLW b'11111000' ;7
    RETLW b'10000000' ;8
    RETLW b'10010000' ;9
    RETLW b'11111001' ;1 (10)
    RETLW b'11100001' ;J
    RETLW b'01000000' ;Q
    RETLW b'10001001' ;K
 
TABLA_PALOS
    ADDWF PCL, F
    RETLW b'11111110' ;ROJO
    RETLW b'11111101' ;VERDE
    RETLW b'11111011' ;AZUL
    RETLW b'11111100' ;AMARILLO

SELECCION_D7S 
    ADDWF PCL,F
    RETLW b'11111110' ; Display 0: 
    RETLW b'11111101' ; Display 1: 
    RETLW b'11111011' ; Display 2: 
    RETLW b'11110111' ; Display 3: 

TABLA_APUESTA 
    ADDWF PCL, F
    RETLW b'11000000' ;0
    RETLW b'11111001' ;1 
    RETLW b'10100100' ;2
    RETLW b'10110000' ;3
    RETLW b'10011001' ;4
    RETLW b'10010010' ;5
    RETLW b'10000010' ;6
    RETLW b'11111000' ;7
    RETLW b'10000000' ;8
    RETLW b'10010000' ;9  

    
    
INICIO
;===============================================================================
;   RB0-RB2 ENTRADAS BOTONES	RA2 = LED TURNO  RB4-RB6 = LED CARTAS 
;===============================================================================
; INICIALIZACI�N 
    ;deshabilitar entradas anal�gicas 
    
    BANKSEL ANSEL
    MOVLW b'00000001'
    MOVWF ANSEL 
    
    BANKSEL ANSELH
    CLRF ANSELH
;-------------------------------------------------------------------------------
;	alta velocidad a 9600	sin bit de paridad  asincronica	 
;-------------------------------------------------------------------------------
    BANKSEL ADCON0
    MOVLW b'01000001'	    ;AN0 COMO ENTRADA 
    MOVWF ADCON0	     
    
    BANKSEL ADCON1	    
    MOVLW b'10000000'	    ;justificado a la derecha, voltaje de referencai
    MOVWF ADCON1	    ; Vss y Vdd
    
    
    
    BANKSEL PIE1	    
    MOVLW b'00100000'
    MOVWF PIE1 
    
    MOVLW b'00100110'	
    MOVWF TXSTA		 
    
    BANKSEL RCSTA	    ;habilita modulo UART
    MOVLW b'10010000'
    MOVWF RCSTA 
    
    BANKSEL BAUDCTL
    MOVLW b'00001000'		
    MOVWF BAUDCTL
    
    BANKSEL SPBRG	    ; transmisios a 9600 baudios 
    MOVLW .103
    MOVWF SPBRG
    
    BANKSEL SPBRGH 
    CLRF SPBRGH  
     
;configuracion puertos
    BANKSEL TRISD
    CLRF    TRISD           ; PORTD todo salida (segmentos)
     BANKSEL TRISC
    MOVLW b'10000000'	    ;RC0-RC3 salidas (selecci�n), 
    MOVWF TRISC		    ;RC7 entrada RX
			    ;RC6 salida TX
			    
    MOVLW b'00000001'	    ; RA0 ENTRADA ANAL�GICA 
    MOVWF TRISA		    ;RA2 LED TURNO
    
    MOVLW 0x00
    MOVWF TRISE		    ;RE0-RE2 como salida para los leds 
    
    MOVLW B'00000111'	    ;PRB0-RB2 COMO ENTRADAS, EL RESTO COMO SALIDA
    MOVWF TRISB
    
    BCF OPTION_REG,7	    ;HABILITACI�N PULL_UPS 
    BANKSEL WPUB
    MOVLW b'00000111'
    MOVWF WPUB		    ;RB0-RB5 PULL UPS (SIEMPRE TIENE UN 1)

;inicializaci�n variables
;--------------------------------------------------------------
    BANKSEL PORTC
    MOVLW 0xFF 
    MOVWF PORTC		    ;Displays pagados 
    MOVWF PORTD		    ;Segmentos deshabilitados
    MOVWF PORTE
    MOVWF COLOR_C1
    MOVWF COLOR_C2
    MOVWF CARTA1
    MOVWF CARTA2
    BCF PORTA,2
    CLRF CONT_MULT
    MOVLW b'01110000'
    MOVWF PORTB 
    CLRF APUESTA_J1
    CLRF APUESTA_J2
    CLRF APUESTA_SUP
    CLRF APUESTA_INF
    CLRF TURNO
    CLRF TICK 
    CLRF CONT_REB
    CLRF BYTE_APUESTA 
    CLRF BYTE_DATO 
    MOVLW b'00000111'
    MOVWF BTN_ULT	;Iinician todos los botones en 1, tienen las pul-ups 
    CLRF RX_ESTADO 
    CLRF RX_BYTE1
    CLRF RX_BYTE2
    CLRF ADC_ALTO
    CLRF ADC_BAJO 
    CLRF APUESTA_TEMP
    CLRF DECENA_APUESTA
    CLRF UNIDAD_APUESTA
    CLRF CONT_RECEPCION 
    CLRF RX_LISTO
    CLRF INDICE_PALO
    CLRF INDICE_CARTA
    CLRF BYTE_AUX 
    CLRF POTENCIOMETRO 
    CLRF APUESTA_ESTADO
;===============================================================================   
;	    TIMER0		PRESCALER 1:16 TMER0 = 100
;	    FOSC = 4MHz --> CICLO DE INTERRUPCI�N = 1us
;	    156 INCREMENTOS * 16 = 2.5 ms 
;===============================================================================
    
  BANKSEL OPTION_REG 
  MOVLW b'00000011'
  MOVWF OPTION_REG	    ;PRESCALER 1:16	    PRESCALER ASIGNADO A TIMER0
 
  BANKSEL TMR0 
  MOVLW .100
  MOVWF TMR0
  
; Limpiamos las banderas 
  BANKSEL PORTB
  BCF INTCON, T0IF
  

; Habilitaci�n interrupciones TMR0 
  BSF INTCON, T0IE 
  BSF INTCON,PEIE
  BSF INTCON,GIE 
  
;===============================================================================
;				lazo principal
;===============================================================================
  
; transmi en serie  
LOOP 
  BTFSC RX_LISTO,0	;Llego una trama completa ? 
  GOTO SERVICIO_RX
  
  BTFSS TURNO,0 
  GOTO LOOP
  
  BTFSS APUESTA_ESTADO,0
  GOTO REVISAR_BOTONES
  CALL INICIA_CONVERSION

REVISAR_BOTONES 
 
  BTFSS TICK,0		;Solo muestreo cada 2.5 ms 
  GOTO LOOP
  BCF TICK,0
  MOVF PORTB,W
  ANDLW b'00000111'	;RB0-RB2 (activos en bajo) si se pone en cero,se apreto
  MOVWF BTN_ACT		    ;valor actual para comparar desp
  XORLW b'00000111'
  BTFSC STATUS,Z	   ;Z=1, ninguno apretado 
  GOTO REB_SUELTO
  MOVF BTN_ACT,W
  XORWF BTN_ULT,W
  BTFSS STATUS,Z	    ;Z=0 cambio el bton respecto al anterior 
  GOTO REB_CAMBIO
  
  INCF CONT_REB,F	    ;la lectura es la misma, suma 1
  MOVLW .8
  XORWF CONT_REB,W 
  BTFSS STATUS,Z	    ;Z = 0 no pasaron 20ms 
  GOTO LOOP
; se confirm� la pulsaci�n, pasa a verificar los botones
 	    
  BTFSS PORTB,0		    ;boton apretado vale 0 
  GOTO  APUESTA 
  BTFSS PORTB,1
  GOTO IGUALAR 
  BTFSS PORTB,2 
  GOTO RETIRA 
  GOTO LOOP
 
REB_SUELTO 
  
  CLRF CONT_REB		    ;fue rebote, se reinicia
  MOVLW b'00000111'
  MOVWF BTN_ULT		    ;Vuelven a estar todos sin apretar
  GOTO LOOP 

REB_CAMBIO 
  MOVF BTN_ACT,W 
  MOVWF BTN_ULT	    ;guarda la �ltima lectura como referencia para la proxima
  CLRF CONT_REB	    ;vuelve a inicar el contador
  GOTO LOOP
  
;                            Servicio RX
 ;============================================================================== 
 SERVICIO_RX 
  BTFSC RX_BYTE1,2	;Es una carta ? Co = 1
  GOTO PROCESAR_RX
  GOTO PROCESAR_APUESTA  

PROCESAR_RX	;Procesa datos carta 
  
    MOVF CONT_RECEPCION, W
    XORLW .2
    BTFSC STATUS,Z		;si contador es 2 => z = 1  
    GOTO FIN_PROCESAMIENTO	;Puede prcesar las cartas

    CALL PROCESAR_PALO
    CALL PROCESAR_NUMERO

    INCF CONT_RECEPCION, F
    
    GOTO FIN_PROCESAMIENTO  
;Subrutina para decodificar la apuesta -------------------------------------   
PROCESAR_APUESTA 
    MOVF RX_BYTE2,W	    ;Limpiamos el byte2 
    ANDLW b'01111111'
    MOVWF APUESTA_J1
    BTFSC STATUS,Z 
    CALL REINICIA_APUESTA
    
    MOVF RX_BYTE1,W 
    ANDLW b'01100000'
    XORLW (ID_JUGADOR << 5 )	; J1 = 0x20, J2 = 0x40
    BTFSS STATUS,Z
    GOTO FIN_PROCESAMIENTO 
    BSF TURNO,0	    ;habilita el poling de los botones
    BSF PORTA,2    ; Enciende LED de turno
    GOTO FIN_PROCESAMIENTO 

 REINICIA_APUESTA 
    MOVF APUESTA_J1,W
    MOVWF APUESTA_J2
    MOVWF POTENCIOMETRO 
    CALL LOOP_APUESTA
    RETURN
;--Subrutina para decodificar el palo -----------------
PROCESAR_PALO
    MOVF RX_BYTE2,W
    ANDLW b'01100000'	    ;Conservar bits 6 y 5

    MOVWF BYTE_AUX
    BCF STATUS,C  ;Se desplazan los bits 6 y 5, cinco posiciones a la derecha
    RRF BYTE_AUX,F   

    BCF STATUS,C
    RRF BYTE_AUX,F

    BCF STATUS,C
    RRF BYTE_AUX,F

    BCF STATUS,C
    RRF BYTE_AUX,F

    BCF STATUS,C
    RRF BYTE_AUX,F

    MOVF BYTE_AUX,W  
    MOVWF INDICE_PALO
    
    MOVF INDICE_PALO, W
    CALL TABLA_PALOS

    MOVWF BYTE_AUX
    
    MOVF CONT_RECEPCION,W	;incrementa una vez que termina de procesar todo
    XORLW .1
    BTFSC STATUS, Z		
    GOTO GUARDAR_COLOR2
    
GUARDAR_COLOR1 		
    MOVF BYTE_AUX,W
    MOVWF COLOR_C1
    RETURN

GUARDAR_COLOR2
    MOVF BYTE_AUX,W
    MOVWF COLOR_C2
    RETURN
    
;--Subrutina para decodificar el numero de la carta-----------------------------
PROCESAR_NUMERO 
    MOVF RX_BYTE2,W
    ANDLW b'00011110'		;limpia el byte para guardarlo en byte_aux 
    
    MOVWF BYTE_AUX

    BCF STATUS,C   ;Se desplaza una posicion a la derecha
    RRF BYTE_AUX,F

    MOVF BYTE_AUX,W
    MOVWF INDICE_CARTA
    
    MOVF INDICE_CARTA, W
    CALL TABLA_CARTAS

    MOVWF BYTE_AUX 
    MOVF CONT_RECEPCION, W
    XORLW .1
    BTFSC STATUS, Z
    GOTO GUARDAR_CARTA2

GUARDAR_CARTA1
    MOVF BYTE_AUX,W
    MOVWF CARTA1
    RETURN

GUARDAR_CARTA2
    MOVF BYTE_AUX,W
    MOVWF CARTA2
    RETURN
    
FIN_PROCESAMIENTO   
  BCF RX_LISTO,0
  GOTO LOOP
  
;				ISR
;===============================================================================
ISR 
  ; Guardado contexto 
  MOVWF W_TEMP
  SWAPF STATUS,W 
  MOVWF STATUS_TEMP
  
  BANKSEL RCSTA
  BTFSC RCSTA,OERR
  CALL RECUPERAR_OERR
  
  BANKSEL PIR1
  BTFSC PIR1,RCIF
  CALL RUTINA_UART
  
REVISAR_TMR0
  BTFSS INTCON,T0IF	;Verifica si la interrupcion fue por TMR0  
  GOTO FIN_ISR

;------------ RUTINA TMER0-----------------
RUTINA_TMR0 
  
  BCF INTCON, T0IF 
  MOVLW .100
  MOVWF TMR0
  BSF TICK,0
  
;Apagamos para evitar sombras
  MOVLW 0xFF	     
  MOVWF PORTC
  MOVLW b'00000111'
  MOVWF PORTE

;Envio valors al display segun cont_mult 
  MOVF CONT_MULT,W
  BTFSC STATUS,Z 
  GOTO DISP4	    ;CONT_MUX = 0 => RC0(APUESTA_INF)
  XORLW .1
  BTFSC STATUS,Z 
  GOTO DISP3	    ;CONT_MUX = 1 => RC1 (APUESTA_SUP)
  MOVF CONT_MULT,W
  XORLW .2	    
  BTFSC STATUS,Z    ;CON_MUX = 2 => RC2 (CARTA 2 + RGD CARTA2 )
  GOTO DISP2
DISP1		    ;CON_MUX = 3 => RC3 (CARTA 1 + RGB CARTA1)
    MOVF COLOR_C1,W
    MOVWF PORTE
    MOVF CARTA1,W
    GOTO CARGAR  
DISP2
    MOVF COLOR_C2,W
    MOVWF PORTE
    MOVF CARTA2,W
    GOTO CARGAR
DISP4 
    MOVF APUESTA_INF,W
    GOTO CARGAR   
DISP3 
    MOVF APUESTA_SUP,W 

CARGAR 
    MOVWF PORTD		    ;Carga a portD el valro que toca
    MOVF CONT_MULT,W
    CALL SELECCION_D7S	    ;Enciende el display correspondiente 
    MOVWF PORTC 
  
    INCF CONT_MULT,F
    MOVF CONT_MULT,W
    XORLW .4 
    BTFSC STATUS,Z 
    CLRF CONT_MULT	    ;Reinicia la cuenta del multiplexado.
    GOTO FIN_ISR 
 

;-------- RUTINA UART--------------------------------    
RUTINA_UART 
    BTFSC RX_ESTADO,0
    GOTO SEGUNDO_BYTE
    
PRIMER_BYTE 
  BANKSEL RCREG
  MOVF RCREG,W	    ;Leer primer byte
  MOVWF RX_BYTE1
  BSF RX_ESTADO,0
  RETURN
  
SEGUNDO_BYTE 
  BANKSEL RCREG
  MOVF RCREG, w ; Leer segundo byte
  MOVWF RX_BYTE2
  BSF RX_LISTO, 0
  BCF RX_ESTADO, 0
  RETURN 
 
FIN_ISR 
  ;RECUPERAMOS CONTEXTO 
  SWAPF STATUS_TEMP,W 
  MOVWF STATUS 
  SWAPF W_TEMP,F 
  SWAPF W_TEMP,W 
  RETFIE 

RECUPERAR_OERR
    BANKSEL RCSTA

    BCF RCSTA,CREN       ; Deshabilita recepci�n continua
    BSF RCSTA,CREN       ; Vuelve a habilitar recepci�n

    CLRF RX_ESTADO       ; Descarta una trama incompleta

    RETURN
;===============================================================================
;			    RUTINAS BOTONES 
;===============================================================================
APUESTA 

    BTFSC APUESTA_ESTADO,0 ; Es la primera pulsaci�n del boton apuesta?
    GOTO CONFIRMAR_APUESTA ; Segunda pulsaci�n

    BSF APUESTA_ESTADO,0 ; Primera pulsaci�n

    GOTO LOOP


CONFIRMAR_APUESTA
  
;Verificamos que el valor de la apuesta sea mayor a la apuesta del otro jugador
  MOVF APUESTA_J1,W
  SUBWF POTENCIOMETRO,W 
  BTFSC STATUS,Z	    ;iugal: no vale
  GOTO LOOP
  BTFSS STATUS,C	    ;menor:no vale
  GOTO LOOP 
  MOVF POTENCIOMETRO,W
  MOVWF APUESTA_J2
  MOVLW 0x08		    ;guardamos el estado de la acci�n  
  MOVWF BYTE_DATO 
  GOTO FIN_TURNO

INICIA_CONVERSION 
    BANKSEL ADCON0
    BSF ADCON0, 1 	;Inicia la conversi�n 
    
ESPERAR_ADC
    BTFSC ADCON0,1	;Sigue conviertiendo?
    GOTO ESPERAR_ADC  
    
    BANKSEL ADRESL 
    MOVF ADRESL,W
    BANKSEL ADC_BAJO	;Guarda los 8 bits bajos de la conversi�n 
    MOVWF ADC_BAJO
    
    BANKSEL ADRESH
    MOVF ADRESH, w
    ANDLW b'00000011'
    BANKSEL ADC_BAJO	;Guarda los 2 bits altos de la conversi�n
    MOVWF ADC_ALTO    
    
    CLRF POTENCIOMETRO 		

ESCALAR_ADC
    MOVF ADC_ALTO,F
    BTFSS STATUS,Z	    ;ADC_ALTO = 0 ?
    GOTO RESTAR_10 
    
    MOVLW .10		    ;adc_alto = 0, revisar adc_bajo
    SUBWF ADC_BAJO,W
    BTFSS STATUS, C	    ;adc_bajo < 10 ? Si C = 0
    GOTO FIN_ESCALADO

    MOVLW .10		    ;adc_bajo >= 10, se resta le 10
    SUBWF ADC_BAJO,F
    GOTO INCREMENTAR_APUESTA

RESTAR_10 
    MOVLW .10
    SUBWF ADC_BAJO,F

    BTFSS STATUS,C	;Ve si hay carry, "pide prestado"
    DECF ADC_ALTO,F

INCREMENTAR_APUESTA

    INCF POTENCIOMETRO,F	;Incrementamos en 1 las veces que se resta 10
    GOTO ESCALAR_ADC

FIN_ESCALADO		;Limitar la apuesta a 99

    MOVLW .100
    SUBWF POTENCIOMETRO,W

    BTFSS STATUS, C	;Si apuesta >= 100 se muestra 99 
    GOTO LOOP_APUESTA 

    MOVLW .99
    MOVWF POTENCIOMETRO
    
LOOP_APUESTA  
    MOVF POTENCIOMETRO,W
    MOVWF APUESTA_TEMP

    CLRF DECENA_APUESTA

LOOP_DECENAS
    MOVLW .10 
    SUBWF APUESTA_TEMP,W

    BTFSS STATUS, C		;apuesta_temp < 10? Si C=0
    GOTO FIN_DECENAS

    MOVLW .10 
    SUBWF APUESTA_TEMP,F 	;apuesta_temp - 10

    INCF DECENA_APUESTA,F
    GOTO LOOP_DECENAS

FIN_DECENAS

    MOVF APUESTA_TEMP ,w 
    MOVWF UNIDAD_APUESTA

MOSTRAR_APUESTA
    MOVF DECENA_APUESTA,W
    CALL TABLA_APUESTA
    movwf APUESTA_SUP
    
    MOVF UNIDAD_APUESTA,W
    CALL TABLA_APUESTA
    MOVWF APUESTA_INF
    RETURN
;---------------------------------------------------------------------------
RETIRA  
  MOVLW 0xFF		    ;Apagamos displys cartas
  MOVWF CARTA1
  MOVWF CARTA2
  MOVWF COLOR_C1
  MOVWF COLOR_C2
  MOVWF PORTE	    ;
  MOVLW 0x10		    ;Guardamos el estado de la acci�n 		    
  MOVWF BYTE_DATO
  CLRF APUESTA_J2 
  CLRF CONT_RECEPCION
  GOTO FIN_TURNO
;---------------------------------------------------------------------------
IGUALAR 
  MOVF APUESTA_J1 ,W
  MOVWF APUESTA_J2
  MOVWF POTENCIOMETRO
  CALL LOOP_APUESTA
  MOVLW 0x18		    ;Guardamos el estado de la acci�n  
  MOVWF BYTE_DATO 
  GOTO FIN_TURNO 


FIN_TURNO
  BCF TURNO,0
  BCF APUESTA_ESTADO,0
  CLRF CONT_REB
  
;Terminamos de acomodar byte 1 
  MOVLW ID_TURNO	    ;1 10 00000
  IORWF BYTE_DATO,F
  
  
;acomodamos byte 2 
  MOVF APUESTA_J2,W
  IORWF BYTE_APUESTA,F 
  
;Envio  
  BANKSEL PIR1
ESPERA1		    ;Verificamos si la UART est� lista para enviar el segundo byte
  BTFSS PIR1,TXIF	
  GOTO ESPERA1
  MOVF BYTE_DATO,W
  MOVWF TXREG
ESPERA2   
  BTFSS PIR1,TXIF 	
  GOTO ESPERA2
  MOVF BYTE_APUESTA,W 
  MOVWF TXREG 

  BCF PORTA,2    ; Apaga LED de turno 
  CLRF BYTE_APUESTA	;Limpiamos el byte de la apuesta
  GOTO LOOP
 
END




```
</details>

</details>
