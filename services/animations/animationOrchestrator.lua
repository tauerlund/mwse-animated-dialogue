--- Decides which clip plays when: resolves configurations off the dialogue
--- events and drives the playback engine (`npcControllersAnimator`) through
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
---@type npcControllersAnimator
this.npcControllersAnimator = nil

---@private
---@type tes3reference
this.npc = nil

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
    this.eventRegistrar         = services.eventRegistrar
    this.settings               = services.settings
    this.animationResolver      = services.animationResolver
    this.npcControllersAnimator = services.npcControllersAnimator

    local events                = services.enums.events

    this.eventHandlers          = {
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
    if not this.settings.npcAnimEnabled then
        return
    end

    local configuration = this.animationResolver.resolveBase(e.npc)
    if not configuration then
        return
    end

    this.npc = e.npc
    this.animationConfiguration = configuration

    this.npcControllersAnimator.play({
        npc       = e.npc,
        animation = configuration.idle,
    })

    if this.pendingInfo and this.pendingInfo.npc == e.npc then
        this.onDialogueInfo(this.pendingInfo)
    end

    this.pendingInfo = nil
end

---@private
---@param e dialogueInfoEventData
function this.onDialogueInfo(e)
    if not this.npc then
        this.pendingInfo = e
        return
    end

    if not this.settings.npcTalkAnimEnabled then
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

    this.npcControllersAnimator.play({
        npc       = this.npc,
        animation = animation,
        revertTo  = this.animationConfiguration.idle,
    })
end

---@private
function this.onDialogueEnded()
    this.npcControllersAnimator.stop()
    this.npc = nil
    this.animationConfiguration = nil
    this.pendingInfo = nil
end

return this
