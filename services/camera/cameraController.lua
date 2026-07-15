---@class cameraController : initializedService
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
---@type number
this.animationTime = 0

---@private
---@type number
this.animationDuration = 0

---@private
---@type cameraPresetResolver
this.cameraPresetResolver = nil

---@private
---@type cameraAnimator[]
this.animators = {}

---@private
---@type cameraStartAnimator
this.cameraStartAnimator = nil

---@private
---@type cameraSwayAnimator
this.cameraSwayAnimator = nil

---@private
---@type dialogueState
this.dialogueState = nil

---@public
---@param services serviceCollection
---@return boolean,string|nil
function this.initialize(services)
    this.eventRegistrar       = services.eventRegistrar
    this.settings             = services.settings
    this.cameraStartAnimator  = services.cameraStartAnimator
    this.cameraSwayAnimator   = services.cameraSwayAnimator
    this.cameraPresetResolver = services.cameraPresetResolver

    local events              = services.enums.events

    this.eventHandlers       = {
        lifetime = {
            [events.dialogueStarted] = this.onDialogueStarted,
            [events.dialogueEnded]   = this.onDialogueEnded,
        },
        dialogue = {
            [tes3.event.enterFrame]          = this.onEnterFrame,
            [events.settingsUpdated]         = this.onSettingsUpdated,
            [events.cameraPresetUpdated]     = this.onCameraPresetUpdated,
            [events.cameraAnimationReplayed] = this.onCameraAnimationReplayed,
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
    if not this.settings.cameraEnabled then
        return
    end
    this.setupWrappers()
    this.animationTime = 0
    this.animationDuration = this.cameraPresetResolver.resolve().animationDuration

    this.animators = { this.cameraStartAnimator }

    if this.settings.swayEnabled then
        table.insert(this.animators, this.cameraSwayAnimator)
    end

    this.dialogueState = e.dialogueState
    this.eventRegistrar.register(this.eventHandlers.dialogue)
end

---@private
function this.onDialogueEnded()
    this.eventRegistrar.unregister(this.eventHandlers.dialogue)
    this.resetWrappers()
    this.animators = {}
    this.dialogueState = nil
end

---@private
function this.onSettingsUpdated()
    this.animationDuration = this.cameraPresetResolver.resolve().animationDuration
end

---@private
---@param e cameraPresetUpdatedEventData
function this.onCameraPresetUpdated(e)
    this.animationDuration = e.preset.animationDuration
end

---@private
function this.onCameraAnimationReplayed()
    this.animationTime = 0
end

---@private
---@param e enterFrameEventData
function this.onEnterFrame(e)
    if this.dialogueState.paused then
        return
    end

    local duration     = this.animationDuration
    this.animationTime = math.min(this.animationTime + e.delta, duration)

    local t            = 1
    if duration > 0 then
        t = math.ease.smoothstep(this.animationTime / duration)
    end

    for i = 1, #this.animators do
        this.animators[i].update(this.cameraWrapper, this.skyWrapper, t, e.delta)
    end

    this.cameraWrapper:update()
    this.skyWrapper:update()
end

---@private
function this.setupWrappers()
    local camera       = tes3.worldController.worldCamera.cameraRoot
    local sky          = tes3.worldController.weatherController.sceneSkyRoot
    this.cameraWrapper = this.getOrCreateWrapper(camera, "cameraAnimator")
    this.skyWrapper    = this.getOrCreateWrapper(sky, "skyAnimator")
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
---@param target niNode
---@param name string
---@return niNode
function this.getOrCreateWrapper(target, name)
    if target.parent.name == name then
        return target.parent
    end

    local wrapper = niNode.new()
    wrapper.name  = name

    local parent  = target.parent
    wrapper:attachChild(target, true)
    parent:attachChild(wrapper, true)

    wrapper:update()
    return wrapper
end

return this
