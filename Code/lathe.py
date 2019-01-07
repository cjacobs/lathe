#!/usr/bin/env python3

# Stepper motor control with A4988 drivers

import argparse
import fractions
import math
import sys
import time

import RPi.GPIO as gpio # https://pypi.python.org/pypi/RPi.GPIO more info

ENABLE = 4

DIR_Y = 27
STEP_Y = 17

DIR_X = 24
STEP_X = 23

# X: left (-) / right (+)
# Y: forward (-) / back (+)

def pairs(l):
    a = l[0::2]
    b = l[1::2]
    return zip(a,b)

class lathe(object):
    def __init__(self, steps_per_second):
        self.reset()
        self.setup()
        self.disable()
        self.steps_per_second = steps_per_second

    def __del__(self):
        self.disable()
        gpio.cleanup()

    def setup(self):
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
                ## don't add segment if it's going to be empty
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
        if dx == 0 and dy == 0:
            return
        dir_x = 1 if dx > 0 else -1
        dir_y = 1 if dy > 0 else -1
        dx = abs(dx)
        dy = abs(dy)
        dist = math.sqrt(dx*dx + dy*dy)
        gcd = fractions.gcd(max(1, dx), max(1, dy))
        iter = max(1, dx) * max(1, dy) // gcd
        inc_x = dx // gcd
        inc_y = dy // gcd
        step_count = 1
        ix = 0
        iy = 0
        for i in range(iter):
            ix -= dx
            iy -= dy

            while ix < 0 or iy < 0:
                if ix < 0:
                    ix += iter
                    self.step_x(dir_x * 1)
                if iy < 0:
                    iy += iter
                    self.step_y(dir_y * 1)
                
                time.sleep(self.get_wait_time() * (dist/iter))

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
        if self.steps_per_second == 0:
            return 0
        
        return 1.0 / self.steps_per_second

    def pulse(self, pin, count):
        for i in range(count):
            gpio.output(pin, gpio.HIGH)
            gpio.output(pin, gpio.LOW)
            time.sleep(0.00001)


if __name__ == '__main__':

    parser = argparse.ArgumentParser()
    # parser.add_argument('--foo', action='store_true', help='foo help')
    subparsers = parser.add_subparsers(help='commands', dest='command')

    carve_args = subparsers.add_parser('carve', help='carve help')

    draw_args = subparsers.add_parser('draw', help='draw help')
    draw_args.add_argument('coords', type=int, help='coordinates', nargs=argparse.REMAINDER)

    move_args = subparsers.add_parser('move', help='move help')
    move_args.add_argument('x', type=int, help='x coordinate')
    move_args.add_argument('y', type=int, help='y coordinate')
    
    args = parser.parse_args()
    print(args)

    l = lathe(steps_per_second=150)
    if args.command == 'move':
        l.move(args.x, args.y)
    elif args.command == 'draw':
        coords = pairs(args.coords)
        for x, y in coords:
            print(x, y)
            l.moveto(x, y)
    elif args.command == 'carve':
        halfwidth = 50
        contour = lambda x: x*x / halfwidth
        l.carve_contour(contour, -halfwidth, halfwidth, halfwidth, -halfwidth)
        # contour = lambda x: (x*x*x + 50*x*x) / (halfwidth*halfwidth)
        # l.carve_contour(contour, -75, 10, 15, -5)
