---@class npcAnimator : initializedService
local this = {}

---@private
---@type eventRegistrar
this.eventRegistrar = nil

---@private
---@type enums
this.enums = nil

---@private
---@type npcConstants
this.constants = nil

---@private
---@type eventHandlerGroups
this.eventHandlers = {
    lifetime = {},
    dialogue = {}
}

---@private
---@type tes3reference
this.npc = nil

---@private
---@type niNode
this.head = nil

---@private
---@type number
this.phase = 0

---@public
---@param services serviceCollection
---@return boolean,string|nil
function this.initialize(services)
    this.eventRegistrar = services.eventRegistrar
    this.enums = services.enums
    this.constants = services.enums.constants.npcs

    local events = this.enums.events

    this.eventHandlers = {
        lifetime = {
            [events.dialogueStarted] = this.onDialogueStarted,
            [events.dialogueEnded] = this.onDialogueEnded,
        },
        dialogue = {
            [tes3.event.enterFrame] = this.onEnterFrame,
        }
    }

    this.eventRegistrar.register(this.eventHandlers.lifetime)

    return true, nil
end

function this.uninitialize()
    this.eventRegistrar.unregister(this.eventHandlers.lifetime)
end

---@private
---@param e dialogueStartedEventData
function this.onDialogueStarted(e)
    this.npc = e.npc
    this.head = e.npc.sceneNode:getObjectByName(this.constants.headNodeName) --[[@as niNode]]
    this.phase = 0
    this.eventRegistrar.register(this.eventHandlers.dialogue)
end

---@private
function this.onDialogueEnded()
    this.eventRegistrar.unregister(this.eventHandlers.dialogue)
    this.npc = nil
    this.head = nil
end

---@private
---@param e enterFrameEventData
function this.onEnterFrame(e)
    local delta = e.delta

    this.updateControllers()
    this.updateHead()
    this.incrementPhase(delta)
end

---@private
function this.updateControllers()
    this.npc.sceneNode:update({
        controllers = true,
        children = true,
        time = this.phase
    })
end

---@private
function this.updateHead()
    local phase = this.isSpeaking()
        and this.getLipsyncPhase()
        or 0

    this.head:update({
        controllers = true,
        time = phase
    })
end

---@private
---@param delta number
function this.incrementPhase(delta)
    this.phase = math.min(this.phase + delta, 2.666667)
    if this.phase >= 2.666667 then
        this.phase = 0
    end
end

---@private
---@return boolean
function this.isSpeaking()
    return this.npc.attachments.animation.lipsyncLevel ~= -1
end

---@private
---@return number
function this.getLipsyncPhase()
    local lipsyncLevel = this.npc.attachments.animation.lipsyncLevel

    -- TODO: Get these values dynamically from the mesh node instead of hardcoding
    local lipSyncStartTime = this.constants.lipsyncStartTime
    local lipSyncEndTime = this.constants.lipsyncEndTime

    local phase = math.remap(lipsyncLevel, 0, 1, lipSyncStartTime, lipSyncEndTime)

    return math.clamp(phase, lipSyncStartTime, lipSyncEndTime)
end

return this
