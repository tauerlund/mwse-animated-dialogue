---@class animationResolver : initializedService
local this = {}

---@private
---@type animationLoader
this.animationLoader = nil

---@private
---@type animationFilterer
this.animationFilterer = nil

---@private
---@type baseAnimationConfiguration
this.configuration = nil

---@public
---@param services serviceCollection
---@return boolean, string|nil
function this.initialize(services)
    this.animationLoader = services.animationLoader
    this.animationFilterer = services.animationFilterer
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
        return nil
    end

    return (table.choice(filtered))
end

return this
