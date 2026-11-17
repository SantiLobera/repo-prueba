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
