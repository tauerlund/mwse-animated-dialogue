local LoggerFactory = require("tauer.shared.logging.LoggerFactory")
local LOG_LEVEL = require("tauer.shared.logging.LogLevel")

---@class Logger
local this = {}

---@public
---@param serviceName string
---@return mwseLogger
function this.Create(serviceName)
    return LoggerFactory.Create("Animated Dialogue", serviceName, LOG_LEVEL.info)
end

return this