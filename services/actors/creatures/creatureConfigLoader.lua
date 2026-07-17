--- Loads per-creature idle overrides (baseObject id -> animation group name)
--- from JSON under MWSE/config/animated-dialogue/creatures. Mirrors
--- animationLoader's loading of the animation configs.
---@class creatureConfigLoader : initializedService
local this = {}

---@private
this.logger = mwse.Logger.new()

---@private
this.basePath = "data files\\mwse\\config"

---@private
this.creaturesPath = "animated-dialogue\\animations\\creatures"

---@private
this.fileType = ".json"

---@private
---@type fileLoader
this.fileLoader = nil

---@private
---@type creatureConfigValidator
this.validator = nil

---@private
---@type { [string]: string } baseObject id -> tes3.animationGroup key name
this.configurations = {}

---@public
---@param services serviceCollection
---@return boolean, string|nil
function this.initialize(services)
    this.fileLoader = services.fileLoader
    this.validator = services.creatureConfigValidator

    this.loadConfigurations()

    return true, nil
end

---@public
---@param services serviceCollection
---@return initializedService[]
function this.dependencies(services)
    return { services.creatureConfigValidator }
end

---@public
function this.uninitialize()
    this.configurations = {}
end

---@public
---@return { [string]: string }
function this.getConfigurations()
    return this.configurations
end

---@private
function this.loadConfigurations()
    local files = this.fileLoader.loadAll({
        directory = string.format("%s\\%s", this.basePath, this.creaturesPath),
        fileType = this.fileType,
        requireNotEmpty = false
    })

    if not files then
        return
    end

    for _, file in ipairs(files) do
        local id = (file:gsub("%.json$", ""))
        local path = string.format("%s\\%s", this.creaturesPath, id)
        local configurations = mwse.loadConfig(path) --[[@as creatureAnimationConfiguration[] ]]

        if this.validator.validateFile(configurations, file) then
            this.registerConfigurations(configurations, file)
        end
    end
end

---@private
---@param configurations creatureAnimationConfiguration[]
---@param file string
function this.registerConfigurations(configurations, file)
    for _, configuration in ipairs(configurations) do
        if this.validator.validateConfiguration(configuration, file) then
            this.registerConfiguration(configuration)
        end
    end
end

---@private
---@param configuration creatureAnimationConfiguration
function this.registerConfiguration(configuration)
    if this.configurations[configuration.id] then
        this.logger:warn("Duplicate creature config for '%s'; overwriting", configuration.id)
    end

    this.configurations[configuration.id] = configuration.group
end

return this
