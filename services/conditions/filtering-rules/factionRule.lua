---@class factionFilteringRule : conditionFilteringRule
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
    local factions = configuration.conditions and configuration.conditions.faction
    if not factions then
        return true
    end

    if actor.baseObject.objectType ~= tes3.objectType.npc then
        return false
    end

    local faction = actor.baseObject.faction
    if not faction then
        return false
    end

    return this.values.contains(factions, faction.id)
end

return this
