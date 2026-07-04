---@class beastFilteringRule : animationFilteringRule
local this = {}

---@public
---@param configuration baseAnimationConfiguration
---@param actor tes3reference
---@return boolean
function this.isMet(configuration, actor)
    local beastOnly = configuration.conditions
        and configuration.conditions.beast == true
        or false

    if beastOnly then
        return actor.baseObject.race.isBeast
    end

    return not actor.baseObject.race.isBeast
end

return this
