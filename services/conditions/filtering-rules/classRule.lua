---@class classFilteringRule : conditionFilteringRule
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
---@param configuration filterableConfiguration
---@param actor tes3reference
---@return boolean
function this.isMet(configuration, actor)
    local classes = configuration.conditions and configuration.conditions.class
    if not classes then
        return true
    end

    if actor.baseObject.objectType ~= tes3.objectType.npc then
        return false
    end

    return this.values.contains(classes, actor.baseObject.class.id)
end

return this
