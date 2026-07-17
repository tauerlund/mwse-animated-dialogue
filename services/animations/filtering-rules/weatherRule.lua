---@class weatherFilteringRule : animationFilteringRule
local this = {}

---@public
---@param configuration animationConfiguration
---@param actor tes3reference
---@return boolean
function this.isMet(configuration, actor)
    local weathers = configuration.conditions and configuration.conditions.weather
    if not weathers then
        return true
    end

    if actor.cell.isInterior then
        return false
    end

    local currentWeather = tes3.worldController.weatherController.currentWeather
    if not currentWeather then
        return false
    end

    return this.matchesWeather(weathers, currentWeather.index)
end

---@private
---@param weathers string[]
---@param index integer
---@return boolean
function this.matchesWeather(weathers, index)
    for _, weather in ipairs(weathers) do
        if tes3.weather[weather:lower()] == index then
            return true
        end
    end

    return false
end

return this
