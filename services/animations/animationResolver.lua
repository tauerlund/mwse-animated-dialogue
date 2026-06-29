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

-- Resolve the base (idle) animation for the NPC's context, remembering the chosen configuration
-- so talk animations for the rest of the dialogue are drawn from the same one.
---@public
---@param npc tes3reference
---@return animationDefinition|nil
function this.resolveIdle(npc)
    local configuration = this.resolveBaseConfiguration(npc)
    if not configuration or not configuration.idle then
        this.configuration = nil
        return nil
    end

    this.configuration = configuration
    return configuration.idle
end

-- Pick a talk animation from the configuration resolved for the current dialogue, if any.
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

-- THE SEAM for the future context-driven selection pattern; currently returns the first config.
---@private
---@param npc tes3reference
---@return baseAnimationConfiguration|nil
function this.resolveBaseConfiguration(npc)
    local configurations = this.animationLoader.getBaseConfigurations()
    return configurations and configurations[1]
end

return this
