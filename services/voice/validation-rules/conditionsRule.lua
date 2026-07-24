---@class voiceConditionsValidationRule : voiceValidationRule
local this = {}

---@private
---@type conditionsValidator
this.conditionsValidator = nil

---@private
---@type values
this.values = nil

---@private
this.allowedNames = {
    dialogueTypes = {
        names = { greeting = true, topic = true, service = true },
        expected = "'greeting', 'topic' or 'service'",
    },
    punctuation = {
        names = { question = true, exclamation = true, statement = true },
        expected = "'question', 'exclamation' or 'statement'",
    },
}

---@public
---@param services serviceCollection
function this.initialize(services)
    this.conditionsValidator = services.conditionsValidator
    this.values = services.values
end

---@public
---@param configuration voiceConfiguration
---@return boolean, string|nil
function this.validate(configuration)
    local valid, reason = this.conditionsValidator.validate(configuration.conditions)
    if not valid then
        return false, reason
    end

    local conditions = configuration.conditions
    if conditions == nil then
        return true
    end

    local supported, supportedReason = this.validateSupportedConditions(conditions)
    if not supported then
        return false, supportedReason
    end

    return this.validateLineConditions(conditions)
end

---@private
---@param conditions conditions
---@return boolean, string|nil
function this.validateSupportedConditions(conditions)
    if conditions.beast ~= nil then
        return false, "conditions.beast has no effect on voice lines"
    end

    if conditions.weaponReadied ~= nil then
        return false, "conditions.weaponReadied has no effect on voice lines"
    end

    return true
end

---@private
---@param conditions conditions
---@return boolean, string|nil
function this.validateLineConditions(conditions)
    if conditions.keywords ~= nil and not this.values.isNonEmptyStringArray(conditions.keywords) then
        return false, "conditions.keywords must be a non-empty array of strings"
    end

    if conditions.dialogueIds ~= nil and not this.values.isNonEmptyStringArray(conditions.dialogueIds) then
        return false, "conditions.dialogueIds must be a non-empty array of strings"
    end

    local typesValid, typesReason = this.validateNames(conditions, "dialogueTypes")
    if not typesValid then
        return false, typesReason
    end

    return this.validateNames(conditions, "punctuation")
end

---@private
---@param conditions conditions
---@param field string
---@return boolean, string|nil
function this.validateNames(conditions, field)
    local authored = conditions[field]
    if authored == nil then
        return true
    end

    if not this.values.isNonEmptyStringArray(authored) then
        return false, string.format("conditions.%s must be a non-empty array of strings", field)
    end

    local allowed = this.allowedNames[field]

    for _, name in ipairs(authored) do
        if not allowed.names[name:lower()] then
            return false, string.format(
                "conditions.%s contains '%s', which must be %s",
                field,
                name,
                allowed.expected)
        end
    end

    return true
end

return this
