---@class timingValidationRule : cameraPresetValidationRule
local this = {}

---@private
this.fields = { "animationDuration" }

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

    if preset.animationDuration < 0 then
        return false, "animationDuration must not be negative"
    end

    return true
end

return this
