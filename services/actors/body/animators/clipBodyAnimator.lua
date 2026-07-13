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
---@type eventRegistrar
this.eventRegistrar = nil

---@private
---@type eventHandlers
this.eventHandlers = nil

---@private
---@type tes3reference
this.actor = nil

---@public
---@type string|nil
this.preferredAnimationId = nil

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
---@type actorPoseBlender
this.poseBlender = nil

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
    this.eventRegistrar    = services.eventRegistrar

    return true, nil
end

---@public
---@param reference tes3reference
---@return boolean
function this.handles(reference)
    return reference.object.objectType == tes3.objectType.npc
end

---@public
---@return clipBodyAnimator
function this.create()
    local instance = setmetatable({}, { __index = this })

    instance.actor = nil
    instance.preferredAnimationId = nil
    instance.animationConfiguration = nil
    instance.activeAnimation = nil
    instance.revertTo = nil
    instance.eventHandlers = nil
    instance.poseBlender = this.actorPoseBlender.create()
    instance.bodyTrack = this.actorTrackBinder.create()
    instance.torchTrack = this.actorTrackBinder.create()

    return instance
end

---@public
---@param reference tes3reference
function this:begin(reference)
    self.eventHandlers = {
        [self.events.dialogueInfo] = function(e)
            self:onDialogueInfo(e)
        end
    }
    self.eventRegistrar.register(self.eventHandlers)

    local configuration = self.animationResolver.resolveBase(reference, self.preferredAnimationId)
    if not configuration then
        return
    end

    self.animationConfiguration = configuration

    self:play({
        actor     = reference,
        animation = configuration.idle,
    })
end

---@private
---@param e dialogueInfoEventData
function this:onDialogueInfo(e)
    if e.actor ~= self.actor then
        return
    end

    if not self.settings.actorTalkAnimEnabled then
        return
    end

    if not self.animationConfiguration then
        return
    end

    local animation = self:resolveTalkAnimation(e.info)
    if not animation then
        return
    end

    self:play({
        actor     = self.actor,
        animation = animation,
        revertTo  = self.animationConfiguration.idle,
    })
end

---@private
---@param info tes3dialogueInfo
---@return animationDefinition|nil
function this:resolveTalkAnimation(info)
    local override = self.animationResolver.resolveOverride(info.id)
    if override then
        return override.animation
    end

    if math.random() >= self.settings.actorTalkAnimChance then
        return nil
    end

    local talk = self.animationConfiguration.talk

    return talk and table.choice(talk)
end

---@public
---@param params clipBodyAnimator.play.param
function this:play(params)
    if not params.actor.animationData then
        return
    end

    self.actor = params.actor
    self.revertTo = params.revertTo

    self:applyAnimation(params.animation, params.revertTo == nil)
end

---@public
function this:stop()
    self.eventRegistrar.unregister(self.eventHandlers)
    self:clearPlayback()
    self.animationConfiguration = nil
    self.poseBlender:reset()
end

---@private
function this:clearPlayback()
    self:resetTracks()
    self:setActiveAnimation(nil)
    self.actor = nil
    self.revertTo = nil
end

---@private
---@param animation animationDefinition|nil
function this:setActiveAnimation(animation)
    if self.activeAnimation then
        ---@type animationEventData
        local eventData = { animation = self.activeAnimation }
        event.trigger(self.events.animationEnded, eventData)
    end

    self.activeAnimation = animation

    if animation then
        ---@type animationEventData
        local eventData = { animation = animation }
        event.trigger(self.events.animationStarted, eventData)
    end
end

---@private
---@param animation animationDefinition
---@param loop boolean
function this:applyAnimation(animation, loop)
    local animationData = self.actor.animationData
    if not animationData then
        return
    end

    self:resetTracks()
    self.poseBlender:capture(animationData.actorNode, self.settings.transitionDuration)

    local holdingTorch = self:isHoldingTorch()

    local region       = holdingTorch and
        self.actorTrackBinder.region.body or
        self.actorTrackBinder.region.all

    local count        = self.actorTrackBinder.bind({
        track     = self.bodyTrack,
        actorNode = animationData.actorNode,
        file      = animation.file,
        group     = animation.group,
        region    = region,
        loop      = loop,
    })

    if count == 0 then
        self:clearPlayback()
        return
    end

    self:setActiveAnimation(animation)

    if holdingTorch then
        self:applyTorchArm(animationData.actorNode)
    end
end

---@private
---@param actorNode niNode
function this:applyTorchArm(actorNode)
    self.actorTrackBinder.bind({
        track     = self.torchTrack,
        actorNode = actorNode,
        file      = self.torchArmAnimation.file,
        group     = self.torchArmAnimation.group,
        region    = self.actorTrackBinder.region.leftArm,
        loop      = true,
    })
end

---@public
---@return boolean
function this:overridesLookAt()
    return self.activeAnimation ~= nil and self.activeAnimation.overrideLookAt == true
end

---@private
---@return boolean
function this:isHoldingTorch()
    local mobile = self.actor.mobile
    if not mobile then
        return false
    end

    return tes3.getEquippedItem({
        actor = mobile --[[@as tes3mobileActor]],
        objectType = tes3.objectType.light,
    }) ~= nil
end

---@private
function this:resetTracks()
    self.actorTrackBinder.reset(self.bodyTrack)
    self.actorTrackBinder.reset(self.torchTrack)
end

---@private
---@param track track
function this:updateTrack(track)
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
function this:advanceTrack(track, delta)
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
        self:applyAnimation(self.revertTo, true)
    end
end

---@public
---@param delta number
function this:update(delta)
    if not self.actor then
        return
    end

    local animationData = self.actor.animationData
    if not animationData then
        return
    end

    self:updateTrack(self.bodyTrack)
    self:updateTrack(self.torchTrack)

    animationData.actorNode:update({ children = true })

    if self.poseBlender:isActive() then
        self.poseBlender:update(animationData.actorNode, delta)
    end

    if not self:overridesLookAt() then
        animationData.headNode:update({
            controllers = true,
            time        = 0
        })
    end

    self:advanceTrack(self.torchTrack, delta)
    self:advanceTrack(self.bodyTrack, delta)
end

return this
