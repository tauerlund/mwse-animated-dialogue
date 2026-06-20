---@class serviceCollection
local this = {
    eventLogger = require("tauer.animated-dialogue.services.events.eventLogger"),
    eventRegistrar = require("tauer.animated-dialogue.services.events.eventRegistrar"),

    dialogueActivator = require("tauer.animated-dialogue.services.dialogue.dialogueActivator"),
    dialogueAnimationResolver = require("tauer.animated-dialogue.services.dialogue.dialogueAnimationResolver"),

    renderingController = require("tauer.animated-dialogue.services.rendering.renderingController"),

    npcAnimator = require("tauer.animated-dialogue.services.npcs.npcAnimator"),

    cameraAnimator = require("tauer.animated-dialogue.services.camera.cameraAnimator"),

    ---@class enums
    enums = {
        events = require("tauer.animated-dialogue.services.events.enums.events"),
    }
}

---@public
---@return service[]
function this.unnamedServices()
    return { this.enums }
end

return this
