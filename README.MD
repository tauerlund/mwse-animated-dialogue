![Model](https://github.com/tauerlund/mwse-animated-dialogue/blob/main/header.png)

An MWSE Lua mod that adds cinematic animations to dialogue with NPCs and creatures. Morrowind freezes the world during dialogue; this mod doesn't unpause the game, but it systematically animates things around you instead.

## :link: Dependencies

- [MWSE](https://github.com/MWSE/MWSE)
- [MGE XE](https://www.nexusmods.com/morrowind/mods/41102) or [MGE XE UF](https://www.nexusmods.com/morrowind/mods/57200)

## :white_check_mark: Features

#### Camera

- The camera moves to a custom framing when dialogue starts, with a smooth fly-in.
- Choose from several built-in presets, separately for first and third person.
- Presets are tweakable both live in-game and in the MCM.
- Optional depth of field effect that blurs the background.
- Optional letterbox bars for a cinematic look.
- Optional fill light on the actor you're talking to, so they stay visible in dark places. It can skip itself automatically when you or the actor is already carrying a light.

#### Actor animation

- NPCs and creatures can play custom idle, greeting and talk animations while you talk to them, based on configurable conditions.
- Specific dialogue lines can trigger their own override animations, for things like handing over an item.
- Their head turns to look at you (or the camera).
- Fully compatible with (but doesn't require) Voices of Vvardenfell: NPC mouths sync to the real voice audio when it's installed.
- Falls back to a simulated lipsync system for unvoiced lines, so NPCs still look like they're speaking.
- Unvoiced NPCs can make short generic sounds ("Hmm.", "Ah.") as they talk, so text-only conversations aren't silent. Which sound plays depends on who's speaking and what they're saying, and one never plays over a real voiced line.
- Small idle gestures (glances, weight shifts) can play occasionally to avoid a frozen look during pauses.
- Props (pipes, mugs, books, etc.) can be spawned on different body parts.
- NPCs with their own custom animations (such as from mods like Animated Morrowind) keep playing them instead of being overridden.
- Works on creatures too, not just NPCs.
- Exclude specific NPCs or creatures from all of the above.
- Optionally disable animation entirely for actors in combat.

#### Player animation

- Optionally animate the player as well as the NPC, in third person.
- Pick a specific animation for yourself, or let the mod choose one automatically.
- Player's head can look at the actor being talked to.

#### World effects

- Torch flames, campfires and other particle effects keep animating instead of freezing.
- Flickering and pulsing lights keep working.
- Rain, snow, ash storms and blight storms keep falling.
- Clouds keep drifting across the sky.
- Choose how far these effects apply: just the actor you're talking to, the current cell, or every active cell.

#### Configuration

- Every feature above can be toggled independently in the MCM.
- Debug mode with an in-game tool for previewing animations, triggering specific gestures, tuning camera presets, adjusting prop positions, playing voice lines, and changing the fill light live.

## :wrench: For Modders

Actor animations and voice lines aren't hardcoded — they're driven by JSON config files, so anyone can add or edit them:

- **Base configs** define an actor's idle pose, greeting, talk clips, gestures, and carried props.
- **Override configs** trigger a specific animation and/or prop on a specific dialogue line.
- **Creature configs** map a creature to the idle animation group it should use.
- **Voice configs** define pools of generic sounds for unvoiced NPCs.

Each config can be restricted with conditions, so different actors and situations can use different animations. Conditions cover who the actor is (race, sex, class, faction, disposition and more) and what's going on around them (weather, time of day, indoors or out). Voice configs can additionally match the line itself — keywords in the text, the topic, or whether it's a question. A tutorial on writing your own configs is coming later.

## :beetle: Bugs

See [issues](https://github.com/tauerlund/mwse-animated-dialogue/issues).
