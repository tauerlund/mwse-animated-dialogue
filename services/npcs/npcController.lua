---@class npcController : initializedService
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
---@type npcAnimator[]
this.animators = {}

---@private
---@type npcTurnAnimator
this.npcTurnAnimator = nil

---@private
---@type npcControllersAnimator
this.npcControllersAnimator = nil

---@private
---@type npcHeadMorphAnimator
this.npcHeadMorphAnimator = nil

---@private
---@type npcHeadLookAtAnimator
this.npcHeadLookAtAnimator = nil

---@private
---@type npcParticlesAnimator
this.npcParticlesAnimator = nil

---@private
this.paused = false

---@public
---@param services serviceCollection
---@return boolean,string|nil
function this.initialize(services)
    this.eventRegistrar         = services.eventRegistrar
    this.settings               = services.settings
    this.npcTurnAnimator        = services.npcTurnAnimator
    this.npcControllersAnimator = services.npcControllersAnimator
    this.npcHeadMorphAnimator   = services.npcHeadMorphAnimator
    this.npcHeadLookAtAnimator  = services.npcHeadLookAtAnimator
    this.npcParticlesAnimator   = services.npcParticlesAnimator

    local events                = services.enums.events

    this.eventHandlers          = {
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

    if this.settings.npcTurnEnabled then
        table.insert(this.animators, this.npcTurnAnimator)
    end

    if this.settings.npcAnimEnabled then
        table.insert(this.animators, this.npcControllersAnimator)
    end

    if this.settings.npcHeadMorphAnimEnabled then
        table.insert(this.animators, this.npcHeadMorphAnimator)
    end

    if this.settings.npcHeadLookAtEnabled then
        table.insert(this.animators, this.npcHeadLookAtAnimator)
    end

    table.insert(this.animators, this.npcParticlesAnimator)

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

    for _, animator in ipairs(this.animators) do
        animator.update(e.delta)
    end
end

return this
