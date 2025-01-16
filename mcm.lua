local Settings = require("tauer.animated-dialogue.shared.Settings")

local template = mwse.mcm.createTemplate{name = "Animated Dialogue"}
template.onClose = function()
    Settings:Save()
end
template:register()

local page = template:createSideBarPage{ label = "Settings" }

-- Animation settings
local animationCategory = page:createCategory({label = "Animations"})

animationCategory:createOnOffButton({
    label = "NPC animations",
    description = "Enabling this setting will animate NPCs during dialogue.",
    variable = mwse.mcm.createTableVariable{ id = "EnableNpcAnimations", table = Settings.Mcm }
})


animationCategory:createOnOffButton({
    label = "NPC lipsyncing",
    description = "Enabling this setting will make NPCs lips move when talking during dialogue.",
    variable = mwse.mcm.createTableVariable{ id = "EnableNpcLipsyncing", table = Settings.Mcm }
})

animationCategory:createOnOffButton({
    label = "Talk animations",
    description = "Enabling this setting will make play different talking animations when a new dialogue option is clicked.",
    variable = mwse.mcm.createTableVariable{ id = "EnableNpcTalkAnimations", table = Settings.Mcm }
})

-- Camera Settings
local cameraCategory = page:createCategory({ label = "Camera" })

cameraCategory:createOnOffButton({
    label = "Animated camera",
    description = "Enabling this setting will make animate the camera during dialogue. Camera position and distance relative to the NPC is configurable.",
    variable = mwse.mcm.createTableVariable{ id = "AnimateCamera", table = Settings.Mcm }
})

cameraCategory:createSlider{
    label = "Camera distance",
    description = "The camera distance to NPCs during dialogue.",
    min = 20,
    max = 100,
    step = 1,
    jump = 10,
    variable = mwse.mcm.createTableVariable{ id = "CameraDistance", table = Settings.Mcm }
}

cameraCategory:createSlider{
    label = "Camera offset (Horizontal)",
    description = "The horizontal offset of the camera relative to the NPC.",
    min = -100,
    max = 100,
    step = 1,
    jump = 10,
    variable = mwse.mcm.createTableVariable{ id = "CameraVerticalOffset", table = Settings.Mcm }
}

cameraCategory:createSlider{
    label = "Camera offset (Vertical)",
    description = "The vertical offset of the camera relative to the NPC.",
    min = -100,
    max = 100,
    step = 1,
    jump = 10,
    variable = mwse.mcm.createTableVariable{ id = "CameraHorizontalOffset", table = Settings.Mcm }
}

-- Blacklist NPCs Settings
template:createExclusionsPage({
    label = "Blacklisted NPCs",
    description = "Animated dialogue will be disabled for these NPCs.",
    leftListLabel = "Blacklisted",
    rightListLabel = "NPCs",
    variable = mwse.mcm.createTableVariable{
        id = "BlacklistedNpcs",
        table = Settings.Mcm,
    },
    filters = {
        {
            label = "NPCs",
            callback = function()
                local npcs = {}

                --- @param npc tes3npc
                for npc in tes3.iterateObjects(tes3.objectType.npc) do
                    if not npc.isInstance then
                        table.insert(npcs, npc.id:lower())
                    end
                end

                table.sort(npcs)
                return npcs
            end
        },
    },
})