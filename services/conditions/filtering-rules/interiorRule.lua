---@class interiorFilteringRule : conditionFilteringRule
local this = {}

---@public
---@param configuration filterableConfiguration
---@param actor tes3reference
---@return boolean
function this.isMet(configuration, actor)
    local interior = configuration.conditions and configuration.conditions.interior
    if interior == nil then
        return true
    end

    return actor.cell.isInterior == interior
end

return this
