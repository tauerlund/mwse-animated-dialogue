---@class lightController : initializedService
local this = {}

local MIN_BRIGHTNESS = 0.25
local MAX_BRIGHTNESS = 1.0
local UPDATE_RATE = 15.0
local FAST_RATE = 0.1
local SLOW_RATE = 0.05

---@class lightEntry
---@field light niPointLight
---@field lightNode tes3lightNode
---@field mode "flicker"|"pulse"
---@field rate number
---@field target number

---@private
---@type settings
this.settings = nil

---@private
---@type eventRegistrar
this.eventRegistrar = nil

---@private
---@type eventHandlerGroups
this.eventHandlers = {
    lifetime = {},
    dialogue = {}
}

---@private
---@type boolean
this.paused = false

---@private
---@type lightEntry[]
this.lights = {}

---@private
---@enum flickerMode
this.modes = {
    flicker = 1,
    pulse = 2,
}

---@private
---@type number
this.smoothedTicks = 0

---@public
---@param services serviceCollection
---@return boolean,string|nil
function this.initialize(services)
    this.eventRegistrar = services.eventRegistrar
    this.settings       = services.settings

    local events        = services.enums.events

    this.eventHandlers  = {
        lifetime = {
            [events.dialogueStarted] = this.onDialogueStarted,
            [events.dialogueEnded]   = this.onDialogueEnded,
        },
        dialogue = {
            [tes3.event.enterFrame] = this.onEnterFrame,
            [events.gamePaused]     = this.onGamePaused,
            [events.gameUnpaused]   = this.onGameUnpaused,
        }
    }

    this.eventRegistrar.register(this.eventHandlers.lifetime)

    return true, nil
end

---@public
function this.uninitialize()
    this.eventRegistrar.unregister(this.eventHandlers.lifetime)
end

---@private
---@param e dialogueStartedEventData
function this.onDialogueStarted(e)
    if not this.settings.lightEnabled then
        return
    end

    this.lights = {}
    this.smoothedTicks = 0
    this.paused = false

    if this.settings.lightMode == "scene" then
        this.buildSceneLights(e.npc)
    else
        this.buildNpcLight(e.npc)
    end

    if #this.lights == 0 then
        return
    end

    this.eventRegistrar.register(this.eventHandlers.dialogue)
end

---@private
function this.onDialogueEnded()
    this.eventRegistrar.unregister(this.eventHandlers.dialogue)
    this.lights = {}
end

---@private
function this.onGamePaused()
    this.paused = true
end

---@private
function this.onGameUnpaused()
    this.paused = false
end

---@private
---@param e enterFrameEventData
function this.onEnterFrame(e)
    if this.paused then
        return
    end

    this.update(e.delta)
end

---@private
---@param delta number
function this.update(delta)
    this.smoothedTicks = 0.25 * (UPDATE_RATE * delta) + 0.75 * this.smoothedTicks

    for _, entry in ipairs(this.lights) do
        local increment = entry.rate * this.smoothedTicks

        local dimmer = entry.light.dimmer
        if dimmer >= entry.target then
            dimmer = dimmer - increment
        else
            dimmer = dimmer + increment
        end
        entry.light.dimmer = dimmer

        if math.abs(dimmer - entry.target) < entry.rate then
            entry.target = this.nextTarget(entry)
            if entry.lightNode then
                entry.lightNode.value = entry.target
            end
        end
    end
end

---@private
---@param npc tes3reference
function this.buildNpcLight(npc)
    local mobile = npc.mobile
    local source = mobile and mobile.torchSlot and mobile.torchSlot.object --[[@as tes3light]]
    this.tryAddLight(npc, source)
end

---@private
---@param npc tes3reference
function this.buildSceneLights(npc)
    local cell = npc.cell
    if not cell then
        return
    end

    local origin = npc.position
    local maxDist = this.settings.lightSceneDistance

    for ref in cell:iterateReferences(tes3.objectType.light, false) do
        this.tryAddLight(ref, ref.object --[[@as tes3light]], origin, maxDist)
    end

    for ref in cell:iterateReferences({ tes3.objectType.npc, tes3.objectType.creature }, false) do
        local mobile = ref.mobile
        local torch = mobile and mobile.torchSlot and mobile.torchSlot.object --[[@as tes3light]]
        if torch then
            this.tryAddLight(ref, torch, origin, maxDist)
        end
    end
end

-- Adds a flickering light to the animated set. Skips lights with no scene-graph light, steady
-- (non-flickering) lights, and — when an origin is given — any beyond the distance limit.
---@private
---@param ref tes3reference
---@param source tes3light|nil
---@param origin tes3vector3|nil
---@param maxDist number|nil
function this.tryAddLight(ref, source, origin, maxDist)
    if origin and ref.position:distance(origin) > maxDist then
        return
    end

    local light = ref.light --[[@as niPointLight]]
    if not light then
        return
    end

    local mode, rate = this.resolveFlicker(source)
    if not mode then
        return
    end

    local node = ref:getAttachedDynamicLight()
    table.insert(this.lights, {
        light = light,
        lightNode = node,
        mode = mode,
        rate = rate,
        target = node and node.value or light.dimmer,
    })
end

-- A light flickers/pulses per its source tes3light's flags. Steady lights (no flags) return nil and
-- are left alone — their dimmer never changes, so freezing them in menu-mode is already correct.
---@private
---@param source tes3light|nil
---@return flickerMode|nil, number|nil
function this.resolveFlicker(source)
    if not source then
        return nil
    end

    if source.pulses or source.pulsesSlowly then
        return this.modes.pulse, source.pulsesSlowly and SLOW_RATE or FAST_RATE
    end

    if source.flickers or source.flickersSlowly then
        return this.modes.flicker, source.flickersSlowly and SLOW_RATE or FAST_RATE
    end

    return nil
end

---@private
---@param entry lightEntry
---@return number
function this.nextTarget(entry)
    if entry.mode == this.modes.pulse then
        if entry.target > 0.5 then
            return MIN_BRIGHTNESS
        end
        return MAX_BRIGHTNESS
    end

    return MIN_BRIGHTNESS + math.random() * (MAX_BRIGHTNESS - MIN_BRIGHTNESS)
end

return this
