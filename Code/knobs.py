#!/usr/bin/env python3

# Read control knobs

import argparse
import sys
import time

# TODO: if testing, import RPi_fake.GPIO...
import RPi.GPIO as gpio # https://pypi.python.org/pypi/RPi.GPIO more info

# GPIO numbers, not pin numbers
STEP_R = 12 # blue
DIR_R = 16 # purple
SWITCH_R = 26 # orange

STEP_L = 5 # brown
DIR_L = 6 # red
SWITCH_L = 13 # gray


# (step, dir) sequence
# (1, 1) at rest
# (0, 0) == reset
# (0, 0) -> (1, 0) -> (1, 1) == left
# (0, 0) -> (0, 1) -> (1, 1) == right
# when (1, 1) is seen, no output until (0, 0) is seen

# state: last read (step, dir)
LEFT_STATE = (1, 1)
LEFT_VALID = True
RIGHT_STATE = (1, 1)
RIGHT_VALID = True

# user callbacks
def null_cb(arg):
    pass

_callbacks = { 'left_move' : null_cb, 'right_move' : null_cb, 'left_button' : null_cb, 'right_button' : null_cb }

def left_step_callback(channel):
    global LEFT_STATE
    val = gpio.input(DIR_L)
    left_step((LEFT_STATE[0], val))


def left_dir_callback(channel):
    global LEFT_STATE
    val = gpio.input(STEP_L)
    left_step((val, LEFT_STATE[1]))


def right_step_callback(channel):
    global RIGHT_STATE
    val = gpio.input(DIR_R)
    right_step((RIGHT_STATE[0], val))


def right_dir_callback(channel):
    global RIGHT_STATE
    val = gpio.input(STEP_R)
    right_step((val, RIGHT_STATE[1]))


def left_step(new_state):
    global LEFT_STATE
    global LEFT_VALID
    # print("L: {} -> {}".format(LEFT_STATE, new_state))
    if LEFT_STATE == (0, 0):
        LEFT_VALID = True
    elif LEFT_STATE == (0, 1) and new_state == (1, 1):
            if LEFT_VALID:
                left_move(0)
            LEFT_VALID = False
    elif LEFT_STATE == (1, 0) and new_state == (1, 1):
            if LEFT_VALID:
                left_move(1)
            LEFT_VALID = False
    LEFT_STATE = new_state


def right_step(new_state):
    global RIGHT_STATE
    global RIGHT_VALID
    # print("R: {} -> {}".format(RIGHT_STATE, new_state))
    if RIGHT_STATE == (0, 0):
        RIGHT_VALID = True
    elif RIGHT_STATE == (0, 1) and new_state == (1, 1):
            if RIGHT_VALID:
                right_move(0)
            RIGHT_VALID = False
    elif RIGHT_STATE == (1, 0) and new_state == (1, 1):
            if RIGHT_VALID:
                right_move(1)
            RIGHT_VALID = False
    RIGHT_STATE = new_state


def left_move(dir):
    print(dir)
    _callbacks['left_move'](dir)


def right_move(dir):
    print(dir)
    _callbacks['right_move'](dir)


def left_button_down_callback(channel):
    print('button callback for channel {}'.format(channel))
    left_button(0)


def left_button_up_callback(channel):
    print('button callback for channel {}'.format(channel))
    left_button(1)


def right_button_down_callback(channel):
    print('button callback for channel {}'.format(channel))
    right_button(0)


def right_button_up_callback(channel):
    print('button callback for channel {}'.format(channel))
    right_button(1)


def add_knob_callback(event, cb):
    """
    move callbacks get called with a "direction" argument (0 or 1)
    button callbacks get called with a "state" argument (0 or 1)

    callback names: left_move, right_move, left_button, right_button
    """
    _callbacks[event] = cb


def init_knobs(knob_debounce_time, switch_debounce_time):
    gpio.setmode(gpio.BCM)
    gpio.setup(STEP_L, gpio.IN, pull_up_down=gpio.PUD_UP)
    gpio.setup(DIR_L, gpio.IN, pull_up_down=gpio.PUD_UP)
    gpio.setup(SWITCH_L, gpio.IN, pull_up_down=gpio.PUD_UP)
    gpio.setup(STEP_R, gpio.IN, pull_up_down=gpio.PUD_UP)
    gpio.setup(DIR_R, gpio.IN, pull_up_down=gpio.PUD_UP)
    gpio.setup(SWITCH_R, gpio.IN, pull_up_down=gpio.PUD_UP)

    gpio.add_event_detect(STEP_L, gpio.BOTH, bouncetime=knob_debounce_time)
    gpio.add_event_detect(STEP_R, gpio.BOTH, bouncetime=knob_debounce_time)
    gpio.add_event_callback(STEP_L, left_step_callback)
    gpio.add_event_callback(STEP_R, right_step_callback)
    gpio.add_event_detect(DIR_L, gpio.BOTH, bouncetime=knob_debounce_time)
    gpio.add_event_detect(DIR_R, gpio.BOTH, bouncetime=knob_debounce_time)
    gpio.add_event_callback(DIR_L, left_dir_callback)
    gpio.add_event_callback(DIR_R, right_dir_callback)
    
    
    gpio.add_event_detect(SWITCH_L, gpio.FALLING, bouncetime=switch_debounce_time)
    gpio.add_event_callback(SWITCH_L, left_button_down_callback)
    gpio.add_event_detect(SWITCH_L, gpio.RISING, bouncetime=switch_debounce_time)
    gpio.add_event_callback(SWITCH_L, left_button_up_callback)
    gpio.add_event_detect(SWITCH_R, gpio.FALLING, bouncetime=switch_debounce_time)
    gpio.add_event_callback(SWITCH_R, right_button_down_callback)
    gpio.add_event_detect(SWITCH_R, gpio.RISING, bouncetime=switch_debounce_time)
    gpio.add_event_callback(SWITCH_R, right_button_up_callback)

def loop():
    while True:
        # step_l = gpio.input(STEP_L)
        # dir_l = gpio.input(DIR_L)
        # switch_l = gpio.input(SWITCH_L)
        # step_r = gpio.input(STEP_R)
        # dir_r = gpio.input(DIR_R)
        # switch_r = gpio.input(SWITCH_R)
        # print("{} {} {} {} {} {}".format(step_l, dir_l, switch_l, step_r, dir_r, switch_r))
        time.sleep(0.1)

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('knob_debounce_time', type=int, help='knob debounce time')
    parser.add_argument('switch_debounce_time', type=int, help='switch debounce time')
    
    args = parser.parse_args()
    init_knobs(args.knob_debounce_time, args.switch_debounce_time)

    def move_l(dir):
        print("LMove: {}".format(dir))

    def move_r(dir):
        print("RMove: {}".format(dir))

    def button_l(dir):
        print("LButton: {}".format(dir))

    def button_r(dir):
        print("RButton: {}".format(dir))

    add_knob_callback('left_move', move_l)
    add_knob_callback('right_move', move_r)
    add_knob_callback('left_button', button_l)
    add_knob_callback('right_button', button_r)
    loop()
