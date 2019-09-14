# null implementation of RPi.GPIO module

BCM = 0

IN = 0
OUT = 1

LOW = 0
HIGH = 1

PUD_UP = 0
PUD_DOWN = 1

BOTH = 2

def setmode(mode):
    pass

def setup(pin, mode, *args, **kwargs):
    pass

def output(pin, value):
    pass

def cleanup():
    pass

def setwarnings(*args):
    pass

def add_event_detect(*args, **kwargs):
    pass

def add_event_callback(*args, **kwargs):
    pass
