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
---@type debugStatusHud
this.debugStatusHud = nil

---@private
---@type debugWindow
this.debugWindow = nil

---@private
this.dialogueActive = false

---@private
this.paused = false

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
    this.debugStatusHud = services.debugStatusHud
    this.debugWindow = services.debugWindow

    local events = this.events

    this.eventHandlers = {
        [events.dialogueStarted] = this.onDialogueStarted,
        [events.dialogueEnded]   = this.onDialogueEnded,
        [events.gamePaused]      = this.onGamePaused,
        [events.gameUnpaused]    = this.onGameUnpaused,
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
---@param e dialogueStartedEventData
function this.onDialogueStarted(e)
    this.dialogueActive = true
    this.paused = false

    if not this.settings.debuggingEnabled then
        return
    end

    this.allowDialogueMenuUnfocus()
    this.debugStatusHud.show()
    this.debugWindow.show({ actor = e.actor })
end

---@private
function this.allowDialogueMenuUnfocus()
    local menuDialog = tes3ui.findMenu("MenuDialog")

    if not menuDialog then
        return
    end

    menuDialog:register(tes3.uiEvent.unfocus, this.onDialogueMenuUnfocus)
end

---@private
---@return boolean
function this.onDialogueMenuUnfocus()
    return true
end

---@private
function this.onDialogueEnded()
    this.dialogueActive = false
    this.paused = false
    this.debugStatusHud.hide()
    this.debugWindow.hide()
end

---@private
function this.onGamePaused()
    this.paused = true
    this.debugStatusHud.setPaused(true)
end

---@private
function this.onGameUnpaused()
    this.paused = false
    this.debugStatusHud.setPaused(false)
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
