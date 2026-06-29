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

---@private
---@type niNode
this.source = nil

---@private
this.boundControllers = {}

---@private
this.boundCount = 0

---@private
this.restBones = {}

---@private
this.restCount = 0

---@private
this.eventHandlers = nil

---@private
---@type animationDefinition
this.idleAnimation = nil

---@public
---@param services serviceCollection
---@return boolean,string|nil
function this.initialize(services)
    this.eventRegistrar    = services.eventRegistrar
    this.settings          = services.settings
    this.npcPoseBlender    = services.npcPoseBlender
    this.animationResolver = services.animationResolver

    local events           = services.enums.events
    this.eventHandlers     = {
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

    this.npc = e.npc
    this.idleAnimation = animation
    this.applyAnimation(animation, true)
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

    this.applyAnimation(animation, false)
end

---@private
function this.onDialogueEnded()
    this.animationResolver.reset()
    this.releaseSource()
    this.npc = nil
    this.npcPoseBlender.reset()
end

---@private
---@param animation animationDefinition
---@param loop boolean
function this.applyAnimation(animation, loop)
    local animationData = this.npc.animationData
    if not animationData then
        return
    end

    this.releaseSource()
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
    this.looping = loop
end

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
    controller.animTimingType = 1
    controller.frequency      = 1
    controller.phase          = 0
    controller.active         = true

    liveBone:prependController(controller)
    node:removeController(controller)
    controller:setTarget(liveBone)

    local index                             = this.boundCount + 1
    this.boundCount                         = index
    this.boundControllers[index]            = this.boundControllers[index] or {}
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
    local index                    = this.restCount + 1
    this.restCount                 = index
    this.restBones[index]          = this.restBones[index] or {}
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
        if this.looping then
            this.phase = this.phaseStart
        else
            this.applyAnimation(this.idleAnimation, true)
        end
    end
end

return this
