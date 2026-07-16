---@class beastFilteringRule : animationFilteringRule
local this = {}

---@public
---@param configuration baseAnimationConfiguration
---@param actor tes3reference
---@return boolean
function this.isMet(configuration, actor)
    local conditions = configuration.conditions
    if conditions and conditions.race then
        return true
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
