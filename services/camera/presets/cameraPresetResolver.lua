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

---@public
---@param services serviceCollection
---@return boolean, string|nil
function this.initialize(services)
    this.settings = services.settings
    this.cameraPresetLoader = services.cameraPresetLoader

    return true, nil
end

---@public
---@param services serviceCollection
---@return initializedService[]
function this.dependencies(services)
    return { services.cameraPresetLoader }
end

---@public
---@return cameraPreset|nil
function this.resolve()
    local id = this.resolveId()

    local preset = this.cameraPresetLoader.getPreset(id)
    if preset then
        return preset
    end

    this.logger:warn("Camera preset '%s' not found; camera animation disabled for this dialogue", id)
    return nil
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
