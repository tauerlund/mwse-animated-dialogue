--- Shared driver for body strategies that keep an actor's OWN bound animation
--- playing while the engine's per-frame pass is frozen in menu-mode: it ticks
--- the whole skeleton each frame over a group's `[start, stop]` window, looping.
--- Stateless module operating on caller-owned state (mirrors actorTrackBinder).
---@class bodySkeletonTicker
local this = {}

---@public
---@return bodySkeletonTicker.state
function this.create()
    return { actor = nil, start = 0, stop = 0, phase = 0 }
end

---@public
---@param state bodySkeletonTicker.state
---@param params bodySkeletonTicker.begin.param
function this.begin(state, params)
    state.actor = params.actor
    state.start = params.start
    state.stop  = params.stop
    state.phase = params.start
end

---@public
---@param state bodySkeletonTicker.state
function this.reset(state)
    state.actor = nil
    state.start = 0
    state.stop  = 0
    state.phase = 0
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

    state.phase = state.phase + delta
    if state.phase >= state.stop then
        state.phase = state.start
    end
end

return this
