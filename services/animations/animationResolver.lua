---@class animationResolver : initializedService
local this = {}

---@private
---@type animationLoader
this.animationLoader = nil

---@private
---@type baseAnimationConfiguration
this.configuration = nil

---@public
---@param services serviceCollection
---@return boolean, string|nil
function this.initialize(services)
    this.animationLoader = services.animationLoader
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
---@return animationDefinition|nil
function this.resolveTalk()
    local talk = this.configuration and this.configuration.talk
    if not talk then
        return nil
    end

    return (table.choice(talk))
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
    return configurations and configurations[1]
end

return this
