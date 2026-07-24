---@class factionRankFilteringRule : conditionFilteringRule
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
---@param configuration filterableConfiguration
---@param actor tes3reference
---@return boolean
function this.isMet(configuration, actor)
    local rank = configuration.conditions and configuration.conditions.factionRank
    if not rank then
        return true
    end

    if actor.baseObject.objectType ~= tes3.objectType.npc then
        return false
    end

    if not actor.baseObject.faction then
        return false
    end

    return this.values.withinRange(rank, actor.baseObject.factionRank)
end

return this
