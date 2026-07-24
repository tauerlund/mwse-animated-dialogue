---@class voiceConditionsValidationRule : voiceValidationRule
local this = {}

---@private
---@type conditionsValidator
this.conditionsValidator = nil

---@private
---@type values
this.values = nil

---@private
this.spokenDialogueTypes = {
    greeting = true,
    topic = true,
    service = true,
}

---@private
this.punctuationShapes = {
    question = true,
    exclamation = true,
    statement = true,
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

    local applicable, applicableReason = this.validateInapplicable(conditions)
    if not applicable then
        return false, applicableReason
    end

    return this.validateLineConditions(conditions)
end

---@private
---@param conditions conditions
---@return boolean, string|nil
function this.validateInapplicable(conditions)
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

    local typesValid, typesReason = this.validateNames({
        names = conditions.dialogueTypes,
        allowed = this.spokenDialogueTypes,
        field = "dialogueTypes",
        expected = "'greeting', 'topic' or 'service'",
    })

    if not typesValid then
        return false, typesReason
    end

    return this.validateNames({
        names = conditions.punctuation,
        allowed = this.punctuationShapes,
        field = "punctuation",
        expected = "'question', 'exclamation' or 'statement'",
    })
end

---@private
---@param params voiceConditionsValidationRule.validateNames.param
---@return boolean, string|nil
function this.validateNames(params)
    local names = params.names
    if names == nil then
        return true
    end

    if not this.values.isNonEmptyStringArray(names) then
        return false, string.format("conditions.%s must be a non-empty array of strings", params.field)
    end

    for _, name in ipairs(names) do
        if not params.allowed[name:lower()] then
            return false, string.format(
                "conditions.%s contains '%s', which must be %s",
                params.field,
                name,
                params.expected)
        end
    end

    return true
end

return this
