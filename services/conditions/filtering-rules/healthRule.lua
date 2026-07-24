---@class healthFilteringRule : conditionFilteringRule
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
    local health = configuration.conditions and configuration.conditions.health
    if not health then
        return true
    end

    local mobile = actor.mobile --[[@as tes3mobileActor]]
    if not mobile then
        return false
    end

    return this.values.withinRange(health, mobile.health.normalized)
end

return this
