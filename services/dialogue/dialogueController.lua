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

---@private
---@type table<number, boolean>
this.spokenDialogueTypes = {
    [tes3.dialogueType.greeting] = true,
    [tes3.dialogueType.topic]    = true,
    [tes3.dialogueType.service]  = true,
}

---@private
---@type tes3dialogueInfo|nil
this.pendingInfo = nil

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
        [tes3.event.infoGetText] = this.onInfoGetText,
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
    local pendingInfo = this.pendingInfo
    this.pendingInfo = nil

    if not this.settings.enabled then
        return
    end

    local reference = this.resolveNpc()
    if not reference then
        return
    end

    e.element:registerAfter(
        tes3.uiEvent.destroy,
        this.onMenuDialogDestroyed
    )

    ---@type dialogueStartedEventData
    local eventData = {
        actor = reference
    }
    event.trigger(this.events.dialogueStarted, eventData)

    if pendingInfo then
        this.emitDialogueInfo(pendingInfo, reference)
    end
end

---@private
---@param e infoGetTextEventData
function this.onInfoGetText(e)
    if not this.settings.enabled then
        return
    end

    if not this.spokenDialogueTypes[e.info.type] then
        return
    end

    local reference = this.resolveNpc()
    if reference then
        this.emitDialogueInfo(e.info, reference)
        return
    end

    -- The greeting's info is retrieved before the service actor is established
    -- (i.e. before MenuDialog's dialogueStarted). Buffer it until the actor is
    -- known, then flush it in onMenuDialogActivated.
    this.pendingInfo = e.info
end

---@private
---@param info tes3dialogueInfo
---@param actor tes3reference
function this.emitDialogueInfo(info, actor)
    ---@type dialogueInfoEventData
    local eventData = {
        info  = info,
        actor = actor
    }
    event.trigger(this.events.dialogueInfo, eventData)
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
---@return tes3reference|nil
function this.resolveNpc()
    local serviceActor = tes3ui.getServiceActor()

    local reference = serviceActor and serviceActor.reference --[[@as tes3reference|nil]]
    if not reference or not this.isNpc(reference) then
        return nil
    end

    return reference
end

---@private
---@param reference tes3reference
---@return boolean
function this.isNpc(reference)
    return reference.object.objectType == tes3.objectType.actor
end

return this
