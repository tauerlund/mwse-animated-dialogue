---@class cameraAnimator : initializedService
local this = {}

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
this.camera = nil

---@private
---@type niNode
this.sky = nil

---@public
---@param services serviceCollection
---@return boolean,string|nil
function this.initialize(services)
    this.eventRegistrar = services.eventRegistrar

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

function this.uninitialize()
    this.eventRegistrar.unregister(this.eventHandlers.lifetime)
end

---@private
---@param _ dialogueStartedEventData
function this.onDialogueStarted(_)
    this.eventRegistrar.register(this.eventHandlers.dialogue)
    this.camera = tes3.worldController.worldCamera.cameraRoot
    this.sky = tes3.worldController.weatherController.sceneSkyRoot
end

---@private
function this.onDialogueEnded()
    this.eventRegistrar.unregister(this.eventHandlers.dialogue)
    this.camera = nil
    this.sky = nil
end

---@private
---@param e enterFrameEventData
function this.onEnterFrame(e)
end

return this
