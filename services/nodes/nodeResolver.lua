---@class nodeResolver : service
local this = {}

---@public
---@param root niNode
---@param controllerType integer a value from `ni.type`
---@return niTimeController[]
function this.resolveControllers(root, controllerType)
    ---@type niTimeController[]
    local controllers = {}

    for node in root:traverse() do
        local controller = node.controller
        while controller do
            if controller:isOfType(controllerType) then
                controllers[#controllers + 1] = controller
            end
            controller = controller.nextController
        end
    end

    return controllers
end

return this
