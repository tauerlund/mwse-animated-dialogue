local DialogueService = require("tauer.animated-dialogue.services.dialogue.DialogueService")
local CameraAnimator = require("tauer.animated-dialogue.services.animation.CameraAnimator")
local NodeAnimator = require("tauer.animated-dialogue.services.animation.NodeAnimator")

local function startMod()
    DialogueService.Initialize()
    CameraAnimator.Initialize()
end

local function resetMod()
    CameraAnimator.Stop()
    NodeAnimator.Stop()
end

event.register(tes3.event.loaded, startMod)
event.register(tes3.event.load, resetMod)