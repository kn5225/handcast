# HandCast — Gesture-Controlled Interface

An extensible embedded input pipeline that translates physical distance metrics into real-time system-wide macros and native application controls using hardware-in-the-loop processing.

> **Development Sprint:** July 10, 2026 (completed in a single 8-hour session)

---

## The 8-hour sprint challenge

HandCast was designed, wired, programmed, and deployed in a single, continuous hack sprint on **July 10, 2026**. The goal was to evaluate how rapidly a fully integrated, low-latency physical-to-digital pipeline could be built from scratch.

By executing the firmware, Python serialization logic, and Windows OS macro drivers as parallel subsystems, the entire ecosystem went from wires on a desk and basic pre-written Python games on a laptop to an optimized, functional interface before the day ended.

---

## What it does

HandCast reads continuous distance data from an ultrasonic sensor and processes it into a stable telemetry stream. The architecture supports two independent operational modes:

1. **Global OS Mode** (`drivers/handcast_parser.ahk`) — Runs as a background Windows service via AutoHotkey. It intercepts the data stream to inject global virtual key codes (`{Space}` and `{Right}`) into the active window, enabling hands-free media playback control, document scrolling, or slide transitions.
2. **Native Application Mode** (`drivers/hardware_input.py`) — An importable Python SDK module. It reads the serial interface directly to handle interactive menu cycling and threshold-based verification within custom software loops.

---

## Technical highlights

- **Sub-50ms pipeline** — Optimized loop execution paths keep end-to-end latency from physical gesture to OS macro dispatch below 50ms.
- **Software-based filtering** — An on-board exponential moving average low-pass filter (α = 0.3) suppresses sensor jitter without extra hardware.
- **Ecosystem architecture** — A modular monorepo keeps microcontroller firmware, OS-level drivers, and SDK integrations synchronized in one version-controlled repo.
- **Buffered non-blocking I/O** — Native file/stream-handling on the host side polls incoming serial bytes without freezing runtime execution loops.

---

## Tech stack

| Layer | Technology |
|---|---|
| Firmware | C++ (Arduino Framework) |
| Hardware | ATmega328P (Arduino Uno), HC-SR04 Ultrasonic Sensor |
| Drivers & Automation | AutoHotkey v2, Python 3 (PySerial) |
| Protocol | UART over USB (115200 baud) |

---

## Project structure

```
handcast/
├── firmware/
│   └── handcast.ino          # Arduino microcontroller firmware
├── drivers/
│   ├── handcast_parser.ahk   # Global Windows OS macro driver
│   └── hardware_input.py     # Native Python serial module/SDK
├── examples/
│   ├── poke.py               # Serial-integrated Pokémon CLI engine
│   └── tictactoe.py          # Serial-integrated Tic-Tac-Toe game
└── README.md                 # System documentation
```

---

## Local setup

### 1. Hardware assembly

Connect the HC-SR04 sensor pins to your Arduino Uno board headers with jumper wires:

| Sensor Pin | Arduino Pin |
|---|---|
| VCC | 5V |
| Trig | Digital Pin 9 |
| Echo | Digital Pin 10 |
| GND | GND |

Connect the Arduino Uno to your PC with a standard USB Type-A to Type-B cable.

### 2. Flash firmware

1. Open `firmware/handcast.ino` in the Arduino IDE.
2. Select your board: **Tools → Board → Arduino Uno**.
3. Select the active COM port: **Tools → Port** (note it, e.g. `COM3`).
4. Click **Upload** to flash the microcontroller.

### 3. Dependencies

Install the serial communication library for Python:

```bash
pip install pyserial
```

Ensure AutoHotkey v2 is installed to run the global macro driver.

### 4. Running Global OS Mode

1. Close all Python game terminals so the COM port is released.
2. Open `drivers/handcast_parser.ahk` and verify the port matches your device:
   ```ahk
   ComPort := "COM3"  ; Match your active Arduino COM port
   ```
3. Double-click `handcast_parser.ahk`. It runs quietly in your Windows system tray.
4. Bring any window into focus (e.g. YouTube or a PDF) and wave your hand over the sensor to trigger spacebar or right-arrow macros.

### 5. Running Native Application Mode

1. Close the AutoHotkey background script from the system tray to release the COM port.
2. Open `drivers/hardware_input.py` and verify the port assignment:
   ```python
   ser = serial.Serial('COM3', 115200, timeout=0.1)
   ```
3. Run one of the pre-integrated games from the root directory:
   ```bash
   python examples/poke.py
   # OR
   python examples/tictactoe.py
   ```
4. Wave your hand over the sensor to cycle menu options, and hold it close to confirm a selection.
