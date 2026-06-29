---@class animationFilterer : initializedService
local this = {}

---@private
---@type animationFilteringRule[]
this.rules = nil

---@public
---@param services serviceCollection
---@return boolean,string|nil
function this.initialize(services)
    this.rules = services.ruleLoader.loadRules("animations\\filtering-rules")
    return true, nil
end

---@public
---@param services serviceCollection
---@return initializedService[]
function this.dependencies(services)
    return { services.ruleLoader }
end

---@public
---@param configurations baseAnimationConfiguration[]
---@param npc tes3reference
---@return baseAnimationConfiguration[]
function this.filter(configurations, npc)
    ---@type baseAnimationConfiguration[]
    local filtered = {}

    for i = 1, #configurations do
        local configuration = configurations[i]
        if this.valid(configuration, npc) then
            filtered[#filtered + 1] = configuration
        end
    end

    return filtered
end

---@private
---@param configuration baseAnimationConfiguration
---@param npc tes3reference
---@return boolean
function this.valid(configuration, npc)
    for i = 1, #this.rules do
        local rule = this.rules[i]
        if not rule.isMet(configuration, npc) then
            return false
        end
    end

    return true
end

---@private
---@param values string[]
---@param value string
---@return boolean
function this.contains(values, value)
    for i = 1, #values do
        if values[i]:lower() == value:lower() then
            return true
        end
    end
    return false
end

return this
