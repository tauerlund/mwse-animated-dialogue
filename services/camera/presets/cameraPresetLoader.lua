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
---@type { [string]: cameraPreset }
this.presets = {}

---@public
---@param services serviceCollection
---@return boolean, string|nil
function this.initialize(services)
    this.fileLoader = services.fileLoader
    this.presets = {}

    this.loadPresets()

    return true, nil
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

---@private
function this.loadPresets()
    local files = this.fileLoader.loadAll({
        directory = string.format("%s\\%s", this.basePath, this.presetsPath),
        fileType = this.fileType
    })

    if not files then
        return
    end

    for _, file in ipairs(files) do
        local id = this.removeExtension(file)
        local preset = mwse.loadConfig(string.format("%s\\%s", this.presetsPath, id)) --[[@as cameraPreset]]
        if preset then
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
