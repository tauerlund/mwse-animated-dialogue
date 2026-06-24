---@class npcPoseBlender : service
local this = {}

---@private
---@type niNode[]
this.nodes = {}

---@private
---@type niQuaternion[]
this.rotations = {}

---@private
---@type tes3vector3[]
this.translations = {}

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
---@param rootNode niNode
---@param duration number
function this.capture(rootNode, duration)
    this.count    = 0
    this.elapsed  = 0
    this.duration = duration
    this.active   = duration > 0

    if not this.active then
        return
    end

    local children = rootNode.children
    if not children then
        return
    end

    for i = 1, #children do
        local child = children[i]
        if child then
            this.captureNode(child --[[@as niNode]])
        end
    end
end

---@public
---@param rootNode niNode
---@param delta number
function this.update(rootNode, delta)
    if not this.active then
        return
    end

    this.elapsed = this.elapsed + delta
    local t = math.ease.smoothstep(math.min(this.elapsed / this.duration, 1))

    for i = 1, this.count do
        local node            = this.nodes[i]
        local fromRotation    = this.rotations[i]
        local fromTranslation = this.translations[i]

        node.rotation         = fromRotation:slerp(node.rotation:toQuaternion(), t):toRotation()
        node.translation      = fromTranslation + (node.translation - fromTranslation) * t
    end

    rootNode:update({ children = true })

    if this.elapsed >= this.duration then
        this.active = false
    end
end

---@public
---@return boolean
function this.isActive()
    return this.active
end

---@public
function this.reset()
    this.active  = false
    this.elapsed = 0

    local n      = #this.nodes
    for i = 1, n do
        this.nodes[i]        = nil
        this.rotations[i]    = nil
        this.translations[i] = nil
    end

    this.count = 0
end

---@private
---@param node niNode
function this.captureNode(node)
    local name = node.name
    if name and name:sub(1, #this.bonePrefix) == this.bonePrefix then
        local index              = this.count + 1
        this.count               = index
        this.nodes[index]        = node
        this.rotations[index]    = node.rotation:toQuaternion()
        this.translations[index] = node.translation:copy()
    end

    local children = node.children
    if not children then
        return
    end

    for i = 1, #children do
        local child = children[i]
        if child then
            this.captureNode(child --[[@as niNode]])
        end
    end
end

return this
