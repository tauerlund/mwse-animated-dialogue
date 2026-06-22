---@class npcAnimator : initializedService
local this = {}

---@private
---@type settings
this.settings = nil

---@private
---@type eventRegistrar
this.eventRegistrar = nil

---@private
---@type eventHandlerGroups
this.eventHandlers = {
    lifetime = {},
    dialogue = {}
}

---@private
---@type tes3reference
this.npc = nil

---@private
---@type number
this.phase = 0

---@private
---@type number
this.originalYaw = nil

---@private
---@type number
this.targetYaw = nil

---@private
---@type number
this.turnTime = 0

---@private
---@type fun(delta: number, data: tes3animationData)[]
this.updaters = {}

---@private
this.axisSafeLength = 1e-5
---@private
this.antiParallelThreshold = 1e-4
---@private
this.maxHeadYaw = math.pi / 2

---@public
---@param services serviceCollection
---@return boolean,string|nil
function this.initialize(services)
    this.eventRegistrar = services.eventRegistrar
    this.settings = services.settings

    local events = services.enums.events

    this.eventHandlers = {
        lifetime = {
            [events.dialogueStarted] = this.onDialogueStarted,
            [events.dialogueEnded] = this.onDialogueEnded,
        },
        dialogue = {
            [tes3.event.enterFrame] = this.onEnterFrame,
        }
    }

    this.eventRegistrar.register(this.eventHandlers.lifetime)

    return true, nil
end

---@public
function this.uninitialize()
    this.eventRegistrar.unregister(this.eventHandlers.lifetime)
end

---@private
---@param e dialogueStartedEventData
function this.onDialogueStarted(e)
    this.npc = e.npc
    this.phase = 0
    this.turnTime = 0
    this.originalYaw = e.npc.orientation.z
    local playerPos = tes3.player.position
    local dx = playerPos.x - e.npc.position.x
    local dy = playerPos.y - e.npc.position.y
    this.targetYaw = math.atan2(dx, dy)

    this.updaters = {}

    if this.settings.npcTurnEnabled then
        table.insert(this.updaters, this.updateTurn)
    end

    if this.settings.npcAnimEnabled then
        table.insert(this.updaters, this.updateControllers)
    end

    if this.settings.npcHeadMorphAnimEnabled then
        table.insert(this.updaters, this.updateHeadMorph)
    end

    if this.settings.npcHeadLookAtEnabled then
        table.insert(this.updaters, this.updateHeadLookAt)
    end

    this.eventRegistrar.register(this.eventHandlers.dialogue)
end

---@private
function this.onDialogueEnded()
    this.eventRegistrar.unregister(this.eventHandlers.dialogue)
    this.updaters = {}
    this.npc = nil
    this.originalYaw = nil
    this.targetYaw = nil
end

---@private
---@param e enterFrameEventData
function this.onEnterFrame(e)
    local data = this.npc.animationData
    if not data then
        return
    end

    for _, updater in ipairs(this.updaters) do
        updater(e.delta, data)
    end
end

---@private
---@param delta number
---@param _ tes3animationData
function this.updateTurn(delta, _)
    local duration = this.settings.turnDuration
    this.turnTime = math.min(this.turnTime + delta, duration)
    local t = math.ease.smoothstep(this.turnTime / duration)
    local yaw = this.lerpAngle(this.originalYaw, this.targetYaw, t)

    local orientation = this.npc.orientation:copy()
    orientation.z = yaw

    this.npc.orientation = orientation
end

---@private
---@param a number
---@param b number
---@param t number
---@return number
function this.lerpAngle(a, b, t)
    local diff = b - a
    if diff > math.pi then
        diff = diff - 2 * math.pi
    end
    if diff < -math.pi then
        diff = diff + 2 * math.pi
    end
    return a + diff * t
end

---@private
---@param delta number
---@param data tes3animationData
function this.updateControllers(delta, data)
    data.actorNode:update({
        controllers = true,
        children = true,
        time = this.phase
    })
    data.headNode:update({
        controllers = true,
        time = 0
    })
    this.phase = this.phase + delta
    if this.phase >= 2.666667 then
        this.phase = 0
    end
end

---@private
---@param _ number
---@param data tes3animationData
function this.updateHeadMorph(_, data)
    local phase = this.isTalking()
        and this.getTalkPhase()
        or 0

    data.headNode:update({
        controllers = true,
        time = phase
    })
end

---@private
---@param direction tes3vector3
---@param data tes3animationData
---@return tes3vector3
function this.clampDirectionToBody(direction, data)
    local hLen = math.sqrt(direction.x ^ 2 + direction.y ^ 2)
    if hLen < this.axisSafeLength then
        return direction
    end

    local bodyForward = data.actorNode.worldTransform.rotation:getForwardVector()
    local bLen = math.sqrt(bodyForward.x ^ 2 + bodyForward.y ^ 2)
    if bLen < this.axisSafeLength then
        return direction
    end
    local bx = bodyForward.x / bLen
    local by = bodyForward.y / bLen

    local dhx = direction.x / hLen
    local dhy = direction.y / hLen

    local dot = math.min(math.max(bx * dhx + by * dhy, -1), 1)
    local angle = math.acos(dot)
    if bx * dhy - by * dhx < 0 then
        angle = -angle
    end

    if math.abs(angle) <= this.maxHeadYaw then
        return direction
    end

    local clampedAngle = math.clamp(angle, -this.maxHeadYaw, this.maxHeadYaw)
    local c = math.cos(clampedAngle)
    local s = math.sin(clampedAngle)
    return tes3vector3.new(
        (bx * c - by * s) * hLen,
        (bx * s + by * c) * hLen,
        direction.z
    ):normalized()
end

---@private
---@param _ number
---@param data tes3animationData
function this.updateHeadLookAt(_, data)
    local node = data.headNode
    local cameraPos = tes3.worldController.worldCamera.cameraRoot.worldTransform.translation

    local headWorldTransform = node.worldTransform
    local headWorldRotation = headWorldTransform.rotation:copy()
    headWorldRotation:reorthogonalize()

    local headWorldPosition = headWorldTransform.translation
    local direction = this.clampDirectionToBody((cameraPos - headWorldPosition):normalized(), data)
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
    local dot = math.min(math.max(forward:dot(dir), -1), 1)
    local axis = forward:cross(dir)
    local len = axis:length()

    if len > this.axisSafeLength then
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

---@private
---@return boolean
function this.isTalking()
    return this.npc.animationData.lipsyncLevel ~= -1
end

---@private
---@return number
function this.getTalkPhase()
    local data = this.npc.animationData
    if not data then
        return 0
    end

    local level = data.lipsyncLevel
    local startTime = data.talkMorphStartTime
    local endTime = data.talkMorphEndTime

    local phase = math.remap(level, 0, 1, startTime, endTime)

    return math.clamp(phase, startTime, endTime)
end

return this
