local keys = require("tauer.animated-dialogue.services.translations.enums.translationKey")

return {
    [keys.modName] = "Animated Dialogue",
    [keys.cameraPage] = "Camera",
    [keys.npcPage] = "NPCs",
    [keys.positionCategory] = "Position",
    [keys.rotationCategory] = "Rotation",
    [keys.timingCategory] = "Timing",
    [keys.distance] = "Distance",
    [keys.distanceDescription] =
    "The minimum distance the camera maintains from the NPC's head during dialogue. If standing closer than this, the camera will pull back.",
    [keys.horizontalOffset] = "Horizontal Offset",
    [keys.horizontalOffsetDescription] = "Shifts the camera left or right relative to the NPC. Negative values move left, positive values move right.",
    [keys.verticalOffset] = "Vertical Offset",
    [keys.verticalOffsetDescription] = "Shifts the camera up or down relative to the NPC's head. Negative values move down, positive values move up.",
    [keys.pitchOffset] = "Pitch",
    [keys.pitchOffsetDescription] = "Tilts the camera up or down relative to the NPC's head. Positive values look down, negative values look up.",
    [keys.yawOffset] = "Yaw",
    [keys.yawOffsetDescription] = "Rotates the camera left or right relative to the NPC's head. Positive values shift the NPC left in frame, negative values shift right.",
    [keys.rollOffset] = "Roll",
    [keys.rollOffsetDescription] = "Rolls the camera around the look direction. Positive values tilt clockwise, negative values tilt counter-clockwise.",
    [keys.animationDuration] = "Duration",
    [keys.animationDurationDescription] = "How long the camera zoom animation takes, in seconds.",
    [keys.turnDuration] = "Turn Duration",
    [keys.turnDurationDescription] = "How long the NPC takes to turn and face the player when dialogue starts, in seconds.",
}
