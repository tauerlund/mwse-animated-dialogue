local DialogueService = require("tauer.animated-dialogue.services.dialogue.DialogueService")

local function startMod()
    DialogueService.Initialize()
end

event.register(tes3.event.loaded, startMod)