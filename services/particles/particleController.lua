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
---@type boolean
this.paused = false

---@private
---@type niParticleSystemController[]
this.controllers = {}

---@private
---@type { [string]: fun(npc: tes3reference) }
this.resolveParticlesStrategies = nil

---@public
---@param services serviceCollection
---@return boolean,string|nil
function this.initialize(services)
    this.eventRegistrar             = services.eventRegistrar
    this.settings                   = services.settings
    this.particleResolver           = services.particleResolver
    this.particleAnimator           = services.particleAnimator

    local events                    = services.enums.events

    this.eventHandlers              = {
        lifetime = {
            [events.dialogueStarted] = this.onDialogueStarted,
            [events.dialogueEnded]   = this.onDialogueEnded,
        },
        dialogue = {
            [tes3.event.enterFrame] = this.onEnterFrame,
            [events.gamePaused]     = this.onGamePaused,
            [events.gameUnpaused]   = this.onGameUnpaused,
        }
    }

    local effectModes               = services.enums.effectModes

    this.resolveParticlesStrategies = {
        [effectModes.npc] = this.resolveNpcParticles,
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

    this.paused = false

    local resolve = this.resolveParticlesStrategies[this.settings.effectsMode]
    if resolve then
        resolve(e.npc)
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
end

---@private
function this.onGamePaused()
    this.paused = true
end

---@private
function this.onGameUnpaused()
    this.paused = false
end

---@private
---@param e enterFrameEventData
function this.onEnterFrame(e)
    if this.paused then
        return
    end

    this.particleAnimator.update(this.controllers, e.delta)
end

---@private
---@param npc tes3reference
function this.resolveNpcParticles(npc)
    this.controllers = this.particleResolver.resolve(npc.sceneNode --[[@as niNode]])
end

---@private
---@param npc tes3reference
function this.resolveCurrentCellParticles(npc)
    this.resolveCellParticles(npc, npc.cell)
end

---@private
---@param npc tes3reference
function this.resolveActiveCellsParticles(npc)
    for _, cell in ipairs(tes3.getActiveCells()) do
        this.resolveCellParticles(npc, cell)
    end
end

---@private
---@param npc tes3reference
---@param cell tes3cell?
function this.resolveCellParticles(npc, cell)
    if not cell then
        return
    end

    local origin = npc.position
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
