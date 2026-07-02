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
---@return baseAnimationConfiguration[]
function this.getBaseConfigurations()
    return this.baseAnimationConfigurations
end

---@public
---@return { [string]: overrideAnimationConfiguration}
function this.getOverrideConfigurations()
    return this.overrideAnimationConfigurations
end

---@public
function this.uninitialize()
    this.baseAnimationConfigurations = {}
    this.overrideAnimationConfigurations = {}
end

---@private
function this.loadBaseConfigurations()
    local files = this.fileLoader.loadAll({
        directory = string.format("%s\\%s", this.basePath, this.baseAnimationsPath),
        fileType = this.fileTypes.json
    })

    if not files then
        return
    end

    for _, file in ipairs(files) do
        local id = this.removeExtension(file)
        local path = string.format("%s\\%s", this.baseAnimationsPath, id)
        local configuration = mwse.loadConfig(path) --[[@as baseAnimationConfiguration]]
        if this.validator.validate(configuration) then
            configuration.id = id
            table.insert(this.baseAnimationConfigurations, configuration)
        end
    end
end

---@private
function this.loadOverrideConfigurations()
    local files = this.fileLoader.loadAll({
        directory = string.format("%s\\%s", this.basePath, this.overrideAnimationsPath),
        fileType = this.fileTypes.json
    })

    if not files then
        return
    end

    for _, file in ipairs(files) do
        local id = this.removeExtension(file)
        local path = string.format("%s\\%s", this.overrideAnimationsPath, id)
        local configurations = mwse.loadConfig(path) --[[@as overrideAnimationConfigurationFile]]
        for _, configuration in ipairs(configurations) do
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
---@param file string
---@return string
function this.removeExtension(file)
    return (file:gsub(this.fileTypes.json, ""))
end

return this
