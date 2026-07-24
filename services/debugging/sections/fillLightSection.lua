---@class fillLightSection : debugSection
local this = {}

---@private
---@type eventRegistrar
this.eventRegistrar = nil

---@private
---@type events
this.events = nil

---@private
---@type settings
this.settings = nil

---@private
---@type mcmSettings
this.mcmSettings = nil

---@private
---@type fillLightRanges
this.fillLightRanges = nil

---@private
---@type fillLightModes
this.fillLightModes = nil

---@private
---@type lightFillController
this.lightFillController = nil

---@private
---@type guiBuilder
this.guiBuilder = nil

---@private
---@type debugSectionBuilder
this.debugSectionBuilder = nil

---@private
---@type debugSliderSection
this.debugSliderSection = nil

---@private
---@type translations
this.translations = nil

---@private
---@type translationKey
this.translationKey = nil

---@private
---@type tes3uiElement|nil
this.block = nil

---@private
---@type eventHandlers
this.eventHandlers = nil

---@public
---@param services serviceCollection
---@return boolean, string|nil
function this.initialize(services)
    this.eventRegistrar = services.eventRegistrar
    this.events = services.constants.events
    this.settings = services.settings
    this.mcmSettings = services.mcmSettings
    this.fillLightRanges = services.constants.fillLightRanges
    this.fillLightModes = services.constants.fillLightModes
    this.lightFillController = services.lightFillController
    this.guiBuilder = services.guiBuilder
    this.debugSectionBuilder = services.debugSectionBuilder
    this.debugSliderSection = services.debugSliderSection
    this.translations = services.translations
    this.translationKey = services.constants.translationKey

    this.eventHandlers = {
        [this.events.settingsUpdated] = this.rebuild,
    }

    this.eventRegistrar.register(this.eventHandlers)

    return true, nil
end

---@public
function this.uninitialize()
    this.eventRegistrar.unregister(this.eventHandlers)
end

---@public
---@param params debugSection.build.param
function this.build(params)
    this.block = params.parent

    this.buildContent()
end

---@public
function this.destroy()
    this.block = nil
end

---@private
function this.rebuild()
    if not this.block then
        return
    end

    this.block:destroyChildren()
    this.buildContent()
    this.block:getTopLevelMenu():updateLayout()
end

---@private
function this.buildContent()
    local section = this.debugSectionBuilder.create({
        parent = this.block,
        title = this.translations.get(this.translationKey.debugFillLight),
    })

    this.buildModeGroup(section)

    if not this.lightFillController.isActive() then
        this.debugSectionBuilder.createHint({
            parent = section,
            text = this.translations.get(this.resolveInactiveHintKey()),
        })

        return
    end

    this.buildLightSection(section)
    this.buildColorSection(section)
    this.buildPlacementSection(section)
    this.buildSaveButton(section)
end

---@private
---@return string
function this.resolveInactiveHintKey()
    if this.settings.fillLightMode == this.fillLightModes.never then
        return this.translationKey.debugFillLightDisabledHint
    end

    return this.translationKey.debugFillLightSuppressedHint
end

---@private
---@param parent tes3uiElement
function this.buildModeGroup(parent)
    local group = this.debugSectionBuilder.createGroup({
        parent = parent,
        title = this.translations.get(this.translationKey.fillLightMode),
    })

    local button = this.guiBuilder.createButton({ parent = group })
        :withText(this.modeLabel())
        :build()

    button:registerBefore(tes3.uiEvent.mouseClick, this.cycleMode)
end

---@private
---@return string[]
function this.modeOrder()
    local modes = this.fillLightModes

    return { modes.always, modes.adaptive, modes.never }
end

---@private
---@return string
function this.modeLabel()
    local keys = this.translationKey
    local modes = this.fillLightModes
    local labels = {
        [modes.always] = keys.fillLightModeAlways,
        [modes.adaptive] = keys.fillLightModeAdaptive,
        [modes.never] = keys.fillLightModeNever,
    }

    return this.translations.get(labels[this.settings.fillLightMode] or keys.fillLightModeNever)
