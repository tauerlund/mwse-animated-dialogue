---@class debugAnimationsTab : debugTab
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
---@type debugDropdown
this.debugDropdown = nil

---@private
---@type debugSliderSection
this.debugSliderSection = nil

---@private
---@type debugSection
this.debugSection = nil

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

---@public
---@type string
this.title = nil

---@private
---@type tes3uiElement|nil
this.content = nil

---@private
---@type tes3reference|nil
this.actor = nil

---@private
---@type niNode
this.node = nil

---@private
---@type tes3uiElement|nil
this.propBlock = nil

---@private
---@type debugDropdownHandle[]
this.handles = {}

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
    this.debugDropdown = services.debugDropdown
    this.debugSliderSection = services.debugSliderSection
    this.debugSection = services.debugSection
    this.animationLoader = services.animationLoader
    this.actorController = services.actorController
    this.translations = services.translations
    this.translationKey = services.enums.translationKey

    this.title = this.translations.get(this.translationKey.debugTabAnimations)

    this.eventHandlers = {
        [this.events.settingsUpdated] = this.onSettingsUpdated,
        [this.events.propSpawned] = this.onPropSpawned,
        [this.events.propDespawned] = this.onPropDespawned,
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
---@param params debugTab.build.param
function this.build(params)
    this.content = params.parent
    this.actor = params.actor

    this.buildContent()
end

---@public
function this.destroy()
    this.releaseHandles()
    this.content = nil
    this.propBlock = nil
    this.actor = nil
end

---@private
---@param e propSpawnedEventData
function this.onPropSpawned(e)
    if not this.settings.debuggingEnabled then
        return
    end

    this.node = e.node
    this.rebuildPropContent()
end

---@private
function this.onPropDespawned()
    this.node = nil
    this.rebuildPropContent()
end

---@private
function this.onDialogueEnded()
    this.node = nil
end

---@private
function this.releaseHandles()
    for _, handle in ipairs(this.handles) do
        this.debugDropdown.release(handle)
    end

    this.handles = {}
end

---@private
function this.onSettingsUpdated()
    if not this.content then
        return
    end

    this.releaseHandles()
    this.content:destroyChildren()
    this.buildContent()
    this.content:getTopLevelMenu():updateLayout()
end

---@private
function this.buildContent()
    this.buildAnimationDropdowns()

    this.propBlock = this.guiBuilder.createBlock({ parent = this.content })
        :withFlowDirection(tes3.flowDirection.topToBottom)
        :withAutoSize()
        :withProportional({ width = 1.0 })
        :build()

    this.buildPropContent()
end

---@private
function this.buildAnimationDropdowns()
    local translations = this.translations
    local keys = this.translationKey

    if not this.settings.actorAnimEnabled then
        this.guiBuilder.createLabel({ parent = this.content })
            :withText(translations.get(keys.debugActorAnimDisabledHint))
            :withColor(tes3ui.getPalette(tes3.palette.disabledColor))
            :withWrapText()
            :build()

        return
    end

    local baseEntries = this.buildBaseEntries()
    local overrideEntries = this.buildOverrideEntries()

    if #baseEntries > 0 then
        local section = this.debugSection.create({
            parent = this.content,
            title = translations.get(keys.debugPreviewAnimation),
        })

        table.insert(this.handles, this.debugDropdown.create({
            parent = section,
            hint = translations.get(keys.debugPreviewAnimationHint),
            entries = baseEntries,
            onSelect = this.previewAnimation,
            onHelp = this.showJsonTooltip,
        }))
    end

    if #overrideEntries > 0 then
        local section = this.debugSection.create({
            parent = this.content,
            title = translations.get(keys.debugTriggerOverride),
        })

        table.insert(this.handles, this.debugDropdown.create({
            parent = section,
            hint = translations.get(keys.debugTriggerOverrideHint),
            entries = overrideEntries,
            onSelect = this.triggerOverride,
            onHelp = this.showJsonTooltip,
        }))
    end
end

---@private
---@param entry previewEntry
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
---@param entry previewEntry
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
---@return previewEntry[]
function this.buildBaseEntries()
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
            dialogueId = dialogueId,
            configuration = configuration,
        })
    end

    return entries
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
function this.rebuildPropContent()
    if not this.propBlock then
        return
    end

    this.propBlock:destroyChildren()
    this.buildPropContent()
    this.propBlock:getTopLevelMenu():updateLayout()
