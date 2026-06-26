---@class particleController : service
local this = {}

---@public
---@param node niNode|nil
---@return niParticleSystemController[]
function this.resolve(node)
    ---@type niParticleSystemController[]
    local controllers = {}

    this.resolveRecursive(node, controllers)

    return controllers
end

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

---@private
---@param node niNode|nil
---@param controllers niParticleSystemController[]
function this.resolveRecursive(node, controllers)
    if not node or node.appCulled then
        return
    end

    local controller = node.controller --[[@as niParticleSystemController]]
    while controller do
        if controller:isOfType(ni.type.NiParticleSystemController) then
            controllers[#controllers + 1] = controller
        end
        controller = controller.nextController --[[@as niParticleSystemController]]
    end

    if not node.children then
        return
    end

    for _, child in ipairs(node.children) do
        this.resolveRecursive(child --[[@as niNode]], controllers)
    end
end

return this
