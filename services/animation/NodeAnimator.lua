local Logger = require("tauer.animated-dialogue.shared.Logger").Create("NodeAnimator")
local BipNodeService = require("tauer.animated-dialogue.services.nodes.BipNodeService")
local MeshNodeService = require("tauer.animated-dialogue.services.nodes.MeshNodeService")

local customEvents = require("tauer.animated-dialogue.shared.Events")

---@class NodeAnimator
local this = {}

---@private
---@type tes3npcInstance
this.currentNpc = nil

---@private
---@type [niNode]:string
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
    this.setupHeadMeshNode()
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
    this.currentAnimation = animation
    this.restartCurrentAnimation()
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
    local lipSyncAnimStart = 0
    local lipSyncAnimEnd = 1.333

    local time = math.clamp(math.remap(this.npcAnimationData.lipsyncLevel, -1, 1, lipSyncAnimStart, lipSyncAnimEnd), -1, 1)

    -- For some reason the morph controller only updates when the phase changes by a considerable amount,
    -- so we set it to the negative value of the desired phase first and then update immediately after.
    this.headNode:update({controllers = true, time = -time})
    this.headNode:update({controllers = true, time = time})
end

function this.isSpeaking()
    return this.npcAnimationData.lipsyncLevel ~= -1
end

---@private
function this.registerEvents()
    if not event.isRegistered(tes3.event.enterFrame, this.onEnterFrame) then
        event.register(tes3.event.enterFrame, this.onEnterFrame)
    end
end

---@private
function this.unregisterEvents()
    if event.isRegistered(tes3.event.enterFrame, this.onEnterFrame) then
        event.unregister(tes3.event.enterFrame, this.onEnterFrame)
    end
end

return this

