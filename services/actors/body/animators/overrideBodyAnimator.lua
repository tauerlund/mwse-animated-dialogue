--- Body strategy for NPCs that already play their OWN custom animation (e.g. the
--- performers added by Animated Morrowind). The current clip IS the intended
--- loop, so we drive its current upper-body group window untouched, keeping the
--- whole skeleton ticking while the engine's pass is frozen (bodySkeletonTicker).
---@class overrideBodyAnimator : initializedService, bodyAnimator
local this = {}

---@private
---@type settings
this.settings = nil

---@private
---@type bodySkeletonTicker
this.bodySkeletonTicker = nil

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
    this.bodySkeletonTicker = services.bodySkeletonTicker

    this.ticker             = this.bodySkeletonTicker.create()

    return true, nil
end

---@public
---@param reference tes3reference
---@return boolean
function this.handles(reference)
    if reference.object.objectType ~= tes3.objectType.npc then
        return false
    end

    if not this.settings.actorNativeAnimEnabled then
        return false
    end

    local animationData = reference.animationData
    return animationData ~= nil and animationData.hasOverrideAnimations
end

---@public
---@param reference tes3reference
function this.begin(reference)
    local animationData = reference.animationData
    if not animationData then
        return
    end

    local group          = animationData.currentAnimGroups[tes3.animationBodySection.upper + 1]
    local animationGroup  = animationData.animationGroups[group + 1]
    if not animationGroup then
        return
    end

    local actionTimings = animationGroup.actionTimings
    local start         = actionTimings[1]
    local stop          = actionTimings[#actionTimings]
    if not start or not stop or stop <= start then
        this.logger:warn("Native animation window invalid for '%s' (group %s); skipping", reference.object.id, group)
        return
    end

    this.bodySkeletonTicker.begin(this.ticker, {
        actor = reference,
        start = start,
        stop  = stop,
    })
end

---@public
function this.stop()
    this.bodySkeletonTicker.reset(this.ticker)
end

---@public
---@param delta number
function this.update(delta)
    this.bodySkeletonTicker.update(this.ticker, delta)
end

return this
