---@class weatherPrecipitationController : initializedService
local this = {}

---@private
---@type number
this.maxStep = 0.1

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
---@type boolean
this.paused = false

---@private
---@type number
this.minZ = 0

---@private
---@type number
this.columnHeight = 1

---@public
---@param services serviceCollection
---@return boolean,string|nil
function this.initialize(services)
    this.eventRegistrar = services.eventRegistrar
    this.settings       = services.settings

    local events        = services.enums.events

    this.eventHandlers  = {
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
---@return tes3weatherControllerParticle[]|nil
function this.getActiveParticles()
    local weatherController = tes3.worldController and tes3.worldController.weatherController
    if not weatherController then
        return nil
    end

    local particles = weatherController.particlesActive
    if not particles or #particles == 0 then
        return nil
    end

    return particles
end

---@private
---@param particles tes3weatherControllerParticle[]
function this.captureColumn(particles)
    local minZ = math.huge
    local maxZ = -math.huge

    for _, particle in ipairs(particles) do
        local object = particle.object
        if object then
            local z = object.translation.z
            if z < minZ then
                minZ = z
            end
            if z > maxZ then
                maxZ = z
            end
        end
    end

    this.minZ = minZ
    this.columnHeight = math.max(maxZ - minZ, 1)
end

---@private
---@param particles tes3weatherControllerParticle[]
---@param delta number
function this.advanceParticles(particles, delta)
    local dt = math.min(delta, this.maxStep)
    local minZ = this.minZ
    local columnHeight = this.columnHeight

    for _, particle in ipairs(particles) do
        local object = particle.object
        if object then
            -- Re-clear each frame: menu-mode freezes the engine's per-particle
            -- cull, which otherwise hides most of the column.
            object.appCulled = false

            local velocity = particle.velocity
            local position = object.translation

            -- Component-wise to avoid allocating a vector per particle per frame.
            position.x = position.x + velocity.x * dt
            position.y = position.y + velocity.y * dt
            position.z = position.z + velocity.z * dt

            if position.z < minZ then
                position.z = position.z + columnHeight
            end

            object.translation = position
        end
    end
end

---@private
---@param particles tes3weatherControllerParticle[]
function this.updateParticleTransforms(particles)
    local root = particles[1].rainRoot
    if root then
        root:update({ children = true })
    end
end

---@private
---@param e dialogueStartedEventData
function this.onDialogueStarted(e)
    if not this.settings.precipitationEnabled then
        return
    end

    local particles = this.getActiveParticles()
    if not particles then
        return
    end

    this.captureColumn(particles)
    this.paused = false

    this.eventRegistrar.register(this.eventHandlers.dialogue)
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
function this.onDialogueEnded()
    this.eventRegistrar.unregister(this.eventHandlers.dialogue)
end

---@private
---@param e enterFrameEventData
function this.onEnterFrame(e)
    if this.paused then
        return
    end

    local particles = this.getActiveParticles()
    if not particles then
        return
    end

    this.advanceParticles(particles, e.delta)
    this.updateParticleTransforms(particles)
end

return this
