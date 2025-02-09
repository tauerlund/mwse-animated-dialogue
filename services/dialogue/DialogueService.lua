local Logger = require("tauer.animated-dialogue.shared.Logger").Create("DialogueService")
local Settings = require("tauer.animated-dialogue.shared.Settings")
local AnimationLoader = require("tauer.animated-dialogue.services.animation.AnimationLoader")
local BipNodeAnimator = require("tauer.animated-dialogue.services.animation.BipNodeAnimator")
local CameraAnimator = require("tauer.animated-dialogue.services.animation.CameraAnimator")
local OrientationService = require("tauer.shared.transform.OrientationService")
local MeshNodeAnimator = require("tauer.animated-dialogue.services.animation.MeshNodeAnimator")

local customEvents = require("tauer.animated-dialogue.shared.Events")

---@class DialogueService
local this = {}

---@private
---@type tes3reference
this.npc = nil

local tempTalkAnimations = {
    ["tauer\\anims\\talk_1.nif"] = "idle9",
    ["tauer\\anims\\talk_2.nif"] = "idle9",
    ["tauer\\anims\\talk_3.nif"] = "idle9",
    ["tauer\\anims\\talk_4.nif"] = "idle9",
    ["tauer\\anims\\talk_5.nif"] = "idle9",
    ["tauer\\anims\\talk_6.nif"] = "idle9",
    ["tauer\\anims\\talk_7.nif"] = "idle9",
    ["tauer\\anims\\talk_8.nif"] = "idle9",
}

local tempIdleAnimations = {
    ["base_anim.nif"] = "idle"
}

---@public
function this.Initialize()
    Logger:debug("Initializing DialogueService")
    event.register(tes3.event.uiActivated, this.onDialogueActivated, { filter = "MenuDialog" })
end

---@private
---@param e uiActivatedEventData
function this.onDialogueActivated(e)
    local reference = tes3ui.getServiceActor().reference --[[@as tes3reference]]
    if reference.object.objectType ~= tes3.objectType.npc and reference.object.objectType ~= tes3.objectType.creature then
        return
    end

    if Settings.Mcm.BlacklistedNpcs[reference.baseObject.id:lower()] then
        return
    end

    e.element:registerAfter(
		tes3.uiEvent.destroy,
		this.onDialogueEnded
	)

    local animation = this.getRandomAnimation(true)
    if not animation then
        Logger:error("Failed to load animation")
        return
    end


    this.npc = reference
    this.registerEvents()

    local target = this.getRelativeHeadPosition(reference --[[@as tes3npcInstance]])
    OrientationService.Face(reference, tes3.getCameraPosition())
    if Settings.Mcm.AnimateCamera then
        CameraAnimator.Start(target)
    end
    if Settings.Mcm.EnableNpcAnimations then
        BipNodeAnimator.Start(reference --[[@as tes3npcInstance]], animation)
    end
    if Settings.Mcm.EnableNpcLipsyncing then
        MeshNodeAnimator.StartHeadAnimations(reference --[[@as tes3npcInstance]])
    end
end

---@private
---@param npc tes3npcInstance
---@return tes3vector3
function this.getRelativeHeadPosition(npc)
    local head = npc.sceneNode:getObjectByName("Bip01 Head")
    return head.worldTransform.translation
end

---@private
---@param e infoGetTextEventData
function this.onInfoGetText(e)
    local info = e.info
	if not this.isMenuDialogInfo(info) then
        return
    end

    local randomAnimation = table.choice(tempTalkAnimations)
    if not randomAnimation then
        return
    end
    local animation = this.getRandomAnimation(true)
    if not animation then
        Logger:error("Failed to load animation")
        return
    end

    BipNodeAnimator.SetAnimation(animation)
end

---@private
---@param e AnimationFinishedEventData
function this.onAnimationFinished(e)
    local animation = this.getRandomAnimation(false)
    if not animation then
        Logger:error("Failed to load animation")
        return
    end
    BipNodeAnimator.SetAnimation(animation)
end

---@private
---@param dialogueInfo tes3dialogueInfo
function this.isMenuDialogInfo(dialogueInfo)
    local type = dialogueInfo.type
    if type == tes3.dialogueType.voice or type == tes3.dialogueType.journal or type == tes3.dialogueType.greeting then
        return false
    end
    return true
end

---@private
function this.onDialogueEnded()
    BipNodeAnimator.Stop()
    MeshNodeAnimator.Stop()
    CameraAnimator.Reset()
    this.unregisterEvents()
    this.npc = nil
end

---@private
---@param isTalk boolean
---@return Animation|nil
function this.getRandomAnimation(isTalk)
    local animationPaths = nil
    if isTalk and Settings.Mcm.EnableNpcTalkAnimations then
        animationPaths = tempTalkAnimations
    else
        animationPaths = tempIdleAnimations
    end
    local sequence, path = table.choice(animationPaths)
    if not path or not sequence then
        return nil
    end
    local animation = AnimationLoader.Load({ AnimationPath = path, SequenceName = sequence, NonLooping = isTalk })
    return animation
end

---@private
function this.registerEvents()
    if Settings.Mcm.EnableNpcTalkAnimations then
        if not event.isRegistered(tes3.event.infoGetText, this.onInfoGetText) then
            event.register(tes3.event.infoGetText, this.onInfoGetText)
        end
    end
    if not event.isRegistered(customEvents.AnimationFinished, this.onAnimationFinished) then
        event.register(customEvents.AnimationFinished, this.onAnimationFinished)
    end
end

function this.unregisterEvents()
    if event.isRegistered(tes3.event.infoGetText, this.onInfoGetText) then
        event.unregister(tes3.event.infoGetText, this.onInfoGetText)
    end
    if event.isRegistered(customEvents.AnimationFinished, this.onAnimationFinished) then
        event.unregister(customEvents.AnimationFinished, this.onAnimationFinished)
    end
end

return this