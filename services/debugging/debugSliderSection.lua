---@class debugSliderSection : initializedService
local this = {}

---@private
---@type guiBuilder
this.guiBuilder = nil

---@private
---@type translations
this.translations = nil

---@private
---@type translationKey
this.translationKey = nil

---@public
---@param services serviceCollection
---@return boolean, string|nil
function this.initialize(services)
    this.guiBuilder = services.guiBuilder
    this.translations = services.translations
    this.translationKey = services.enums.translationKey

    return true, nil
end

---@public
---@param params debugSliderSection.create.param
---@return tes3uiElement
function this.create(params)
    local guiBuilder = this.guiBuilder

    local section = guiBuilder.createBlock({ parent = params.parent })
        :withFlowDirection(tes3.flowDirection.topToBottom)
        :withAutoSize()
        :withPadding({ top = 4, bottom = 4 })
        :build()

    guiBuilder.createLabel({ parent = section })
        :withText(params.title)
        :build()

    guiBuilder.createDivider({ parent = section }):build()

    local rows = {}

    for _, definition in ipairs(params.sliders) do
        table.insert(rows, this.createSliderRow(section, definition))
    end

    guiBuilder.createDivider({ parent = section }):build()

    this.createButtonRow(section, rows, params.onCopy)

    return section
end

---@private
---@param section tes3uiElement
---@param definition debugSliderDefinition
---@return debugSliderRow
function this.createSliderRow(section, definition)
    local guiBuilder = this.guiBuilder
    local steps = math.round((definition.max - definition.min) / definition.step)
    local defaultStep = math.round((definition.default - definition.min) / definition.step)

    local row = guiBuilder.createBlock({ parent = section })
        :withFlowDirection(tes3.flowDirection.leftToRight)
        :withAutoSize()
        :withPadding({ top = 4, bottom = 4 })
        :build()

    guiBuilder.createLabel({ parent = row })
        :withText(definition.label)
        :withSize({ width = 60 })
        :build()

    local valueLabel = guiBuilder.createLabel({ parent = row })
        :withText(string.format("%.3f", definition.default))
        :withSize({ width = 55 })
        :build()

    local slider = guiBuilder.createSlider({
            parent = row,
            current = defaultStep,
            max = steps,
            step = 1,
            jump = math.max(1, math.round(steps / 10)),
        })
        :withSize({ width = 185 })
        :build()

    slider:registerAfter(tes3.uiEvent.partScrollBarChanged, function()
        local currentStep = slider.widget.current
        local value = definition.min + (currentStep / steps) * (definition.max - definition.min)
        valueLabel.text = string.format("%.3f", value)
        this.refreshLayout(section)
        definition.onChange(value)
    end)

    return { slider = slider, valueLabel = valueLabel, defaultStep = defaultStep, definition = definition }
end

---@private
---@param section tes3uiElement
---@param rows debugSliderRow[]
---@param onCopy (fun(): string)|nil
function this.createButtonRow(section, rows, onCopy)
    local guiBuilder = this.guiBuilder
    local translations = this.translations
    local keys = this.translationKey

    local buttonRow = guiBuilder.createBlock({ parent = section })
        :withFlowDirection(tes3.flowDirection.leftToRight)
        :withAutoSize()
        :build()

    local resetButton = guiBuilder.createButton({ parent = buttonRow })
        :withText(translations.get(keys.debugReset))
        :build()

    resetButton:registerBefore(tes3.uiEvent.mouseClick, function()
        for _, row in ipairs(rows) do
            row.slider.widget.current = row.defaultStep
            row.valueLabel.text = string.format("%.3f", row.definition.default)
            row.definition.onChange(row.definition.default)
        end
        this.refreshLayout(section)
    end)

    if not onCopy then
        return
    end

    local copyButton = guiBuilder.createButton({ parent = buttonRow })
        :withText(translations.get(keys.debugCopy))
        :build()

    copyButton:registerBefore(tes3.uiEvent.mouseClick, function()
        os.setClipboardText(onCopy())
    end)
end

---@private
---@param section tes3uiElement
function this.refreshLayout(section)
    local menu = section:getTopLevelMenu()

    if menu then
        menu:updateLayout()
    end
end

return this
