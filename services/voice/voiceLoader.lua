---@class voiceLoader : initializedService
local this = {}

---@private
this.logger = mwse.Logger.new()

---@private
this.basePath = "data files\\mwse\\config"

---@private
this.voicesPath = "animated-dialogue\\voices"

---@private
this.fileType = ".json"

---@private
---@type fileLoader
this.fileLoader = nil

---@private
---@type voiceValidator
this.validator = nil

---@private
---@type soundPlayer
this.soundPlayer = nil

---@private
---@type events
this.events = nil

---@private
---@type voiceConfiguration[]
this.configurations = {}

---@public
---@param services serviceCollection
---@return boolean, string|nil
function this.initialize(services)
    this.fileLoader = services.fileLoader
    this.validator = services.voiceValidator
    this.soundPlayer = services.soundPlayer
    this.events = services.constants.events

    this.loadConfigurations()

    return true, nil
end

---@public
---@param services serviceCollection
---@return initializedService[]
function this.dependencies(services)
    return { services.voiceValidator }
end

---@public
function this.uninitialize()
    this.configurations = {}
end

---@public
---@return voiceConfiguration[]
function this.getConfigurations()
    return this.configurations
end

---@private
function this.loadConfigurations()
    local files = this.fileLoader.loadAll({
        directory = string.format("%s\\%s", this.basePath, this.voicesPath),
        fileType = this.fileType,
        requireNotEmpty = false
    })

    if not files then
        return
    end

    for _, file in ipairs(files) do
        local path = string.format("%s\\%s", this.voicesPath, this.removeExtension(file))
        local configurations = mwse.loadConfig(path) --[[@as voiceConfigurationFile]]

        if this.validator.validateFile(configurations, file) then
            this.registerConfigurations(configurations, file)
        end
    end
end

---@private
---@param configurations voiceConfigurationFile
---@param file string
function this.registerConfigurations(configurations, file)
    for _, configuration in ipairs(configurations) do
        if this.validator.validateConfiguration(configuration, file) then
            this.registerConfiguration(configuration, file)
        end
    end
end

---@private
---@param configuration voiceConfiguration
---@param file string
function this.registerConfiguration(configuration, file)
    configuration.sounds = this.resolveExistingSounds(configuration.sounds, file)

    if #configuration.sounds == 0 then
        this.logger:warn("Skipping voice entry in '%s'; none of its sounds exist", file)
        event.trigger(this.events.validationFailed)
        return
    end

    configuration.source = file
    table.insert(this.configurations, configuration)
end

---@private
---@param sounds string[]
---@param file string
---@return string[]
function this.resolveExistingSounds(sounds, file)
    local existing = {}

    for _, sound in ipairs(sounds) do
        if this.soundPlayer.exists(sound) then
            table.insert(existing, sound)
        else
            this.logger:warn("Dropping sound '%s' in '%s'; the file does not exist", sound, file)
            event.trigger(this.events.validationFailed)
        end
    end

    return existing
end

---@private
---@param file string
---@return string
function this.removeExtension(file)
    return (file:gsub("%.json$", ""))
end

return this
