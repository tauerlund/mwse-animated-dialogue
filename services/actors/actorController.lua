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
---@type bodyAnimator|nil
this.actorBodyAnimator = nil

---@private
---@type bodyAnimatorSelector
this.bodyAnimatorSelector = nil

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
---@type playerController
this.playerController = nil

---@private
---@type lookAtModes
this.lookAtModes = nil

---@private
---@type dialogueState
this.dialogueState = nil

---@public
---@param services serviceCollection
---@return boolean,string|nil
function this.initialize(services)
    this.eventRegistrar        = services.eventRegistrar
    this.settings              = services.settings
    this.bodyAnimatorSelector  = services.bodyAnimatorSelector
    this.actorTurnAnimator     = services.actorTurnAnimator
    this.headMorphAnimator     = services.headMorphAnimator
    this.headLookAtAnimator    = services.headLookAtAnimator
    this.headBobAnimator       = services.headBobAnimator
    this.lipsyncController     = services.lipsyncController
    this.playerController      = services.playerController
    this.lookAtModes           = services.enums.lookAtModes

    local events               = services.enums.events

    this.eventHandlers         = {
        lifetime = {
            [events.dialogueStarted] = this.onDialogueStarted,
            [events.dialogueEnded]   = this.onDialogueEnded,
        },
        dialogue = {
            [tes3.event.enterFrame] = this.onEnterFrame,
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
    this.actorBodyAnimator = nil

    this.addActorAnimators(e.dialogueState.actor)
    this.addPlayerAnimators(e.dialogueState.actor)

    this.dialogueState = e.dialogueState
    this.eventRegistrar.register(this.eventHandlers.dialogue)
end

---@private
---@param actor tes3reference
function this.addActorAnimators(actor)
    local body = this.bodyAnimatorSelector.resolve(actor, this.resolveActorToggles())
    if body then
        body:begin(actor)
        this.addAnimator(body)
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

    local lookAtMode = this.resolveActorLookAtMode()
    if lookAtMode ~= this.lookAtModes.off then
        local lookAt = this.headLookAtAnimator.create()
        lookAt:begin({
            reference    = actor,
            target       = this.resolveActorLookAtTarget(lookAtMode),
            bodyAnimator = body,
        })
        this.addAnimator(lookAt)
    end

    if this.settings.actorHeadBobEnabled then
        local bob = this.headBobAnimator.create()
        bob:begin(actor)
        this.addAnimator(bob)
    end
end

---@private
---@return bodyAnimatorToggles
function this.resolveActorToggles()
    return {
        creature = this.settings.creatureAnimEnabled,
        native   = this.settings.actorNativeAnimEnabled,
        clip     = this.settings.actorAnimEnabled,
    }
end

---@private
---@return string
function this.resolveActorLookAtMode()
    if tes3.is3rdPerson() then
        return this.settings.actorHeadLookAtModeThirdPerson
    end

    return this.settings.actorHeadLookAtModeFirstPerson
end

---@private
---@param mode string
---@return tes3reference|nil
function this.resolveActorLookAtTarget(mode)
    if mode == this.lookAtModes.player then
        return tes3.player
    end

    return nil
end

---@private
---@param actor tes3reference
function this.addPlayerAnimators(actor)
    if not tes3.is3rdPerson() then
        return
    end

    if this.playerController.shouldHidePlayer() then
        return
    end

    local player = tes3.player
    local body = this.bodyAnimatorSelector.resolve(player, this.resolvePlayerToggles())
    if body then
        body.preferredAnimationId = this.settings.playerAnimation
        body:begin(player)
        this.addAnimator(body)
    end

    if this.settings.playerTurnEnabled then
        local turn = this.actorTurnAnimator.create()
        turn:begin({ reference = player, target = actor, restoresOrientation = true })
        this.addAnimator(turn)
    end

    if this.settings.playerHeadLookAtEnabled then
        local lookAt = this.headLookAtAnimator.create()
        lookAt:begin({ reference = player, target = actor, bodyAnimator = body })
        this.addAnimator(lookAt)
    end
end

---@private
---@return bodyAnimatorToggles
function this.resolvePlayerToggles()
    return {
        creature = false,
        native   = false,
        clip     = this.settings.playerAnimEnabled,
    }
end

---@private
---@param animator actorAnimator
function this.addAnimator(animator)
    this.animators[#this.animators + 1] = animator
end

---@private
function this.onDialogueEnded()
    this.eventRegistrar.unregister(this.eventHandlers.dialogue)

    this.stopAnimators()

    this.animators = {}
    this.actorBodyAnimator = nil
    this.dialogueState = nil
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
---@param e enterFrameEventData
function this.onEnterFrame(e)
    if this.dialogueState.paused then
        return
    end

    this.lipsyncController.update(e.delta)

    for i = 1, #this.animators do
        this.animators[i]:update(e.delta)
    end
end

return this
