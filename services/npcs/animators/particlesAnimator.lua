---@class npcParticlesAnimator : initializedService, npcAnimator
local this = {}

---@private
---@type eventRegistrar
this.eventRegistrar = nil

---@private
---@type eventHandlers
this.eventHandlers = nil

---@private
---@type particleController
this.particleController = nil

---@private
---@type niParticleSystemController[]
this.particleControllers = {}

---@public
---@param services serviceCollection
---@return boolean,string|nil
function this.initialize(services)
    this.eventRegistrar     = services.eventRegistrar
    this.particleController = services.particleController

    local events            = services.enums.events
    this.eventHandlers      = {
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
---@param e dialogueStartedEventData
function this.onDialogueStarted(e)
    this.particleControllers = this.particleController.resolve(e.npc.sceneNode --[[@as niNode]])
end

---@private
function this.onDialogueEnded()
    this.particleControllers = {}
end

---@public
---@param delta number
function this.update(delta)
    this.particleController.update(this.particleControllers, delta)
end

return this
