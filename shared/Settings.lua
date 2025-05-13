---@class Settings
local this = {}

---@private
---@type string
this.configPath = "Animated Dialogue"

---@private
---@type Mcm
this.defaults = {
    AnimateCamera = true,
    CameraDistance = 50,
    CameraVerticalOffset = -5,
    CameraHorizontalOffset = 25,
    BlacklistedNpcs = {},
    EnableNpcAnimations = true,
    EnableNpcLipsyncing = true,
    EnableNpcTalkAnimations = true,
    EnableLookAtCamera = true,
}

---@type Mcm
this.Mcm = mwse.loadConfig (
    this.configPath,
    this.defaults
) --[[@as Mcm]]

function this.Save()
    mwse.saveConfig(this.configPath, this.Mcm)
end

return this