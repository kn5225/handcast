import random as r
import time
import sys
import os

sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))
from drivers.hardware_input import get_hardware_choice

pokemon_types=["Normal" , "Fire" , "Water" ,  "Electric" , "Grass" , "Ice" , "Fighting" , "Poison" , "Ground" , "Flying" ,
       "Psychic" , "Bug" , "Rock" , "Ghost" , "Dragon" , "Dark" , "Steel" , "Fairy"]
pokemon_list=["Rattata" , "Charmander" , "Squirtle" , "Pikachu" , "Bulbasaur" , "Snover" , "Hitmonlee" , "Muk" , "Dugtrio" , 
             "Pidgey" , "Psyduck" , "Butterfree" , "Geodude" , "Gastly" , "Sableye" , "Gibble" , "Aron" , "Clefairy"]                            
pokemon_moves = ["Tackle" , "Ember" , "Bubble" , "Thunder Shock" ,"Vine Whip" , "Icy Wind" , "Rolling Kick" , "Toxin" ,
         "Earthquake" , "Aerial Ace" , "Psybeam" ,"Bug Bite" , "Rock Smash" , "Shadow Claw" ,"Night Slash" , "Dragon Claw" ,
         "Metal Claw" , "Fairy Wind"]   

# --- RESTORED ORIGINAL RANDOM HP GENERATION ---
ph = ph1 = r.randrange(100, 200, 10)

class Pokemon:
    def __init__(self, type_index):
        self.name=pokemon_list[type_index]
        self.type_name=pokemon_types[type_index]
        self.HP=ph1
        self.type_index=type_index
    def change_hp(self, d):
        self.HP+=d
    def display_hp(self):
        print(f"{self.name} has {self.HP} HP")

Pokemon1=Pokemon(r.randint(0,17))
Pokemon2=Pokemon(r.randint(0,17))
pokemove2=pokemon_moves[Pokemon2.type_index]
posmoves=[(Pokemon1.type_name + i) for i in [" Spin"," Punch"," Bite"," Slam"]] 

print("Your Pokemon is", Pokemon1.name)
print("You have encountered", Pokemon2.name)                 

t = 0
lose = 0
movepp = [5,5,5,5]

while (t<20 and Pokemon2.HP>0) or (t<10 and Pokemon1.HP>0):
    Wrongchoice=0
    Pokemon1.display_hp()
    Pokemon2.display_hp()
    time.sleep(1)
    
    if Pokemon2.HP>0:
        event = get_hardware_choice(4, "What would you like to do?\n 1: Attack\n 2: Bag \n 3: PokeBall \n 4: Run")
        
        if event=="1":
            pm3=[(f" {i+1}: {posmoves[i]} (PP {movepp[i]})") for i in range(0,4)]
            prompt = "Which move would you like to use?\n" + "\n".join(pm3)
            move = int(get_hardware_choice(4, prompt))
            
            move2=movepp[move-1]
            if move<5:
                if move2>0:
                    print("You used",posmoves[move-1])
                    movepp[move-1]=move2-1
                    time.sleep(1)
                else:
                    print("You don't have enough PP for that move")
                    Wrongchoice=1
            else:
                Wrongchoice=1  
            if Wrongchoice!=1: 
                d1=10+(5*move)
                if Pokemon2.HP>=d1:
                    Pokemon2.change_hp(-d1)
                    print(f"You did {d1} damage!!")
                else:
                    Pokemon2.HP=0
                    print(f"You did {Pokemon2.HP} damage!!")
        elif event=="2":
            item = get_hardware_choice(2, "Which item would you like to use? \n 1: Potion \n 2: Full Restore")
            if item=="1":
                if Pokemon1.HP < ph - 10:
                    Pokemon1.change_hp(10)
                    print("The Potion healed 10 HP")
                elif Pokemon1.HP == ph:
                    print("This item cannot be used")
                    Wrongchoice=1
                else:
                    healed_amount = ph - Pokemon1.HP
                    Pokemon1.HP = ph
                    print(f"The Potion healed {healed_amount} HP")
            elif item=="2": 
                if Pokemon1.HP == ph:
                    print("This item cannot be used")
                    Wrongchoice=1
                else:
                    Pokemon1.HP = ph
                    print(f"The Full Restore healed {Pokemon1.name} to full HP")
            else:
                Wrongchoice=1
        elif event=="3":
            pokeball = get_hardware_choice(3, "Which pokeball would you like to use? \n 1: Regular \n 2: Great \n 3: Ultra")
            print("You threw a ball")
            if Pokemon2.HP < 40:
                print("You caught ", Pokemon2.name, "!!")
                break
            else:
                print(Pokemon2.name +" Escaped!!")
        elif event=="4":
            lose=1
            print("You ran away!!")
            break
            
        if Pokemon2.HP!=0 and event!="4" and Wrongchoice!=1:
            time.sleep(1)
            print(Pokemon2.name,"used ",pokemove2)
            Pokemon1.change_hp(-20)
            if Pokemon1.HP<=0:
                lose=1
                break
            t += 1
            
if lose==1:
    print("You lose!!")
else:
    print ("You win!!")
