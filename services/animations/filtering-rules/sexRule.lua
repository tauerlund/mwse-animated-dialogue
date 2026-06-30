---@class sexFilteringRule : animationFilteringRule
local this = {}

---@public
---@param configuration baseAnimationConfiguration
---@param npc tes3reference
---@return boolean
function this.isMet(configuration, npc)
    local sex = configuration.conditions and configuration.conditions.sex
    if not sex then
        return true
    end

    return sex == "female"
        and npc.baseObject.female
        or not npc.baseObject.female
end

return this
