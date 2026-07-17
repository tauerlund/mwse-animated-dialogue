---@class lipsyncController : initializedService
local this = {}

---@private
this.tuning = {
    mouthFrequency1 = 5.5,
    mouthFrequency2 = 8.0,
    mouthWeight1 = 0.65,
    mouthWeight2 = 0.35,
    frequencyJitter = 0.15,
    minOpenness = 0.08,

    wordDurationMin = 0.22,
    wordDurationMax = 0.65,
    pauseDurationMin = 0.06,
    pauseDurationMax = 0.20,
    sentencePauseChance = 0.2,
    sentencePauseMin = 0.3,
    sentencePauseMax = 0.6,
    speechLevelEaseRate = 20,

    intensity = 0.9,

    charsPerSecond = 14,
    minDuration = 0.8,
    tailDuration = 0.2,
}

---@private
this.twoPi = math.pi * 2

---@private
---@type number
this.simulatedLevel = -1

---@private
---@type number
this.speechRemaining = 0

---@private
---@type number
this.time = 0

---@private
---@type number
this.speechLevel = 0

---@private
---@type boolean
this.speaking = false

---@private
---@type number
this.segmentRemaining = 0

---@private
---@type mouthMotion
this.mouth = { frequency1 = 0, frequency2 = 0, phase1 = 0, phase2 = 0 }

---@private
---@type eventRegistrar
this.eventRegistrar = nil

---@private
---@type settings
this.settings = nil

---@private
---@type events
this.events = nil

---@private
---@type tes3reference
this.actor = nil

---@private
this.eventHandlers = nil

---@public
---@param services serviceCollection
---@return boolean,string|nil
function this.initialize(services)
    this.eventRegistrar = services.eventRegistrar
    this.settings       = services.settings
    this.events         = services.constants.events

    this.eventHandlers  = {
        [this.events.dialogueStarted] = this.onDialogueStarted,
        [this.events.dialogueEnded]   = this.onDialogueEnded,
        [this.events.dialogueInfo]    = this.onDialogueInfo,
    }

    this.eventRegistrar.register(this.eventHandlers)

    return true, nil
end

---@public
function this.uninitialize()
    this.eventRegistrar.unregister(this.eventHandlers)
end

---@public
---@param data tes3animationData
---@return boolean
function this.isActive(data)
    return this.getLipsyncLevel(data) ~= -1
end

---@public
---@param data tes3animationData
---@return number
function this.getLipsyncLevel(data)
    local nativeLevel = data.lipsyncLevel
    if nativeLevel ~= -1 then
        return nativeLevel
    end

    return this.simulatedLevel
end

---@private
---@param event dialogueStartedEventData
function this.onDialogueStarted(event)
    this.actor = event.dialogueState.actor
    this.reset()
end

---@private
function this.onDialogueEnded()
    this.actor = nil
    this.reset()
end

---@private
function this.reset()
    this.simulatedLevel = -1
    this.speechRemaining = 0
    this.time = 0
    this.speechLevel = 0
    this.speaking = false
    this.segmentRemaining = 0
end

---@private
---@param event dialogueInfoEventData
function this.onDialogueInfo(event)
    if not this.settings.actorSimulatedVoiceEnabled then
        return
    end

    if not this.actor or event.actor ~= this.actor then
        return
    end

    this.beginSpeech(event.text)
end

---@private
---@param text string
function this.beginSpeech(text)
    this.speechRemaining = this.estimateDuration(text)
    this.time = 0
    this.speechLevel = 0
    this.speaking = true
    this.segmentRemaining = this.randomWordDuration()
    this.randomizeMouth()
end

---@private
---@param text string
---@return number
function this.estimateDuration(text)
    local tuning = this.tuning
    local length = text and #text or 0

    local duration = length / tuning.charsPerSecond + tuning.tailDuration
    return math.clamp(duration, tuning.minDuration, this.settings.actorSimulatedVoiceMaxDuration)
end

---@private
function this.randomizeMouth()
    local mouth = this.mouth
    mouth.frequency1 = this.jitterFrequency(this.tuning.mouthFrequency1)
    mouth.frequency2 = this.jitterFrequency(this.tuning.mouthFrequency2)
    mouth.phase1 = math.random() * this.twoPi
    mouth.phase2 = math.random() * this.twoPi
end

---@private
---@param frequency number
---@return number
function this.jitterFrequency(frequency)
    local jitter = math.lerp(-this.tuning.frequencyJitter, this.tuning.frequencyJitter, math.random())
    return frequency * (1 + jitter)
end

---@private
---@return number
function this.readNativeLevel()
    if not this.actor then
        return -1
    end

    local animationData = this.actor.animationData
    if not animationData then
        return -1
    end

    return animationData.lipsyncLevel
end

---@public
---@param delta number
function this.update(delta)
    local native = this.readNativeLevel()

    if native ~= -1 then
        this.speechRemaining = 0
        this.simulatedLevel = -1
        return
    end

    if this.speechRemaining <= 0 then
        this.simulatedLevel = -1
        return
    end

    this.speechRemaining = this.speechRemaining - delta
    if this.speechRemaining <= 0 then
        this.simulatedLevel = -1
        return
    end

    this.time = this.time + delta
    this.advanceSpeechLevel(delta)

    local openness = this.sampleMouthOpenness()
    this.simulatedLevel = math.clamp(this.speechLevel * openness * this.tuning.intensity, 0, 1)
end

---@private
---@param delta number
function this.advanceSpeechLevel(delta)
    this.segmentRemaining = this.segmentRemaining - delta

    while this.segmentRemaining <= 0 do
        this.speaking = not this.speaking
        this.segmentRemaining = this.segmentRemaining + this.nextSegmentDuration()
    end

    local target = this.speaking and 1 or 0
    this.speechLevel = this.easeTowards(this.speechLevel, target, this.tuning.speechLevelEaseRate, delta)
end

---@private
---@return number
function this.nextSegmentDuration()
    if this.speaking then
        return this.randomWordDuration()
    end

    local tuning = this.tuning
    if math.random() < tuning.sentencePauseChance then
        return this.scaleBySpeed(this.randomRange(tuning.sentencePauseMin, tuning.sentencePauseMax))
    end

    return this.scaleBySpeed(this.randomRange(tuning.pauseDurationMin, tuning.pauseDurationMax))
end

---@private
---@return number
function this.randomWordDuration()
    return this.scaleBySpeed(this.randomRange(this.tuning.wordDurationMin, this.tuning.wordDurationMax))
end

---@private
---@param duration number
---@return number
function this.scaleBySpeed(duration)
    local speed = this.settings.actorSimulatedVoiceSpeed
    if speed <= 0 then
        return duration
    end

    return duration / speed
end

---@private
---@param minimum number
---@param maximum number
---@return number
function this.randomRange(minimum, maximum)
    return math.lerp(minimum, maximum, math.random())
end

---@private
---@return number
function this.sampleMouthOpenness()
    local mouth = this.mouth
    local tuning = this.tuning

    local wave = tuning.mouthWeight1 * math.sin(this.time * mouth.frequency1 + mouth.phase1)
        + tuning.mouthWeight2 * math.sin(this.time * mouth.frequency2 + mouth.phase2)

    local magnitude = math.abs(wave) / (tuning.mouthWeight1 + tuning.mouthWeight2)
    return math.lerp(tuning.minOpenness, 1, magnitude)
end

---@private
---@param current number
---@param target number
---@param rate number
---@param delta number
---@return number
function this.easeTowards(current, target, rate, delta)
    return current + (target - current) * (1 - math.exp(-rate * delta))
end

return this
