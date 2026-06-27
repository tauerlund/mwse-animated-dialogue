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

---@public
---@param services serviceCollection
---@return boolean,string|nil
function this.initialize(services)
    this.eventRegistrar   = services.eventRegistrar
    this.settings         = services.settings
    this.particleResolver = services.particleResolver
    this.particleAnimator = services.particleAnimator

    local events          = services.enums.events

    this.eventHandlers    = {
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

    if this.settings.effectsMode == "scene" then
        this.controllers = this.resolveSceneParticles(e.npc)
    else
        this.controllers = this.resolveNpcParticles(e.npc)
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
---@return niParticleSystemController[]
function this.resolveSceneParticles(npc)
    ---@type niParticleSystemController[]
    local controllers = {}

    local cell = npc.cell
    if not cell then
        return controllers
    end

    local origin = npc.position
    local maxDist = this.settings.effectsSceneDistance

    for ref in cell:iterateReferences(nil, false) do
        if ref.position:distance(origin) <= maxDist then
            local resolved = this.particleResolver.resolve(ref.sceneNode --[[@as niNode]])
            for _, controller in ipairs(resolved) do
                controllers[#controllers + 1] = controller
            end
        end
    end

    return controllers
end

---@private
---@param npc tes3reference
---@return niParticleSystemController[]
function this.resolveNpcParticles(npc)
    return this.particleResolver.resolve(npc.sceneNode --[[@as niNode]])
end

return this
