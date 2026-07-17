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
---@type tes3uiElement|nil
this.hiddenMenu = nil

---@private
---@type boolean
this.previousVisible = false

---@public
---@param services serviceCollection
---@return boolean,string|nil
function this.initialize(services)
    this.eventRegistrar = services.eventRegistrar
    this.settings = services.settings

    local events = services.enums.events

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

    this.hiddenMenu = menu
    this.previousVisible = menu.visible
    menu.visible = false
end

---@private
function this.onDialogueEnded()
    if not this.hiddenMenu then
        return
    end

    this.hiddenMenu.visible = this.previousVisible
    this.hiddenMenu = nil
end

return this
