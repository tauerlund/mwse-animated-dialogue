---@class dialogueTypesFilteringRule : conditionFilteringRule
local this = {}

---@public
---@param configuration voiceConfiguration
---@param _ tes3reference
---@param line dialogueLine|nil
---@return boolean
function this.isMet(configuration, _, line)
    local dialogueTypes = configuration.conditions and configuration.conditions.dialogueTypes
    if not dialogueTypes then
        return true
    end

    if not line or line.info.type == nil then
        return false
    end

    return this.matches(dialogueTypes, line.info.type)
end

---@private
---@param dialogueTypes string[]
---@param dialogueType integer
---@return boolean
function this.matches(dialogueTypes, dialogueType)
    for _, name in ipairs(dialogueTypes) do
        if tes3.dialogueType[name:lower()] == dialogueType then
            return true
        end
    end

    return false
end

return this
