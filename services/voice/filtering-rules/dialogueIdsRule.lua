---@class dialogueIdsFilteringRule : conditionFilteringRule
local this = {}

---@private
---@type values
this.values = nil

---@public
---@param services serviceCollection
function this.initialize(services)
    this.values = services.values
end

---@public
---@param configuration voiceConfiguration
---@param _ tes3reference
---@param line dialogueLine|nil
---@return boolean
function this.isMet(configuration, _, line)
    local dialogueIds = configuration.conditions and configuration.conditions.dialogueIds
    if not dialogueIds then
        return true
    end

    if not line then
        return false
    end

    return this.values.contains(dialogueIds, line.info.id)
end

return this
