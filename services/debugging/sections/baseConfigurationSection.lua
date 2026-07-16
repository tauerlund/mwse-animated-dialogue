---@class baseConfigurationSection : debugSection
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
---@type actorController
this.actorController = nil

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
---@type string|nil
this.selectedId = nil

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
    this.actorController = services.actorController
    this.translations = services.translations
    this.translationKey = services.enums.translationKey

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
function this.onDialogueEnded()
    this.selectedId = nil
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
        hint = translations.get(keys.debugBaseConfigurationHint),
        entries = entries,
        onSelect = this.applyConfiguration,
        onHelp = this.showTooltip,
    })
end

---@private
---@return tes3uiElement
function this.createSection()
    return this.debugSectionBuilder.create({
        parent = this.block,
        title = this.translations.get(this.translationKey.debugBaseConfiguration),
    })
end

---@private
---@return debugAnimationEntry[]
function this.buildEntries()
    local entries = {}

    for _, configuration in ipairs(this.animationLoader.getBaseConfigurations()) do
        ---@type debugAnimationEntry
        local entry = {
            label = configuration.id,
            baseConfiguration = configuration,
        }

        if configuration.id == this.selectedId then
            table.insert(entries, 1, entry)
        else
            table.insert(entries, entry)
        end
    end

    return entries
end

---@private
---@param entry debugAnimationEntry
function this.applyConfiguration(entry)
    if not this.actor then
        return
    end

    local bodyAnimator = this.actorController.getActorBodyAnimator()
    if not bodyAnimator or not bodyAnimator.applyConfiguration then
        return
    end

    this.selectedId = entry.baseConfiguration.id

    bodyAnimator:applyConfiguration(this.actor, entry.baseConfiguration)
end

---@private
---@param entry debugAnimationEntry
function this.showTooltip(entry)
    this.debugTooltip.showJson(entry.baseConfiguration)
end

return this
