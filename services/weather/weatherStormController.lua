---@class weatherStormController : initializedService
local this = {}

---@private
---@type settings
this.settings = nil

---@private
---@type eventRegistrar
this.eventRegistrar = nil

---@private
---@type particleResolver
this.particleResolver = nil

---@private
---@type particleAnimator
this.particleAnimator = nil

---@private
---@type eventHandlerGroups
this.eventHandlers = {
    lifetime = {},
    dialogue = {}
}

---@private
---@type dialogueState
this.dialogueState = nil

---@private
---@type niParticleSystemController[]
this.stormControllers = {}

---@public
---@param services serviceCollection
---@return boolean,string|nil
function this.initialize(services)
    this.eventRegistrar     = services.eventRegistrar
    this.settings           = services.settings
    this.particleResolver   = services.particleResolver
    this.particleAnimator   = services.particleAnimator

    local events            = services.constants.events

    this.eventHandlers      = {
        lifetime = {
            [events.dialogueStarted] = this.onDialogueStarted,
            [events.dialogueEnded]   = this.onDialogueEnded,
        },
        dialogue = {
            [tes3.event.enterFrame] = this.onEnterFrame,
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
---@param e dialogueStartedEventData
function this.onDialogueStarted(e)
    if not this.settings.stormsEnabled then
        return
    end

    local weatherController = tes3.worldController.weatherController

    local stormControllers = this.particleResolver.resolve(weatherController.sceneStormRoot)
    if #stormControllers == 0 then
        return
    end

    this.stormControllers = stormControllers
    this.dialogueState = e.dialogueState

    this.eventRegistrar.register(this.eventHandlers.dialogue)
end

---@private
function this.onDialogueEnded()
    this.eventRegistrar.unregister(this.eventHandlers.dialogue)
    this.stormControllers = {}
    this.dialogueState = nil
end

---@private
---@param e enterFrameEventData
function this.onEnterFrame(e)
    if this.dialogueState.paused then
        return
    end

    this.particleAnimator.update(this.stormControllers, e.delta)
end

return this
