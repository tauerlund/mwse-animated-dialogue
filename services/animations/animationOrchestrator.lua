--- Routes the dialogue lifecycle to the actor's body-animation strategy: selects
--- one (bodyAnimatorSelector) at dialogue start, then forwards begin / dialogue
--- info / stop to it. It is strategy-agnostic - each strategy owns what it plays
--- (ordinary NPCs resolve dialogue clips; the native creature / custom-override
--- strategies self-resolve and ignore per-line info). The only cross-cutting
--- concern kept here is buffering a dialogue info that arrives before the actor
--- is established (the greeting case) and replaying it once begin has run.
---@class animationOrchestrator : initializedService
local this = {}

---@private
---@type eventRegistrar
this.eventRegistrar = nil

---@private
---@type bodyAnimatorSelector
this.bodyAnimatorSelector = nil

---@private
---@type bodyAnimator|nil
this.activeBodyAnimator = nil

---@private
---@type tes3reference
this.actor = nil

---@private
---@type dialogueInfoEventData|nil
this.pendingInfo = nil

---@private
---@type eventHandlers
this.eventHandlers = nil

---@public
---@param services serviceCollection
---@return boolean,string|nil
function this.initialize(services)
    this.eventRegistrar       = services.eventRegistrar
    this.bodyAnimatorSelector = services.bodyAnimatorSelector

    local events              = services.enums.events

    this.eventHandlers        = {
        [events.dialogueStarted] = this.onDialogueStarted,
        [events.dialogueEnded]   = this.onDialogueEnded,
        [events.dialogueInfo]    = this.onDialogueInfo,
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
    this.activeBodyAnimator = this.bodyAnimatorSelector.resolve(e.actor)
    if not this.activeBodyAnimator then
        this.pendingInfo = nil
        return
    end

    this.actor = e.actor
    this.activeBodyAnimator.begin(e.actor)

    if this.pendingInfo and this.pendingInfo.actor == e.actor then
        this.deliverInfo(this.pendingInfo.info)
    end

    this.pendingInfo = nil
end

---@private
---@param e dialogueInfoEventData
function this.onDialogueInfo(e)
    if not this.actor then
        this.pendingInfo = e
        return
    end

    this.deliverInfo(e.info)
end

--- Forwards a spoken line to the active strategy only if it reacts to lines.
--- Native strategies (creature / custom-override) drive one continuous clip and
--- omit the optional onDialogueInfo hook entirely.
---@private
---@param info tes3dialogueInfo
function this.deliverInfo(info)
    if this.activeBodyAnimator.onDialogueInfo then
        this.activeBodyAnimator.onDialogueInfo(info)
    end
end

---@private
function this.onDialogueEnded()
    if this.activeBodyAnimator then
        this.activeBodyAnimator.stop()
    end

    this.activeBodyAnimator = nil
    this.actor = nil
    this.pendingInfo = nil
end

return this
