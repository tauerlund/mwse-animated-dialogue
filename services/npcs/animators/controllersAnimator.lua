---@class npcControllersAnimator : initializedService, npcAnimator
local this = {}

---@private
---@type eventRegistrar
this.eventRegistrar = nil

---@private
---@type settings
this.settings = nil

---@private
---@type npcPoseBlender
this.npcPoseBlender = nil

---@private
---@type tes3reference
this.npc = nil

---@private
---@type number
this.phase = 0

---@private
---@type number
this.phaseStart = 0

---@private
---@type number
this.phaseEnd = 0

---@private
---@type mwseLogger
this.logger = mwse.Logger.new()

---@private
---@type niKeyframeController[]
this.sectionControllers = {}

---@private
---@type number[]
this.sectionOriginalPhases = {}

---@private
this.sectionCount = 0

---@private
this.eventHandlers = nil

---@public
---@param services serviceCollection
---@return boolean,string|nil
function this.initialize(services)
    this.eventRegistrar = services.eventRegistrar
    this.settings       = services.settings
    this.npcPoseBlender = services.npcPoseBlender

    local events        = services.enums.events
    this.eventHandlers  = {
        [events.dialogueAnimationResolved] = this.onDialogueAnimationResolved,
        [events.dialogueEnded]             = this.onDialogueEnded,
    }

    this.eventRegistrar.register(this.eventHandlers)

    return true, nil
end

---@public
function this.uninitialize()
    this.eventRegistrar.unregister(this.eventHandlers)
end

---@private
---@param e dialogueAnimationResolvedEventData
function this.onDialogueAnimationResolved(e)
    local animationData = e.npc.animationData
    if not animationData then
        return
    end

    this.npc   = e.npc
    this.phase = 0

    -- Capture the pre-dialogue pose before loading/playing so the walk/idle -> animation blend
    -- starts from the NPC's genuine current pose.
    this.npcPoseBlender.capture(animationData.actorNode, this.settings.transitionDuration)

    tes3.loadAnimation({
        reference = e.npc,
        file      = e.animation.file
    })

    local group = tes3.animationGroup[e.animation.group]
    if not group then
        this.logger:error("Unknown animation group '%s'", e.animation.group)
        this.npc = nil
        return
    end

    tes3.playAnimation({
        reference = e.npc,
        group     = group
    })

    this.captureSectionPhases(animationData)

    local start, stop = this.getGroupWindow(animationData, group)
    this.phaseStart   = start or 0
    this.phaseEnd     = stop or this.phaseStart
    this.phase        = this.phaseStart
end

---@private
function this.onDialogueEnded()
    this.restoreSectionPhases()

    -- Reset the actor's animations to default, undoing the loaded animation file.
    if this.npc then
        tes3.loadAnimation({ reference = this.npc })
    end

    this.npc = nil
    this.npcPoseBlender.reset()
end

---@private
---@param animationData tes3animationData
function this.captureSectionPhases(animationData)
    this.sectionCount = 0

    local sections = tes3.animationBodySection

    this.cancelSectionOffset(animationData, sections.lower, "lower")
    this.cancelSectionOffset(animationData, sections.upper, "upper")

    -- The leftArm of a torch-carrier should hold the torch raised, not drop to idle. Anchor
    -- it into the vanilla `torch` group's window instead of cancelling it to the idle region.
    if this.isHoldingTorch() then
        this.anchorTorchArm(animationData)
    else
        this.cancelSectionOffset(animationData, sections.leftArm, "leftArm")
    end
end

---@private
---@param animationData tes3animationData
---@param section tes3.animationBodySection
---@param field string
---@return niSequence|nil
function this.resolveSectionSequence(animationData, section, field)
    local layer = animationData.currentAnimGroupLayers[section + 1]
    if not layer then
        return nil
    end

    local group = animationData.keyframeLayers[layer + 1]
    return group and group[field] --[[@as niSequence]]
end

