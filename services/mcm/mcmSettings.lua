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

---@private
this.fillLightModes = require("tauer.animated-dialogue.services.lights.constants.fillLightModes")

---@private
this.mcmMigrator = require("tauer.animated-dialogue.services.mcm.mcmMigrator")

---@class settings
---@field configVersion integer
this.defaults = {
    enabled = true,
    disableInCombat = false,
    limitDialogueDistance = true,
    maxDialogueDistance = 1024,
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
    actorSimulatedVoiceSpeed = 2.5,
    actorSimulatedVoiceMaxDuration = 12,
    actorHeadLookAtModeFirstPerson = this.lookAtModes.camera,
    actorHeadLookAtModeThirdPerson = this.lookAtModes.player,
    actorHeadBobEnabled = true,
    actorHeadBobNodEnabled = true,
    actorHeadBobYawEnabled = true,
    actorHeadBobTiltEnabled = true,
    actorHeadBobAmount = 0.6,
    actorHeadBobSpeed = 1.5,
    actorHeadBobRandomness = 0.8,
    voiceLinesEnabled = true,
    voiceLineChance = 0.35,
    voiceLineInterval = 4,
    voiceLineMinimumDelay = 0.3,
    playerAnimEnabled = true,
    playerAnimation = "",
    playerTurnEnabled = true,
    playerHeadLookAtEnabled = true,
    hidePlayerMode = this.hidePlayerModes.firstPerson,
    hideHudEnabled = true,
    propsEnabled = true,
    flickerEnabled = true,
    particlesEnabled = true,
    fillLightMode = this.fillLightModes.adaptive,
    fillLightBrightness = 0.64,
    fillLightColor = { r = 1.0, g = 0.9, b = 0.75 },
    fillLightRadius = 256,
    fillLightDistance = 64,
    fillLightHeight = -32,
    effectsMode = this.effectModes.activeCells,
    effectsCellDistance = 4096,
    precipitationEnabled = true,
    stormsEnabled = true,
    cloudsEnabled = true,
    cameraPresetFirstPerson = "cinematic",
    cameraPresetThirdPerson = "over-shoulder",
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

---@private
function this.migrateStoredConfig()
    local stored = mwse.loadConfig(this.path)
    if not stored then
        return
    end

    if not this.mcmMigrator.migrate(stored) then
        return
    end

    mwse.saveConfig(this.path, stored)
end

---@private
---@return settings
function this.load()
    this.migrateStoredConfig()

    local config = mwse.loadConfig(this.path, this.defaults) --[[@as settings]]
    config.configVersion = this.mcmMigrator.currentVersion()

    return config
end

---@type settings
this.mcm = this.load()

---@public
function this.save()
    mwse.saveConfig(this.path, this.mcm)
end

return this
