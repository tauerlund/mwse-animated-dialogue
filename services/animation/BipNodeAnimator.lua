local BipNodeService = require("tauer.animated-dialogue.services.nodes.BipNodeService")

local customEvents = require("tauer.animated-dialogue.shared.Events")

---@class BipNodeAnimator
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

---@public
---@param npc tes3npcInstance
---@param animation Animation
function this.Start(npc, animation)
    this.currentNpc = npc
    this.nodesToUpdate = BipNodeService.GetAllBipNodes(npc.sceneNode, { IncludeParent = true, Exclude = { "Bip01 Head" } })

    this.SetAnimation(animation)
    this.restartCurrentAnimation()
    this.registerEvents()
end

---@public
function this.Stop()
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
    this.currentAnimation = table.deepcopy(animation)
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
            this.incrementKeyFrames(keyFrames.Position)
            this.incrementKeyFrames(keyFrames.Rotation)
            this.incrementKeyFrames(keyFrames.Scale)
        end
    end
end

---@private
---@param node niNode
---@return boolean
function this.shouldUpdate(node)
    return this.currentAnimation.NodeKeyFrames[node.name] ~= nil
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
function this.incrementKeyFrames(keyFrames)
    local next = keyFrames.Key and keyFrames.Key.Next
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
    event.trigger(customEvents.AnimationFinished, eventData)
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
    if not event.isRegistered(tes3.event.uiActivated, this.onOptionsMenuOpened, { filter = "MenuOptions" }) then
        event.register(tes3.event.uiActivated, this.onOptionsMenuOpened, { filter = "MenuOptions" })
    end
end

---@private
function this.unregisterEvents()
    if event.isRegistered(tes3.event.enterFrame, this.onEnterFrame) then
        event.unregister(tes3.event.enterFrame, this.onEnterFrame)
    end
    if event.isRegistered(tes3.event.uiActivated, this.onOptionsMenuOpened, { filter = "MenuOptions" }) then
        event.unregister(tes3.event.uiActivated, this.onOptionsMenuOpened, { filter = "MenuOptions" })
    end
end

return this