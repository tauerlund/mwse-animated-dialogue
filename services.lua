---@class serviceCollection
local this = {
    eventLogger = require("tauer.animated-dialogue.services.events.eventLogger"),
    eventRegistrar = require("tauer.animated-dialogue.services.events.eventRegistrar"),

    dialogueActivator = require("tauer.animated-dialogue.services.dialogue.dialogueActivator"),
    dialogueAnimationResolver = require("tauer.animated-dialogue.services.dialogue.dialogueAnimationResolver"),

    renderingController = require("tauer.animated-dialogue.services.rendering.renderingController"),

    npcAnimator = require("tauer.animated-dialogue.services.npcs.npcAnimator"),

    cameraController = require("tauer.animated-dialogue.services.camera.cameraController"),
    cameraStartAnimator = require("tauer.animated-dialogue.services.camera.animators.startAnimator"),
    cameraSwayAnimator = require("tauer.animated-dialogue.services.camera.animators.swayAnimator"),

    mcmInitializer = require("tauer.animated-dialogue.services.mcm.mcmInitializer"),
    mcmSettings = require("tauer.animated-dialogue.services.mcm.mcmSettings"),
    settings = require("tauer.animated-dialogue.services.mcm.mcmSettings").mcm,

    translations = require("tauer.animated-dialogue.services.translations.translations"),

    ---@class enums
    enums = {
        events = require("tauer.animated-dialogue.services.events.enums.events"),
        translationKey = require("tauer.animated-dialogue.services.translations.enums.translationKey"),
    }
}

---@public
---@return service[]
function this.unnamedServices()
    return { this.enums, this.settings }
end

return this
