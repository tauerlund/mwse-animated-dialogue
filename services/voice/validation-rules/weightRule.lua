---@class voiceWeightValidationRule : voiceValidationRule
local this = {}

---@public
---@param configuration voiceConfiguration
---@return boolean, string|nil
function this.validate(configuration)
    if configuration.weight ~= nil and type(configuration.weight) ~= "number" then
        return false, "weight must be a number"
    end

    return true
end

return this
