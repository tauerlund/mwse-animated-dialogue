# Animated Dialogue (MWSE Lua)

MWSE Lua mod that enables animations during dialogue in The Elder Scrolls III: Morrowind.

## :link: Dependencies:
- [mwse](https://github.com/MWSE/MWSE)
- [mwse-shared-library](https://github.com/tauerlund/mwse-shared-library)

## :white_check_mark: Features:
- [ ] Animation
    - [x] Load animations from .nif files and play them during dialogue mode
    - [x] Play lip sync animations during dialogue mode
    - [x] Play blinking animations during dialogue mode
    - [x] Pause animations when options menu is opened
    - [x] Make NPC face player when dialogue starts
    - [x] Make NPC head look at player
    - [ ] Add smooth transitions between animations
- [ ] Camera
    - [x] Animate camera to smoothly zoom in on the NPC when dialogue starts
    - [x] Add offset to camera so it does not center on NPC
- [ ] Configuration
    - [ ] Add support for animation configurations
        - [ ] Play specific animations for specific dialogue options
        - [ ] Play specific animations for specific NPCs
        - [ ] Rule-based system for better control over animations
        - [ ] More?
- [ ] Assets
    - [ ] Idle animations
    - [ ] Talk animations (Consider using the ones from [dynamic-conversations](https://github.com/tauerlund/dynamic-conversations))
- [ ] MCM
    - [x] Blacklist NPCs
    - [ ] Animation settings
        - [x] Enable/disable animations
        - [x] Enable/disable only talk animations
        - [x] Enable/disable lip syncing
    - [ ] Camera settings
        - [x] Enable/disable camera animations
        - [x] Set camera offset (centered, left, right etc)
        - [ ] Set camera animation speed
- [ ] V2: Add creature support
    - Works somewhat - tested with Vivec, animations work but lip syncing does not.
- [ ] V3: Add support for animating multiple NPCs using NodeAnimator
- [ ] V4: Decouple NodeAnimator from menu mode animating and promote to a shared service that can be used in other mods
- [ ] Interop support?

## :beetle: Bugs & Issues:
- [ ] Using vanilla Morrowind animations looks weird. Seems like the position of the parent node is all over the place. Not a problem with my own animations.
- [ ] Lip sync and blinking animation is currently not very robust. Timing is hardcoded based on vanilla heads, so this might cause compatibility issues with head replacers.
- [x] Lip syncing sometimes not animating properly. Reproducable example: the dialogue when giving Fargoth his ring. ~~Might be related to the fact that the journal updates~~? It also seems to disable lip syncing animations entirely until a new dialogue is initiated.
    - Does not seem to be because of journal update. ~~Maybe due to item removal~~?
    - Not related to item removal. Needs more investigation.
    - Confirmed to be caused by adding an item to NPC. When removing `additem "ring_keley" 1` from the dialogue the problem disappears.
    - Fixed
- [ ] Camera animation causes sky to become offset. Expected behavior, need to animate the sky along with the camera.
- [ ] Interpolating camera back to its original position when ending dialogue causes unreliable behavior. For now it just snaps back, needs more work.
- [ ] Camera animation only animates position, not rotation, which causes it to look inconsistent depending on the where the camera is pointing when activating dialogue.