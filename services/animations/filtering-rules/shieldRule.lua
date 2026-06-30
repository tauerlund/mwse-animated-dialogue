---@class shieldFilteringRule : animationFilteringRule
local this = {}

---@public
---@param configuration baseAnimationConfiguration
---@param npc tes3reference
---@return boolean
function this.isMet(configuration, npc)
    local shieldCompatible = configuration.conditions and configuration.conditions.shieldCompatible
    if shieldCompatible == nil then
        return true
    end

    local shieldEquipped = tes3.getEquippedItem({
        actor = npc.mobile --[[@as tes3mobileActor]],
        slot = tes3.armorSlot.shield,
        objectType = tes3.objectType.armor,
    })

    if shieldEquipped then
        return shieldCompatible
    end

    return true
end

return this
