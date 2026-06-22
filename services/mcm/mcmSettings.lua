---@class mcmSettings
local this = {}

---@private
this.path = "animated-dialogue"

---@type settings
this.defaults = {
    distance = 75,
    horizontalOffset = 0,
    verticalOffset = 0,
    pitchOffset = 0,
    yawOffset = 0,
    rollOffset = 0,
    animationDuration = 1.0,
    turnDuration = 0.5,
}

---@type settings
this.mcm = mwse.loadConfig(this.path, this.defaults) --[[@as settings]]

---@public
function this.save()
    mwse.saveConfig(this.path, this.mcm)
end

return this
