TODO: circuts


interface idea:
* knob to control steppers. 
* toggle button to toggle between speed and absolute positioning. 
* LED segmented display (green->red) to indicate speed (left/right).  [|||*****\ [] [||||||||]

Make a single motor-driver board for 4 (?) motors. input signals (per motor): enable, sleep, direction, step. (also, microstep settings?) -- check if it's OK to modify microstep settings while running. Look at what other motor control boards / shields do.

Make an arduino motor controller, instead of a zillion 555s, transistors, etc.
