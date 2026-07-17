---@class mcmSettings
local this = {}

---@private
this.path = "animated-dialogue"

---@private
this.effectModes = require("tauer.animated-dialogue.services.mcm.pages.constants.effectModes")

---@private
this.lookAtModes = require("tauer.animated-dialogue.services.mcm.pages.constants.lookAtModes")

---@private
this.hidePlayerModes = require("tauer.animated-dialogue.services.mcm.pages.constants.hidePlayerModes")

---@class settings
this.defaults = {
    enabled = true,
    blacklistedActors = {},
    cameraEnabled = true,
    actorAnimEnabled = true,
    actorNativeAnimEnabled = true,
    creatureAnimEnabled = true,
    actorTalkAnimEnabled = true,
    actorTalkAnimChance = 0.5,
    actorGreetingEnabled = true,
    actorIdleVariationEnabled = true,
    actorIdleVariationInterval = 10,
    actorTurnEnabled = true,
    actorHeadMorphAnimEnabled = true,
    actorSimulatedVoiceEnabled = true,
    actorSimulatedVoiceSpeed = 1.0,
    actorSimulatedVoiceMaxDuration = 12,
    actorHeadLookAtModeFirstPerson = this.lookAtModes.camera,
    actorHeadLookAtModeThirdPerson = this.lookAtModes.camera,
    actorHeadBobEnabled = true,
    actorHeadBobNodEnabled = true,
    actorHeadBobYawEnabled = true,
    actorHeadBobTiltEnabled = true,
    actorHeadBobAmount = 1.0,
    actorHeadBobSpeed = 1.0,
    actorHeadBobRandomness = 0.4,
    playerAnimEnabled = true,
    playerAnimation = "",
    playerTurnEnabled = true,
    playerHeadLookAtEnabled = true,
    hidePlayerMode = this.hidePlayerModes.firstPerson,
    hideHudEnabled = true,
    propsEnabled = true,
    lightEnabled = true,
    particlesEnabled = true,
    effectsMode = this.effectModes.activeCells,
    effectsCellDistance = 4096,
    precipitationEnabled = true,
    stormsEnabled = true,
    cloudsEnabled = true,
    cameraPresetFirstPerson = "cinematic",
    cameraPresetThirdPerson = "cinematic",
    turnDuration = 0.7,
    transitionDuration = 0.5,
    dofEnabled = true,
    dofStrength = 3.0,
    letterboxEnabled = true,
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
