--- Picks the body-animation strategy for a reference and returns a fresh
--- instance of it. The caller supplies the toggles - which strategies it has
--- enabled - so the same strategies can serve participants with independent
--- MCM settings (the actor's and the player's).
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
        { kind = "creature", animator = services.creatureBodyAnimator },
        { kind = "native",   animator = services.overrideBodyAnimator },
        { kind = "clip",     animator = services.clipBodyAnimator },
    }

    return true, nil
end

---@public
---@param reference tes3reference
---@param toggles bodyAnimatorToggles
---@return bodyAnimator|nil
function this.resolve(reference, toggles)
    for i = 1, #this.strategies do
        local strategy = this.strategies[i]
        if toggles[strategy.kind] and strategy.animator.handles(reference) then
            return strategy.animator.create()
        end
    end

    return nil
end

return this
