#!/usr/bin/env python3

# Read control knobs

import argparse
import sys
import time

# TODO: if testing, import RPi_fake.GPIO...
import RPi.GPIO as gpio # https://pypi.python.org/pypi/RPi.GPIO more info

# GPIO numbers, not pin numbers
STEP_L = 12 # blue
DIR_L = 16 # purple
SWITCH_L = 26 # orange

STEP_R = 5 # brown
DIR_R = 6 # red
SWITCH_R = 13 # gray


# (step, dir) sequence
# (1, 1) at rest
# (0, 0) == reset
# (0, 0) -> (1, 0) -> (1, 1) == left
# (0, 0) -> (0, 1) -> (1, 1) == right
# when (1, 1) is seen, no output until (0, 0) is seen


def left_step_callback(channel):
    d = gpio.input(DIR_L)
    if d:
        print("LEFT")
    else
        print("RIGHT")

def right_step_callback(channel):
    d = gpio.input(DIR_R)
    if d:
        print("UP")
    else
        print("DOWN")

def button_callback(channel):
    print('button callback for channel {}'.format(channel))


def init():
    gpio.setmode(gpio.BCM)
    gpio.setup(STEP_L, gpio.IN, pull_up_down=gpio.PUD_UP)
    gpio.setup(DIR_L, gpio.IN, pull_up_down=gpio.PUD_UP)
    gpio.setup(SWITCH_L, gpio.IN, pull_up_down=gpio.PUD_UP)
    gpio.setup(STEP_R, gpio.IN, pull_up_down=gpio.PUD_UP)
    gpio.setup(DIR_R, gpio.IN, pull_up_down=gpio.PUD_UP)
    gpio.setup(SWITCH_R, gpio.IN, pull_up_down=gpio.PUD_UP)

    gpio.add_event_detect(STEP_L, gpio.FALLING, bouncetime=200)
    gpio.add_event_callback(STEP_L, left_step_callback)
    gpio.add_event_detect(STEP_R, gpio.FALLING, bouncetime=200)
    gpio.add_event_callback(STEP_R, right_step_callback)
    gpio.add_event_detect(SWITCH_L, gpio.FALLING, bouncetime=200)
    gpio.add_event_callback(SWITCH_L, button_callback)
    gpio.add_event_detect(SWITCH_R, gpio.FALLING, bouncetime=200)
    gpio.add_event_callback(SWITCH_R, button_callback)

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
    parser.add_argument('--speed', type=float, help='steps per second', default=200)
    args = parser.parse_args()
    print(args)
    init()
    loop()
