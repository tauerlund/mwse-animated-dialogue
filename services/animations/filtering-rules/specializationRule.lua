---@class specializationFilteringRule : animationFilteringRule
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
---@param configuration baseAnimationConfiguration
---@param actor tes3reference
---@return boolean
function this.isMet(configuration, actor)
    local specializations = configuration.conditions and configuration.conditions.specialization
    if not specializations then
        return true
    end

    local specialization = tes3.specializationName[actor.baseObject.class.specialization]
    if not specialization then
        return false
    end

    return this.values.contains(specializations, specialization)
end

return this
