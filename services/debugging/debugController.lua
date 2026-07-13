---@class debugController : initializedService
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
---@type guiBuilder
this.guiBuilder = nil

---@private
---@type debugSliderPanel
this.debugSliderPanel = nil

---@private
---@type animationLoader
this.animationLoader = nil

---@private
---@type actorController
this.actorController = nil

---@private
---@type translations
this.translations = nil

---@private
---@type translationKey
this.translationKey = nil

---@private
this.dialogueActive = false

---@private
this.paused = false

---@private
---@type tes3uiElement|nil
this.debugHud = nil

---@private
---@type tes3uiElement|nil
this.statusLabel = nil

---@private
---@type tes3uiElement|nil
this.previewContainer = nil

---@private
---@type tes3uiElement[]|nil
this.debugPanels = nil

---@private
---@type tes3reference|nil
this.currentNpc = nil

---@private
---@type previewDropdown[]
this.previewDropdowns = {}

---@private
---@type eventHandlers
this.eventHandlers = nil

---@public
---@param services serviceCollection
---@return boolean, string|nil
function this.initialize(services)
    this.eventRegistrar = services.eventRegistrar
    this.events = services.enums.events
    this.settings = services.settings
    this.guiBuilder = services.guiBuilder
    this.debugSliderPanel = services.debuggingSliderPanel
    this.animationLoader = services.animationLoader
    this.actorController = services.actorController
    this.translations = services.translations
    this.translationKey = services.enums.translationKey

    local events = this.events

    this.eventHandlers = {
        [events.dialogueStarted] = this.onDialogueStarted,
        [events.dialogueEnded]   = this.onDialogueEnded,
        [events.gamePaused]      = this.onGamePaused,
        [events.gameUnpaused]    = this.onGameUnpaused,
        [events.propSpawned]     = this.onPropSpawned,
        [events.propDespawned]   = this.onPropDespawned,
        [tes3.event.keyDown]     = this.onKeyDown,
    }

    this.eventRegistrar.register(this.eventHandlers)

    return true, nil
end

---@public
function this.uninitialize()
    this.eventRegistrar.unregister(this.eventHandlers)
end

---@private
---@param e dialogueStartedEventData
function this.onDialogueStarted(e)
    this.dialogueActive = true
    this.paused = false
    this.currentNpc = e.actor

    if this.settings.debuggingEnabled then
        this.showDebugHud()
    end
end

---@private
function this.onDialogueEnded()
    this.dialogueActive = false
    this.paused = false
    this.currentNpc = nil
    this.hideDebugHud()
    this.destroyDebugPanels()
end

---@private
---@param e propSpawnedEventData
function this.onPropSpawned(e)
    if not this.settings.debuggingEnabled then
        return
    end

    this.destroyDebugPanels()
    this.debugPanels = this.debugSliderPanel.createTransformSliders(e.node)
end

---@private
function this.onPropDespawned()
    this.destroyDebugPanels()
end

---@private
function this.destroyDebugPanels()
    if not this.debugPanels then
        return
    end

    for _, panel in ipairs(this.debugPanels) do
        panel:destroy()
    end

    this.debugPanels = nil
end

---@private
function this.onGamePaused()
    this.paused = true
    this.updateStatusLabel()
end

---@private
function this.onGameUnpaused()
    this.paused = false
    this.updateStatusLabel()
end

---@private
function this.showDebugHud()
    if this.debugHud then
        return
    end

    local menu = this.guiBuilder.createMenu({
            id = "AnimatedDialogue:DebugHud",
            fixedFrame = true,
            dragFrame = false,
            modal = false,
        })
        :withFlowDirection(tes3.flowDirection.topToBottom)
        :withAutoSize()
        :withPositionAlign({ x = 0.5, y = 0.04 })
        :withCallback(this.events.settingsUpdated, this.onSettingsUpdated)
        :build()

    local content = this.guiBuilder.createBlock({ parent = menu })
        :withFlowDirection(tes3.flowDirection.topToBottom)
        :withAutoSize()
        :withPadding({ all = 8 })
        :build()

    local translations = this.translations
    local keys = this.translationKey

    this.guiBuilder.createLabel({ parent = content })
        :withText(translations.get(keys.debugHudTitle))
        :withColor(tes3ui.getPalette(tes3.palette.headerColor))
        :build()

    this.guiBuilder.createLabel({ parent = content })
        :withText(translations.get(keys.debugHudPause, { key = this.getKeyName(this.settings.debugPauseKey) }))
        :build()

    this.guiBuilder.createLabel({ parent = content })
        :withText(translations.get(keys.debugHudStep, { key = this.getKeyName(this.settings.debugStepKey) }))
        :build()

    this.statusLabel = this.guiBuilder.createLabel({ parent = content })
        :build()

    this.previewContainer = this.guiBuilder.createBlock({ parent = content })
        :withFlowDirection(tes3.flowDirection.topToBottom)
        :withAutoSize()
        :build()

    this.buildPreviewControls(this.previewContainer)

    this.debugHud = menu
    this.updateStatusLabel()
