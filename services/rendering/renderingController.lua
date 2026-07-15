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
---@type mgeShaderHandle|nil
this.letterbox = nil

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

    this.letterbox = mge.shaders.load({ name = "animated-dialogue/letterbox" })

    if this.letterbox then
        this.letterbox.enabled = false
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

    local dofActive = this.depthOfField and this.settings.dofEnabled
    local letterboxActive = this.letterbox and this.settings.letterboxEnabled

    if not dofActive and not letterboxActive then
        return
    end

    this.actor = e.dialogueState.actor
    this.dialogueState = e.dialogueState
    this.animationTime = 0
    this.animationDuration = this.cameraPresetResolver.resolve().animationDuration

    if dofActive then
        this.depthOfField["focal_length"] = 0
        this.depthOfField.enabled = true
    end

    if letterboxActive then
        this.letterbox["amount"] = 0
        this.letterbox.enabled = true
    end

    this.eventRegistrar.register(this.eventHandlers.dialogue)
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

    if this.letterbox then
        this.letterbox.enabled = false
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

    if this.depthOfField and settings.dofEnabled then
        this.depthOfField["focal_length"] = t * settings.dofStrength

        local animData = this.actor.animationData
        local actorPos = animData and animData.headNode
            and animData.headNode.worldTransform.translation
            or this.actor.position

        this.depthOfField["focus_distance"] = (tes3.getCameraPosition() - actorPos):length() * 0.0142
    end

    if this.letterbox and settings.letterboxEnabled then
        this.letterbox["amount"] = t
    end

    if this.animationTime >= duration and not settings.debuggingEnabled then
        this.eventRegistrar.unregister(this.eventHandlers.dialogue)
    end
end

return this
