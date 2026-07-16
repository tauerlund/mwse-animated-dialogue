---@class creatureGroupValidationRule : creatureValidationRule
local this = {}

---@public
---@param configuration creatureAnimationConfiguration
---@return boolean, string|nil
function this.validate(configuration)
    local group = configuration.group
    if group == nil then
        return false, "group is missing"
    end

    if type(group) ~= "string" then
        return false, string.format("group must be a string, got '%s'", tostring(group))
    end

    if tes3.animationGroup[group] == nil then
        return false, string.format("group '%s' is not an animation group name", group)
    end

    return true
end

return this
