---@class serviceCollection
local this = {
    eventLogger = require("tauer.animated-dialogue.services.events.eventLogger"),
    eventRegistrar = require("tauer.animated-dialogue.services.events.eventRegistrar"),

    fileLoader = require("tauer.animated-dialogue.services.files.fileLoader"),

    nifLoader = require("tauer.animated-dialogue.services.nif.nifLoader"),
    nodeResolver = require("tauer.animated-dialogue.services.nodes.nodeResolver"),

    animationValidator = require(
        "tauer.animated-dialogue.services.animations.animationValidator"),
    animationFilterer = require(
        "tauer.animated-dialogue.services.animations.animationFilterer"),
    animationLoader = require("tauer.animated-dialogue.services.animations.animationLoader"),
    animationResolver = require("tauer.animated-dialogue.services.animations.animationResolver"),

    dialogueController = require("tauer.animated-dialogue.services.dialogue.dialogueController"),

    renderingController = require("tauer.animated-dialogue.services.rendering.renderingController"),

    particleResolver = require("tauer.animated-dialogue.services.particles.particleResolver"),
    particleAnimator = require("tauer.animated-dialogue.services.particles.particleAnimator"),
    particleController = require("tauer.animated-dialogue.services.particles.particleController"),

    playerController = require("tauer.animated-dialogue.services.player.playerController"),

    actorController = require("tauer.animated-dialogue.services.actors.actorController"),
    actorPoseBlender = require("tauer.animated-dialogue.services.actors.actorPoseBlender"),
    actorTrackBinder = require("tauer.animated-dialogue.services.actors.actorTrackBinder"),
    actorTurnAnimator = require("tauer.animated-dialogue.services.actors.actorTurnAnimator"),

    headMorphAnimator = require("tauer.animated-dialogue.services.actors.head.animators.headMorphAnimator"),
    headLookAtAnimator = require("tauer.animated-dialogue.services.actors.head.animators.headLookAtAnimator"),
    headBobAnimator = require("tauer.animated-dialogue.services.actors.head.animators.headBobAnimator"),

    lipsyncController = require("tauer.animated-dialogue.services.lipsync.lipsyncController"),

    bodySkeletonTicker = require("tauer.animated-dialogue.services.actors.body.bodySkeletonTicker"),
    clipBodyAnimator = require("tauer.animated-dialogue.services.actors.body.animators.clipBodyAnimator"),
    creatureBodyAnimator = require("tauer.animated-dialogue.services.actors.body.animators.creatureBodyAnimator"),
    overrideBodyAnimator = require("tauer.animated-dialogue.services.actors.body.animators.overrideBodyAnimator"),
    bodyAnimatorSelector = require("tauer.animated-dialogue.services.actors.body.bodyAnimatorSelector"),

    creatureConfigLoader = require("tauer.animated-dialogue.services.actors.creatures.creatureConfigLoader"),
    creatureAnimationResolver = require("tauer.animated-dialogue.services.actors.creatures.creatureAnimationResolver"),

    cameraPresetLoader = require("tauer.animated-dialogue.services.camera.presets.cameraPresetLoader"),
    cameraPresetResolver = require("tauer.animated-dialogue.services.camera.presets.cameraPresetResolver"),
    cameraController = require("tauer.animated-dialogue.services.camera.cameraController"),
    cameraStartAnimator = require("tauer.animated-dialogue.services.camera.animators.startAnimator"),
    cameraSwayAnimator = require("tauer.animated-dialogue.services.camera.animators.swayAnimator"),

    weatherPrecipitationController = require("tauer.animated-dialogue.services.weather.weatherPrecipitationController"),
    weatherStormController = require("tauer.animated-dialogue.services.weather.weatherStormController"),
    weatherSkyController = require("tauer.animated-dialogue.services.weather.weatherSkyController"),

    lightController = require("tauer.animated-dialogue.services.lights.lightController"),

    mcmInitializer = require("tauer.animated-dialogue.services.mcm.mcmInitializer"),
    mcmSettings = require("tauer.animated-dialogue.services.mcm.mcmSettings"),
    settings = require("tauer.animated-dialogue.services.mcm.mcmSettings").mcm,

    translations = require("tauer.animated-dialogue.services.translations.translations"),

    ruleLoader = require("tauer.animated-dialogue.services.rules.ruleLoader"),

    arrays = require("tauer.animated-dialogue.services.arrays.arrays"),

    propSpawner = require("tauer.animated-dialogue.services.props.propSpawner"),

    guiBuilder = require("tauer.animated-dialogue.services.gui.guiBuilder"),

    debugSliderSection = require("tauer.animated-dialogue.services.debugging.debugSliderSection"),
    debugDropdown = require("tauer.animated-dialogue.services.debugging.debugDropdown"),
    debugSection = require("tauer.animated-dialogue.services.debugging.debugSection"),
    debugStatusHud = require("tauer.animated-dialogue.services.debugging.debugStatusHud"),
    debugAnimationsTab = require("tauer.animated-dialogue.services.debugging.tabs.debugAnimationsTab"),
    debugWindow = require("tauer.animated-dialogue.services.debugging.debugWindow"),
    debugController = require("tauer.animated-dialogue.services.debugging.debugController"),

    ---@class enums
    enums = {
        events = require("tauer.animated-dialogue.services.events.enums.events"),
        translationKey = require("tauer.animated-dialogue.services.translations.enums.translationKey"),
        effectModes = require("tauer.animated-dialogue.services.mcm.pages.enums.effectModes"),
        lookAtModes = require("tauer.animated-dialogue.services.mcm.pages.enums.lookAtModes"),
        hidePlayerModes = require("tauer.animated-dialogue.services.mcm.pages.enums.hidePlayerModes"),
        cameraAnchors = require("tauer.animated-dialogue.services.camera.presets.enums.cameraAnchors"),
    }
}

---@public
---@return service[]
function this.unnamedServices()
    return { this.enums, this.settings }
end

return this
