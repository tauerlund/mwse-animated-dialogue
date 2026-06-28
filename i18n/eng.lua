local keys = require("tauer.animated-dialogue.services.translations.enums.translationKey")

return {
    [keys.modName] = "Animated Dialogue",
    [keys.cameraPage] = "Camera",
    [keys.cameraEnabled] = "Enable Camera Animation",
    [keys.cameraEnabledDescription] = "Enables or disables the camera animation during dialogue.",
    [keys.npcPage] = "NPCs",
    [keys.npcAnimEnabled] = "Enable NPC Animations",
    [keys.npcAnimEnabledDescription] = "Enables or disables NPC body animations during dialogue.",
    [keys.npcTurnEnabled] = "Enable NPC Turning",
    [keys.npcTurnEnabledDescription] = "Enables or disables the NPC turning to face the player when dialogue starts.",
    [keys.npcHeadMorphAnimEnabled] = "Enable Head Morph Animations",
    [keys.npcHeadMorphAnimEnabledDescription] =
    "Enables or disables NPC head morph animations during dialogue. This includes blinking and lip syncing (for voiced dialogue).",
    [keys.npcHeadLookAtEnabled] = "Enable Head Look-At",
    [keys.npcHeadLookAtEnabledDescription] =
    "Enables or disables the NPC's head turning to look at the camera during dialogue.",
    [keys.positionCategory] = "Position",
    [keys.rotationCategory] = "Rotation",
    [keys.timingCategory] = "Timing",
    [keys.distance] = "Distance",
    [keys.distanceDescription] =
    "The minimum distance the camera maintains from the NPC's head during dialogue. If standing closer than this, the camera will pull back.",
    [keys.horizontalOffset] = "Horizontal Offset",
    [keys.horizontalOffsetDescription] =
    "Shifts the camera left or right relative to the NPC. Negative values move left, positive values move right.",
    [keys.verticalOffset] = "Vertical Offset",
    [keys.verticalOffsetDescription] =
    "Shifts the camera up or down relative to the NPC's head. Negative values move down, positive values move up.",
    [keys.pitchOffset] = "Pitch",
    [keys.pitchOffsetDescription] =
    "Tilts the camera up or down relative to the NPC's head. Positive values look down, negative values look up.",
    [keys.yawOffset] = "Yaw",
    [keys.yawOffsetDescription] =
    "Rotates the camera left or right relative to the NPC's head. Positive values shift the NPC left in frame, negative values shift right.",
    [keys.rollOffset] = "Roll",
    [keys.rollOffsetDescription] =
    "Rolls the camera around the look direction. Positive values tilt clockwise, negative values tilt counter-clockwise.",
    [keys.animationDuration] = "Duration",
    [keys.animationDurationDescription] = "How long the camera zoom animation takes, in seconds.",
    [keys.turnDuration] = "Turn Duration",
    [keys.turnDurationDescription] =
    "How long the NPC takes to turn and face the player when dialogue starts, in seconds.",
    [keys.transitionDuration] = "Transition Duration",
    [keys.transitionDurationDescription] =
    "How long the NPC's body takes to ease into the dialogue animation when dialogue starts, in seconds. Set to 0 to snap instantly.",
    [keys.effectsPage] = "Effects",
    [keys.dofCategory] = "Depth of Field",
    [keys.dofEnabled] = "Enable Depth of Field",
    [keys.dofEnabledDescription] =
    "Applies a depth of field effect during dialogue, keeping the NPC in focus while blurring the background.",
    [keys.dofStrength] = "Blur Strength",
    [keys.dofStrengthDescription] = "Controls how strongly out-of-focus areas are blurred.",
    [keys.lightingParticlesCategory] = "Lighting & Particles",
    [keys.lightEnabled] = "Enable Light Animation",
    [keys.lightEnabledDescription] =
    "Keeps flickering and pulsing lights (such as torches, candles, and braziers) animating during dialogue. Without this, they freeze while in menu mode.",
    [keys.particlesEnabled] = "Enable Particle Effects",
    [keys.particlesEnabledDescription] =
    "Keeps particle effects (such as the flame on a held torch) animating during dialogue. Without this, they remain frozen while in menu mode.",
    [keys.effectsMode] = "Animation Mode",
    [keys.effectsModeDescription] =
    "NPC: animates just the NPC's lights and particle effects.\n\nCurrent cell: animates all lights and particle effects in the current cell, including placed world lights, fireplaces, and other actors' torches.\n\nActive cells: like Current cell, but also includes neighboring loaded cells (exteriors). Within the cell distance. May have a bigger performance impact.",
    [keys.effectsModeNpc] = "NPC",
    [keys.effectsModeCurrentCell] = "Current cell",
    [keys.effectsModeActiveCells] = "Active cells",
    [keys.effectsCellDistance] = "Cell Distance",
    [keys.effectsCellDistanceDescription] =
    "In the cell modes, the maximum distance (in game units) a light or particle effect may be from the NPC to be animated. Anything beyond this remains frozen.",
    [keys.weatherPage] = "Weather",
    [keys.precipitationEnabled] = "Enable Precipitation",
    [keys.precipitationEnabledDescription] =
    "Keeps rain and snow falling during dialogue. Without this, precipitation freezes while in menu mode.",
    [keys.stormsEnabled] = "Enable Storms",
    [keys.stormsEnabledDescription] =
    "Keeps ash, blight, and blizzard storms swirling during dialogue. Without this, storms freeze while in menu mode.",
    [keys.swayCategory] = "Sway",
    [keys.swayEnabled] = "Enable Camera Sway",
    [keys.swayEnabledDescription] =
    "Adds a subtle oscillation to the camera during dialogue for a more cinematic, living feel.",
    [keys.swayAmplitude] = "Amplitude",
    [keys.swayAmplitudeDescription] = "How far the camera sways, in degrees. Lower values are more subtle.",
    [keys.swayFrequency] = "Frequency",
    [keys.swayFrequencyDescription] =
    "How fast the camera sways, in cycles per second. Lower values give a slow, breathing-like motion.",
}
