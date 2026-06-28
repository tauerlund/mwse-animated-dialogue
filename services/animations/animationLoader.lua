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
---@type string[]
this.baseAnimationConfigurations = nil

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

    local validator = services.animationConfigurationValidator

    this.baseAnimationConfigurations = {}

    for _, file in ipairs(files) do
        local configuration = mwse.loadConfig(this.buildPath(file)) --[[@as baseAnimationConfiguration]]
        if validator.validate(configuration) then
            table.insert(this.baseAnimationConfigurations, configuration)
        end
    end

    if table.empty(this.baseAnimationConfigurations) then
        return false, "no valid base animation configurations found"
    end

    return true, nil
end

---@public
function this.uninitialize()
    this.baseAnimationConfigurations = nil
end

---@private
---@param file string
---@return string
function this.buildPath(file)
    return (string.format("%s\\%s", this.animationsBaseDirectory, file):gsub(this.fileTypes.json, ""))
end

return this
