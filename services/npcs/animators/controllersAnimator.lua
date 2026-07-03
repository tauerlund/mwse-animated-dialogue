---@class npcControllersAnimator : initializedService, npcAnimator
local this = {}

---@private
---@type settings
this.settings = nil

---@private
---@type npcPoseBlender
this.npcPoseBlender = nil

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
    this.settings       = services.settings
    this.npcPoseBlender = services.npcPoseBlender
    this.npcTrackBinder = services.npcTrackBinder
    this.events         = services.enums.events

    this.bodyTrack      = this.npcTrackBinder.create()
    this.torchTrack     = this.npcTrackBinder.create()

    return true, nil
end

---@public
---@param params npcControllersAnimator.play.param
function this.play(params)
    if not params.npc.animationData then
        return
    end

    this.npc = params.npc
    this.revertTo = params.revertTo

    this.applyAnimation(params.animation, params.revertTo == nil)
end

---@public
function this.stop()
    this.resetTracks()
    this.setActiveAnimation(nil)
    this.npc = nil
    this.revertTo = nil
    this.npcPoseBlender.reset()
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
        this.applyAnimation(this.revertTo, true)
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
