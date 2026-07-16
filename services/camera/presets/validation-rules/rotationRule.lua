---@class rotationValidationRule : cameraPresetValidationRule
local this = {}

---@private
this.fields = { "pitchOffset", "yawOffset", "rollOffset" }

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
    return this.cameraPresetFieldValidator.validateNumbers(preset, this.fields)
end

return this
