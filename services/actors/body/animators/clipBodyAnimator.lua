--- Body strategy for ordinary NPCs: drives context-resolved dialogue clips via
--- the controller-rebind mechanism (track binding, pose blending, torch-arm,
--- one-shot talk clips reverting to idle). Decided/driven by animationOrchestrator.
---@class clipBodyAnimator : initializedService, bodyAnimator
local this = {}

---@private
---@type settings
this.settings = nil

---@private
---@type actorPoseBlender
this.actorPoseBlender = nil

---@private
---@type actorTrackBinder
this.actorTrackBinder = nil

---@private
---@type animationResolver
this.animationResolver = nil

---@private
---@type events
this.events = nil

---@private
---@type tes3reference
this.actor = nil

---@private
---@type baseAnimationConfiguration|nil
this.animationConfiguration = nil

---@private
---@type animationDefinition|nil
this.activeAnimation = nil

---@private
---@type animationDefinition|nil
this.revertTo = nil

---@private
---@type track
this.bodyTrack = nil

---@private
---@type track
this.torchTrack = nil

---@private
---@type animationDefinition
this.torchArmAnimation = { file = "tauer\\ad\\torch.nif", group = "idle9" }

---@public
---@param services serviceCollection
---@return boolean,string|nil
function this.initialize(services)
    this.settings          = services.settings
    this.actorPoseBlender  = services.actorPoseBlender
    this.actorTrackBinder  = services.actorTrackBinder
    this.animationResolver = services.animationResolver
    this.events            = services.enums.events

    this.bodyTrack         = this.actorTrackBinder.create()
    this.torchTrack        = this.actorTrackBinder.create()

    return true, nil
end

---@public
---@param reference tes3reference
---@return boolean
function this.handles(reference)
    return reference.object.objectType == tes3.objectType.npc
        and this.settings.actorAnimEnabled
end

--- Resolves and plays this NPC's dialogue idle. The looping idle is held until a
--- talk clip replaces it (onDialogueInfo) or the dialogue ends (stop).
---@public
---@param reference tes3reference
function this.begin(reference)
    local configuration = this.animationResolver.resolveBase(reference)
    if not configuration then
        return
    end

    this.animationConfiguration = configuration

    this.play({
        actor     = reference,
        animation = configuration.idle,
    })
end

--- Plays a one-shot talk / dialogue-override clip reverting to the idle. A
--- spoken line drives this; if talk animations are off or nothing resolves, the
--- current idle keeps looping untouched.
---@public
---@param info tes3dialogueInfo
function this.onDialogueInfo(info)
    if not this.settings.actorTalkAnimEnabled then
        return
    end

    if not this.animationConfiguration then
        return
    end

    local talk = this.animationConfiguration.talk
    local override = this.animationResolver.resolveOverride(info.id)

    local animation =
        override and override.animation or
        talk and table.choice(talk)

    if not animation then
        return
    end

    this.play({
        actor     = this.actor,
        animation = animation,
        revertTo  = this.animationConfiguration.idle,
    })
end

---@public
---@param params clipBodyAnimator.play.param
function this.play(params)
    if not params.actor.animationData then
        return
    end

    this.actor = params.actor
    this.revertTo = params.revertTo

    this.applyAnimation(params.animation, params.revertTo == nil)
end

---@public
function this.stop()
    this.resetTracks()
    this.setActiveAnimation(nil)
    this.actor = nil
    this.revertTo = nil
    this.animationConfiguration = nil
    this.actorPoseBlender.reset()
end

---@private
---@param animation animationDefinition|nil
function this.setActiveAnimation(animation)
    if this.activeAnimation then
        ---@type animationEventData
        local eventData = { animation = this.activeAnimation }
        event.trigger(this.events.animationEnded, eventData)
    end

    this.activeAnimation = animation

    if animation then
        ---@type animationEventData
        local eventData = { animation = animation }
        event.trigger(this.events.animationStarted, eventData)
    end
end

---@private
---@param animation animationDefinition
---@param loop boolean
function this.applyAnimation(animation, loop)
    local animationData = this.actor.animationData
    if not animationData then
        return
    end

    this.resetTracks()
    this.actorPoseBlender.capture(animationData.actorNode, this.settings.transitionDuration)

    local holdingTorch = this.isHoldingTorch()

    local region       = holdingTorch and
        this.actorTrackBinder.region.body or
        this.actorTrackBinder.region.all

    local count        = this.actorTrackBinder.bind({
        track     = this.bodyTrack,
        actorNode = animationData.actorNode,
        file      = animation.file,
        group     = animation.group,
        region    = region,
        loop      = loop,
    })

    if count == 0 then
        this.resetTracks()
        this.setActiveAnimation(nil)
        this.actor = nil
        this.revertTo = nil
        return
    end

    this.setActiveAnimation(animation)

    if holdingTorch then
        this.applyTorchArm(animationData.actorNode)
    end
end

---@private
---@param actorNode niNode
function this.applyTorchArm(actorNode)
    this.actorTrackBinder.bind({
        track     = this.torchTrack,
        actorNode = actorNode,
        file      = this.torchArmAnimation.file,
        group     = this.torchArmAnimation.group,
        region    = this.actorTrackBinder.region.leftArm,
        loop      = true,
    })
end

---@private
---@return boolean
function this.overridesLookAt()
    return this.activeAnimation ~= nil and this.activeAnimation.overrideLookAt == true
end

---@private
---@return boolean
function this.isHoldingTorch()
    local mobile = this.actor.mobile
    if not mobile then
        return false
    end

    return tes3.getEquippedItem({
        actor = mobile --[[@as tes3mobileActor]],
        objectType = tes3.objectType.light,
    }) ~= nil
end

---@private
function this.resetTracks()
    this.actorTrackBinder.reset(this.bodyTrack)
    this.actorTrackBinder.reset(this.torchTrack)
end

---@private
---@param track track
function this.updateTrack(track)
    for i = 1, track.count do
        track.controllers[i].target:update({
            controllers = true,
            time        = track.phase
        })
    end

    for i = 1, track.restCount do
        track.rest[i].target.rotation = track.rest[i].rotation
    end
end

---@private
---@param track track
---@param delta number
function this.advanceTrack(track, delta)
    if track.count == 0 then
        return
    end

    track.phase = track.phase + delta

    if track.phase < track.stop then
        return
    end

    if track.looping then
        track.phase = track.start
    else
        this.applyAnimation(this.revertTo, true)
    end
end

---@public
---@param delta number
function this.update(delta)
    if not this.actor then
        return
    end

    local animationData = this.actor.animationData
    if not animationData then
        return
    end

    this.updateTrack(this.bodyTrack)
    this.updateTrack(this.torchTrack)

    animationData.actorNode:update({ children = true })

    if this.actorPoseBlender.isActive() then
        this.actorPoseBlender.update(animationData.actorNode, delta)
    end

    if not this.overridesLookAt() then
        animationData.headNode:update({
            controllers = true,
            time        = 0
        })
    end

    this.advanceTrack(this.torchTrack, delta)
    this.advanceTrack(this.bodyTrack, delta)
end

return this
