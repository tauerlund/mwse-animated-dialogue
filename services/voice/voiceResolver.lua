---@class voiceResolver : initializedService
local this = {}

---@private
---@type conditionFilterer
this.conditionFilterer = nil

---@private
---@type values
this.values = nil

---@private
---@type conditionFilteringRule[]
this.lineRules = nil

---@private
---@type voiceConfiguration[]
this.configurations = nil

---@public
---@param services serviceCollection
---@return boolean, string|nil
function this.initialize(services)
    this.conditionFilterer = services.conditionFilterer
    this.values = services.values
    this.lineRules = services.ruleLoader.loadRules("services\\voice\\filtering-rules")
    this.configurations = services.voiceLoader.getConfigurations()

    return true, nil
end

---@public
---@param services serviceCollection
---@return initializedService[]
function this.dependencies(services)
    return { services.voiceLoader, services.conditionFilterer, services.ruleLoader }
end

---@public
---@param actor tes3reference
---@param line dialogueLine
---@return voiceConfiguration|nil
function this.resolve(actor, line)
    local candidates = this.conditionFilterer.filter(this.configurations, actor, line)

    local matching = this.conditionFilterer.applyRules({
        configurations = candidates,
        actor = actor,
        rules = this.lineRules,
        line = line,
    })

    if #matching == 0 then
        return nil
    end

    return this.values.weightedChoice(matching, this.resolveWeight)
end

---@private
---@param configuration voiceConfiguration
---@return number
function this.resolveWeight(configuration)
    return configuration.weight or 1
end

return this
