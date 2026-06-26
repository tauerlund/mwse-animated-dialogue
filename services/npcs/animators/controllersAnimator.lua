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
        [events.dialogueStarted] = this.onDialogueStarted,
        [events.dialogueEnded]   = this.onDialogueEnded,
    }

    this.eventRegistrar.register(this.eventHandlers)

    return true, nil
end

---@public
function this.uninitialize()
    this.eventRegistrar.unregister(this.eventHandlers)
end

---@private
---@param event dialogueStartedEventData
function this.onDialogueStarted(event)
    this.npc            = event.npc
    this.phase          = 0

    local animationData = event.npc.animationData
    if animationData then
        this.npcPoseBlender.capture(animationData.actorNode, this.settings.transitionDuration)
    end

    tes3.playAnimation({
        reference = event.npc,
        group     = tes3.animationGroup.idle
    })

    if animationData then
        this.captureSectionPhases(animationData)
    end
end

---@private
function this.onDialogueEnded()
    this.restoreSectionPhases()
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
    this.cancelSectionOffset(animationData, sections.leftArm, "leftArm")
end

---@private
---@param animationData tes3animationData
---@param section tes3.animationBodySection
---@param field string
function this.cancelSectionOffset(animationData, section, field)
    local layer = animationData.currentAnimGroupLayers[section + 1]
    if not layer then
        return
    end

    local group    = animationData.keyframeLayers[layer + 1]
    local sequence = group and group[field] --[[@as niSequence]]
    if not sequence then
        return
    end

    local offset = sequence.offset
    if offset == 0 then
        return
    end

    for _, controller in ipairs(sequence.controllers) do
        local index                       = this.sectionCount + 1
        this.sectionCount                 = index
        this.sectionControllers[index]    = controller
        this.sectionOriginalPhases[index] = controller.phase
        controller.phase                  = controller.phase - offset
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
    if this.phase >= 2.666667 then
        this.phase = 0
    end
end

return this
