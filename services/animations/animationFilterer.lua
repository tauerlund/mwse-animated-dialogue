---@class animationFilterer : initializedService
local this = {}

---@private
---@type animationFilteringRule[]
this.rules = nil

---@private
this.logger = mwse.Logger.new()

---@public
---@param services serviceCollection
---@return boolean,string|nil
function this.initialize(services)
    this.rules = services.ruleLoader.loadRules("services\\animations\\filtering-rules")
    return true, nil
end

---@public
---@param services serviceCollection
---@return initializedService[]
function this.dependencies(services)
    return { services.ruleLoader }
end

---@public
---@param configurations animationConfiguration[]
---@param actor tes3reference
---@return animationConfiguration[]
function this.filter(configurations, actor)
    ---@type animationConfiguration[]
    local filtered = {}

    for i = 1, #configurations do
        local configuration = configurations[i]
        if this.valid(configuration, actor) then
            filtered[#filtered + 1] = configuration
        end
    end

    return filtered
end

---@private
---@param configuration animationConfiguration
---@param actor tes3reference
---@return boolean
function this.valid(configuration, actor)
    for i = 1, #this.rules do
        local rule = this.rules[i]
        if not rule.isMet(configuration, actor) then
            this.logger:debug("Animation '%s' not valid for '%s' because '%s' was violated",
                this.resolveId(configuration),
                actor.baseObject.id,
                rule.name)

            return false
        end
    end

    return true
end

---@private
---@param configuration animationConfiguration
---@return string
function this.resolveId(configuration)
    return tostring(configuration.id or configuration.source)
end

return this
