---@class particleAnimator : service
local this = {}

---@public
---@param controllers niParticleSystemController[]
---@param delta number
function this.update(controllers, delta)
    for _, controller in ipairs(controllers) do
        local target = controller.target --[[@as niNode]]
        if target then
            target:update({ controllers = true, time = controller.lastTime + delta })
        end
    end
end

return this
