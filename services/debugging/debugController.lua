---@class debugController : initializedService
local this = {}

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
---@type guiBuilder
this.guiBuilder = nil

---@private
---@type debugSliderPanel
this.debugSliderPanel = nil

---@private
---@type translations
this.translations = nil

---@private
---@type translationKey
this.translationKey = nil

---@private
this.dialogueActive = false

---@private
this.paused = false

---@private
---@type tes3uiElement|nil
this.debugHud = nil

---@private
---@type tes3uiElement|nil
this.statusLabel = nil

---@private
---@type tes3uiElement[]|nil
this.debugPanels = nil

---@private
---@type eventHandlers
this.eventHandlers = nil

---@public
---@param services serviceCollection
---@return boolean, string|nil
function this.initialize(services)
    this.eventRegistrar = services.eventRegistrar
    this.events = services.enums.events
    this.settings = services.settings
    this.guiBuilder = services.guiBuilder
    this.debugSliderPanel = services.debuggingSliderPanel
    this.translations = services.translations
    this.translationKey = services.enums.translationKey

    local events = this.events

    this.eventHandlers = {
        [events.dialogueStarted] = this.onDialogueStarted,
        [events.dialogueEnded]   = this.onDialogueEnded,
        [events.gamePaused]      = this.onGamePaused,
        [events.gameUnpaused]    = this.onGameUnpaused,
        [events.propSpawned]     = this.onPropSpawned,
        [events.propDespawned]   = this.onPropDespawned,
        [tes3.event.keyDown]     = this.onKeyDown,
    }

    this.eventRegistrar.register(this.eventHandlers)

    return true, nil
end

---@public
function this.uninitialize()
    this.eventRegistrar.unregister(this.eventHandlers)
end

---@private
function this.onDialogueStarted()
    this.dialogueActive = true
    this.paused = false

    if this.settings.debuggingEnabled then
        this.showDebugHud()
    end
end

---@private
function this.onDialogueEnded()
    this.dialogueActive = false
    this.paused = false
    this.hideDebugHud()
    this.destroyDebugPanels()
end

---@private
---@param e propSpawnedEventData
function this.onPropSpawned(e)
    if not this.settings.debuggingEnabled then
        return
    end

    this.destroyDebugPanels()
    this.debugPanels = this.debugSliderPanel.createTransformSliders(e.node)
end

---@private
function this.onPropDespawned()
    this.destroyDebugPanels()
end

---@private
function this.destroyDebugPanels()
    if not this.debugPanels then
        return
    end

    for _, panel in ipairs(this.debugPanels) do
        panel:destroy()
    end

    this.debugPanels = nil
end

---@private
function this.onGamePaused()
    this.paused = true
    this.updateStatusLabel()
end

---@private
function this.onGameUnpaused()
    this.paused = false
    this.updateStatusLabel()
end

---@private
function this.showDebugHud()
    if this.debugHud then
        return
    end

    local menu = this.guiBuilder.createMenu({
        id = "AnimatedDialogue:DebugHud",
        fixedFrame = true,
        modal = false,
    })
        :withFlowDirection(tes3.flowDirection.topToBottom)
        :withAutoSize()
        :withPositionAlign({ x = 0.5, y = 0.04 })
        :build()

    local content = this.guiBuilder.createBlock({ parent = menu })
        :withFlowDirection(tes3.flowDirection.topToBottom)
        :withAutoSize()
        :withPadding({ all = 8 })
        :build()

    local translations = this.translations
    local keys = this.translationKey

    this.guiBuilder.createLabel({ parent = content })
        :withText(translations.get(keys.debugHudTitle))
        :withColor(tes3ui.getPalette(tes3.palette.headerColor))
        :build()

    this.guiBuilder.createLabel({ parent = content })
        :withText(translations.get(keys.debugHudPause, { key = this.getKeyName(this.settings.debugPauseKey) }))
        :build()

    this.guiBuilder.createLabel({ parent = content })
        :withText(translations.get(keys.debugHudStep, { key = this.getKeyName(this.settings.debugStepKey) }))
        :build()

    this.statusLabel = this.guiBuilder.createLabel({ parent = content })
        :build()

    this.debugHud = menu
    this.updateStatusLabel()
end

---@private
function this.updateStatusLabel()
    if not this.statusLabel then
        return
    end

    local translations = this.translations
    local keys = this.translationKey

    if this.paused then
        this.statusLabel.text = translations.get(keys.debugHudStatusPaused)
        this.statusLabel.color = tes3ui.getPalette(tes3.palette.healthColor)
    else
        this.statusLabel.text = translations.get(keys.debugHudStatusRunning)
        this.statusLabel.color = tes3ui.getPalette(tes3.palette.normalColor)
    end

    if this.debugHud then
        this.debugHud:updateLayout()
    end
end

---@private
---@param bind mwseKeyCombo
---@return string
function this.getKeyName(bind)
    return mwse.mcm.getKeyComboName(bind) or "Unbound"
end

---@private
function this.hideDebugHud()
    if not this.debugHud then
        return
    end

    this.debugHud:destroy()
    this.debugHud = nil
    this.statusLabel = nil
end

---@private
---@param e keyDownEventData
function this.onKeyDown(e)
    if not this.settings.debuggingEnabled then
        return
    end

    if not this.dialogueActive then
        return
    end

    if this.matchesKey(e, this.settings.debugPauseKey) then
        this.togglePause()
        return
    end

    if this.matchesKey(e, this.settings.debugStepKey) then
        this.stepFrame()
        return
    end
end

---@private
function this.togglePause()
    if this.paused then
        event.trigger(this.events.gameUnpaused)
    else
        event.trigger(this.events.gamePaused)
    end
end

--- Advances the frozen scene by a single frame: resumes everyone, then re-pauses
--- after one enterFrame. The re-pause tick registers at a low priority so it runs
--- after every service's enterFrame handler, giving them exactly one update.
---@private
function this.stepFrame()
    if not this.paused then
        return
    end

    event.trigger(this.events.gameUnpaused)
    event.register(tes3.event.enterFrame, this.onStepFrame, { priority = -100, doOnce = true })
end

---@private
function this.onStepFrame()
    event.trigger(this.events.gamePaused)
end

---@private
---@param e keyDownEventData
---@param bind mwseKeyCombo|nil
---@return boolean
function this.matchesKey(e, bind)
    if not bind then
        return false
    end

    return e.keyCode == bind.keyCode
        and (not not e.isShiftDown) == (not not bind.isShiftDown)
        and (not not e.isControlDown) == (not not bind.isControlDown)
        and (not not e.isAltDown) == (not not bind.isAltDown)
end

return this
