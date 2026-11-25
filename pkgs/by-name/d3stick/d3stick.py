"""
Diablo III Virtual Left Stick Daemon for Linux.

Emulates a 360-degree analog stick via /dev/uinput using:
- Keyboard WASD for character movement.
- Mouse wheel / discrete keys for 14-sector radial menu navigation.
- Optional mouse pointer steering when holding a modifier key.
"""

import math
import select
import sys
import time

import evdev
from evdev import AbsInfo, UInput, ecodes as e

# =====================================================================
# CONFIGURATION
# =====================================================================

# 1. Stepped Wheel Navigation Keys (14 sectors)
# Common options: e.KEY_LEFTBRACE, e.KEY_RIGHTBRACE, e.KEY_Q, e.KEY_E, e.KEY_MINUS, e.KEY_EQUAL
KEY_WHEEL_PREV = e.KEY_LEFTBRACE     # Step counter-clockwise (default: '[')
KEY_WHEEL_NEXT = e.KEY_RIGHTBRACE    # Step clockwise (default: ']')

# 2. Mouse Wheel Navigation
ENABLE_MOUSE_WHEEL = True            # 1 scroll tick = exactly 1 menu slot

# 3. Mouse Aim (Analog Pointer Mode)
ENABLE_MOUSE_AIM = True              # Steer stick toward mouse displacement while holding modifier
MOUSE_MODIFIER_KEY = e.KEY_LEFTCTRL  # Modifier key (e.g. e.KEY_LEFTCTRL, e.KEY_LEFTALT, e.KEY_SPACE)
MOUSE_RADIUS = 120                   # Virtual trackpad boundary radius in pixels
MOUSE_DEADZONE = 20                  # Center deadzone threshold in pixels

# 4. Radial Geometry & Base Parameters
STEPS = 14                           # Total radial menu sectors in Diablo III (Kadala / Inventory)
OFFSET = math.pi / STEPS             # Half-step offset (12.857°) for vertical axis alignment
RESET_ON_WASD = False                # Reset wheel position back to default when moving with WASD
RESET_INDEX = 10                     # Default index: 3 = 90° (due East / Right)

MAX_VAL = 32767                      # Maximum analog axis amplitude

# =====================================================================
# VIRTUAL DEVICE INITIALIZATION
# =====================================================================

capabilities = {
    e.EV_ABS: [
        (e.ABS_X, AbsInfo(value=0, min=-MAX_VAL, max=MAX_VAL, fuzz=0, flat=0, resolution=0)),
        (e.ABS_Y, AbsInfo(value=0, min=-MAX_VAL, max=MAX_VAL, fuzz=0, flat=0, resolution=0)),
    ],
    e.EV_KEY: [e.BTN_SOUTH],
}

try:
    vpad = UInput(capabilities, name="D3-Virtual-Stick")
except PermissionError:
    print("\n[!] ERROR: Permission denied on /dev/uinput.")
    print("    Ensure your user is in 'uinput' and 'input' groups, or run with sudo.\n")
    sys.exit(1)

# Detect physical input devices (excluding the virtual stick itself)
keyboards = []
mice = []

for path in evdev.list_devices():
    dev = evdev.InputDevice(path)
    if "D3-Virtual-Stick" in dev.name:
        continue

    caps = dev.capabilities()

    # Detect keyboards
    if e.EV_KEY in caps:
        keys = caps[e.EV_KEY]
        if e.KEY_A in keys and e.KEY_W in keys:
            keyboards.append(dev)

    # Detect mice
    if e.EV_REL in caps:
        rels = caps[e.EV_REL]
        if e.REL_X in rels or e.REL_WHEEL in rels:
            mice.append(dev)

if not keyboards:
    print("[!] ERROR: No compatible keyboard detected!")
    sys.exit(1)

print("=" * 65)
print("D3 Virtual Left Stick Daemon active!")
print("  WASD                     -> Character movement")
if ENABLE_MOUSE_WHEEL:
    print("  Mouse Wheel              -> 1 tick = 1 radial menu slot")
print("  Wheel Keys ([ / ])       -> Step through radial menu")
if ENABLE_MOUSE_AIM:
    print("  Hold [Left Ctrl] + Mouse -> Direct analog pointing")
print("=" * 65)

# =====================================================================
# STATE & HELPER FUNCTIONS
# =====================================================================

