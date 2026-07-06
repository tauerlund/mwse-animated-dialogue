---@class actorHeadBobAnimator : initializedService, actorAnimator
local this = {}

-- Amplitude below which the bob is treated as off (head left untouched). Kept high enough to
-- trim the exponential envelope's invisible tail so the head settles promptly on release.
---@private
this.amplitudeEpsilon = 5e-3

-- Two euler values within this are considered "the same write" (see resolveBase).
---@private
this.changeEpsilon = 1e-4

-- Envelope eases bob amplitude up/down as speech starts/stops. On release the oscillation phase is
-- frozen (see update) so the head glides straight back to neutral instead of wiggling to a stop;
-- the release rate sets how gentle that glide is. Kept faster than attack so it still settles
-- promptly once the mouth goes quiet.
---@private
this.envelopeAttackRate = 8
---@private
this.envelopeReleaseRate = 8

-- lipsyncLevel loudness above which the mouth counts as active. It is 0.0 during silent parts of a
-- voice line (including the file's trailing silence) and -1 when not speaking, so gating on loudness
-- lets the head settle when the mouth stops instead of waiting out the trailing silence.
---@private
this.activityThreshold = 0.02

-- Keep the bob alive this long after the mouth goes quiet, bridging short inter-word silences so it
-- does not stutter mid-sentence, while still settling promptly at the end of a line.
---@private
this.holdDuration = 0.2

-- Smoothing applied to the raw (per-phoneme, noisy) lipsync level before it accents amplitude.
-- Deliberately slow so the accent is the line's overall energy, not syllable jitter.
---@private
this.levelRate = 1.5

-- Fraction of amplitude that is constant while talking; the remainder is the smoothed lipsync
-- accent. High, so the bob is driven mostly by the steady envelope and only nudged by speech.
---@private
this.baseIntensity = 0.85

-- Each axis blends two summed sines (a steady rhythm) with a slow value-noise wander (organic
-- non-periodicity), mixed by the Randomness setting. `f1`/`f2` are base frequencies (rad/s); at
-- each dialogue they are jittered and given random phases so no two conversations share a cadence.
-- The noise picks a fresh random target every noise segment and eases to it with smoothstep, so it
-- adds variety with no velocity kinks. `max` is the peak angle (radians) when sines/noise and
-- amplitude align. Frequencies scale with Speed, angles with Amount. Component→motion mapping
-- confirmed in-game: x = yaw (turn), y = tilt (roll), z = nod.
---@private
this.sineWeight1 = 0.6
---@private
this.sineWeight2 = 0.4
---@private
this.twoPi = math.pi * 2
-- Per-dialogue frequency jitter (±fraction) and noise-segment duration range (phase-seconds).
---@private
this.freqJitter = 0.12
---@private
this.noiseMinDuration = 0.5
---@private
this.noiseMaxDuration = 1.4
---@private
this.axes = {
    { component = "x", max = 0.11,  settingKey = "actorHeadBobYawEnabled",  f1 = 2.0, f2 = 3.6 },
    { component = "y", max = 0.075, settingKey = "actorHeadBobTiltEnabled", f1 = 1.6, f2 = 2.9 },
    { component = "z", max = 0.13,  settingKey = "actorHeadBobNodEnabled",  f1 = 2.4, f2 = 4.3 },
}

---@private
this.time = 0

---@private
this.envelope = 0

---@private
this.holdTimer = 0

-- True while speaking/holding (phase advances); false during release, freezing the phase so the
-- head eases straight to neutral.
---@private
this.oscillating = false

---@private
this.smoothedLevel = 0

-- Change-detection state: the euler values written last frame, the clean base they rode on,
-- and whether that state is valid this frame.
---@private
this.writtenX = 0
---@private
this.writtenY = 0
---@private
this.writtenZ = 0
---@private
this.baseX = 0
---@private
this.baseY = 0
---@private
this.baseZ = 0
---@private
this.hasState = false

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
    this.envelope = 0
    this.holdTimer = 0
    this.oscillating = false
    this.smoothedLevel = 0
    this.hasState = false

    for i = 1, #this.axes do
        this.randomizeAxis(this.axes[i])
    end
end

-- Reseeds an axis's per-dialogue randomness: jittered frequencies, random sine phases, and a
-- fresh noise segment. Runs once per conversation so each feels distinct.
---@private
---@param axis table
function this.randomizeAxis(axis)
    axis.rf1 = axis.f1 * (1 + (math.random() * 2 - 1) * this.freqJitter)
    axis.rf2 = axis.f2 * (1 + (math.random() * 2 - 1) * this.freqJitter)
    axis.rp1 = math.random() * this.twoPi
    axis.rp2 = math.random() * this.twoPi

    axis.noiseFrom = math.random() * 2 - 1
    axis.noiseTo = math.random() * 2 - 1
    axis.noiseValue = axis.noiseFrom
    axis.noiseElapsed = 0
    axis.noiseDuration = this.randomNoiseDuration()
end

---@private
---@return number
function this.randomNoiseDuration()
    return this.noiseMinDuration + math.random() * (this.noiseMaxDuration - this.noiseMinDuration)
end

---@public
---@param delta number
function this.update(delta)
    local animationData = this.actor.animationData
    if not animationData then
        return
    end

    local node = animationData.headNode
    if not node then
        return
    end

    local amplitude = this.updateAmplitude(animationData, delta)
    if amplitude < this.amplitudeEpsilon then
        this.hasState = false
        return
    end

    -- Advance the phase clock (not raw time, so Speed changes stay continuous) only while speaking;
    -- freezing it during release locks the offset direction so the head eases straight to neutral.
    if this.oscillating then
        local phaseDelta = delta * this.settings.actorHeadBobSpeed
        this.time = this.time + phaseDelta
        this.advanceNoise(phaseDelta)
    end

    local offsetX, offsetY, offsetZ = this.updateOffsets(amplitude)

    local euler = node.rotation:toEulerXYZ()
    local baseX = this.resolveBase(euler.x, this.writtenX, this.baseX)
    local baseY = this.resolveBase(euler.y, this.writtenY, this.baseY)
    local baseZ = this.resolveBase(euler.z, this.writtenZ, this.baseZ)

    local x = baseX + offsetX
    local y = baseY + offsetY
    local z = baseZ + offsetZ

    node.rotation:fromEulerXYZ(x, y, z)
    node:update()

    this.baseX, this.baseY, this.baseZ = baseX, baseY, baseZ
    this.writtenX, this.writtenY, this.writtenZ = x, y, z
    this.hasState = true
end

-- Derives the bob-free base for one axis. If the node still holds exactly what we wrote last
-- frame, nobody upstream touched it, so the clean base is unchanged; otherwise the current
-- value is a fresh upstream write (look-at aim, a clip keyframe, the rest pose) and becomes
-- the new base. This is what keeps an additive bob from compounding into drift.
---@private
---@param current number
---@param written number
---@param base number
---@return number
function this.resolveBase(current, written, base)
    if not this.hasState then
        return current
    end

    if math.abs(current - written) < this.changeEpsilon then
        return base
    end

    return current
end

---@private
---@param animationData tes3animationData
---@param delta number
---@return number
function this.updateAmplitude(animationData, delta)
    local level = animationData.lipsyncLevel

    -- Active only while the mouth is actually loud; a hold bridges brief inter-word silences (both
    -- read as level 0) so the bob keeps going mid-sentence but releases once speech truly stops.
    local active = level > this.activityThreshold
    if active then
        this.holdTimer = this.holdDuration
    else
        this.holdTimer = math.max(this.holdTimer - delta, 0)
    end

    local envelopeTarget = (active or this.holdTimer > 0) and 1 or 0
    this.oscillating = envelopeTarget > 0
    local envelopeRate = envelopeTarget > this.envelope and this.envelopeAttackRate or this.envelopeReleaseRate
    this.envelope = this.envelope + (envelopeTarget - this.envelope) * (1 - math.exp(-envelopeRate * delta))

    local levelTarget = active and math.clamp(level, 0, 1) or 0
    this.smoothedLevel = this.smoothedLevel +
        (levelTarget - this.smoothedLevel) * (1 - math.exp(-this.levelRate * delta))

    return this.envelope * (this.baseIntensity + (1 - this.baseIntensity) * this.smoothedLevel)
end

---@private
---@param amplitude number
---@return number, number, number
function this.updateOffsets(amplitude)
    local offsetX, offsetY, offsetZ = 0, 0, 0
    local amount = this.settings.actorHeadBobAmount
    local randomness = math.clamp(this.settings.actorHeadBobRandomness, 0, 1)

    for i = 1, #this.axes do
        local axis = this.axes[i]

        if this.settings[axis.settingKey] then
            local offset = this.axisValue(axis, randomness) * axis.max * amount * amplitude
            if axis.component == "x" then
                offsetX = offset
            elseif axis.component == "y" then
                offsetY = offset
            else
                offsetZ = offset
            end
        end
    end

    return offsetX, offsetY, offsetZ
end

-- Advances every axis's value-noise: on segment end pick a new random target, then smoothstep
-- from the previous target toward it. Smoothstep gives zero velocity at both ends, so the wander
-- has no kinks. Runs on the phase clock so Speed scales it too.
---@private
---@param phaseDelta number
function this.advanceNoise(phaseDelta)
    for i = 1, #this.axes do
        local axis = this.axes[i]
        axis.noiseElapsed = axis.noiseElapsed + phaseDelta

        while axis.noiseElapsed >= axis.noiseDuration do
            axis.noiseElapsed = axis.noiseElapsed - axis.noiseDuration
            axis.noiseFrom = axis.noiseTo
            axis.noiseTo = math.random() * 2 - 1
            axis.noiseDuration = this.randomNoiseDuration()
        end

        local t = math.ease.smoothstep(axis.noiseElapsed / axis.noiseDuration)
        axis.noiseValue = axis.noiseFrom + (axis.noiseTo - axis.noiseFrom) * t
    end
end

-- Blends the steady summed-sine rhythm with the noise wander in [-1, 1]; `randomness` mixes
-- pure sine (0) toward pure noise (1).
---@private
---@param axis table
---@param randomness number
---@return number
function this.axisValue(axis, randomness)
    local sine = this.sineWeight1 * math.sin(this.time * axis.rf1 + axis.rp1)
        + this.sineWeight2 * math.sin(this.time * axis.rf2 + axis.rp2)

    return (1 - randomness) * sine + randomness * axis.noiseValue
end

return this
