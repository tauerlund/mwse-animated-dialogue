---@class actorController : initializedService
local this = {}

---@private
---@type settings
this.settings = nil

---@private
---@type eventRegistrar
this.eventRegistrar = nil

---@private
---@type eventHandlerGroups
this.eventHandlers = {
    lifetime = {},
    dialogue = {}
}

---@private
---@type actorAnimator[]
this.animators = {}

---@private
---@type actorTurnAnimator
this.actorTurnAnimator = nil

---@private
---@type actorControllersAnimator
this.actorControllersAnimator = nil

---@private
---@type actorHeadMorphAnimator
this.actorHeadMorphAnimator = nil

---@private
---@type actorHeadLookAtAnimator
this.actorHeadLookAtAnimator = nil

---@private
this.paused = false

---@public
---@param services serviceCollection
---@return boolean,string|nil
function this.initialize(services)
    this.eventRegistrar           = services.eventRegistrar
    this.settings                 = services.settings
    this.actorTurnAnimator        = services.actorTurnAnimator
    this.actorControllersAnimator = services.actorControllersAnimator
    this.actorHeadMorphAnimator   = services.actorHeadMorphAnimator
    this.actorHeadLookAtAnimator  = services.actorHeadLookAtAnimator

    local events                  = services.enums.events

    this.eventHandlers            = {
        lifetime = {
            [events.dialogueStarted] = this.onDialogueStarted,
            [events.dialogueEnded]   = this.onDialogueEnded,
        },
        dialogue = {
            [tes3.event.enterFrame] = this.onEnterFrame,
            [events.gamePaused]     = this.onGamePaused,
            [events.gameUnpaused]   = this.onGameUnpaused,
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
---@param _ dialogueStartedEventData
function this.onDialogueStarted(_)
    this.animators = {}

    if this.settings.actorTurnEnabled then
        table.insert(this.animators, this.actorTurnAnimator)
    end

    if this.settings.actorAnimEnabled then
        table.insert(this.animators, this.actorControllersAnimator)
    end

    if this.settings.actorHeadMorphAnimEnabled then
        table.insert(this.animators, this.actorHeadMorphAnimator)
    end

    if this.settings.actorHeadLookAtEnabled then
        table.insert(this.animators, this.actorHeadLookAtAnimator)
    end

    this.paused = false
    this.eventRegistrar.register(this.eventHandlers.dialogue)
end

---@private
function this.onDialogueEnded()
    this.eventRegistrar.unregister(this.eventHandlers.dialogue)
    this.animators = {}
end

---@private
function this.onGamePaused()
    this.paused = true
end

---@private
function this.onGameUnpaused()
    this.paused = false
end

---@private
---@param e enterFrameEventData
function this.onEnterFrame(e)
    if this.paused then
        return
    end

    for i = 1, #this.animators do
        this.animators[i].update(e.delta)
    end
end

return this
