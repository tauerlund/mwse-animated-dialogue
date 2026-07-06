---@class bodyAnimatorSelector : initializedService
local this = {}

---@private
---@type bodyAnimator[]
this.strategies = nil

---@public
---@param services serviceCollection
---@return boolean,string|nil
function this.initialize(services)
    this.strategies = {
        services.creatureBodyAnimator,
        services.overrideBodyAnimator,
        services.clipBodyAnimator,
    }

    return true, nil
end

---@public
---@param reference tes3reference
---@return bodyAnimator|nil
function this.resolve(reference)
    for i = 1, #this.strategies do
        local strategy = this.strategies[i]
        if strategy.handles(reference) then
            return strategy
        end
    end

    return nil
end

return this
