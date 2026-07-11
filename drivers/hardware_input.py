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
    
    ser.reset_input_buffer()
    
    last_cycle_time = 0
    CYCLE_COOLDOWN = 0.6  # Half a second buffer between option jumps
    
    while True:
        if ser.in_waiting > 0:
            try:
                line = ser.readline().decode('utf-8').strip()
                if line.startswith("DIST:"):
                    distance = float(line.split(":")[1])
                    current_time = time.time()
                    
                    # 1. Selection Logic
                    if 2.0 <= distance <= 12.0:
                        print(f"\n[Confirmed] Selected Option: {current_option}\n")
                        
                        # --- THE FIX FOR GHOST SELECTING ---
                        # Force a pause loop right here until you physically move your hand away
                        print("Clear your hand away to continue...", end="\r")
                        consecutive_clears = 0
                        while consecutive_clears < 5:
                            if ser.in_waiting > 0:
                                clear_line = ser.readline().decode('utf-8').strip()
                                if clear_line.startswith("DIST:"):
                                    try:
                                        clear_dist = float(clear_line.split(":")[1])
                                        if clear_dist > 15.0 or clear_dist < 1.0: # 1.0 handles any dropped frames
                                            consecutive_clears += 1
                                        else:
                                            consecutive_clears = 0 # reset if hand is still there
                                    except ValueError:
                                        pass
                            time.sleep(0.01)
                        
                        ser.reset_input_buffer() # flush any backlogged frames
                        return str(current_option)
                        
                    # 2. Cycling Logic (Uses non-blocking cooldown)
                    elif 15.0 < distance <= 30.0:
                        if current_time - last_cycle_time > CYCLE_COOLDOWN:
                            current_option = (current_option % max_options) + 1
                            print(f"-> Current Selection: [{current_option}]     ", end="\r")
                            last_cycle_time = current_time
                            ser.reset_input_buffer() # Clear backlog so it registers real-time position
                            
            except (ValueError, IndexError):
                pass
        time.sleep(0.01)
