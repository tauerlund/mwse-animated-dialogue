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
}
