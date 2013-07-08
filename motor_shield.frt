marker _motor_shield_



synonym pwm_a digital.3
synonym pin_dir_a digital.12
synonym pwm_b digital.11
synonym pin_dir_b digital.13
synonym pin_collision_front digital.2
synonym collision_status digital.7


1 constant forward
0 constant backward

90 value global_speed

: setup
    pwm_a pin_output
    pwm_b pin_output
    pin_dir_a pin_output
    pin_dir_b pin_output
    pin_collision_front pin_input
    collision_status pin_output
    5 0 do
	collision_status high
	200 ms
	collision_status low
	200 ms
    loop
;

: dir_motor_a  ( f -- )
    pin_dir_a rot if high else low then ;

: dir_motor_b  ( f -- )
    pin_dir_b rot if high else low then ;

: speed_motor_a ( u -- )
    pwm_a
    

