---@class animationLoader : initializedService
local this = {}

---@private
this.logger = mwse.Logger.new()

---@private
this.basePath = "data files\\mwse\\config"

---@private
---@enum fileType
this.fileTypes = {
    json = ".json"
}

---@private
this.baseAnimationsPath = "animated-dialogue\\animations\\base"

---@private
this.overrideAnimationsPath = "animated-dialogue\\animations\\override"

---@private
---@type baseAnimationConfiguration[]
this.baseAnimationConfigurations = {}

---@private
---@type { [string]: overrideAnimationConfiguration }
this.overrideAnimationConfigurations = {}

---@private
---@type { [string]: overrideAnimationConfigurationFile }
this.overrideAnimationFiles = {}

---@public
---@param services serviceCollection
---@return boolean, string|nil
function this.initialize(services)
    this.fileLoader = services.fileLoader
    this.validator = services.animationValidator

    this.loadBaseConfigurations()
    this.loadOverrideConfigurations()

    if table.empty(this.baseAnimationConfigurations) then
        return false, "no valid base animation configurations found"
    end

    return true, nil
end

---@public
---@param services serviceCollection
---@return initializedService[]
function this.dependencies(services)
    return { services.animationValidator }
end

---@public
---@return baseAnimationConfiguration[]
function this.getBaseConfigurations()
    return this.baseAnimationConfigurations
end

---@public
---@param id string
---@return baseAnimationConfiguration|nil
function this.getBaseConfiguration(id)
    for _, configuration in ipairs(this.baseAnimationConfigurations) do
        if configuration.id == id then
            return configuration
        end
    end

    return nil
end

---@public
---@return { [string]: overrideAnimationConfiguration}
function this.getOverrideConfigurations()
    return this.overrideAnimationConfigurations
end

---@public
---@param configuration baseAnimationConfiguration
---@return boolean
function this.saveBaseConfiguration(configuration)
    local id = configuration.id

    if not id or id == "" then
        this.logger:error("Cannot save base animation configuration; missing id")
        return false
    end

    local path = string.format("%s\\%s", this.baseAnimationsPath, id)
    mwse.saveConfig(path, this.removeId(configuration))

    return true
end

---@public
---@param configuration overrideAnimationConfiguration
---@return boolean
function this.saveOverrideConfiguration(configuration)
    local source = configuration.source --[[@as string]]
    local configurations = source and this.overrideAnimationFiles[source]

    if not configurations then
        this.logger:error("Cannot save override configuration; unknown source file '%s'", source)
        return false
    end

    local path = string.format("%s\\%s", this.overrideAnimationsPath, this.removeExtension(source))
    mwse.saveConfig(path, this.removeSourceFilenames(configurations))

    return true
end

---@public
function this.uninitialize()
    this.baseAnimationConfigurations = {}
    this.overrideAnimationConfigurations = {}
    this.overrideAnimationFiles = {}
end

---@private
function this.loadBaseConfigurations()
    local files = this.fileLoader.loadAll({
        directory = string.format("%s\\%s", this.basePath, this.baseAnimationsPath),
        fileType = this.fileTypes.json,
        requireNotEmpty = true
    })

    if not files then
        return
    end

    for _, file in ipairs(files) do
        local id = this.removeExtension(file)
        local path = string.format("%s\\%s", this.baseAnimationsPath, id)
        local configuration = mwse.loadConfig(path) --[[@as baseAnimationConfiguration]]

        if this.validator.validateBaseConfiguration(configuration, id) then
            configuration.id = id
            table.insert(this.baseAnimationConfigurations, configuration)
        end
    end
end

---@private
function this.loadOverrideConfigurations()
    local files = this.fileLoader.loadAll({
        directory = string.format("%s\\%s", this.basePath, this.overrideAnimationsPath),
        fileType = this.fileTypes.json,
        requireNotEmpty = false
    })

    if not files then
        return
    end

    for _, file in ipairs(files) do
        local id = this.removeExtension(file)
        local path = string.format("%s\\%s", this.overrideAnimationsPath, id)
        local configurations = mwse.loadConfig(path) --[[@as overrideAnimationConfigurationFile]]

        if this.validator.validateOverrideFile(configurations, file) then
            this.overrideAnimationFiles[file] = configurations
            this.registerOverrideConfigurations(file, configurations)
        end
    end
end

---@private
---@param file string
---@param configurations overrideAnimationConfigurationFile
function this.registerOverrideConfigurations(file, configurations)
    for _, configuration in ipairs(configurations) do
        if this.validator.validateOverrideConfiguration(configuration, file) then
            configuration.source = file
            for _, dialogueId in ipairs(configuration.dialogueIds) do
                if this.overrideAnimationConfigurations[dialogueId] then
                    this.logger:warn("Duplicate override for dialogueId '%s'; overwriting previous entry", dialogueId)
                end

                this.overrideAnimationConfigurations[dialogueId] = configuration
            end
        end
    end
end

---@private
---@param configuration baseAnimationConfiguration
---@return baseAnimationConfiguration
function this.removeId(configuration)
    local copy = table.copy(configuration)
    copy.id = nil

    return copy
end

---@private
---@param configurations overrideAnimationConfigurationFile
---@return overrideAnimationConfigurationFile
function this.removeSourceFilenames(configurations)
    local copies = {}

    for _, configuration in ipairs(configurations) do
        local copy = table.copy(configuration)
        copy.source = nil
        table.insert(copies, copy)
    end

    return copies
end

---@private
---@param file string
---@return string
function this.removeExtension(file)
    return (file:gsub("%.json$", ""))
end

return this
