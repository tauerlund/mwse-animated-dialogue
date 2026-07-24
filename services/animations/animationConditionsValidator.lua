---@class animationConditionsValidator : initializedService
local this = {}

---@private
---@type conditionsValidator
this.conditionsValidator = nil

---@public
---@param services serviceCollection
---@return boolean, string|nil
function this.initialize(services)
    this.conditionsValidator = services.conditionsValidator

    return true, nil
end

---@public
---@param services serviceCollection
---@return initializedService[]
function this.dependencies(services)
    return { services.conditionsValidator }
end

---@public
---@param conditions any
---@return boolean, string|nil
function this.validate(conditions)
    local valid, reason = this.conditionsValidator.validate(conditions)
    if not valid then
        return false, reason
    end

    if conditions == nil then
        return true
    end

    if conditions.beast ~= nil and type(conditions.beast) ~= "boolean" then
        return false, "conditions.beast must be a boolean"
    end

    if conditions.weaponReadied ~= nil and type(conditions.weaponReadied) ~= "boolean" then
        return false, "conditions.weaponReadied must be a boolean"
    end

    return true
end

return this
