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
    animationOrchestrator = require(
        "tauer.animated-dialogue.services.animations.animationOrchestrator"),

    dialogueController = require("tauer.animated-dialogue.services.dialogue.dialogueController"),

    renderingController = require("tauer.animated-dialogue.services.rendering.renderingController"),

    particleResolver = require("tauer.animated-dialogue.services.particles.particleResolver"),
    particleAnimator = require("tauer.animated-dialogue.services.particles.particleAnimator"),
    particleController = require("tauer.animated-dialogue.services.particles.particleController"),

    actorController = require("tauer.animated-dialogue.services.actors.actorController"),
    actorPoseBlender = require("tauer.animated-dialogue.services.actors.actorPoseBlender"),
    actorTrackBinder = require("tauer.animated-dialogue.services.actors.actorTrackBinder"),
    actorTurnAnimator = require("tauer.animated-dialogue.services.actors.animators.turnAnimator"),
    actorControllersAnimator = require("tauer.animated-dialogue.services.actors.animators.controllersAnimator"),
    actorHeadMorphAnimator = require("tauer.animated-dialogue.services.actors.animators.headMorphAnimator"),
    actorHeadLookAtAnimator = require("tauer.animated-dialogue.services.actors.animators.headLookAtAnimator"),

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

    debuggingSliderPanel = require("tauer.animated-dialogue.services.debugging.debugSliderPanel"),
    debugController = require("tauer.animated-dialogue.services.debugging.debugController"),

    ---@class enums
    enums = {
        events = require("tauer.animated-dialogue.services.events.enums.events"),
        translationKey = require("tauer.animated-dialogue.services.translations.enums.translationKey"),
        effectModes = require("tauer.animated-dialogue.services.mcm.pages.enums.effectModes"),
    }
}

---@public
---@return service[]
function this.unnamedServices()
    return { this.enums, this.settings }
end

return this
