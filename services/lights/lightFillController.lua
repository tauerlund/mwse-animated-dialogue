---@class lightFillController : initializedService
local this = {}

---@private
---@type settings
this.settings = nil

---@private
---@type eventRegistrar
this.eventRegistrar = nil

---@private
---@type fillLightModes
this.fillLightModes = nil

---@private
---@type cameraPresetResolver
this.cameraPresetResolver = nil

---@private
---@type number
this.animationTime = 0

---@private
---@type number
this.animationDuration = 0

---@private
this.fallbackRampDuration = 1.5

---@private
---@type eventHandlerGroups
this.eventHandlers = {
    lifetime = {},
    dialogue = {}
}

---@private
---@type dialogueState
this.dialogueState = nil

---@private
---@type niPointLight|nil
this.light = nil

---@private
---@type niNode|nil
this.parentNode = nil

---@private
---@type tes3vector3
this.worldUp = tes3vector3.new(0, 0, 1)

---@private
---@type string
this.lightName = "AnimatedDialogue:FillLight"

---@public
---@param services serviceCollection
---@return boolean,string|nil
function this.initialize(services)
    this.eventRegistrar       = services.eventRegistrar
    this.settings             = services.settings
    this.fillLightModes       = services.constants.fillLightModes
    this.cameraPresetResolver = services.cameraPresetResolver

    local events              = services.constants.events

    this.eventHandlers        = {
        lifetime = {
            [events.dialogueStarted]  = this.onDialogueStarted,
            [events.dialogueEnded]    = this.onDialogueEnded,
            [events.settingsUpdated]  = this.onSettingsChanged,
            [events.fillLightUpdated] = this.onSettingsChanged,
        },
        dialogue = {
            [tes3.event.enterFrame] = this.onEnterFrame,
        }
    }

    this.eventRegistrar.register(this.eventHandlers.lifetime)

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
    this.eventRegistrar.unregister(this.eventHandlers.lifetime)
end

---@private
---@param e dialogueStartedEventData
function this.onDialogueStarted(e)
    this.dialogueState = e.dialogueState

    if not this.shouldLight(e.dialogueState.actor) then
        return
    end

    this.attach(e.dialogueState.actor)
end

---@private
function this.onDialogueEnded()
    this.stop()
    this.dialogueState = nil
end

---@private
function this.onSettingsChanged()
    if not this.dialogueState then
        return
    end

    if not this.shouldLight(this.dialogueState.actor) then
        this.stop()
        return
    end

    if not this.light then
        this.attach(this.dialogueState.actor)
        return
    end

    this.applySettings()
    this.applyPosition()
end

---@public
---@return boolean
function this.isActive()
    return this.light ~= nil
end

---@private
---@param actor tes3reference
---@return boolean
function this.shouldLight(actor)
    local mode = this.settings.fillLightMode
    local modes = this.fillLightModes

    if mode == modes.always then
        return true
    end

    if mode == modes.adaptive then
        return not this.isCarryingLight(tes3.player) and not this.isCarryingLight(actor)
    end

    return false
end

---@private
---@param reference tes3reference
---@return boolean
function this.isCarryingLight(reference)
    local mobile = reference.mobile
    if not mobile then
        return false
    end

    local light = tes3.getEquippedItem({
        actor = mobile --[[@as tes3mobileActor]],
        objectType = tes3.objectType.light,
    })

    return light ~= nil
end

---@private
---@param e enterFrameEventData
function this.onEnterFrame(e)
    if this.dialogueState.paused then
        return
    end

    this.animationTime = math.min(this.animationTime + e.delta, this.animationDuration)

    this.applyBrightness()
    this.applyPosition()
end

---@private
---@param actor tes3reference
function this.attach(actor)
    local parent = actor.sceneNode --[[@as niNode]]
    if not parent then
        return
    end

    local light = niPointLight.new() --[[@as niPointLight]]
    light.name = this.lightName
    light.ambient = niColor.new(0, 0, 0)

    parent:attachChild(light)
    parent:attachEffect(light)
    light:attachAffectedNode(parent)
    parent:updateEffects()

    this.light = light
    this.parentNode = parent
    this.animationTime = 0
    this.animationDuration = this.resolveRampDuration()

    this.applySettings()
    this.applyPosition()

    this.eventRegistrar.register(this.eventHandlers.dialogue)
end

---@private
---@return number
function this.resolveRampDuration()
    local preset = this.cameraPresetResolver.resolve()
    if not preset then
        return this.fallbackRampDuration
    end

    return preset.animationDuration
end

---@private
function this.stop()
    if not this.light then
        return
    end

    this.eventRegistrar.unregister(this.eventHandlers.dialogue)
    this.detach()
end

---@private
function this.detach()
    local light = this.light
    local parent = this.parentNode
    if not light or not parent then
        return
    end

    light:detachAffectedNode(parent)
    parent:detachEffect(light)
    parent:detachChild(light)
    parent:updateEffects()

    this.light = nil
    this.parentNode = nil
end

---@private
function this.applySettings()
    local settings = this.settings
    local color = settings.fillLightColor
    local light = this.light
    if not light then
        return
    end

    light.diffuse = niColor.new(color.r, color.g, color.b)
    light:setRadius(math.round(settings.fillLightRadius))

    this.applyBrightness()
end

---@private
function this.applyBrightness()
    this.light.dimmer = this.rampProgress() * this.settings.fillLightBrightness
end

---@private
---@return number
function this.rampProgress()
    if this.animationDuration <= 0 then
        return 1
    end

    return math.ease.smoothstep(this.animationTime / this.animationDuration)
end

---@private
function this.applyPosition()
    local translation = this.resolveLocalTranslation()
    if not translation then
        return
    end

    this.light.translation = translation
    this.light:update()
end

---@private
---@return tes3vector3|nil
function this.resolveLocalTranslation()
    local settings = this.settings
    local anchor = this.resolveAnchorPoint()
    local position = anchor
        + this.resolveCameraDirection(anchor) * settings.fillLightDistance
        + this.worldUp * settings.fillLightHeight

    local inverse, valid = this.parentNode.worldTransform:invert()
    if not valid then
        return nil
    end

    return inverse * position
end

---@private
---@return tes3vector3
function this.resolveAnchorPoint()
    local actor = this.dialogueState.actor
    local animationData = actor.animationData
    local headNode = animationData and animationData.headNode

    if headNode then
        return headNode.worldTransform.translation
    end

    return actor.position
end

---@private
---@param anchor tes3vector3
---@return tes3vector3
function this.resolveCameraDirection(anchor)
    local cameraPosition = tes3.getCameraPosition()
    local direction = tes3vector3.new(cameraPosition.x - anchor.x, cameraPosition.y - anchor.y, 0)

    if direction:length() < 0.001 then
        return this.worldUp
    end

    return direction:normalized()
end

return this
