#!/usr/bin/env python3

import argparse
import sys
import time

# Constants
FOREVER = -1

def accurate_sleep(sec):
    start = time.perf_counter()
    end = start + sec
    slop = 1 / (4*1024*1024)
    time.sleep(max(0, sec-slop))
    # time.sleep(max(0, sec))
    while time.perf_counter() < end:
        sleep(0)

class scheduler:
    def __init__(self, period):
        self.period = period
        self.timefunc = time.perf_counter

    def run(self, end, func, *args, yield_func=None):
        self.stop = False
        if not yield_func:
            yield_func = time.sleep # time.sleep appears to be more accurate than accurate_sleep. Sigh.
            # yield_func = accurate_sleep
    
        count = 0
        g = self.get_timer(self.period)
        while (count < end or end < 0) and not self.stop:
            func(count, *args)
            count, nexttime, delay = next(g)
            tick = delay / 8 # ?
            while self.timefunc() < nexttime:
                yield_func(delay)
    
    def stop(self):
        self.stop = True

    def get_timer(self, period):
        def schedule_generator(period):
            start = self.timefunc()
            count = 0
            while True:
                count += 1
                now = self.timefunc()
                delay = max(start + count*period - now, 0)
                yield count, start + count*period, delay

        g = schedule_generator(period)
        return g

if __name__ == '__main__':
    def test(period, end):
        s = scheduler(period)
        curr_count = 0
        def count(x):
            nonlocal curr_count
            curr_count += 1
        
        start = time.perf_counter()
        s.run(end, count)
        end = time.perf_counter()
        real_speed = curr_count / (end-start)
        real_speed_err = real_speed / (1/period)
        print("Total time: {}, total steps: {}, steps/s: {}, factor: {}".format(end-start, curr_count, real_speed, real_speed_err))


    parser = argparse.ArgumentParser()
    parser.add_argument('--speed', type=float, help='steps per second', default=500)
    args = parser.parse_args()
    period = 1 / args.speed
    end = int(1 / period)
    test(period, end)
