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
---@type propDefinition|nil
this.definition = nil

---@private
---@type string|nil
this.dialogueId = nil

---@private
---@type niNode|nil
this.node = nil

---@private
---@type niNode|nil
this.bone = nil

---@private
---@type number
this.elapsed = 0

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
    this.events            = services.enums.events

    local events           = this.events

    this.eventHandlers     = {
        lifetime = {
            [events.dialogueStarted] = this.onDialogueStarted,
            [events.dialogueEnded]   = this.onDialogueEnded,
            [events.dialogueInfo]    = this.onDialogueInfo,
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
    this.despawn()
    this.actor = nil
    this.pendingInfo = nil
    this.dialogueState = nil
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

    this.despawn()

    local override = this.animationResolver.resolveOverride(e.info.id)
    local prop = override and override.prop
    if not prop then
        return
    end

    this.spawn(prop, e.info.id)
end

---@private
---@param prop propDefinition
---@param dialogueId string
function this.spawn(prop, dialogueId)
    this.definition = prop
    this.dialogueId = dialogueId
    this.elapsed    = 0

    this.eventRegistrar.register(this.eventHandlers.prop)
end

---@private
function this.despawn()
    local hadProp = this.node ~= nil

    if this.node and this.bone then
        this.bone:detachChild(this.node)
        this.bone:update({ children = true })
    end

    this.node       = nil
    this.bone       = nil
    this.definition = nil
    this.dialogueId = nil
    this.elapsed    = 0

    this.eventRegistrar.unregister(this.eventHandlers.prop)

    if hadProp then
        event.trigger(this.events.propDespawned)
    end
end

---@private
---@param e enterFrameEventData
function this.onEnterFrame(e)
    if this.dialogueState.paused or not this.definition then
        return
    end

    this.elapsed = this.elapsed + e.delta

    if not this.node and this.elapsed >= (this.definition.spawnAfter or 0) then
        this.attach(this.definition)
    end

    local despawnAfter = this.definition.despawnAfter
    if despawnAfter and this.elapsed >= despawnAfter then
        this.despawn()
    end
end

---@private
---@param prop propDefinition
function this.attach(prop)
    local sceneNode = this.actor and this.actor.sceneNode
    if not sceneNode then
        return
    end

    local bone = sceneNode:getObjectByName(prop.attachTo) --[[@as niNode|nil]]
    if not bone then
        this.logger:error("No bone '%s' on NPC for prop '%s'", prop.attachTo, prop.file)
        this.definition = nil
        return
    end
    this.bone = bone

    local node = this.nifLoader.load(prop.file)
    if not node then
        this.logger:error("Could not load prop mesh '%s' (file missing or failed to load)", prop.file)
        this.definition = nil
        return
    end
    this.node = node

    this.applyTransform(node, prop.transform)

    bone:attachChild(node)
    bone:update({ children = true })
    node:updateProperties()
    node:updateEffects()

    ---@type propSpawnedEventData
    local eventData = { node = node, dialogueId = this.dialogueId }
    event.trigger(this.events.propSpawned, eventData)
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
