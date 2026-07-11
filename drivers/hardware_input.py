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
    print(f"-> Current Selection: [{current_option}] (Wave hand to cycle, hold close to select)")
    
    # Empty out any backlog before reading active gestures
    ser.reset_input_buffer()
    
    last_cycle_time = 0
    CYCLE_COOLDOWN = 0.5  # Time in seconds between item selection jumps
    
    while True:
        if ser.in_waiting > 0:
            try:
                line = ser.readline().decode('utf-8').strip()
                if line.startswith("DIST:"):
                    distance = float(line.split(":")[1])
                    current_time = time.time()
                    
                    # 1. SELECTION ZONE (Hand held tight to sensor)
                    if 2.0 <= distance <= 12.0:
                        print(f"\n[Confirmed] Selected Option: {current_option}\n")
                        
                        # ANTI-DOUBLE-TRIGGER LOOP:
                        # Stalls execution until you pull your hand out of the action zone
                        print("Clear your hand away to continue...", end="\r")
                        consecutive_clears = 0
                        while consecutive_clears < 8:
                            if ser.in_waiting > 0:
                                clear_line = ser.readline().decode('utf-8').strip()
                                if clear_line.startswith("DIST:"):
                                    try:
                                        clear_dist = float(clear_line.split(":")[1])
                                        # If the sensor reads far away or out-of-range (>15), count it as a clear
                                        if clear_dist > 15.0:
                                            consecutive_clears += 1
                                        else:
                                            consecutive_clears = 0 # hand is still there, reset counter
                                    except ValueError:
                                        pass
                            time.sleep(0.01)
                        
                        # Clear old inputs built up during the stall and yield control back to PokeCLI
                        ser.reset_input_buffer()
                        return str(current_option)
                        
                    # 2. CYCLING ZONE (Hand held in mid-air sweet spot)
                    elif 15.0 < distance <= 32.0:
                        if current_time - last_cycle_time > CYCLE_COOLDOWN:
                            current_option = (current_option % max_options) + 1
                            print(f"-> Current Selection: [{current_option}]     ", end="\r")
                            last_cycle_time = current_time
                            ser.reset_input_buffer() # flush buffer to ensure responsive tracking
                            
            except (ValueError, IndexError):
                pass
        time.sleep(0.01)
