--- Picks the single body-animation strategy for a dialogue actor by asking each
--- candidate's handles() in priority order (creature, then custom-override NPC,
--- then ordinary clip NPC). Passive (no events); shared by actorController (which
--- pumps the result each frame) and animationOrchestrator (which decides what it
--- plays). handles() folds in each strategy's MCM toggle, so both consumers and
--- the fall-through (e.g. override toggled off -> ordinary clip) always agree.
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
