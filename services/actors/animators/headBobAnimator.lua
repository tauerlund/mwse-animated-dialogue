---@class actorHeadBobAnimator : initializedService, actorAnimator
local this = {}

---@private
this.speechTuning = {
    loudnessThreshold = 0.02,
    holdDuration = 0.2,
    activityEaseRate = 8,
    loudnessEaseRate = 1.5,
    loudnessInfluence = 0.15,
    minimumStrength = 5e-3,
}

---@private
this.motionTuning = {
    waveWeight1 = 0.6,
    waveWeight2 = 0.4,
    frequencyJitter = 0.12,
    wanderDurationMin = 0.5,
    wanderDurationMax = 1.4,
}

---@private
this.ownWriteEpsilon = 1e-4

---@private
this.twoPi = math.pi * 2

---@private
---@type headBobAxis
this.yawAxis = { maxAngle = 0.11, frequency1 = 2.0, frequency2 = 3.6 }

---@private
---@type headBobAxis
this.tiltAxis = { maxAngle = 0.075, frequency1 = 1.6, frequency2 = 2.9 }

---@private
---@type headBobAxis
this.nodAxis = { maxAngle = 0.13, frequency1 = 2.4, frequency2 = 4.3 }

---@private
this.axes = { this.yawAxis, this.tiltAxis, this.nodAxis }

---@private
this.time = 0

---@private
---@type headBobSpeech
this.speech = {
    activity = 0,
    loudness = 0,
    holdTimer = 0,
    isTalking = false,
}

---@private
---@type headBobBasePose
this.basePose = {
    tracked = false,
    x = 0,
    y = 0,
    z = 0,
    writtenX = 0,
    writtenY = 0,
    writtenZ = 0,
}

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
    this.actor = event.actor
    this.reset()
end

---@private
function this.onDialogueEnded()
    this.actor = nil
    this.reset()
end

---@private
function this.reset()
    this.time = 0

    this.speech = {
        activity = 0,
        loudness = 0,
        holdTimer = 0,
        isTalking = false,
    }

    this.basePose.tracked = false

    for i = 1, #this.axes do
        this.reseedAxis(this.axes[i])
    end
end

---@private
---@param axis headBobAxis
function this.reseedAxis(axis)
    axis.wave = {
        frequency1 = this.jitterFrequency(axis.frequency1),
        frequency2 = this.jitterFrequency(axis.frequency2),
        phase1 = math.random() * this.twoPi,
        phase2 = math.random() * this.twoPi,
    }

    local start = this.randomSigned()
    axis.wander = {
        from = start,
        to = this.randomSigned(),
        value = start,
        elapsed = 0,
        duration = this.randomWanderDuration(),
    }
end

---@private
---@param frequency number
---@return number
function this.jitterFrequency(frequency)
    return frequency * (1 + this.randomSigned() * this.motionTuning.frequencyJitter)
end

---@private
---@return number
function this.randomSigned()
    return math.random() * 2 - 1
end

---@private
---@return number
function this.randomWanderDuration()
    local tuning = this.motionTuning
    return tuning.wanderDurationMin + math.random() * (tuning.wanderDurationMax - tuning.wanderDurationMin)
end

---@public
---@param delta number
function this.update(delta)
    local animationData = this.actor.animationData
    if not animationData then
        return
    end

    local headNode = animationData.headNode
    if not headNode then
        return
    end

    local strength = this.updateStrength(animationData.lipsyncLevel, delta)
    if strength < this.speechTuning.minimumStrength then
        this.basePose.tracked = false
        return
    end

    if this.speech.isTalking then
        this.advanceTime(delta)
    end

    this.applyBob(headNode, strength)
end

