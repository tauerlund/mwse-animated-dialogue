---@class renderingController : initializedService
local this = {}

---@private
---@type eventRegistrar
this.eventRegistrar = nil

---@private
this.eventHandlers = {
    lifetime = {},
    dialogue = {}
}

---@private
---@type boolean
this.pauseRenderingInMenus = nil

---@private
---@type mgeShaderHandle|nil
this.depthOfField = nil

---@private
---@type settings
this.settings = nil

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
---@type tes3reference|nil
this.actor = nil

---@private
---@type dialogueState
this.dialogueState = nil

---@public
---@param services serviceCollection
---@return boolean,string|nil
function this.initialize(services)
    this.eventRegistrar = services.eventRegistrar
    this.settings = services.settings
    this.cameraPresetResolver = services.cameraPresetResolver

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

    if not mge or not mge.shaders then
        return false, "Valid MGE XE API not found"
    end

    this.depthOfField = mge.shaders.load({ name = "animated-dialogue/Bokeh" })

    if this.depthOfField then
        this.depthOfField.enabled = false
    end

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
    this.pauseRenderingInMenus = mge.render.pauseRenderingInMenus

    mge.render.pauseRenderingInMenus = false

    if this.depthOfField and this.settings.dofEnabled then
        this.actor = e.dialogueState.actor
        this.depthOfField["focal_length"] = 0
        this.depthOfField.enabled = true
        this.animationTime = 0
        this.animationDuration = this.cameraPresetResolver.resolve().animationDuration
        this.dialogueState = e.dialogueState
        this.eventRegistrar.register(this.eventHandlers.dialogue)
    end
end

---@private
function this.onDialogueEnded()
    mge.render.pauseRenderingInMenus = this.pauseRenderingInMenus

    this.eventRegistrar.unregister(this.eventHandlers.dialogue)
    this.actor = nil
    this.dialogueState = nil

    if this.depthOfField then
        this.depthOfField.enabled = false
    end
end

---@private
---@param e enterFrameEventData
function this.onEnterFrame(e)
    if this.dialogueState.paused then
        return
    end

    local settings = this.settings
    local duration = this.animationDuration

    this.animationTime = math.min(this.animationTime + e.delta, duration)

    local t = 1
    if duration > 0 then
        t = math.ease.smoothstep(this.animationTime / duration)
    end

    this.depthOfField["focal_length"] = t * settings.dofStrength

    local animData = this.actor.animationData
    local actorPos = animData and animData.headNode
        and animData.headNode.worldTransform.translation
        or this.actor.position

    this.depthOfField["focus_distance"] = (tes3.getCameraPosition() - actorPos):length() * 0.0142

    if this.animationTime >= duration and not settings.debuggingEnabled then
        this.eventRegistrar.unregister(this.eventHandlers.dialogue)
    end
end

return this
