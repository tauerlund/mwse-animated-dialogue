--- Builds the animators for every participant in the dialogue and ticks them
--- each frame. Animators are per-participant instances, created here and thrown
--- away at dialogue end, so the same modules can drive the actor and the player
--- side by side.
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
---@type bodyAnimator[]
this.bodyAnimators = {}

---@private
---@type bodyAnimator|nil
this.actorBodyAnimator = nil

---@private
---@type bodyAnimatorSelector
this.bodyAnimatorSelector = nil

---@private
---@type animationOrchestrator
this.animationOrchestrator = nil

---@private
---@type actorTurnAnimator
this.actorTurnAnimator = nil

---@private
---@type headMorphAnimator
this.headMorphAnimator = nil

---@private
---@type headLookAtAnimator
this.headLookAtAnimator = nil

---@private
---@type headBobAnimator
this.headBobAnimator = nil

---@private
---@type lipsyncController
this.lipsyncController = nil

---@private
this.paused = false

---@public
---@param services serviceCollection
---@return boolean,string|nil
function this.initialize(services)
    this.eventRegistrar        = services.eventRegistrar
    this.settings              = services.settings
    this.bodyAnimatorSelector  = services.bodyAnimatorSelector
    this.animationOrchestrator = services.animationOrchestrator
    this.actorTurnAnimator     = services.actorTurnAnimator
    this.headMorphAnimator     = services.headMorphAnimator
    this.headLookAtAnimator    = services.headLookAtAnimator
    this.headBobAnimator       = services.headBobAnimator
    this.lipsyncController     = services.lipsyncController

    local events               = services.enums.events

    this.eventHandlers         = {
        lifetime = {
            [events.dialogueStarted] = this.onDialogueStarted,
            [events.dialogueEnded]   = this.onDialogueEnded,
        },
        dialogue = {
            [tes3.event.enterFrame]        = this.onEnterFrame,
            [tes3.event.bodyPartsUpdated]  = this.onBodyPartsUpdated,
            [events.gamePaused]            = this.onGamePaused,
            [events.gameUnpaused]          = this.onGameUnpaused,
        }
    }

    this.eventRegistrar.register(this.eventHandlers.lifetime)

    return true, nil
end

---@public
function this.uninitialize()
    this.eventRegistrar.unregister(this.eventHandlers.lifetime)
end

--- The body animator the debug preview drives.
---@public
---@return bodyAnimator|nil
function this.getActorBodyAnimator()
    return this.actorBodyAnimator
end

---@private
---@param e dialogueStartedEventData
function this.onDialogueStarted(e)
    this.animators = {}
    this.bodyAnimators = {}
    this.actorBodyAnimator = nil

    this.addActorAnimators(e.actor)

    this.animationOrchestrator.begin(this.bodyAnimators)

    this.paused = false
    this.eventRegistrar.register(this.eventHandlers.dialogue)
end

---@private
---@param actor tes3reference
function this.addActorAnimators(actor)
    local body = this.bodyAnimatorSelector.resolve(actor, this.resolveActorGates())
    if body then
        body:begin(actor)
        this.addBodyAnimator(body)
    end

    this.actorBodyAnimator = body

    if this.settings.actorTurnEnabled and not (body and body.suppressesTurn) then
        local turn = this.actorTurnAnimator.create()
        turn:begin({ reference = actor, target = tes3.player })
        this.addAnimator(turn)
    end

    if this.settings.actorHeadMorphAnimEnabled then
        local morph = this.headMorphAnimator.create()
        morph:begin(actor)
        this.addAnimator(morph)
    end

    if this.settings.actorHeadLookAtEnabled then
        local lookAt = this.headLookAtAnimator.create()
        lookAt:begin({ reference = actor, bodyAnimator = body })
        this.addAnimator(lookAt)
    end

    if this.settings.actorHeadBobEnabled then
        local bob = this.headBobAnimator.create()
        bob:begin(actor)
        this.addAnimator(bob)
    end
end

---@private
---@return bodyAnimatorGates
function this.resolveActorGates()
    return {
        creature = this.settings.creatureAnimEnabled,
        native   = this.settings.actorNativeAnimEnabled,
        clip     = this.settings.actorAnimEnabled,
    }
end

---@private
---@param animator actorAnimator
function this.addAnimator(animator)
    this.animators[#this.animators + 1] = animator
end

---@private
---@param animator bodyAnimator
function this.addBodyAnimator(animator)
    this.addAnimator(animator)
    this.bodyAnimators[#this.bodyAnimators + 1] = animator
end

---@private
function this.onDialogueEnded()
    this.eventRegistrar.unregister(this.eventHandlers.dialogue)

    this.stopAnimators()

    this.animators = {}
    this.bodyAnimators = {}
    this.actorBodyAnimator = nil
end

---@private
function this.stopAnimators()
    for i = 1, #this.animators do
        local animator = this.animators[i]
        if animator.stop then
            animator:stop()
        end
    end
end

---@private
function this.onGamePaused()
    this.paused = true
end

---@private
function this.onGameUnpaused()
    this.paused = false
end

--- An equipment change rebuilds an actor's body parts, invalidating any node
--- an animator cached. Fanned out here so the animators need no subscriptions
--- of their own - as instances they would share one handler function, which the
--- event system would deduplicate down to a single registration.
---@private
---@param e bodyPartsUpdatedEventData
function this.onBodyPartsUpdated(e)
    for i = 1, #this.animators do
        local animator = this.animators[i]
        if animator.onBodyPartsUpdated then
            animator:onBodyPartsUpdated(e)
        end
    end
end

---@private
---@param e enterFrameEventData
function this.onEnterFrame(e)
    if this.paused then
        return
    end

    this.lipsyncController.update(e.delta)

    for i = 1, #this.animators do
        this.animators[i]:update(e.delta)
    end
end

return this