---@private
---@param animationData tes3animationData
---@param section tes3.animationBodySection
---@param field string
function this.cancelSectionOffset(animationData, section, field)
    local sequence = this.resolveSectionSequence(animationData, section, field)
    if not sequence then
        return
    end

    local offset = sequence.offset
    if offset == 0 then
        return
    end

    -- Cancelling the offset drives the section at `phase` (the idle window at [0, 2.666667]).
    this.captureSectionShift(sequence, -offset)
end

---@private
---@return boolean
function this.isHoldingTorch()
    local mobile = this.npc.mobile
    return mobile ~= nil and mobile.torchSlot ~= nil and mobile.torchSlot.object ~= nil
end

-- Drive the leftArm in the vanilla `torch` group's keyframe window instead of the idle one,
-- so the manager poses the arm raised. `offset` (read-only) is what the manager folds into the
-- fed time; the writable `controller.phase` lets us re-target by shifting `torchStart - offset`,
-- making the effective time `phase + torchStart`. The torch span equals the idle period
-- (2.666667), so the existing phase wrap sweeps exactly [torchStart, torchStop] and loops cleanly.
---@private
---@param animationData tes3animationData
function this.anchorTorchArm(animationData)
    local sequence = this.resolveSectionSequence(animationData, tes3.animationBodySection.leftArm, "leftArm")
    if not sequence then
        return
    end

    local torchStart = this.getGroupWindow(animationData, tes3.animationGroup.torch)
    if not torchStart then
        -- No torch window available; fall back to the idle cancel (arm down, but not flailing).
        this.captureSectionShift(sequence, -sequence.offset)
        return
    end

    this.captureSectionShift(sequence, torchStart - sequence.offset)
end

-- An animation group's absolute [start, stop] time on the concatenated KF timeline, from its
-- action note keys (actionTimings[1]/[2]). Verified against idle = [0, 2.666667]. Read per-actor
-- so it adapts to the actor's own keyframes rather than hardcoding a base-anim value.
---@private
---@param animationData tes3animationData
---@param group tes3.animationGroup
---@return number|nil start, number|nil stop
function this.getGroupWindow(animationData, group)
    local groups = animationData.animationGroups
    if not groups then
        return nil, nil
    end

    local animationGroup = groups[group + 1]
    if not animationGroup or (animationGroup.actionCount or 0) < 2 then
        return nil, nil
    end

    local timings = animationGroup.actionTimings
    return timings[1], timings[2]
end

-- Shift every (non-nil) controller of a section's sequence by `phaseShift` seconds, caching
-- the originals so restoreSectionPhases can undo it. Effective drive time becomes
-- `phase + offset + originalPhase + phaseShift`.
---@private
---@param sequence niSequence
---@param phaseShift number
function this.captureSectionShift(sequence, phaseShift)
    -- MWSE's controllers array is sparse (nil holes), and ipairs over it yields the nils
    -- rather than terminating, so guard each entry.
    for _, controller in ipairs(sequence.controllers) do
        if controller then
            local index                       = this.sectionCount + 1
            this.sectionCount                 = index
            this.sectionControllers[index]    = controller
            this.sectionOriginalPhases[index] = controller.phase
            controller.phase                  = controller.phase + phaseShift
        end
    end
end

---@private
function this.restoreSectionPhases()
    for i = 1, this.sectionCount do
        this.sectionControllers[i].phase = this.sectionOriginalPhases[i]
        this.sectionControllers[i]       = nil
        this.sectionOriginalPhases[i]    = nil
    end

    this.sectionCount = 0
end

---@public
---@param delta number
function this.update(delta)
    if not this.npc then
        return
    end

    local animationData = this.npc.animationData
    if not animationData then
        return
    end

    animationData.actorNode:update({
        controllers = true,
        children    = true,
        time        = this.phase
    })

    if this.npcPoseBlender.isActive() then
        this.npcPoseBlender.update(animationData.actorNode, delta)
    end

    animationData.headNode:update({
        controllers = true,
        time        = 0
    })

    this.phase = this.phase + delta
    if this.phase >= this.phaseEnd then
        this.phase = this.phaseStart
    end
end

return this
