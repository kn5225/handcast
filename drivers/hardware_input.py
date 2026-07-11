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
    time.sleep(0.05)            
    ser.reset_input_buffer()    
    if ser.in_waiting > 0:
        ser.readline()          
    ser.reset_input_buffer()
    
    last_cycle_time = 0
    CYCLE_COOLDOWN = 0.6 
    selection_counter = 0 
    
    while True:
        if ser.in_waiting > 0:
            try:
                line = ser.readline().decode('utf-8').strip()
                if line.startswith("DIST:"):
                    distance = float(line.split(":")[1])
                    current_time = time.time()
                    
                    # 1. INTENT-BASED SELECTION ZONE
                    if 2.0 <= distance <= 12.0:
                        selection_counter += 1
                        
                        # Requires 3 consecutive close readings (~100ms hold time) before confirming
                        if selection_counter >= 3:
                            # Print spaces to completely wipe out the carriage return line buffer
                            print("[Confirmed] Selected Option: {}                        ".format(current_option))
                            print("\n")
                            
                            # ANTI-DOUBLE-TRIGGER LOOP
                            print("Clear your hand away to continue...                     ", end="\r")
                            consecutive_clears = 0
                            while consecutive_clears < 8:
                                if ser.in_waiting > 0:
                                    clear_line = ser.readline().decode('utf-8').strip()
                                    if clear_line.startswith("DIST:"):
                                        try:
                                            clear_dist = float(clear_line.split(":")[1])
                                            if clear_dist > 15.0:
                                                consecutive_clears += 1
                                            else:
                                                consecutive_clears = 0
                                        except ValueError:
                                            pass
                                time.sleep(0.01)
                            
                            # Wipe the clearance message cleanly from the command line interface
                            print("                                                        ", end="\r")
                            ser.reset_input_buffer()
                            return str(current_option)
                        
                    # 2. SPEED CYCLING ZONE
                    elif 15.0 < distance <= 32.0:
                        selection_counter = 0 # Broke the selection path, reset confirmation counter
                        if current_time - last_cycle_time > CYCLE_COOLDOWN:
                            current_option = (current_option % max_options) + 1
                            # Added padding spaces to ensure clean menu display overwrites
                            print(f"-> Current Selection: [{current_option}]       ", end="\r")
                            last_cycle_time = current_time
                            ser.reset_input_buffer()
                            
                    else:
                        # Hand is completely out of bounds or out of range, reset tracking
                        selection_counter = 0
                            
            except (ValueError, IndexError):
                pass
        time.sleep(0.01)
