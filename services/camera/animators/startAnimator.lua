---@class cameraStartAnimator : initializedService, cameraAnimator
local this = {}

---@private
---@type eventRegistrar
this.eventRegistrar = nil

---@private
---@type cameraPresetResolver
this.cameraPresetResolver = nil

---@private
this.cameraAnchors = require("tauer.animated-dialogue.services.camera.presets.enums.cameraAnchors")

---@private
---@type tes3vector3
this.worldUp = tes3vector3.new(0, 0, 1)

---@private
---@type number
this.liveEaseRate = 8

---@private
---@type number
this.collisionPadding = 20

---@private
---@type tes3reference|nil
this.actor = nil

---@private
---@type cameraPreset|nil
this.activePreset = nil

---@private
---@type tes3vector3
this.startCameraPosition = nil

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
---@type niQuaternion|nil
this.appliedRotation = nil

---@private
---@type tes3vector3|nil
this.appliedDisplacement = nil

---@private
---@type tes3vector3
this.cameraRootLocalPosition = nil

---@private
this.eventHandlers = nil

---@public
---@param services serviceCollection
---@return boolean,string|nil
function this.initialize(services)
    this.eventRegistrar       = services.eventRegistrar
    this.cameraPresetResolver = services.cameraPresetResolver

    local events              = services.enums.events
    this.eventHandlers        = {
        [events.dialogueStarted]     = this.onDialogueStarted,
        [events.dialogueEnded]       = this.onDialogueEnded,
        [events.settingsUpdated]     = this.onSettingsUpdated,
        [events.cameraPresetUpdated] = this.onCameraPresetUpdated,
    }

    this.eventRegistrar.register(this.eventHandlers)

    return true, nil
end

---@public
---@param services serviceCollection
---@return initializedService[]
function this.dependencies(services)
    return { services.cameraPresetResolver }
end

---@public
function this.uninitialize()
    this.eventRegistrar.unregister(this.eventHandlers)
end

---@private
---@param event dialogueStartedEventData
function this.onDialogueStarted(event)
    this.actor                   = event.dialogueState.actor
    this.activePreset            = this.cameraPresetResolver.resolve()
    this.startCameraPosition     = tes3.getCameraPosition()
    this.originalRotation        = tes3.worldController.worldCamera.cameraRoot.rotation:toQuaternion()
    this.cameraRootLocalPosition = tes3.worldController.worldCamera.cameraRoot.translation:copy()
    this.appliedRotation         = nil
    this.appliedDisplacement     = nil

    this.computeTarget()
end

---@private
function this.onSettingsUpdated()
    if not this.actor then
        return
    end

    this.activePreset = this.cameraPresetResolver.resolve()
    this.computeTarget()
end

---@private
---@param event cameraPresetUpdatedEventData
function this.onCameraPresetUpdated(event)
    if not this.actor then
        return
    end

    this.activePreset = event.preset
    this.computeTarget()
end

---@private
function this.computeTarget()
    local actor          = this.actor
    local preset         = this.activePreset
    local playerPosition = tes3.player.position
    local actorForward   = tes3vector3.new(playerPosition.x - actor.position.x, playerPosition.y - actor.position.y, 0)
        :normalized()
    local actorRight     = this.worldUp:cross(actorForward)
    if actorRight:length() < 0.001 then
        actorRight = tes3vector3.new(1, 0, 0)
    else
        actorRight = actorRight:normalized()
    end

    local cameraPosition = this.startCameraPosition
    local headNode       = this.resolveHeadNode(actor)

    local aimPoint       = nil
    local targetPosition = nil
    if headNode then
        aimPoint = headNode.worldTransform.translation
        targetPosition = this.resolveAnchorPoint(preset, headNode)
            + actorForward * preset.distance
            + actorRight * preset.horizontalOffset
            + this.worldUp * preset.verticalOffset
        targetPosition = this.clampTargetToGeometry(aimPoint, targetPosition)
    else
        targetPosition = cameraPosition
        aimPoint = tes3vector3.new(actor.position.x, actor.position.y, cameraPosition.z)
    end

    local displacement      = targetPosition - cameraPosition

    local lookDirection     = this.resolveLookDirection(aimPoint, targetPosition) or -actorForward

    this.targetRotation     = this.computeTargetRotation(preset, lookDirection)
    this.targetDisplacement = displacement
