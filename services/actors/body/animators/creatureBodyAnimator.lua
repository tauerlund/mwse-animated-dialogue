---@class creatureBodyAnimator : initializedService, bodyAnimator
local this = {}

---@private
---@type settings
this.settings = nil

---@private
---@type creatureAnimationResolver
this.creatureAnimationResolver = nil

---@private
---@type actorPoseBlender
this.actorPoseBlender = nil

---@private
---@type bodySkeletonTicker
this.bodySkeletonTicker = nil

---@private
---@type actorPoseBlender
this.poseBlender = nil

---@private
---@type bodySkeletonTicker.state
this.ticker = nil

---@private
this.logger = mwse.Logger.new()

---@public
---@param services serviceCollection
---@return boolean,string|nil
function this.initialize(services)
    this.settings                  = services.settings
    this.actorPoseBlender          = services.actorPoseBlender
    this.creatureAnimationResolver = services.creatureAnimationResolver
    this.bodySkeletonTicker        = services.bodySkeletonTicker

    return true, nil
end

---@public
---@param services serviceCollection
---@return initializedService[]
function this.dependencies(services)
    return { services.creatureAnimationResolver }
end

---@public
---@param reference tes3reference
---@return boolean
function this.handles(reference)
    return reference.object.objectType == tes3.objectType.creature
end

---@public
---@return creatureBodyAnimator
function this.create()
    local instance = setmetatable({}, { __index = this })

    instance.poseBlender = this.actorPoseBlender.create()
    instance.ticker = this.bodySkeletonTicker.create()

    return instance
end

---@public
---@param reference tes3reference
function this:begin(reference)
    if not reference.animationData then
        return
    end

    local drive = self.creatureAnimationResolver.resolve(reference)
    if not drive then
        self.logger:warn("No usable idle group for creature '%s'; skipping", reference.object.id)
        return
    end

    tes3.playAnimation({
        reference = reference,
        group     = drive.group,
        startFlag = tes3.animationStartFlag.immediate,
        loopCount = -1,
    })

    self.bodySkeletonTicker.begin(self.ticker, {
        actor              = reference,
        start              = drive.start,
        stop               = drive.stop,
        poseBlender        = self.poseBlender,
        transitionDuration = self.settings.transitionDuration,
    })
end

---@public
function this:stop()
    self.bodySkeletonTicker.reset(self.ticker)
end

---@public
---@param delta number
function this:update(delta)
    self.bodySkeletonTicker.update(self.ticker, delta)
end

return this
