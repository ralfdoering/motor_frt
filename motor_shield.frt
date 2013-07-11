(
Sample code to interface with Arduino Motor shield and
my "Rover" tracked robot.

The Rover is a tracked vehicle with 2 motors.
I will call them "motor_a" and "motor_b".

motor_a is on the left side, motor_b is on the right side.
[FIXME: is this true?]


The code below uses some Arduino specific definitions for
the pin layout to fit with the labeling on an Arduino board.

For this code to work we need:

- bitnames.frt:
  This comes as lib/bitnames.frt with amFORTH 5.1
- marker.frt:
  This comes as lib/marker.frt with amFORTH 5.1
- synonym.frt:
  This comes as lib/forth200x/synonym.frt with amFORTH 5.1
- app/arduino/blocks/ports-standard.frt:
  from amFORTH 5.1 for definitions of digital.X pin layout.


PWM information:

The motor shield is connected to the Arduino PWM-capable
pins digital.11 and digital.3.
These to pins map to the following Atmega 328p Pins:

| *Arduino*  | *Atmega* | *PWM channel* |
| digital.11 | PB3      |  OC2A         |
| digital.3  | PD3      |  OC2B         |

)



( includes for use with amFORTH Python shell 

)

( execute old marker if it exists )



marker _motor_shield_




( NOTES for PWM  from http://www.mikrocontrollerspielwiese.de/ )

\ include <avr/io.h>


\ define F_CPU 8000000UL      // 8 MHz (fuer delay.h)

\ include <util/delay.h>



\ int main(void){

    
\     //Hardware-PWM initialisieren
\     DDRB |= _BV(PB2);

\     TCCR0A = (1<<WGM11) | (1<<WGM10) | (1<<COM1A1); TCCR0B = (1<<CS10); 

     
\     while(1){

\         OCR0A = 0;   _delay_ms(250);_delay_ms(250); //dunkel
\         OCR0A = 30;  _delay_ms(250);_delay_ms(250); //schwach leuchtend
\         OCR0A = 80;  _delay_ms(250);_delay_ms(250); //staerker leuchtend
\         OCR0A = 255; _delay_ms(250);_delay_ms(250); //volle Helligkeit

\     }


\     return 0;
\ }




\ pin layout matching an Arduino motor shield on
\ Arduino Uno.
synonym pwm_a digital.3       \ PWM pin for motor_a
synonym pin_dir_a digital.12  \ forward == 1, reverse == 0
synonym pwm_b digital.11      \ PWM pin for motor_a
synonym pin_dir_b digital.13  \ forward == 1, reverse == 0
synonym pin_collision_front digital.2 \ collision sensor
synonym collision_status digital.7    \ LED for collision status


1 constant GO_FORWARD
0 constant GO_BACKWARD

128 value global_speed     \ default value for PWM 



\ setup the system
\ FIXME: 
: setup      ( -- )
    \ setup pins
    pwm_a pin_output
    pwm_b pin_output
    pin_dir_a pin_output
    pin_dir_b pin_output
    pin_collision_front pin_input
    collision_status pin_output
    \ blink collision led 5 times to show
    \ "I'm ready" [FIXME: factor this out]
    5 0 do
	collision_status high
	200 ms
	collision_status low
	200 ms
    loop
;


\ seems defintions for PWM related TCCR settings are
\ not complete, (re)define them

\ take the position of a bit and make a value out of it
\ for instance: 2 bit2val --> create binary value 00000100
\ technicaly: 1 n lshift (in C speek: 1 << n)
: bit2val     ( n - n' )
    1 swap lshift
;
\ we need only TCCR2
0 bit2val constant TCCR2A_WGM20
1 bit2val constant TCCR2A_WGM21
4 bit2val constant TCCR2A_COM2B0
5 bit2val constant TCCR2A_COM2B1
6 bit2val constant TCCR2A_COM2A0
7 bit2val constant TCCR2A_COM2A1

0 bit2val constant TCCR2B_CS20
1 bit2val constant TCCR2B_CS21
2 bit2val constant TCCR2B_CS22
6 bit2val constant TCCR2B_FOC2B
7 bit2val constant TCCR2B_FOC2A


    


: setup_pwm ( -- )
    \ make sure pwm_b is an output
    pwm_b pin_output
    \ setup timer2:
    \    phase correct pwm
    TCCR2A_WGM20
    \ enable OC2B and OC1A
    TCCR2A_COM2B1 or
    TCCR2A_COM2A1 or
    TCCR2A c!  
    \ setup timer 2
    \ prescale 64
    TCCR2B_CS22 TCCR2B c!
;


: set_pwm_a ( c - )
    OCR2B c!
;

: set_pwm_b ( c - )
    OCR2A c!
;



\ set direction of motor_a/motor_b.
\ use constant forward / backward for flag f
: dir_motor_a!  ( f -- )
    pin_dir_a rot if high else low then
;

: dir_motor_b!  ( f -- )
    pin_dir_b rot if high else low then
;

: speed_motor_a! ( u -- )
    set_pwm_a
;    

: speed_motor_b! ( u -- )
    set_pwm_b
;

: stop_motor_a
    0 speed_motor_a!
;

: stop_motor_b
    0 speed_motor_b!
;

: stop!
    stop_motor_a
    stop_motor_b
;

: stop
    stop!
;


: forward!
    GO_FORWARD dup dir_motor_a! dir_motor_b!
    global_speed dup speed_motor_a! speed_motor_b!
;

: forward
    forward!
    1000 ms
    stop!
;

: backward!
    GO_BACKWARD dup dir_motor_a! dir_motor_b!
    global_speed dup speed_motor_a! speed_motor_b!
;

: backward
    backward!
    1000 ms
    stop!
;



: right!
    GO_FORWARD dir_motor_b!
    GO_BACKWARD dir_motor_a!
    global_speed dup speed_motor_a! speed_motor_b!
;

: right
    right!
    1000 ms
    stop!
;


: left!
    GO_FORWARD dir_motor_a!
    GO_BACKWARD dir_motor_b!
    global_speed dup speed_motor_a! speed_motor_b!
;

: left
    left!
    1000 ms
    stop!
;

\ some short short-cuts

synonym s stop
synonym l left
synonym r right
synonym f forward
synonym b backward

synonym s! stop!
synonym l! left!
synonym r! right!
synonym f! forward!
synonym b! backward!