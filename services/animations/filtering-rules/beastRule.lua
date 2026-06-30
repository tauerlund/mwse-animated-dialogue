---@class beastFilteringRule : animationFilteringRule
local this = {}

---@public
---@param configuration baseAnimationConfiguration
---@param npc tes3reference
---@return boolean
function this.isMet(configuration, npc)
    local beastOnly = configuration.conditions
        and configuration.conditions.beast == true
        or false

    if beastOnly then
        return npc.baseObject.race.isBeast
    end

    return not npc.baseObject.race.isBeast
end

return this
