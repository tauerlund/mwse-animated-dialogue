---@class conditionFilterer : initializedService
local this = {}

---@private
---@type conditionFilteringRule[]
this.rules = nil

---@private
this.logger = mwse.Logger.new()

---@public
---@param services serviceCollection
---@return boolean,string|nil
function this.initialize(services)
    this.rules = services.ruleLoader.loadRules("services\\conditions\\filtering-rules")
    return true, nil
end

---@public
---@param services serviceCollection
---@return initializedService[]
function this.dependencies(services)
    return { services.ruleLoader }
end

---@public
---@param configurations filterableConfiguration[]
---@param actor tes3reference
---@return filterableConfiguration[]
function this.filter(configurations, actor)
    return this.applyRules({
        configurations = configurations,
        actor = actor,
        rules = this.rules,
    })
end

---@public
---@param params conditionFilterer.applyRules.param
---@return filterableConfiguration[]
function this.applyRules(params)
    local configurations = params.configurations

    ---@type filterableConfiguration[]
    local filtered = {}

    for i = 1, #configurations do
        local configuration = configurations[i]
        if this.valid(configuration, params.actor, params.rules) then
            filtered[#filtered + 1] = configuration
        end
    end

    return filtered
end

---@private
---@param configuration filterableConfiguration
---@param actor tes3reference
---@param rules conditionFilteringRule[]
---@return boolean
function this.valid(configuration, actor, rules)
    for i = 1, #rules do
        local rule = rules[i]
        if not rule.isMet(configuration, actor) then
            this.logger:debug("Configuration '%s' not valid for '%s' because '%s' was violated",
                this.resolveId(configuration),
                actor.baseObject.id,
                rule.name)

            return false
        end
    end

    return true
end

---@private
---@param configuration filterableConfiguration
---@return string
function this.resolveId(configuration)
    return tostring(configuration.id or configuration.source)
end

return this
