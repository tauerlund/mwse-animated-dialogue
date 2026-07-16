---@class variationsValidationRule : animationValidationRule
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
    local variations = configuration.variations
    if variations == nil then
        return true
    end

    if type(variations) ~= "table" then
        return false, "variations must be an array"
    end

    for index, definition in ipairs(variations) do
        local ok, reason = this.animationDefinitionValidator.validate(definition, string.format("variations[%d]", index))
        if not ok then
            return false, reason
        end
    end

    return true
end

return this
