---@class voiceLineSection : debugSection
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
---@type voiceLoader
this.voiceLoader = nil

---@private
---@type soundPlayer
this.soundPlayer = nil

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
    this.events = services.constants.events
    this.settings = services.settings
    this.debugSectionBuilder = services.debugSectionBuilder
    this.debugDropdown = services.debugDropdown
    this.debugTooltip = services.debugTooltip
    this.voiceLoader = services.voiceLoader
    this.soundPlayer = services.soundPlayer
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
    local translations = this.translations
    local keys = this.translationKey
    local section = this.createSection()

    if not this.settings.voiceLinesEnabled then
        this.debugSectionBuilder.createHint({
            parent = section,
            text = translations.get(keys.debugVoiceLinesDisabledHint),
        })

        return
    end

    local entries = this.buildEntries()
    if #entries == 0 then
        this.debugSectionBuilder.createHint({
            parent = section,
            text = translations.get(keys.debugNoVoiceLinesHint),
        })

        return
    end

    this.dropdown = this.debugDropdown.create({
        parent = section,
        hint = translations.get(keys.debugVoiceLineHint),
        entries = entries,
        onSelect = this.playSound,
        onHelp = this.showTooltip,
    })
end

---@private
---@return tes3uiElement
function this.createSection()
    return this.debugSectionBuilder.create({
        parent = this.block,
        title = this.translations.get(this.translationKey.debugVoiceLines),
    })
end

---@private
---@return debugVoiceEntry[]
function this.buildEntries()
    local entries = {}

    for _, configuration in ipairs(this.voiceLoader.getConfigurations()) do
        for _, sound in ipairs(configuration.sounds) do
            table.insert(entries, {
                label = string.format("%s (%s)", sound, configuration.source or "?"),
                configuration = configuration,
                sound = sound,
            })
        end
    end

    return entries
end

---@private
---@param entry debugVoiceEntry
function this.playSound(entry)
    if not this.actor then
        return
    end

    this.soundPlayer.say({
        reference = this.actor,
        file = entry.sound,
        pitch = entry.configuration.pitch,
    })
end

---@private
---@param entry debugVoiceEntry
function this.showTooltip(entry)
    this.debugTooltip.showJson(entry.configuration)
end

return this
