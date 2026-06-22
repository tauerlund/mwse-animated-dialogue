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
---@type tes3reference|nil
this.npc = nil

---@private
---@type mwseTimer|nil
this.animationTimer = nil

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
function this.uninitialize()
    this.eventRegistrar.unregister(this.eventHandlers.lifetime)
end

---@private
---@param e dialogueStartedEventData
function this.onDialogueStarted(e)
    this.pauseRenderingInMenus = mge.render.pauseRenderingInMenus

    mge.render.pauseRenderingInMenus = false

    if this.depthOfField and this.settings.dofEnabled then
        this.npc = e.npc

        this.depthOfField["focal_length"] = 0
        this.depthOfField.enabled = true

        this.animationTime = 0

        this.eventRegistrar.register(this.eventHandlers.dialogue)
        this.animationTimer = timer.start({
            duration = this.settings.animationDuration,
            type = timer.real,
            callback = this.onAnimationComplete,
        })
    end
end

---@private
function this.onDialogueEnded()
    mge.render.pauseRenderingInMenus = this.pauseRenderingInMenus

    if this.animationTimer then
        this.animationTimer:cancel()
        this.animationTimer = nil
    end
    this.eventRegistrar.unregister(this.eventHandlers.dialogue)
    this.npc = nil

    if this.depthOfField then
        this.depthOfField.enabled = false
    end
end

---@private
function this.onAnimationComplete()
    this.eventRegistrar.unregister(this.eventHandlers.dialogue)
    this.depthOfField["focal_length"] = this.settings.dofStrength
    this.animationTimer = nil
end

---@private
---@param e enterFrameEventData
function this.onEnterFrame(e)
    local settings = this.settings

    this.animationTime = math.min(this.animationTime + e.delta, settings.animationDuration)
    local t = math.ease.smoothstep(this.animationTime / settings.animationDuration)

    this.depthOfField["focal_length"] = t * settings.dofStrength

    local animData = this.npc.animationData
    local npcPos = animData and animData.headNode
        and animData.headNode.worldTransform.translation
        or this.npc.position

    this.depthOfField["focus_distance"] = (tes3.getCameraPosition() - npcPos):length() * 0.0142
end

return this
