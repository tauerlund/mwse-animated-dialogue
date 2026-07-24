---@class voiceConditionsValidationRule : voiceValidationRule
local this = {}

---@private
---@type conditionsValidator
this.conditionsValidator = nil

---@public
---@param services serviceCollection
function this.initialize(services)
    this.conditionsValidator = services.conditionsValidator
end

---@public
---@param configuration voiceConfiguration
---@return boolean, string|nil
function this.validate(configuration)
    local valid, reason = this.conditionsValidator.validate(configuration.conditions)
    if not valid then
        return false, reason
    end

    return this.validateInapplicable(configuration.conditions)
end

---@private
---@param conditions conditions|nil
---@return boolean, string|nil
function this.validateInapplicable(conditions)
    if conditions == nil then
        return true
    end

    if conditions.beast ~= nil then
        return false, "conditions.beast has no effect on voice lines"
    end

    if conditions.weaponReadied ~= nil then
        return false, "conditions.weaponReadied has no effect on voice lines"
    end

    return true
end

return this
