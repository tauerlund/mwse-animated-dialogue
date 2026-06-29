---@class npcControllersAnimator : initializedService, npcAnimator
local this = {}

local LEFT_ARM_ROOT = "Bip01 L Clavicle"

local BONE_REGION = {
    all     = "all",
    body    = "body",
    leftArm = "leftArm",
}

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
---@type mwseLogger
this.logger = mwse.Logger.new()

---@private
---@type niNode
this.source = nil

---@private
---@type niNode
this.torchSource = nil

---@private
this.bodyTrack = { controllers = {}, count = 0, rest = {}, restCount = 0, phase = 0, start = 0, stop = 0, looping = false }

---@private
this.torchTrack = { controllers = {}, count = 0, rest = {}, restCount = 0, phase = 0, start = 0, stop = 0, looping = false }

---@private
---@type animationDefinition
this.torchArmAnimation = { file = "tauer\\ad\\torch.nif", group = "idle9" }

---@private
this.eventHandlers = nil

---@private
---@type baseAnimationConfiguration
this.animationConfiguration = nil

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
    local configuration = this.animationResolver.resolve(e.npc)
    if not configuration then
        return
    end

    this.npc = e.npc
    this.animationConfiguration = configuration
    this.applyAnimation(configuration.idle, true)
end

---@private
---@param _ infoGetTextEventData
function this.onInfoGetText(_)
    if not this.npc then
        return
    end

    local animation = table.choice(this.animationConfiguration.talk)

    this.applyAnimation(animation, false)
end

---@private
function this.onDialogueEnded()
    this.animationResolver.reset()
    this.resetControllers()
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

    this.resetControllers()
    this.npcPoseBlender.capture(animationData.actorNode, this.settings.transitionDuration)

    local source = tes3.loadMesh(animation.file, false)
    if not source then
        this.logger:error("Could not load animation mesh '%s'", animation.file)
        this.npc = nil
        return
    end

    this.source = source

    local start, stop = this.resolveTimings(source, animation.group)
    if not start or not stop then
        this.logger:error("No '%s' group window in '%s'", animation.group, animation.file)
        this.resetControllers()
        this.npc = nil
        return
    end

    local anchorTorch = this.isHoldingTorch()

    this.bindTrack({
        track     = this.bodyTrack,
        actorNode = animationData.actorNode,
        source    = source,
        region    = anchorTorch and BONE_REGION.body or BONE_REGION.all,
    })

    if this.bodyTrack.count == 0 then
        this.logger:error("No bones matched for animation '%s'", animation.file)
        this.resetControllers()
        this.npc = nil
        return
    end

    this.startTrack({ track = this.bodyTrack, start = start, stop = stop, loop = loop })

    if anchorTorch then
        this.applyTorchArm(animationData.actorNode)
    end
end

---@private
---@param actorNode niNode
function this.applyTorchArm(actorNode)
    local source = tes3.loadMesh(this.torchArmAnimation.file, true):clone() --[[@as niNode]]
    if not source then
        this.logger:error("Could not load torch-arm mesh '%s'", this.torchArmAnimation.file)
        return
    end

    local start, stop = this.resolveTimings(source, this.torchArmAnimation.group)
    if not start or not stop then
        this.logger:error("No '%s' group window in torch-arm '%s'", this.torchArmAnimation.group,
            this.torchArmAnimation.file)
        return
    end

    this.torchSource = source

    this.bindTrack({
        track     = this.torchTrack,
        actorNode = actorNode,
        source    = source,
        region    = BONE_REGION.leftArm,
    })

    this.startTrack({
        track = this.torchTrack,
        start = start,
        stop = stop,
        loop = true
    })
end

---@private
---@return boolean
function this.isHoldingTorch()
    local mobile = this.npc.mobile
    return mobile ~= nil and mobile.torchSlot ~= nil and mobile.torchSlot.object ~= nil
end

---@private
---@param source niNode
---@param group string
---@return number|nil start, number|nil stop
function this.resolveTimings(source, group)
    local startMarker = group:lower() .. ": start"
    local stopMarker  = group:lower() .. ": stop"
    local start, stop

    local function walk(node)
        if not node then
            return
        end

        local extra = node.extraData
        while extra do
            if extra.keys then
                for i = 1, #extra.keys do
                    local text = extra.keys[i].text:lower()
                    if text == startMarker then
                        start = extra.keys[i].time
                    elseif text == stopMarker then
                        stop = extra.keys[i].time
                    end
                end
            end
            extra = extra.next
        end

        if node.children then
            for i = 1, #node.children do
                walk(node.children[i])
            end
        end
    end

    walk(source)
    return start, stop
