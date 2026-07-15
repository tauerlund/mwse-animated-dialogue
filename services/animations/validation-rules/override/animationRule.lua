---@class animationOverrideValidationRule : overrideValidationRule
local this = {}

---@private
---@type animationDefinitionValidator
this.animationDefinitionValidator = nil

---@public
---@param services serviceCollection
function this.initialize(services)
    this.animationDefinitionValidator = services.animationDefinitionValidator
end

---@public
---@param configuration overrideAnimationConfiguration
---@return boolean, string|nil
function this.validate(configuration)
    return this.animationDefinitionValidator.validate(configuration.animation, "animation")
end

return this
