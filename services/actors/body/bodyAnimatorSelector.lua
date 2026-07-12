--- Picks the body-animation strategy for a reference and returns a fresh
--- instance of it. The caller supplies the gates - which strategies it will
--- accept - so the same strategies can serve participants with independent MCM
--- toggles (the actor's and the player's).
---@class bodyAnimatorSelector : initializedService
local this = {}

---@private
---@type bodyAnimatorStrategy[]
this.strategies = nil

---@public
---@param services serviceCollection
---@return boolean,string|nil
function this.initialize(services)
    this.strategies = {
        { gate = "creature", animator = services.creatureBodyAnimator },
        { gate = "native",   animator = services.overrideBodyAnimator },
        { gate = "clip",     animator = services.clipBodyAnimator },
    }

    return true, nil
end

---@public
---@param reference tes3reference
---@param gates bodyAnimatorGates
---@return bodyAnimator|nil
function this.resolve(reference, gates)
    for i = 1, #this.strategies do
        local strategy = this.strategies[i]
        if gates[strategy.gate] and strategy.animator.handles(reference) then
            return strategy.animator.create()
        end
    end

    return nil
end

return this
