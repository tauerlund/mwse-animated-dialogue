---@class weatherStormController : initializedService
local this = {}

---@private
---@type settings
this.settings = nil

---@private
---@type eventRegistrar
this.eventRegistrar = nil

---@private
---@type particleController
this.particleController = nil

---@private
---@type eventHandlerGroups
this.eventHandlers = {
    lifetime = {},
    dialogue = {}
}

---@private
---@type boolean
this.paused = false

---@private
---@type niParticleSystemController[]
this.stormControllers = {}

---@public
---@param services serviceCollection
---@return boolean,string|nil
function this.initialize(services)
    this.eventRegistrar     = services.eventRegistrar
    this.settings           = services.settings
    this.particleController = services.particleController

    local events            = services.enums.events

    this.eventHandlers      = {
        lifetime = {
            [events.dialogueStarted] = this.onDialogueStarted,
            [events.dialogueEnded]   = this.onDialogueEnded,
        },
        dialogue = {
            [tes3.event.enterFrame] = this.onEnterFrame,
            [events.gamePaused]     = this.onGamePaused,
            [events.gameUnpaused]   = this.onGameUnpaused,
        }
    }

    this.eventRegistrar.register(this.eventHandlers.lifetime)

    return true, nil
end

---@public
function this.uninitialize()
    this.eventRegistrar.unregister(this.eventHandlers.lifetime)
end

---@private
---@param _ dialogueStartedEventData
function this.onDialogueStarted(_)
    if not this.settings.stormsEnabled then
        return
    end

    local weatherController = tes3.worldController and tes3.worldController.weatherController
    if not weatherController then
        return
    end

    local stormControllers = this.particleController.resolve(weatherController.sceneStormRoot)
    if #stormControllers == 0 then
        return
    end

    this.stormControllers = stormControllers
    this.paused = false

    this.eventRegistrar.register(this.eventHandlers.dialogue)
end

---@private
function this.onGamePaused()
    this.paused = true
end

---@private
function this.onGameUnpaused()
    this.paused = false
end

---@private
function this.onDialogueEnded()
    this.eventRegistrar.unregister(this.eventHandlers.dialogue)
    this.stormControllers = {}
end

---@private
---@param e enterFrameEventData
function this.onEnterFrame(e)
    if this.paused then
        return
    end

    this.particleController.update(this.stormControllers, e.delta)
end

return this
