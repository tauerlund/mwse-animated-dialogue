---@class nifLoader
local this         = {}

local ERROR_MARKER = "marker_error"
local MESH_ROOT    = "Meshes\\"

---@public
---@param file string
---@return niNode|nil
function this.load(file)
    local mesh = tes3.loadMesh(file, true)
    if not mesh or this.isErrorMarker(mesh) then
        return nil
    end

    return mesh:clone() --[[@as niNode]]
end

---@public
---@param file string
---@return boolean
function this.exists(file)
    return tes3.getFileExists(string.format("%s%s", MESH_ROOT, file))
end

---@private
---@param node niNode
---@return boolean
function this.isErrorMarker(node)
    return node.name ~= nil and node.name:lower() == ERROR_MARKER
end

return this
