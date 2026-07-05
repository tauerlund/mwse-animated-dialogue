---@class bodySkeletonTicker
local this = {}

---@private
this.bonePrefix = "Bip"

---@public
---@return bodySkeletonTicker.state
function this.create()
    return { actor = nil, start = 0, stop = 0, phase = 0, pins = {} }
end

---@private
---@param state bodySkeletonTicker.state
---@param actorNode niNode|nil
function this.resolvePinnedNodes(state, actorNode)
    if not actorNode then
        return
    end

    for bone in actorNode:traverse({ prefix = this.bonePrefix }) do
        state.pins[#state.pins + 1] = {
            node = bone --[[@as niNode]],
            translation = bone.translation:copy()
        }
    end
end

---@public
---@param state bodySkeletonTicker.state
---@param params bodySkeletonTicker.begin.param
function this.begin(state, params)
    state.actor         = params.actor
    state.start         = params.start
    state.stop          = params.stop
    state.phase         = params.start
    state.pins          = {}

    local animationData = params.actor.animationData
    local actorNode     = animationData and animationData.actorNode
    this.resolvePinnedNodes(state, actorNode)
end

---@public
---@param state bodySkeletonTicker.state
function this.reset(state)
    state.actor = nil
    state.start = 0
    state.stop  = 0
    state.phase = 0
    state.pins  = {}
end

---@public
---@param state bodySkeletonTicker.state
---@param delta number
function this.update(state, delta)
    if not state.actor then
        return
    end

    local animationData = state.actor.animationData
    if not animationData then
        return
    end

    animationData.actorNode:update({
        children    = true,
        controllers = true,
        time        = state.phase,
    })

    for _, pin in ipairs(state.pins) do
        local translation = pin.node.translation
        translation.x = pin.translation.x
        translation.y = pin.translation.y
        pin.node.translation = translation
    end
    animationData.actorNode:update({ children = true })

    state.phase = state.phase + delta
    if state.phase >= state.stop then
        state.phase = state.start
    end
end

return this
