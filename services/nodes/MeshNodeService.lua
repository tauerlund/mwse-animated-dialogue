local Logger = require("tauer.animated-dialogue.shared.Logger").Create("MeshNodeService")

---@class MeshNodeService
local this = {}

---@public
---@param npc tes3npcInstance
---@return niTriShape|nil
function this.GetHeadMeshNode(npc)
    local sceneNode = npc.sceneNode --[[@as niNode]]
    local headBipNode = sceneNode:getObjectByName("Bip01 Head")
    local meshNodes = {}
    for child in table.traverse(headBipNode.children) do
        local childNode = child --[[@as niNode]]
        if childNode:isInstanceOfType(ni.type.NiTriShape) and this.GetMorphController(childNode --[[@as niTriShape]]) then
           table.insert(meshNodes, childNode)
        end
    end
    if table.size(meshNodes) == 0 then
        Logger:error("Did not find a suitable head mesh node!")
        return nil
    end

    if table.size(meshNodes) > 1 then
        Logger:error("Found more than one candidate for head mesh node!")
        return nil
    end

    return meshNodes[1]
end

---@public
---@param node niTriShape
---@return niTimeController|nil
function this.GetMorphController(node)
    ---@type niTimeController
    local controller = nil

    local currentController = node.controller
    while currentController do
        if currentController:isInstanceOfType(ni.type.NiGeomMorpherController) then
            controller = currentController
            break
        end
        currentController = currentController.nextController
    end

    return controller
end

return this