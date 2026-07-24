---@class keywordsFilteringRule : conditionFilteringRule
local this = {}

---@public
---@param configuration voiceConfiguration
---@param _ tes3reference
---@param line dialogueLine|nil
---@return boolean
function this.isMet(configuration, _, line)
    local keywords = configuration.conditions and configuration.conditions.keywords
    if not keywords then
        return true
    end

    if not line or line.text == "" then
        return false
    end

    local patterns = configuration.keywordPatterns
    if not patterns then
        return false
    end

    return this.matches(patterns, line.text:lower())
end

---@private
---@param patterns string[]
---@param text string
---@return boolean
function this.matches(patterns, text)
    for i = 1, #patterns do
        if text:find(patterns[i]) then
            return true
        end
    end

    return false
end

return this
