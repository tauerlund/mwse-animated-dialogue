---@class serviceCollection
local this = {
    eventLogger = require("tauer.animated-dialogue.services.events.eventLogger"),
    eventRegistrar = require("tauer.animated-dialogue.services.events.eventRegistrar"),

    fileLoader = require("tauer.animated-dialogue.services.files.fileLoader"),

    nifLoader = require("tauer.animated-dialogue.services.nif.nifLoader"),
    nodeResolver = require("tauer.animated-dialogue.services.nodes.nodeResolver"),

    animationValidator = require(
        "tauer.animated-dialogue.services.animations.animationValidator"),
    animationDefinitionValidator = require(
        "tauer.animated-dialogue.services.animations.animationDefinitionValidator"),
    animationConditionsValidator = require(
        "tauer.animated-dialogue.services.animations.animationConditionsValidator"),
    animationFilterer = require(
        "tauer.animated-dialogue.services.animations.animationFilterer"),
    animationLoader = require("tauer.animated-dialogue.services.animations.animationLoader"),
    animationResolver = require("tauer.animated-dialogue.services.animations.animationResolver"),

    dialogueController = require("tauer.animated-dialogue.services.dialogue.dialogueController"),
    dialogueCircuitBreaker = require("tauer.animated-dialogue.services.dialogue.dialogueCircuitBreaker"),

    renderingController = require("tauer.animated-dialogue.services.rendering.renderingController"),

    particleResolver = require("tauer.animated-dialogue.services.particles.particleResolver"),
    particleAnimator = require("tauer.animated-dialogue.services.particles.particleAnimator"),
    particleController = require("tauer.animated-dialogue.services.particles.particleController"),

    playerController = require("tauer.animated-dialogue.services.player.playerController"),

    hudController = require("tauer.animated-dialogue.services.hud.hudController"),

    actorController = require("tauer.animated-dialogue.services.actors.actorController"),
    actorPoseBlender = require("tauer.animated-dialogue.services.actors.actorPoseBlender"),
    actorTrackBinder = require("tauer.animated-dialogue.services.actors.actorTrackBinder"),
    actorTurnAnimator = require("tauer.animated-dialogue.services.actors.actorTurnAnimator"),

    headMorphAnimator = require("tauer.animated-dialogue.services.actors.head.animators.headMorphAnimator"),
    headLookAtAnimator = require("tauer.animated-dialogue.services.actors.head.animators.headLookAtAnimator"),
    headBobAnimator = require("tauer.animated-dialogue.services.actors.head.animators.headBobAnimator"),

    lipsyncController = require("tauer.animated-dialogue.services.lipsync.lipsyncController"),

    bodyBonePinner = require("tauer.animated-dialogue.services.actors.body.bodyBonePinner"),
    bodySkeletonTicker = require("tauer.animated-dialogue.services.actors.body.bodySkeletonTicker"),
    clipBodyAnimator = require("tauer.animated-dialogue.services.actors.body.animators.clipBodyAnimator"),
    creatureBodyAnimator = require("tauer.animated-dialogue.services.actors.body.animators.creatureBodyAnimator"),
    overrideBodyAnimator = require("tauer.animated-dialogue.services.actors.body.animators.overrideBodyAnimator"),
    bodyAnimatorSelector = require("tauer.animated-dialogue.services.actors.body.bodyAnimatorSelector"),

    creatureConfigValidator = require("tauer.animated-dialogue.services.actors.creatures.creatureConfigValidator"),
    creatureConfigLoader = require("tauer.animated-dialogue.services.actors.creatures.creatureConfigLoader"),
    creatureAnimationResolver = require("tauer.animated-dialogue.services.actors.creatures.creatureAnimationResolver"),

    cameraPresetValidator = require(
        "tauer.animated-dialogue.services.camera.presets.cameraPresetValidator"),
    cameraPresetFieldValidator = require(
        "tauer.animated-dialogue.services.camera.presets.cameraPresetFieldValidator"),
    cameraPresetLoader = require("tauer.animated-dialogue.services.camera.presets.cameraPresetLoader"),
    cameraPresetResolver = require("tauer.animated-dialogue.services.camera.presets.cameraPresetResolver"),
    cameraController = require("tauer.animated-dialogue.services.camera.cameraController"),
    cameraStartAnimator = require("tauer.animated-dialogue.services.camera.animators.startAnimator"),
    cameraSwayAnimator = require("tauer.animated-dialogue.services.camera.animators.swayAnimator"),

    weatherPrecipitationController = require("tauer.animated-dialogue.services.weather.weatherPrecipitationController"),
    weatherStormController = require("tauer.animated-dialogue.services.weather.weatherStormController"),
    weatherSkyController = require("tauer.animated-dialogue.services.weather.weatherSkyController"),

    lightFlickerController = require("tauer.animated-dialogue.services.lights.lightFlickerController"),
    lightFillController = require("tauer.animated-dialogue.services.lights.lightFillController"),

    mcmInitializer = require("tauer.animated-dialogue.services.mcm.mcmInitializer"),
    mcmSettings = require("tauer.animated-dialogue.services.mcm.mcmSettings"),
    settings = require("tauer.animated-dialogue.services.mcm.mcmSettings").mcm,

    translations = require("tauer.animated-dialogue.services.translations.translations"),

    ruleLoader = require("tauer.animated-dialogue.services.rules.ruleLoader"),

    failureReporter = require("tauer.animated-dialogue.services.failures.failureReporter"),

    values = require("tauer.animated-dialogue.services.values.values"),

    propSpawner = require("tauer.animated-dialogue.services.props.propSpawner"),
    propDefinitionValidator = require(
        "tauer.animated-dialogue.services.props.propDefinitionValidator"),

    guiBuilder = require("tauer.animated-dialogue.services.gui.guiBuilder"),

    debugSliderSection = require("tauer.animated-dialogue.services.debugging.debugSliderSection"),
    debugDropdown = require("tauer.animated-dialogue.services.debugging.debugDropdown"),
    debugSectionBuilder = require("tauer.animated-dialogue.services.debugging.debugSectionBuilder"),
    debugTooltip = require("tauer.animated-dialogue.services.debugging.debugTooltip"),
    debugStatusHud = require("tauer.animated-dialogue.services.debugging.debugStatusHud"),
    baseConfigurationSection = require(
        "tauer.animated-dialogue.services.debugging.sections.baseConfigurationSection"),
    previewAnimationSection = require(
        "tauer.animated-dialogue.services.debugging.sections.previewAnimationSection"),
    triggerOverrideSection = require(
        "tauer.animated-dialogue.services.debugging.sections.triggerOverrideSection"),
    propTransformSection = require("tauer.animated-dialogue.services.debugging.sections.propTransformSection"),
    cameraPresetSection = require("tauer.animated-dialogue.services.debugging.sections.cameraPresetSection"),
    fillLightSection = require("tauer.animated-dialogue.services.debugging.sections.fillLightSection"),
    debugWindow = require("tauer.animated-dialogue.services.debugging.debugWindow"),
    debugController = require("tauer.animated-dialogue.services.debugging.debugController"),

    ---@class constants
    constants = {
        events = require("tauer.animated-dialogue.services.events.constants.events"),
        translationKey = require("tauer.animated-dialogue.services.translations.constants.translationKey"),
        effectModes = require("tauer.animated-dialogue.services.mcm.pages.constants.effectModes"),
        lookAtModes = require("tauer.animated-dialogue.services.mcm.pages.constants.lookAtModes"),
        hidePlayerModes = require("tauer.animated-dialogue.services.mcm.pages.constants.hidePlayerModes"),
        cameraAnchors = require("tauer.animated-dialogue.services.camera.presets.constants.cameraAnchors"),
        cameraPresetRanges = require("tauer.animated-dialogue.services.camera.presets.constants.cameraPresetRanges"),
        fillLightRanges = require("tauer.animated-dialogue.services.lights.constants.fillLightRanges"),
        fillLightModes = require("tauer.animated-dialogue.services.lights.constants.fillLightModes"),
    }
}

---@public
---@return service[]
function this.unnamedServices()
    return { this.constants, this.settings }
end

return this
