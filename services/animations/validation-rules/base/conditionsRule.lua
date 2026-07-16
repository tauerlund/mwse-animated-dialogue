---@class conditionsValidationRule : animationValidationRule
local this = {}

---@private
---@type values
this.values = nil

---@private
this.specializations = {
    combat = true,
    magic = true,
    stealth = true,
}

---@public
---@param services serviceCollection
function this.initialize(services)
    this.values = services.values
end

---@public
---@param configuration baseAnimationConfiguration
---@return boolean, string|nil
function this.validate(configuration)
    local conditions = configuration.conditions
    if conditions == nil then
        return true
    end

    if type(conditions) ~= "table" then
        return false, "conditions must be a table"
    end

    if conditions.actor ~= nil and not this.values.isNonEmptyStringArray(conditions.actor) then
        return false, "conditions.actor must be a non-empty array of strings"
    end

    if conditions.faction ~= nil and not this.values.isNonEmptyStringArray(conditions.faction) then
        return false, "conditions.faction must be a non-empty array of strings"
    end

    if conditions.factionRank ~= nil and not this.values.isValidRange(conditions.factionRank) then
        return false, "conditions.factionRank must be a table with a numeric 'min' and/or 'max', where min is not greater than max"
    end

    if conditions.class ~= nil and not this.values.isNonEmptyStringArray(conditions.class) then
        return false, "conditions.class must be a non-empty array of strings"
    end

    local specializationsValid, specializationsReason = this.validateSpecializations(conditions)
    if not specializationsValid then
        return false, specializationsReason
    end

    if conditions.race ~= nil and not this.values.isNonEmptyStringArray(conditions.race) then
        return false, "conditions.race must be a non-empty array of strings"
    end

    if conditions.sex ~= nil and conditions.sex ~= "male" and conditions.sex ~= "female" then
        return false, "conditions.sex must be 'male' or 'female'"
    end

    if conditions.beast ~= nil and type(conditions.beast) ~= "boolean" then
        return false, "conditions.beast must be a boolean"
    end

    if conditions.weaponReadied ~= nil and type(conditions.weaponReadied) ~= "boolean" then
        return false, "conditions.weaponReadied must be a boolean"
    end

    local weaponTypesValid, weaponTypesReason = this.validateWeaponTypes(conditions)
    if not weaponTypesValid then
        return false, weaponTypesReason
    end

    if conditions.interior ~= nil and type(conditions.interior) ~= "boolean" then
        return false, "conditions.interior must be a boolean"
    end

    local weatherValid, weatherReason = this.validateWeathers(conditions)
    if not weatherValid then
        return false, weatherReason
    end

    local timeOfDayValid, timeOfDayReason = this.validateTimeOfDay(conditions)
    if not timeOfDayValid then
        return false, timeOfDayReason
    end

    if conditions.disposition ~= nil and not this.values.isValidRange(conditions.disposition) then
        return false, "conditions.disposition must be a table with a numeric 'min' and/or 'max', where min is not greater than max"
    end

    if conditions.torchCompatible ~= nil and type(conditions.torchCompatible) ~= "boolean" then
        return false, "conditions.torchCompatible must be a boolean"
    end

    if conditions.shieldCompatible ~= nil and type(conditions.shieldCompatible) ~= "boolean" then
        return false, "conditions.shieldCompatible must be a boolean"
    end

    return true
end

---@private
---@param conditions animationConditions
---@return boolean, string|nil
function this.validateWeathers(conditions)
    local weathers = conditions.weather
    if weathers == nil then
        return true
    end

    if not this.values.isNonEmptyStringArray(weathers) then
        return false, "conditions.weather must be a non-empty array of strings"
    end

    for _, weather in ipairs(weathers) do
        if tes3.weather[weather:lower()] == nil then
            return false, string.format(
                "conditions.weather contains '%s', which is not a weather name",
                weather)
        end
    end

    return true
end

---@private
---@param conditions animationConditions
---@return boolean, string|nil
function this.validateWeaponTypes(conditions)
    local weaponTypes = conditions.weaponType
    if weaponTypes == nil then
        return true
    end

    if not this.values.isNonEmptyStringArray(weaponTypes) then
        return false, "conditions.weaponType must be a non-empty array of strings"
    end

    for _, weaponType in ipairs(weaponTypes) do
        if not this.isWeaponType(weaponType) then
            return false, string.format(
                "conditions.weaponType contains '%s', which is not a weapon type name, 'handToHand' or 'spell'",
                weaponType)
        end
    end

    return true
end

---@private
---@param weaponType string
---@return boolean
function this.isWeaponType(weaponType)
    local name = weaponType:lower()
    if name == "handtohand" or name == "spell" then
        return true
    end

    for enumName in pairs(tes3.weaponType) do
        if enumName:lower() == name then
            return true
        end
    end

    return false
end

---@private
---@param conditions animationConditions
---@return boolean, string|nil
function this.validateTimeOfDay(conditions)
    local timeOfDay = conditions.timeOfDay
    if timeOfDay == nil then
        return true
    end

    if type(timeOfDay) ~= "table" then
        return false, "conditions.timeOfDay must be a table with a 'from' and 'to' hour"
    end

    if type(timeOfDay.from) ~= "number" or type(timeOfDay.to) ~= "number" then
        return false, "conditions.timeOfDay must have a numeric 'from' and 'to' hour"
    end

    if not this.isHour(timeOfDay.from) or not this.isHour(timeOfDay.to) then
        return false, "conditions.timeOfDay hours must be within 0 and 24"
    end

    if timeOfDay.from == timeOfDay.to then
        return false, "conditions.timeOfDay 'from' and 'to' must differ"
    end

    return true
end

---@private
---@param hour number
---@return boolean
function this.isHour(hour)
    return hour >= 0 and hour <= 24
end

---@private
---@param conditions animationConditions
---@return boolean, string|nil
function this.validateSpecializations(conditions)
    local specializations = conditions.specialization
    if specializations == nil then
        return true
    end

    if not this.values.isNonEmptyStringArray(specializations) then
        return false, "conditions.specialization must be a non-empty array of strings"
    end

    for _, specialization in ipairs(specializations) do
        if not this.specializations[specialization:lower()] then
            return false, string.format(
                "conditions.specialization contains '%s', which must be 'combat', 'magic' or 'stealth'",
                specialization)
        end
    end

    return true
end

return this
