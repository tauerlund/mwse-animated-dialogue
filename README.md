# Animated Dialogue (MWSE Lua)

Pre-alpha.

## :beetle: Bugs & Issues:
- [ ] Using vanilla Morrowind animations looks weird. Seems like the position of the parent node is all over the place. Not a problem with my own animations.
- [ ] Lip sync and blinking animation is currently not very robust. Timing is hardcoded based on vanilla heads, so this might cause compatibility issues with head replacers.
- [ ] Lip syncing sometimes not animating properly. Reproducable example: the dialogue when giving Fargoth his ring. ~~Might be related to the fact that the journal updates~~? It also seems to disable lip syncing animations entirely until a new dialogue is initiated.
    - Does not seem to be because of journal update. ~~Maybe due to item removal~~?
    - Not related to item removal. Needs more investigation.
    - Confirmed to be caused by adding an item to NPC. When removing `add additem "ring_keley" 1` from the dialogue the problem disappears.
- [ ] Blinking animation seems unreliable. Sometimes the eyes stay shut for a while after the NPC is done speaking.

## :white_check_mark: Features:
- [ ] Animation
    - [x] Load animations from .nif files and store key frame information
    - [x] Play animations during dialogue mode
    - [x] Play lip sync animations during dialogue mode
    - [x] Play blinking animations during dialogue mode
    - [ ] Pause animations when options menu is opened
    - [ ] Make NPC face player when dialogue starts
    - [ ] Allow for offsetting transforms on specific nodes (e.g. to make head face the player)
    - [ ] Add smooth transitions between animations
- [ ] Camera
    - [ ] Animate camera to smoothly zoom in on the NPC when dialogue starts
- [ ] Configuration
    - [ ] Add support for animation configurations
        - [ ] Play specific animations for specific dialogue options
        - [ ] More?
- [ ] Assets
    - [ ] Idle animations
    - [ ] Talk animations (Consider using the ones from [dynamic-conversations](https://github.com/tauerlund/dynamic-conversations))
- [ ] MCM
    - [ ] Blacklist NPCs
- [ ] V2: Add support for animating multiple NPCs using NodeAnimator
- [ ] V3: Decouple NodeAnimator from menu mode animating and promote to a shared service that can be used in other mods
- [ ] Interop support?