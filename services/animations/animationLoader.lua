---@class animationLoader : initializedService
local this = {}

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
this.talkAnimationsPath = "animated-dialogue\\animations\\talk"

---@private
---@type baseAnimationConfiguration[]
this.baseAnimationConfigurations = {}

---@private
---@type { [string]: talkAnimationConfiguration }
this.talkAnimationConfigurations = {}

---@public
---@param services serviceCollection
---@return boolean, string|nil
function this.initialize(services)
    this.fileLoader = services.fileLoader
    this.validator = services.animationValidator

    this.loadBaseConfigurations()
    this.loadTalkConfigurations()

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
---@return { [string]: talkAnimationConfiguration}
function this.getTalkConfigurations()
    return this.talkAnimationConfigurations
end

---@public
function this.uninitialize()
    this.baseAnimationConfigurations = {}
    this.talkAnimationConfigurations = {}
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
function this.loadTalkConfigurations()
    local files = this.fileLoader.loadAll({
        directory = string.format("%s\\%s", this.basePath, this.talkAnimationsPath),
        fileType = this.fileTypes.json
    })

    if not files then
        return
    end

    for _, file in ipairs(files) do
        local id = this.removeExtension(file)
        local path = string.format("%s\\%s", this.talkAnimationsPath, id)
        local configuration = mwse.loadConfig(path) --[[@as talkAnimationConfiguration]]
        this.talkAnimationConfigurations[configuration.dialogueId] = configuration
    end
end

---@private
---@param file string
---@return string
function this.removeExtension(file)
    return (file:gsub(this.fileTypes.json, ""))
end

return this
