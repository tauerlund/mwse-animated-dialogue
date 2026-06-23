---@class npcControllersAnimator : initializedService, npcAnimator
local this = {}

---@private
---@type eventRegistrar
this.eventRegistrar = nil

---@private
---@type settings
this.settings = nil

---@private
---@type tes3reference
this.npc = nil

---@private
---@type number
this.phase = 0

---@private
this.eventHandlers = nil

---@public
---@param services serviceCollection
---@return boolean,string|nil
function this.initialize(services)
    this.eventRegistrar = services.eventRegistrar
    this.settings       = services.settings

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
---@param event dialogueStartedEventData
function this.onDialogueStarted(event)
    this.npc   = event.npc
    this.phase = 0
end

---@private
function this.onDialogueEnded()
    this.npc = nil
end

---@public
---@param delta number
function this.update(delta)
    local animationData = this.npc.animationData
    if not animationData then
        return
    end

    animationData.actorNode:update({
        controllers = true,
        children    = true,
        time        = this.phase
    })
    animationData.headNode:update({
        controllers = true,
        time        = 0
    })

    this.phase = this.phase + delta
    if this.phase >= 2.666667 then
        this.phase = 0
    end
end

return this