end

---@private
function this.buildPropContent()
    local section = this.debugSection.create({
        parent = this.propBlock,
        title = this.translations.get(this.translationKey.debugPropSection),
    })

    if not this.node then
        this.guiBuilder.createLabel({ parent = section })
            :withText(this.translations.get(this.translationKey.debugNoPropSpawned))
            :withColor(tes3ui.getPalette(tes3.palette.disabledColor))
            :withWrapText()
            :build()

        return
    end

    this.buildTranslationSection(section)
    this.buildRotationSection(section)
    this.buildScaleSection(section)
end

---@private
---@param parent tes3uiElement
function this.buildTranslationSection(parent)
    local node = this.node
    local t = node.translation:copy()

    local function apply()
        node.translation = tes3vector3.new(t.x, t.y, t.z)
        node:update()
    end

    this.debugSliderSection.create({
        parent = parent,
        title = this.translations.get(this.translationKey.debugTranslationSection),
        onCopy = function()
            return string.format('{ "x": %.4f, "y": %.4f, "z": %.4f }', t.x, t.y, t.z)
        end,
        sliders = {
            {
                label = "X",
                min = -50,
                max = 50,
                step = 0.1,
                default = t.x,
                onChange = function(v)
                    t.x = v
                    apply()
                end
            },
            {
                label = "Y",
                min = -50,
                max = 50,
                step = 0.1,
                default = t.y,
                onChange = function(v)
                    t.y = v
                    apply()
                end
            },
            {
                label = "Z",
                min = -50,
                max = 50,
                step = 0.1,
                default = t.z,
                onChange = function(v)
                    t.z = v
                    apply()
                end
            },
        },
    })
end

---@private
---@param parent tes3uiElement
function this.buildRotationSection(parent)
    local node = this.node
    local euler = node.rotation:toEulerXYZ()
    local rx, ry, rz = euler.x, euler.y, euler.z

    local function apply()
        local m = tes3matrix33.new()
        m:fromEulerXYZ(rx, ry, rz)
        node.rotation = m
        node:update()
    end

    this.debugSliderSection.create({
        parent = parent,
        title = this.translations.get(this.translationKey.debugRotationSection),
        onCopy = function()
            return string.format('{ "x": %.4f, "y": %.4f, "z": %.4f }', rx, ry, rz)
        end,
        sliders = {
            {
                label = "X",
                min = -math.pi,
                max = math.pi,
                step = 0.01,
                default = rx,
                onChange = function(v)
                    rx = v
                    apply()
                end
            },
            {
                label = "Y",
                min = -math.pi,
                max = math.pi,
                step = 0.01,
                default = ry,
                onChange = function(v)
                    ry = v
                    apply()
                end
            },
            {
                label = "Z",
                min = -math.pi,
                max = math.pi,
                step = 0.01,
                default = rz,
                onChange = function(v)
                    rz = v
                    apply()
                end
            },
        },
    })
end

---@private
---@param parent tes3uiElement
function this.buildScaleSection(parent)
    local node = this.node

    this.debugSliderSection.create({
        parent = parent,
        title = this.translations.get(this.translationKey.debugScaleSection),
        onCopy = function()
            return string.format("%.4f", node.scale)
        end,
        sliders = {
            {
                label = "S",
                min = 0.01,
                max = 5,
                step = 0.01,
                default = node.scale,
                onChange = function(v)
                    node.scale = v
                    node:update()
                end
            },
        },
    })
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

return this
