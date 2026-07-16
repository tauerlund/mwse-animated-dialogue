---@class positionValidationRule : cameraPresetValidationRule
local this = {}

---@private
this.fields = { "verticalAnchor", "distance", "horizontalOffset", "verticalOffset" }

---@private
---@type cameraPresetFieldValidator
this.cameraPresetFieldValidator = nil

---@public
---@param services serviceCollection
function this.initialize(services)
    this.cameraPresetFieldValidator = services.cameraPresetFieldValidator
end

---@public
---@param preset cameraPreset
---@return boolean, string|nil
function this.validate(preset)
    local ok, reason = this.cameraPresetFieldValidator.validateNumbers(preset, this.fields)
    if not ok then
        return false, reason
    end

    if preset.verticalAnchor < 0 or preset.verticalAnchor > 1 then
        return false, "verticalAnchor must be between 0 and 1"
    end

    return true
end

return this
