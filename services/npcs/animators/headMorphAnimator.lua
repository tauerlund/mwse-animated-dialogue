---@class npcHeadMorphAnimator : initializedService, npcAnimator
local this = {}

---@private
this.minBlinkInterval = 2

---@private
this.maxBlinkInterval = 6

---@private
---@type number time accumulated since the last blink ended
this.blinkTimer = 0

---@private
---@type number seconds to wait before the next blink
this.blinkInterval = 0

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
    this.startBlinkTimer()
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

    local phase = animationData.lipsyncLevel ~= -1
        and this.getTalkPhase(animationData)
        or this.getBlinkPhase(animationData, delta)

    animationData.headNode:update({
        controllers = true,
        time        = phase
    })
end

---@private
---@param animationData tes3animationData
---@return number
function this.getTalkPhase(animationData)
    this.stopBlinkTimer()

    local level     = animationData.lipsyncLevel
    local startTime = animationData.talkMorphStartTime
    local endTime   = animationData.talkMorphEndTime
    local phase     = math.remap(level, 0, 1, startTime, endTime)
    return math.clamp(phase, startTime, endTime)
end

---@private
---@param animationData tes3animationData
---@param delta number
---@return number
function this.getBlinkPhase(animationData, delta)
    local startTime = animationData.blinkMorphStartTime
    local endTime   = animationData.blinkMorphEndTime
    local duration  = endTime - startTime

    this.blinkTimer = this.blinkTimer + delta

    if this.blinkTimer < this.blinkInterval then
        return startTime
    end

    local elapsed = this.blinkTimer - this.blinkInterval
    if elapsed >= duration then
        this.startBlinkTimer()
        return startTime
    end

    return startTime + elapsed
end

---@private
function this.startBlinkTimer()
    this.blinkTimer = 0
    this.blinkInterval = this.getRandomBlinkInterval()
end

---@private
function this.stopBlinkTimer()
    this.blinkTimer = 0
end

---@private
---@return number
function this.getRandomBlinkInterval()
    return this.minBlinkInterval + math.random() * (this.maxBlinkInterval - this.minBlinkInterval)
end

return this
