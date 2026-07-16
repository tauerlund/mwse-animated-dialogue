---@class cameraPresetFieldValidator : service
local this = {}

---@public
---@param preset cameraPreset
---@param fields string[]
---@return boolean, string|nil
function this.validateNumbers(preset, fields)
    for i = 1, #fields do
        local field = fields[i]
        local value = preset[field]

        if value == nil then
            return false, string.format("%s is missing", field)
        end

        if type(value) ~= "number" then
            return false, string.format("%s must be a number", field)
        end
    end

    return true
end

return this
