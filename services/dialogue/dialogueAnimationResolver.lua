---@class dialogueAnimationResolver : initializedService
local this = {}

---@private
---@type eventHandlers
this.eventHandlers = nil

---@private
---@type eventRegistrar
this.eventRegistrar = nil

---@private
---@type tes3reference
this.npc = nil

---@private
---@type mwseLogger
this.logger = mwse.Logger.new()

---@public
---@param services serviceCollection
---@return boolean,string|nil
function this.initialize(services)
    this.eventRegistrar = services.eventRegistrar

    local events = services.enums.events

    this.eventHandlers = {
        [events.dialogueStarted] = this.onDialogueStarted,
        [events.dialogueEnded] = this.onDialogueEnded,
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
---@param e dialogueStartedEventData
function this.onDialogueStarted(e)
    this.npc = e.npc
end

---@private
function this.onDialogueEnded()
    this.npc = nil
end

---@private
---@param e infoGetTextEventData
function this.onInfoGetText(e)
    if not this.npc then
        return
    end
end

return this
