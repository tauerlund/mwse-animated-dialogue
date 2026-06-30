---@class dialogueController : initializedService
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

---@private
---@type settings
this.settings = nil

---@public
---@param services serviceCollection
---@return boolean,string|nil
function this.initialize(services)
    this.eventRegistrar = services.eventRegistrar
    this.events = services.enums.events
    this.settings = services.settings

    this.eventHandlers = {
        [tes3.event.uiActivated] = {
            { this.onMenuDialogActivated,  { filter = "MenuDialog" } },
            { this.onMenuOptionsActivated, { filter = "MenuOptions" } },
            { this.onMenuConsoleActivated, { filter = "MenuConsole" } },
        },
    }

    this.eventRegistrar.register(this.eventHandlers)

    return true, nil
end

---@public
function this.uninitialize()
    this.eventRegistrar.unregister(this.eventHandlers)
end

---@private
---@param e uiActivatedEventData
function this.onMenuDialogActivated(e)
    if not this.settings.enabled then
        return
    end

    local serviceActor = tes3ui.getServiceActor()

    local reference = serviceActor and serviceActor.reference --[[@as tes3reference]]
    if not reference or not this.isNpc(reference) then
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
---@param e uiActivatedEventData
function this.onMenuOptionsActivated(e)
    e.element:getContentElement():registerAfter(
        tes3.uiEvent.destroy,
        this.onMenuOptionsDestroyed
    )

    event.trigger(this.events.gamePaused)
end

---@private
---@param e uiActivatedEventData
function this.onMenuConsoleActivated(e)
    e.element:registerAfter(
        tes3.uiEvent.update,
        this.onMenuConsoleUpdated
    )

    event.trigger(this.events.gamePaused)
end

---@private
---@param e uiEventEventData
function this.onMenuConsoleUpdated(e)
    if e.source.visible then
        return
    end

    e.source:unregisterAfter(tes3.uiEvent.update, this.onMenuConsoleUpdated)

    event.trigger(this.events.gameUnpaused)
end

---@private
---@param _ uiEventEventData
function this.onMenuOptionsDestroyed(_)
    event.trigger(this.events.gameUnpaused)
end

---@private
---@param _ uiEventEventData
function this.onMenuDialogDestroyed(_)
    event.trigger(this.events.dialogueEnded)
end

---@private
---@param reference tes3reference
---@return boolean
function this.isNpc(reference)
    return reference.object.objectType == tes3.objectType.npc
end

return this
