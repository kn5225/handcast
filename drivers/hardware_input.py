import serial
import time

try:
    ser = serial.Serial('COM3', 115200, timeout=0.1)
    time.sleep(2) 
except Exception:
    ser = None
    print("[Warning] Hardware not connected. Falling back to keyboard input.")

def get_hardware_choice(max_options, prompt_text):
    print(prompt_text)
    
    if not ser:
        return input("Enter choice manually: ")
        
    current_option = 1
    print(f"-> Current Selection: [{current_option}] (Wave hand to cycle, hold close to select)")
    
    ser.reset_input_buffer()
    
    while True:
        if ser.in_waiting > 0:
            try:
                line = ser.readline().decode('utf-8').strip()
                if line.startswith("DIST:"):
                    distance = float(line.split(":")[1])
                    
                    if 2.0 <= distance <= 12.0:
                        print(f"\n[Confirmed] Selected Option: {current_option}\n")
                        return str(current_option)
                        
                    elif 15.0 < distance <= 30.0:
                        current_option = (current_option % max_options) + 1
                        print(f"-> Current Selection: [{current_option}]", end="\r")
                        time.sleep(0.4) 
                        
            except (ValueError, IndexError):
                pass
        time.sleep(0.01)
