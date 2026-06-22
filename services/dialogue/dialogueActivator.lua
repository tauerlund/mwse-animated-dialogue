---@class dialogueActivator : initializedService
local this = {}

---@private
---@type eventHandlers
this.eventHandlers = nil

---@private
---@type eventRegistrar
this.eventRegistrar = nil

---@private
---@type events
this.events = nil

---@public
---@param services serviceCollection
---@return boolean,string|nil
function this.initialize(services)
    this.eventRegistrar = services.eventRegistrar
    this.events = services.enums.events

    this.eventHandlers = {
        [tes3.event.uiActivated] = { this.onUiActivated, { filter = "MenuDialog" } },
    }

    this.eventRegistrar.register(this.eventHandlers)

    return true, nil
end

---@public
function this.uninitialize()
    this.eventRegistrar.register(this.eventHandlers)
end

---@private
---@param e uiActivatedEventData
function this.onUiActivated(e)
    local reference = tes3ui.getServiceActor().reference --[[@as tes3reference]]
    if not this.isNpc(reference) then
        return
    end

    e.element:registerAfter(
        tes3.uiEvent.destroy,
        this.onMenuDialogDestroyed
    )

    ---@type dialogueStartedEventData
    local eventData = {
        npc = reference
    }
    event.trigger(this.events.dialogueStarted, eventData)
end

---@private
function this.onMenuDialogDestroyed()
    event.trigger(this.events.dialogueEnded)
end

---@private
---@param reference tes3reference
---@return boolean
function this.isNpc(reference)
    return reference.object.objectType == tes3.objectType.npc
end

return this
