# Stepper motor control with A4988 drivers

import fractions
import math
import sys
import time

import RPi.GPIO as gpio # https://pypi.python.org/pypi/RPi.GPIO more info

DIR_Y = 27
STEP_Y = 17

DIR_X = 24
STEP_X = 23

# X: left (-) / right (+)
# Y: forward (-) / back (+)
class lathe(object):
    def __init__(self):
        self.reset()

    def setup(self):
        gpio.setmode(gpio.BCM)
        gpio.setup(DIR_X, gpio.OUT)
        gpio.setup(STEP_X, gpio.OUT)
        gpio.setup(DIR_Y, gpio.OUT)
        gpio.setup(STEP_Y, gpio.OUT)

    def reset(self):
        self.curr_x = 0
        self.curr_y = 0

    def moveto(self, x, y, steps_per_second):
        dx = x - self.curr_x
        dy = y - self.curr_y
        self.move(dx, dy, steps_per_second)

    def move(self, dx, dy, steps_per_second):
        if dx == 0 and dy == 0:
            return
        dir_x = 1 if dx > 0 else -1
        dir_y = 1 if dy > 0 else -1
        dx = abs(dx)
        dy = abs(dy)
        dist = math.sqrt(dx*dx + dy*dy)
        gcd = fractions.gcd(max(1, dx), max(1, dy))
        iter = max(1, dx) * max(1, dy) // gcd
        print("print dx: {}, dy: {}, gcd: {}, iter: {}, dist: {}".format(dx, dy, gcd, iter, dist))
        wait_time = (dist / iter) / steps_per_second
        inc_x = dy // gcd
        inc_y = dx // gcd
        print("inc_x: {}, inc_y: {}".format(inc_x, inc_y))
        step_count = 1
        ix = inc_x-step_count
        iy = inc_y-step_count
        for i in range(iter):
            if ix >= inc_x:
                ix -= inc_x
                self.step_x(dir_x * step_count)
                print("  xpos: {}".format(self.curr_x))
            if iy >= inc_y:
                iy -= inc_y
                self.step_y(dir_y * step_count)
                print("  ypos: {}".format(self.curr_y))
            
            ix += step_count
            iy += step_count
            
            print("  pos: ({}, {})".format(self.curr_x, self.curr_y))
            time.sleep(wait_time)

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
    
    def pulse(self, pin, count):
        for i in range(count):
            gpio.output(pin, gpio.HIGH)
            gpio.output(pin, gpio.LOW)
            time.sleep(0.00001)


if __name__ == '__main__':
    coords = [int(v) for v in sys.argv[1:]]

    xs = coords[0::2]
    ys = coords[1::2]
    coords = zip(xs, ys)
    l = lathe()
    l.setup()

    for x, y in coords:
        print(x, y)
        l.moveto(x, y, 100.0)

    gpio.cleanup()
