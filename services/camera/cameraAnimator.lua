---@class cameraAnimator : initializedService
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
---@type niNode
this.cameraWrapper = nil

---@private
---@type niNode
this.skyWrapper = nil

---@private
---@type tes3vector3
this.cameraRootLocalPos = nil

---@private
---@type tes3vector3
this.naturalCameraPosition = nil

---@private
---@type tes3vector3
this.targetDisplacement = nil

---@private
---@type niQuaternion
this.originalRotation = nil

---@private
---@type niQuaternion
this.targetRotation = nil

---@private
---@type number
this.animationTime = 0

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
            [tes3.event.enterFrame] = this.onEnterFrame
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
    if not this.settings.cameraEnabled then
        return
    end
    this.setupWrappers()
    this.naturalCameraPosition = tes3.getCameraPosition()
    this.targetDisplacement = this.computeTargetDisplacement(e.npc)
    this.originalRotation = this.captureOriginalRotation()
    this.computeTargetRotation(e.npc)
    this.animationTime = 0
    this.eventRegistrar.register(this.eventHandlers.dialogue)
end

---@private
function this.onDialogueEnded()
    this.eventRegistrar.unregister(this.eventHandlers.dialogue)
    this.resetWrappers()
    this.targetDisplacement = nil
    this.naturalCameraPosition = nil
    this.originalRotation = nil
    this.targetRotation = nil
end

---@private
---@param e enterFrameEventData
function this.onEnterFrame(e)
    if not this.targetDisplacement then
        return
    end

    local settings = this.settings

    this.animationTime = math.min(this.animationTime + e.delta, settings.animationDuration)
    local t = math.ease.smoothstep(this.animationTime / settings.animationDuration)

    this.applyTransform(this.targetDisplacement * t, t)
end

---@private
function this.setupWrappers()
    local camera = tes3.worldController.worldCamera.cameraRoot
    local sky = tes3.worldController.weatherController.sceneSkyRoot

    this.cameraWrapper = this.getOrCreateWrapper(camera, "cameraAnimator")
    this.skyWrapper = this.getOrCreateWrapper(sky, "skyAnimator")

    this.cameraRootLocalPos = camera.translation:copy()
end

---@private
function this.resetWrappers()
    if not this.cameraWrapper then
        return
    end
    this.cameraWrapper.translation = tes3vector3.new(0, 0, 0)
    this.cameraWrapper.rotation:toIdentity()
    this.cameraWrapper:update()
    this.skyWrapper.translation = tes3vector3.new(0, 0, 0)
    this.skyWrapper:update()
end

---@private
---@param displacement tes3vector3
---@param t number
function this.applyTransform(displacement, t)
    if not this.originalRotation then
        return
    end

    local D                        = this.originalRotation:slerp(this.targetRotation, t):toRotation()
    local Rc                       = tes3.worldController.worldCamera.cameraRoot.rotation
    local Rw                       = D * Rc:transpose()

    local P                        = this.cameraRootLocalPos
    this.cameraWrapper.translation = displacement + P - Rw * P
    this.cameraWrapper.rotation    = Rw
    this.cameraWrapper:update()

    this.skyWrapper.translation = displacement
    this.skyWrapper:update()
end

---@private
---@return niQuaternion
function this.captureOriginalRotation()
    return tes3.worldController.worldCamera.cameraRoot.rotation:toQuaternion()
end

---@private
---@param npc tes3reference
---@return tes3vector3
function this.getNpcHorizontalForward(npc)
    local playerPos = tes3.player.position
    return tes3vector3.new(playerPos.x - npc.position.x, playerPos.y - npc.position.y, 0):normalized()
end

---@private
---@param npc tes3reference
function this.computeTargetRotation(npc)
    local settings   = this.settings
    local worldUp    = tes3vector3.new(0, 0, 1)

    local npcForward = this.getNpcHorizontalForward(npc)
    local npcRight   = worldUp:cross(npcForward)

    local lookDir    = -npcForward
    local right      = lookDir:cross(worldUp)
    if npcRight:length() < 0.001 then
        npcRight = tes3vector3.new(1, 0, 0)
    else
        npcRight = npcRight:normalized()
    end

    if settings.yawOffset ~= 0 then
        lookDir = this.rotateAroundAxis(lookDir, worldUp, settings.yawOffset)
        right   = this.rotateAroundAxis(right, worldUp, settings.yawOffset)
    end
    if settings.pitchOffset ~= 0 then
        lookDir = this.rotateAroundAxis(lookDir, npcRight, settings.pitchOffset)
        right   = this.rotateAroundAxis(right, npcRight, settings.pitchOffset)
    end
    if settings.rollOffset ~= 0 then
        lookDir = this.rotateAroundAxis(lookDir, npcForward, settings.rollOffset)
        right   = this.rotateAroundAxis(right, npcForward, settings.rollOffset)
    end

    local up = right:cross(lookDir):normalized()

    local D = tes3matrix33.new()
    D.x = tes3vector3.new(right.x, lookDir.x, up.x)
    D.y = tes3vector3.new(right.y, lookDir.y, up.y)
    D.z = tes3vector3.new(right.z, lookDir.z, up.z)

    this.targetRotation = D:toQuaternion()
end

---@private
---@param v tes3vector3
---@param axis tes3vector3
---@param degrees number
---@return tes3vector3
function this.rotateAroundAxis(v, axis, degrees)
    local q = niQuaternion.new()
    q:fromAngleAxis(math.rad(degrees), axis)
    return q:toRotation() * v
end

---@private
---@param npc tes3reference
---@return tes3vector3
function this.computeTargetDisplacement(npc)
    local data = npc.animationData
    if not data or not data.headNode then
        return tes3vector3.new(0, 0, 0)
    end

    local settings   = this.settings
    local headPos    = data.headNode.worldTransform.translation
    local cameraPos  = this.naturalCameraPosition
    local worldUp    = tes3vector3.new(0, 0, 1)

    local npcForward = this.getNpcHorizontalForward(npc)
    local right      = worldUp:cross(npcForward)
    if right:length() < 0.001 then
        right = tes3vector3.new(1, 0, 0)
    else
        right = right:normalized()
    end

    local targetPos = headPos
        + npcForward * settings.distance
        + right * settings.horizontalOffset
        + worldUp * settings.verticalOffset

    return targetPos - cameraPos
end

---@private
---@param target niNode
---@param name string
---@return niNode
function this.getOrCreateWrapper(target, name)
    if target.parent.name == name then
        return target.parent
    end

    local wrapper = niNode.new()
    wrapper.name = name

    local parent = target.parent
    wrapper:attachChild(target, true)
    parent:attachChild(wrapper, true)

    wrapper:update()
    return wrapper
end

return this
