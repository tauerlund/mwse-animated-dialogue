---@class overrideConditionsValidationRule : overrideValidationRule
local this = {}

---@private
---@type animationConditionsValidator
this.animationConditionsValidator = nil

---@public
---@param services serviceCollection
function this.initialize(services)
    this.animationConditionsValidator = services.animationConditionsValidator
end

---@public
---@param configuration overrideAnimationConfiguration
---@return boolean, string|nil
function this.validate(configuration)
    return this.animationConditionsValidator.validate(configuration.conditions)
end

return this
