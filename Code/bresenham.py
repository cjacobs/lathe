#!/usr/bin/env python3

#
# Bresenham's algorithm
#

X_AXIS = 'x'
Y_AXIS = 'y'

def line_gen(dx, dy, allow_diagonals=False):
    '''Generate single-pixel increments to move in a straight line using Bresenham's algorithm'''
    if dx == 0 and dy == 0:
        return

    dir_x = 1 if dx > 0 else -1
    dir_y = 1 if dy > 0 else -1
    dx = abs(dx)
    dy = abs(dy)

    major_axis = True
    major_dist = max(dx, dy)
    minor_dist = min(dx, dy)
    if dx >= dy:
        major_dist = dx
        major_dir = dir_x
        major_axis = True
        minor_dist = dy
        minor_dir = dir_y
    else:
        major_dist = dy
        major_dir = dir_y
        major_axis = False
        minor_dist = dx
        minor_dir = dir_x

    err = 0
    for i in range(major_dist):
        err -= minor_dist

        minor_amt = 0
        if err < 0:
            err += major_dist
            minor_amt = minor_dir

        if allow_diagonals:
            if major_axis:
                yield (major_dir, minor_amt)
            else:
                yield (minor_amt, major_dir)
        else:
            if major_axis:
                yield (major_dir, 0)
                if minor_amt:
                    yield(0, minor_amt)
            else:
                yield (0, major_dir)
                if minor_amt:
                    yield(minor_amt, 0)
