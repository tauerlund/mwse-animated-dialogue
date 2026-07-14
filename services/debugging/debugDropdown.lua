---@class debugDropdown : initializedService
local this = {}

---@private
---@type guiBuilder
this.guiBuilder = nil

---@private
---@type dropdown[]
this.dropdowns = {}

---@public
---@param services serviceCollection
---@return boolean, string|nil
function this.initialize(services)
    this.guiBuilder = services.guiBuilder

    return true, nil
end

---@public
---@param params debugDropdown.create.param
---@return dropdown
function this.create(params)
    local guiBuilder = this.guiBuilder

    local header = guiBuilder.createTextSelect({ parent = params.parent })
        :withText(params.entries[1].label)
        :withWidgetColors({
            idle = tes3ui.getPalette(tes3.palette.normalColor),
            over = tes3ui.getPalette(tes3.palette.normalOverColor),
            pressed = tes3ui.getPalette(tes3.palette.normalPressedColor),
        })
        :build()

    local optionsBlock = guiBuilder.createBlock({ parent = params.parent })
        :withFlowDirection(tes3.flowDirection.topToBottom)
        :withAutoSize()
        :build()

    guiBuilder.createLabel({ parent = params.parent })
        :withText(params.hint)
        :withColor(tes3ui.getPalette(tes3.palette.disabledColor))
        :withWrapText()
        :build()

    ---@type dropdown
    local dropdown = {
        entries = params.entries,
        header = header,
        optionsBlock = optionsBlock,
        open = false,
        onSelect = params.onSelect,
        onHelp = params.onHelp,
    }

    header:registerBefore(tes3.uiEvent.mouseClick, function()
        this.toggle(dropdown)
    end)

    header:registerBefore(tes3.uiEvent.destroy, function()
        table.removevalue(this.dropdowns, dropdown)
    end)

    table.insert(this.dropdowns, dropdown)

    return dropdown
end

---@public
---@param dropdown dropdown
function this.remove(dropdown)
    table.removevalue(this.dropdowns, dropdown)
end

---@private
---@param dropdown dropdown
function this.toggle(dropdown)
    if dropdown.open then
        this.close(dropdown)
    else
        this.open(dropdown)
    end
end

---@private
---@param dropdown dropdown
function this.open(dropdown)
    this.closeAll()

    dropdown.open = true

    for i, entry in ipairs(dropdown.entries) do
        local item = this.guiBuilder.createTextSelect({ parent = dropdown.optionsBlock })
            :withText(entry.label)
            :withBorder({ left = 6 })
            :withWidgetColors({
                idle = tes3ui.getPalette(tes3.palette.normalColor),
                over = tes3ui.getPalette(tes3.palette.normalOverColor),
                pressed = tes3ui.getPalette(tes3.palette.normalPressedColor),
            })
            :build()

        item:registerBefore(tes3.uiEvent.mouseClick, function()
            this.select(dropdown, i)
        end)

        if dropdown.onHelp then
            item:register(tes3.uiEvent.help, function()
                dropdown.onHelp(entry)
            end)
        end
    end

    this.refreshLayout(dropdown)
end

---@private
---@param dropdown dropdown
function this.close(dropdown)
    dropdown.open = false
    dropdown.optionsBlock:destroyChildren()

    this.refreshLayout(dropdown)
end

---@private
function this.closeAll()
    for _, dropdown in ipairs(this.dropdowns) do
        if dropdown.open then
            dropdown.open = false
            dropdown.optionsBlock:destroyChildren()
        end
    end
end

---@private
---@param dropdown dropdown
---@param index integer
function this.select(dropdown, index)
    local entry = dropdown.entries[index]
    dropdown.header.text = entry.label

    this.close(dropdown)
    dropdown.onSelect(entry)
end

---@private
---@param dropdown dropdown
function this.refreshLayout(dropdown)
    local menu = dropdown.header:getTopLevelMenu()

    if menu then
        menu:updateLayout()
    end
end

return this
