---@class dialogueIdsValidationRule : overrideValidationRule
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
---@param configuration overrideAnimationConfiguration
---@return boolean, string|nil
function this.validate(configuration)
    if not this.arrays.isNonEmptyStringArray(configuration.dialogueIds) then
        return false, "dialogueIds must be a non-empty array of strings"
    end

    return true
end

return this
