---@class actorTurnAnimator : initializedService, actorAnimator
local this = {}

---@private
---@type settings
this.settings = nil

---@private
---@type tes3reference
this.actor = nil

---@private
---@type tes3reference
this.target = nil

---@private
---@type boolean
this.restoresOrientation = false

---@private
---@type number
this.originalYaw = nil

---@private
---@type number
this.targetYaw = nil

---@private
this.turnTime = 0

---@public
---@param services serviceCollection
---@return boolean,string|nil
function this.initialize(services)
    this.settings = services.settings

    return true, nil
end

---@public
---@return actorTurnAnimator
function this.create()
    local instance = setmetatable({}, { __index = this })

    instance.actor = nil
    instance.target = nil
    instance.restoresOrientation = false
    instance.originalYaw = nil
    instance.targetYaw = nil
    instance.turnTime = 0

    return instance
end

---@public
---@param params actorTurnAnimator.begin.param
function this:begin(params)
    self.actor               = params.reference
    self.target              = params.target
    self.restoresOrientation = params.restoresOrientation == true
    self.turnTime            = 0
    self.originalYaw         = params.reference.orientation.z

    local targetPosition     = params.target.position
    local deltaX             = targetPosition.x - params.reference.position.x
    local deltaY             = targetPosition.y - params.reference.position.y

    self.targetYaw           = math.atan2(deltaX, deltaY)
end

---@public
function this:stop()
    if self.restoresOrientation and self.originalYaw then
        self:applyYaw(self.originalYaw)
    end

    self.actor = nil
    self.target = nil
    self.originalYaw = nil
    self.targetYaw = nil
end

---@public
---@param delta number
function this:update(delta)
    local duration = self.settings.turnDuration
    self.turnTime  = math.min(self.turnTime + delta, duration)

    local progress = 1
    if duration > 0 then
        progress = math.ease.smoothstep(self.turnTime / duration)
    end

    self:applyYaw(self:lerpAngle(self.originalYaw, self.targetYaw, progress))
end

---@private
---@param yaw number
function this:applyYaw(yaw)
    local orientation      = self.actor.orientation:copy()

    orientation.z          = yaw
    self.actor.orientation = orientation
end

---@private
---@param fromAngle number
---@param toAngle number
---@param progress number
---@return number
function this:lerpAngle(fromAngle, toAngle, progress)
    local diff = toAngle - fromAngle
    if diff > math.pi then
        diff = diff - 2 * math.pi
    end
    if diff < -math.pi then
        diff = diff + 2 * math.pi
    end
    return fromAngle + diff * progress
end

return this
