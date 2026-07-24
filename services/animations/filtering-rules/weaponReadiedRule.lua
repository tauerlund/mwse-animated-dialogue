---@class weaponReadiedFilteringRule : conditionFilteringRule
local this = {}

---@public
---@param configuration filterableConfiguration
---@param actor tes3reference
---@return boolean
function this.isMet(configuration, actor)
    local conditions = configuration.conditions

    local weaponReadiedOnly = conditions
        and conditions.weaponReadied == true
        or false

    local mobile = actor.mobile --[[@as tes3mobileActor]]
    local weaponReadied = mobile.weaponReady or mobile.spellReadied

    if weaponReadiedOnly then
        return weaponReadied
    end

    return not weaponReadied
end

return this
