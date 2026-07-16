---@class dialogueIdsValidationRule : overrideValidationRule
local this = {}

---@private
---@type values
this.values = nil

---@public
---@param services serviceCollection
function this.initialize(services)
    this.values = services.values
end

---@public
---@param configuration overrideAnimationConfiguration
---@return boolean, string|nil
function this.validate(configuration)
    if not this.values.isNonEmptyStringArray(configuration.dialogueIds) then
        return false, "dialogueIds must be a non-empty array of strings"
    end

    return true
end

return this
