---@class sexFilteringRule : conditionFilteringRule
local this = {}

---@public
---@param configuration filterableConfiguration
---@param actor tes3reference
---@return boolean
function this.isMet(configuration, actor)
    local sex = configuration.conditions and configuration.conditions.sex
    if not sex then
        return true
    end

    if actor.baseObject.objectType ~= tes3.objectType.npc then
        return false
    end

    return (sex == "female") == (actor.baseObject.female == true)
end

return this
