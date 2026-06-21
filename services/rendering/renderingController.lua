---@class renderingController : initializedService
local this = {}

---@private
---@type eventRegistrar
this.eventRegistrar = nil

---@private
---@type eventHandlers
this.eventHandlers = nil

---@private
---@type boolean
this.pauseRenderingInMenus = nil

---@public
---@param services serviceCollection
---@return boolean,string|nil
function this.initialize(services)
    this.eventRegistrar = services.eventRegistrar

    local events = services.enums.events

    this.eventHandlers = {
        [events.dialogueStarted] = this.onDialogueStarted,
        [events.dialogueEnded] = this.onDialogueEnded,
    }

    this.eventRegistrar.register(this.eventHandlers)

    return true, nil
end

---@private
---@param _ dialogueStartedEventData
function this.onDialogueStarted(_)
    this.pauseRenderingInMenus = mge.render.pauseRenderingInMenus

    mge.render.pauseRenderingInMenus = false
end

---@private
function this.onDialogueEnded()
    mge.render.pauseRenderingInMenus = this.pauseRenderingInMenus
end

return this
