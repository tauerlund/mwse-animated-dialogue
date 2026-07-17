---@class greetingValidationRule : animationValidationRule
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
    local greeting = configuration.greeting
    if greeting == nil then
        return true
    end

    if type(greeting) ~= "table" then
        return false, "greeting must be an array"
    end

    if #greeting == 0 then
        return false, "greeting must not be an empty array"
    end

    for index, definition in ipairs(greeting) do
        local ok, reason = this.animationDefinitionValidator.validate(definition, string.format("greeting[%d]", index))
        if not ok then
            return false, reason
        end
    end

    return true
end

return this
