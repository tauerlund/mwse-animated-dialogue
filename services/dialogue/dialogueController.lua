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
---@type { info: tes3dialogueInfo, text: string }|nil
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

    local settings = this.settings

    if not settings.enabled then
        return
    end

    local reference = this.resolveActor()
    if not reference then
        return
    end

    if this.isBlacklisted(reference) then
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
        this.triggerDialogueInfo(pendingInfo.info, pendingInfo.text, reference)
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

    local text = e.text or e:loadOriginalText()
    e.text = text

    local reference = this.resolveActor()
    if reference then
        if this.isBlacklisted(reference) then
            return
        end

        this.triggerDialogueInfo(e.info, text, reference)
        return
    end

    this.pendingInfo = { info = e.info, text = text }
end

---@private
---@param info tes3dialogueInfo
---@param text string
---@param actor tes3reference
function this.triggerDialogueInfo(info, text, actor)
    ---@type dialogueInfoEventData
    local eventData = {
        info  = info,
        text  = text,
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
function this.resolveActor()
    local serviceActor = tes3ui.getServiceActor()

    local reference = serviceActor and serviceActor.reference --[[@as tes3reference|nil]]
    if not reference or not this.isActor(reference) then
        return nil
    end

    return reference
end

---@private
---@param reference tes3reference
---@return boolean
function this.isBlacklisted(reference)
    return this.settings.blacklistedActors[reference.baseObject.id:lower()] == true
end

---@private
---@param reference tes3reference
---@return boolean
function this.isActor(reference)
    local objectType = reference.object.objectType
    return objectType == tes3.objectType.npc
        or objectType == tes3.objectType.creature
end

return this
