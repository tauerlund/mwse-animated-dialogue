---@class animationLoader : initializedService
local this = {}

---@private
this.basePath = "data files\\mwse\\config"

---@private
this.animationsBaseDirectory = "animated-dialogue\\animations\\base"

---@private
this.animationsDialogueDirectory = ""

---@private
---@enum fileType
this.fileTypes = {
    json = ".json"
}

---@private
---@type baseAnimationConfiguration[]
this.baseAnimationConfigurations = {}

---@public
---@param services serviceCollection
---@return boolean, string|nil
function this.initialize(services)
    local files = services.fileLoader.loadAll({
        directory = string.format("%s\\%s", this.basePath, this.animationsBaseDirectory),
        fileType = this.fileTypes.json
    })

    if not files then
        return false, "base animation configurations could not be loaded"
    end

    local validator = services.animationValidator

    for _, file in ipairs(files) do
        local id = this.removeExtension(file)
        local configuration = mwse.loadConfig(this.buildPath(id)) --[[@as baseAnimationConfiguration]]
        if validator.validate(configuration) then
            configuration.id = id
            table.insert(this.baseAnimationConfigurations, configuration)
        end
    end

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
function this.uninitialize()
    this.baseAnimationConfigurations = {}
end

---@private
---@param file string
---@return string
function this.buildPath(file)
    return (string.format("%s\\%s", this.animationsBaseDirectory, file):gsub(this.fileTypes.json, ""))
end

---@private
---@param file string
---@return string
function this.removeExtension(file)
    return (file:gsub(this.fileTypes.json, ""))
end

return this
