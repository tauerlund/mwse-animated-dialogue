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
    CameraVerticalOffset = 0,
    CameraHorizontalOffset = 0,
    BlacklistedNpcs = {}
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