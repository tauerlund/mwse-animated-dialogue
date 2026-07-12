--- Routes spoken dialogue lines to the body-animation strategies driving the
--- conversation. actorController owns the strategies (it builds and ticks them)
--- and hands them over at dialogue start with a synchronous begin, keeping
--- decide -> perform on one call stack. This service is strategy-agnostic: each
--- strategy owns what it plays, and the ones that drive one continuous clip (the
--- creature / custom-override strategies) simply omit onDialogueInfo. The only
--- cross-cutting concern kept here is buffering a line that arrives before the
--- strategies are established (the greeting case) and replaying it once they are.
---@class animationOrchestrator : initializedService
local this = {}

---@private
---@type eventRegistrar
this.eventRegistrar = nil

---@private
---@type bodyAnimator[]
this.bodyAnimators = {}

---@private
this.active = false

---@private
---@type tes3dialogueInfo|nil
this.pendingInfo = nil

---@private
---@type eventHandlers
this.eventHandlers = nil

---@public
---@param services serviceCollection
---@return boolean,string|nil
function this.initialize(services)
    this.eventRegistrar = services.eventRegistrar

    local events        = services.enums.events

    this.eventHandlers  = {
        [events.dialogueEnded] = this.onDialogueEnded,
        [events.dialogueInfo]  = this.onDialogueInfo,
    }

    this.eventRegistrar.register(this.eventHandlers)

    return true, nil
end

---@public
function this.uninitialize()
    this.eventRegistrar.unregister(this.eventHandlers)
end

---@public
---@param bodyAnimators bodyAnimator[]
function this.begin(bodyAnimators)
    this.bodyAnimators = bodyAnimators
    this.active = true

    if this.pendingInfo then
        this.deliverInfo(this.pendingInfo)
    end

    this.pendingInfo = nil
end

---@private
---@param e dialogueInfoEventData
function this.onDialogueInfo(e)
    if not this.active then
        this.pendingInfo = e.info
        return
    end

    this.deliverInfo(e.info)
end

---@private
---@param info tes3dialogueInfo
function this.deliverInfo(info)
    for i = 1, #this.bodyAnimators do
        local animator = this.bodyAnimators[i]
        if animator.onDialogueInfo then
            animator:onDialogueInfo(info)
        end
    end
end

---@private
function this.onDialogueEnded()
    this.bodyAnimators = {}
    this.active = false
    this.pendingInfo = nil
end

return this
