---@class animationValidator : initializedService
local this = {}

---@private
---@type animationValidationRule[]
this.baseRules = nil

---@private
---@type overrideValidationRule[]
this.overrideRules = nil

---@private
---@type events
this.events = nil

---@private
this.logger = mwse.Logger.new()

---@public
---@param services serviceCollection
---@return boolean,string|nil
function this.initialize(services)
    this.baseRules = services.ruleLoader.loadRules("services\\animations\\validation-rules\\base")
    this.overrideRules = services.ruleLoader.loadRules("services\\animations\\validation-rules\\override")
    this.events = services.enums.events

    return true, nil
end

---@public
---@param services serviceCollection
---@return initializedService[]
function this.dependencies(services)
    return { services.ruleLoader }
end

---@public
---@param configuration baseAnimationConfiguration
---@param id string
---@return boolean
function this.validateBaseConfiguration(configuration, id)
    local ok, reason = this.applyRules(this.baseRules, configuration)
    if not ok then
        this.logger:warn("Skipping base animation configuration '%s': %s", id, reason)
        event.trigger(this.events.validationFailed)
        return false
    end

    return true
end

---@public
---@param configurations overrideAnimationConfigurationFile
---@param file string
---@return boolean
function this.validateOverrideFile(configurations, file)
    if type(configurations) ~= "table" then
        this.logger:warn("Skipping override animation file '%s'; missing or malformed", file)
        event.trigger(this.events.validationFailed)
        return false
    end

    return true
end

---@public
---@param configuration overrideAnimationConfiguration
---@param file string
---@return boolean
function this.validateOverrideConfiguration(configuration, file)
    local ok, reason = this.applyRules(this.overrideRules, configuration)
    if not ok then
        this.logger:warn("Skipping override entry in '%s': %s", file, reason)
        event.trigger(this.events.validationFailed)
        return false
    end

    return true
end

---@private
---@param rules animationValidationRule[]|overrideValidationRule[]
---@param configuration any
---@return boolean, string|nil
function this.applyRules(rules, configuration)
    if type(configuration) ~= "table" then
        return false, "missing or malformed"
    end

    for i = 1, #rules do
        local ok, reason = rules[i].validate(configuration)
        if not ok then
            return false, reason
        end
    end

    return true
end

return this
