---@class overrideBodyAnimator : initializedService, bodyAnimator
local this = {}

---@type boolean
this.suppressesTurn = false

---@private
---@type settings
this.settings = nil

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
    this.settings           = services.settings
    this.actorPoseBlender   = services.actorPoseBlender
    this.bodySkeletonTicker = services.bodySkeletonTicker

    return true, nil
end

---@public
---@param reference tes3reference
---@return boolean
function this.handles(reference)
    if reference.object.objectType ~= tes3.objectType.npc then
        return false
    end

    local animationData = reference.animationData
    return animationData ~= nil and animationData.hasOverrideAnimations
end

---@public
---@return overrideBodyAnimator
function this.create()
    local instance = setmetatable({}, { __index = this })

    instance.suppressesTurn = false
    instance.poseBlender = this.actorPoseBlender.create()
    instance.ticker = this.bodySkeletonTicker.create()

    return instance
end

---@public
---@param reference tes3reference
function this:begin(reference)
    local start, stop = self:resolveNativeWindow(reference)
    if not start or not stop then
        return
    end

    self.bodySkeletonTicker.begin(self.ticker, {
        actor              = reference,
        start              = start,
        stop               = stop,
        poseBlender        = self.poseBlender,
        transitionDuration = self.settings.transitionDuration,
    })

    self.suppressesTurn = true
end

---@private
---@param reference tes3reference
---@return number|nil start, number|nil stop
function this:resolveNativeWindow(reference)
    local animationData = reference.animationData
    if not animationData then
        return nil
    end

    local group          = animationData.currentAnimGroups[tes3.animationBodySection.upper + 1]
    local animationGroup = animationData.animationGroups[group + 1]
    if not animationGroup then
        return nil
    end

    local timings     = animationGroup.actionTimings
    local start, stop = timings[1], timings[#timings]
    if not start or not stop or stop <= start then
        self.logger:warn("Native animation window invalid for '%s' (group %s); skipping", reference.object.id, group)
        return nil
    end

    return start, stop
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
