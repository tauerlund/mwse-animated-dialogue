---@class headMorphAnimator : initializedService, actorAnimator
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
---@type tes3reference
this.actor = nil

---@private
---@type nodeResolver
this.nodeResolver = nil

---@private
---@type eventRegistrar
this.eventRegistrar = nil

---@private
---@type eventHandlers
this.eventHandlers = nil

---@private
---@type niTimeController[]
this.morphers = nil

---@private
this.resolved = false

---@private
---@type lipsyncController
this.lipsyncController = nil

---@public
---@param services serviceCollection
---@return boolean,string|nil
function this.initialize(services)
    this.nodeResolver      = services.nodeResolver
    this.lipsyncController = services.lipsyncController
    this.eventRegistrar    = services.eventRegistrar

    return true, nil
end

---@public
---@return headMorphAnimator
function this.create()
    local instance = setmetatable({}, { __index = this })

    instance.actor = nil
    instance.morphers = {}
    instance.resolved = false
    instance.blinkTimer = 0
    instance.blinkInterval = 0
    instance.eventHandlers = nil

    return instance
end

---@public
---@param reference tes3reference
function this:begin(reference)
    self.actor = reference
    self.resolved = false
    self.morphers = {}
    self.eventHandlers = {
        [tes3.event.bodyPartsUpdated] = function(e)
            self:onBodyPartsUpdated(e)
        end
    }
    self.eventRegistrar.register(self.eventHandlers)
    self:startBlinkTimer()
end

---@public
function this:stop()
    self.eventRegistrar.unregister(self.eventHandlers)
end

---@private
---@param e bodyPartsUpdatedEventData
function this:onBodyPartsUpdated(e)
    if e.reference ~= self.actor then
        return
    end

    self.resolved = false
    self.morphers = {}
end

---@public
---@param delta number
function this:update(delta)
    local animationData = self.actor.animationData
    if not animationData then
        return
    end

    if not animationData.headNode then
        return
    end

    if not self.resolved then
        self.morphers = self.nodeResolver.resolveControllers(
            animationData.headNode,
            ni.type.NiGeomMorpherController)
        self.resolved = true
    end

    local phase = self.lipsyncController.isActive(animationData)
        and self:getTalkPhase(animationData)
        or self:getBlinkPhase(animationData, delta)

    for i = 1, #self.morphers do
        local target = self.morphers[i].target --[[@as niNode]]
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
function this:getTalkPhase(animationData)
    self:stopBlinkTimer()

    local level     = self.lipsyncController.getLipsyncLevel(animationData)

    local startTime = animationData.talkMorphStartTime
    local endTime   = animationData.talkMorphEndTime

    local phase     = math.remap(level, 0, 1, startTime, endTime)
    return math.clamp(phase, startTime, endTime)
end

---@private
---@param animationData tes3animationData
---@param delta number
---@return number
function this:getBlinkPhase(animationData, delta)
    local startTime = animationData.blinkMorphStartTime
    local endTime   = animationData.blinkMorphEndTime
    local duration  = endTime - startTime

    self.blinkTimer = self.blinkTimer + delta

    if self.blinkTimer < self.blinkInterval then
        return startTime
    end

    local elapsed = self.blinkTimer - self.blinkInterval
    if elapsed >= duration then
        self:startBlinkTimer()
        return startTime
    end

    return startTime + elapsed
end

---@private
function this:startBlinkTimer()
    self.blinkTimer = 0
    self.blinkInterval = self:getRandomBlinkInterval()
end

---@private
function this:stopBlinkTimer()
    self.blinkTimer = 0
end

---@private
---@return number
function this:getRandomBlinkInterval()
    return self.minBlinkInterval + math.random() * (self.maxBlinkInterval - self.minBlinkInterval)
end

return this