end

---@private
---@param aimPoint tes3vector3
---@param targetPosition tes3vector3
---@return tes3vector3
function this.clampTargetToGeometry(aimPoint, targetPosition)
    local toTarget = targetPosition - aimPoint
    local distance = toTarget:length()
    if distance < 0.001 then
        return targetPosition
    end

    local direction = toTarget:normalized()
    local result    = tes3.rayTest({
        position = aimPoint,
        direction = direction,
        maxDistance = distance,
        ignore = { this.actor, tes3.player },
    })

    if not result then
        return targetPosition
    end

    local safeDistance = math.max(result.distance - this.collisionPadding, 0)
    return aimPoint + direction * safeDistance
end

---@private
function this.onDialogueEnded()
    this.actor                   = nil
    this.activePreset            = nil
    this.startCameraPosition     = nil
    this.originalRotation        = nil
    this.targetRotation          = nil
    this.targetDisplacement      = nil
    this.appliedRotation         = nil
    this.appliedDisplacement     = nil
    this.cameraRootLocalPosition = nil
end

---@public
---@param cameraWrapper niNode
---@param skyWrapper niNode
---@param animationProgress number
---@param delta number
function this.update(cameraWrapper, skyWrapper, animationProgress, delta)
    this.advancePose(animationProgress, delta)

    local targetOrientation   = this.appliedRotation:toRotation()
    local cameraRootRotation  = tes3.worldController.worldCamera.cameraRoot.rotation
    local wrapperRotation     = targetOrientation * cameraRootRotation:transpose()
    local localPosition       = this.cameraRootLocalPosition

    local displacement        = this.appliedDisplacement
    cameraWrapper.translation = displacement + localPosition - wrapperRotation * localPosition
    cameraWrapper.rotation    = wrapperRotation

    skyWrapper.translation    = displacement
end

---@private
---@param animationProgress number
---@param delta number
function this.advancePose(animationProgress, delta)
    if animationProgress < 1 then
        this.appliedRotation     = this.originalRotation:slerp(this.targetRotation, animationProgress)
        this.appliedDisplacement = this.targetDisplacement * animationProgress
        return
    end

    if not this.appliedRotation then
        this.appliedRotation     = this.targetRotation
        this.appliedDisplacement = this.targetDisplacement
        return
    end

    local alpha              = 1 - math.exp(-this.liveEaseRate * delta)
    this.appliedRotation     = this.appliedRotation:slerp(this.targetRotation, alpha)
    this.appliedDisplacement = this.appliedDisplacement
        + (this.targetDisplacement - this.appliedDisplacement) * alpha
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
---@param preset cameraPreset
---@param headNode niNode
---@return tes3vector3
function this.resolveAnchorPoint(preset, headNode)
    local headPosition = headNode.worldTransform.translation
    local eyePosition  = tes3.getPlayerEyePosition()

    local x = headPosition.x
    local y = headPosition.y
    if preset.anchor == this.cameraAnchors.player then
        x = eyePosition.x
        y = eyePosition.y
    end

    return tes3vector3.new(x, y, math.lerp(eyePosition.z, headPosition.z, preset.verticalAnchor))
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
---@param preset cameraPreset
---@param lookDirection tes3vector3
---@return niQuaternion
function this.computeTargetRotation(preset, lookDirection)
    local right = lookDirection:cross(this.worldUp)

    if right:length() < 0.001 then
        right = tes3vector3.new(1, 0, 0)
    else
        right = right:normalized()
    end

    if preset.yawOffset ~= 0 then
        lookDirection = this.rotateAroundAxis(lookDirection, this.worldUp, preset.yawOffset)
        right = this.rotateAroundAxis(right, this.worldUp, preset.yawOffset)
    end

    if preset.pitchOffset ~= 0 then
        lookDirection = this.rotateAroundAxis(lookDirection, right, preset.pitchOffset)
    end

    if preset.rollOffset ~= 0 then
        right = this.rotateAroundAxis(right, -lookDirection, preset.rollOffset)
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
