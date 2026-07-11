import serial
import time

try:
    ser = serial.Serial('COM5', 115200, timeout=0.1)
    time.sleep(2) 
except Exception:
    ser = None
    print("[Warning] Hardware not connected. Falling back to keyboard input.")

def get_hardware_choice(max_options, prompt_text):
    print(prompt_text)
    
    if not ser:
        return input("Enter choice manually: ")
        
    current_option = 1
    
    # Clean the line completely before reading
    ser.reset_input_buffer()
    time.sleep(0.2)
    ser.reset_input_buffer()
    
    print("\n--- DIAGNOSTIC MODE: Move your hand away from the sensor ---")
    
    samples = 0
    while samples < 15:
        if ser.in_waiting > 0:
            try:
                line = ser.readline().decode('utf-8').strip()
                print(f"Raw Hardware Output: {line}")
                samples += 1
            except Exception as e:
                print(f"Error reading line: {e}")
        time.sleep(0.01)
        
    print("----------------------------------------------------------\n")
    return input("Type anything here to close diagnostics: ")
