---@class conditionsValidationRule : animationValidationRule
local this = {}

---@private
---@type arrays
this.arrays = nil

---@public
---@param services serviceCollection
function this.initialize(services)
    this.arrays = services.arrays
end

---@public
---@param configuration baseAnimationConfiguration
---@return boolean, string|nil
function this.validate(configuration)
    local conditions = configuration.conditions
    if conditions == nil then
        return true
    end

    if type(conditions) ~= "table" then
        return false, "conditions must be a table"
    end

    if conditions.class ~= nil and not this.arrays.isNonEmptyStringArray(conditions.class) then
        return false, "conditions.class must be a non-empty array of strings"
    end

    if conditions.sex ~= nil and conditions.sex ~= "male" and conditions.sex ~= "female" then
        return false, "conditions.sex must be 'male' or 'female'"
    end

    if conditions.beast ~= nil and type(conditions.beast) ~= "boolean" then
        return false, "conditions.beast must be a boolean"
    end

    if conditions.torchCompatible ~= nil and type(conditions.torchCompatible) ~= "boolean" then
        return false, "conditions.torchCompatible must be a boolean"
    end

    if conditions.shieldCompatible ~= nil and type(conditions.shieldCompatible) ~= "boolean" then
        return false, "conditions.shieldCompatible must be a boolean"
    end

    return true
end

return this
