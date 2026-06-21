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
this.originalWrapperPosition = nil

---@private
---@type tes3vector3
this.targetOffset = nil

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
    this.setupWrappers()
    this.computeTargetOffset(e.npc)
    this.animationTime = 0

    this.eventRegistrar.register(this.eventHandlers.dialogue)
end

---@private
function this.onDialogueEnded()
    this.eventRegistrar.unregister(this.eventHandlers.dialogue)
    this.resetWrappers()
    this.targetOffset = nil
end

---@private
---@param e enterFrameEventData
function this.onEnterFrame(e)
    if not this.targetOffset then
        return
    end

    local settings = this.settings

    this.animationTime = math.min(this.animationTime + e.delta, settings.animationDuration)
    local t = math.ease.smoothstep(this.animationTime / settings.animationDuration)
    local offset = this.originalWrapperPosition:lerp(this.originalWrapperPosition + this.targetOffset, t)

    this.applyOffset(offset)
end

---@private
function this.setupWrappers()
    local camera = tes3.worldController.worldCamera.cameraRoot
    local sky = tes3.worldController.weatherController.sceneSkyRoot

    this.cameraWrapper = this.getOrCreateWrapper(camera, "cameraAnimator")
    this.skyWrapper = this.getOrCreateWrapper(sky, "skyAnimator")
    this.originalWrapperPosition = this.cameraWrapper.translation:copy()
end

---@private
function this.resetWrappers()
    if not this.cameraWrapper or not this.originalWrapperPosition then
        return
    end
    this.applyOffset(this.originalWrapperPosition)
end

---@private
---@param offset tes3vector3
function this.applyOffset(offset)
    this.cameraWrapper.translation = offset
    this.cameraWrapper:update()
    this.skyWrapper.translation = offset
    this.skyWrapper:update()
end

---@private
---@param npc tes3reference
function this.computeTargetOffset(npc)
    local data = npc.animationData
    if not data or not data.headNode then
        return nil
    end

    local headPosition = data.headNode.worldTransform.translation
    local cameraPosition = tes3.getCameraPosition()
    local distance = cameraPosition:distance(headPosition)
    local direction = (headPosition - cameraPosition):normalized()

    this.targetOffset = direction * (distance - this.settings.distance)
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
