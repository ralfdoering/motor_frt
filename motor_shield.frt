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


1 constant forward 
0 constant backward

90 value global_speed     \ default value for PWM 

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


\ set direction of motor_a/motor_b.
\ use constant forward / backward for flag f
: dir_motor_a  ( f -- )
    pin_dir_a rot if high else low then ;

: dir_motor_b  ( f -- )
    pin_dir_b rot if high else low then ;

: speed_motor_a ( u -- )
    pwm_a
    

