---@class voiceValidator : initializedService
local this = {}

---@private
---@type voiceValidationRule[]
this.rules = nil

---@private
---@type events
this.events = nil

---@private
this.logger = mwse.Logger.new()

---@public
---@param services serviceCollection
---@return boolean,string|nil
function this.initialize(services)
    this.rules = services.ruleLoader.loadRules("services\\voice\\validation-rules")
    this.events = services.constants.events

    return true, nil
end

---@public
---@param services serviceCollection
---@return initializedService[]
function this.dependencies(services)
    return { services.ruleLoader }
end

---@public
---@param configurations voiceConfigurationFile
---@param file string
---@return boolean
function this.validateFile(configurations, file)
    if type(configurations) ~= "table" then
        this.logger:warn("Skipping voice file '%s'; missing or malformed", file)
        event.trigger(this.events.validationFailed)
        return false
    end

    if #configurations == 0 then
        this.logger:warn("Skipping voice file '%s'; it holds no entries", file)
        event.trigger(this.events.validationFailed)
        return false
    end

    return true
end

---@public
---@param configuration voiceConfiguration
---@param file string
---@return boolean
function this.validateConfiguration(configuration, file)
    local ok, reason = this.applyRules(configuration)
    if not ok then
        this.logger:warn("Skipping voice entry in '%s': %s", file, reason)
        event.trigger(this.events.validationFailed)
        return false
    end

    return true
end

---@private
---@param configuration any
---@return boolean, string|nil
function this.applyRules(configuration)
    if type(configuration) ~= "table" then
        return false, "missing or malformed"
    end

    for i = 1, #this.rules do
        local ok, reason = this.rules[i].validate(configuration)
        if not ok then
            return false, reason
        end
    end

    return true
end

return this
