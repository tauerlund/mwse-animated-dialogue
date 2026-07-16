---@class raceFilteringRule : animationFilteringRule
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
---@param configuration baseAnimationConfiguration
---@param actor tes3reference
---@return boolean
function this.isMet(configuration, actor)
    local races = configuration.conditions and configuration.conditions.race
    if not races then
        return true
    end

    return this.values.contains(races, actor.baseObject.race.id)
end

return this
