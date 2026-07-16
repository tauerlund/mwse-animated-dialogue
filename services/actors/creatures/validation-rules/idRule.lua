---@class creatureIdValidationRule : creatureValidationRule
local this = {}

---@public
---@param configuration creatureAnimationConfiguration
---@return boolean, string|nil
function this.validate(configuration)
    local id = configuration.id
    if id == nil then
        return false, "id is missing"
    end

    if type(id) ~= "string" then
        return false, string.format("id must be a string, got '%s'", tostring(id))
    end

    if id == "" then
        return false, "id must not be empty"
    end

    return true
end

return this
