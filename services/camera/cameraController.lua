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
---@type cameraAnimator[]
this.animators = {}

---@private
---@type cameraStartAnimator
this.cameraStartAnimator = nil

---@private
---@type cameraSwayAnimator
this.cameraSwayAnimator = nil

---@public
---@param services serviceCollection
---@return boolean,string|nil
function this.initialize(services)
    this.eventRegistrar      = services.eventRegistrar
    this.settings            = services.settings
    this.cameraStartAnimator = services.cameraStartAnimator
    this.cameraSwayAnimator  = services.cameraSwayAnimator

    local events             = services.enums.events

    this.eventHandlers       = {
        lifetime = {
            [events.dialogueStarted] = this.onDialogueStarted,
            [events.dialogueEnded]   = this.onDialogueEnded,
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
    this.animationTime = 0

    this.animators = { this.cameraStartAnimator }

    if this.settings.swayEnabled then
        table.insert(this.animators, this.cameraSwayAnimator)
    end

    this.eventRegistrar.register(this.eventHandlers.dialogue)
end

---@private
function this.onDialogueEnded()
    this.eventRegistrar.unregister(this.eventHandlers.dialogue)
    this.resetWrappers()
    this.animators = {}
end

---@private
---@param e enterFrameEventData
function this.onEnterFrame(e)
    local settings     = this.settings
    this.animationTime = math.min(this.animationTime + e.delta, settings.animationDuration)
    local t            = math.ease.smoothstep(this.animationTime / settings.animationDuration)

    for _, animator in ipairs(this.animators) do
        animator.update(this.cameraWrapper, this.skyWrapper, t, e.delta)
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
