---@class debugStatusHud : initializedService
local this = {}

---@private
---@type guiBuilder
this.guiBuilder = nil

---@private
---@type settings
this.settings = nil

---@private
---@type translations
this.translations = nil

---@private
---@type translationKey
this.translationKey = nil

---@private
---@type tes3uiElement|nil
this.menu = nil

---@private
---@type tes3uiElement|nil
this.statusLabel = nil

---@public
---@param services serviceCollection
---@return boolean, string|nil
function this.initialize(services)
    this.guiBuilder = services.guiBuilder
    this.settings = services.settings
    this.translations = services.translations
    this.translationKey = services.enums.translationKey

    return true, nil
end

---@public
function this.show()
    if this.menu then
        return
    end

    local guiBuilder = this.guiBuilder
    local translations = this.translations
    local keys = this.translationKey

    local menu = guiBuilder.createMenu({
            id = "AnimatedDialogue:DebugStatusHud",
            fixedFrame = true,
            dragFrame = false,
            modal = false,
        })
        :withFlowDirection(tes3.flowDirection.topToBottom)
        :withAutoSize()
        :withPositionAlign({ x = 0.5, y = 0.04 })
        :build()

    local content = guiBuilder.createBlock({ parent = menu })
        :withFlowDirection(tes3.flowDirection.topToBottom)
        :withAutoSize()
        :withPadding({ all = 8 })
        :build()

    guiBuilder.createLabel({ parent = content })
        :withText(translations.get(keys.debugHudTitle))
        :withColor(tes3ui.getPalette(tes3.palette.headerColor))
        :build()

    guiBuilder.createLabel({ parent = content })
        :withText(translations.get(keys.debugHudPause, { key = this.getKeyName(this.settings.debugPauseKey) }))
        :build()

    guiBuilder.createLabel({ parent = content })
        :withText(translations.get(keys.debugHudStep, { key = this.getKeyName(this.settings.debugStepKey) }))
        :build()

    this.statusLabel = guiBuilder.createLabel({ parent = content })
        :build()

    this.menu = menu
    this.setPaused(false)
end

---@public
function this.hide()
    if not this.menu then
        return
    end

    this.menu:destroy()
    this.menu = nil
    this.statusLabel = nil
end

---@public
---@param paused boolean
function this.setPaused(paused)
    if not this.statusLabel then
        return
    end

    local translations = this.translations
    local keys = this.translationKey

    if paused then
        this.statusLabel.text = translations.get(keys.debugHudStatusPaused)
        this.statusLabel.color = tes3ui.getPalette(tes3.palette.healthColor)
    else
        this.statusLabel.text = translations.get(keys.debugHudStatusRunning)
        this.statusLabel.color = tes3ui.getPalette(tes3.palette.normalColor)
    end

    this.menu:updateLayout()
end

---@private
---@param bind mwseKeyCombo
---@return string
function this.getKeyName(bind)
    return mwse.mcm.getKeyComboName(bind) or "Unbound"
end

return this
