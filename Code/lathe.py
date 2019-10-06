#!/usr/bin/env python3

#
# Stepper motor control for the lathe
#

# There are 2 steppers: X and Y. Each motor takes 200 steps per revolution, and they are each
# driving a T8 Acme leadscrew (pitch: 2mm, lead: 8mm). The linear motion is 8 mm / rev
# or (8/200) = 0.04 mm / step, or 0.0016 in / step (1.6 thou per step).
#
# If we wanted to move the carriage 1 in/s, we'd need to run the stepper at 1600 steps/sec.
# Therefore, our pulse timer must be able to sleep for much less than 1/1000 s.

import scheduler

import argparse
import math
import sys
import threading
import time

try:
    # https://pypi.python.org/pypi/RPi.GPIO more info
    import RPi.GPIO as gpio 
except:
    import RPi_fake.GPIO as gpio
    
import knobs


# current implementation == absolute
# velocity mode: turning left decreases rightward speed or increses leftward speed
#   velocityValue += dir ? 1 : -1
#   velocity = some exponential function of velocityValue? sgn(velocityValue) * 2^*(velocityValue/scale)


# GPIO numbers, not pin numbers
ENABLE = 22

STEP_Y = 17
DIR_Y = 27

STEP_X = 23
DIR_X = 24

X_AXIS = 'x'
Y_AXIS = 'y'
# X: left (-) / right (+)
# Y: forward (-) / back (+)

MAX_DIST_PER_MOVE = 16
MAX_SPEED = 1.0 # in/sec

# Physical properties of the machine:
STEPS_PER_ROTATION = 200
MM_PER_ROTATION = 8.0
MM_PER_STEP = MM_PER_ROTATION / STEPS_PER_ROTATION
IN_PER_STEP = MM_PER_STEP / 25.4


def clamp_inclusive(x, lo, hi):
    if x < lo:
        return lo
    elif x > hi:
        return hi
    return x


def pairs(l):
    a = l[0::2]
    b = l[1::2]
    return zip(a, b)


