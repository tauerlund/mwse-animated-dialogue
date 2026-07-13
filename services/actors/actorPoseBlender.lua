---@class actorPoseBlender : service
local this = {}

---@private
---@type niNode[]
this.nodes = nil

---@private
---@type niQuaternion[]
this.rotations = nil

---@private
---@type tes3vector3[]
this.translations = nil

---@private
this.count = 0

---@private
this.elapsed = 0

---@private
this.duration = 0

---@private
this.active = false

---@private
this.bonePrefix = "Bip"

---@public
---@return actorPoseBlender
function this.create()
    local instance = setmetatable({}, { __index = this })

    instance.nodes = {}
    instance.rotations = {}
    instance.translations = {}
    instance.count = 0
    instance.elapsed = 0
    instance.duration = 0
    instance.active = false

    return instance
end

---@public
---@param rootNode niNode
---@param duration number
function this:capture(rootNode, duration)
    self.count    = 0
    self.elapsed  = 0
    self.duration = duration
    self.active   = duration > 0

    if not self.active then
        return
    end

    for node in rootNode:traverse({ prefix = self.bonePrefix }) do
        local index              = self.count + 1
        self.count               = index
        self.nodes[index]        = node --[[@as niNode]]
        self.rotations[index]    = node.rotation:toQuaternion()
        self.translations[index] = node.translation:copy()
    end
end

---@public
---@param rootNode niNode
---@param delta number
function this:update(rootNode, delta)
    if not self.active then
        return
    end

    self.elapsed = self.elapsed + delta
    local t = math.ease.smoothstep(math.min(self.elapsed / self.duration, 1))

    for i = 1, self.count do
        local node            = self.nodes[i]
        local fromRotation    = self.rotations[i]
        local fromTranslation = self.translations[i]

        node.rotation         = fromRotation:slerp(node.rotation:toQuaternion(), t):toRotation()
        node.translation      = fromTranslation + (node.translation - fromTranslation) * t
    end

    rootNode:update({ children = true })

    if self.elapsed >= self.duration then
        self.active = false
    end
end

---@public
---@return boolean
function this:isActive()
    return self.active
end

---@public
function this:reset()
    self.active  = false
    self.elapsed = 0

    local n      = #self.nodes
    for i = 1, n do
        self.nodes[i]        = nil
        self.rotations[i]    = nil
        self.translations[i] = nil
    end

    self.count = 0
end

return this