---@private
---@param lipsyncLevel number
---@param delta number
---@return number
function this.updateStrength(lipsyncLevel, delta)
    local speech = this.speech
    local tuning = this.speechTuning
    local mouthActive = lipsyncLevel > tuning.loudnessThreshold

    if mouthActive then
        speech.holdTimer = tuning.holdDuration
    else
        speech.holdTimer = math.max(speech.holdTimer - delta, 0)
    end

    speech.isTalking = mouthActive or speech.holdTimer > 0

    local activityTarget = speech.isTalking and 1 or 0
    speech.activity = this.easeTowards(speech.activity, activityTarget, tuning.activityEaseRate, delta)

    local loudnessTarget = mouthActive and math.clamp(lipsyncLevel, 0, 1) or 0
    speech.loudness = this.easeTowards(speech.loudness, loudnessTarget, tuning.loudnessEaseRate, delta)

    return speech.activity * (1 - tuning.loudnessInfluence + tuning.loudnessInfluence * speech.loudness)
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

---@private
---@param delta number
function this.advanceTime(delta)
    local scaledDelta = delta * this.settings.actorHeadBobSpeed
    this.time = this.time + scaledDelta
    for i = 1, #this.axes do
        local wander = this.axes[i].wander
        if wander then
            this.advanceWander(wander, scaledDelta)
        end
    end
end

---@private
---@param wander headBobWander
---@param scaledDelta number
function this.advanceWander(wander, scaledDelta)
    wander.elapsed = wander.elapsed + scaledDelta

    while wander.elapsed >= wander.duration do
        wander.elapsed = wander.elapsed - wander.duration
        wander.from = wander.to
        wander.to = this.randomSigned()
        wander.duration = this.randomWanderDuration()
    end

    local progress = math.ease.smoothstep(wander.elapsed / wander.duration)
    wander.value = wander.from + (wander.to - wander.from) * progress
end

---@private
---@param headNode niNode
---@param strength number
function this.applyBob(headNode, strength)
    local yaw, tilt, nod = this.calculateOffsets(strength)

    local euler = headNode.rotation:toEulerXYZ()
    local pose = this.basePose
    local baseX = this.resolveBaseAngle(euler.x, pose.writtenX, pose.x)
    local baseY = this.resolveBaseAngle(euler.y, pose.writtenY, pose.y)
    local baseZ = this.resolveBaseAngle(euler.z, pose.writtenZ, pose.z)

    local x = baseX + yaw
    local y = baseY + tilt
    local z = baseZ + nod

    headNode.rotation:fromEulerXYZ(x, y, z)
    headNode:update()

    pose.x, pose.y, pose.z = baseX, baseY, baseZ
    pose.writtenX, pose.writtenY, pose.writtenZ = x, y, z
    pose.tracked = true
end

---@private
---@param current number
---@param lastWritten number
---@param lastBase number
---@return number
function this.resolveBaseAngle(current, lastWritten, lastBase)
    if not this.basePose.tracked then
        return current
    end

    local isOwnWrite = math.abs(current - lastWritten) < this.ownWriteEpsilon
    if isOwnWrite then
        return lastBase
    end

    return current
end

---@private
---@param strength number
---@return number, number, number
function this.calculateOffsets(strength)
    local settings = this.settings
    local scale = settings.actorHeadBobAmount * strength
    local randomness = math.clamp(settings.actorHeadBobRandomness, 0, 1)

    local yaw = settings.actorHeadBobYawEnabled and this.axisOffset(this.yawAxis, randomness, scale) or 0
    local tilt = settings.actorHeadBobTiltEnabled and this.axisOffset(this.tiltAxis, randomness, scale) or 0
    local nod = settings.actorHeadBobNodEnabled and this.axisOffset(this.nodAxis, randomness, scale) or 0

    return yaw, tilt, nod
end

---@private
---@param axis headBobAxis
---@param randomness number
---@param scale number
---@return number
function this.axisOffset(axis, randomness, scale)
    local wave = axis.wave
    if not wave then
        return 0
    end

    local tuning = this.motionTuning
    local steady = tuning.waveWeight1 * math.sin(this.time * wave.frequency1 + wave.phase1)
        + tuning.waveWeight2 * math.sin(this.time * wave.frequency2 + wave.phase2)

    local motion = (1 - randomness) * steady + randomness * axis.wander.value

    return motion * axis.maxAngle * scale
end

return this
