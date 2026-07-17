---@class propSpawner : initializedService
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
---@type nifLoader
this.nifLoader = nil

---@private
---@type events
this.events = nil

---@private
---@type mwseLogger
this.logger = mwse.Logger.new()

---@private
---@type eventHandlerGroups
this.eventHandlers = {
    lifetime = {},
    prop = {}
}

---@private
---@type tes3reference|nil
this.actor = nil

---@private
---@type dialogueInfoEventData|nil
this.pendingInfo = nil

---@private
---@type propSlot|nil
this.baseSlot = nil

---@private
---@type propSlot|nil
this.overrideSlot = nil

---@private
---@type dialogueState
this.dialogueState = nil

---@public
---@param services serviceCollection
---@return boolean, string|nil
function this.initialize(services)
    this.eventRegistrar    = services.eventRegistrar
    this.settings          = services.settings
    this.animationResolver = services.animationResolver
    this.nifLoader         = services.nifLoader
    this.events            = services.constants.events

    local events           = this.events

    this.eventHandlers     = {
        lifetime = {
            [events.dialogueStarted]  = this.onDialogueStarted,
            [events.dialogueEnded]    = this.onDialogueEnded,
            [events.dialogueInfo]     = this.onDialogueInfo,
            [events.animationStarted] = this.onAnimationStarted,
        },
        prop = {
            [tes3.event.enterFrame] = this.onEnterFrame,
        }
    }

    this.eventRegistrar.register(this.eventHandlers.lifetime)

    return true, nil
end

function this.uninitialize()
    this.eventRegistrar.unregister(this.eventHandlers.lifetime)
end

---@private
---@param e dialogueStartedEventData
function this.onDialogueStarted(e)
    this.dialogueState = e.dialogueState
    this.actor = e.dialogueState.actor

    if this.pendingInfo and this.pendingInfo.actor == e.dialogueState.actor then
        this.onDialogueInfo(this.pendingInfo)
    end

    this.pendingInfo = nil
end

---@private
function this.onDialogueEnded()
    this.despawnBase()
    this.despawnOverride()

    this.actor = nil
    this.pendingInfo = nil
    this.dialogueState = nil
end

---@private
---@param e animationEventData
function this.onAnimationStarted(e)
    if not this.settings.propsEnabled then
        return
    end

    if e.actor == tes3.player then
        return
    end

    local configuration = e.configuration
    if not configuration then
        return
    end

    if this.baseSlot and this.baseSlot.configuration == configuration then
        return
    end

    this.despawnBase()

    if not configuration.prop then
        return
    end

    this.baseSlot = {
        reference     = e.actor,
        definition    = configuration.prop,
        configuration = configuration,
        elapsed       = 0,
    }

    this.refreshFrameHandler()
end

---@private
---@param e dialogueInfoEventData
function this.onDialogueInfo(e)
    if not this.settings.propsEnabled then
        return
    end

    if not this.actor then
        this.pendingInfo = e
        return
    end

    this.despawnOverride()

    local override = this.animationResolver.resolveOverride(e.info.id, e.actor)
    if not override then
        return
    end

    local prop = override.prop
    if not prop then
        return
    end

    this.overrideSlot = {
        reference     = e.actor,
        definition    = prop,
        configuration = override,
        elapsed       = 0,
    }

    this.refreshFrameHandler()
end

---@private
function this.refreshFrameHandler()
    if this.baseSlot or this.overrideSlot then
        this.eventRegistrar.register(this.eventHandlers.prop)
        return
    end

    this.eventRegistrar.unregister(this.eventHandlers.prop)
end

---@private
---@param e enterFrameEventData
function this.onEnterFrame(e)
    if this.dialogueState.paused then
        return
    end

    this.advanceSlot(this.baseSlot, e.delta)
    this.advanceSlot(this.overrideSlot, e.delta)

    if this.overrideSlot and this.hasExpired(this.overrideSlot) then
        this.despawnOverride()
    end
end

