---@class cameraPresetResolver : initializedService
local this = {}

---@private
this.logger = mwse.Logger.new()

---@private
---@type settings
this.settings = nil

---@private
---@type cameraPresetLoader
this.cameraPresetLoader = nil

---@private
---@type cameraPreset
this.fallbackPreset = nil

---@public
---@param services serviceCollection
---@return boolean, string|nil
function this.initialize(services)
    this.settings = services.settings
    this.cameraPresetLoader = services.cameraPresetLoader

    this.fallbackPreset = this.cameraPresetLoader.defaultPreset()
    this.fallbackPreset.id = "fallback"
    this.fallbackPreset.name = "Fallback"

    return true, nil
end

---@public
---@param services serviceCollection
---@return initializedService[]
function this.dependencies(services)
    return { services.cameraPresetLoader }
end

---@public
---@return cameraPreset
function this.resolve()
    local id = this.resolveId()

    local preset = this.cameraPresetLoader.getPreset(id)
    if preset then
        return preset
    end

    this.logger:warn("Camera preset '%s' not found; falling back to '%s'", id, this.fallbackPreset.id)
    return this.fallbackPreset
end

---@private
---@return string
function this.resolveId()
    local settings = this.settings
    if tes3.is3rdPerson() then
        return settings.cameraPresetThirdPerson
    end

    return settings.cameraPresetFirstPerson
end

return this
