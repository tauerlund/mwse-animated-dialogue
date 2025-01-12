local SharedLoggerFactory = require("tauer.shared.Logger")
local LOG_LEVEL = require("tauer.shared.enums.LOG_LEVEL")

---@class LoggerFactory
local this = {}

---@public
---@param serviceName string
---@return mwseLogger
function this.Create(serviceName)
    return SharedLoggerFactory.Create("Animated Dialogue", serviceName, LOG_LEVEL.info)
end

return this