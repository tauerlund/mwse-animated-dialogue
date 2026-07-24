---@class voiceTimingValidationRule : voiceValidationRule
local this = {}

---@public
---@param configuration voiceConfiguration
---@return boolean, string|nil
function this.validate(configuration)
    local delay = configuration.delay
    if delay ~= nil then
        if type(delay) ~= "number" then
            return false, "delay must be a number"
        end

        if delay < 0 then
            return false, "delay must not be negative"
        end
    end

    local pitch = configuration.pitch
    if pitch ~= nil then
        if type(pitch) ~= "number" then
            return false, "pitch must be a number"
        end

        if pitch <= 0 then
            return false, "pitch must be greater than zero"
        end
    end

    return true
end

return this