wasd = {e.KEY_W: False, e.KEY_A: False, e.KEY_S: False, e.KEY_D: False}
wheel_index = RESET_INDEX
ctrl_pressed = False
cur_mouse_x, cur_mouse_y = 0.0, 0.0


def send_stick(x: float, y: float) -> None:
    """Send target X/Y coordinates to the virtual stick."""
    vpad.write(e.EV_ABS, e.ABS_X, int(x))
    vpad.write(e.EV_ABS, e.ABS_Y, int(y))
    vpad.syn()


def update_wasd() -> None:
    """Calculate and emit analog vector from active WASD keys."""
    global wheel_index

    if RESET_ON_WASD:
        wheel_index = RESET_INDEX

    dx, dy = 0, 0
    if wasd[e.KEY_A]:
        dx -= 1
    if wasd[e.KEY_D]:
        dx += 1
    if wasd[e.KEY_W]:
        dy -= 1  # Linux gamepad Y-axis is negative upwards
    if wasd[e.KEY_S]:
        dy += 1

    if dx == 0 and dy == 0:
        send_stick(0, 0)
    else:
        # Normalize diagonal vector
        length = math.hypot(dx, dy)
        send_stick((dx / length) * MAX_VAL, (dy / length) * MAX_VAL)


def step_wheel(direction: int) -> None:
    """Rotate the radial selector by one sector."""
    global wheel_index
    wheel_index = (wheel_index + direction) % STEPS
    angle = OFFSET + (2 * math.pi / STEPS) * wheel_index
    x = math.sin(angle) * MAX_VAL
    y = -math.cos(angle) * MAX_VAL
    send_stick(x, y)
    print(f"Slot: {wheel_index + 1}/{STEPS} ({int(round(math.degrees(angle)))}°)")


# =====================================================================
# MAIN EVENT LOOP
# =====================================================================

all_devices = keyboards + mice

try:
    while True:
        readable, _, _ = select.select(all_devices, [], [])
        for dev in readable:
            for ev in dev.read():
                # -----------------------------------------------------
                # 1. Mouse Events
                # -----------------------------------------------------
                if ev.type == e.EV_REL:
                    # Scroll wheel stepping
                    if ENABLE_MOUSE_WHEEL and ev.code == e.REL_WHEEL:
                        step_wheel(1 if ev.value < 0 else -1)
                        # Pulse duration (40ms) to ensure engine registers the angle
                        time.sleep(0.04)
                        send_stick(0, 0)

                    # Mouse aim when modifier key is held
                    elif ENABLE_MOUSE_AIM and ctrl_pressed:
                        if ev.code == e.REL_X:
                            cur_mouse_x += ev.value
                        elif ev.code == e.REL_Y:
                            cur_mouse_y += ev.value

                        # Clamp displacement to maximum radius
                        dist = math.hypot(cur_mouse_x, cur_mouse_y)
                        if dist > MOUSE_RADIUS:
                            cur_mouse_x = (cur_mouse_x / dist) * MOUSE_RADIUS
                            cur_mouse_y = (cur_mouse_y / dist) * MOUSE_RADIUS

                        # Send normalized vector if outside deadzone
                        if dist > MOUSE_DEADZONE:
                            nx = (cur_mouse_x / dist) * MAX_VAL
                            ny = (cur_mouse_y / dist) * MAX_VAL
                            send_stick(nx, ny)

                # -----------------------------------------------------
                # 2. Keyboard Events
                # -----------------------------------------------------
                elif ev.type == e.EV_KEY:
                    code, val = ev.code, ev.value

                    # Mouse aim modifier toggle
                    if ENABLE_MOUSE_AIM and code == MOUSE_MODIFIER_KEY:
                        ctrl_pressed = (val != 0)
                        if ctrl_pressed:
                            cur_mouse_x, cur_mouse_y = 0.0, 0.0
                        else:
                            cur_mouse_x, cur_mouse_y = 0.0, 0.0
                            send_stick(0, 0)

                    # Character WASD movement
                    elif not ctrl_pressed and code in wasd:
                        wasd[code] = (val != 0)
                        update_wasd()

                    # Stepped wheel navigation keys
                    elif not ctrl_pressed and code in (KEY_WHEEL_PREV, KEY_WHEEL_NEXT):
                        if val == 1:
                            direction = -1 if code == KEY_WHEEL_PREV else 1
                            step_wheel(direction)
                        elif val == 0:
                            send_stick(0, 0)

except KeyboardInterrupt:
    print("\nShutting down virtual stick daemon...")
    vpad.close()
