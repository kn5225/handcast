import time
import sys
import os

sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))
from drivers.hardware_input import get_hardware_choice

tuplist=[(0,1,2),(3,4,5),(6,7,8),(0,3,6),(1,4,7),(2,5,8),(0,4,8),(2,4,6)]
ticlist=[" "," "," "," "," "," "," "," "," ",]
turns=0
play1win=0
play2win=0

def ticboard():
    print("\n")
    print (ticlist[0],ticlist[1],ticlist[2],sep=" | ")
    print("----------")
    print (ticlist[3],ticlist[4],ticlist[5],sep=" | ")
    print("----------")
    print (ticlist[6],ticlist[7],ticlist[8],sep=" | ")
    print("\n")

while turns < 5:  # Changed to 5 because each iteration processes a turn pair
    ticboard()
    
    # --- PLAYER 1 TURN WITH VALIDATION ---
    while True:
        move = int(get_hardware_choice(9, "Player 1 (X): Select grid position (1-9)"))
        if ticlist[move-1] == " ":
            ticlist[move-1] = 'X'
            break
        else:
            print("That space is already occupied! Try again.")
            time.sleep(1)
            
    ticboard()
    
    for i in tuplist:
        if ticlist[i[0]]==ticlist[i[1]]==ticlist[i[2]]!=" ":
            play1win=1
    if play1win==1 or turns==4: # If turns == 4 on Player 1's 5th move, board is full
        break
        
    # --- PLAYER 2 TURN WITH VALIDATION ---
    while True:
        move = int(get_hardware_choice(9, "Player 2 (O): Select grid position (1-9)"))
        if ticlist[move-1] == " ":
            ticlist[move-1] = 'O'
            break
        else:
            print("That space is already occupied! Try again.")
            time.sleep(1)
    
    for i in tuplist:
        if ticlist[i[0]]==ticlist[i[1]]==ticlist[i[2]]!=" ":
            play2win=1
    if play2win==1:
        break
    turns += 1

if play1win==1:
    print("Player 1 wins!!")
elif play2win==1:
    print("Player 2 wins!!")
else:
    print("It is a draw!")