end

---@private
function this.cycleMode()
    local order = this.modeOrder()
    local index = table.find(order, this.settings.fillLightMode) or #order

    this.settings.fillLightMode = order[index % #order + 1]

    this.triggerFillLightUpdated()
    this.rebuild()
end

---@private
---@param parent tes3uiElement
function this.buildLightSection(parent)
    local keys = this.translationKey

    this.debugSliderSection.create({
        parent = parent,
        title = this.translations.get(keys.debugFillLightSection),
        sliders = {
            this.createSlider({ label = keys.fillLightBrightness, step = 0.01, field = "fillLightBrightness" }),
            this.createSlider({ label = keys.fillLightRadius, step = 8, field = "fillLightRadius" }),
        },
    })
end

---@private
---@param parent tes3uiElement
function this.buildPlacementSection(parent)
    local keys = this.translationKey

    this.debugSliderSection.create({
        parent = parent,
        title = this.translations.get(keys.debugPlacementSection),
        sliders = {
            this.createSlider({ label = keys.fillLightDistance, step = 1, field = "fillLightDistance" }),
            this.createSlider({ label = keys.fillLightHeight, step = 1, field = "fillLightHeight" }),
        },
    })
end

---@private
---@param parent tes3uiElement
function this.buildColorSection(parent)
    local group = this.debugSectionBuilder.createGroup({
        parent = parent,
        title = this.translations.get(this.translationKey.debugColorSection),
    })

    local picker = this.guiBuilder.createColorPicker({
        parent = group,
        initialColor = this.settings.fillLightColor,
        height = 128,
        mainWidth = 192,
        hueWidth = 24,
        previewWidth = 48,
        previewHeight = 32,
    }):build()

    picker:register(tes3.uiEvent.colorChanged, function()
        this.pickColor(picker)
    end)

    local copyButton = this.guiBuilder.createButton({ parent = group })
        :withText(this.translations.get(this.translationKey.debugCopy))
        :build()

    copyButton:registerBefore(tes3.uiEvent.mouseClick, function()
        os.setClipboardText(this.copyColor())
    end)
end

---@private
---@param picker tes3uiElement
function this.pickColor(picker)
    local widget = picker.widget --[[@as tes3uiColorPicker]]
    local picked = widget:getColor()
    local color = this.settings.fillLightColor

    color.r = picked.r
    color.g = picked.g
    color.b = picked.b

    this.triggerFillLightUpdated()
end

---@class fillLightSection.createSlider.param
---@field public label string
---@field public step number
---@field public field string

---@private
---@param params fillLightSection.createSlider.param
---@return debugSliderDefinition
function this.createSlider(params)
    local settings = this.settings
    local range = this.fillLightRanges[params.field]

    return {
        label = this.translations.get(params.label),
        min = range.min,
        max = range.max,
        step = params.step,
        default = settings[params.field],
        onChange = function(value)
            settings[params.field] = value
            this.triggerFillLightUpdated()
        end,
    }
end

---@private
---@return string
function this.copyColor()
    local color = this.settings.fillLightColor

    return string.format('{ "r": %.2f, "g": %.2f, "b": %.2f }', color.r, color.g, color.b)
end

---@private
function this.triggerFillLightUpdated()
    event.trigger(this.events.fillLightUpdated)
end

---@private
---@param parent tes3uiElement
function this.buildSaveButton(parent)
    local button = this.guiBuilder.createButton({ parent = parent })
        :withText(this.translations.get(this.translationKey.debugSaveSettings))
        :build()

    button:registerBefore(tes3.uiEvent.mouseClick, this.saveSettings)
end

---@private
function this.saveSettings()
    this.mcmSettings.save()
    tes3.messageBox(this.translations.get(this.translationKey.debugSettingsSaved))
end

return this