---@private
---@param slot propSlot|nil
---@param delta number
function this.advanceSlot(slot, delta)
    if not slot then
        return
    end

    slot.elapsed = slot.elapsed + delta

    if slot.node then
        return
    end

    if slot.elapsed >= (slot.definition.spawnAfter or 0) then
        this.attach(slot)
    end
end

---@private
---@param slot propSlot
---@return boolean
function this.hasExpired(slot)
    local despawnAfter = slot.definition.despawnAfter

    return despawnAfter ~= nil and slot.elapsed >= despawnAfter
end

---@private
---@param slot propSlot
function this.attach(slot)
    local sceneNode = slot.reference.sceneNode
    if not sceneNode then
        return
    end

    local definition = slot.definition

    local bone = sceneNode:getObjectByName(definition.attachTo) --[[@as niNode|nil]]
    if not bone then
        this.logger:error("No bone '%s' on NPC for prop '%s'", definition.attachTo, definition.file)
        this.despawnSlot(slot)
        return
    end
    slot.bone = bone

    local node = this.nifLoader.load(definition.file)
    if not node then
        this.logger:error("Could not load prop mesh '%s' (file missing or failed to load)", definition.file)
        this.despawnSlot(slot)
        return
    end
    slot.node = node

    this.applyTransform(node, definition.transform)

    bone:attachChild(node)
    bone:update({ children = true })
    node:updateProperties()
    node:updateEffects()

    if slot == this.overrideSlot then
        this.setBaseVisible(false)
        this.triggerPropSpawned(slot)
        return
    end

    if this.isOverrideVisible() then
        node.appCulled = true
        return
    end

    this.triggerPropSpawned(slot)
end

---@private
---@return boolean
function this.isOverrideVisible()
    return this.overrideSlot ~= nil and this.overrideSlot.node ~= nil
end

---@private
---@param visible boolean
function this.setBaseVisible(visible)
    local slot = this.baseSlot
    if not slot or not slot.node then
        return
    end

    local culled = not visible
    if slot.node.appCulled == culled then
        return
    end

    slot.node.appCulled = culled

    if visible then
        this.triggerPropSpawned(slot)
        return
    end

    event.trigger(this.events.propDespawned)
end

---@private
---@param slot propSlot
function this.triggerPropSpawned(slot)
    ---@type propSpawnedEventData
    local eventData = {
        node          = slot.node,
        configuration = slot.configuration,
    }

    event.trigger(this.events.propSpawned, eventData)
end

---@private
function this.despawnBase()
    local slot = this.baseSlot
    if not slot then
        return
    end

    local wasVisible = slot.node ~= nil and not slot.node.appCulled

    this.detachSlot(slot)
    this.baseSlot = nil

    if wasVisible then
        event.trigger(this.events.propDespawned)
    end

    this.refreshFrameHandler()
end

---@private
function this.despawnOverride()
    local slot = this.overrideSlot
    if not slot then
        return
    end

    local hadNode = slot.node ~= nil

    this.detachSlot(slot)
    this.overrideSlot = nil

    if hadNode then
        event.trigger(this.events.propDespawned)
    end

    this.setBaseVisible(true)
    this.refreshFrameHandler()
end

---@private
---@param slot propSlot
function this.despawnSlot(slot)
    if slot == this.baseSlot then
        this.despawnBase()
        return
    end

    this.despawnOverride()
end

---@private
---@param slot propSlot
function this.detachSlot(slot)
    if slot.node and slot.bone then
        slot.bone:detachChild(slot.node)
        slot.bone:update({ children = true })
    end

    slot.node = nil
    slot.bone = nil
end

---@private
---@param node niNode
---@param transform transformOverride|nil
function this.applyTransform(node, transform)
    if not transform then
        return
    end

    local translation = transform.translation
    if translation then
        local current    = node.translation
        node.translation = tes3vector3.new(
            translation.x or current.x,
            translation.y or current.y,
            translation.z or current.z
        )
    end

    local rotation = transform.rotation
    if rotation then
        local matrix = tes3matrix33.identity()
        matrix:fromEulerXYZ(rotation.x or 0, rotation.y or 0, rotation.z or 0)
        node.rotation = matrix
    end

    if transform.scale then
        node.scale = transform.scale
    end
end

return this
