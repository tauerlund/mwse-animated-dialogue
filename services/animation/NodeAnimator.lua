local BipNodeService = require("tauer.animated-dialogue.services.nodes.BipNodeService")
local MeshNodeService = require("tauer.animated-dialogue.services.nodes.MeshNodeService")

local customEvents = require("tauer.animated-dialogue.shared.Events")

---@class NodeAnimator
local this = {}

---@private
---@type tes3npcInstance
this.currentNpc = nil

---@private
---@type { [string]: niNode }
this.nodesToUpdate = nil

---@private
---@type number
this.currentPhase = 0

---@private
---@type Animation
this.currentAnimation = nil

---@private
---@type boolean
this.paused = false

---@private
---@type niTriShape|nil
this.headNode = nil

---@private
---@type tes3animationData
this.npcAnimationData = nil

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

---@public
---@param npc tes3npcInstance
---@param animation Animation
function this.Start(npc, animation)
    this.currentNpc = npc
    this.currentAnimation = animation
    this.currentPhase = animation.StartTime
    this.paused = false
    this.nodesToUpdate = BipNodeService.GetAllBipNodes(npc.sceneNode, { IncludeParent = false })

    this.restartCurrentAnimation()
    this.setupBlinkTimers()
    this.setupHeadMeshNode()
    this.registerEvents()
end

---@public
function this.Stop()
    this.stopBlinkTimers()
    this.unregisterEvents()

    this.nodesToUpdate = nil
    this.currentPhase = 0
    this.currentAnimation = nil
    this.currentNpc = nil
end

---@public
---@param animation Animation
function this.SetAnimation(animation)
    this.paused = false
    this.currentAnimation = animation -- TODO: Make this deep copy of the animation object so the original cannot be changed?
    this.restartCurrentAnimation()
end

---@public
function this.Pause()
    this.paused = true
end

---@public
function this.Resume()
    this.paused = false
end

---@private
---@param e enterFrameEventData
function this.onEnterFrame(e)
    if this.paused then
        return
    end

    if this.currentAnimationFinished() then
        if this.currentAnimation.NonLooping then
            this.paused = true
            this.triggerAnimationFinishedEvent()
            return
        end
        this.restartCurrentAnimation()
    else
        this.incrementCurrentPhase(e.delta)
        this.updateKeyFrames()
    end

    for _, node in pairs(this.nodesToUpdate) do
        if this.shouldUpdate(node) then
            this.updateNode(node)
            this.updateHeadMeshNode()
        end
    end
end

---@private
---@return boolean
function this.currentAnimationFinished()
    return this.currentPhase >= this.currentAnimation.EndTime
end

---@private
function this.restartCurrentAnimation()
    this.currentPhase = this.currentAnimation.StartTime
    for _, node in pairs(this.nodesToUpdate) do
        local keyFrames = this.currentAnimation.NodeKeyFrames[node.name]
        if keyFrames then
            this.restartKeyFrames(keyFrames.Position)
            this.restartKeyFrames(keyFrames.Rotation)
            this.restartKeyFrames(keyFrames.Scale)
        end
    end
end

---@private
---@param amount number
function this.incrementCurrentPhase(amount)
    this.currentPhase = this.currentPhase + amount
end

---@private
function this.updateKeyFrames()
    for _, node in pairs(this.nodesToUpdate) do
        local keyFrames = this.currentAnimation.NodeKeyFrames[node.name]
        if keyFrames then
            this.nextKeyFrame(keyFrames.Position)
            this.nextKeyFrame(keyFrames.Rotation)
            this.nextKeyFrame(keyFrames.Scale)
        end
    end
end

---@private
---@param node niNode
---@return boolean
function this.shouldUpdate(node)
    if this.currentAnimation.NodeKeyFrames[node.name] then
        return true
    end
    return false
end

---@private
---@param node niNode
function this.updateNode(node)
    node.translation = this.getNewPosition(node)
    node.rotation = this.getNewRotation(node)
    node.scale = this.getNewScale(node)
    node:update()
end

---@private
---@param keyFrames KeyFrameData
function this.restartKeyFrames(keyFrames)
    keyFrames.Key = keyFrames.Origin
end

