---@class animationResolver : initializedService
local this = {}

---@private
---@type animationFilterer
this.animationFilterer = nil

---@private
---@type arrays
this.arrays = nil

---@private
---@type baseAnimationConfiguration
this.configuration = nil

---@private
---@type baseAnimationConfiguration[]
this.baseConfigurations = nil

---@private
---@type { [string]: talkAnimationConfiguration }
this.talkConfigurations = nil

---@private
this.logger = mwse.Logger.new()

---@public
---@param services serviceCollection
---@return boolean, string|nil
function this.initialize(services)
    this.animationFilterer = services.animationFilterer
    this.arrays = services.arrays

    local animationLoader = services.animationLoader

    this.baseConfigurations = animationLoader.getBaseConfigurations()
    this.talkConfigurations = animationLoader.getTalkConfigurations()

    return true, nil
end

---@public
---@param services serviceCollection
---@return initializedService[]
function this.dependencies(services)
    return { services.animationLoader }
end

---@public
---@param npc tes3reference
---@return baseAnimationConfiguration|nil
function this.resolve(npc)
    local configuration = this.resolveBaseConfiguration(npc)
    if not configuration or not configuration.idle then
        return nil
    end

    return configuration
end

---@public
---@param dialogueId string
---@return talkAnimationConfiguration|nil
function this.tryResolve(dialogueId)
    return this.talkConfigurations[dialogueId]
end

---@private
---@param npc tes3reference
---@return baseAnimationConfiguration|nil
function this.resolveBaseConfiguration(npc)
    local filtered = this.animationFilterer.filter(this.baseConfigurations, npc)
    if #filtered == 0 then
        this.logger:error("Could not resolve base animation")
        return nil
    end

    return this.arrays.weightedChoice(filtered, this.resolveWeight)
end

---@private
---@param configuration baseAnimationConfiguration
---@return number
function this.resolveWeight(configuration)
    return configuration.weight or 1
end

return this
