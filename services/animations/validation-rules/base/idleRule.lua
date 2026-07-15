---@class idleValidationRule : animationValidationRule
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
---@param configuration baseAnimationConfiguration
---@return boolean, string|nil
function this.validate(configuration)
    return this.animationDefinitionValidator.validate(configuration.idle, "idle")
end

return this
