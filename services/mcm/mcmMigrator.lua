---@class mcmMigrator
local this = {}

---@private
---@param config table
function this.renameLightEnabledToFlickerEnabled(config)
    config.flickerEnabled = config.lightEnabled
    config.lightEnabled = nil
end

---@private
---@type fun(config: table)[]
this.migrations = {
    this.renameLightEnabledToFlickerEnabled,
}

---@public
---@return integer
function this.currentVersion()
    return #this.migrations
end

---@public
---@param config table
---@return boolean
function this.migrate(config)
    local version = config.configVersion or 0

    if version >= this.currentVersion() then
        return false
    end

    for index = version + 1, this.currentVersion() do
        this.migrations[index](config)
    end

    config.configVersion = this.currentVersion()

    return true
end

return this