class Lathe(object):
    def __init__(self, steps_per_second):
        self.reset()
        self.setup()
        self.disable()
        self.steps_per_second = steps_per_second

    def __del__(self):
        self.disable()
        # gpio.cleanup()

    def setup(self):
        gpio.setwarnings(False)
    
        gpio.setmode(gpio.BCM)
        gpio.setup(ENABLE, gpio.OUT)
        gpio.setup(DIR_X, gpio.OUT)
        gpio.setup(STEP_X, gpio.OUT)
        gpio.setup(DIR_Y, gpio.OUT)
        gpio.setup(STEP_Y, gpio.OUT)

    def enable(self):
        gpio.output(ENABLE, gpio.LOW)

    def disable(self):
        gpio.output(ENABLE, gpio.HIGH)

    def reset(self):
        self.curr_x = 0
        self.curr_y = 0

    def carve_convex_contour(self, contour, start_x, end_x, start_y, min_y):
        initial_l = math.floor(start_x) # initial lefthand end
        l = math.floor(start_x)
        r = math.ceil(end_x)
        print('carve: {}, {}, {}, {}'.format(l, r, start_y, min_y))
        y = math.ceil(start_y)
        self.moveto(l, y)
        while l < r and y > min_y:
            self.moveto(l, y)

            # update l
            while math.ceil(contour(l)) >= y and l < r:
                l += 1
                self.moveto(l, y)

            # advance y
            y -= 1
            self.moveto(l, y)
            print('y: {} = {}\t'.format(y, math.ceil(contour(l))), end='')
            print(' '*(l-initial_l), end='')

            # carve
            x = l+1
            while math.ceil(contour(x)) <= y and x < r:
                self.moveto(x, y)
                print('.', end='')
                x += 1

            print(' '*(r-x), end='')
            print('\t = {}'.format(math.ceil(contour(x-1))))

    def carve_contour(self, contour, start_x, end_x, start_y, min_y):
        extra_segments = []
        initial_l = math.floor(start_x) # initial lefthand end
        initial_r = math.ceil(end_x)
        
        l = math.floor(start_x)
        r = math.ceil(end_x)
        print('carve: {}, {}, {}, {}'.format(l, r, start_y, min_y))
        y = math.ceil(start_y)
        
        self.moveto(self.curr_x, y);
        self.moveto(l, y)

        while l < r and y > min_y:
            print('{} -- {}'.format(l, r))
            self.moveto(l, y)

            # update l
            while math.ceil(contour(l)) >= y and l <= r:
                l += 1
                self.moveto(l, y)

            if l == r:
                break

            # advance y
            y -= 1
            self.moveto(l, y)
            # print('y: {} = {}\t'.format(y, math.ceil(contour(l))), end='')
            print(' '*(l-initial_l), end='', flush=True)

            # carve
            x = l
            while math.ceil(contour(x)) <= y and x < r:
                self.moveto(x, y)
                print('.', end='', flush=True)
                x += 1

            print(' '*(initial_r-x), end='', flush=True)
            print(' span: ({}, {}), {}'.format(l, x-1, y))
            # print('\t = {}'.format(math.ceil(contour(x-1))))
            old_r = r
            r = x

            if x+1 < old_r:
                # don't add the segment if it's going to be empty
                ok = False
                for xx in range(x+1, old_r):
                    if math.ceil(contour(xx)) < y:
                        ok = True
                if ok:
                    extra_segments += [(x+1, old_r, y, min_y)]
        
        # Now recursively do the rest
        for args in extra_segments:
            self.carve_contour(contour, *args)

    def moveto(self, x, y):
        dx = x - self.curr_x
        dy = y - self.curr_y
        self.move(dx, dy)

    def move(self, dx, dy):
        '''Move in a straight line using Bresenham's algorithm'''
        if dx == 0 and dy == 0:
            return
        dir_x = 1 if dx > 0 else -1
        dir_y = 1 if dy > 0 else -1
        dx = abs(dx)
        dy = abs(dy)

        major_dist = max(dx, dy)
        minor_dist = min(dx, dy)
        if dx >= dy:
            major_dist = dx
            major_dir = dir_x
            major_axis = X_AXIS
            minor_dist = dy
            minor_dir = dir_y
            minor_axis = Y_AXIS
        else:
            major_dist = dy
            major_dir = dir_y
            major_axis = Y_AXIS
            minor_dist = dx
            minor_dir = dir_x
            minor_axis = X_AXIS

        dist = math.sqrt(dx*dx + dy*dy) # used for timing only
        sleep_time = self.get_wait_time() * (dist/major_dist)

        err = 0
        for i in range(major_dist):
            err -= minor_dist

            self.step(major_axis, major_dir * 1)
            if err < 0:
                err += major_dist
                self.step(minor_axis, minor_dir * 1)
                
            scheduler.accurate_sleep(sleep_time)

    def step(self, axis, count):
        if axis == X_AXIS:
            self.step_x(count)
        else:
            self.step_y(count)

    def step_x(self, count):
        self.set_x_dir(1 if count > 0 else 0)
        self.pulse(STEP_X, abs(count))
        self.curr_x += count

    def step_y(self, count):
        self.set_y_dir(1 if count > 0 else 0)
        self.pulse(STEP_Y, abs(count))
        self.curr_y += count

    def set_x_dir(self, d):
        gpio.output(DIR_X, d)

    def set_y_dir(self, d):
        gpio.output(DIR_Y, d)
    
    def get_wait_time(self):
        ''' return the time between steps: 1/steps_per_second'''
        if self.steps_per_second == 0:
            return 0
        
        return 1.0 / self.steps_per_second

    def pulse(self, pin, count):
        for i in range(count):
            gpio.output(pin, gpio.HIGH)
            gpio.output(pin, gpio.LOW)
            time.sleep(0.00001)


