---@class overrideWeightValidationRule : overrideValidationRule
local this = {}

---@public
---@param configuration overrideAnimationConfiguration
---@return boolean, string|nil
function this.validate(configuration)
    local weight = configuration.weight
    if weight ~= nil and type(weight) ~= "number" then
        return false, "weight must be a number"
    end

    return true
end

return this
