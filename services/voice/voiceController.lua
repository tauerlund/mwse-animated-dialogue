---@class voiceController : initializedService
local this = {}

---@private
---@type settings
this.settings = nil

---@private
---@type eventRegistrar
this.eventRegistrar = nil

---@private
---@type voiceResolver
this.voiceResolver = nil

---@private
---@type soundPlayer
this.soundPlayer = nil

---@private
this.logger = mwse.Logger.new()

---@private
---@type eventHandlerGroups
this.eventHandlers = {
    lifetime = {},
    dialogue = {}
}

---@private
---@type dialogueState
this.dialogueState = nil

---@private
---@type tes3reference
this.actor = nil

---@private
---@type scheduledVoiceLine|nil
this.scheduledLine = nil

---@private
---@type number
this.timeUntilNextLine = 0

---@private
---@type boolean
this.playingOwnLine = false

---@public
---@param services serviceCollection
---@return boolean,string|nil
function this.initialize(services)
    this.eventRegistrar = services.eventRegistrar
    this.settings       = services.settings
    this.voiceResolver  = services.voiceResolver
    this.soundPlayer    = services.soundPlayer

    local events        = services.constants.events

    this.eventHandlers  = {
        lifetime = {
            [events.dialogueStarted] = this.onDialogueStarted,
            [events.dialogueEnded]   = this.onDialogueEnded,
        },
        dialogue = {
            [events.dialogueInfo]     = this.onDialogueInfo,
            [tes3.event.enterFrame]   = this.onEnterFrame,
            [tes3.event.addTempSound] = this.onAddTempSound,
        }
    }

    this.eventRegistrar.register(this.eventHandlers.lifetime)

    return true, nil
end

---@public
---@param services serviceCollection
---@return initializedService[]
function this.dependencies(services)
    return { services.voiceResolver }
end

---@public
function this.uninitialize()
    this.eventRegistrar.unregister(this.eventHandlers.lifetime)
    this.eventRegistrar.unregister(this.eventHandlers.dialogue)
end

---@private
---@param e dialogueStartedEventData
function this.onDialogueStarted(e)
    if not this.settings.voiceLinesEnabled then
        return
    end

    this.dialogueState = e.dialogueState
    this.actor = e.dialogueState.actor
    this.scheduledLine = nil
    this.timeUntilNextLine = 0
    this.playingOwnLine = false

    this.eventRegistrar.register(this.eventHandlers.dialogue)
end

---@private
function this.onDialogueEnded()
    this.eventRegistrar.unregister(this.eventHandlers.dialogue)

    this.dialogueState = nil
    this.actor = nil
    this.scheduledLine = nil
end

---@private
---@param e dialogueInfoEventData
function this.onDialogueInfo(e)
    if e.actor ~= this.actor then
        return
    end

    if this.timeUntilNextLine > 0 then
        return
    end

    if math.random() > this.settings.voiceLineChance then
        return
    end

    this.scheduleLine()
end

---@private
function this.scheduleLine()
    local configuration = this.voiceResolver.resolve(this.actor)
    if not configuration then
        return
    end

    this.scheduledLine = {
        configuration = configuration,
        sound = table.choice(configuration.sounds),
        remainingDelay = math.max(configuration.delay or 0, this.settings.voiceLineMinimumDelay),
    }
end

---@private
---@param e addTempSoundEventData
function this.onAddTempSound(e)
    if this.playingOwnLine then
        return
    end

    if not e.isVoiceover or e.reference ~= this.actor then
        return
    end

    this.yieldToOtherSound()
end

---@private
---@param e enterFrameEventData
function this.onEnterFrame(e)
    if this.dialogueState.paused then
        return
    end

    this.timeUntilNextLine = math.max(0, this.timeUntilNextLine - e.delta)

    local line = this.scheduledLine
    if not line then
        return
    end

    line.remainingDelay = line.remainingDelay - e.delta
    if line.remainingDelay > 0 then
        return
    end

    if this.isActorSpeaking() then
        this.yieldToOtherSound()
        return
    end

    this.scheduledLine = nil
    this.play(line)
end

---@private
function this.yieldToOtherSound()
    this.scheduledLine = nil
    this.startInterval()
end

---@private
---@return boolean
function this.isActorSpeaking()
    local mobile = this.actor.mobile
    if not mobile then
        return false
    end

    return mobile.isSpeaking
end

---@private
---@param line scheduledVoiceLine
function this.play(line)
    this.logger:debug("Playing voice line '%s' for '%s'", line.sound, this.actor.baseObject.id)

    this.playingOwnLine = true

    this.soundPlayer.say({
        reference = this.actor,
        file = line.sound,
        pitch = line.configuration.pitch,
    })

    this.playingOwnLine = false

    this.startInterval()
end

---@private
function this.startInterval()
    this.timeUntilNextLine = this.settings.voiceLineInterval
end

return this
