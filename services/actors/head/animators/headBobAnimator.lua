---@class headBobAnimator : initializedService, actorAnimator
local this = {}

---@private
this.speechTuning = {
    loudnessThreshold = 0.02,
    holdDuration = 0.2,
    activityEaseRate = 4,
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
this.writeMatchTolerance = 1e-4

---@private
this.twoPi = math.pi * 2

---@private
---@type headBobAxis
this.yawTuning = { maxAngle = 0.11, frequency1 = 2.0, frequency2 = 3.6 }

---@private
---@type headBobAxis
this.tiltTuning = { maxAngle = 0.075, frequency1 = 1.6, frequency2 = 2.9 }

---@private
---@type headBobAxis
this.nodTuning = { maxAngle = 0.13, frequency1 = 2.4, frequency2 = 4.3 }

---@private
---@type headBobAxis
this.yawAxis = nil

---@private
---@type headBobAxis
this.tiltAxis = nil

---@private
---@type headBobAxis
this.nodAxis = nil

---@private
---@type headBobAxis[]
this.axes = nil

---@private
this.time = 0

---@private
---@type headBobSpeech
this.speech = nil

---@private
---@type headBobBasePose
this.basePose = nil

---@private
---@type settings
this.settings = nil

---@private
---@type tes3reference
this.actor = nil

---@private
---@type lipsyncController
this.lipsyncController = nil

---@public
---@param services serviceCollection
---@return boolean,string|nil
function this.initialize(services)
    this.settings          = services.settings
    this.lipsyncController = services.lipsyncController

    return true, nil
end

---@public
---@return headBobAnimator
function this.create()
    local instance = setmetatable({}, { __index = this })

    instance.actor = nil
    instance.yawAxis = this.copyAxis(this.yawTuning)
    instance.tiltAxis = this.copyAxis(this.tiltTuning)
    instance.nodAxis = this.copyAxis(this.nodTuning)
    instance.axes = { instance.yawAxis, instance.tiltAxis, instance.nodAxis }

    return instance
end

---@private
---@param tuning headBobAxis
---@return headBobAxis
function this.copyAxis(tuning)
    return {
        maxAngle = tuning.maxAngle,
        frequency1 = tuning.frequency1,
        frequency2 = tuning.frequency2,
    }
end

---@public
---@param reference tes3reference
function this:begin(reference)
    self.actor = reference
    self:reset()
end

---@private
function this:reset()
    self.time = 0

    self.speech = {
        activity = 0,
        loudness = 0,
        holdTimer = 0,
        isTalking = false,
    }

    self.basePose = {
        tracked = false,
        x = 0,
        y = 0,
        z = 0,
        writtenX = 0,
        writtenY = 0,
        writtenZ = 0,
    }

    for i = 1, #self.axes do
        self:randomizeAxis(self.axes[i])
    end
end

---@private
---@param axis headBobAxis
function this:randomizeAxis(axis)
    axis.wave = {
        frequency1 = self:jitterFrequency(axis.frequency1),
        frequency2 = self:jitterFrequency(axis.frequency2),
        phase1 = math.random() * self.twoPi,
        phase2 = math.random() * self.twoPi,
    }

    local start = self:randomSigned()
    axis.wander = {
        from = start,
        to = self:randomSigned(),
        value = start,
        elapsed = 0,
        duration = self:randomWanderDuration(),
    }
end

---@private
---@param frequency number
---@return number
function this:jitterFrequency(frequency)
    return frequency * (1 + self:randomSigned() * self.motionTuning.frequencyJitter)
end

---@private
---@return number
function this:randomSigned()
    return math.random() * 2 - 1
end

---@private
---@return number
function this:randomWanderDuration()
    local tuning = self.motionTuning
    return tuning.wanderDurationMin + math.random() * (tuning.wanderDurationMax - tuning.wanderDurationMin)
end

---@public
---@param delta number
function this:update(delta)
    local animationData = self.actor.animationData
    if not animationData then
        return
    end

    local headNode = animationData.headNode
    if not headNode then
        return
    end

    local strength = self:updateStrength(animationData, delta)
    if strength < self.speechTuning.minimumStrength then
        self.basePose.tracked = false
        return
    end

    if self.speech.isTalking then
        self:advanceTime(delta)
    end

    self:applyBob(headNode, strength)
end

---@private
---@param data tes3animationData
---@param delta number
---@return number
function this:updateStrength(data, delta)
    local lipsyncLevel = self.lipsyncController.getLipsyncLevel(data)

    local speech = self.speech
    local tuning = self.speechTuning
    local mouthActive = lipsyncLevel > tuning.loudnessThreshold

    if mouthActive then
        speech.holdTimer = tuning.holdDuration
    else
        speech.holdTimer = math.max(speech.holdTimer - delta, 0)
    end

    speech.isTalking = mouthActive or speech.holdTimer > 0

    local activityTarget = speech.isTalking and 1 or 0
    speech.activity = self:easeTowards(speech.activity, activityTarget, tuning.activityEaseRate, delta)

    local loudnessTarget = mouthActive and math.clamp(lipsyncLevel, 0, 1) or 0
    speech.loudness = self:easeTowards(speech.loudness, loudnessTarget, tuning.loudnessEaseRate, delta)

    return speech.activity * (1 - tuning.loudnessInfluence + tuning.loudnessInfluence * speech.loudness)
end

---@private
---@param current number
---@param target number
---@param rate number
---@param delta number
---@return number
function this:easeTowards(current, target, rate, delta)
    return current + (target - current) * (1 - math.exp(-rate * delta))
end

---@private
---@param delta number
function this:advanceTime(delta)
    local scaledDelta = delta * self.settings.actorHeadBobSpeed
    self.time = self.time + scaledDelta
    for i = 1, #self.axes do
        local wander = self.axes[i].wander
        if wander then
            self:advanceWander(wander, scaledDelta)
        end
    end
end

---@private
---@param wander headBobWander
---@param scaledDelta number
function this:advanceWander(wander, scaledDelta)
    wander.elapsed = wander.elapsed + scaledDelta

    while wander.elapsed >= wander.duration do
        wander.elapsed = wander.elapsed - wander.duration
        wander.from = wander.to
        wander.to = self:randomSigned()
        wander.duration = self:randomWanderDuration()
    end

    local progress = math.ease.smoothstep(wander.elapsed / wander.duration)
    wander.value = wander.from + (wander.to - wander.from) * progress
end

---@private
---@param headNode niNode
---@param strength number
function this:applyBob(headNode, strength)
    local yaw, tilt, nod = self:calculateOffsets(strength)

    local euler = headNode.rotation:toEulerXYZ()
    local pose = self.basePose
    local baseX = self:resolveBaseAngle(euler.x, pose.writtenX, pose.x)
    local baseY = self:resolveBaseAngle(euler.y, pose.writtenY, pose.y)
    local baseZ = self:resolveBaseAngle(euler.z, pose.writtenZ, pose.z)

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
function this:resolveBaseAngle(current, lastWritten, lastBase)
    if not self.basePose.tracked then
        return current
    end

    local matchesLastWrite = math.abs(current - lastWritten) < self.writeMatchTolerance
    if matchesLastWrite then
        return lastBase
    end

    return current
end

---@private
---@param strength number
---@return number, number, number
function this:calculateOffsets(strength)
    local settings = self.settings
    local scale = settings.actorHeadBobAmount * strength
    local randomness = math.clamp(settings.actorHeadBobRandomness, 0, 1)

    local yaw = settings.actorHeadBobYawEnabled and self:axisOffset(self.yawAxis, randomness, scale) or 0
    local tilt = settings.actorHeadBobTiltEnabled and self:axisOffset(self.tiltAxis, randomness, scale) or 0
    local nod = settings.actorHeadBobNodEnabled and self:axisOffset(self.nodAxis, randomness, scale) or 0

    return yaw, tilt, nod
end

---@private
---@param axis headBobAxis
---@param randomness number
---@param scale number
---@return number
function this:axisOffset(axis, randomness, scale)
    local wave = axis.wave
    if not wave then
        return 0
    end

    local tuning = self.motionTuning
    local steady = tuning.waveWeight1 * math.sin(self.time * wave.frequency1 + wave.phase1)
        + tuning.waveWeight2 * math.sin(self.time * wave.frequency2 + wave.phase2)

    local motion = (1 - randomness) * steady + randomness * axis.wander.value

    return motion * axis.maxAngle * scale
end

return this
