---@class debugSection : initializedService
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
---@param params debugSection.create.param
---@return tes3uiElement
function this.create(params)
    local guiBuilder = this.guiBuilder

    local frame = guiBuilder.createThinBorder({ parent = params.parent })
        :withFlowDirection(tes3.flowDirection.topToBottom)
        :withAutoSize()
        :withProportional({ width = 1.0 })
        :withPadding({ all = 8 })
        :withBorder({ bottom = 8 })
        :build()

    guiBuilder.createLabel({ parent = frame })
        :withText(params.title)
        :withColor(tes3ui.getPalette(tes3.palette.headerColor))
        :build()

    local content = guiBuilder.createBlock({ parent = frame })
        :withFlowDirection(tes3.flowDirection.topToBottom)
        :withAutoSize()
        :withProportional({ width = 1.0 })
        :withBorder({ top = 6 })
        :build()

    return content
end

return this
