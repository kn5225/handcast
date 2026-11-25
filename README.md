# HandCast: Gesture-Controlled Interface

HandCast turns hand distance over an ultrasonic sensor into keyboard input. An Arduino Uno reads an HC-SR04 sensor, smooths the reading, and streams it to a PC over USB serial. On the PC, either an AutoHotkey script turns distance zones into key presses in any window, or a Python module turns them into menu selections inside Python programs.

Built in two sprints: July 10, 2026 (4 PM to 11 PM) built the firmware, wiring, and the Python serial module; July 15 to 16, 2026 (9 PM to 1 AM) debugged the AutoHotkey script and tested the whole system.

---

## How it works

```
HC-SR04 ──> Arduino Uno ──USB serial──> PC
            (EMA filter)   "DIST:23.4"   ├─ AutoHotkey: zones -> key presses (any window)
                                          └─ Python: zones -> menu choices (games)
```

**Firmware** (`firmware/handcast.ino`): triggers the sensor, measures the echo with `pulseIn` (30 ms timeout), converts it to centimeters, smooths it with an exponential moving average (alpha = 0.3), and prints `DIST:<cm>` at 115200 baud. A new reading goes out about every 30 ms while a hand is in range, and less often when nothing is in range, because the echo measurement waits for its timeout. The firmware does not detect gestures; all zone logic runs on the PC.

Only one PC driver can use the serial port at a time.

### Global mode: AutoHotkey (`drivers/handcast_parser.ahk`)

Runs in the Windows system tray and sends key presses to whatever window has focus.

| Zone | Distance | Default key |
|---|---|---|
| Close | 5 to 20 cm | `{Space}` |
| Mid | 25 to 40 cm | `{Right}` |
| Far | 45 to 60 cm | `{Down}` |

- On start, three input boxes let you change the key for each zone.
- The script averages the last 5 readings, then requires the hand to stay in a zone for 150 ms before it sends that zone's key. This prevents false triggers when a hand passes through a zone.
- Each zone fires once per entry. Move your hand to another zone, or out of range, to fire again.
- The gaps between zones (20 to 25 cm, 40 to 45 cm) are dead bands that reset all zones.
- Press `Esc` to quit.

### App mode: Python (`drivers/hardware_input.py`)

An importable module. `get_hardware_choice(max_options, prompt_text)` returns the chosen option as a string.

- **Cycle:** hold your hand 15 to 32 cm away to step to the next option (at most once every 0.6 s).
- **Select:** hold your hand 2 to 12 cm away for 3 readings in a row to confirm.
- **Release:** after a selection, move your hand past 15 cm for 8 readings in a row before the next choice starts, so one gesture can't select twice.
- If no board is connected, it falls back to typed keyboard input.

The two examples use it: `examples/poke.py` (a turn-based Pokemon battle) and `examples/tictactoe.py` (two-player tic-tac-toe).

---

## Latency

**Not yet measured.** An earlier version of this README claimed under 50 ms from gesture to key press. That number was a target, not a measurement, and the AutoHotkey driver cannot meet it by design: it waits 150 ms in a zone before sending a key, on top of the averaging delay.

A measurement study is in progress (Thanksgiving break 2026). It will break the delay into stages (sensor and filter, serial transport, PC-side decision, OS) using a 240 fps camera and timestamps, and results will go in `LATENCY.md`.

---

## Hardware

| Part | Notes |
|---|---|
| Arduino Uno (ATmega328P) | Firmware written with the Arduino framework (C++) |
| HC-SR04 ultrasonic sensor | 5 V |
| USB A to B cable | Power and serial |

| Sensor pin | Arduino pin |
|---|---|
| VCC | 5V |
| Trig | D9 |
| Echo | D10 |
| GND | GND |

---

## Setup

### 1. Flash the firmware

1. Open `firmware/handcast.ino` in the Arduino IDE.
2. Select **Tools → Board → Arduino Uno**.
3. Select the board's port under **Tools → Port** and note it (for example `COM5`).
4. Click **Upload**.

### 2. Install dependencies

```bash
pip install pyserial
```

Install [AutoHotkey v2](https://www.autohotkey.com/) for global mode (Windows only).

### 3. Set the COM port

Both drivers are set to `COM5`. If your board uses a different port, change it in:

- `drivers/handcast_parser.ahk`: the `mode COM5:` line and the `\\.\COM5` line
- `drivers/hardware_input.py`: `serial.Serial('COM5', 115200, timeout=0.1)`

### 4. Run global mode

1. Close any serial monitor or Python program using the port.
2. Double-click `drivers/handcast_parser.ahk` and confirm or change the three keys.
3. Focus a window (a YouTube video, a PDF, slides) and move your hand into a zone.

### 5. Run app mode

1. Quit the AutoHotkey script from the system tray to free the port.
2. From the repo root, run:

```bash
python examples/poke.py
# or
python examples/tictactoe.py
```

---

## Project structure

```
handcast/
├── firmware/
│   └── handcast.ino          # Arduino firmware: sensor read, EMA filter, serial output
├── drivers/
│   ├── handcast_parser.ahk   # AutoHotkey v2 global key driver
│   └── hardware_input.py     # Python serial input module
├── examples/
│   ├── poke.py               # Pokemon battle using hardware input
│   └── tictactoe.py          # Tic-tac-toe using hardware input
└── README.md
```

## Tech stack

| Layer | Technology |
|---|---|
| Firmware | C++ (Arduino framework) on ATmega328P |
| Sensor | HC-SR04 |
| PC drivers | AutoHotkey v2, Python 3 with PySerial |
| Link | UART over USB, 115200 baud |
