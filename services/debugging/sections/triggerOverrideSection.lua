---@class triggerOverrideSection : debugSection
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
---@type debugSectionBuilder
this.debugSectionBuilder = nil

---@private
---@type debugDropdown
this.debugDropdown = nil

---@private
---@type debugTooltip
this.debugTooltip = nil

---@private
---@type animationLoader
this.animationLoader = nil

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
---@type tes3reference|nil
this.actor = nil

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
    this.events = services.enums.events
    this.settings = services.settings
    this.debugSectionBuilder = services.debugSectionBuilder
    this.debugDropdown = services.debugDropdown
    this.debugTooltip = services.debugTooltip
    this.animationLoader = services.animationLoader
    this.translations = services.translations
    this.translationKey = services.enums.translationKey

    this.eventHandlers = {
        [this.events.settingsUpdated] = this.onSettingsUpdated,
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
    this.actor = params.actor

    this.buildContent()
end

---@public
function this.destroy()
    this.removeDropdown()
    this.block = nil
    this.actor = nil
end

---@private
function this.onSettingsUpdated()
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
    local translations = this.translations
    local keys = this.translationKey

    if not this.settings.actorAnimEnabled then
        this.debugSectionBuilder.createHint({
            parent = this.createSection(),
            text = translations.get(keys.debugActorAnimDisabledHint),
        })

        return
    end

    local entries = this.buildEntries()
    if #entries == 0 then
        return
    end

    this.dropdown = this.debugDropdown.create({
        parent = this.createSection(),
        hint = translations.get(keys.debugTriggerOverrideHint),
        entries = entries,
        onSelect = this.triggerOverride,
        onHelp = this.showTooltip,
    })
end

---@private
---@return tes3uiElement
function this.createSection()
    return this.debugSectionBuilder.create({
        parent = this.block,
        title = this.translations.get(this.translationKey.debugTriggerOverride),
    })
end

---@private
---@return debugAnimationEntry[]
function this.buildEntries()
    local entries = {}
    local configurations = this.animationLoader.getOverrideConfigurations()

    for _, dialogueId in ipairs(this.collectDialogueIds()) do
        local configuration = configurations[dialogueId]
        table.insert(entries, {
            label = string.format("%s (%s)", dialogueId, configuration.source or "?"),
            dialogueId = dialogueId,
            configuration = configuration,
        })
    end

    return entries
end

---@private
---@return string[]
function this.collectDialogueIds()
    local ids = {}

    for dialogueId in pairs(this.animationLoader.getOverrideConfigurations()) do
        table.insert(ids, dialogueId)
    end

    table.sort(ids)

    return ids
end

---@private
---@param entry debugAnimationEntry
function this.triggerOverride(entry)
    if not this.actor then
        return
    end

    local eventData = {
        info = { id = entry.dialogueId },
        actor = this.actor,
    }

    event.trigger(this.events.dialogueInfo, eventData)
end

---@private
---@param entry debugAnimationEntry
function this.showTooltip(entry)
    this.debugTooltip.showJson(entry.configuration)
end

return this
