---@class anchorValidationRule : cameraPresetValidationRule
local this = {}

---@private
---@type cameraAnchor
this.cameraAnchors = nil

---@public
---@param services serviceCollection
function this.initialize(services)
    this.cameraAnchors = services.constants.cameraAnchors
end

---@public
---@param preset cameraPreset
---@return boolean, string|nil
function this.validate(preset)
    if preset.anchor == nil then
        return false, "anchor is missing"
    end

    if this.cameraAnchors[preset.anchor] == nil then
        return false,
            string.format(
                "anchor '%s' is invalid (allowed values: %s)",
                tostring(preset.anchor),
                table.concat(table.values(this.cameraAnchors, true), ", "))
    end

    return true
end

return this
