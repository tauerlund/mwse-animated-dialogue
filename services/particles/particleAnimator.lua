---@class particleAnimator : service
local this = {}

---@public
---@param controllers niParticleSystemController[]
---@param delta number
function this.update(controllers, delta)
    for i = 1, #controllers do
        local controller = controllers[i]
        local target = controller.target --[[@as niNode]]
        if target then
            target:update({ controllers = true, time = controller.lastTime + delta })
        end
    end
end

return this
