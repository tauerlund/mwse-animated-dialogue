---@class cameraPresetSection : debugSection
local this = {}

---@private
---@type eventRegistrar
this.eventRegistrar = nil

---@private
---@type events
this.events = nil

---@private
this.cameraAnchors = nil

---@private
---@type cameraPresetRanges
this.cameraPresetRanges = nil

---@private
---@type settings
this.settings = nil

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
---@type debugDropdown
this.debugDropdown = nil

---@private
---@type debugTooltip
this.debugTooltip = nil

---@private
---@type cameraPresetLoader
this.cameraPresetLoader = nil

---@private
---@type cameraPresetResolver
this.cameraPresetResolver = nil

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
---@type cameraPreset
this.preset = nil

---@private
---@type dropdown|nil
this.dropdown = nil

---@private
---@type eventHandlers
this.eventHandlers = nil

---@public
---@param services serviceCollection
---@return boolean, string|nil
function this.initialize(services)
    this.eventRegistrar = services.eventRegistrar
    this.events = services.constants.events
    this.cameraAnchors = services.constants.cameraAnchors
    this.cameraPresetRanges = services.constants.cameraPresetRanges
    this.settings = services.settings
    this.guiBuilder = services.guiBuilder
    this.debugSectionBuilder = services.debugSectionBuilder
    this.debugSliderSection = services.debugSliderSection
    this.debugDropdown = services.debugDropdown
    this.debugTooltip = services.debugTooltip
    this.cameraPresetLoader = services.cameraPresetLoader
    this.cameraPresetResolver = services.cameraPresetResolver
    this.translations = services.translations
    this.translationKey = services.constants.translationKey

    this.eventHandlers = {
        [this.events.settingsUpdated] = this.onSettingsUpdated,
        [this.events.dialogueEnded] = this.onDialogueEnded,
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
    this.removeDropdown()
    this.block = nil
end

---@private
function this.onSettingsUpdated()
    this.preset = nil
    this.rebuild()
end

---@private
function this.onDialogueEnded()
    this.preset = nil
end

---@private
function this.rebuild()
    if not this.block then
        return
    end

    this.removeDropdown()
    this.block:destroyChildren()
    this.buildContent()
    this.block:getTopLevelMenu():updateLayout()
end

---@private
function this.removeDropdown()
    if not this.dropdown then
        return
    end

    this.debugDropdown.remove(this.dropdown)
    this.dropdown = nil
end

---@private
function this.buildContent()
    local section = this.debugSectionBuilder.create({
        parent = this.block,
        title = this.translations.get(this.translationKey.debugCameraPreset),
    })

    if not this.settings.cameraEnabled then
        this.debugSectionBuilder.createHint({
            parent = section,
            text = this.translations.get(this.translationKey.debugCameraDisabledHint),
        })

        return
    end

    this.preset = this.preset or this.cameraPresetResolver.resolve()

    if not this.preset then
        this.debugSectionBuilder.createHint({
            parent = section,
            text = this.translations.get(this.translationKey.debugCameraNoPresetHint),
        })

        return
    end

    this.dropdown = this.debugDropdown.create({
        parent = section,
        entries = this.buildEntries(),
        onSelect = this.selectPreset,
        onHelp = this.showTooltip,
    })

    this.buildAnchorGroup(section)
    this.buildPositionSection(section)
    this.buildRotationSection(section)
    this.buildTimingSection(section)
    this.buildButtonRow(section)
end

---@private
---@return debugPresetEntry[]
function this.buildEntries()
    local entries = { { label = this.preset.id, preset = this.preset } }

    for _, id in ipairs(this.cameraPresetLoader.getIds()) do
        if id ~= this.preset.id then
            table.insert(entries, {
                label = id,
                preset = this.cameraPresetLoader.getPreset(id),
            })
        end
    end

    return entries
end

---@private
---@param entry debugPresetEntry
function this.selectPreset(entry)
    this.preset = entry.preset
    this.triggerCameraPresetUpdated()
    this.rebuild()
end

---@private
---@param entry debugPresetEntry
function this.showTooltip(entry)
    this.debugTooltip.showJson(entry.preset)
end

---@private
function this.triggerCameraPresetUpdated()
    event.trigger(this.events.cameraPresetUpdated, { preset = this.preset })
end

---@private
---@param parent tes3uiElement
function this.buildAnchorGroup(parent)
    local group = this.debugSectionBuilder.createGroup({
        parent = parent,
        title = this.translations.get(this.translationKey.presetAnchor),
    })

    local button = this.guiBuilder.createButton({ parent = group })
        :withText(this.anchorLabel())
        :build()

    button:registerBefore(tes3.uiEvent.mouseClick, function()
        this.toggleAnchor(button)
    end)
end

---@private
---@return string
function this.anchorLabel()
    local key = this.translationKey.presetAnchorActor
    if this.preset.anchor == this.cameraAnchors.player then
        key = this.translationKey.presetAnchorPlayer
    end

    return this.translations.get(key)
end

---@private
---@param button tes3uiElement
function this.toggleAnchor(button)
    if this.preset.anchor == this.cameraAnchors.player then
        this.preset.anchor = this.cameraAnchors.actor
    else
        this.preset.anchor = this.cameraAnchors.player
    end

    button.text = this.anchorLabel()
    this.triggerCameraPresetUpdated()
end

---@private
---@param parent tes3uiElement
function this.buildPositionSection(parent)
    local keys = this.translationKey

    this.debugSliderSection.create({
        parent = parent,
        title = this.translations.get(keys.positionCategory),
        sliders = {
            this.createSlider({ label = keys.presetVerticalAnchor, step = 0.01, field = "verticalAnchor" }),
            this.createSlider({ label = keys.distance, step = 1, field = "distance" }),
            this.createSlider({ label = keys.horizontalOffset, step = 1, field = "horizontalOffset" }),
            this.createSlider({ label = keys.verticalOffset, step = 1, field = "verticalOffset" }),
        },
    })
end

---@private
---@param parent tes3uiElement
function this.buildRotationSection(parent)
    local keys = this.translationKey

    this.debugSliderSection.create({
        parent = parent,
        title = this.translations.get(keys.rotationCategory),
        sliders = {
            this.createSlider({ label = keys.pitchOffset, step = 0.5, field = "pitchOffset" }),
            this.createSlider({ label = keys.yawOffset, step = 0.5, field = "yawOffset" }),
            this.createSlider({ label = keys.rollOffset, step = 0.5, field = "rollOffset" }),
        },
    })
end

---@private
---@param parent tes3uiElement
function this.buildTimingSection(parent)
    local keys = this.translationKey

    this.debugSliderSection.create({
        parent = parent,
        title = this.translations.get(keys.timingCategory),
        sliders = {
            this.createSlider({ label = keys.animationDuration, step = 0.1, field = "animationDuration" }),
        },
    })
end

---@class cameraPresetSection.createSlider.param
---@field public label string
---@field public step number
---@field public field string

---@private
---@param params cameraPresetSection.createSlider.param
---@return debugSliderDefinition
function this.createSlider(params)
    local preset = this.preset
    local range = this.cameraPresetRanges[params.field]

    return {
        label = this.translations.get(params.label),
        min = range.min,
        max = range.max,
        step = params.step,
        default = preset[params.field],
        onChange = function(value)
            preset[params.field] = value
            this.triggerCameraPresetUpdated()
        end,
    }
end

---@private
---@param parent tes3uiElement
function this.buildButtonRow(parent)
    local guiBuilder = this.guiBuilder

    local row = guiBuilder.createBlock({ parent = parent })
        :withFlowDirection(tes3.flowDirection.leftToRight)
        :withAutoSize()
        :build()

    local replayButton = guiBuilder.createButton({ parent = row })
        :withText(this.translations.get(this.translationKey.debugReplay))
        :build()

    replayButton:registerBefore(tes3.uiEvent.mouseClick, function()
        event.trigger(this.events.cameraAnimationReplayed)
    end)

    local saveButton = guiBuilder.createButton({ parent = row })
        :withText(this.translations.get(this.translationKey.debugSavePreset, { id = this.preset.id }))
        :build()

    saveButton:registerBefore(tes3.uiEvent.mouseClick, this.confirmSavePreset)
end

---@private
function this.confirmSavePreset()
    tes3ui.showMessageMenu({
        message = this.translations.get(this.translationKey.debugSavePresetConfirm, { id = this.preset.id }),
        cancels = true,
        leaveMenuMode = false,
        buttons = {
            {
                text = this.translations.get(this.translationKey.debugSave),
                callback = this.savePreset,
            },
        },
    })
end

---@private
function this.savePreset()
    this.cameraPresetLoader.savePreset(this.preset)
    tes3.messageBox(this.translations.get(this.translationKey.debugPresetSaved, { id = this.preset.id }))
end

return this
