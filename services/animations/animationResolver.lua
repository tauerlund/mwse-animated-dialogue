---@class animationResolver : initializedService
local this = {}

---@private
---@type eventRegistrar
this.eventRegistrar = nil

---@private
---@type animationLoader
this.animationLoader = nil

---@private
---@type events
this.events = nil

---@private
---@type eventHandlers
this.eventHandlers = nil

---@private
---@type baseAnimationConfiguration
this.configuration = nil

---@public
---@param services serviceCollection
---@return boolean, string|nil
function this.initialize(services)
    this.eventRegistrar  = services.eventRegistrar
    this.animationLoader = services.animationLoader
    this.events          = services.enums.events

    this.eventHandlers   = {
        [this.events.dialogueStarted] = this.onDialogueStarted,
        [this.events.dialogueEnded]   = this.onDialogueEnded,
    }

    this.eventRegistrar.register(this.eventHandlers)

    return true, nil
end

---@public
function this.uninitialize()
    this.eventRegistrar.unregister(this.eventHandlers)
end

---@private
---@param e dialogueStartedEventData
function this.onDialogueStarted(e)
    local configuration = this.resolveBaseConfiguration()
    if not configuration or not configuration.idle then
        return
    end

    this.configuration = configuration

    ---@type dialogueAnimationResolvedEventData
    local eventData = {
        npc       = e.npc,
        animation = configuration.idle,
    }

    event.trigger(this.events.dialogueAnimationResolved, eventData)
end

---@private
function this.onDialogueEnded()
    this.configuration = nil
end

---@private
---@return baseAnimationConfiguration|nil
function this.resolveBaseConfiguration()
    local configurations = this.animationLoader.getBaseConfigurations()
    return configurations and configurations[1]
end

return this
