---@class creatureBodyAnimator : initializedService, bodyAnimator
local this = {}

---@private
---@type settings
this.settings = nil

---@private
---@type creatureAnimationResolver
this.creatureAnimationResolver = nil

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
    this.settings                  = services.settings
    this.creatureAnimationResolver = services.creatureAnimationResolver
    this.bodySkeletonTicker        = services.bodySkeletonTicker

    this.ticker                    = this.bodySkeletonTicker.create()

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
        and this.settings.creatureAnimEnabled
end

---@public
---@param reference tes3reference
function this.begin(reference)
    if not reference.animationData then
        return
    end

    local drive = this.creatureAnimationResolver.resolve(reference)
    if not drive then
        this.logger:warn("No usable idle group for creature '%s'; skipping", reference.object.id)
        return
    end

    tes3.playAnimation({
        reference = reference,
        group     = drive.group,
        startFlag = tes3.animationStartFlag.immediate,
        loopCount = -1,
    })

    this.bodySkeletonTicker.begin(this.ticker, {
        actor = reference,
        start = drive.start,
        stop  = drive.stop,
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
