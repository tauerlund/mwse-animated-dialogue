---@class mcmSettings
local this = {}

---@private
this.path = "animated-dialogue"

---@type settings
this.defaults = {
    distance = 75,
    animationDuration = 1.0,
}

---@type settings
this.mcm = mwse.loadConfig(this.path, this.defaults) --[[@as settings]]

---@public
function this.save()
    mwse.saveConfig(this.path, this.mcm)
end

return this
