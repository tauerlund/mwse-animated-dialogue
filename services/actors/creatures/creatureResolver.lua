--- Picks the idle animation to force on a creature during dialogue. Creatures
--- play randomized ambient idles, so - unlike custom-override NPCs, whose current
--- clip is the intended loop - we can't drive "current"; we resolve a neutral
--- idle and force it (see creatureBodyAnimator).
---
--- Resolution is an explicit per-creature config (creatureConfigLoader) or,
--- failing that, a heuristic: the longest non-travelling loop among the
--- creature's OWN idle groups (its override layer, not inherited base_anim idles).
---@class creatureResolver : initializedService
local this = {}

---@class creatureResolver.drive
---@field group number a tes3.animationGroup value
---@field start number loop window start time
---@field stop number loop window stop time
---@field layer number the animGroupLayerIndices layer the group came from

---@private
this.logger = mwse.Logger.new()

---@private
---@type creatureConfigLoader
this.creatureConfigLoader = nil

--- The actor's own (override) animation layer; inherited base_anim idles sit on
--- a different layer.
---@private
this.overrideLayer = 0

--- Root travel over a cycle above which a group is locomotion, not an idle.
---@private
this.maxIdleTravel = 1.0

---@private
---@type number[]
this.idleGroups = {
    tes3.animationGroup.idle,
    tes3.animationGroup.idle2,
    tes3.animationGroup.idle3,
    tes3.animationGroup.idle4,
    tes3.animationGroup.idle5,
    tes3.animationGroup.idle6,
    tes3.animationGroup.idle7,
    tes3.animationGroup.idle8,
    tes3.animationGroup.idle9,
}

---@public
---@param services serviceCollection
---@return boolean, string|nil
function this.initialize(services)
    this.creatureConfigLoader = services.creatureConfigLoader

    return true, nil
end

---@public
---@param services serviceCollection
---@return initializedService[]
function this.dependencies(services)
    return { services.creatureConfigLoader }
end

---@public
---@param reference tes3reference
---@return creatureResolver.drive|nil
function this.resolve(reference)
    local animationData = reference.animationData
    if not animationData then
        return nil
    end

    return this.resolveConfigured(reference, animationData)
        or this.resolveHeuristic(reference, animationData)
end

---@private
---@param reference tes3reference
---@param animationData tes3animationData
---@return creatureResolver.drive|nil
function this.resolveConfigured(reference, animationData)
    local name = this.creatureConfigLoader.getConfigurations()[reference.baseObject.id]
    if not name then
        return nil
    end

    local group = tes3.animationGroup[name]
    if not group then
        this.logger:warn("Unknown animation group '%s' configured for '%s'", name, reference.baseObject.id)
        return nil
    end

    local drive = this.evaluate(reference, animationData, group)
    if not drive then
        this.logger:warn("Configured idle '%s' for '%s' is not usable; falling back to heuristic", name,
            reference.baseObject.id)
    end

    return drive
end

---@private
---@param reference tes3reference
---@param animationData tes3animationData
---@return creatureResolver.drive|nil
function this.resolveHeuristic(reference, animationData)
    local candidates = {}
    for i = 1, #this.idleGroups do
        local group = this.idleGroups[i]
        local drive = this.evaluate(reference, animationData, group)
        if drive and not this.isTravelling(animationData, group) then
            table.insert(candidates, drive)
        end
    end

    local best = nil
    for _, drive in ipairs(this.preferOwn(candidates)) do
        if not best or (drive.stop - drive.start) > (best.stop - best.start) then
            best = drive
        end
    end

    return best
end

--- Restrict to the creature's OWN (override-layer) idles when it has any, so we
--- never fall back onto inherited base_anim idles (the Vivec case).
---@private
---@param candidates creatureResolver.drive[]
---@return creatureResolver.drive[]
function this.preferOwn(candidates)
    local own = {}
    for _, drive in ipairs(candidates) do
        if drive.layer == this.overrideLayer then
            table.insert(own, drive)
        end
    end

    return (#own > 0) and own or candidates
end

--- Builds the drive for a group, or nil if the creature lacks it / its window is
--- degenerate. No idle/travel filtering - the heuristic caller decides that.
---@private
---@param reference tes3reference
---@param animationData tes3animationData
---@param group number
---@return creatureResolver.drive|nil
function this.evaluate(reference, animationData, group)
    if not animationData.animationGroups[group + 1] then
        return nil
    end

    local start, stop = this.resolveWindow(reference, animationData, group)
    if not start or not stop or stop <= start then
        return nil
    end

    return {
        group = group,
        start = start,
        stop  = stop,
        layer = animationData.animGroupLayerIndices[group + 1],
    }
end

--- The group's loop window: the `Loop Start`/`Loop Stop` text markers, else
--- `Start`/`Stop`, else the positional group window.
---@private
---@param reference tes3reference
---@param animationData tes3animationData
---@param group number
---@return number|nil start, number|nil stop
function this.resolveWindow(reference, animationData, group)
    local timings = tes3.getAnimationActionTiming({ reference = reference, group = group })
    if timings then
        local marker = {}
        for key, value in pairs(timings) do
            marker[key:lower()] = value
        end

        local start = marker["loop start"] or marker["start"]
        local stop  = marker["loop stop"] or marker["stop"]
        if start and stop then
            return start, stop
        end
    end

    local actionTimings = animationData.animationGroups[group + 1].actionTimings
    return actionTimings[1], actionTimings[#actionTimings]
end

---@private
---@param animationData tes3animationData
---@param group number
---@return boolean
function this.isTravelling(animationData, group)
    local travel = animationData.approxRootTravelDistances[group + 1]
    return travel ~= nil and travel > this.maxIdleTravel
end

return this
