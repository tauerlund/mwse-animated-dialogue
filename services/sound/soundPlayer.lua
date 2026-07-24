---@class soundPlayer
local this = {}

local SOUND_ROOT = "Sound\\"

---@public
---@param file string
---@return boolean
function this.exists(file)
    return tes3.getFileExists(string.format("%s%s", SOUND_ROOT, file))
end

---@public
---@param params soundPlayer.say.param
function this.say(params)
    tes3.say({
        reference = params.reference,
        soundPath = params.file,
        pitch = params.pitch,
    })
end

return this
