---@class particleController : initializedService
local this = {}

---@private
---@type settings
this.settings = nil

---@private
---@type eventRegistrar
this.eventRegistrar = nil

---@private
---@type particleResolver
this.particleResolver = nil

---@private
---@type particleAnimator
this.particleAnimator = nil

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
---@type niParticleSystemController[]
this.controllers = {}

---@private
---@type { [string]: fun(actor: tes3reference) }
this.resolveParticlesStrategies = nil

---@public
---@param services serviceCollection
---@return boolean,string|nil
function this.initialize(services)
    this.eventRegistrar             = services.eventRegistrar
    this.settings                   = services.settings
    this.particleResolver           = services.particleResolver
    this.particleAnimator           = services.particleAnimator

    local events                    = services.constants.events

    this.eventHandlers              = {
        lifetime = {
            [events.dialogueStarted] = this.onDialogueStarted,
            [events.dialogueEnded]   = this.onDialogueEnded,
        },
        dialogue = {
            [tes3.event.enterFrame] = this.onEnterFrame,
        }
    }

    local effectModes               = services.constants.effectModes

    this.resolveParticlesStrategies = {
        [effectModes.actor] = this.resolveActorParticles,
        [effectModes.currentCell] = this.resolveCurrentCellParticles,
        [effectModes.activeCells] = this.resolveActiveCellsParticles
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
    if not this.settings.particlesEnabled then
        return
    end

    this.controllers = {}
    this.dialogueState = e.dialogueState

    local resolve = this.resolveParticlesStrategies[this.settings.effectsMode]
    if resolve then
        resolve(e.dialogueState.actor)
    end

    if #this.controllers == 0 then
        return
    end

    this.eventRegistrar.register(this.eventHandlers.dialogue)
end

---@private
function this.onDialogueEnded()
    this.eventRegistrar.unregister(this.eventHandlers.dialogue)
    this.controllers = {}
    this.dialogueState = nil
end

---@private
---@param e enterFrameEventData
function this.onEnterFrame(e)
    if this.dialogueState.paused then
        return
    end

    this.particleAnimator.update(this.controllers, e.delta)
end

---@private
---@param actor tes3reference
function this.resolveActorParticles(actor)
    this.controllers = this.particleResolver.resolve(actor.sceneNode --[[@as niNode]])
end

---@private
---@param actor tes3reference
function this.resolveCurrentCellParticles(actor)
    this.resolveCellParticles(actor, actor.cell)
end

---@private
---@param actor tes3reference
function this.resolveActiveCellsParticles(actor)
    for _, cell in ipairs(tes3.getActiveCells()) do
        this.resolveCellParticles(actor, cell)
    end
end

---@private
---@param actor tes3reference
---@param cell tes3cell?
function this.resolveCellParticles(actor, cell)
    if not cell then
        return
    end

    local origin = actor.position
    local maxDist = this.settings.effectsCellDistance

    for ref in cell:iterateReferences(nil, false) do
        if ref.position:distance(origin) <= maxDist then
            local resolved = this.particleResolver.resolve(ref.sceneNode --[[@as niNode]])
            for _, controller in ipairs(resolved) do
                this.controllers[#this.controllers + 1] = controller
            end
        end
    end
end

return this
