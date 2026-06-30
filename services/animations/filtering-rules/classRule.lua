---@class classFilteringRule : animationFilteringRule
local this = {}

---@private
---@type arrays
this.arrays = nil

---@public
---@param services serviceCollection
function this.initialize(services)
    this.arrays = services.arrays
end

---@public
---@param configuration baseAnimationConfiguration
---@param npc tes3reference
---@return boolean
function this.isMet(configuration, npc)
    local classes = configuration.conditions and configuration.conditions.class
    if not classes then
        return true
    end

    return this.arrays.contains(classes, npc.baseObject.class.id)
end

return this
