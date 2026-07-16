---@class nameValidationRule : cameraPresetValidationRule
local this = {}

---@public
---@param preset cameraPreset
---@return boolean, string|nil
function this.validate(preset)
    if preset.name == nil then
        return false, "name is missing"
    end

    if type(preset.name) ~= "string" then
        return false, "name must be a string"
    end

    return true
end

return this
