---@class headLookAtAnimator : service, actorAnimator
local this = {}

---@private
---@type tes3reference
this.actor = nil

---@private
---@type tes3reference|nil
this.target = nil

---@private
---@type bodyAnimator|nil
this.bodyAnimator = nil

---@private
this.axisSafeLength = 1e-5
---@private
this.antiParallelThreshold = 1e-4
---@private
this.maxHeadYaw = math.pi / 2

---@private
---@type niQuaternion
this.arc = nil

---@private
this.lerpSpeed = 8

---@private
this.currentEulerX = nil

---@private
this.currentEulerZ = nil

---@private
this.overridden = false

---@public
---@return headLookAtAnimator
function this.create()
    local instance = setmetatable({}, { __index = this })

    instance.actor = nil
    instance.target = nil
    instance.bodyAnimator = nil
    instance.arc = niQuaternion.new()
    instance.currentEulerX = nil
    instance.currentEulerZ = nil
    instance.overridden = false

    return instance
end

---@public
---@param params headLookAtAnimator.begin.param
function this:begin(params)
    self.actor = params.reference
    self.target = params.target
    self.bodyAnimator = params.bodyAnimator
    self.overridden = false
end

---@public
---@param delta number
function this:update(delta)
    if self:resolveOverridden() then
        return
    end

    local animationData = self.actor.animationData
    if not animationData then
        return
    end

    if not animationData.headNode then
        return
    end

    local node               = animationData.headNode
    local aimPoint           = self:resolveAimPoint()
    local headWorldTransform = node.worldTransform
    local headWorldRotation  = headWorldTransform.rotation:copy()
    headWorldRotation:reorthogonalize()

    local headWorldPosition              = headWorldTransform.translation
    local direction                      = self:clampDirectionToBody((aimPoint - headWorldPosition):normalized(),
        animationData)
    local forward                        = headWorldRotation:getForwardVector()

    local arc                            = self:calculateArc(direction, forward)
    local updatedWorldRotation           = (arc * headWorldRotation:toQuaternion()):toRotation()

    local invertedParentWorldRotation, _ = node.parent.worldTransform.rotation:copy():invert()
    local updatedLocalRotation           = invertedParentWorldRotation * updatedWorldRotation

    local originalEuler, _               = node.rotation:toEulerXYZ()
    local updatedEuler, _                = updatedLocalRotation:toEulerXYZ()

    if self.currentEulerX == nil then
        self.currentEulerX = originalEuler.x
        self.currentEulerZ = originalEuler.z
    end

    local t            = 1 - math.exp(-self.lerpSpeed * delta)
    self.currentEulerX = self.currentEulerX + (updatedEuler.x - self.currentEulerX) * t
    self.currentEulerZ = self.currentEulerZ + (updatedEuler.z - self.currentEulerZ) * t

    node.rotation:fromEulerXYZ(self.currentEulerX, originalEuler.y, self.currentEulerZ)
    node:update()
end

---@private
---@return boolean
function this:resolveOverridden()
    local bodyAnimator = self.bodyAnimator
    local overridden   = bodyAnimator ~= nil
        and bodyAnimator.overridesLookAt ~= nil
        and bodyAnimator:overridesLookAt()

    if overridden then
        self.overridden = true
        return true
    end

    if self.overridden then
        self.overridden = false
        self.currentEulerX = nil
        self.currentEulerZ = nil
    end

    return false
end

---@private
---@return tes3vector3
function this:resolveAimPoint()
    if not self.target then
        return tes3.worldController.worldCamera.cameraRoot.worldTransform.translation
    end

    local animationData = self.target.animationData
    local headNode      = animationData and animationData.headNode
    if not headNode then
        return self.target.position
    end

    return headNode.worldTransform.translation
end

---@private
---@param direction tes3vector3
---@param animationData tes3animationData
---@return tes3vector3
function this:clampDirectionToBody(direction, animationData)
    local horizontalLength = math.sqrt(direction.x ^ 2 + direction.y ^ 2)
    if horizontalLength < self.axisSafeLength then
        return direction
    end

    local bodyForward       = animationData.actorNode.worldTransform.rotation:getForwardVector()
    local bodyForwardLength = math.sqrt(bodyForward.x ^ 2 + bodyForward.y ^ 2)
    if bodyForwardLength < self.axisSafeLength then
        return direction
    end

    local bodyForwardX = bodyForward.x / bodyForwardLength
    local bodyForwardY = bodyForward.y / bodyForwardLength

    local directionX   = direction.x / horizontalLength
    local directionY   = direction.y / horizontalLength

    local dot          = math.min(math.max(bodyForwardX * directionX + bodyForwardY * directionY, -1), 1)
    local angle        = math.acos(dot)
    if bodyForwardX * directionY - bodyForwardY * directionX < 0 then
        angle = -angle
    end

    if math.abs(angle) <= self.maxHeadYaw then
        return direction
    end

    local clampedAngle = math.clamp(angle, -self.maxHeadYaw, self.maxHeadYaw)
    local cosAngle     = math.cos(clampedAngle)
    local sinAngle     = math.sin(clampedAngle)

    return tes3vector3.new(
        (bodyForwardX * cosAngle - bodyForwardY * sinAngle) * horizontalLength,
        (bodyForwardX * sinAngle + bodyForwardY * cosAngle) * horizontalLength,
        direction.z
    ):normalized()
end

---@private
---@param direction tes3vector3
---@param forward tes3vector3
---@return niQuaternion
function this:calculateArc(direction, forward)
    local dot        = math.min(math.max(forward:dot(direction), -1), 1)
    local axis       = forward:cross(direction)
    local axisLength = axis:length()

    if axisLength > self.axisSafeLength then
        axis:normalize()
    else
        axis = forward:cross(tes3vector3.new(0, 0, 1))
        if axis:length() < self.axisSafeLength then
            axis = forward:cross(tes3vector3.new(0, 1, 0))
        end
        axis:normalize()
    end

    if math.abs(dot + 1) < self.antiParallelThreshold then
        self.arc:fromAngleAxis(math.pi, tes3vector3.new(0, 0, 1))
    else
        self.arc:fromAngleAxis(math.acos(dot), axis)
    end

    return self.arc
end

return this
