# Animated Dialogue (MWSE Lua)

Pre-alpha.

## :beetle: Bugs & Issues:
- [ ] Using vanilla Morrowind animations looks weird. Seems like the position of the parent node is all over the place. Not a problem with my own animations.
- [ ] Lip sync animation is currently not robust. Timing is hardcoded based on vanilla heads, so this might cause compatibility issues with head replacers.

## :white_check_mark: Features:
- [ ] Animation
    - [x] Load animations from .nif files and store key frame information
    - [x] Play animations during dialogue mode
    - [x] Play lip sync animations during dialogue mode
    - [ ] Play blinking animations during dialogue mode
- [ ] Camera
    - [ ] Animate camera smoothly to zoom in on the NPC before dialogue starts
- [ ] Assets
    - [ ] Idle animations
    - [ ] Talk animations (Consider using the ones from [dynamic-conversations](https://github.com/tauerlund/dynamic-conversations))
- [ ] MCM
- [ ] Interop support?