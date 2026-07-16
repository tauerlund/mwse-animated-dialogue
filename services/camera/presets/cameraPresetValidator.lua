---@class cameraPresetValidator : initializedService
local this = {}

---@private
---@type cameraPresetValidationRule[]
this.rules = nil

---@private
this.logger = mwse.Logger.new()

---@public
---@param services serviceCollection
---@return boolean,string|nil
function this.initialize(services)
    this.rules = services.ruleLoader.loadRules("services\\camera\\presets\\validation-rules")

    return true, nil
end

---@public
---@param services serviceCollection
---@return initializedService[]
function this.dependencies(services)
    return { services.ruleLoader }
end

---@public
---@param preset cameraPreset
---@param id string
---@return boolean
function this.validatePreset(preset, id)
    local ok, reason = this.applyRules(preset)
    if not ok then
        this.logger:warn("Skipping camera preset '%s': %s", id, reason)
        return false
    end

    return true
end

---@private
---@param preset any
---@return boolean, string|nil
function this.applyRules(preset)
    if type(preset) ~= "table" then
        return false, "missing or malformed"
    end

    for i = 1, #this.rules do
        local ok, reason = this.rules[i].validate(preset)
        if not ok then
            return false, reason
        end
    end

    return true
end

return this
