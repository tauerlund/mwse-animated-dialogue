---@class beastFilteringRule : conditionFilteringRule
local this = {}

---@public
---@param configuration filterableConfiguration
---@param actor tes3reference
---@return boolean
function this.isMet(configuration, actor)
    local conditions = configuration.conditions
    if conditions and conditions.race then
        return true
    end

    if actor.baseObject.objectType ~= tes3.objectType.npc then
        return conditions == nil or conditions.beast == nil
    end

    local beastOnly = conditions
        and conditions.beast == true
        or false

    if beastOnly then
        return actor.baseObject.race.isBeast
    end

    return not actor.baseObject.race.isBeast
end

return this
