---@class bodySkeletonTicker : initializedService
local this = {}

---@private
---@type bonePinner
this.bonePinner = nil

---@public
---@param services serviceCollection
---@return boolean, string|nil
function this.initialize(services)
    this.bonePinner = services.bonePinner

    return true, nil
end

---@public
---@return bodySkeletonTicker.state
function this.create()
    return {
        actor              = nil,
        start              = 0,
        stop               = 0,
        phase              = 0,
        pinner             = this.bonePinner.create(),
        poseBlender        = nil,
        transitionDuration = 0,
    }
end

---@public
---@param state bodySkeletonTicker.state
---@param params bodySkeletonTicker.begin.param
function this.begin(state, params)
    state.actor              = params.actor
    state.start              = params.start
    state.stop               = params.stop
    state.phase              = params.start
    state.poseBlender        = params.poseBlender
    state.transitionDuration = params.transitionDuration or 0

    local animationData = params.actor.animationData
    local actorNode     = animationData and animationData.actorNode
    state.pinner:capture(actorNode)

    -- Capture the pre-animation pose before the first tick drives the skeleton,
    -- so the blend eases from the frozen dialogue-open pose into the clip.
    if state.poseBlender and actorNode then
        state.poseBlender:capture(actorNode, state.transitionDuration)
    end
end

---@public
---@param state bodySkeletonTicker.state
function this.reset(state)
    if state.poseBlender then
        state.poseBlender:reset()
    end

    state.pinner:reset()

    state.actor              = nil
    state.start              = 0
    state.stop               = 0
    state.phase              = 0
    state.poseBlender        = nil
    state.transitionDuration = 0
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

    state.pinner:apply()
    animationData.actorNode:update({ children = true })

    if state.poseBlender and state.poseBlender:isActive() then
        state.poseBlender:update(animationData.actorNode, delta)
    end

    state.phase = state.phase + delta
    if state.phase >= state.stop then
        state.phase = state.start + (state.phase - state.stop)
    end
end

return this
