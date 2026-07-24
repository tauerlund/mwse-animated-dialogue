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
---@param line? dialogueLine
---@return filterableConfiguration[]
function this.filter(configurations, actor, line)
    return this.applyRules({
        configurations = configurations,
        actor = actor,
        rules = this.rules,
        line = line,
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
        if this.valid(configuration, params) then
            filtered[#filtered + 1] = configuration
        end
    end

    return filtered
end

---@private
---@param configuration filterableConfiguration
---@param params conditionFilterer.applyRules.param
---@return boolean
function this.valid(configuration, params)
    local rules = params.rules

    for i = 1, #rules do
        local rule = rules[i]
        if not rule.isMet(configuration, params.actor, params.line) then
            this.logger:debug("Configuration '%s' not valid for '%s' because '%s' was violated",
                this.resolveId(configuration),
                params.actor.baseObject.id,
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
