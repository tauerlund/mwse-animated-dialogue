---@class animationResolver : initializedService
local this = {}

---@private
---@type animationLoader
this.animationLoader = nil

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
this.logger = mwse.Logger.new()

---@public
---@param services serviceCollection
---@return boolean, string|nil
function this.initialize(services)
    this.animationLoader = services.animationLoader
    this.animationFilterer = services.animationFilterer
    this.arrays = services.arrays
    return true, nil
end

---@public
---@param npc tes3reference
---@return baseAnimationConfiguration|nil
function this.resolve(npc)
    local configuration = this.resolveBaseConfiguration(npc)
    if not configuration or not configuration.idle then
        this.configuration = nil
        return nil
    end

    this.configuration = configuration

    return configuration
end

---@public
function this.reset()
    this.configuration = nil
end

---@private
---@param npc tes3reference
---@return baseAnimationConfiguration|nil
function this.resolveBaseConfiguration(npc)
    local configurations = this.animationLoader.getBaseConfigurations()

    local filtered = this.animationFilterer.filter(configurations, npc)
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
