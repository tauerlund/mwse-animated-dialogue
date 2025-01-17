local MeshNodeService = require('tauer.animated-dialogue.services.nodes.MeshNodeService')
local EventManager = require("tauer.shared.events.EventManager")

---@class MeshNodeAnimator
local this = {}

---@private
---@type boolean
this.paused = false

---@private
---@type tes3npcInstance
this.currentNpc = nil

---@private
---@type number
this.blinkPhase = 0

---@private
---@type mwseTimer
this.blinkIntervalTimer = nil

---@private
---@type mwseTimer
this.blinkPhaseTimer = nil

---@private
---@type number
this.blinkInterval = 3

---@private
---@type number
this.blinkSpeed = 0.5

---@private
---@type tes3animationData
this.npcAnimationData = nil

---@public
---@param npc tes3npcInstance
function this.StartHeadAnimations(npc)
    this.currentNpc = npc
    this.setupBlinkTimers()
    this.setupHeadMeshNode()
    this.registerEvents()
end

    ---@public
function this.Stop()
    this.stopBlinkTimers()
    this.unregisterEvents()
    this.currentNpc = nil
end

---@public
function this.Pause()
    this.paused = true
end

---@public
function this.Resume()
    this.paused = false
end

function this.setupBlinkTimers()
    local iterations = 20
    local transition = 1 / iterations
    this.blinkPhaseTimer = timer.start({
        duration = this.blinkSpeed / iterations,
        iterations = iterations,
        type = timer.real,
        callback = function()
            this.blinkPhase = this.blinkPhase + transition
        end
    })
    this.blinkPhaseTimer:pause()

    this.blinkIntervalTimer = timer.start({
        duration = this.blinkInterval,
        type = timer.real,
        iterations = -1,
        callback = function()
            this.blinkPhase = 0
            this.blinkPhaseTimer:reset()
        end
    })
end

function this.stopBlinkTimers()
    if this.blinkPhaseTimer then
        this.blinkPhaseTimer:cancel()
    end
    if this.blinkIntervalTimer then
        this.blinkIntervalTimer:cancel()
    end
end

---@private
function this.setupHeadMeshNode()
    this.headNode = MeshNodeService.GetHeadMeshNode(this.currentNpc)
    if not this.headNode then
        return
    end

    local controller = MeshNodeService.GetMorphController(this.headNode)
    if controller then
        controller.active = true
    end

    local reference = this.currentNpc --[[@as tes3reference]]
    this.npcAnimationData = reference.attachments.animation --[[@as tes3animationData]]
end

---@private
function this.updateHeadMeshNode()
    if not this.headNode then
        return
    end

    local phase = this.isSpeaking()
        and this.getLipsyncPhase()
        or this.getBlinkingPhase()

    this.headNode:update({controllers = true, time = phase})
end

---@private
---@return boolean
function this.isSpeaking()
    return this.npcAnimationData.lipsyncLevel ~= -1
end

---@private
---@return number
function this.getLipsyncPhase()
    -- TODO: Get these values dynamically from the mesh node instead of hardcoding
    local lipSyncAnimStart = 0
    local lipSyncAnimEnd = 1.333

    local phase = math.remap(this.npcAnimationData.lipsyncLevel, 0, 1, lipSyncAnimStart, lipSyncAnimEnd)

    return math.clamp(phase, lipSyncAnimStart, lipSyncAnimEnd)
end

---@private
---@return number
function this.getBlinkingPhase()
    -- TODO: Get these values dynamically from the mesh node instead of hardcoding
    local blinkAnimationStart = 1.4
    local blinkAnimationEnd = 2

    local phase = math.remap(this.blinkPhase, 0, 1, blinkAnimationStart, blinkAnimationEnd)

    return math.clamp(phase, blinkAnimationStart, blinkAnimationEnd)
end

---@private
function this.onEnterFrame()
    if this.paused then
        return
    end
    this.updateHeadMeshNode()
end

-- Have to force an update on the head mesh node when this event is triggered,
-- as lip syncing and blinking is broken when any equipment is added to the NPC.
--- @private 
--- @param e bodyPartsUpdatedEventData
function this.onBodyPartsUpdated(e)
    if e.reference ~= this.currentNpc then
        return
    end
    this.setupHeadMeshNode()
end

---@private
---@param e uiActivatedEventData
function this.onOptionsMenuOpened(e)
    e.element:getContentElement():registerAfter(
		tes3.uiEvent.destroy,
		this.onOptionsMenuClosed
	)
    this.paused = true
end

---@private
function this.onOptionsMenuClosed()
    this.paused = false
end

---@private
function this.registerEvents()
    EventManager.Register(tes3.event.enterFrame, this.onEnterFrame)
    EventManager.Register(tes3.event.bodyPartsUpdated, this.onBodyPartsUpdated)
    EventManager.Register(tes3.event.uiActivated, this.onOptionsMenuOpened, { filter = "MenuOptions" })
end

---@private
function this.unregisterEvents()
    EventManager.Unregister(tes3.event.enterFrame, this.onEnterFrame)
    EventManager.Unregister(tes3.event.bodyPartsUpdated, this.onBodyPartsUpdated)
    EventManager.Unregister(tes3.event.uiActivated, this.onOptionsMenuOpened, { filter = "MenuOptions" })
end

return this