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

    local sliderRefs = {}

    for _, sliderDef in ipairs(params.sliders) do
        table.insert(sliderRefs, this.createSliderRow(section, sliderDef))
    end

    guiBuilder.createDivider({ parent = section }):build()

    this.createButtonRow(section, sliderRefs, params.onCopy)

    return section
end

---@private
---@param section tes3uiElement
---@param sliderDef debugSliderDef
---@return table
function this.createSliderRow(section, sliderDef)
    local guiBuilder = this.guiBuilder
    local steps = math.round((sliderDef.max - sliderDef.min) / sliderDef.step)
    local defaultStep = math.round((sliderDef.default - sliderDef.min) / sliderDef.step)

    local row = guiBuilder.createBlock({ parent = section })
        :withFlowDirection(tes3.flowDirection.leftToRight)
        :withAutoSize()
        :withPadding({ top = 4, bottom = 4 })
        :build()

    guiBuilder.createLabel({ parent = row })
        :withText(sliderDef.label)
        :withSize({ width = 60 })
        :build()

    local valueLabel = guiBuilder.createLabel({ parent = row })
        :withText(string.format("%.3f", sliderDef.default))
        :withSize({ width = 55 })
        :build()

    local sliderEl = guiBuilder.createSlider({
            parent = row,
            current = defaultStep,
            max = steps,
            step = 1,
            jump = math.max(1, math.round(steps / 10)),
        })
        :withSize({ width = 185 })
        :build()

    sliderEl:registerAfter(tes3.uiEvent.partScrollBarChanged, function()
        local intVal = sliderEl.widget.current
        local floatVal = sliderDef.min + (intVal / steps) * (sliderDef.max - sliderDef.min)
        valueLabel.text = string.format("%.3f", floatVal)
        this.refreshLayout(section)
        sliderDef.onChange(floatVal)
    end)

    return { sliderEl = sliderEl, valueLabel = valueLabel, defaultStep = defaultStep, sliderDef = sliderDef }
end

---@private
---@param section tes3uiElement
---@param sliderRefs table[]
---@param onCopy (fun(): string)|nil
function this.createButtonRow(section, sliderRefs, onCopy)
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
        for _, ref in ipairs(sliderRefs) do
            ref.sliderEl.widget.current = ref.defaultStep
            ref.valueLabel.text = string.format("%.3f", ref.sliderDef.default)
            ref.sliderDef.onChange(ref.sliderDef.default)
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