---@private
---@param keyFrames KeyFrameData
function this.nextKeyFrame(keyFrames)
    if not keyFrames.Key then
        return
    end
    local next = keyFrames.Key.Next
    if next and this.currentPhase >= next.Value.timing then
        keyFrames.Key = next
    end
end

---@private
---@param node niNode
---@return tes3vector3
function this.getNewPosition(node)
    local currentPosition = node.translation

    local keys  = this.currentAnimation.NodeKeyFrames[node.name].Position.Key
    if not keys or not keys.Next then
        return currentPosition
    end

    local targetPosition = keys.Next.Value

    local transition = this.calculateTransition(keys)

    return currentPosition:lerp(targetPosition.value, transition)
end

---@private
---@param node niNode
---@return tes3matrix33
function this.getNewRotation(node)
    local currentRotation = node.rotation

    local keys  = this.currentAnimation.NodeKeyFrames[node.name].Rotation.Key
    if not keys or not keys.Next then
        return currentRotation
    end

    local targetRotation = keys.Next.Value

    local transition = this.calculateTransition(keys)
    local newRotation = currentRotation:toQuaternion():slerp(targetRotation.value, transition)

    return newRotation:toRotation()
end

---@private
---@param node niNode
---@return number
function this.getNewScale(node)
    local currentScale = node.scale

    local keys  = this.currentAnimation.NodeKeyFrames[node.name].Scale.Key
    if not keys or not keys.Next then
        return currentScale
    end

    local targetScale = keys.Next.Value

    local transition = this.calculateTransition(keys)

    return math.lerp(currentScale, targetScale.value, transition)
end

---@private
---@param keys KeyFrameLinkedList
---@return number
function this.calculateTransition(keys)
    local sourcePhase = keys.Value.timing
    local targetPhase = keys.Next.Value.timing

    return math.clamp(math.remap(this.currentPhase, sourcePhase, targetPhase, 0, 1), 0, 1)
end

---@private
function this.triggerAnimationFinishedEvent()
    ---@type AnimationFinishedEventData
    local eventData = { Animation = this.currentAnimation }
    event.trigger(customEvents.animationFinished, eventData)
end

function this.setupBlinkTimers()
    local iterations = 10
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
    this.blinkPhaseTimer:cancel()
    this.blinkIntervalTimer:cancel()
end

---@private
function this.setupHeadMeshNode()
    this.headNode = MeshNodeService.GetHeadMeshNode(this.currentNpc)

    local controller = MeshNodeService.GetMorphController(this.headNode)
    if controller then
        controller.active = true
    end

    local reference = this.currentNpc --[[@as tes3reference]]
    this.npcAnimationData = reference.attachments.animation --[[@as tes3animationData]]
end

---@private
function this.updateHeadMeshNode()
    local phase = 0
    if this.isSpeaking() then
        phase = this.getLipsyncPhase()
    else
        phase = this.getBlinkingPhase()
    end

    -- For some reason the morph controller only updates when the phase changes by a considerable amount.
    -- Hacking this by calling update once without phase first and then again immediately after.
    this.headNode:update({controllers = true})
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
    if not event.isRegistered(tes3.event.enterFrame, this.onEnterFrame) then
        event.register(tes3.event.enterFrame, this.onEnterFrame)
    end
    if not event.isRegistered(tes3.event.bodyPartsUpdated, this.onBodyPartsUpdated) then
        event.register(tes3.event.bodyPartsUpdated, this.onBodyPartsUpdated)
    end
    if not event.isRegistered(tes3.event.uiActivated, this.onOptionsMenuOpened, { filter = "MenuOptions" }) then
        event.register(tes3.event.uiActivated, this.onOptionsMenuOpened, { filter = "MenuOptions" })
    end
end

---@private
function this.unregisterEvents()
    if event.isRegistered(tes3.event.enterFrame, this.onEnterFrame) then
        event.unregister(tes3.event.enterFrame, this.onEnterFrame)
    end
    if event.isRegistered(tes3.event.bodyPartsUpdated, this.onBodyPartsUpdated) then
        event.unregister(tes3.event.bodyPartsUpdated, this.onBodyPartsUpdated)
    end
    if event.isRegistered(tes3.event.uiActivated, this.onOptionsMenuOpened, { filter = "MenuOptions" }) then
        event.unregister(tes3.event.uiActivated, this.onOptionsMenuOpened, { filter = "MenuOptions" })
    end
end

return this