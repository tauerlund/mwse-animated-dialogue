---@class animationDefinitionValidator : service
local this = {}

---@public
---@param definition any
---@param label string
---@return boolean, string|nil
function this.validate(definition, label)
    if type(definition) ~= "table" then
        return false, string.format("%s must be a table", label)
    end

    if type(definition.file) ~= "string" or definition.file == "" then
        return false, string.format("%s.file must be a non-empty string", label)
    end

    if type(definition.group) ~= "string" or definition.group == "" then
        return false, string.format("%s.group must be a non-empty string", label)
    end

    if definition.overrideLookAt ~= nil and type(definition.overrideLookAt) ~= "boolean" then
        return false, string.format("%s.overrideLookAt must be a boolean", label)
    end

    return true
end

return this
