---@class dialogueCircuitBreaker : initializedService
local this = {}

---@private
---@type eventRegistrar
this.eventRegistrar = nil

---@private
---@type eventHandlerGroups
this.eventHandlers = nil

---@private
---@type dialogueController
this.dialogueController = nil

---@private
---@type tes3reference|nil
this.actor = nil

---@public
---@param services serviceCollection
---@return boolean,string|nil
function this.initialize(services)
    this.eventRegistrar = services.eventRegistrar
    this.dialogueController = services.dialogueController

    local events = services.enums.events

    this.eventHandlers = {
        lifetime = {
            [events.dialogueStarted] = this.onDialogueStarted,
            [events.dialogueEnded] = this.onDialogueEnded,
        },
        dialogue = {
            [tes3.event.load] = this.onLoad,
            [tes3.event.referenceDeactivated] = this.onReferenceDeactivated,
        }
    }

    this.eventRegistrar.register(this.eventHandlers.lifetime)

    return true, nil
end

---@public
---@param services serviceCollection
---@return initializedService[]
function this.dependencies(services)
    return { services.dialogueController }
end

---@public
function this.uninitialize()
    this.eventRegistrar.unregister(this.eventHandlers.lifetime)
    this.eventRegistrar.unregister(this.eventHandlers.dialogue)
end

---@private
---@param e dialogueStartedEventData
function this.onDialogueStarted(e)
    this.actor = e.dialogueState.actor
    this.eventRegistrar.register(this.eventHandlers.dialogue)
end

---@private
function this.onDialogueEnded()
    this.eventRegistrar.unregister(this.eventHandlers.dialogue)
    this.actor = nil
end

---@private
---@param _ loadEventData
function this.onLoad(_)
    this.dialogueController.endDialogue()
end

---@private
---@param e referenceDeactivatedEventData
function this.onReferenceDeactivated(e)
    if e.reference ~= this.actor then
        return
    end

    this.dialogueController.endDialogue()
end

return this
