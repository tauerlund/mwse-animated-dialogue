---@class bodyBonePinner
local this = {}

---@private
this.bonePrefix = "Bip"

---@private
---@type bonePin[]
this.pins = nil

---@public
---@type boolean
this.includeVertical = false

---@public
---@return bodyBonePinner
function this.create()
    local instance = setmetatable({}, { __index = this })

    instance.pins = {}
    instance.includeVertical = false

    return instance
end

---@public
---@param actorNode niNode|nil
function this:capture(actorNode)
    self:reset()

    if not actorNode then
        return
    end

    for bone in actorNode:traverse({ prefix = self.bonePrefix }) do
        self.pins[#self.pins + 1] = {
            node        = bone --[[@as niNode]],
            translation = bone.translation:copy(),
        }
    end
end

---@public
function this:apply()
    for i = 1, #self.pins do
        local pin = self.pins[i]
        local translation = pin.node.translation
        translation.x = pin.translation.x
        translation.y = pin.translation.y
        if self.includeVertical then
            translation.z = pin.translation.z
        end
        pin.node.translation = translation
    end
end

---@public
function this:reset()
    for i = #self.pins, 1, -1 do
        self.pins[i] = nil
    end
end

return this
