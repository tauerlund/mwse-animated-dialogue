---@class previewAnimationSection : debugSection
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
        hint = translations.get(keys.debugPreviewAnimationHint),
        entries = entries,
        onSelect = this.previewAnimation,
        onHelp = this.showTooltip,
    })
end

---@private
---@return tes3uiElement
function this.createSection()
    return this.debugSectionBuilder.create({
        parent = this.block,
        title = this.translations.get(this.translationKey.debugPreviewAnimation),
    })
end

---@private
---@return debugAnimationEntry[]
function this.buildEntries()
    local entries = {}

    for _, configuration in ipairs(this.animationLoader.getBaseConfigurations()) do
        table.insert(entries, {
            label = string.format("%s / idle", configuration.id),
            animation = configuration.idle,
        })

        if configuration.talk then
            for i, talk in ipairs(configuration.talk) do
                table.insert(entries, {
                    label = string.format("%s / talk %d", configuration.id, i),
                    animation = talk,
                })
            end
        end

        if configuration.variations then
            for i, variation in ipairs(configuration.variations) do
                table.insert(entries, {
                    label = string.format("%s / variation %d", configuration.id, i),
                    animation = variation,
                })
            end
        end
    end

    return entries
end

---@private
---@param entry debugAnimationEntry
function this.previewAnimation(entry)
    if not this.actor then
        return
    end

    local bodyAnimator = this.actorController.getActorBodyAnimator()
    if not bodyAnimator or not bodyAnimator.play then
        return
    end

    bodyAnimator:play({
        actor     = this.actor,
        animation = entry.animation,
    })
end

---@private
---@param entry debugAnimationEntry
function this.showTooltip(entry)
    this.debugTooltip.showJson(entry.animation)
end

return this
