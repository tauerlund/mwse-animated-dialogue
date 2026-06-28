---@class mcmSettings
local this = {}

---@private
this.path = "animated-dialogue"

---@private
this.effectModes = require("tauer.animated-dialogue.services.mcm.pages.enums.effectModes")

---@class settings
this.defaults = {
    cameraEnabled = true,
    npcAnimEnabled = true,
    npcTurnEnabled = true,
    npcHeadMorphAnimEnabled = true,
    npcHeadLookAtEnabled = true,
    lightEnabled = true,
    particlesEnabled = true,
    effectsMode = this.effectModes.activeCells,
    effectsCellDistance = 4096,
    precipitationEnabled = true,
    stormsEnabled = true,
    distance = 90,
    horizontalOffset = 40,
    verticalOffset = -15,
    pitchOffset = 5,
    yawOffset = 5,
    rollOffset = 0,
    animationDuration = 1.5,
    turnDuration = 0.7,
    transitionDuration = 0.5,
    dofEnabled = true,
    dofStrength = 3.0,
    swayEnabled = false,
    swayAmplitude = 0.3,
    swayFrequency = 0.1,
}

---@type settings
this.mcm = mwse.loadConfig(this.path, this.defaults) --[[@as settings]]

---@public
function this.save()
    mwse.saveConfig(this.path, this.mcm)
end

return this
