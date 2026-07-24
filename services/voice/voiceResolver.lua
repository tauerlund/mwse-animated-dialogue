---@class voiceResolver : initializedService
local this = {}

---@private
---@type conditionFilterer
this.conditionFilterer = nil

---@private
---@type values
this.values = nil

---@private
---@type voiceConfiguration[]
this.configurations = nil

---@public
---@param services serviceCollection
---@return boolean, string|nil
function this.initialize(services)
    this.conditionFilterer = services.conditionFilterer
    this.values = services.values
    this.configurations = services.voiceLoader.getConfigurations()

    return true, nil
end

---@public
---@param services serviceCollection
---@return initializedService[]
function this.dependencies(services)
    return { services.voiceLoader, services.conditionFilterer }
end

---@public
---@param actor tes3reference
---@return voiceConfiguration|nil
function this.resolve(actor)
    local filtered = this.conditionFilterer.filter(this.configurations, actor)
    if #filtered == 0 then
        return nil
    end

    return this.values.weightedChoice(filtered, this.resolveWeight)
end

---@private
---@param configuration voiceConfiguration
---@return number
function this.resolveWeight(configuration)
    return configuration.weight or 1
end

return this
