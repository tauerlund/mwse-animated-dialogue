---@class weatherStormController : initializedService
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
---@type boolean
this.paused = false

---@private
---@type niParticleSystemController[]
this.stormControllers = {}

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

-- Ash/blight/blizzard storms are NiParticleSystem meshes under sceneStormRoot,
-- driven by NiParticleSystemControllers the engine stops ticking in menu-mode
-- (the same class as NPC torch flames). All three storm clouds coexist in the
-- graph with only the current one visible, so controllers are collected from
-- non-culled nodes only -- this animates just the active storm and also gates
-- the whole path off during rain/clear (those clouds are culled).
---@private
---@return niParticleSystemController[]
function this.getStormControllers()
    local controllers = {}

    local weatherController = tes3.worldController and tes3.worldController.weatherController
    if weatherController then
        this.collectVisibleParticleControllers(weatherController.sceneStormRoot, controllers)
    end

    return controllers
end

---@private
---@param node niNode|nil
---@param controllers niParticleSystemController[]
function this.collectVisibleParticleControllers(node, controllers)
    if not node or node.appCulled then
        return
    end

    local controller = node.controller --[[@as niParticleSystemController]]
    while controller do
        if controller:isOfType(ni.type.NiParticleSystemController) then
            controllers[#controllers + 1] = controller
        end
        controller = controller.nextController --[[@as niParticleSystemController]]
    end

    if node.children then
        for _, child in ipairs(node.children) do
            this.collectVisibleParticleControllers(child --[[@as niNode]], controllers)
        end
    end
end

---@private
---@param delta number
function this.advanceStorm(delta)
    for _, controller in ipairs(this.stormControllers) do
        local target = controller.target --[[@as niNode]]
        if target then
            target:update({ controllers = true, time = controller.lastTime + delta })
        end
    end
end

---@private
---@param e dialogueStartedEventData
function this.onDialogueStarted(e)
    if not this.settings.precipitationEnabled then
        return
    end

    local stormControllers = this.getStormControllers()
    if #stormControllers == 0 then
        return
    end

    this.stormControllers = stormControllers
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
    this.stormControllers = {}
end

---@private
---@param e enterFrameEventData
function this.onEnterFrame(e)
    if this.paused then
        return
    end

    this.advanceStorm(e.delta)
end

return this
