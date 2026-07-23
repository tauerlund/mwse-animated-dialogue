---@class hudController : initializedService
local this = {}

local MENU_MULTI = "MenuMulti"

---@private
---@type eventRegistrar
this.eventRegistrar = nil

---@private
---@type settings
this.settings = nil

---@private
this.eventHandlers = {
    lifetime = {}
}

---@private
---@type boolean
this.hidden = false

---@private
---@type boolean
this.previousVisible = false

---@public
---@param services serviceCollection
---@return boolean,string|nil
function this.initialize(services)
    this.eventRegistrar = services.eventRegistrar
    this.settings = services.settings

    local events = services.constants.events

    this.eventHandlers = {
        lifetime = {
            [events.dialogueStarted] = this.onDialogueStarted,
            [events.dialogueEnded] = this.onDialogueEnded,
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
function this.onDialogueStarted()
    if not this.settings.hideHudEnabled then
        return
    end

    local menu = tes3ui.findMenu(MENU_MULTI)
    if not menu then
        return
    end

    this.previousVisible = menu.visible
    menu.visible = false
    this.hidden = true
end

---@private
function this.onDialogueEnded()
    if not this.hidden then
        return
    end

    this.hidden = false

    local menu = tes3ui.findMenu(MENU_MULTI)
    if not menu then
        return
    end

    menu.visible = this.previousVisible
end

return this
