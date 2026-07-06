---@class actorHeadMorphAnimator : initializedService, actorAnimator
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
this.actor = nil

---@private
---@type nodeResolver
this.nodeResolver = nil

---@private
---@type niTimeController[]
this.morphers = {}

---@private
this.resolved = false

---@private
this.eventHandlers = nil

---@private
---@type actorLipsyncController
this.lipsyncController = nil

---@public
---@param services serviceCollection
---@return boolean,string|nil
function this.initialize(services)
    this.eventRegistrar    = services.eventRegistrar
    this.settings          = services.settings
    this.nodeResolver      = services.nodeResolver
    this.lipsyncController = services.actorLipsyncController

    local events           = services.enums.events
    this.eventHandlers     = {
        [events.dialogueStarted]      = this.onDialogueStarted,
        [events.dialogueEnded]        = this.onDialogueEnded,
        [tes3.event.bodyPartsUpdated] = this.onBodyPartsUpdated,
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
    this.actor = event.actor
    this.resolved = false
    this.morphers = {}
    this.startBlinkTimer()
end

---@private
function this.onDialogueEnded()
    this.actor = nil
    this.resolved = false
    this.morphers = {}
end

---@private
---@param event bodyPartsUpdatedEventData
function this.onBodyPartsUpdated(event)
    if event.reference ~= this.actor then
        return
    end

    this.resolved = false
    this.morphers = {}
end

---@public
---@param delta number
function this.update(delta)
    local animationData = this.actor.animationData
    if not animationData then
        return
    end

    if not animationData.headNode then
        return
    end

    if not this.resolved then
        this.morphers = this.nodeResolver.resolveControllers(
            animationData.headNode,
            ni.type.NiGeomMorpherController)
        this.resolved = true
    end

    local phase = this.lipsyncController.isActive(animationData)
        and this.getTalkPhase(animationData)
        or this.getBlinkPhase(animationData, delta)

    for i = 1, #this.morphers do
        local target = this.morphers[i].target --[[@as niNode]]
        if target then
            target:update({
                controllers = true,
                time        = phase
            })
        end
    end
end

---@private
---@param animationData tes3animationData
---@return number
function this.getTalkPhase(animationData)
    this.stopBlinkTimer()

    local level     = this.lipsyncController.getLipsyncLevel(animationData)

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
