---@class beastFilteringRule : animationFilteringRule
local this = {}

---@public
---@param configuration baseAnimationConfiguration
---@param npc tes3reference
---@return boolean
function this.isMet(configuration, npc)
    local npcIsBeast = npc.baseObject.race.isBeast

    local beastExclusive = configuration.conditions
        and configuration.conditions.beast == true
        or false

    return npcIsBeast == beastExclusive
end

return this
