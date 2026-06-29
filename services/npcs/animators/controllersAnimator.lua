---@class npcControllersAnimator : initializedService, npcAnimator
local this = {}

---@private
---@type eventRegistrar
this.eventRegistrar = nil

---@private
---@type settings
this.settings = nil

---@private
---@type npcPoseBlender
this.npcPoseBlender = nil

---@private
---@type animationResolver
this.animationResolver = nil

---@private
---@type tes3reference
this.npc = nil

---@private
---@type number
this.phase = 0

---@private
---@type number
this.phaseStart = 0

---@private
---@type number
this.phaseEnd = 0

---@private
---@type mwseLogger
this.logger = mwse.Logger.new()

-- The standalone-loaded animation mesh whose keyframe controllers we drive onto the live
-- skeleton. Held so it is not garbage-collected while bound.
---@private
---@type niNode
this.source = nil

-- Each entry: { target = niNode, controller = niKeyframeController }. The controller has been
-- moved onto the live bone (it both owns and targets it), so ticking the bone poses it.
---@private
this.boundControllers = {}

---@private
this.boundCount = 0

-- Bones the source animation does not keyframe (e.g. the Bip01 root). Each entry:
-- { target = niNode, rotation = tes3matrix33 }. Held at the source's rest rotation every frame
-- so stale locomotion tilt cannot persist or be dragged back in by the pose blend.
---@private
this.restBones = {}

---@private
this.restCount = 0

---@private
this.eventHandlers = nil

---@public
---@param services serviceCollection
---@return boolean,string|nil
function this.initialize(services)
    this.eventRegistrar    = services.eventRegistrar
    this.settings          = services.settings
    this.npcPoseBlender    = services.npcPoseBlender
    this.animationResolver = services.animationResolver

    local events        = services.enums.events
    this.eventHandlers  = {
        [events.dialogueStarted] = this.onDialogueStarted,
        [events.dialogueEnded]   = this.onDialogueEnded,
        [tes3.event.infoGetText] = this.onInfoGetText,
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
    local animation = this.animationResolver.resolveIdle(e.npc)
    if not animation then
        return
    end

    this.applyAnimation(e.npc, animation)
end

---@private
---@param _ infoGetTextEventData
function this.onInfoGetText(_)
    if not this.npc then
        return
    end

    local animation = this.animationResolver.resolveTalk()
    if not animation then
        return
    end

    this.applyAnimation(this.npc, animation)
end

---@private
function this.onDialogueEnded()
    this.animationResolver.reset()
    this.releaseSource()
    this.npc = nil
    this.npcPoseBlender.reset()
end

-- Load the resolved animation mesh and rebind its keyframe controllers onto the live skeleton.
---@private
---@param npc tes3reference
---@param animation animationDefinition
function this.applyAnimation(npc, animation)
    this.npc = npc

    local animationData = this.npc.animationData
    if not animationData then
        return
    end

    -- Re-applying (e.g. a talk animation mid-dialogue) rebinds to a new source.
    this.releaseSource()

    -- Capture the genuine current pose so the transition into the animation blends from it.
    -- We never call tes3.loadAnimation, so the skeleton is intact and these node refs stay valid.
    this.npcPoseBlender.capture(animationData.actorNode, this.settings.transitionDuration)

    local source = tes3.loadMesh(animation.file, false)
    if not source then
        this.logger:error("Could not load animation mesh '%s'", animation.file)
        this.npc = nil
        return
    end

    this.source = source
    this.bindControllers(animationData.actorNode, source)

    if this.boundCount == 0 then
        this.logger:error("No bones matched for animation '%s'", animation.file)
        this.releaseSource()
        this.npc = nil
        return
    end

    this.phase = this.phaseStart
end

-- Move each of the source mesh's keyframe controllers onto the live skeleton bone of the same
-- name (attach + retarget), so the live bone both owns and is the target of the controller --
-- the only arrangement that actually ticks (a detached source node never updates). Establishes
-- the [start, stop] loop window from the controllers' own key range.
---@private
---@param actorNode niNode
---@param source niNode
function this.bindControllers(actorNode, source)
    this.boundCount = 0
    this.restCount  = 0
    this.phaseStart = 0
    this.phaseEnd   = 0

    local liveBones = this.buildBoneMap(actorNode)

    local function walk(node)
        if not node then
            return
        end

        local liveBone   = node.name and liveBones[node.name]
        local controller = node.controller
        if controller and liveBone then
            this.bindController(node, controller, liveBone)
        elseif liveBone then
            this.recordRestBone(node, liveBone)
        end

        if node.children then
            for i = 1, #node.children do
                walk(node.children[i])
            end
        end
    end

    walk(source)
end

---@private
---@param node niNode
---@param controller niKeyframeController
---@param liveBone niNode
function this.bindController(node, controller, liveBone)
    controller.animTimingType = 1 -- treat fed time as an offset from the start
    controller.frequency      = 1
    controller.phase          = 0
    controller.active         = true

    -- Prepend before removing so the controller is never at a zero ref count mid-move.
    liveBone:prependController(controller)
    node:removeController(controller)
    controller:setTarget(liveBone)

    local index                  = this.boundCount + 1
    this.boundCount              = index
    this.boundControllers[index] = this.boundControllers[index] or {}
    this.boundControllers[index].target     = liveBone
    this.boundControllers[index].controller = controller

    if controller.highKeyFrame > this.phaseEnd then
        this.phaseEnd = controller.highKeyFrame
    end
end

---@private
---@param node niNode
---@param liveBone niNode
function this.recordRestBone(node, liveBone)
    local index            = this.restCount + 1
    this.restCount         = index
    this.restBones[index]  = this.restBones[index] or {}
    this.restBones[index].target   = liveBone
    this.restBones[index].rotation = node.rotation:copy()
end

---@private
---@param actorNode niNode
---@return table<string, niNode>
function this.buildBoneMap(actorNode)
    local map = {}

    local function walk(node)
        if not node then
            return
        end

        if node.name then
            map[node.name] = node
        end

        if node.children then
            for i = 1, #node.children do
                walk(node.children[i])
            end
        end
    end

    walk(actorNode)
    return map
end

-- Detach our controllers from the live skeleton so the engine's own animation manager resumes
-- posing the bones once dialogue closes; otherwise the actor stays frozen in the last pose.
---@private
function this.releaseSource()
    for i = 1, this.boundCount do
        local bound = this.boundControllers[i]
        bound.target:removeController(bound.controller)
        bound.target     = nil
        bound.controller = nil
    end

    for i = 1, this.restCount do
        this.restBones[i].target   = nil
        this.restBones[i].rotation = nil
    end

    this.boundCount = 0
    this.restCount  = 0
    this.source     = nil
    this.phase      = 0
end

---@public
---@param delta number
function this.update(delta)
    if not this.npc or not this.source then
        return
    end

    local animationData = this.npc.animationData
    if not animationData then
        return
    end

    for i = 1, this.boundCount do
        this.boundControllers[i].target:update({
            controllers = true,
            time        = this.phase
        })
    end

    -- Hold un-keyframed bones at rest each frame, before the blend reads the pose.
    for i = 1, this.restCount do
        this.restBones[i].target.rotation = this.restBones[i].rotation
    end

    animationData.actorNode:update({ children = true })

    if this.npcPoseBlender.isActive() then
        this.npcPoseBlender.update(animationData.actorNode, delta)
    end

    animationData.headNode:update({
        controllers = true,
        time        = 0
    })

    this.phase = this.phase + delta
    if this.phase >= this.phaseEnd then
        this.phase = this.phaseStart
    end
end

return this
