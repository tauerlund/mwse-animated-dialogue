---@class npcHeadLookAtAnimator : initializedService, npcAnimator
local this = {}

---@private
---@type eventRegistrar
this.eventRegistrar = nil

---@private
---@type settings
this.settings = nil

---@private
---@type tes3reference
this.npc = nil

---@private
this.axisSafeLength = 1e-5
---@private
this.antiParallelThreshold = 1e-4
---@private
this.maxHeadYaw = math.pi / 2

---@private
this.eventHandlers = nil

---@public
---@param services serviceCollection
---@return boolean,string|nil
function this.initialize(services)
    this.eventRegistrar = services.eventRegistrar
    this.settings       = services.settings

    local events        = services.enums.events
    this.eventHandlers  = {
        [events.dialogueStarted] = this.onDialogueStarted,
        [events.dialogueEnded]   = this.onDialogueEnded,
    }

    this.eventRegistrar.register(this.eventHandlers)

    return true, nil
end

---@public
function this.uninitialize()
    this.eventRegistrar.unregister(this.eventHandlers)
end

---@private
---@param event dialogueStartedEventData
function this.onDialogueStarted(event)
    this.npc = event.npc
end

---@private
function this.onDialogueEnded()
    this.npc = nil
end

---@public
---@param _ number
function this.update(_)
    local animationData = this.npc.animationData
    if not animationData then
        return
    end

    local node               = animationData.headNode
    local cameraPosition     = tes3.worldController.worldCamera.cameraRoot.worldTransform.translation
    local headWorldTransform = node.worldTransform
    local headWorldRotation  = headWorldTransform.rotation:copy()
    headWorldRotation:reorthogonalize()

    local headWorldPosition              = headWorldTransform.translation
    local direction                      = this.clampDirectionToBody((cameraPosition - headWorldPosition):normalized(),
        animationData)
    local forward                        = headWorldRotation:getForwardVector()

    local arc                            = this.calculateArc(direction, forward)
    local updatedWorldRotation           = (arc * headWorldRotation:toQuaternion()):toRotation()

    local invertedParentWorldRotation, _ = node.parent.worldTransform.rotation:copy():invert()
    local updatedLocalRotation           = invertedParentWorldRotation * updatedWorldRotation

    local originalEuler, _               = node.rotation:toEulerXYZ()
    local updatedEuler, _                = updatedLocalRotation:toEulerXYZ()

    node.rotation:fromEulerXYZ(updatedEuler.x, originalEuler.y, updatedEuler.z)
    node:update()
end

---@private
---@param direction tes3vector3
---@param animationData tes3animationData
---@return tes3vector3
function this.clampDirectionToBody(direction, animationData)
    local horizontalLength = math.sqrt(direction.x ^ 2 + direction.y ^ 2)
    if horizontalLength < this.axisSafeLength then
        return direction
    end

    local bodyForward       = animationData.actorNode.worldTransform.rotation:getForwardVector()
    local bodyForwardLength = math.sqrt(bodyForward.x ^ 2 + bodyForward.y ^ 2)
    if bodyForwardLength < this.axisSafeLength then
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

    if math.abs(angle) <= this.maxHeadYaw then
        return direction
    end

    local clampedAngle = math.clamp(angle, -this.maxHeadYaw, this.maxHeadYaw)
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
function this.calculateArc(direction, forward)
    local dot        = math.min(math.max(forward:dot(direction), -1), 1)
    local axis       = forward:cross(direction)
    local axisLength = axis:length()

    if axisLength > this.axisSafeLength then
        axis:normalize()
    else
        axis = forward:cross(tes3vector3.new(0, 0, 1))
        if axis:length() < this.axisSafeLength then
            axis = forward:cross(tes3vector3.new(0, 1, 0))
        end
        axis:normalize()
    end

    local arc = niQuaternion.new()

    if math.abs(dot + 1) < this.antiParallelThreshold then
        arc:fromAngleAxis(math.pi, tes3vector3.new(0, 0, 1))
    else
        arc:fromAngleAxis(math.acos(dot), axis)
    end

    return arc
end

return this
