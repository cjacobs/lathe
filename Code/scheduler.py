#!/usr/bin/env python3

import argparse
import sys
import threading
import time
import sched


go = False
def stop():
    global go
    go = False
    
def do_every(period, end, func, *args):
    global go
    go = True
    timefunc = time.perf_counter
    
    count = 0
    def g_tick():
        nonlocal count
        start = timefunc()
        while True:
            count += 1
            now = timefunc()
            delay = max(start + count*period - now, 0)
            yield start + count*period, delay
    g = g_tick()

    while (count < end or end < 0) and go:
        nexttime, delay = next(g)
        # while timefunc() < nexttime:
            # TODO: yield work
            # time.sleep(tick)
        time.sleep(delay)
        func(*args)


def test(period):
    n = 0
    def count():
        nonlocal n
        n += 1
    
    start = time.perf_counter()
    do_every(period, int(1/period), count)
    end = time.perf_counter()
    print("Total time: {}, total steps: {}, steps/s: {}".format(end-start, n, n / (end-start)))

