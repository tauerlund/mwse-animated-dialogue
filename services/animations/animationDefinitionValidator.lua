---@class animationDefinitionValidator : initializedService
local this = {}

---@private
---@type nifLoader
this.nifLoader = nil

---@public
---@param services serviceCollection
---@return boolean, string|nil
function this.initialize(services)
    this.nifLoader = services.nifLoader

    return true, nil
end

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

    if not this.nifLoader.exists(definition.file) then
        return false, string.format("%s.file '%s' does not exist", label, definition.file)
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
