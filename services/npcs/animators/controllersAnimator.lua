---@class npcControllersAnimator : initializedService, npcAnimator
local this = {}

---@private
---@type eventRegistrar
this.eventRegistrar = nil

---@private
---@type settings
this.settings = nil

---@private
---@type npcPoseBlender
this.npcPoseBlender = nil

---@private
---@type animationResolver
this.animationResolver = nil

---@private
---@type npcTrackBinder
this.npcTrackBinder = nil

---@private
---@type events
this.events = nil

---@private
---@type tes3reference
this.npc = nil

---@private
---@type animationDefinition|nil
this.activeAnimation = nil

---@private
---@type mwseLogger
this.logger = mwse.Logger.new()

---@private
---@type track
this.bodyTrack = nil

---@private
---@type track
this.torchTrack = nil

---@private
---@type animationDefinition
this.torchArmAnimation = { file = "tauer\\ad\\torch.nif", group = "idle9" }

---@private
this.eventHandlers = nil

---@private
---@type baseAnimationConfiguration
this.animationConfiguration = nil

---@private
---@type dialogueInfoEventData|nil
this.pendingInfo = nil

---@public
---@param services serviceCollection
---@return boolean,string|nil
function this.initialize(services)
    this.eventRegistrar    = services.eventRegistrar
    this.settings          = services.settings
    this.npcPoseBlender    = services.npcPoseBlender
    this.animationResolver = services.animationResolver
    this.npcTrackBinder    = services.npcTrackBinder
    this.events            = services.enums.events

    this.bodyTrack         = this.npcTrackBinder.create()
    this.torchTrack        = this.npcTrackBinder.create()

    local events           = this.events
    this.eventHandlers     = {
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
    if not this.settings.npcAnimEnabled then
        return
    end

    local configuration = this.animationResolver.resolveBase(e.npc)
    if not configuration then
        return
    end

    this.npc = e.npc
    this.animationConfiguration = configuration

    this.applyAnimation(configuration.idle, true)

    if this.pendingInfo and this.pendingInfo.npc == e.npc then
        this.onDialogueInfo(this.pendingInfo)
    end

    this.pendingInfo = nil
end

---@private
---@param e dialogueInfoEventData
function this.onDialogueInfo(e)
    if not this.npc then
        this.pendingInfo = e
        return
    end

    if not this.settings.npcTalkAnimEnabled then
        return
    end

    local talk = this.animationConfiguration.talk
    local override = this.animationResolver.resolveOverride(e.info.id)

    local animation =
        override and override.animation or
        talk and table.choice(talk)

    if not animation then
        return
    end

    this.applyAnimation(animation, false)
end

---@private
function this.onDialogueEnded()
    this.resetTracks()
    this.setActiveAnimation(nil)
    this.npc = nil
    this.npcPoseBlender.reset()
    this.pendingInfo = nil
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
    local animationData = this.npc.animationData
    if not animationData then
        return
    end

    this.resetTracks()
    this.npcPoseBlender.capture(animationData.actorNode, this.settings.transitionDuration)

    local holdingTorch = this.isHoldingTorch()

    local region       = holdingTorch and
        this.npcTrackBinder.region.body or
        this.npcTrackBinder.region.all

    local count        = this.npcTrackBinder.bind({
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
        this.npc = nil
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
    this.npcTrackBinder.bind({
        track     = this.torchTrack,
        actorNode = actorNode,
        file      = this.torchArmAnimation.file,
        group     = this.torchArmAnimation.group,
        region    = this.npcTrackBinder.region.leftArm,
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
    local mobile = this.npc.mobile
    return mobile ~= nil and mobile.torchSlot ~= nil and mobile.torchSlot.object ~= nil
end

---@private
function this.resetTracks()
    this.npcTrackBinder.reset(this.bodyTrack)
    this.npcTrackBinder.reset(this.torchTrack)
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
        this.applyAnimation(this.animationConfiguration.idle, true)
    end
end

---@public
---@param delta number
function this.update(delta)
    if not this.npc then
        return
    end

    local animationData = this.npc.animationData
    if not animationData then
        return
    end

    this.updateTrack(this.bodyTrack)
    this.updateTrack(this.torchTrack)

    animationData.actorNode:update({ children = true })

    if this.npcPoseBlender.isActive() then
        this.npcPoseBlender.update(animationData.actorNode, delta)
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
