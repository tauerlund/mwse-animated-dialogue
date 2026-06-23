---@class cameraStartAnimator : initializedService, cameraAnimator
local this = {}

---@private
---@type eventRegistrar
this.eventRegistrar = nil

---@private
---@type settings
this.settings = nil

---@private
---@type niQuaternion
this.originalRotation = nil

---@private
---@type niQuaternion
this.targetRotation = nil

---@private
---@type tes3vector3
this.targetDisplacement = nil

---@private
---@type tes3vector3
this.cameraRootLocalPosition = nil

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
    local npc            = event.npc
    local worldUp        = tes3vector3.new(0, 0, 1)
    local playerPosition = tes3.player.position
    local npcForward     = tes3vector3.new(playerPosition.x - npc.position.x, playerPosition.y - npc.position.y, 0):normalized()
    local npcRight       = worldUp:cross(npcForward)
    if npcRight:length() < 0.001 then
        npcRight = tes3vector3.new(1, 0, 0)
    else
        npcRight = npcRight:normalized()
    end

    this.originalRotation        = tes3.worldController.worldCamera.cameraRoot.rotation:toQuaternion()
    this.targetRotation          = this.computeTargetRotation(npcForward, npcRight)
    this.targetDisplacement      = this.computeTargetDisplacement(npc, npcForward, npcRight)
    this.cameraRootLocalPosition = tes3.worldController.worldCamera.cameraRoot.translation:copy()
end

---@private
function this.onDialogueEnded()
    this.originalRotation        = nil
    this.targetRotation          = nil
    this.targetDisplacement      = nil
    this.cameraRootLocalPosition = nil
end

---@public
---@param cameraWrapper niNode
---@param skyWrapper niNode
---@param animationProgress number
---@param _ number
function this.update(cameraWrapper, skyWrapper, animationProgress, _)
    local targetOrientation  = this.originalRotation:slerp(this.targetRotation, animationProgress):toRotation()
    local cameraRootRotation = tes3.worldController.worldCamera.cameraRoot.rotation
    local wrapperRotation    = targetOrientation * cameraRootRotation:transpose()
    local localPosition      = this.cameraRootLocalPosition

    local displacement        = this.targetDisplacement * animationProgress
    cameraWrapper.translation = displacement + localPosition - wrapperRotation * localPosition
    cameraWrapper.rotation    = wrapperRotation

    skyWrapper.translation = displacement
end

---@private
---@param npcForward tes3vector3
---@param npcRight tes3vector3
---@return niQuaternion
function this.computeTargetRotation(npcForward, npcRight)
    local settings       = this.settings
    local worldUp        = tes3vector3.new(0, 0, 1)
    local lookDirection  = -npcForward
    local right          = lookDirection:cross(worldUp)

    if settings.yawOffset ~= 0 then
        lookDirection = this.rotateAroundAxis(lookDirection, worldUp, settings.yawOffset)
        right         = this.rotateAroundAxis(right, worldUp, settings.yawOffset)
    end

    if settings.pitchOffset ~= 0 then
        lookDirection = this.rotateAroundAxis(lookDirection, npcRight, settings.pitchOffset)
        right         = this.rotateAroundAxis(right, npcRight, settings.pitchOffset)
    end

    if settings.rollOffset ~= 0 then
        lookDirection = this.rotateAroundAxis(lookDirection, npcForward, settings.rollOffset)
        right         = this.rotateAroundAxis(right, npcForward, settings.rollOffset)
    end

    local up              = right:cross(lookDirection):normalized()
    local orientationMatrix = tes3matrix33.new()
    orientationMatrix.x   = tes3vector3.new(right.x, lookDirection.x, up.x)
    orientationMatrix.y   = tes3vector3.new(right.y, lookDirection.y, up.y)
    orientationMatrix.z   = tes3vector3.new(right.z, lookDirection.z, up.z)

    return orientationMatrix:toQuaternion()
end

---@private
---@param npc tes3reference
---@param npcForward tes3vector3
---@param npcRight tes3vector3
---@return tes3vector3
function this.computeTargetDisplacement(npc, npcForward, npcRight)
    local animationData = npc.animationData
    if not animationData or not animationData.headNode then
        return tes3vector3.new(0, 0, 0)
    end

    local settings       = this.settings
    local headPosition   = animationData.headNode.worldTransform.translation
    local cameraPosition = tes3.getCameraPosition()
    local worldUp        = tes3vector3.new(0, 0, 1)

    local targetPosition = headPosition
        + npcForward * settings.distance
        + npcRight   * settings.horizontalOffset
        + worldUp    * settings.verticalOffset

    return targetPosition - cameraPosition
end

---@private
---@param vector tes3vector3
---@param axis tes3vector3
---@param degrees number
---@return tes3vector3
function this.rotateAroundAxis(vector, axis, degrees)
    local quaternion = niQuaternion.new()
    quaternion:fromAngleAxis(math.rad(degrees), axis)
    return quaternion:toRotation() * vector
end

return this
