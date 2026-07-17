---@class cameraPresetLoader : initializedService
local this = {}

---@private
this.basePath = "data files\\mwse\\config"

---@private
this.presetsPath = "animated-dialogue\\camera"

---@private
this.fileType = ".json"

---@private
---@type fileLoader
this.fileLoader = nil

---@private
---@type cameraPresetValidator
this.validator = nil

---@private
---@type { [string]: cameraPreset }
this.presets = {}

---@public
---@param services serviceCollection
---@return boolean, string|nil
function this.initialize(services)
    this.fileLoader = services.fileLoader
    this.validator = services.cameraPresetValidator
    this.presets = {}

    this.loadPresets()

    return true, nil
end

---@public
---@param services serviceCollection
---@return initializedService[]
function this.dependencies(services)
    return { services.cameraPresetValidator }
end

---@public
function this.uninitialize()
    this.presets = {}
end

---@public
---@param id string
---@return cameraPreset|nil
function this.getPreset(id)
    return this.presets[id]
end

---@public
---@return string[]
function this.getIds()
    local ids = {}
    for id in pairs(this.presets) do
        table.insert(ids, id)
    end

    table.sort(ids)
    return ids
end

---@public
---@param id string
---@return boolean
function this.hasPreset(id)
    return this.presets[id] ~= nil
end

---@public
---@param preset cameraPreset
function this.savePreset(preset)
    local data = table.copy(preset)
    data.id = nil

    mwse.saveConfig(string.format("%s\\%s", this.presetsPath, preset.id), data)
    this.presets[preset.id] = preset
end

---@public
---@param name string
---@return string
function this.createPreset(name)
    local preset = this.defaultPreset()
    preset.id = this.nextFreeId("preset")
    preset.name = name

    this.savePreset(preset)
    return preset.id
end

---@public
---@param sourceId string
---@param name string
---@return string|nil
function this.clonePreset(sourceId, name)
    local source = this.presets[sourceId]
    if not source then
        return nil
    end

    local preset = table.copy(source)
    preset.id = this.nextFreeId(sourceId)
    preset.name = name

    this.savePreset(preset)
    return preset.id
end

---@public
---@param id string
function this.deletePreset(id)
    os.remove(string.format("%s\\%s\\%s%s", this.basePath, this.presetsPath, id, this.fileType))
    this.presets[id] = nil
end

---@private
---@param base string
---@return string
function this.nextFreeId(base)
    local index = 1
    local candidate = string.format("%s-%d", base, index)

    while this.presets[candidate] do
        index = index + 1
        candidate = string.format("%s-%d", base, index)
    end

    return candidate
end

---@public
---@return cameraPreset
function this.defaultPreset()
    return {
        id = "",
        name = "",
        anchor = "actor",
        verticalAnchor = 1.0,
        distance = 90,
        horizontalOffset = 40,
        verticalOffset = -15,
        pitchOffset = -4,
        yawOffset = -19,
        rollOffset = 0,
        animationDuration = 1.5,
    }
end

---@private
function this.loadPresets()
    local files = this.fileLoader.loadAll({
        directory = string.format("%s\\%s", this.basePath, this.presetsPath),
        fileType = this.fileType,
        requireNotEmpty = true
    })

    if not files then
        return
    end

    for _, file in ipairs(files) do
        local id = this.removeExtension(file)
        local preset = mwse.loadConfig(string.format("%s\\%s", this.presetsPath, id)) --[[@as cameraPreset]]

        if this.validator.validatePreset(preset, id) then
            preset.id = id
            this.presets[id] = preset
        end
    end
end

---@private
---@param file string
---@return string
function this.removeExtension(file)
    return (file:gsub("%.json$", ""))
end

return this
