---@class cameraSwayAnimator : initializedService, cameraAnimator
local this = {}

---@private
---@type eventRegistrar
this.eventRegistrar = nil

---@private
---@type settings
this.settings = nil

---@private
---@type tes3vector3
this.swayAxis = nil

---@private
---@type tes3vector3
this.cameraRootLocalPosition = nil

---@private
---@type number
this.swayTime = 0

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
    local npcForward     = tes3vector3.new(playerPosition.x - npc.position.x, playerPosition.y - npc.position.y, 0)
        :normalized()
    local npcRight       = worldUp:cross(npcForward)
    if npcRight:length() < 0.001 then
        this.swayAxis = tes3vector3.new(1, 0, 0)
    else
        this.swayAxis = npcRight:normalized()
    end
    this.cameraRootLocalPosition = tes3.worldController.worldCamera.cameraRoot.translation:copy()
    this.swayTime = 0
end

---@private
function this.onDialogueEnded()
    this.swayAxis                = nil
    this.cameraRootLocalPosition = nil
    this.swayTime                = 0
end

---@public
---@param cameraWrapper niNode
---@param _ niNode
---@param animationProgress number
---@param delta number
function this.update(cameraWrapper, _, animationProgress, delta)
    local settings = this.settings
    if not this.swayAxis or not settings.swayEnabled or settings.swayAmplitude <= 0 then
        return
    end

    this.swayTime         = this.swayTime + delta
    local frequency       = settings.swayFrequency
    local amplitude       = math.rad(settings.swayAmplitude) * animationProgress
    local pitchAngle      = math.sin(2 * math.pi * frequency * this.swayTime) * amplitude
    local yawAngle        = math.sin(2 * math.pi * frequency * 0.7 * this.swayTime + 0.9) * amplitude * 0.4

    local pitchQuaternion = niQuaternion.new()
    pitchQuaternion:fromAngleAxis(pitchAngle, this.swayAxis)
    local yawQuaternion = niQuaternion.new()
    yawQuaternion:fromAngleAxis(yawAngle, tes3vector3.new(0, 0, 1))

    local localPosition           = this.cameraRootLocalPosition
    local previousWrapperRotation = cameraWrapper.rotation
    local swayedWrapperRotation   = yawQuaternion:toRotation() * pitchQuaternion:toRotation() * previousWrapperRotation

    cameraWrapper.translation     = cameraWrapper.translation + previousWrapperRotation * localPosition -
        swayedWrapperRotation * localPosition
    cameraWrapper.rotation        = swayedWrapperRotation
end

return this
