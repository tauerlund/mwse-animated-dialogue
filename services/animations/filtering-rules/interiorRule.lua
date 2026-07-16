---@class interiorFilteringRule : animationFilteringRule
local this = {}

---@public
---@param configuration baseAnimationConfiguration
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
