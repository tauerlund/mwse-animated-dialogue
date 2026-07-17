---@class dispositionFilteringRule : animationFilteringRule
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
---@param configuration animationConfiguration
---@param actor tes3reference
---@return boolean
function this.isMet(configuration, actor)
    local disposition = configuration.conditions and configuration.conditions.disposition
    if not disposition then
        return true
    end

    if actor.baseObject.objectType ~= tes3.objectType.npc then
        return false
    end

    return this.values.withinRange(disposition, this.resolveDisposition(actor))
end

---@private
---@param actor tes3reference
---@return number
function this.resolveDisposition(actor)
    local object = actor.object
    if object ~= actor.baseObject then
        return object.disposition
    end

    return actor.baseObject.baseDisposition
end

return this
