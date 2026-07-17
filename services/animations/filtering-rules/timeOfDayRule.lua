---@class timeOfDayFilteringRule : animationFilteringRule
local this = {}

---@public
---@param configuration animationConfiguration
---@param _ tes3reference
---@return boolean
function this.isMet(configuration, _)
    local timeOfDay = configuration.conditions and configuration.conditions.timeOfDay
    if not timeOfDay then
        return true
    end

    return this.contains(timeOfDay, tes3.worldController.hour.value)
end

---@private
---@param timeOfDay timeOfDayRange
---@param hour number
---@return boolean
function this.contains(timeOfDay, hour)
    if timeOfDay.from <= timeOfDay.to then
        return hour >= timeOfDay.from and hour < timeOfDay.to
    end

    return hour >= timeOfDay.from or hour < timeOfDay.to
end

return this