end

---@class bindTrackParams
---@field track table
---@field actorNode niNode
---@field source niNode
---@field region string

---@private
---@param params bindTrackParams
function this.bindTrack(params)
    local track     = params.track
    local region    = params.region

    track.count     = 0
    track.restCount = 0

    local liveBones = this.buildBoneMap(params.actorNode)

    local function walk(node, inLeftArm)
        if not node then
            return
        end

        inLeftArm = inLeftArm or node.name == LEFT_ARM_ROOT

        if node.name and this.isBoneInRegion(region, inLeftArm) then
            local liveBone = liveBones[node.name]
            if liveBone then
                local controller = node.controller
                if controller then
                    this.bindController(track, node, controller, liveBone)
                else
                    this.recordRestBone(track, node, liveBone)
                end
            end
        end

        if node.children then
            for i = 1, #node.children do
                walk(node.children[i], inLeftArm)
            end
        end
    end

    walk(params.source, false)
end

---@private
---@param region string
---@param inLeftArm boolean
---@return boolean
function this.isBoneInRegion(region, inLeftArm)
    if region == BONE_REGION.body then
        return not inLeftArm
    elseif region == BONE_REGION.leftArm then
        return inLeftArm
    end

    return true
end

---@private
---@param track table
---@param node niNode
---@param controller niKeyframeController
---@param liveBone niNode
function this.bindController(track, node, controller, liveBone)
    controller.animTimingType = 1
    controller.frequency      = 1
    controller.phase          = 0
    controller.active         = true

    liveBone:prependController(controller)
    node:removeController(controller)
    controller:setTarget(liveBone)

    local index                         = track.count + 1
    track.count                         = index
    track.controllers[index]            = track.controllers[index] or {}
    track.controllers[index].target     = liveBone
    track.controllers[index].controller = controller
end

---@private
---@param track table
---@param node niNode
---@param liveBone niNode
function this.recordRestBone(track, node, liveBone)
    local index                = track.restCount + 1
    track.restCount            = index
    track.rest[index]          = track.rest[index] or {}
    track.rest[index].target   = liveBone
    track.rest[index].rotation = node.rotation:copy()
end

---@class startTrackParams
---@field track table
---@field start number
---@field stop number
---@field loop boolean

---@private
---@param params startTrackParams
function this.startTrack(params)
    local track   = params.track
    track.start   = params.start
    track.stop    = params.stop
    track.phase   = params.start
    track.looping = params.loop
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
function this.resetControllers()
    this.resetTrack(this.bodyTrack)
    this.resetTrack(this.torchTrack)
    this.source      = nil
    this.torchSource = nil
end

---@private
---@param track table
function this.resetTrack(track)
    for i = 1, track.count do
        local bound = track.controllers[i]
        bound.target:removeController(bound.controller)
        bound.target     = nil
        bound.controller = nil
    end

    for i = 1, track.restCount do
        track.rest[i].target   = nil
        track.rest[i].rotation = nil
    end

    track.count     = 0
    track.restCount = 0
    track.phase     = 0
end

---@private
---@param track table
function this.updateTrack(track)
    for i = 1, track.count do
        track.controllers[i].target:update({
            controllers = true,
            time        = track.phase
        })
    end

    for i = 1, track.restCount do
        track.rest[i].target.rotation = track.rest[i].rotation
    end
end

---@private
---@param track table
---@param delta number
function this.advanceTrack(track, delta)
    if track.count == 0 then
        return
    end

    track.phase = track.phase + delta
    if track.phase < track.stop then
        return
    end

    if track.looping then
        track.phase = track.start
    else
        this.applyAnimation(this.animationConfiguration.idle, true)
    end
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

    this.updateTrack(this.bodyTrack)
    this.updateTrack(this.torchTrack)

    animationData.actorNode:update({ children = true })

    if this.npcPoseBlender.isActive() then
        this.npcPoseBlender.update(animationData.actorNode, delta)
    end

    animationData.headNode:update({
        controllers = true,
        time        = 0
    })

    this.advanceTrack(this.torchTrack, delta)
    this.advanceTrack(this.bodyTrack, delta)
end

return this
