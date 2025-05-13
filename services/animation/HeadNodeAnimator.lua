local BipNodeService = require("tauer.animated-dialogue.services.nodes.BipNodeService")

--- Lots of GPT code here, probably need to verify performance/correctness at some point, but it seems to be working for now.

---@class HeadNodeAnimator
local this = {}

---@private
---@type niNode
this.headNode = nil

---@private
---@type niAVObject
this.target = nil

---@public
---@param npc tes3npcInstance
---@param target niAVObject
function this.LookAt(npc, target)
    local headNode = BipNodeService.GetHeadNode(npc)
    if not headNode then
        return
    end
    this.headNode = headNode
    this.target = target

    this.registerEvents()
end

---@public
function this.Stop()
    this.unregisterEvents()
    this.headNode = nil
    this.target = nil
end

---@private
function this.onEnterFrame()
    local node   = this.headNode
    local target = this.target

    local headWorldTransform = node.worldTransform
    local headWorldRotation = headWorldTransform.rotation:copy()
    headWorldRotation:reorthogonalize()

    local headWorldPosition = headWorldTransform.translation
    local cameraWorldPosition  = target.worldTransform.translation

    local direction = (cameraWorldPosition - headWorldPosition):normalized()
    local forward = headWorldRotation:getForwardVector()

    local arc = this.calculateArc(direction, forward)

    local updatedWorldRotation = (arc * headWorldRotation:toQuaternion()):toRotation()

    local invertedParentWorldRotation, _ = node.parent.worldTransform.rotation:copy():invert()

    local updatedLocalRotation = invertedParentWorldRotation * updatedWorldRotation

    local originalEuler, _ = node.rotation:toEulerXYZ()
    local updatedEuler, _ = updatedLocalRotation:toEulerXYZ()

    node.rotation:fromEulerXYZ(updatedEuler.x, originalEuler.y, updatedEuler.z)
    node:update()
end

---@private
---@param dir tes3vector3
---@param forward tes3vector3
---@return niQuaternion
function this.calculateArc(dir, forward)
    local dot = this.calculateDot(dir, forward)

    local angle = math.acos(dot)
    local axis = this.calculateAxis(dir, forward)

    local arc = niQuaternion.new()

    if math.abs(dot + 1) < 1e-4 then
        -- camera is almost exactly behind the head:
        -- rotate by 180° about *the world-up* axis so you get a stable yaw, zero tilt
        arc:fromAngleAxis(math.pi, tes3vector3.new(0, 0, 1))
    else
        arc:fromAngleAxis(angle, axis)
    end

    return arc
end

---@private
---@param dir tes3vector3
---@param forward tes3vector3
---@return number
function this.calculateDot(dir, forward)
    return math.min(math.max(forward:dot(dir), -1), 1)
end

---@private
---@param dir tes3vector3
---@param forward tes3vector3
---@return tes3vector3
function this.calculateAxis(dir, forward)
    local axis = forward:cross(dir)

    local len  = axis:length()
    if len > 1e-5 then
        axis:normalize()
    else
        axis = forward:cross(tes3vector3.new(0, 0, 1))
        if axis:length() < 1e-5 then
            axis = forward:cross(tes3vector3.new(0, 1, 0))
        end
        axis:normalize()
    end

    return axis
end

---@private
function this.registerEvents()
    if not event.isRegistered(tes3.event.enterFrame, this.onEnterFrame) then
        event.register(tes3.event.enterFrame, this.onEnterFrame)
    end
end

---@private
function this.unregisterEvents()
    if event.isRegistered(tes3.event.enterFrame, this.onEnterFrame) then
        event.unregister(tes3.event.enterFrame, this.onEnterFrame)
    end
end

return this