---@class npcHeadMorphAnimator : initializedService, npcAnimator
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
    this.npc = event.npc
end

---@private
function this.onDialogueEnded()
    this.npc = nil
end

---@public
---@param _ number
function this.update(_)
    local animationData = this.npc.animationData
    if not animationData then
        return
    end

    local phase
    if animationData.lipsyncLevel ~= -1 then
        phase = this.getTalkPhase(animationData)
    else
        phase = 0
    end

    animationData.headNode:update({
        controllers = true,
        time        = phase
    })
end

---@private
---@param animationData tes3animationData
---@return number
function this.getTalkPhase(animationData)
    local level     = animationData.lipsyncLevel
    local startTime = animationData.talkMorphStartTime
    local endTime   = animationData.talkMorphEndTime
    local phase     = math.remap(level, 0, 1, startTime, endTime)
    return math.clamp(phase, startTime, endTime)
end

return this