def run_with_knobs(lathe):
    print("Running in interactive mode")
    lock = threading.Lock()
    
    # mode constants
    ABSOLUTE = 0 # knobs move a specified amount
    SPEED = 1 # knobs affect current speed

    # direction constants
    LEFT = 0
    RIGHT = 1

    gamma = 1.5
    max_speed_index = 16
    
    # state
    period = 1 / 8192
    mode = ABSOLUTE
    abs_speed = 1
    move_amount = [0, 0]
    
    speed_index = [0, 0]
    motion_dir = [0, 0]
    events_per_step = [0, 0]

    def move(dir, amount):
        nonlocal speed_index, motion_dir, events_per_step

        # dir in [0, 1], 0 == left, 1 == right
        if mode == ABSOLUTE:
            if amount:
                val = abs_speed * amount
                with lock:
                    move_amount[dir] += val
                print("move {} {} ({})".format(dir, val, move_amount))
        else:

            speed_index[dir] += amount
            speed_index[dir] = clamp_inclusive(speed_index[dir], -max_speed_index, max_speed_index)

            # compute move amount given left and right speed indices and count
            if speed_index[dir] < 0:
                motion_dir[dir] = -1
            elif speed_index[dir] > 0:
                motion_dir[dir] = 1
            else:
                motion_dir[dir] = 0

            speed = MAX_SPEED * pow(abs(speed_index[dir]) / max_speed_index, gamma)
            steps_per_sec = speed / IN_PER_STEP # = (in / s) / (in/step) -> steps / s
            if steps_per_sec == 0:
                events_per_step[dir] = 0
            else:
                events_per_step[dir] = int(1 / (period * steps_per_sec))

            print("speed_index: {}\tsteps_per_sec: {}\tspeed: {}\tevents_per_step: {}".format(speed_index, speed, steps_per_sec, events_per_step))

    def move_l(amount):
        move(LEFT, -amount)
 
    def move_r(amount):
        move(RIGHT, amount)

    # Change steps per detent in ABSOLUTE mode
    def button_l(state):
        nonlocal abs_speed
        if state and (mode == ABSOLUTE): # button-up
            abs_speed *= 2
            if abs_speed > MAX_DIST_PER_MOVE:
                abs_speed = 1
            print("speed: {}".format(abs_speed))

    # toggle between ABSOLUTE and SPEED modes
    def button_r(state):
        nonlocal mode, speed_index, motion_dir
        if state: # button-up
            speed_index = [0, 0]
            events_per_step = [0, 0]
            motion_dir = [0, 0]
            if mode == ABSOLUTE:
                mode = SPEED
            else:
                mode = ABSOLUTE
            print("mode: {}".format("ABS" if mode == ABSOLUTE else "REL"))
    
    def timer_func(count):
        nonlocal lock
        nonlocal mode, move_amount
        nonlocal events_per_step, motion_dir

        # atomic copy-and-zero
        x, y = 0, 0
        with lock:
            x, y = move_amount
            move_amount = [0, 0]

        if mode == SPEED:
            if events_per_step[LEFT] != 0 and count % events_per_step[LEFT] == 0:
                x += motion_dir[LEFT]
            if events_per_step[RIGHT] != 0 and count % events_per_step[RIGHT] == 0:
                y += motion_dir[RIGHT]

        if x or y:
            lathe.move(x, y)
        
    knobs.init_knobs()
    knobs.set_knob_callback(knobs.LEFT_MOVE, move_l)
    knobs.set_knob_callback(knobs.RIGHT_MOVE, move_r)
    knobs.set_knob_callback(knobs.LEFT_BUTTON, button_l)
    knobs.set_knob_callback(knobs.RIGHT_BUTTON, button_r)

    s = scheduler.scheduler(period)
    s.run(scheduler.FOREVER, timer_func)


if __name__ == '__main__':

    parser = argparse.ArgumentParser()
    parser.add_argument('--speed', type=float, help='steps per second', default=500)
    subparsers = parser.add_subparsers(help='commands', dest='command')

    knobs_args = subparsers.add_parser('knobs', help='knobs help')

    draw_args = subparsers.add_parser('draw', help='draw help')
    draw_args.add_argument('coords', type=int, help='coordinates', nargs=argparse.REMAINDER)

    move_args = subparsers.add_parser('move', help='move help')
    move_args.add_argument('x', type=int, help='x coordinate')
    move_args.add_argument('y', type=int, help='y coordinate')
    
    move_args = subparsers.add_parser('circle', help='circle help')
    move_args.add_argument('r', type=int, help='radius')
    
    carve_args = subparsers.add_parser('carve', help='carve help')
    
    args = parser.parse_args()
    if not args.command:
        args.command = 'knobs'

    l = Lathe(steps_per_second=args.speed)
    l.enable()

    if args.command == 'knobs':
        run_with_knobs(l)
    elif args.command == 'move':
        l.move(args.x, args.y)
    elif args.command == 'draw':
        coords = pairs(args.coords)
        for x, y in coords:
            print(x, y)
            l.moveto(x, y)
    elif args.command == 'test':
        halfwidth = 200
        contour = lambda x: x*x / halfwidth # parabola
        l.carve_contour(contour, -halfwidth, halfwidth, halfwidth, -halfwidth)
        # contour = lambda x: (x*x*x + 50*x*x) / (halfwidth*halfwidth)
        # l.carve_contour(contour, -75, 10, 15, -5)