end

---@private
function this.onSettingsUpdated()
    if not this.previewContainer then
        return
    end

    this.previewContainer:destroyChildren()
    this.buildPreviewControls(this.previewContainer)
end

---@private
---@param content tes3uiElement
function this.buildPreviewControls(content)
    this.previewDropdowns = {}

    if not this.settings.actorAnimEnabled then
        return
    end

    local baseEntries = this.buildBaseEntries()
    local overrideEntries = this.buildOverrideEntries()

    if #baseEntries > 0 then
        this.buildDropdown(content, "Preview Animation",
            "Force a base clip onto this NPC.", baseEntries,
            this.previewAnimation)
    end

    if #overrideEntries > 0 then
        this.buildDropdown(content, "Trigger Override",
            "Simulate a dialogue line: override clip + prop.", overrideEntries,
            function(entry)
                if not this.currentNpc then
                    return
                end

                this.triggerDialogueInfo(entry.dialogueId)
            end)
    end
end

---@private
---@param entry previewEntry
function this.previewAnimation(entry)
    if not this.currentNpc then
        return
    end

    local bodyAnimator = this.actorController.getActorBodyAnimator()
    if not bodyAnimator or not bodyAnimator.play then
        return
    end

    bodyAnimator:play({
        actor     = this.currentNpc,
        animation = entry.animation,
    })
end

---@private
---@return previewEntry[]
function this.buildBaseEntries()
    local entries = {}

    for _, configuration in ipairs(this.animationLoader.getBaseConfigurations()) do
        table.insert(entries, {
            label = string.format("%s / idle", configuration.id),
            kind = "base",
            animation = configuration.idle,
        })

        if configuration.talk then
            for i, talk in ipairs(configuration.talk) do
                table.insert(entries, {
                    label = string.format("%s / talk %d", configuration.id, i),
                    kind = "base",
                    animation = talk,
                })
            end
        end
    end

    return entries
end

---@private
---@return previewEntry[]
function this.buildOverrideEntries()
    local entries = {}
    local configurations = this.animationLoader.getOverrideConfigurations()

    for _, dialogueId in ipairs(this.collectOverrideIds()) do
        local configuration = configurations[dialogueId]
        table.insert(entries, {
            label = string.format("%s (%s)", dialogueId, configuration.source or "?"),
            kind = "override",
            dialogueId = dialogueId,
            configuration = configuration,
        })
    end

    return entries
end

---@private
---@param content tes3uiElement
---@param caption string
---@param hint string
---@param entries previewEntry[]
---@param onSelect fun(entry: previewEntry)
---@return previewDropdown
function this.buildDropdown(content, caption, hint, entries, onSelect)
    this.guiBuilder.createDivider({ parent = content }):build()

    this.guiBuilder.createLabel({ parent = content })
        :withText(caption)
        :withColor(tes3ui.getPalette(tes3.palette.headerColor))
        :build()

    local header = this.guiBuilder.createTextSelect({ parent = content })
        :withText(entries[1].label)
        :build()
    this.applyTextSelectColors(header)

    local listParent = this.guiBuilder.createBlock({ parent = content })
        :withFlowDirection(tes3.flowDirection.topToBottom)
        :withAutoSize()
        :build()

    this.guiBuilder.createLabel({ parent = content })
        :withText(hint)
        :withColor(tes3ui.getPalette(tes3.palette.disabledColor))
        :build()

    ---@type previewDropdown
    local dropdown = {
        entries = entries,
        header = header,
        listParent = listParent,
        open = false,
        onSelect = onSelect,
    }

    header:registerBefore(tes3.uiEvent.mouseClick, function()
        this.toggleDropdown(dropdown)
    end)

    table.insert(this.previewDropdowns, dropdown)

    return dropdown
end

---@private
---@return string[]
function this.collectOverrideIds()
    local ids = {}

    for dialogueId in pairs(this.animationLoader.getOverrideConfigurations()) do
        table.insert(ids, dialogueId)
    end

    table.sort(ids)

    return ids
end

---@private
---@param dropdown previewDropdown
function this.toggleDropdown(dropdown)
    if dropdown.open then
        this.closeDropdown(dropdown)
    else
        this.openDropdown(dropdown)
    end
end

