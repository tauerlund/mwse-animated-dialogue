local Logger = require("tauer.animated-dialogue.shared.Logger").Create("BipNodeService")
local TableUtils = require("tauer.shared.Arrays")

---@class BipNodeService
local this = {}

---@public
---@param node niNode
---@param parameters? GetALlBipNodesParameters
---@return niNode[]
function this.GetAllBipNodes(node, parameters)
    ---@type [niNode]:string
    local bipNodes = {}

    local parentBip = node:getObjectByName("Bip01") --[[@as niNode]]
    if not parentBip then
        Logger:error("%s does not contain a Bip01 node!", node.name)
        return bipNodes
    end

    if parameters and parameters.IncludeParent then
        bipNodes[parentBip.name] = parentBip
    end
    for child in table.traverse(parentBip.children) do
        local childNode = child --[[@as niNode]]
        if this.isBipNode(childNode) and not this.isExcluded(childNode, parameters) then
            bipNodes[childNode.name] = childNode
        end
    end

    return bipNodes
end

---@public
---@param npc tes3npcInstance
---@return niNode | nil
function this.GetHeadNode(npc)
    return npc.sceneNode:getObjectByName("Bip01 Head") --[[@as niNode]]
end

---@private
---@param node niNode
---@return boolean
function this.isBipNode(node)
    return node.name and node.name:startswith("Bip01")
end

---@private
---@param node niNode
---@param parameters GetALlBipNodesParameters|nil
---@return boolean
function this.isExcluded(node, parameters)
    if not parameters or not parameters.Exclude then
        return false
    end
    return TableUtils.Contains(parameters.Exclude, node.name)
end

return this