---@class fatigueFilteringRule : conditionFilteringRule
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
    local fatigue = configuration.conditions and configuration.conditions.fatigue
    if not fatigue then
        return true
    end

    local mobile = actor.mobile --[[@as tes3mobileActor]]
    if not mobile then
        return false
    end

    return this.values.withinRange(fatigue, mobile.fatigue.normalized)
end

return this
