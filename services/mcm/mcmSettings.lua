---@class mcmSettings
local this = {}

---@private
this.path = "animated-dialogue"

---@private
this.effectModes = require("tauer.animated-dialogue.services.mcm.pages.enums.effectModes")

---@class settings
this.defaults = {
    enabled = true,
    cameraEnabled = true,
    actorAnimEnabled = true,
    actorNativeAnimEnabled = true,
    creatureAnimEnabled = true,
    actorTalkAnimEnabled = true,
    actorTurnEnabled = true,
    actorHeadMorphAnimEnabled = true,
    actorHeadLookAtEnabled = true,
    propsEnabled = true,
    lightEnabled = true,
    particlesEnabled = true,
    effectsMode = this.effectModes.activeCells,
    effectsCellDistance = 4096,
    precipitationEnabled = true,
    stormsEnabled = true,
    cloudsEnabled = true,
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
    swayEnabled = true,
    swayAmplitude = 0.3,
    swayFrequency = 0.1,
    debuggingEnabled = false,
    debugPauseKey = { keyCode = tes3.scanCode.p },
    debugStepKey = { keyCode = tes3.scanCode.o },
    logLevel = mwse.logLevel.info,
}

---@type settings
this.mcm = mwse.loadConfig(this.path, this.defaults) --[[@as settings]]

---@public
function this.save()
    mwse.saveConfig(this.path, this.mcm)
end

return this
