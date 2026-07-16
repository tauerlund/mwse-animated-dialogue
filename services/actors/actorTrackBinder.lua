---@class actorTrackBinder : initializedService
local this          = {}

local LEFT_ARM_ROOT = "Bip01 L Clavicle"
local BONE_PREFIX   = "Bip"

local REGION        = {
    all     = "all",
    body    = "body",
    leftArm = "leftArm",
}

---@public
this.region         = REGION

---@private
---@type nifLoader
this.nifLoader      = nil

---@private
---@type mwseLogger
this.logger         = mwse.Logger.new()

---@public
---@param services serviceCollection
---@return boolean, string|nil
function this.initialize(services)
    this.nifLoader = services.nifLoader

    return true, nil
end

---@public
---@return track
function this.create()
    return {
        source      = nil,
        controllers = {},
        count       = 0,
        rest        = {},
        restCount   = 0,
        phase       = 0,
        start       = 0,
        stop        = 0,
        looping     = false,
    }
end

---@public
---@param params actorTrackBinder.bind.param
---@return integer count
function this.bind(params)
    local track = params.track

    local source = this.nifLoader.load(params.file)
    if not source then
        this.logger:error("Could not load animation mesh '%s' (file missing or failed to load)", params.file)
        return 0
    end

    local start, stop = this.resolveTimings(source, params.group)
    if not start or not stop then
        this.logger:error("No '%s' group timing in '%s'", params.group, params.file)
        return 0
    end

    track.source = source
    this.bindBones(track, params.actorNode, source, params.region)

    if track.count == 0 then
        this.logger:error("No bones matched for animation '%s'", params.file)
        this.reset(track)
        return 0
    end

    track.start   = start
    track.stop    = stop
    track.phase   = start
    track.looping = params.loop

    this.applyGroupOffset(track, start)

    return track.count
end

---@private
---@param track track
---@param start number
function this.applyGroupOffset(track, start)
    for i = 1, track.count do
        track.controllers[i].controller.phase = start
    end
end

---@public
---@param track track
function this.reset(track)
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
    track.source    = nil
end

---@private
---@param source niNode
---@param group string
---@return number|nil start, number|nil stop
function this.resolveTimings(source, group)
    local startMarker = group:lower() .. ": start"
    local stopMarker  = group:lower() .. ": stop"
    local start, stop

    for node in source:traverse() do
        local extra = node.extraData
        while extra do
            if extra.keys then
                start, stop = this.readMarkerKeys(extra.keys, startMarker, stopMarker, start, stop)
            end
            extra = extra.next
        end
    end

    return start, stop
end

---@private
---@param keys niTextKey[]
---@param startMarker string
---@param stopMarker string
---@param start number|nil
---@param stop number|nil
---@return number|nil start, number|nil stop
function this.readMarkerKeys(keys, startMarker, stopMarker, start, stop)
    for i = 1, #keys do
        local key = keys[i]
        local marker = key.text:lower():trim()
        if marker == startMarker then
            start = key.time
        elseif marker == stopMarker then
            stop = key.time
        end
    end

    return start, stop
end

---@private
---@param track track
---@param actorNode niNode
---@param source niNode
---@param region string
function this.bindBones(track, actorNode, source, region)
    track.count     = 0
    track.restCount = 0

    local bones     = this.buildBoneMap(actorNode)

    this.bindNode(source, false, track, region, bones)
end

---@private
---@param node niNode
---@param inLeftArm boolean
---@param track track
---@param region string
---@param bones table<string, niNode>
function this.bindNode(node, inLeftArm, track, region, bones)
    if not node then
        return
    end

    inLeftArm = inLeftArm or node.name == LEFT_ARM_ROOT

    if node.name and this.isBoneInRegion(region, inLeftArm) then
        local bone = bones[node.name]
        if bone then
            local controller = node.controller
            if controller then
                this.bindController(track, node, controller, bone)
            else
                this.storeRestBone(track, node, bone)
            end
        end
    end

    if node.children then
        for i = 1, #node.children do
            this.bindNode(node.children[i] --[[@as niNode]], inLeftArm, track, region, bones)
        end
    end
end

---@private
---@param region string
---@param inLeftArm boolean
---@return boolean
function this.isBoneInRegion(region, inLeftArm)
    if region == REGION.body then
        return not inLeftArm
    elseif region == REGION.leftArm then
        return inLeftArm
    end

    return true
end

---@private
---@param track track
---@param node niNode
---@param controller niTimeController
---@param liveBone niNode
function this.bindController(track, node, controller, liveBone)
    controller.animTimingType = 1
    controller.frequency      = 1
    controller.phase          = 0
    controller.cycleType      = ni.animCycleType.clamp
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
---@param track track
---@param node niNode
---@param liveBone niNode
function this.storeRestBone(track, node, liveBone)
    local index                = track.restCount + 1
    track.restCount            = index
    track.rest[index]          = track.rest[index] or {}
    track.rest[index].target   = liveBone
    track.rest[index].rotation = node.rotation:copy()
end

---@private
---@param actorNode niNode
---@return table<string, niNode>
function this.buildBoneMap(actorNode)
    local map = {}

    for bone in actorNode:traverse({ prefix = BONE_PREFIX }) do
        map[bone.name] = bone --[[@as niNode]]
    end

    return map
end

return this
