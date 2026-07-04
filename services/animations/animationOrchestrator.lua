--- Decides which clip plays when: resolves configurations off the dialogue
--- events and drives the playback engine (`actorControllersAnimator`) through
--- synchronous `play`/`stop` calls.
---@class animationOrchestrator : initializedService
local this = {}

---@private
---@type eventRegistrar
this.eventRegistrar = nil

---@private
---@type settings
this.settings = nil

---@private
---@type animationResolver
this.animationResolver = nil

---@private
---@type actorControllersAnimator
this.actorControllersAnimator = nil

---@private
---@type tes3reference
this.actor = nil

---@private
---@type baseAnimationConfiguration
this.animationConfiguration = nil

---@private
---@type dialogueInfoEventData|nil
this.pendingInfo = nil

---@private
---@type eventHandlers
this.eventHandlers = nil

---@public
---@param services serviceCollection
---@return boolean,string|nil
function this.initialize(services)
    this.eventRegistrar           = services.eventRegistrar
    this.settings                 = services.settings
    this.animationResolver        = services.animationResolver
    this.actorControllersAnimator = services.actorControllersAnimator

    local events                  = services.enums.events

    this.eventHandlers            = {
        [events.dialogueStarted] = this.onDialogueStarted,
        [events.dialogueEnded]   = this.onDialogueEnded,
        [events.dialogueInfo]    = this.onDialogueInfo,
    }

    this.eventRegistrar.register(this.eventHandlers)

    return true, nil
end

---@public
function this.uninitialize()
    this.eventRegistrar.unregister(this.eventHandlers)
end

---@private
---@param e dialogueStartedEventData
function this.onDialogueStarted(e)
    if not this.settings.actorAnimEnabled then
        return
    end

    local configuration = this.animationResolver.resolveBase(e.actor)
    if not configuration then
        return
    end

    this.actor = e.actor
    this.animationConfiguration = configuration

    this.actorControllersAnimator.play({
        actor     = e.actor,
        animation = configuration.idle,
    })

    if this.pendingInfo and this.pendingInfo.actor == e.actor then
        this.onDialogueInfo(this.pendingInfo)
    end

    this.pendingInfo = nil
end

---@private
---@param e dialogueInfoEventData
function this.onDialogueInfo(e)
    if not this.actor then
        this.pendingInfo = e
        return
    end

    if not this.settings.actorTalkAnimEnabled then
        return
    end

    if not this.animationConfiguration then
        return
    end

    local talk = this.animationConfiguration.talk
    local override = this.animationResolver.resolveOverride(e.info.id)

    local animation =
        override and override.animation or
        talk and table.choice(talk)

    if not animation then
        return
    end

    this.actorControllersAnimator.play({
        actor     = this.actor,
        animation = animation,
        revertTo  = this.animationConfiguration.idle,
    })
end

---@private
function this.onDialogueEnded()
    this.actorControllersAnimator.stop()
    this.actor = nil
    this.animationConfiguration = nil
    this.pendingInfo = nil
end

return this
