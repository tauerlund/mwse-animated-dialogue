---@class npcParticlesAnimator : initializedService, npcAnimator
local this = {}

---@private
---@type eventRegistrar
this.eventRegistrar = nil

---@private
---@type eventHandlers
this.eventHandlers = nil

---@private
---@type niParticleSystemController[]
this.particleControllers = {}

---@public
---@param services serviceCollection
---@return boolean,string|nil
function this.initialize(services)
    this.eventRegistrar = services.eventRegistrar

    local events        = services.enums.events
    this.eventHandlers  = {
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
    local node = e.npc.sceneNode

    ---@type niParticleSystemController[]
    local controllers = {}

    this.discoverControllers(controllers, node --[[@as niNode]])

    this.particleControllers = controllers
end

---@private
function this.onDialogueEnded()
    this.particleControllers = {}
end

---@private
---@param controllers niParticleSystemController[]
---@param node niNode
function this.discoverControllers(controllers, node)
    if not node then
        return
    end

    local controller = node.controller
    while controller do
        if controller:isOfType(ni.type.NiParticleSystemController) then
            table.insert(controllers, controller)
        end
        controller = controller.nextController
    end

    if not node.children then
        return
    end

    for _, child in ipairs(node.children) do
        this.discoverControllers(controllers, child --[[@as niNode]])
    end
end

---@public
---@param delta number
function this.update(delta)
    for _, controller in ipairs(this.particleControllers) do
        local node = controller.target --[[@as niNode]]
        if node then
            node:update({ controllers = true, time = controller.lastTime + delta })
        end
    end
end

return this
