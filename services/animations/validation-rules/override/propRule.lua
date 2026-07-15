---@class propValidationRule : overrideValidationRule
local this = {}

---@private
---@param value any
---@param label string
---@return boolean, string|nil
function this.validateVectorFields(value, label)
    if type(value) ~= "table" then
        return false, string.format("%s must be a table", label)
    end

    if value.x ~= nil and type(value.x) ~= "number" then
        return false, string.format("%s.x must be a number", label)
    end

    if value.y ~= nil and type(value.y) ~= "number" then
        return false, string.format("%s.y must be a number", label)
    end

    if value.z ~= nil and type(value.z) ~= "number" then
        return false, string.format("%s.z must be a number", label)
    end

    return true
end

---@private
---@param transform any
---@return boolean, string|nil
function this.validateTransform(transform)
    if transform == nil then
        return true
    end

    if type(transform) ~= "table" then
        return false, "prop.transform must be a table"
    end

    if transform.translation ~= nil then
        local ok, reason = this.validateVectorFields(transform.translation, "prop.transform.translation")
        if not ok then
            return false, reason
        end
    end

    if transform.rotation ~= nil then
        local ok, reason = this.validateVectorFields(transform.rotation, "prop.transform.rotation")
        if not ok then
            return false, reason
        end
    end

    if transform.scale ~= nil and type(transform.scale) ~= "number" then
        return false, "prop.transform.scale must be a number"
    end

    return true
end

---@public
---@param configuration overrideAnimationConfiguration
---@return boolean, string|nil
function this.validate(configuration)
    local prop = configuration.prop
    if prop == nil then
        return true
    end

    if type(prop) ~= "table" then
        return false, "prop must be a table"
    end

    if type(prop.file) ~= "string" or prop.file == "" then
        return false, "prop.file must be a non-empty string"
    end

    if type(prop.attachTo) ~= "string" or prop.attachTo == "" then
        return false, "prop.attachTo must be a non-empty string"
    end

    if prop.spawnAfter ~= nil and type(prop.spawnAfter) ~= "number" then
        return false, "prop.spawnAfter must be a number"
    end

    if prop.despawnAfter ~= nil and type(prop.despawnAfter) ~= "number" then
        return false, "prop.despawnAfter must be a number"
    end

    return this.validateTransform(prop.transform)
end

return this
