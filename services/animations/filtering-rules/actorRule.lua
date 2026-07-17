---@class actorFilteringRule : animationFilteringRule
local this = {}

---@private
---@type values
this.values = nil

---@public
---@param services serviceCollection
function this.initialize(services)
    this.values = services.values
end

---@public
---@param configuration animationConfiguration
---@param actor tes3reference
---@return boolean
function this.isMet(configuration, actor)
    local actorIds = configuration.conditions and configuration.conditions.actor
    if not actorIds then
        return true
    end

    return this.values.contains(actorIds, actor.baseObject.id)
end

return this
