---@class talkValidationRule : animationValidationRule
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
    local talk = configuration.talk
    if talk == nil then
        return true
    end

    if type(talk) ~= "table" then
        return false, "talk must be an array"
    end

    for index, definition in ipairs(talk) do
        local ok, reason = this.animationDefinitionValidator.validate(definition, string.format("talk[%d]", index))
        if not ok then
            return false, reason
        end
    end

    return true
end

return this