---@private
---@param dropdown previewDropdown
function this.openDropdown(dropdown)
    this.closeAllDropdowns()

    dropdown.open = true

    for i, entry in ipairs(dropdown.entries) do
        local item = this.guiBuilder.createTextSelect({ parent = dropdown.listParent })
            :withText(entry.label)
            :withBorder({ left = 6 })
            :build()
        this.applyTextSelectColors(item)

        item:registerBefore(tes3.uiEvent.mouseClick, function()
            this.selectDropdown(dropdown, i)
        end)

        item:register(tes3.uiEvent.help, function()
            this.showJsonTooltip(entry)
        end)
    end

    this.refreshHudLayout()
end

---@private
---@param dropdown previewDropdown
function this.closeDropdown(dropdown)
    dropdown.open = false
    dropdown.listParent:destroyChildren()

    this.refreshHudLayout()
end

---@private
function this.closeAllDropdowns()
    for _, dropdown in ipairs(this.previewDropdowns) do
        if dropdown.open then
            dropdown.open = false
            dropdown.listParent:destroyChildren()
        end
    end
end

---@private
---@param dropdown previewDropdown
---@param index integer
function this.selectDropdown(dropdown, index)
    local entry = dropdown.entries[index]
    dropdown.header.text = entry.label

    this.closeDropdown(dropdown)
    dropdown.onSelect(entry)
end

---@private
---@param dialogueId string
function this.triggerDialogueInfo(dialogueId)
    local eventData = {
        info = { id = dialogueId },
        actor = this.currentNpc,
    }

    event.trigger(this.events.dialogueInfo, eventData)
end

---@private
---@param element tes3uiElement
function this.applyTextSelectColors(element)
    element.widget.idle = tes3ui.getPalette(tes3.palette.normalColor)
    element.widget.over = tes3ui.getPalette(tes3.palette.normalOverColor)
    element.widget.pressed = tes3ui.getPalette(tes3.palette.normalPressedColor)
end

---@private
---@param entry previewEntry
function this.showJsonTooltip(entry)
    local tooltip = tes3ui.createTooltipMenu()

    local block = this.guiBuilder.createBlock({ parent = tooltip })
        :withFlowDirection(tes3.flowDirection.topToBottom)
        :withAutoSize()
        :withPadding({ all = 6 })
        :build()

    this.guiBuilder.createLabel({ parent = block })
        :withText(json.encode(entry.configuration or entry.animation, { indent = true }))
        :build()

    tooltip:updateLayout()
end

---@private
function this.refreshHudLayout()
    if this.debugHud then
        this.debugHud:updateLayout()
    end
end

---@private
function this.updateStatusLabel()
    if not this.statusLabel then
        return
    end

    local translations = this.translations
    local keys = this.translationKey

    if this.paused then
        this.statusLabel.text = translations.get(keys.debugHudStatusPaused)
        this.statusLabel.color = tes3ui.getPalette(tes3.palette.healthColor)
    else
        this.statusLabel.text = translations.get(keys.debugHudStatusRunning)
        this.statusLabel.color = tes3ui.getPalette(tes3.palette.normalColor)
    end

    if this.debugHud then
        this.debugHud:updateLayout()
    end
end

---@private
---@param bind mwseKeyCombo
---@return string
function this.getKeyName(bind)
    return mwse.mcm.getKeyComboName(bind) or "Unbound"
end

---@private
function this.hideDebugHud()
    if not this.debugHud then
        return
    end

    this.debugHud:destroy()
    this.debugHud = nil
    this.statusLabel = nil
    this.previewContainer = nil
    this.previewDropdowns = {}
end

---@private
---@param e keyDownEventData
function this.onKeyDown(e)
    if not this.settings.debuggingEnabled then
        return
    end

    if not this.dialogueActive then
        return
    end

    if this.matchesKey(e, this.settings.debugPauseKey) then
        this.togglePause()
        return
    end

    if this.matchesKey(e, this.settings.debugStepKey) then
        this.stepFrame()
        return
    end
end

---@private
function this.togglePause()
    if this.paused then
        event.trigger(this.events.gameUnpaused)
    else
        event.trigger(this.events.gamePaused)
    end
end

---@private
function this.stepFrame()
    if not this.paused then
        return
    end

    event.trigger(this.events.gameUnpaused)
    event.register(tes3.event.enterFrame, this.onStepFrame, { priority = -100, doOnce = true })
end

---@private
function this.onStepFrame()
    event.trigger(this.events.gamePaused)
end

---@private
---@param e keyDownEventData
---@param bind mwseKeyCombo|nil
---@return boolean
function this.matchesKey(e, bind)
    if not bind then
        return false
    end

    return e.keyCode == bind.keyCode
        and (not not e.isShiftDown) == (not not bind.isShiftDown)
        and (not not e.isControlDown) == (not not bind.isControlDown)
        and (not not e.isAltDown) == (not not bind.isAltDown)
end

return this
