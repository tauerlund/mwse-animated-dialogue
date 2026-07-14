---@class debugTooltip : initializedService
local this = {}

---@private
---@type guiBuilder
this.guiBuilder = nil

---@public
---@param services serviceCollection
---@return boolean, string|nil
function this.initialize(services)
    this.guiBuilder = services.guiBuilder

    return true, nil
end

---@public
---@param value any
function this.showJson(value)
    local tooltip = tes3ui.createTooltipMenu()

    local block = this.guiBuilder.createBlock({ parent = tooltip })
        :withFlowDirection(tes3.flowDirection.topToBottom)
        :withAutoSize()
        :withPadding({ all = 6 })
        :build()

    this.guiBuilder.createLabel({ parent = block })
        :withText(json.encode(value, { indent = true }))
        :build()

    tooltip:updateLayout()
end

return this
