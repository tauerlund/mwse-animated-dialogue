---@class weaponTypeFilteringRule : conditionFilteringRule
local this = {}

---@private
---@type values
this.values = nil

---@private
---@type table<integer, string>
this.weaponTypeNames = nil

---@private
this.handToHandType = "handToHand"

---@private
this.spellType = "spell"

---@private
this.shortBladeOneHandType = "shortBladeOneHand"

---@public
---@param services serviceCollection
function this.initialize(services)
    this.values = services.values
    this.weaponTypeNames = this.buildWeaponTypeNames()
end

---@private
---@return table<integer, string>
function this.buildWeaponTypeNames()
    local names = {}
    for name, value in pairs(tes3.weaponType) do
        names[value] = name
    end

    return names
end

---@public
---@param configuration filterableConfiguration
---@param actor tes3reference
---@return boolean
function this.isMet(configuration, actor)
    local weaponTypes = configuration.conditions and configuration.conditions.weaponType
    if not weaponTypes then
        return true
    end

    local weaponType = this.resolveWeaponType(actor.mobile --[[@as tes3mobileActor]])
    if not weaponType then
        return false
    end

    return this.values.contains(weaponTypes, weaponType)
end

---@private
---@param mobile tes3mobileActor
---@return string|nil
function this.resolveWeaponType(mobile)
    if mobile.spellReadied then
        return this.spellType
    end

    if not mobile.weaponReady then
        return nil
    end

    local readiedWeapon = mobile.readiedWeapon
    if not readiedWeapon then
        return this.handToHandType
    end

    return this.weaponTypeNames[readiedWeapon.object.type] or this.shortBladeOneHandType
end

return this
