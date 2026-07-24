---@class animationFilterer : initializedService
local this = {}

---@private
---@type conditionFilterer
this.conditionFilterer = nil

---@private
---@type conditionFilteringRule[]
this.rules = nil

---@public
---@param services serviceCollection
---@return boolean,string|nil
function this.initialize(services)
    this.conditionFilterer = services.conditionFilterer
    this.rules = services.ruleLoader.loadRules("services\\animations\\filtering-rules")
    return true, nil
end

---@public
---@param services serviceCollection
---@return initializedService[]
function this.dependencies(services)
    return { services.ruleLoader, services.conditionFilterer }
end

---@public
---@param configurations animationConfiguration[]
---@param actor tes3reference
---@return animationConfiguration[]
function this.filter(configurations, actor)
    local filtered = this.conditionFilterer.filter(configurations, actor)

    return this.conditionFilterer.applyRules({
        configurations = filtered,
        actor = actor,
        rules = this.rules,
    })
end

return this
