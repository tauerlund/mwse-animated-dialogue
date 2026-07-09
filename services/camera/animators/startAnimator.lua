---@class cameraStartAnimator : initializedService, cameraAnimator
local this = {}

---@private
---@type eventRegistrar
this.eventRegistrar = nil

---@private
---@type settings
this.settings = nil

---@private
---@type tes3vector3
this.worldUp = tes3vector3.new(0, 0, 1)

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
    local actor          = event.actor
    local settings       = this.settings
    local playerPosition = tes3.player.position
    local actorForward   = tes3vector3.new(playerPosition.x - actor.position.x, playerPosition.y - actor.position.y, 0)
        :normalized()
    local actorRight     = this.worldUp:cross(actorForward)
    if actorRight:length() < 0.001 then
        actorRight = tes3vector3.new(1, 0, 0)
    else
        actorRight = actorRight:normalized()
    end

    local cameraPosition = tes3.getCameraPosition()
    local headNode       = this.resolveHeadNode(actor)

    local aimPoint       = nil
    local targetPosition = nil
    if headNode then
        aimPoint = headNode.worldTransform.translation
        targetPosition = aimPoint
            + actorForward * settings.distance
            + actorRight * settings.horizontalOffset
            + this.worldUp * settings.verticalOffset
    else
        targetPosition = cameraPosition
        aimPoint = tes3vector3.new(actor.position.x, actor.position.y, cameraPosition.z)
    end

    local lookDirection          = this.resolveLookDirection(aimPoint, targetPosition) or -actorForward

    this.originalRotation        = tes3.worldController.worldCamera.cameraRoot.rotation:toQuaternion()
    this.targetRotation          = this.computeTargetRotation(lookDirection)
    this.targetDisplacement      = targetPosition - cameraPosition
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
    local targetOrientation   = this.originalRotation:slerp(this.targetRotation, animationProgress):toRotation()
    local cameraRootRotation  = tes3.worldController.worldCamera.cameraRoot.rotation
    local wrapperRotation     = targetOrientation * cameraRootRotation:transpose()
    local localPosition       = this.cameraRootLocalPosition

    local displacement        = this.targetDisplacement * animationProgress
    cameraWrapper.translation = displacement + localPosition - wrapperRotation * localPosition
    cameraWrapper.rotation    = wrapperRotation

    skyWrapper.translation    = displacement
end

---@private
---@param actor tes3reference
---@return niNode|nil
function this.resolveHeadNode(actor)
    local animationData = actor.animationData
    if not animationData then
        return nil
    end
    return animationData.headNode
end

---@private
---@param aimPoint tes3vector3
---@param targetPosition tes3vector3
---@return tes3vector3|nil
function this.resolveLookDirection(aimPoint, targetPosition)
    local lookDirection = aimPoint - targetPosition
    if lookDirection:length() < 0.001 then
        return nil
    end
    return lookDirection:normalized()
end

---@private
---@param lookDirection tes3vector3
---@return niQuaternion
function this.computeTargetRotation(lookDirection)
    local settings = this.settings
    local right    = lookDirection:cross(this.worldUp)

    if right:length() < 0.001 then
        right = tes3vector3.new(1, 0, 0)
    else
        right = right:normalized()
    end

    if settings.yawOffset ~= 0 then
        lookDirection = this.rotateAroundAxis(lookDirection, this.worldUp, settings.yawOffset)
        right = this.rotateAroundAxis(right, this.worldUp, settings.yawOffset)
    end

    if settings.pitchOffset ~= 0 then
        lookDirection = this.rotateAroundAxis(lookDirection, right, settings.pitchOffset)
    end

    if settings.rollOffset ~= 0 then
        right = this.rotateAroundAxis(right, -lookDirection, settings.rollOffset)
    end

    local up = right:cross(lookDirection):normalized()

    return tes3matrix33.new(
        right.x, lookDirection.x, up.x,
        right.y, lookDirection.y, up.y,
        right.z, lookDirection.z, up.z
    ):toQuaternion()
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
