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
---@type dialogueState|nil
this.dialogueState = nil

---@private
---@type eventHandlers
this.eventHandlers = nil

---@public
---@param services serviceCollection
---@return boolean, string|nil
function this.initialize(services)
    this.eventRegistrar = services.eventRegistrar
    this.events = services.constants.events
    this.settings = services.settings
    this.debugStatusHud = services.debugStatusHud
    this.debugWindow = services.debugWindow

    local events = this.events

    this.eventHandlers = {
        [events.dialogueStarted] = this.onDialogueStarted,
        [events.dialogueEnded]   = this.onDialogueEnded,
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
    this.dialogueState = e.dialogueState

    if not this.settings.debuggingEnabled then
        return
    end

    this.allowDialogueMenuUnfocus()
    this.debugStatusHud.show()
    this.debugWindow.show({ actor = e.dialogueState.actor })
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
    this.dialogueState = nil
    this.debugStatusHud.hide()
    this.debugWindow.hide()
end

---@private
---@param paused boolean
function this.setPaused(paused)
    this.paused = paused

    if this.dialogueState then
        this.dialogueState.paused = paused
    end

    this.debugStatusHud.setPaused(paused)
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
    this.setPaused(not this.paused)
end

---@private
function this.stepFrame()
    if not this.paused or not this.dialogueState then
        return
    end

    this.dialogueState.paused = false
    event.register(tes3.event.enterFrame, this.onStepFrame, { priority = -100, doOnce = true })
end

---@private
function this.onStepFrame()
    if this.dialogueState then
        this.dialogueState.paused = true
    end
end

---@private
---@param e keyDownEventData
---@param keyCombo mwseKeyCombo|nil
---@return boolean
function this.matchesKey(e, keyCombo)
    if not keyCombo then
        return false
    end

    return e.keyCode == keyCombo.keyCode
end

return this
