local keys = require("tauer.animated-dialogue.services.translations.enums.translationKey")

return {
    [keys.modName] = "Animated Dialogue",
    [keys.cameraCategory] = "Camera Animation",
    [keys.distance] = "Distance",
    [keys.distanceDescription] =
    "The minimum distance the camera maintains from the NPC's head during dialogue. If standing closer than this, the camera will pull back.",
    [keys.animationDuration] = "Duration",
    [keys.animationDurationDescription] = "How long the camera zoom animation takes, in seconds.",
}
