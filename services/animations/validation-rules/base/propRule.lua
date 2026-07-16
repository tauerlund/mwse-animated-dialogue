---@class basePropValidationRule : animationValidationRule
local this = {}

---@private
---@type propDefinitionValidator
this.propDefinitionValidator = nil

---@public
---@param services serviceCollection
function this.initialize(services)
    this.propDefinitionValidator = services.propDefinitionValidator
end

---@public
---@param configuration baseAnimationConfiguration
---@return boolean, string|nil
function this.validate(configuration)
    local prop = configuration.prop
    if prop == nil then
        return true
    end

    local ok, reason = this.propDefinitionValidator.validate(prop)
    if not ok then
        return false, reason
    end

    if prop.despawnAfter ~= nil then
        return false, "prop.despawnAfter is not supported on base configurations"
    end

    return true
end

return this
