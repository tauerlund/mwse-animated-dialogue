---@class sexFilteringRule : animationFilteringRule
local this = {}

---@public
---@param configuration baseAnimationConfiguration
---@param actor tes3reference
---@return boolean
function this.isMet(configuration, actor)
    local sex = configuration.conditions and configuration.conditions.sex
    if not sex then
        return true
    end

    return (sex == "female") == (actor.baseObject.female == true)
end

return this
