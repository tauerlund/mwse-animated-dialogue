---@class npcAnimator : initializedService
local this = {}

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
---@type tes3reference
this.npc = nil

---@private
---@type number
this.phase = 0

---@public
---@param services serviceCollection
---@return boolean,string|nil
function this.initialize(services)
    this.eventRegistrar = services.eventRegistrar

    local events = services.enums.events

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

---@public
function this.uninitialize()
    this.eventRegistrar.unregister(this.eventHandlers.lifetime)
end

---@private
---@param e dialogueStartedEventData
function this.onDialogueStarted(e)
    this.npc = e.npc
    this.phase = 0
    this.eventRegistrar.register(this.eventHandlers.dialogue)
end

---@private
function this.onDialogueEnded()
    this.eventRegistrar.unregister(this.eventHandlers.dialogue)
    this.npc = nil
end

---@private
---@param e enterFrameEventData
function this.onEnterFrame(e)
    local data = this.npc.animationData
    if not data then
        return
    end

    this.updateControllers(data)
    this.updateHead(data)
    this.incrementPhase(e.delta)
end

---@private
---@param data tes3animationData
function this.updateControllers(data)
    data.actorNode:update({
        controllers = true,
        children = true,
        time = this.phase
    })
end

---@private
---@param data tes3animationData
function this.updateHead(data)
    local phase = this.isTalking()
        and this.getTalkPhase()
        or 0

    data.headNode:update({
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
function this.isTalking()
    return this.npc.animationData.lipsyncLevel ~= -1
end

---@private
---@return number
function this.getTalkPhase()
    local data = this.npc.animationData
    if not data then
        return 0
    end

    local level = data.lipsyncLevel
    local startTime = data.talkMorphStartTime
    local endTime = data.talkMorphEndTime

    local phase = math.remap(level, 0, 1, startTime, endTime)

    return math.clamp(phase, startTime, endTime)
end

return this
