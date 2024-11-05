# Magical Quest 2 Practice Hack
A practice oriented romhack for Magical Quest 2 speedruns.
It has features such as reloading/advancing through rooms, level warp menu on pause, and more. See below for full feature list.

## How to patch

- Apply the .ips patch to your vanilla Magical Quest 2 (U) ROM with the included Lunar IPS program. 
- Enjoy.

## Features

#### **Disclaimer:** Support for Normal mode, Hard mode or 2-Player routes is not yet implemented.

- When entering a level/room, the game will set the appropriate values for RNG, number of hearts, active costume and similar, to reflect what the route for the speedrun should have in that room.

- Pause the game to access the Warp menu. Select the stage with the D-Pad and press any face button (ABXY) to warp to it.

- Lives are no longer deducted on death.

- At any point in the stage, press SELECT to reload the current room you're in.

- If holding the X button, press D-PAD Left or Right to go to the previous or next room respectively (this wraps around, so going to the previous room while in the first room of a stage will put you at the boss room).


## Known Issues

- The warp menu will not display in the dark room of stage 3 due to conflicts with HDMA (still works, but invisible)
  
- Warping to another level can sometimes play a crackling sound effect.

- Warping to another level during a boss may not set the proper music for the selected level.
