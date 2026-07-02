---@class fileLoader
local this = {}

---@private
this.logger = mwse.Logger.new()

---@public
---@param param fileLoader.loadAll.params
---@return string[]|nil files
function this.loadAll(param)
    local directory = param.directory

    if not this.isDirectory(directory) then
        this.logger:error("%s is not a valid directory", directory)
        return nil
    end

    local files = {}

    for file in lfs.dir(directory) do
        if file:lower():endswith(param.fileType:lower()) then
            table.insert(files, file)
        end
    end

    if table.empty(files) then
        this.logger:warn("Found no files at %s", directory)
        return nil
    end

    return files
end

---@private
---@param path string
---@return boolean
function this.isDirectory(path)
    return lfs.attributes(path, "mode") == "directory"
end

return this
