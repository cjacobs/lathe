#!/usr/bin/env python3

# Read control knobs

import argparse
import sys
import threading
import time

try:
    # https://pypi.python.org/pypi/RPi.GPIO more info
    import RPi.GPIO as gpio 
except:
    import RPi_fake.GPIO as gpio

# GPIO numbers, not pin numbers
STEP_R = 12 # blue
DIR_R = 16 # green
SWITCH_R = 26 # orange

STEP_L = 5 # white/blue
DIR_L = 6 # white/green
SWITCH_L = 13 # white/orange

# Vcc: white/brown
# GND: brown

_verbose = False

# (step, dir) sequence
# (1, 1) at rest
# (0, 0) == reset
# (0, 0) -> (1, 0) -> (1, 1) == left
# (0, 0) -> (0, 1) -> (1, 1) == right
# when (1, 1) is seen, no output until (0, 0) is seen

# state: last read (step, dir)
lock = threading.Lock()
_left_state = (1, 1)
_left_valid = True
_right_state = (1, 1)
_right_valid = True

# Callback ids
LEFT_MOVE = 'left_move'
RIGHT_MOVE = 'right_move'
LEFT_BUTTON = 'left_button'
RIGHT_BUTTON = 'right_button'

# user callbacks
def null_cb(arg):
    pass

_callbacks = { LEFT_MOVE : null_cb, RIGHT_MOVE : null_cb, LEFT_BUTTON : null_cb, RIGHT_BUTTON : null_cb }

def left_step_callback(channel):
    global _left_state
    val = gpio.input(DIR_L)
    left_step((_left_state[0], val), "clk")


def left_dir_callback(channel):
    global _left_state
    val = gpio.input(STEP_L)
    left_step((val, _left_state[1]), "dir")


def right_step_callback(channel):
    global _right_state
    new_dir = gpio.input(DIR_R)
    new_state = (_right_state[0], new_dir)
    right_step(new_state, "clk")


def right_dir_callback(channel):
    global _right_state
    new_clk = gpio.input(STEP_R)
    new_state = (new_clk, _right_state[1])
    right_step(new_state, "dir")


def left_step(new_state, signal):
    global _left_state
    global _left_valid
    amount = None
    with lock:
        old_state = _left_state
        if old_state == (0, 0):
            _left_valid = True
        elif new_state == (1, 1):
            if _left_valid:
                amount = old_state[0] - old_state[1]
            _left_valid = False
        if _verbose:
            print("left knob event: {} -> {} amount: {}, valid: {}, signal: {}".format(old_state, new_state, amount, _left_valid, signal))
    if amount:
        left_move(amount)

def right_step(new_state, signal):
    global _right_state
    global _right_valid
    amount = None
    with lock:
        old_state = _right_state
        if old_state == (0, 0):
            _right_valid = True
        elif new_state == (1, 1):
            if _right_valid:
                amount = old_state[0] - old_state[1]
            _right_valid = False
        _right_state = new_state
        if _verbose:
            print("right knob event: {} -> {} amount: {}, valid: {}, signal: {}".format(old_state, new_state, amount, _right_valid, signal))

    if amount:
        right_move(amount)


def left_move(dir):
    _callbacks['left_move'](dir)


def right_move(dir):
    _callbacks['right_move'](dir)


def left_button_callback(channel):
    dir = gpio.input(SWITCH_L)
    if _verbose:
        print("left button event, channel: {}, value: {}".format(channel, dir))
    _callbacks['left_button'](dir)


def right_button_callback(channel):
    dir = gpio.input(SWITCH_R)
    if _verbose:
        print("right button event, channel: {}, value: {}".format(channel, dir))
    _callbacks['right_button'](dir)


def add_knob_callback(event, cb):
    """
    move callbacks get called with a "direction" argument (0 or 1)
    button callbacks get called with a "state" argument (0 or 1)

    callback names: left_move, right_move, left_button, right_button
    """
    _callbacks[event] = cb


def init_knobs(knob_debounce_time=1, switch_debounce_time=100):
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
    
    
    gpio.add_event_detect(SWITCH_L, gpio.BOTH, bouncetime=switch_debounce_time)
    gpio.add_event_callback(SWITCH_L, left_button_callback)
    gpio.add_event_detect(SWITCH_R, gpio.BOTH, bouncetime=switch_debounce_time)
    gpio.add_event_callback(SWITCH_R, right_button_callback)


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
    parser.add_argument('--knob_debounce_time', '-k', type=int, help='knob debounce time', default=1)
    parser.add_argument('--switch_debounce_time', '-s', type=int, help='switch debounce time', default=100)
    parser.add_argument('--verbose', '-v', action="store_true", help='print all events')
    
    args = parser.parse_args()
    init_knobs(args.knob_debounce_time, args.switch_debounce_time)
    _verbose = args.verbose

    def move_l(dir):
        print("LMove: {}".format(dir))

    def move_r(dir):
        print("RMove: {}".format(dir))

    def button_l(dir):
        print("LButton: {}".format(dir))

    def button_r(dir):
        print("RButton: {}".format(dir))

    add_knob_callback(LEFT_MOVE, move_l)
    add_knob_callback(RIGHT_MOVE, move_r)
    add_knob_callback(LEFT_BUTTON, button_l)
    add_knob_callback(RIGHT_BUTTON, button_r)
    loop()
