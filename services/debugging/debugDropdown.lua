---@class debugDropdown : initializedService
local this = {}

---@private
---@type guiBuilder
this.guiBuilder = nil

---@private
---@type debugDropdownHandle[]
this.handles = {}

---@public
---@param services serviceCollection
---@return boolean, string|nil
function this.initialize(services)
    this.guiBuilder = services.guiBuilder

    return true, nil
end

---@public
---@param params debugDropdown.create.param
---@return debugDropdownHandle
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

    local listParent = guiBuilder.createBlock({ parent = params.parent })
        :withFlowDirection(tes3.flowDirection.topToBottom)
        :withAutoSize()
        :build()

    guiBuilder.createLabel({ parent = params.parent })
        :withText(params.hint)
        :withColor(tes3ui.getPalette(tes3.palette.disabledColor))
        :withWrapText()
        :build()

    ---@type debugDropdownHandle
    local handle = {
        entries = params.entries,
        header = header,
        listParent = listParent,
        open = false,
        onSelect = params.onSelect,
        onHelp = params.onHelp,
    }

    header:registerBefore(tes3.uiEvent.mouseClick, function()
        this.toggle(handle)
    end)

    header:registerBefore(tes3.uiEvent.destroy, function()
        table.removevalue(this.handles, handle)
    end)

    table.insert(this.handles, handle)

    return handle
end

---@public
---@param handle debugDropdownHandle
function this.release(handle)
    table.removevalue(this.handles, handle)
end

---@private
---@param handle debugDropdownHandle
function this.toggle(handle)
    if handle.open then
        this.close(handle)
    else
        this.open(handle)
    end
end

---@private
---@param handle debugDropdownHandle
function this.open(handle)
    this.closeAll()

    handle.open = true

    for i, entry in ipairs(handle.entries) do
        local item = this.guiBuilder.createTextSelect({ parent = handle.listParent })
            :withText(entry.label)
            :withBorder({ left = 6 })
            :withWidgetColors({
                idle = tes3ui.getPalette(tes3.palette.normalColor),
                over = tes3ui.getPalette(tes3.palette.normalOverColor),
                pressed = tes3ui.getPalette(tes3.palette.normalPressedColor),
            })
            :build()

        item:registerBefore(tes3.uiEvent.mouseClick, function()
            this.select(handle, i)
        end)

        if handle.onHelp then
            item:register(tes3.uiEvent.help, function()
                handle.onHelp(entry)
            end)
        end
    end

    this.refreshLayout(handle)
end

---@private
---@param handle debugDropdownHandle
function this.close(handle)
    handle.open = false
    handle.listParent:destroyChildren()

    this.refreshLayout(handle)
end

---@private
function this.closeAll()
    for _, handle in ipairs(this.handles) do
        if handle.open then
            handle.open = false
            handle.listParent:destroyChildren()
        end
    end
end

---@private
---@param handle debugDropdownHandle
---@param index integer
function this.select(handle, index)
    local entry = handle.entries[index]
    handle.header.text = entry.label

    this.close(handle)
    handle.onSelect(entry)
end

---@private
---@param handle debugDropdownHandle
function this.refreshLayout(handle)
    local menu = handle.header:getTopLevelMenu()

    if menu then
        menu:updateLayout()
    end
end

return this
