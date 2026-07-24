---@class punctuationFilteringRule : conditionFilteringRule
local this = {}

---@private
this.question = "question"

---@private
this.exclamation = "exclamation"

---@private
this.statement = "statement"

---@public
---@param configuration voiceConfiguration
---@param _ tes3reference
---@param line dialogueLine|nil
---@return boolean
function this.isMet(configuration, _, line)
    local punctuation = configuration.conditions and configuration.conditions.punctuation
    if not punctuation then
        return true
    end

    if not line or line.text == "" then
        return false
    end

    local shape = this.resolveShape(line.text)

    for _, name in ipairs(punctuation) do
        if name:lower() == shape then
            return true
        end
    end

    return false
end

---@private
---@param text string
---@return string
function this.resolveShape(text)
    local trimmed = (text:gsub("[%s\"'%)%]}]+$", ""))
    local last = trimmed:sub(-1)

    if last == "?" then
        return this.question
    end

    if last == "!" then
        return this.exclamation
    end

    return this.statement
end

return this
