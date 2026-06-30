---@class torchFilteringRule : animationFilteringRule
local this = {}

---@public
---@param configuration baseAnimationConfiguration
---@param npc tes3reference
---@return boolean
function this.isMet(configuration, npc)
    local torchCompatible = configuration.conditions and configuration.conditions.torchCompatible
    if torchCompatible == nil then
        return true
    end

    local torchEquipped = tes3.getEquippedItem({
        actor = npc.mobile --[[@as tes3mobileActor]],
        objectType = tes3.objectType.light,
    })

    if torchEquipped then
        return torchCompatible
    end

    return true
end

return this
